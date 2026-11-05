## Description #############################################################################
#
# Functions related to display manipulation.
#
############################################################################################

"""
    _text__check_eol(display::Display) -> Bool

Check if the current column of the `display` is past the end of line.
"""
function _text__check_eol(display::Display)
    w = display.size[2]
    return (w > 0) && (display.column > display.size[2])
end

"""
    _text__print(display::Display, char::Char) -> Nothing

Print a single character `char` to the `display`.

Notice that this method must write the character directly instead of forwarding to the
`AbstractString` one. Otherwise, printing a table border would allocate one `String` per
vertical line per row.
"""
function _text__print(display::Display, char::Char)
    _text__check_eol(display) && return nothing
    print(display.buf_line, char)
    display.column += textwidth(char)
    return nothing
end

"""
    _text__print(display::Display, char::Char, n::Int) -> Nothing

Print the character `char` repeated `n` times to the `display`.

Notice that this method must write the characters directly instead of using `char^n`.
Otherwise, printing a horizontal line would allocate one `String` per table column.
"""
function _text__print(display::Display, char::Char, n::Int)
    _text__check_eol(display) && return nothing

    for _ in 1:n
        print(display.buf_line, char)
    end

    display.column += textwidth(char) * n
    return nothing
end

"""
    _text__print(display::Display, str::AbstractString, str_width::Int = -1) -> Nothing

Print a string `str` to the `display`, updating the column position. If `str_width` is
positive, it is used as the width of the printed string, reducing the computational burden.
Otherwise, the printable width of `str` is computed using `printable_textwidth`.
"""
function _text__print(display::Display, str::AbstractString, str_width::Int = -1)
    _text__check_eol(display) && return nothing
    print(display.buf_line, str)
    display.column += str_width < 0 ? printable_textwidth(str) : str_width
    return nothing
end

"""
    _text__begin_styled_line(display::Display, sgr::String) -> Nothing
    _text__end_styled_line(display::Display, sgr::String) -> Nothing

Print to `display` the escape sequence `sgr` that starts a styled line, or the reset
sequence that ends it, if `sgr` is not empty and the display has color. Both functions are
guarded by the same condition. Otherwise, a table styled with a non-default face would leak
a bare `\\e[0m` into an output where color is disabled.
"""
function _text__begin_styled_line(display::Display, sgr::String)
    (display.has_color && !isempty(sgr)) && _text__print(display, sgr)
    return nothing
end

function _text__end_styled_line(display::Display, sgr::String)
    # The reset sequence must be written even if the line is past the display width, since
    # the line can be cropped at the display edge. Otherwise, the style would leak into the
    # rest of the output. Notice that the escape sequence does not change the column.
    (display.has_color && !isempty(sgr)) && print(display.buf_line, _TEXT__STRING_RESET)
    return nothing
end

"""
    _text__styled_print(display::Display, char::Char, sgr::String) -> Nothing
    _text__styled_print(display::Display, line::TextVerticalLine) -> Nothing

Print a single character `char` to the `display` with the style given by the escape
sequence `sgr`, which can be empty for no style, or the vertical `line`.
"""
_text__styled_print(display::Display, line::TextVerticalLine) =
    _text__styled_print(display, line.char, line.sgr)

function _text__styled_print(display::Display, char::Char, sgr::String)
    (!display.has_color || isempty(sgr)) && return _text__print(display, char)

    _text__check_eol(display) && return nothing
    print(display.buf_line, sgr, char, _TEXT__STRING_RESET)
    display.column += textwidth(char)
    return nothing
end

"""
    _text__flush_line(
        display::Display,
        add_continuation_char::Bool = true,
        continuation_char::Char = '⋯';
        crop_line::Bool = true
    ) -> Nothing

Flush the current line buffer to the `display`, cropping and adding continuation characters
if needed.
"""
function _text__flush_line(
    display::Display,
    add_continuation_char::Bool = true,
    continuation_char::Char = '⋯';
    crop_line::Bool = true,
)
    dw   = display.size[2]
    line = String(take!(display.buf_line))

    if crop_line && (dw > 0) && (display.column > dw)
        str_width = printable_textwidth(line)

        crop = crop_width_to_fit_string_in_field(
            line,
            dw;
            add_continuation_char,
            add_space_in_continuation_char = add_continuation_char,
            continuation_char,
            printable_string_width = str_width,
        )

        if crop > 0
            cont_str = add_continuation_char ? (" " * string(continuation_char)) : ""

            cropped_str, ansi = right_crop(
                line, crop; keep_escape_seq = true, printable_string_width = str_width
            )

            line = cropped_str * String(parse_decoration(ansi)) * cont_str
        end
    end

    println(display.buf, rstrip(line))
    display.column = 0

    return nothing
end

"""
    _text__print_aligned(
        display::Display,
        str::AbstractString,
        cell_width::Int,
        alignment::Symbol,
        sgr::String = "",
        fill::Bool = true;
        kwargs...
    ) -> Nothing

Print a string `str` to the `display`, aligned according to `alignment` in a cell of width
`cell_width`. The string is printed with the style given by the escape sequence `sgr`, which
can be empty for no style. The `alignment` can be
`:l` (left), `:r` (right), or `:c` (center). If `fill` is `true`, the string is filled with
spaces to fit the cell width.

# Keywords

- `left_margin::Int`: Number of spaces to print before the aligned cell.
    (**Default**: 0)
- `right_margin::Int`: Number of spaces to print after the aligned cell.
    (**Default**: 0)

Notice that the margins are **not** part of `cell_width`. They exist so that the caller does
not need to build a new string just to pad the cell, which would allocate once per cell and
would also force the padding to be measured again by `printable_textwidth`.
"""
function _text__print_aligned(
    display::Display,
    str::AbstractString,
    cell_width::Int,
    alignment::Symbol,
    sgr::String = "",
    fill::Bool = true;
    left_margin::Int = 0,
    right_margin::Int = 0,
)
    _text__check_eol(display) && return nothing
    str_width = printable_textwidth(str)

    if cell_width > str_width
        remaining = cell_width - str_width

        # Notice that the text back end cannot omit the alignment. Hence, `:n` (no
        # alignment information) is rendered as left alignment.
        if (alignment === :l) || (alignment === :n)
            right_margin += fill ? remaining : 0
        elseif alignment === :c
            Δ = div(remaining, 2)
            left_margin += Δ
            right_margin += fill ? remaining - Δ : 0
        elseif alignment === :r
            left_margin += remaining
        end
    end

    styled = display.has_color && !isempty(sgr)

    styled && print(display.buf_line, sgr)

    for _ in 1:left_margin
        write(display.buf_line, ' ')
    end

    print(display.buf_line, str)

    for _ in 1:right_margin
        write(display.buf_line, ' ')
    end

    styled && print(display.buf_line, _TEXT__STRING_RESET)
    display.column += left_margin + str_width + right_margin

    return nothing
end

"""
    _text__print_horizontal_line(
        display::Display,
        lines::TableLines,
        line::TextHorizontalLine,
        table_data::TableData,
        row_number_column_width::Int,
        row_label_column_width::Int,
        printed_data_column_widths::Vector{Int};
        kwargs...
    ) -> Nothing

Print a horizontal line to `display`.

# Arguments

- `display::Display`: Display where the horizontal line will be printed.
- `lines::TableLines`: Table lines, used to select the intersections with the vertical lines.
- `line::TextHorizontalLine`: Characters and escape sequence used to draw the horizontal
    line, resolved for the line being printed (see [`TextResolvedTableLines`](@ref)).
- `table_data::TableData`: Table data.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.

# Keywords

- `top::Bool`: If `true`, a top horizontal line will be drawn.
    (**Default**: false)
- `bottom::Bool`: If `true`, a bottom horizontal line will be drawn.
    (**Default**: false)
- `row_group_label::Bool`: If `true`, a row group label horizontal line will be drawn. In
    this case, the horizontal line type is also modified by the keyword `top`, whereas the
    keyword `bottom` is neglected. To draw the bottom row label horizontal line, set `top`
    to `false`.
    (**Default**: false)
- `column_label_row::Union{Nothing, Int}`: If it is an integer, the line is drawn after
    this column label row (0 for the line before the first one), and the intersections take
    into account the merged column labels above and below the line (see
    `_text__column_label_intersection`). If it is `nothing`, the intersections are the ones
    of a line inside the table.
    (**Default**: `nothing`)
- `top_row_group_label::Bool`: If `true`, the line is the top line of the table and the
    first row is a row group label, which spans the entire table. Hence, the line has the
    top corners but no intersections.
    (**Default**: false)
"""
function _text__print_horizontal_line(
    display::Display,
    lines::TableLines,
    line::TextHorizontalLine,
    table_data::TableData,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int};
    top::Bool = false,
    bottom::Bool = false,
    row_group_label::Bool = false,
    column_label_row::Union{Nothing, Int} = nothing,
    top_row_group_label::Bool = false,
)
    # == Auxiliary Variables ===============================================================

    tb  = line.chars
    sgr = line.sgr
    row = tb.row

    # Here, we obtain the characters for the left, middle, and right intersections.

    local li, mi, ri

    if top_row_group_label
        li = tb.up_left_corner
        mi = row
        ri = tb.up_right_corner

    elseif !row_group_label
        li = if top
            tb.up_left_corner
        elseif bottom
            tb.bottom_left_corner
        else
            tb.left_intersection
        end

        mi = if top
            tb.up_intersection
        elseif bottom
            tb.bottom_intersection
        else
            tb.middle_intersection
        end

        ri = if top
            tb.up_right_corner
        elseif bottom
            tb.bottom_right_corner
        else
            tb.right_intersection
        end
    else
        li = tb.left_intersection
        mi = top ? tb.bottom_intersection : tb.up_intersection
        ri = tb.right_intersection
    end

    # == Print the Horizontal Line =========================================================

    _text__begin_styled_line(display, sgr)

    # -- Left Intersection -----------------------------------------------------------------

    lines.vertical_line_at_beginning && _text__print(display, li)

    # -- Row Number Column -----------------------------------------------------------------

    if table_data.show_row_number_column
        _text__print(display, row, row_number_column_width + 2)
        (_vertical_line_after_column(lines, table_data, :row_number) != :none) &&
            _text__horizontal_line_intersection(display, mi, row, false)
    end

    # -- Row Label Column ------------------------------------------------------------------

    if _has_row_labels(table_data)
        _text__print(display, row, row_label_column_width + 2)
        (_vertical_line_after_column(lines, table_data, :row_label) != :none) &&
            _text__horizontal_line_intersection(display, mi, row, false)
    end

    # -- Data ------------------------------------------------------------------------------

    for j in eachindex(printed_data_column_widths)
        cw = printed_data_column_widths[j]
        _text__print(display, row, cw + 2)

        role = _vertical_line_after_column(lines, table_data, :data, j)
        role == :none && continue

        if j == last(eachindex(printed_data_column_widths))
            # The line after the data columns is the final intersection of the table unless
            # the continuation column follows it.
            final = role == :right_line
            _text__horizontal_line_intersection(display, final ? ri : mi, row, final)

        else
            intersection = if isnothing(column_label_row)
                mi
            else
                _text__column_label_intersection(
                    table_data, lines, tb, column_label_row, j, top, mi
                )
            end

            _text__horizontal_line_intersection(display, intersection, row, false)
        end
    end

    # -- Table Continuation Column ---------------------------------------------------------

    if _is_horizontally_cropped(table_data)
        _text__print(display, row, 3)
        (_vertical_line_after_column(lines, table_data, :continuation) != :none) &&
            _text__horizontal_line_intersection(display, ri, row, true)
    end

    _text__end_styled_line(display, sgr)

    return nothing
end

"""
    _text__column_label_intersection(
        table_data::TableData,
        lines::TableLines,
        tb::TextTableBorders,
        row_number::Int,
        j::Int,
        top::Bool,
        mi::Char
    ) -> Char

Return the intersection character of the horizontal line drawn after the column label row
`row_number` at the vertical line after the data column `j`, taking into account the merged
column labels above and below the line. `tb` is the character set of the line, `top`
indicates that the line is at the top of the table, and `mi` is the intersection used when
the column labels above and below the line are not merged.
"""
function _text__column_label_intersection(
    table_data::TableData,
    lines::TableLines,
    tb::TextTableBorders,
    row_number::Int,
    j::Int,
    top::Bool,
    mi::Char,
)
    # We must compute if the cell at the top or at the bottom from the current horizontal
    # line is merged. Notice that if we are at the top of the table, the effect is equal to
    # have a merged cell above it.
    top_j₀, top_j₁       = _column_label_limits(table_data, row_number, j + 1)
    bottom_j₀, bottom_j₁ = _column_label_limits(table_data, row_number + 1, j + 1)

    tcm = (top_j₀ != top_j₁) && (j + 1 != top_j₀) || top
    bcm = (bottom_j₀ != bottom_j₁) && (j + 1 != bottom_j₀)

    if lines.suppress_vertical_lines_at_column_labels
        bcm = tcm = true

        # We must have a special treatment if this is the last column label since we must
        # connect the vertical lines with those at the table.
        row_number == length(table_data.column_labels) && (bcm = false)
    end

    (tcm && bcm) && return tb.row
    tcm && return tb.up_intersection
    bcm && return tb.bottom_intersection
    return mi
end

"""
    _text__print_column_label_horizontal_line_only_at_merged_labels(
        display::Display,
        lines::TableLines,
        rl::TextResolvedTableLines,
        table_data::TableData,
        row_number::Int,
        row_number_column_width::Int,
        row_label_column_width::Int,
        printed_data_column_widths::Vector{Int}
    )

Print a column label line to `display` where a horizontal line is drawn only after merged
column labels.

# Arguments

- `display::Display`: Display where the horizontal line will be printed.
- `lines::TableLines`: Table lines, used to select the vertical lines.
- `rl::TextResolvedTableLines`: Resolved table lines. The horizontal line sections use the
    characters and escape sequence of the lines under the merged column labels, whereas the
    vertical line sections use the resolved vertical line characters.
- `table_data::TableData`: Table data.
- `row_number::Int`: Column label row number before the horizontal line.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
"""
function _text__print_column_label_horizontal_line_only_at_merged_labels(
    display::Display,
    lines::TableLines,
    rl::TextResolvedTableLines,
    table_data::TableData,
    row_number::Int,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
)
    # == Auxiliary Variables ===============================================================

    tb  = rl.merged_header.chars
    sgr = rl.merged_header.sgr
    ti  = tb.up_intersection
    ri  = tb.right_intersection
    col = rl.center.char
    row = tb.row

    suppress_vertical_lines = lines.suppress_vertical_lines_at_column_labels

    # == Print the Horizontal Line =========================================================

    _text__begin_styled_line(display, sgr)

    # -- Left Intersection -----------------------------------------------------------------

    lines.vertical_line_at_beginning && _text__print(display, rl.left.char)

    # -- Row Number Column -----------------------------------------------------------------

    if table_data.show_row_number_column
        _text__print(display, ' ', row_number_column_width + 2)
        (_vertical_line_after_column(lines, table_data, :row_number) != :none) &&
            _text__print(display, col)
    end

    # -- Row Label Column ------------------------------------------------------------------

    if _has_row_labels(table_data)
        _text__print(display, ' ', row_label_column_width + 2)
        (_vertical_line_after_column(lines, table_data, :row_label) != :none) &&
            _text__print(display, col)
    end

    # -- Data ------------------------------------------------------------------------------

    for j in eachindex(printed_data_column_widths)
        j₀, j₁ = _column_label_limits(table_data, row_number, j)
        is_merged = j₀ != j₁

        cw = printed_data_column_widths[j]

        if !is_merged
            _text__print(display, ' ', cw + 2)
        else
            _text__print(display, j == j₀ ? " " : row)
            _text__print(display, row, cw)
            _text__print(display, j == j₁ ? " " : row)
        end

        role = _vertical_line_after_column(lines, table_data, :data, j)
        role == :none && continue

        # The line after the last printed data column is never suppressed because it must
        # connect with the vertical lines of the table.
        if j == last(eachindex(printed_data_column_widths))
            _text__print(display, role == :right_line ? rl.right.char : col)

        else
            # Check if we are in the middle of a merged column label.
            if (j₀ != j₁) && (j₁ != j)
                # Check if the next column label is merged so that we can print the correct
                # intersection.
                bottom_j₀, bottom_j₁ = _column_label_limits(table_data, row_number + 1, j)
                ci = (bottom_j₀ != bottom_j₁) && (j != bottom_j₁) ? row : ti

                _text__print(display, suppress_vertical_lines ? row : ci)

                continue
            end

            _text__print(display, suppress_vertical_lines ? " " : col)
        end
    end

    # -- Table Continuation Column ---------------------------------------------------------

    if _is_horizontally_cropped(table_data)
        _text__print(display, row, 3)
        (_vertical_line_after_column(lines, table_data, :continuation) != :none) &&
            _text__horizontal_line_intersection(display, ri, row, true)
    end

    _text__end_styled_line(display, sgr)

    return nothing
end

"""
    _text__horizontal_line(rl::TextResolvedTableLines, role::Symbol) -> TextHorizontalLine

Return the resolved horizontal line in `rl` with the `role` returned by
`_horizontal_line_after_row` (`:top_line`, `:header_line`, `:middle_line`, or
`:bottom_line`).
"""
function _text__horizontal_line(rl::TextResolvedTableLines, role::Symbol)
    role == :top_line && return rl.top
    role == :header_line && return rl.header
    role == :bottom_line && return rl.bottom
    return rl.middle
end

"""
    _text__vertical_line(rl::TextResolvedTableLines, role::Symbol) -> TextVerticalLine

Return the resolved vertical line in `rl` with the `role` returned by
`_vertical_line_after_column` (`:left_line`, `:center_line`, or `:right_line`). The center
line is returned for `:none`, which must be checked before drawing the line.
"""
function _text__vertical_line(rl::TextResolvedTableLines, role::Symbol)
    role == :right_line && return rl.right
    role == :left_line && return rl.left
    return rl.center
end

"""
    _text__horizontal_line_intersection(
        display::Display,
        intersection::Char,
        row::Char,
        final_intersection::Bool
    ) -> Nothing

Print to `display` the horizontal line `intersection` if we have enough space. Otherwise,
print `row`. The argument `final_intersection` indicates that we are printing the final
intersection of the table. In that case, we print `intersection` if we have at least one
remaining space.
"""
function _text__horizontal_line_intersection(
    display::Display, intersection::Char, row::Char, final_intersection::Bool
)
    # If the display width is not positive, it means we do not have a limit. Hence, just
    # print the intersection.
    if display.size[2] <= 0
        _text__print(display, intersection)
        return nothing
    end

    # If the display has only two characters and we are not at the final intersection, we
    # should use the row character because the other lines will be cropped.
    num_remaining_chars = display.size[2] - display.column

    if num_remaining_chars > 2
        _text__print(display, intersection)
    elseif (num_remaining_chars >= 1) && final_intersection
        _text__print(display, intersection)
    else
        _text__print(display, row)
    end

    return nothing
end
