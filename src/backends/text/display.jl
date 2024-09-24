## Description #############################################################################
#
# Functions related to display manipulation.
#
############################################################################################

function _text__check_eol(display::Display)
    w = display.size[2]
    return (w > 0) && (display.column > display.size[2])
end

_text__print(display::Display, char::Char) = _text__print(display, string(char))

function _text__print(display::Display, str::AbstractString, str_width::Int = -1)
    _text__check_eol(display) && return nothing
    print(display.buf_line, str)
    display.column += str_width < 0 ? printable_textwidth(str) : str_width
    return nothing
end

function _text__styled_print(display::Display, char::Char, crayon::Crayon)
    return _text__styled_print(display, string(char), crayon)
end

function _text__styled_print(display::Display, str::AbstractString, crayon::Crayon)
    (!display.has_color || crayon == _TEXT__DEFAULT) && return _text__print(display, str)

    _text__print(display, string(crayon) * str * _TEXT__STRING_RESET)
    return nothing
end

function _text__flush_line(
    display::Display,
    add_continuation_char::Bool = true,
    continuation_char::Char = '⋯'
)
    dw   = display.size[2]
    line = String(take!(display.buf_line))

    if (dw > 0) && (display.column > dw)
        line = fit_string_in_field(
            line,
            dw;
            add_continuation_char,
            add_space_in_continuation_char = add_continuation_char,
            crop_side = :right,
            keep_escape_seq = true
        )
    end

    println(display.buf, line)
    display.column = 0
    display.row += 1

    return nothing
end

function _text__print_aligned(
    display::Display,
    str::AbstractString,
    cell_width::Int,
    alignment::Symbol,
    crayon::Crayon = _TEXT__DEFAULT,
    fill::Bool = true
)
    aligned_str = align_string(str, cell_width, alignment; fill)
    _text__styled_print(display, aligned_str, crayon)
    return nothing
end

"""
    _text__print_horizontal_line(display::Display, tf::TextTableFormat, crayon::Crayon, table_data::TableData, right_vertical_lines_at_data_columns::AbstractVector{Int}, row_number_column_width::Int, row_label_column_width::Int, printed_data_column_widths::Vector{Int}, top::Bool = false, bottom::Bool = false, row_group_label::Bool = false) -> Nothing

Print a horizontal line to `display`.

# Arguments

- `display::Display`: Display where the horizontal line will be printed.
- `tf::TextTableFormat`: Table format.
- `crayon::Crayon`: Crayon used to print the horizontal line.
- `table_data::TableData`: Table data.
- `right_vertical_lines_at_data_columns::AbstractVector{Int}`: Location of the right vertical
    lines at the data columns.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
- `top::Bool`: If `true`, a top horizontal line will be drawn.
    (**Default**: false)
- `bottom::Bool`: If `true`, a bottom horizontal line will be drawn.
    (**Default**: false)
- `row_group_label::Bool`: If `true`, a row group label horizontal line will be drawn. In
    this case, the horizontal line type is also modified by the keyword `top`, whereas the
    keyword `bottom` is neglected. To draw the bottom row label horizontal line, set `top`to
    `false`.
    (**Default**: false)
"""
function _text__print_horizontal_line(
    display::Display,
    tf::TextTableFormat,
    crayon::Crayon,
    table_data::TableData,
    right_vertical_lines_at_data_columns::AbstractVector{Int},
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
    top::Bool = false,
    bottom::Bool = false,
    row_group_label::Bool = false
)
    # == Auxiliary Variables ===============================================================

    tb = tf.borders

    # Here, we obtain the characters for the left, middle, and right intersections. We also
    # convert them to string.

    local li, mi, ri

    if !row_group_label
        li = if top
            string(tb.up_left_corner)
        elseif bottom
            string(tb.bottom_left_corner)
        else
            string(tb.left_intersection)
        end

        mi = if top
            string(tb.up_intersection)
        elseif bottom
            string(tb.bottom_intersection)
        else
            string(tb.middle_intersection)
        end

        ri = if top
            string(tb.up_right_corner)
        elseif bottom
            string(tb.bottom_right_corner)
        else
            string(tb.right_intersection)
        end
    else
        li = string(tb.left_intersection)
        mi = top ? string(tb.bottom_intersection) : string(tb.up_intersection)
        ri = string(tb.right_intersection)
    end

    row = string(tb.row)

    table_continuation_column = _is_horizontally_cropped(table_data)

    # == Print the Horizontal Line =========================================================

    crayon != _TEXT__DEFAULT && _text__print(display, string(crayon))

    # -- Left Intersection -----------------------------------------------------------------

    tf.vertical_line_at_beginning && _text__print(display, li)

    # -- Row Number Column -----------------------------------------------------------------

    if table_data.show_row_number_column
        _text__print(display, row^(row_number_column_width + 2))
        tf.vertical_line_after_row_number_column && _text__horizontal_line_intersection(
            display,
            mi,
            row,
            false
        )
    end

    # -- Row Label Column ------------------------------------------------------------------

    if _has_row_labels(table_data)
        _text__print(display, row^(row_label_column_width + 2))
        tf.vertical_line_after_row_label_column && _text__horizontal_line_intersection(
            display,
            mi,
            row,
            false
        )
    end

    # -- Data ------------------------------------------------------------------------------

    for j in eachindex(printed_data_column_widths)
        cw = printed_data_column_widths[j]
        _text__print(display, row^(cw + 2))

        if (j == last(eachindex(printed_data_column_widths)))
            tf.vertical_line_after_data_columns && _text__horizontal_line_intersection(
                display,
                table_continuation_column ? mi : ri,
                row,
                !table_continuation_column
            )
        elseif j ∈ right_vertical_lines_at_data_columns
            _text__horizontal_line_intersection(display, mi, row, false)
        end
    end

    # -- Table Continuation Column ---------------------------------------------------------

    if table_continuation_column
        _text__print(display, row^3)
        tf.vertical_line_after_continuation_column && _text__horizontal_line_intersection(
            display,
            ri,
            row,
            true
        )
    end

    crayon != _TEXT__DEFAULT && _text__print(display, _TEXT__STRING_RESET)

    return nothing
end

"""
    _text__print_column_label_horizontal_line(display::Display, tf::TextTableFormat, crayon::Crayon, table_data::TableData, row_number::Int, right_vertical_lines_at_data_columns::AbstractVector{Int}, row_number_column_width::Int, row_label_column_width::Int, printed_data_column_widths::Vector{Int}, top::Bool = false, bottom::Bool = false)

Print a column label horizontal line to `display`.

# Arguments

- `display::Display`: Display where the horizontal line will be printed.
- `tf::TextTableFormat`: Table format.
- `crayon::Crayon`: Crayon used to print the horizontal line.
- `table_data::TableData`: Table data.
- `row_number::Int`: Column label row number before the horizontal line.
- `right_vertical_lines_at_data_columns::AbstractVector{Int}`: Location of the right vertical
    lines at the data columns.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
- `top::Bool`: If `true`, a top horizontal line will be drawn.
    (**Default**: false)
- `bottom::Bool`: If `true`, a bottom horizontal line will be drawn.
    (**Default**: false)
"""
function _text__print_column_label_horizontal_line(
    display::Display,
    tf::TextTableFormat,
    crayon::Crayon,
    table_data::TableData,
    row_number::Int,
    right_vertical_lines_at_data_columns::AbstractVector{Int},
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
    top::Bool = false,
    bottom::Bool = false,
)
    # == Auxiliary Variables ===============================================================

    tb = tf.borders
    num_column_labels = length(table_data.column_labels)

    # Here, we obtain the characters for the left, middle, and right intersections. We also
    # convert them to string.

    local li, mi, ri

    ti = string(tb.up_intersection)
    bi = string(tb.bottom_intersection)

    li = if top
        string(tb.up_left_corner)
    elseif bottom
        string(tb.bottom_left_corner)
    else
        string(tb.left_intersection)
    end

    mi = if top
        ti
    elseif bottom
        bi
    else
        string(tb.middle_intersection)
    end

    ri = if top
        string(tb.up_right_corner)
    elseif bottom
        string(tb.bottom_right_corner)
    else
        string(tb.right_intersection)
    end

    row = string(tb.row)

    table_continuation_column = _is_horizontally_cropped(table_data)

    # == Print the Horizontal Line =========================================================

    crayon != _TEXT__DEFAULT && _text__print(display, string(crayon))

    # -- Left Intersection -----------------------------------------------------------------

    tf.vertical_line_at_beginning && _text__print(display, li)

    # -- Row Number Column -----------------------------------------------------------------

    if table_data.show_row_number_column
        _text__print(display, row^(row_number_column_width + 2))
        tf.vertical_line_after_row_number_column && _text__horizontal_line_intersection(
            display,
            mi,
            row,
            false
        )
    end

    # -- Row Label Column ------------------------------------------------------------------

    if _has_row_labels(table_data)
        _text__print(display, row^(row_label_column_width + 2))
        tf.vertical_line_after_row_label_column && _text__horizontal_line_intersection(
            display,
            mi,
            row,
            false
        )
    end

    # -- Data ------------------------------------------------------------------------------

    for j in eachindex(printed_data_column_widths)
        cw = printed_data_column_widths[j]
        _text__print(display, row^(cw + 2))

        if (j == last(eachindex(printed_data_column_widths)))
            tf.vertical_line_after_data_columns && _text__horizontal_line_intersection(
                display,
                table_continuation_column ? mi : ri,
                row,
                !table_continuation_column
            )
        elseif j ∈ right_vertical_lines_at_data_columns
            # We must compute if the cell at the top or at the bottom from the current
            # horizontal line is merged. Notice that if we are at the top of the table, the
            # effect is equal to have a merged cell above it.
            tcm = _is_column_label_cell_merged(table_data, row_number,     j + 1) || top
            bcm = _is_column_label_cell_merged(table_data, row_number + 1, j + 1)

            if tf.suppress_vertical_lines_at_column_labels
                bcm = tcm = true

                # We must have a specia treatment if this is the last column label since we
                # must connect the vertical lines with those at the table.
                row_number == num_column_labels && (bcm = false)
            end

            aux = if tcm && bcm
                row
            elseif tcm && !bcm
                ti
            elseif !tcm && bcm
                bi
            else
                mi
            end

            _text__horizontal_line_intersection(display, aux, row, false)
        end
    end

    # -- Table Continuation Column ---------------------------------------------------------

    if table_continuation_column
        _text__print(display, row^3)
        tf.vertical_line_after_continuation_column && _text__horizontal_line_intersection(
            display,
            ri,
            row,
            true
        )
    end

    crayon != _TEXT__DEFAULT && _text__print(display, _TEXT__STRING_RESET)

    return nothing
end

"""
    _text__horizontal_line_intersection(display::Display, intersection::String, row::String, final_intersection::Bool) -> Nothing

Print to `display` the horizontal line `intersection` if we have enough space. Otherwise,
print `row`. The argument `final_intersection` indicates that we are printing the final
intersection of the table. In that case, we print `intersection` if we have at least two
remaning spaces.
"""
function _text__horizontal_line_intersection(
    display::Display,
    intersection::String,
    row::String,
    final_intersection::Bool
)
    # If the display size is negative, it means we do not have a limite. Hence, just print
    # the intersection.
    if display.size[2] < 0
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
