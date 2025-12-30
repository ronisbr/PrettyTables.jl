## Description #############################################################################
#
# Private functions for the Typst back end.
#
############################################################################################

# == Strings ===============================================================================

"""
    _typst__escape_str(io::IO, s::AbstractString, escape_typst_chars::Bool = true) -> Nothing
    _typst__escape_str(s::AbstractString, escape_typst_chars::Bool = true) -> String

Print the string `s` in `io` escaping the characters for the Typst backend. If `io` is
omitted, the escaped string is returned.

If `escape_typst_chars` is `true`, then `&`, `<`, `>`, `"`, and `'`  will be replaced by
Typst sequences.
"""
function _typst__escape_str(
    @nospecialize(io::IO),
    s::AbstractString,
    escape_typst_chars::Bool = true
)
    a = Iterators.Stateful(s)

    for c in a
        if Base.isascii(c)
            c == '#'   ? (escape_typst_chars ? print(io, "\\#") : print(io,c)) :
            isprint(c) ? print(io, c) : print(io, "\\x", string(UInt32(c), base = 16, pad = 2))

        elseif !Base.isoverlong(c) && !Base.ismalformed(c)
            isprint(c)    ? print(io, c) :
            c <= '\x7f'   ? print(io, "\\x", string(UInt32(c), base = 16, pad = 2)) :
            c <= '\uffff' ? print(io, "\\u", string(UInt32(c), base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2)) :
                            print(io, "\\U", string(UInt32(c), base = 16, pad = Base.need_full_hex(peek(a)) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\x", string(u % UInt8, base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

function _typst__escape_str(s::AbstractString, escape_typst_chars::Bool = true)
    return sprint(_typst__escape_str, s, escape_typst_chars; sizehint = lastindex(s))
end

# == Components ============================================================================

"""
    _typst__close_component() -> String

Create the string that closes the Typst `component`.
"""
_typst__close_component(comma = false) = "]$(comma ? "," : "")"

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
    content::String;
    args::Union{Nothing, Vector{String}} = nothing,
    properties::Union{Nothing, Vector{TypstPair}} = nothing,
)
    isnothing(args) &&
        return _typst__open_component(component; properties) * content * _typst__close_component()

    return _typst__open_component(component, args; properties) * content * _typst__close_component()
end

"""
    _typst__open_component(component::String, args::Union{Nothing, Vector{String}} = nothing; kwargs...) -> String

Create the string that opens the Typst `component` with the arguments `args`.

# Keywords

- `properties::Union{Nothing, Vector{TypstPair}}`: Properties.
    (**Default**: `nothing`)
"""
function _typst__open_component(
    component::String,
    args::Union{Nothing, Vector{String}} = nothing;
    properties::Union{Nothing, Vector{TypstPair}} = nothing
)
    # Compile the text with the properties.
    properties_str = ""
    args_str = (!isnothing(args) && length(args) > 0) ? join(args,", ") : ""

    # Make sure the properties are sorted by key.
    if !isnothing(properties)
        sort!(properties)

        for (k, v) in properties
            if !isempty(v)
                v_str = _typst__escape_str(v)
                if occursin(r"^[0-9]",v_str) || k ∉ _TYPST__STRING_ATTRIBUTES
                    properties_str *= "$k: $v_str,"
                else
                    properties_str *= "$k: \"$v_str\","
                end
            end
        end
    end

    # Return the component.
    args_str != "" && return "$(component)($(args_str), $(properties_str))["

    return "$(component)($(properties_str))["
end

# == Styles ================================================================================

const _TYPST__ALIGNMENT_MAP = Dict(
    :l => "left",
    :L => "left",
    :c => "center",
    :C => "center",
    :r => "right",
    :R => "right"
)

"""
    _typst__add_alignment_to_style!(style::Vector{TypstPair}, alignment::Symbol) -> Nothing

Add the Typst alignment property to `style` according to the `alignment` symbol.
"""
function _typst__add_alignment_to_style!(style::Vector{TypstPair}, alignment::Symbol)
    if (alignment == :n) || (alignment == :N)
        return nothing
    elseif haskey(_TYPST__ALIGNMENT_MAP, alignment)
        return push!(style, "align" => _TYPST__ALIGNMENT_MAP[alignment])
    else
        return push!(style, "align" => _TYPST__ALIGNMENT_MAP[:r])
    end

    return nothing
end

"""
    _typst__get_data_column_widths(columns::AbstractTypstLength, num_columns::Int) -> String

Create the `columns` https://typst.app/docs/reference/model/table/#parameters-columns 
configuration for tables in Typst.
"""
function _typst__get_data_column_widths(column_length::AbstractTypstLength, num_columns::Int) :: String
    columns = fill(column_length, num_columns)
    return _typst__get_data_column_widths(columns, num_columns)
end

function _typst__get_data_column_widths(columns::Integer, ::Int) :: String
    return string(columns)
end

function _typst__get_data_column_widths(str_columns::String, num_columns::Int) :: String
    col_length = parse(TypstLength, str_columns) # Throw error if string doesn't match any known kind
    columns = fill(col_length,num_columns)
    return _typst__get_data_column_widths(columns,num_columns)
end

"""
    _typst__get_data_column_widths(columns::Vector{T}, num_columns::Int) where {T<: AbstractTypstLength} -> String

Create the `columns` https://typst.app/docs/reference/model/table/#parameters-columns 
configuration for tables in Typst.
"""
function _typst__get_data_column_widths(columns::Vector{T}, num_columns::Int) :: String where {T<: AbstractTypstLength}
    length(columns) > num_columns &&
        error("The number of vectors in `data_column_widths` must be equal or lower than the number of columns of data.")
    out_columns::Vector{AbstractTypstLength} = fill(TypstLength(), num_columns)
    out_columns[1:length(columns)] = columns
    return string("(", join(out_columns,", "), ")")
end

"""
    _typst__get_data_column_widths(columns::Vector{Pair{Int, String}}, num_columns::Int) -> String

Create the `columns` https://typst.app/docs/reference/model/table/#parameters-columns
configuration for tables in Typst.
"""
function _typst__get_data_column_widths(pair_columns::Vector{Pair{Int, String}}, num_columns::Int) ::String
    columns::Vector{AbstractTypstLength} = fill(TypstLength(), num_columns)
    for c in pair_columns
        pos = c[1]
        pos > num_columns && continue
        columns[pos] = parse(TypstLength,c[2])
    end
    return _typst__get_data_column_widths(columns, num_columns)
end

function _typst__get_data_column_widths(str::Vector{T}, num_columns::Int) where T<: AbstractString
    out_columns = map(TypstLength ∘ string,str)
    return _typst__get_data_column_widths(out_columns, num_columns)
end

function _typst__get_data_column_widths(::Nothing, num_columns::Int)
    return _typst__get_data_column_widths(AbstractTypstLength[], num_columns)
end


""" 
    _typst__merge_style!(bstyle::Vector{TypstPair}, nstyle::Vector{TypstPair}) -> Vector{TypstPair}

Merge two Typst styles, `bstyle` and `nstyle`, giving priority to `nstyle` in case of
conflicts.
"""
function _typst__merge_style!(bstyle::Vector{TypstPair}, nstyle::Vector{TypstPair})
    filter!(bstyle) do l
        l[1] ∉ map(first, nstyle)
    end

    append!(bstyle, nstyle)

    return bstyle
end