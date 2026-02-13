## Description #############################################################################
#
# Private functions for the Typst back end.
#
############################################################################################

# == Alignment =============================================================================

"""
    _typst__alignment(a::Symbol) -> String

Get the Typst alignment string corresponding to the given alignment symbol `a`. If the
alignment symbol is not recognized, it defaults to "right".
"""
_typst__alignment(a::Symbol) = get(_TYPST__ALIGNMENT_MAP, a, "right")

"""
    _typst__alignment_configuration(td::TableData) -> String

Create the Typst alignment configuration string for the given `td::TableData`.
"""
function _typst__alignment_configuration(td::TableData)
    num_columns = td.num_columns

    alignment_str = IOBuffer(sizehint = 8num_columns)

    # == Row Number Column =================================================================

    td.show_row_number_column &&
        print(alignment_str, _typst__alignment(_row_number_column_alignment(td)) * ", ")

    # == Row Labels ========================================================================

    _has_row_labels(td) &&
        print(alignment_str, _typst__alignment(_row_label_column_alignment(td)) * ", ")

    # == Data Columns ======================================================================

    nc = if td.maximum_number_of_columns >= 0
        min(td.maximum_number_of_columns, num_columns)
    else
        num_columns
    end

    for i in 1:nc
        print(alignment_str, _typst__alignment(_data_column_alignment(td, i)) * ", ")
    end

    # == Continuation Column ===============================================================

    nc < num_columns && print(alignment_str, _typst__alignment(:c) * ", ")

    return String(take!(alignment_str)) |> rstrip
end

# == Attributes ============================================================================

"""
    _typst__cell_and_text_properties(vproperties::Vector{TypstPair}) -> Tuple{Vector{TypstPair}, Vector{TypstPair}}

Split `vproperties` into the properties that must be applied to the Typst `table.cell` and
those that must be applied to the text content.

The first returned vector contains only attributes listed in `_TYPST__CELL_ATTRIBUTES`. The
second returned vector contains only valid text properties prefixed with `text-`, with this
prefix removed.
"""
function _typst__cell_and_text_properties(vproperties::Vector{TypstPair})
    # Separate cell and text attributes in a single pass to reduce allocations.
    cell_properties = TypstPair[]
    text_properties = TypstPair[]
    sizehint!(cell_properties, length(vproperties))
    sizehint!(text_properties, length(vproperties))

    for (k, v) in vproperties
        if k ∈ _TYPST__CELL_ATTRIBUTES
            push!(cell_properties, k => v)
        end

        if startswith(k, "text-")
            text_key = SubString(k, 6)
            text_key ∈ _TYPST__TEXT_ATTRIBUTES &&
                push!(text_properties, String(text_key) => v)
        end
    end

    return cell_properties, text_properties
end

# == Cells =================================================================================

"""
    _typst__table_cell(content::AbstractString[, properties::Vector{TypstPair}]; kwargs...) -> String

Create a Typst table cell with `content` and optional `properties`. If `properties` is not
provided or empty, a basic cell is created with the content. If `properties` are provided, a
`table.cell` component is created with the content and properties.

# Keywords

- `il::Int`: Indentation level for formatting.
    (**Default**: 2)
- `ns::Int`: Number of spaces for indentation.
    (**Default**: 2)
- `wrap_column::Int`: Column width threshold for wrapping content.
    (**Default**: 92)
"""
function _typst__table_cell(
    content::AbstractString,
    properties::Vector{TypstPair};
    il::Int = 2,
    ns::Int = 2,
    wrap_column::Int = 92
)
    isempty(properties) && return _typst__table_cell(content; il, ns, wrap_column)
    return _typst__create_component("table.cell", content, properties; il, ns, wrap_column)
end

function _typst__table_cell(
    content::AbstractString;
    il::Int = 2,
    ns::Int = 2,
    wrap_column::Int = 92
)
    cl = length(content)
    id_str = repeat(" ", ns)

    _typst__should_wrap(cl, il, ns, wrap_column) && return "[\n$id_str$content\n]"
    return "[$content]"
end

# == Components ============================================================================

"""
    _typst__create_component(component::String, content::String; kwargs...) -> String

Create an HTML `component` with the `content`.

# Keywords

- `properties::Union{Nothing, Vector{TypstPair}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Vector{TypstPair}}`: Tag style.
    (**Default**: `nothing`)
"""
function _typst__create_component(
    component::String,
    content::String,
    properties::Union{Nothing, Vector{TypstPair}} = nothing;
    il::Int = 0,
    ns::Int = 2,
    wrap_column::Int = 92,
)
    open_tag = _typst__open_component(component, properties)

    line_length = length(open_tag) + length(content) + 1

    if _typst__should_wrap(line_length, il, ns, wrap_column)
        buf = IOBuffer()

        println(buf, open_tag)
        # Notice that we must print at the first indentation level because this text will
        # also be indented when printing to the output buffer.
        _aprintln(buf, content, 1, ns)
        print(buf, "]")

        return String(take!(buf))
    end

    return open_tag * content * "]"
end

"""
    _typst__open_component(component::String, properties::Union{Nothing, Vector{TypstPair}} = nothing) -> String

Create the string that opens the Typst `component` with the given `properties`.
"""
function _typst__open_component(
    component::String,
    properties::Union{Nothing, Vector{TypstPair}} = nothing
)
    prop_str = isnothing(properties) ? "" : "($(_typst__property_list(properties)))"
    return "$component$prop_str["
end

"""
    _typst__property_list(properties::Vector{TypstPair}) -> String

Create a Typst property list string from the given vector of `properties`.
"""
function _typst__property_list(properties::Vector{TypstPair})
    buf = IOBuffer(sizehint = length(properties) * 32)
    first_prop = true

    for (k, v) in properties
        !first_prop && print(buf, " ")
        first_prop = false

        print(buf, k)

        if !isempty(v)
            v_str = _typst__escape_str(v)
            starts_with_digit = isdigit(first(v_str))
            needs_quote = !starts_with_digit && (k ∈ _TYPST__STRING_ATTRIBUTES)

            print(buf, ": ")
            needs_quote && print(buf, "\"")
            print(buf, v_str)
            needs_quote && print(buf, "\"")
        end

        print(buf, ",")
    end

    return String(take!(buf))
end

"""
    _typst__process_caption(c::TypstCaption, il::Int) -> String

Convert a `TypstCaption` into a string with the corresponding Typst configuration. The `il`
parameter indicates the indentation level for the generated string.
"""
function _typst__process_caption(c::TypstCaption, il::Int)
    (; caption, kind, supplement, gap, position) = c

    ind = repeat(" ", max(il, 0))

    out = "caption: figure.caption(\n"

    if !isnothing(position)
        out *= "$(ind)position: $position,\n"
    end

    out *= "$ind[$caption]\n"
    out *= "),\n"

    if kind ∉ ["table", "auto", "image"]
        out *= "kind: \"$kind\",\n"
        out *= "supplement: [$(something(supplement, titlecase(kind)))],\n"
    else
        out *= "kind: $kind,\n"

        if !isnothing(supplement)
            out *= "supplement: [$supplement],\n"
        end
    end

    if gap != "auto"
        out *= "gap: $gap,\n"
    end

    return out
end

"""
    _typst__text(content::AbstractString, properties::Union{Vector{TypstPair}, Nothing}) -> String

Convert the `content` to Typst format with optional styling `properties`. If `properties`
is empty or `nothing` (default), the function returns the content unchanged.  Otherwise, it
creates a Typst `#text` component with the specified properties.
"""
_typst__text(content::AbstractString, ::Nothing) = content

function _typst__text(content::AbstractString, properties::Vector{TypstPair})
    (isempty(properties) || isempty(content)) && return _typst__text(content, nothing)
    return _typst__create_component("#text", content, properties; wrap_column = -1)
end

# == Strings ===============================================================================

"""
    _typst__escape_str(io::IO, s::AbstractString) -> Nothing
    _typst__escape_str(s::AbstractString) -> String

Print the string `s` in `io` escaping the characters for the Typst backend. If `io` is
omitted, the escaped string is returned.
"""
function _typst__escape_str(io::IO, s::AbstractString)
    a = Iterators.Stateful(s)

    for c in a
        if Base.isascii(c)
            c == '#'   ? print(io, "\\#") :
            isprint(c) ? print(io, c) : print(io, "\\x", string(UInt32(c); base = 16, pad = 2))

        elseif !Base.isoverlong(c) && !Base.ismalformed(c)
            isprint(c)    ? print(io, c) :
            c <= '\x7f'   ? print(io, "\\x", string(UInt32(c); base = 16, pad = 2)) :
            c <= '\uffff' ? print(io, "\\u", string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2)) :
                            print(io, "\\U", string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\x", string(u % UInt8; base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

function _typst__escape_str(s::AbstractString)
    return sprint(_typst__escape_str, s; sizehint = 2 * lastindex(s))
end

"""
    _typst__should_wrap(str_length::Int, il::Int, ns::Int, wrap_column::Int) -> Bool

Determine whether a string with length `str_length` should be wrapped in Typst backend based
on length constraints. The current indentation level of the string is determined by `il`,
the number of spaces per indentation level is `ns`, and the maximum column width for
wrapping is `wrap_column`.
"""
function _typst__should_wrap(str_length::Int, il::Int, ns::Int, wrap_column::Int)
    identation_length = (il - 1) * ns
    return (wrap_column >= 0) && (identation_length + str_length) > wrap_column
end

# == Styles ================================================================================

"""
    _typst__get_data_column_widths(column_length::AbstractTypstLength, num_data_columns::Int, num_columns::Int)

Create the `columns` https://typst.app/docs/reference/model/table/#parameters-columns 
configuration for tables in Typst.
"""
function _typst__get_data_column_widths(table_data::TableData, ::Nothing)
    return _typst__get_data_column_widths(table_data, Base.Iterators.repeated("auto", 10))
end

function _typst__get_data_column_widths(table_data::TableData, data_column_widths)
    buf = IOBuffer(sizehint = 8 * (table_data.num_columns + 3) + 2)

    print(buf, "(")

    # == Row Number Column =================================================================

    table_data.show_row_number_column && print(buf, "auto, ")

    # == Row Labels ========================================================================

    _has_row_labels(table_data) && print(buf, "auto, ")

    # == Data Columns ======================================================================

    num_printed_data_columns = _number_of_printed_data_columns(table_data)

    i = 1
    for width in data_column_widths
        print(buf, width)
        print(buf, ",")
        i += 1
        i > num_printed_data_columns && break
        print(buf, " ")
    end

    # == Continuation Column ===============================================================

    num_printed_data_columns < table_data.num_columns && print(buf, " auto,")

    print(buf, ")")

    return String(take!(buf))
end

""" 
    _typst__merge_properties!(bproperties::Vector{TypstPair}, nproperties::Vector{TypstPair}) -> Vector{TypstPair}

Merge two Typst properties, `bproperties` and `nproperties`, giving priority to
`nproperties` in case of conflicts.
"""
function _typst__merge_properties!(bproperties::Vector{TypstPair}, nproperties::Vector{TypstPair})
    nkeys = first.(nproperties)

    filter!(bproperties) do l
        first(l) ∉ nkeys
    end

    append!(bproperties, nproperties)

    return bproperties
end
