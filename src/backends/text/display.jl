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

function _text__print(display::Display, str::AbstractString)
    _text__check_eol(display) && return nothing
    print(display.buf_line, str)
    display.column += printable_textwidth(str)
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
        if add_continuation_char
            line =
                first(right_crop(line, display.column - dw + 2)) *
                " $(continuation_char)" *
                (display.has_color ? _TEXT__STRING_RESET : "")
        else
            line = first(right_crop(line, display.column - dw))
        end
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
    decoration::Crayon = _TEXT__DEFAULT
)
    aligned_str = align_string(str, cell_width, alignment; fill = true)

    if display.has_color && (decoration != _TEXT__DEFAULT)
        aligned_str = "$(decoration)$(aligned_str)$(_TEXT__STRING_RESET)"
    end

    _text__print(display, aligned_str)
    return nothing
end

function _text__print_horizontal_line(
    display::Display,
    tf::TextTableFormat,
    table_data::TableData,
    vertical_lines_at_data_columns::AbstractVector{Int},
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
    top::Bool = false,
    bottom::Bool = false,
)
    # == Auxiliary Variables ===============================================================

    # Here, we obtain the characters for the left, middle, and right intersections. We also
    # convert them to string.

    li = if top
        string(tf.up_left_corner)
    elseif bottom
        string(tf.bottom_left_corner)
    else
        string(tf.left_intersection)
    end

    mi = if top
        string(tf.up_intersection)
    elseif bottom
        string(tf.bottom_intersection)
    else
        string(tf.middle_intersection)
    end

    ri = if top
        string(tf.up_right_corner)
    elseif bottom
        string(tf.bottom_right_corner)
    else
        string(tf.right_intersection)
    end

    row = string(tf.row)

    table_continuation_column = _is_horizontally_cropped(table_data)

    # == Print the Horizontal Line =========================================================

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
        elseif j ∈ vertical_lines_at_data_columns
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
