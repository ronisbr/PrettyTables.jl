## Description #############################################################################
#
# Private functions for the HTML back end.
#
############################################################################################

# == Strings ===============================================================================

raw"""
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
            # When `escape_html_chars` is `false`, the user asked for the cell content to be
            # emitted as raw HTML. Hence, we must keep the line breaks. Otherwise, we would
            # corrupt the HTML code with a literal `\n`.
            c == '\n'         ? (
                replace_newline ? print(io, "<br>") :
                escape_html_chars ? print(io, "\\n") : print(io, c)
            ) :
            c == '&'          ? (escape_html_chars ? print(io, "&amp;") : print(io, c))  :
            c == '<'          ? (escape_html_chars ? print(io, "&lt;") : print(io, c))   :
            c == '>'          ? (escape_html_chars ? print(io, "&gt;") : print(io, c))   :
            c == '"'          ? (escape_html_chars ? print(io, "&quot;") : print(io, c)) :
            c == '\''         ? (escape_html_chars ? print(io, "&apos;") : print(io, c)) :
            c == '\0'         ? print(io, Base.escape_nul(peek(a)))                      :
            c == '\e'         ? print(io, "\\e")                                         :
            # When `escape_html_chars` is `false`, the user asked for the cell content to be
            # emitted as raw HTML. Escaping the backslash would corrupt any inline CSS or
            # JavaScript in it.
            c == '\\'         ? (escape_html_chars ? print(io, "\\\\") : print(io, c))     :
            '\a' <= c <= '\r' ? print(io, '\\', "abtnvfr"[Int(c) - 6])                   :
            isprint(c)        ? print(io, c)                                             :
            print(io, "\\x", string(UInt32(c); base = 16, pad = 2))
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

function _html__escape_str(
    s::AbstractString, replace_newline::Bool = false, escape_html_chars::Bool = true
)
    return sprint(
        _html__escape_str, s, replace_newline, escape_html_chars; sizehint = lastindex(s)
    )
end

# == Styles ================================================================================

const _HTML__ALIGNMENT_MAP = Dict(
    :l => "left", :L => "left", :c => "center", :C => "center", :r => "right", :R => "right"
)

"""
    _html__add_alignment_to_style!(style::Vector{HtmlPair}, alignment::Symbol) -> Nothing

Add the HTML alignment property to `style` according to the `alignment` symbol.
"""
function _html__add_alignment_to_style!(style::Vector{HtmlPair}, alignment::Symbol)
    if (alignment == :n) || (alignment == :N)
        return nothing
    elseif haskey(_HTML__ALIGNMENT_MAP, alignment)
        return push!(style, "text-align" => _HTML__ALIGNMENT_MAP[alignment])
    else
        return push!(style, "text-align" => _HTML__ALIGNMENT_MAP[:r])
    end
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

    # Make sure the style is sorted by key. We must sort by the key only so that duplicated
    # keys keep their insertion order, given that `sort!` is stable. Since the browser
    # applies the last declaration of a duplicated key, a pair pushed later to `style`
    # overrides a pair pushed earlier. The table borders rely on this contract: they are
    # pushed first so that any other decoration (alignment, styles, or highlighters) can
    # override them.
    sort!(style; by = first)

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

        print(buf, key)
        print(buf, ": ")
        print(buf, value)
        print(buf, ';')

        first_pair = false
    end

    !first_pair && print(buf, '"')

    return nothing
end

_html__write_style(::IO, ::Nothing) = nothing

"""
    _html__create_style(style::Union{Nothing, Vector{HtmlPair}}) -> String

Create the HTML style string using the information in the vector `style`.
"""
function _html__create_style(style::Vector{HtmlPair})
    buf = IOBuffer()
    _html__write_style(buf, style)
    return String(take!(buf))
end

_html__create_style(::Nothing) = ""

# == Table Borders =========================================================================

"""
    _html__has_any_table_line(tf::HtmlTableFormat) -> Bool

Return whether the table format `tf` draws at least one horizontal or vertical line. If it
does not, the table must be emitted without any border decoration, including the
`border-collapse` style in the `<table>` element.
"""
function _html__has_any_table_line(tf::HtmlTableFormat)
    return tf.horizontal_line_at_beginning ||
        tf.horizontal_line_before_column_labels ||
        tf.horizontal_line_after_column_labels ||
        tf.horizontal_line_at_merged_column_labels ||
        (tf.horizontal_lines_at_data_rows != :none) ||
        tf.horizontal_line_before_row_group_label ||
        tf.horizontal_line_after_row_group_label ||
        tf.horizontal_line_after_data_rows ||
        tf.horizontal_line_before_summary_rows ||
        tf.horizontal_line_after_summary_rows ||
        tf.horizontal_line_after_footnotes ||
        tf.horizontal_line_at_end ||
        tf.vertical_line_at_beginning ||
        tf.vertical_line_after_row_number_column ||
        tf.vertical_line_after_row_label_column ||
        (tf.vertical_lines_at_data_columns != :none) ||
        tf.vertical_line_after_data_columns ||
        tf.vertical_line_after_continuation_column
end

"""
    _html__column_borders(
        tf::HtmlTableFormat,
        table_data::TableData,
        vertical_lines_at_data_columns::AbstractVector{Int},
        num_printed_data_columns::Int,
        horizontally_cropped::Bool
    ) -> Vector{String}

Return the border at the right of each printed column (the row number column, the row label
column, the data columns, and the continuation column, in this order), or an empty string
for the columns without a vertical line after them. `vertical_lines_at_data_columns` must
be the processed version of the homonym field of `tf`.
"""
function _html__column_borders(
    tf::HtmlTableFormat,
    table_data::TableData,
    vertical_lines_at_data_columns::AbstractVector{Int},
    num_printed_data_columns::Int,
    horizontally_cropped::Bool,
)
    borders = String[]

    table_data.show_row_number_column && push!(
        borders,
        tf.vertical_line_after_row_number_column ? tf.borders.center_line : ""
    )

    _has_row_labels(table_data) && push!(
        borders,
        tf.vertical_line_after_row_label_column ? tf.borders.center_line : ""
    )

    for j in 1:num_printed_data_columns
        push!(
            borders,
            _html__vertical_line_after_data_column(
                tf,
                j,
                vertical_lines_at_data_columns,
                num_printed_data_columns,
                horizontally_cropped,
            )
        )
    end

    horizontally_cropped && push!(
        borders,
        tf.vertical_line_after_continuation_column ? tf.borders.right_line : ""
    )

    return borders
end

"""
    _html__vertical_line_after_data_column(tf::HtmlTableFormat, j::Int, vertical_lines_at_data_columns::AbstractVector{Int}, num_printed_data_columns::Int, horizontally_cropped::Bool) -> String

Return the border at the right of the data column `j`, or an empty string if the table
format `tf` defines no vertical line at this position. `vertical_lines_at_data_columns`
must be the processed version of the homonym field of `tf`.
"""
function _html__vertical_line_after_data_column(
    tf::HtmlTableFormat,
    j::Int,
    vertical_lines_at_data_columns::AbstractVector{Int},
    num_printed_data_columns::Int,
    horizontally_cropped::Bool,
)
    if j < num_printed_data_columns
        (j ∈ vertical_lines_at_data_columns) && return tf.borders.center_line
    elseif horizontally_cropped
        # If the table is horizontally cropped, the continuation column is at the right of
        # the last printed data column. Hence, the line here is an internal one.
        (tf.vertical_line_after_data_columns || (j ∈ vertical_lines_at_data_columns)) &&
            return tf.borders.center_line
    elseif tf.vertical_line_after_data_columns
        return tf.borders.right_line
    end

    return ""
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
                _html__escape_str(buf, v)
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
    (action == :title)              && return style.title
    (action == :subtitle)           && return style.subtitle
    (action == :row_number_label)   && return style.row_number_label
    (action == :row_number)         && return style.row_number
    (action == :summary_row_number) && return style.row_number
    (action == :stubhead_label)     && return style.stubhead_label
    (action == :row_group_label)    && return style.row_group_label
    (action == :row_label)          && return style.row_label
    (action == :summary_row_label)  && return style.summary_row_label
    (action == :summary_row_cell)   && return style.summary_row_cell
    (action == :footnote)           && return style.footnote
    (action == :source_notes)       && return style.source_note

    if action == :column_label
        s = (i == 1) ? style.first_line_column_label : style.column_label
        return s isa Vector{Vector{HtmlPair}} ? s[j] : s
    end

    return _HTML__NO_DECORATION
end
