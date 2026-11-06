## Description #############################################################################
#
# Private functions for the HTML back end.
#
############################################################################################

# == Strings ===============================================================================

@doc raw"""
    _html__escape_str(
        @nospecialize(io::IO),
        s::AbstractString,
        replace_newline::Bool = false,
        escape_html_chars::Bool = true
    ) -> Nothing
    _html__escape_str(
        s::AbstractString,
        replace_newline::Bool = false,
        escape_html_chars::Bool = true
    ) -> String

Print the string `s` in `io` escaping the characters for the HTML back end. If `io` is
omitted, the escaped string is returned.

If `replace_newline` is `true`, `\n` is replaced with `<br>`. Otherwise, it is escaped when
`escape_html_chars` is `true`, leading to `\\n`, and kept unchanged otherwise.

If `escape_html_chars` is `true`, `&`, `<`, `>`, `"`, and `'` will be replaced by HTML
sequences.
"""
function _html__escape_str(
    io::IO, s::AbstractString, replace_newline::Bool = false, escape_html_chars::Bool = true
)
    a = Iterators.Stateful(s)
    for c in a
        if Base.isascii(c)
            if c == '\n'
                # When `escape_html_chars` is `false`, the user asked for the cell content
                # to be emitted as raw HTML. Hence, we must keep the line breaks. Otherwise,
                # we would corrupt the HTML code with a literal `\n`.
                if replace_newline
                    print(io, "<br>")
                elseif escape_html_chars
                    print(io, "\\n")
                else
                    print(io, c)
                end
            elseif c == '&'
                escape_html_chars ? print(io, "&amp;") : print(io, c)
            elseif c == '<'
                escape_html_chars ? print(io, "&lt;") : print(io, c)
            elseif c == '>'
                escape_html_chars ? print(io, "&gt;") : print(io, c)
            elseif c == '"'
                escape_html_chars ? print(io, "&quot;") : print(io, c)
            elseif c == '\''
                escape_html_chars ? print(io, "&apos;") : print(io, c)
            elseif c == '\0'
                print(io, Base.escape_nul(peek(a)))
            elseif c == '\e'
                print(io, "\\e")
            elseif c == '\\'
                # When `escape_html_chars` is `false`, the user asked for the cell content
                # to be emitted as raw HTML. Escaping the backslash would corrupt any inline
                # CSS or JavaScript in it.
                escape_html_chars ? print(io, "\\\\") : print(io, c)
            elseif '\a' <= c <= '\r'
                print(io, '\\', "abtnvfr"[Int(c) - 6])
            elseif isprint(c)
                print(io, c)
            else
                print(io, "\\x", string(UInt32(c); base = 16, pad = 2))
            end
        elseif !Base.isoverlong(c) && !Base.ismalformed(c)
            if isprint(c)
                print(io, c)
            elseif c <= '\x7f'
                print(io, "\\x", string(UInt32(c); base = 16, pad = 2))
            elseif c <= '\uffff'
                print(
                    io,
                    "\\u",
                    string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2),
                )
            else
                print(
                    io,
                    "\\U",
                    string(UInt32(c); base = 16, pad = Base.need_full_hex(peek(a)) ? 8 : 4),
                )
            end
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c))
            while true
                print(io, "\\x", string(u % UInt8; base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

function _html__escape_str(
    s::AbstractString, replace_newline::Bool = false, escape_html_chars::Bool = true
)
    return sprint(
        _html__escape_str, s, replace_newline, escape_html_chars; sizehint = lastindex(s)
    )
end

"""
    _html__escape_attribute(io::IO, s::AbstractString) -> Nothing

Print the string `s` in `io` escaping the characters that cannot appear verbatim in a
double-quoted HTML attribute value: `&`, `<`, `>`, `"`, and `'`. The line breaks are
replaced by character references because the output lines are indented. The other
characters are kept unchanged because the attribute value is not Julia code.
"""
function _html__escape_attribute(io::IO, s::AbstractString)
    for c in s
        if c == '\n'
            print(io, "&#10;")
        elseif c == '&'
            print(io, "&amp;")
        elseif c == '<'
            print(io, "&lt;")
        elseif c == '>'
            print(io, "&gt;")
        elseif c == '"'
            print(io, "&quot;")
        elseif c == '\''
            print(io, "&apos;")
        else
            print(io, c)
        end
    end

    return nothing
end

# == Styles ================================================================================

"""
    _html__add_alignment_to_style!(style::Vector{HtmlPair}, alignment::Symbol) -> Nothing

Add the HTML alignment property to `style` according to the `alignment` symbol. The
alignment `:n` (no alignment information) does not add any property.
"""
function _html__add_alignment_to_style!(style::Vector{HtmlPair}, alignment::Symbol)
    alignment === :n && return nothing
    return push!(style, "text-align" => _alignment_name(alignment, "right"))
end

"""
    _html__write_style(buf::IO, style::Union{Nothing, Vector{HtmlPair}}) -> Nothing

Write the HTML style attribute to `buf` using the information in the vector `style`.

Notice that this function writes directly to `buf` instead of building intermediate strings.
Otherwise, we would allocate multiple strings per printed cell.
"""
function _html__write_style(buf::IO, style::Vector{HtmlPair})
    # If there are no keys in the style vector, we have nothing to do.
    isempty(style) && return nothing

    # Make sure the style is sorted by the property family, i.e., the part of the key before
    # the first `-`. Since `sort!` is stable, the properties of the same family keep their
    # insertion order, including the duplicated keys. The browser applies the last
    # declaration of a property. Hence, a pair pushed later to `style` overrides a pair
    # pushed earlier, even if one of them is a shorthand, such as `border`, and the other is
    # one of its longhands, such as `border-bottom`. The table borders rely on this
    # contract: they are pushed first so that any other decoration (alignment, styles, or
    # highlighters) can override them.
    sort!(style; by = _html__property_family)

    # Every value can be empty, in which case there is no style to emit. Hence, we must
    # check it before writing the attribute opening.
    first_pair = true

    # NOTE: The separator is *prepended* to every entry but the first. Appending it and
    # skipping the last index left a trailing space whenever the last pair had an empty
    # value, as in `["a" => "1", "z" => ""]`.
    @inbounds for (key, value) in style
        # If the value is empty, then just continue.
        isempty(value) && continue

        if first_pair
            print(buf, " style = \"")
        else
            print(buf, ' ')
        end

        # The style is an attribute value. Hence, the properties must be escaped, allowing,
        # for example, quoted font families.
        _html__escape_attribute(buf, key)
        print(buf, ": ")
        _html__escape_attribute(buf, value)
        print(buf, ';')

        first_pair = false
    end

    !first_pair && print(buf, '"')

    return nothing
end

_html__write_style(::IO, ::Nothing) = nothing

"""
    _html__property_family(property::HtmlPair) -> SubString{String}

Return the family of the CSS `property`, which is the part of its key before the first `-`.
For example, `border`, `border-bottom`, and `border-bottom-color` belong to the family
`border`.
"""
function _html__property_family(property::HtmlPair)
    key = first(property)
    i   = findfirst('-', key)
    return SubString(key, 1, isnothing(i) ? lastindex(key) : prevind(key, i))
end

# == Table Borders =========================================================================

"""
    _html__row_owns_line_above(prev_rs::Symbol, rs::Symbol) -> Bool

Return whether the row of section `rs` owns the horizontal line between it and the previous
row, whose section is `prev_rs`, meaning that the line is emitted as its top border. The
line is owned by the row below if it is a row group label, the first summary row, the first
row of the ruled area after the table header (title and subtitle), or a data row after the
continuation row. Otherwise, the line is emitted as the bottom border of the row above.
The rows of the table header and footer never own the line above them, and neither does the
first row of a table without a header (`prev_rs` is `:none`), since the line at the
beginning of the table is emitted in the `<table>` element.

The line above a data row after the continuation row must be owned by that row because, in
the middle cropping, it is the line after the data row before it, which is only known when
that row is reached.
"""
function _html__row_owns_line_above(prev_rs::Symbol, rs::Symbol)
    ((rs ∈ (:table_header, :table_footer)) || (prev_rs == :none)) && return false

    return (rs == :row_group_label) ||
           ((rs == :summary_row) && (prev_rs != :summary_row)) ||
           (prev_rs == :table_header) ||
           ((prev_rs == :continuation_row) && (rs == :data))
end

"""
    _html__column_borders(tf::HtmlTableFormat, lines::TableLines, table_data::TableData) -> Vector{String}

Return the border at the right of each printed column (the row number column, the row label
column, the data columns, and the continuation column, in this order), or an empty string
for the columns without a vertical line after them.
"""
function _html__column_borders(
    tf::HtmlTableFormat, lines::TableLines, table_data::TableData
)
    borders = String[]

    _border(column, j = 0) = begin
        role = _vertical_line_after_column(lines, table_data, column, j)
        return role == :none ? "" : getfield(tf.borders, role)::String
    end

    table_data.show_row_number_column && push!(borders, _border(:row_number))

    _has_row_labels(table_data) && push!(borders, _border(:row_label))

    for j in 1:_number_of_printed_data_columns(table_data)
        push!(borders, _border(:data, j))
    end

    _is_horizontally_cropped(table_data) && push!(borders, _border(:continuation))

    return borders
end

# == Tags ==================================================================================

"""
    _html__open_tag(tag::String; kwargs...) -> String

Create the string that opens the HTML `tag`.

# Keywords

- `properties::Union{Nothing, Vector{HtmlPair}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Vector{HtmlPair}}`: Tag style.
    (**Default**: `nothing`)
"""
function _html__open_tag(
    tag::String;
    properties::Union{Nothing, Vector{HtmlPair}} = nothing,
    style::Union{Nothing, Vector{HtmlPair}} = nothing,
)
    buf = IOBuffer()
    _html__write_open_tag(buf, tag, properties, style)
    return String(take!(buf))
end

"""
    _html__write_open_tag(
        buf::IO,
        tag::String,
        properties::Union{Nothing, Vector{HtmlPair}},
        style::Union{Nothing, Vector{HtmlPair}}
    ) -> Nothing

Write the string that opens the HTML `tag` to `buf`.

Notice that this function writes directly to `buf` instead of building intermediate strings.
Otherwise, we would allocate multiple strings per printed cell.
"""
function _html__write_open_tag(
    buf::IO,
    tag::String,
    properties::Union{Nothing, Vector{HtmlPair}},
    style::Union{Nothing, Vector{HtmlPair}},
)
    print(buf, '<')
    print(buf, tag)

    if !isnothing(properties)
        # Make sure the properties are sorted by key.
        sort!(properties)

        for (k, v) in properties
            if !isempty(v)
                print(buf, ' ')
                print(buf, k)
                print(buf, " = \"")
                _html__escape_attribute(buf, v)
                print(buf, '"')
            end
        end
    end

    _html__write_style(buf, style)

    print(buf, '>')

    return nothing
end

"""
    _html__close_tag(tag::String) -> String

Create the string that closes the HTML `tag`.
"""
_html__close_tag(tag::String) = "</$tag>"

"""
    _html__create_tag(tag::String, content::String; kwargs...) -> String

Create an HTML `tag` with the `content`.

# Keywords

- `properties::Union{Nothing, Vector{HtmlPair}}`: Tag properties.
    (**Default**: `nothing`)
- `style::Union{Nothing, Vector{HtmlPair}}`: Tag style.
    (**Default**: `nothing`)
"""
function _html__create_tag(
    tag::String,
    content::String;
    properties::Union{Nothing, Vector{HtmlPair}} = nothing,
    style::Union{Nothing, Vector{HtmlPair}} = nothing,
)
    buf = IOBuffer(; sizehint = 32 + ncodeunits(tag) * 2 + ncodeunits(content))
    _html__write_open_tag(buf, tag, properties, style)
    print(buf, content)
    print(buf, "</")
    print(buf, tag)
    print(buf, '>')
    return String(take!(buf))
end

# == Top Bar ===============================================================================

"""
    _html__print_top_bar_section(
        buf::IOContext,
        position::String,
        text::String,
        decoration::Union{Nothing, Vector{HtmlPair}},
        il::Int,
        ns::Int;
        kwargs...
    )

Print the HTML top bar section.

# Arguments

- `buf::IOContext`: Buffer to which the top bar will be printed.
- `position::String`: Buffer position. It can be "left" or "right".
- `text::String`: Text to be printed in the selected position.
- `decoration::Union{Nothing, Vector{HtmlPair}}`: Text decoration.
- `il::Int`: Indentation level.
- `ns::Int`: Number of space per indentation level.

# Keywords

- `minify::Bool`: If `true`, the output will be minified.
    (**Default**: `false`)
"""
function _html__print_top_bar_section(
    buf::IOContext,
    position::String,
    text::String,
    decoration::Union{Nothing, Vector{HtmlPair}},
    il::Int,
    ns::Int;
    minify::Bool = false,
)
    style = isnothing(decoration) ? HtmlPair[] : copy(decoration)
    push!(style, "float" => position)

    _aprintln(buf, _html__open_tag("div"; style), il, ns; minify)
    il += 1

    _aprintln(buf, _html__create_tag("span", _html__escape_str(text)), il, ns; minify)

    il -= 1
    return _aprintln(buf, _html__close_tag("div"), il, ns; minify)
end

# == Cell Classes and Styles ===============================================================

# CSS class of the cells printed by each action. The cells without an entry have no class.
const _HTML__CELL_CLASSES = Dict{Symbol, String}(
    :row_number_label   => "rowNumberLabel",
    :row_number         => "rowNumber",
    :summary_row_number => "summaryRowNumber",
    :stubhead_label     => "stubheadLabel",
    :row_label          => "rowLabel",
    :summary_row_label  => "summaryRowLabel",
)

"""
    _html__cell_class(action::Symbol) -> String

Return the CSS class of the cell printed by `action`, or an empty string if it has no class.
"""
_html__cell_class(action::Symbol) = get(_HTML__CELL_CLASSES, action, "")

"""
    _html__cell_style(style::HtmlTableStyle, action::Symbol, i::Int, j::Int) -> Vector{HtmlPair}

Return the decoration in `style` of the cell printed by `action` at the row `i` and column
`j`.
"""
function _html__cell_style(style::HtmlTableStyle, action::Symbol, i::Int, j::Int)
    (action == :title) && return style.title
    (action == :subtitle) && return style.subtitle
    (action == :row_number_label) && return style.row_number_label
    (action == :row_number) && return style.row_number
    (action == :summary_row_number) && return style.row_number
    (action == :stubhead_label) && return style.stubhead_label
    (action == :row_group_label) && return style.row_group_label
    (action == :row_label) && return style.row_label
    (action == :summary_row_label) && return style.summary_row_label
    (action == :summary_row_cell) && return style.summary_row_cell
    (action == :footnote) && return style.footnote
    (action == :source_notes) && return style.source_note

    if action == :column_label
        s = (i == 1) ? style.first_line_column_label : style.column_label
        return s isa Vector{Vector{HtmlPair}} ? s[j] : s
    end

    return _HTML__NO_DECORATION
end
