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
    if alignment == :l
        return ":" * "-"^(column_width - 1)
    elseif alignment == :c
        return ":" * "-"^(column_width - 2) * ":"
    elseif alignment == :r
        return "-"^(column_width - 1) * ":"
    else
        return "-"^(column_width)
    end
end

"""
    _markdown__print_header_separator(buf::IOContext, table_data::TableData, row_number_column_width::Int, row_label_column_width::Int, printed_data_column_widths::Vector{Int}) -> Nothing

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
    printed_data_column_widths::Vector{Int}
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

# == Decoration ============================================================================

"""
    _markdown__apply_decoration(d::MarkdownDecoration, str::String) -> String

Apply the markdown decoration `d` to `str`.
"""
function _markdown__apply_decoration(d::MarkdownDecoration, str::String)
    d.bold          && (str = "**" * str * "**")
    d.italic        && (str = "*"  * str * "*")
    d.strikethrough && (str = "~~" * str * "~~")
    d.code          && (str = "`"  * str * "`")

    return str
end

# == Rows ==================================================================================

"""
    _markdown__row_group_line(buf::IOContext, row_group_label::String, table_data::TableData, row_number_column_width::Int, row_label_column_width::Int, printed_data_column_widths::Vector{Int}) -> Nothing

Print the row group line to `buf`.

# Arguments

- `buf::IOContext`: Buffer where the separator will be printed.
- `row_group_label::String`: Row group label.
- `table_data::TableData`: Table data.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Widths of the printed data columns.
"""
function _markdown__print_row_group_line(
    buf::IOContext,
    row_group_label::String,
    table_data::TableData,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int}
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
            print(buf, "-"^row_label_column_width)
            print(buf, " |")
        end

        print(buf, " ")
        print(buf, "-"^first(printed_data_column_widths))
        print(buf, " |")

    elseif _has_row_labels(table_data)
        print(buf, " ")
        print(buf, "-"^first(printed_data_column_widths))
        print(buf, " |")

    end

    for i in eachindex(printed_data_column_widths)[2:end]
        print(buf, " ")
        print(buf, "-"^printed_data_column_widths[i])
        print(buf, " |")
    end

    # == Continuation Column ===============================================================

    _is_horizontally_cropped(table_data) && print(buf, " ⋯ |")

    return nothing
end

"""
    _markdown__row_separation_line(buf::IOContext, table_data::TableData, row_number_column_width::Int, row_label_column_width::Int, printed_data_column_widths::Vector{Int}) -> Nothing

Print a row separation line to `buf`.

# Arguments

- `buf::IOContext`: Buffer where the separator will be printed.
- `table_data::TableData`: Table data.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Widths of the printed data columns.
"""
function _markdown__print_separation_line(
    buf::IOContext,
    table_data::TableData,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int}
)
    print(buf, "|")

    # == Row Number Column =================================================================

    if table_data.show_row_number_column
        print(buf, " ")
        print(buf, "-"^row_number_column_width)
        print(buf, " |")
    end

    # == Row Label Column ==================================================================

    if _has_row_labels(table_data)
        print(buf, " ")
        print(buf, "-"^row_label_column_width)
        print(buf, " |")
    end

    # == Data ==============================================================================

    for w in printed_data_column_widths
        print(buf, " ")
        print(buf, "-"^w)
        print(buf, " |")
    end

    # == Continuation Column ===============================================================

    _is_horizontally_cropped(table_data) && print(buf, " ⋯ |")

    println(buf)

    return nothing
end

# == Strings ===============================================================================

"""
    _markdown__escape_str(@nospecialize(io::IO), s::AbstractString, replace_newline::Bool = false, escape_markdown_chars::Bool = true) -> Nothing
    _markdown__escape_str(s::AbstractString, replace_newline::Bool = false, escape_markdown_chars::Bool = true) -> String

Print the string `s` in `io` escaping the characters for the markdown back end. If `io` is
omitted, the escaped string is returned.

If `replace_newline` is `true`, `\n` is replaced with `<br>`. Otherwise, it is escaped,
leading to `\\n`.

If `escape_markdown_chars` is `true`, `*`, `_`, `~`, `\\``, and `|`  will be escaped.
"""
function _markdown__escape_str(
    io::IO,
    s::AbstractString,
    replace_newline::Bool,
    escape_markdown_chars::Bool
)
    a = Iterators.Stateful(s)
    for c in a
        if isascii(c)
            c == '\n'          ? print(io, replace_newline ? "<br>" : "\\n") :
            c == '*'           ? print(io, escape_markdown_chars ? "\\*" : "*") :
            c == '_'           ? print(io, escape_markdown_chars ? "\\_" : "_") :
            c == '~'           ? print(io, escape_markdown_chars ? "\\~" : "~") :
            c == '`'           ? print(io, escape_markdown_chars ? "\\`" : "`") :
            c == '|'           ? print(io, escape_markdown_chars ? "\\|" : "|") :
            '\a' <= c <= '\r'  ? print(io, "\\", "abtnvfr"[Int(c)-6]) :
            isprint(c)         ? print(io, c) :
                                 print(io, "\\x", string(UInt32(c), base = 16, pad = 2))
        elseif !isoverlong(c) && !ismalformed(c)
            isprint(c)         ? print(io, c) :
            c <= '\x7f'        ? print(io, "\\x", string(UInt32(c), base = 16, pad = 2)) :
            c <= '\uffff'      ? print(io, "\\u", string(UInt32(c), base = 16, pad = Base.need_full_hex(peek(a)) ? 4 : 2)) :
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

function _markdown__escape_str(
    s::AbstractString,
    replace_newline::Bool,
    escape_markdown_chars::Bool,
)
    return sprint(
        _markdown__escape_str,
        s,
        replace_newline,
        escape_markdown_chars;
        sizehint = lastindex(s)
    )
end
