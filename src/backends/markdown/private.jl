## Description #############################################################################
#
# Private functions for the markdown back end.
#
############################################################################################

# == Alignment =============================================================================

"""
    _markdown__column_alignment_str(column_width::Int, alignment::Symbol) -> String

Compose the markdown `alignment` string given a column with width `column_width`. The
possible values for `alignment` are:

- `:l`: Left alignment.
- `:c`: Center alignment.
- `:r`: Right alignment.
- `:n`: No alignment information will be added to the string.
"""
function _markdown__column_alignment_str(column_width::Int, alignment::Symbol)
    if alignment === :l
        return ":" * "-"^(column_width - 1)
    elseif alignment === :c
        return ":" * "-"^(column_width - 2) * ":"
    elseif alignment === :r
        return "-"^(column_width - 1) * ":"
    else
        return "-"^(column_width)
    end
end

"""
    _markdown__print_aligned(
        buf::IOContext,
        str::String,
        cell_width::Int,
        alignment::Symbol
    ) -> Nothing

Print `str` to the buffer `buf` with `alignment` considering the `cell_width`.
"""
function _markdown__print_aligned(
    buf::IOContext, str::String, cell_width::Int, alignment::Symbol
)
    print(buf, align_string(str, cell_width, alignment; fill = true))
    return nothing
end

"""
    _markdown__print_header_separator(
        buf::IOContext,
        table_data::TableData,
        row_number_column_width::Int,
        row_label_column_width::Int,
        printed_data_column_widths::Vector{Int}
    ) -> Nothing

Print the markdown header separator with the column alignment information.

# Arguments

- `buf::IOContext`: Buffer where the separator will be printed.
- `table_data::TableData`: Table data.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Widths of the printed data columns.
"""
function _markdown__print_header_separator(
    buf::IOContext,
    table_data::TableData,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
)
    print(buf, "|")

    # == Row Number Column =================================================================

    if table_data.show_row_number_column
        a = _row_number_column_alignment(table_data)
        print(buf, _markdown__column_alignment_str(row_number_column_width + 2, a))
        print(buf, "|")
    end

    # == Row Labels ========================================================================

    if _has_row_labels(table_data)
        a = _row_label_column_alignment(table_data)
        print(buf, _markdown__column_alignment_str(row_label_column_width + 2, a))
        print(buf, "|")
    end

    # == Data ==============================================================================

    for i in eachindex(printed_data_column_widths)
        a = _data_column_alignment(table_data, i)
        print(buf, _markdown__column_alignment_str(printed_data_column_widths[i] + 2, a))
        print(buf, "|")
    end

    # == Continuation Column ===============================================================

    if _is_horizontally_cropped(table_data)
        print(buf, _markdown__column_alignment_str(3, :n))
        print(buf, "|")
    end

    println(buf)

    return nothing
end

# == Rows ==================================================================================

"""
    _markdown__print_row_group_line(
        buf::IOContext,
        row_group_label::String,
        table_data::TableData,
        char::Char,
        row_number_column_width::Int,
        row_label_column_width::Int,
        printed_data_column_widths::Vector{Int}
    ) -> Nothing

Print the row group line to `buf`.

# Arguments

- `buf::IOContext`: Buffer where the separator will be printed.
- `row_group_label::String`: Row group label.
- `table_data::TableData`: Table data.
- `char::Char`: Character used for the separation line.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Widths of the printed data columns.
"""
function _markdown__print_row_group_line(
    buf::IOContext,
    row_group_label::String,
    table_data::TableData,
    char::Char,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
)

    # Check the initial column.
    cell_width = if table_data.show_row_number_column
        row_number_column_width
    elseif _has_row_labels(table_data)
        row_label_column_width
    else
        first(printed_data_column_widths)
    end

    # == Row Group Label ===================================================================

    print(buf, " ")
    print(buf, rpad(row_group_label, cell_width))
    print(buf, " |")

    # == Fill the Rest of the Cells ========================================================

    if table_data.show_row_number_column
        if _has_row_labels(table_data)
            print(buf, " ")
            print(buf, repeat(char, row_label_column_width))
            print(buf, " |")
        end

        print(buf, " ")
        print(buf, repeat(char, first(printed_data_column_widths)))
        print(buf, " |")

    elseif _has_row_labels(table_data)
        print(buf, " ")
        print(buf, repeat(char, first(printed_data_column_widths)))
        print(buf, " |")
    end

    for i in eachindex(printed_data_column_widths)[2:end]
        print(buf, " ")
        print(buf, repeat(char, printed_data_column_widths[i]))
        print(buf, " |")
    end

    # == Continuation Column ===============================================================

    _is_horizontally_cropped(table_data) && print(buf, " ⋯ |")

    return nothing
end

"""
    _markdown__print_separation_line(
        buf::IOContext,
        table_data::TableData,
        char::Char,
        row_number_column_width::Int,
        row_label_column_width::Int,
        printed_data_column_widths::Vector{Int}
    ) -> Nothing

Print a row separation line to `buf`.

# Arguments

- `buf::IOContext`: Buffer where the separator will be printed.
- `table_data::TableData`: Table data.
- `char::Char`: Character used for the separation line.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Widths of the printed data columns.
"""
function _markdown__print_separation_line(
    buf::IOContext,
    table_data::TableData,
    char::Char,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
)
    print(buf, "|")

    # == Row Number Column =================================================================

    if table_data.show_row_number_column
        print(buf, " ")
        print(buf, repeat(char, row_number_column_width))
        print(buf, " |")
    end

    # == Row Label Column ==================================================================

    if _has_row_labels(table_data)
        print(buf, " ")
        print(buf, repeat(char, row_label_column_width))
        print(buf, " |")
    end

    # == Data ==============================================================================

    for w in printed_data_column_widths
        print(buf, " ")
        print(buf, repeat(char, w))
        print(buf, " |")
    end

    # == Continuation Column ===============================================================

    _is_horizontally_cropped(table_data) && print(buf, " ", char, " |")

    println(buf)

    return nothing
end

# == Strings ===============================================================================

# ASCII characters that carry a special meaning inside a Markdown table cell and, hence, must
# be escaped with a backslash. Notice that `[` and `]` are particularly important because the
# back end itself emits `[^N]` footnote references, meaning that unescaped user data can
# collide with the generated markup, whereas `<` and `>` would otherwise be interpreted as
# raw HTML or as an autolink.
#
# `#` and `!` are deliberately **not** escaped. `#` only starts an ATX heading at the
# beginning of a line, which cannot happen inside a cell, and escaping it would corrupt the
# `#= circular reference =#` and `#undef` sentinels this package emits. `!` is only special
# when immediately followed by `[`, which is already escaped.
const _MARKDOWN__ESCAPED_CHARACTERS = ('*', '_', '~', '`', '|', '[', ']', '<', '>')

raw"""
    _markdown__escape_str(
        @nospecialize(io::IO),
        s::Union{String, SubString{String}},
        replace_newline::Bool,
        escape_markdown_chars::Bool
    ) -> Nothing
    _markdown__escape_str(
        s::Union{String, SubString{String}},
        replace_newline::Bool,
        escape_markdown_chars::Bool
    ) -> String

Print the string `s` in `io` escaping the characters for the markdown back end. If `io` is
omitted, the escaped string is returned.

If `replace_newline` is `true`, `\n` is replaced with `<br>`. Otherwise, it is escaped,
leading to `\n`.

If `escape_markdown_chars` is `true`, the characters in `_MARKDOWN__ESCAPED_CHARACTERS`
(`*`, `_`, `~`, `` ` ``, `|`, `[`, `]`, `<`, and `>`) will be escaped, as well as the
backslash itself. Otherwise, only the pipes that are not already escaped, i.e., that are
not preceded by an odd number of backslashes, are escaped because they would split the
table cell.
"""
function _markdown__escape_str(
    io::IO, s::_PlainString, replace_newline::Bool, escape_markdown_chars::Bool
)
    a = Iterators.Stateful(s)

    # Number of consecutive backslashes before the current character.
    num_backslashes = 0

    for c in a
        if isascii(c)
            c == '\n'         ? print(io, replace_newline ? "<br>" : "\\n") :
            c == '\\'         ? print(io, escape_markdown_chars ? "\\\\" : "\\") :
            c == '|'          ? print(io, (escape_markdown_chars || iseven(num_backslashes)) ? "\\|" : "|") :
            c ∈ _MARKDOWN__ESCAPED_CHARACTERS ?
                (escape_markdown_chars ? print(io, '\\', c) : print(io, c)) :
            '\a' <= c <= '\r' ? print(io, "\\", "abtnvfr"[Int(c) - 6]) :
            isprint(c)        ? print(io, c) :
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

        num_backslashes = (c == '\\') ? num_backslashes + 1 : 0
    end
end

"""
    _markdown__escape_pipes(s::Union{String, SubString{String}}) -> String

Escape the pipes in `s` that are not already escaped, i.e., that are not preceded by an odd
number of backslashes, since they would split a table cell.
"""
_markdown__escape_pipes(s::_PlainString) =
    replace(s, r"(?<!\\)((?:\\\\)*)\|" => s"\1\\|")

function _markdown__escape_str(
    s::_PlainString, replace_newline::Bool, escape_markdown_chars::Bool
)
    return sprint(
        _markdown__escape_str,
        s,
        replace_newline,
        escape_markdown_chars;
        sizehint = lastindex(s),
    )
end

"""
    _markdown__row_group_label(label::String, line_breaks::Bool) -> String

Return the row group `label` escaped for the Markdown back end. The
line breaks are replaced with `<br>` if `line_breaks` is `true`. Notice that, as the title
and the footnotes, the row group labels are always escaped because they are not table
cells.
"""
function _markdown__row_group_label(label::String, line_breaks::Bool)
    return _markdown__escape_str(label, line_breaks, true)
end

# == Style =================================================================================

"""
    _markdown__apply_style(s::MarkdownStyle, str::String) -> String

Apply the markdown style `s` to `str`. The leading and trailing white spaces of `str` are
kept outside the style markers because the emphasis markers next to a white space are not
recognized by Markdown.
"""
function _markdown__apply_style(s::MarkdownStyle, str::String)
    core = strip(str)
    isempty(core) && return str

    lead  = SubString(str, 1, core.offset)
    trail = SubString(str, core.offset + ncodeunits(core) + 1)

    # NOTE: `code` must be applied innermost because a Markdown code span renders its
    # content verbatim. Otherwise, the `bold`, `italic`, and `strikethrough` markers would
    # be shown literally to the user.
    styled = String(core)
    s.code && (styled = _markdown__code_span(styled))
    s.bold && (styled = "**" * styled * "**")
    s.italic && (styled = "*" * styled * "*")
    s.strikethrough && (styled = "~~" * styled * "~~")

    return lead * styled * trail
end

"""
    _markdown__code_span(str::String) -> String

Wrap `str`, which was escaped with `_markdown__escape_str`, in a Markdown code span. Since a
code span renders its content verbatim, the escape sequences of the Markdown characters are
removed. However, `\\|` is kept because the pipe must always be escaped inside a table,
even in code spans. The code span is delimited by a sequence of backticks longer than the
longest one in `str`, which is padded with spaces if it begins or ends with a backtick.
"""
function _markdown__code_span(str::String)
    buf = IOBuffer(; sizehint = ncodeunits(str) + 2)

    # Longest sequence of backticks in the content.
    max_ticks = 0
    ticks     = 0
    escaped   = false

    for c in str
        if escaped
            # Remove only the escape sequences of the Markdown characters, except the one of
            # the pipe. The other sequences, such as `\\n`, represent special characters.
            ((c == '|') || ((c ∉ _MARKDOWN__ESCAPED_CHARACTERS) && (c != '\\'))) &&
                print(buf, '\\')
            print(buf, c)
            escaped = false
        elseif (c == '\\')
            escaped = true
            continue
        else
            print(buf, c)
        end

        ticks     = (c == '`') ? ticks + 1 : 0
        max_ticks = max(max_ticks, ticks)
    end

    # A backslash at the end of the string does not escape anything.
    escaped && print(buf, '\\')

    content = String(take!(buf))
    fence   = "`"^(max_ticks + 1)
    pad     = (startswith(content, '`') || endswith(content, '`')) ? " " : ""

    return fence * pad * content * pad * fence
end

"""
    _markdown__style_textwidth(s::MarkdownStyle) -> Int

Return the additional textwidth required to apply the markdown style `s`.
"""
function _markdown__style_textwidth(s::MarkdownStyle)
    Δ = 0
    s.bold && (Δ += 4)
    s.italic && (Δ += 2)
    s.strikethrough && (Δ += 4)
    s.code && (Δ += 2)

    return Δ
end

"""
    _markdown__footnote_marks(table_data::TableData, section::Symbol, i::Int, j::Int) -> String

Return the references to the footnotes in the cell `(i, j)` of the table `section`, or an
empty string if the cell has no footnotes.
"""
function _markdown__footnote_marks(table_data::TableData, section::Symbol, i::Int, j::Int)
    return _current_cell_footnote_marks(f -> "[^$f]", table_data, section, i, j, "")
end
