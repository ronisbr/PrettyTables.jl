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
    display.column += textwidth(str)
    return nothing
end

function _text__flush_line(display::Display, add_continuation_char::Bool = true)
    dw   = display.size[2]
    line = String(take!(display.buf_line))

    if (dw > 0) && (display.column > dw)
        if add_continuation_char
            line =
                first(right_crop(line, display.column - dw + 2)) *
                " $(display.continuation_char)"
        else
            line = first(right_crop(line, display.column - dw))
        end
    end

    println(display.buf, line)
    display.column = 0
    display.row += 1
    return nothing
end

function _text__aligned_print(
    display::Display,
    str::AbstractString,
    cell_width::Int,
    alignment::Symbol
)
    if alignment == :r
        _text__print(display, lpad(str, cell_width))

    elseif alignment == :c
        tw = textwidth(str)
        Δ = max(div(cell_width - tw, 2), 0)
        _text__print(display, " "^Δ * str * " "^(cell_width - tw - Δ))

    else
        _text__print(display, rpad(str, cell_width))
    end

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
    bottom::Bool = false
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

    # == Print the Horizontal Line =========================================================

    # -- Left Intersection -----------------------------------------------------------------

    tf.vertical_line_at_beginning && _text__print(display, li)

    # -- Row Number Column -----------------------------------------------------------------

    if table_data.show_row_number_column
        _text__print(display, row^(row_number_column_width + 2))
        tf.vertical_line_after_row_number_column && _text__print(display, mi)
    end

    # -- Row Label Column ------------------------------------------------------------------

    if _has_row_labels(table_data)
        _text__print(display, row^(row_label_column_width + 2))
        tf.vertical_line_after_row_label_column && _text__print(display, mi)
    end

    # -- Data ------------------------------------------------------------------------------

    for j in eachindex(printed_data_column_widths)
        cw = printed_data_column_widths[j]
        _text__print(display, row^(cw + 2))

        if (j == last(eachindex(printed_data_column_widths)))
            tf.vertical_line_at_end && _text__print(display, ri)
        elseif j ∈ vertical_lines_at_data_columns
            _text__print(display, mi)
        end
    end

    return nothing
end
