## Description #############################################################################
#
# Private functions for the text back end.
#
############################################################################################

# == Footnotes =============================================================================

const _TEXT__EXPONENTS = ("⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹")

function _text__render_footnote_superscript(number::Int)
    aux = abs(number)
    str = ""

    while aux ≥ 1
        i = aux % 10
        str = _TEXT__EXPONENTS[i + 1] * str
        aux = floor(aux / 10)
    end

    return str
end

# == Vertical Cropping =====================================================================

"""
    _text__number_of_required_lines(table_data::TableData, tf::TextTableFormat, horizontal_lines_at_data_rows::AbstractVector{Int},) -> NTuple{4, Int}

Compute the total number of lines required to print the table.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_data_rows::AbstractVector{Int}`: Horizontal lines at data rows.

# Returns

- `Int`: Total number of lines required to print the table.
- `Int`: Number of lines required before printing the data.
- `Int`: Number of lines required after printing the data.
- `Int`: Number of horizontal lines required to print the table.
"""
function _text__number_of_required_lines(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_data_rows::AbstractVector{Int},
)
    # Compute the number of lines we must have before printing the data.
    num_lines_before_data =
        1 + # ................................................................ Margin at top
        tf.horizontal_line_at_beginning +
        length(table_data.column_labels) +
        tf.horizontal_line_after_column_labels

    # Compute the number of lines we must have after printing the data.
    num_lines_after_data =
        (
            _has_summary_rows(table_data) ?
                length(table_data.summary_rows) + tf.horizontal_line_before_summary_rows :
                0
        ) +
        tf.horizontal_line_at_end +
        (
            _has_footnotes(table_data) ? length(table_data.footnotes) : 0
        ) +
        2 # ................................................................ Margin at bottom

    # Count how many horizontal table lines we must draw.
    num_horizontal_lines = 0
    for i in 1:(table_data.num_rows - 1)
        num_horizontal_lines += i ∈ horizontal_lines_at_data_rows
    end

    # Obtain the total number of lines required to print the table.
    total_table_lines =
        num_lines_before_data +
        table_data.num_rows +
        num_horizontal_lines +
        num_lines_after_data

    return (
        total_table_lines,
        num_lines_before_data,
        num_lines_after_data,
        num_horizontal_lines
    )
end

"""
    _text__design_vertical_cropping(table_data::TableData, tf::TextTableFormat, horizontal_lines_at_data_rows::AbstractVector{Int}, display_number_of_rows::Int) -> Int, Bool

Design the vertical cropping of the table by computing how many data lines we can print and
if we must suppress the horizontal line before the continuation line.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_data_rows::AbstractVector{Int}`: Horizontal lines at data rows.
- `display_number_of_rows::Int`: Number of rows in the display.

# Returns

- `Int`: Number of data rows we can print.
- `Bool`: If `true`, we must suppress the horizontal line before the continuation line.
"""
function _text__design_vertical_cropping(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_data_rows::AbstractVector{Int},
    show_omitted_row_summary::Bool,
    display_number_of_rows::Int
)
    num_data_rows = 0
    suppress_vline_before_continuation_row = false

    # Compute the number of required lines to print the table.
    total_table_lines, num_lines_before_data, num_lines_after_data, _ =
        _text__number_of_required_lines(table_data, tf, horizontal_lines_at_data_rows)

    # Check if we can draw the entire table, meaning that a continuation line is not
    # necessary.
    (total_table_lines <= display_number_of_rows) && return num_data_rows, false

    # We need one additional line to show the omitted row summary, if required, since we
    # must crop the table here.
    num_lines_after_data += show_omitted_row_summary

    if table_data.vertical_crop_mode == :bottom
        # In bottom mode, the continuation line will be at the end. Hence, we can assume
        # that all the necessary data lines are at the top for the sake of computing the
        # number of data rows we can print. The last `1` refers to the continuation line
        # that we must print since we reach this part of the code.
        current_line = num_lines_before_data + num_lines_after_data + 1

        for i in 1:table_data.num_rows
            Δ = 1
            num_remaining_lines = display_number_of_rows - current_line

            if i ∈ horizontal_lines_at_data_rows
                Δ += 1

                if num_remaining_lines <= 0
                    break

                elseif num_remaining_lines <= 2
                    suppress_vline_before_continuation_row = num_remaining_lines == 1
                    num_data_rows += 1
                    break
                end

            else
                (num_remaining_lines < 1) && break
            end

            num_data_rows += 1
            current_line += Δ
        end

    else
        # Compute how many lines we must draw before the continuation line.
        cont_line_id = num_lines_before_data + div(
            display_number_of_rows -
            num_lines_before_data -
            num_lines_after_data,
            2,
            RoundUp
        )

        # == Process Data Rows Before Continuation Line ====================================

        current_line = num_lines_before_data

        # We will compute the number of data lines before the continuation line.
        for i in 1:table_data.num_rows
            Δ = 1
            num_remaining_lines = cont_line_id - current_line

            if i ∈ horizontal_lines_at_data_rows
                Δ += 1

                if num_remaining_lines <= 0
                    break

                elseif num_remaining_lines <= 2
                    suppress_vline_before_continuation_row = num_remaining_lines == 1
                    num_data_rows += 1
                    current_line += 1 + !suppress_vline_before_continuation_row
                    break
                end

            else
                (num_remaining_lines < 1) && break
            end

            num_data_rows += 1
            current_line += Δ
        end

        # Consider the continuation line.
        current_line += 1

        # == Process Data Rows After Continuation Line =====================================

        current_line += num_lines_after_data

        for i in table_data.num_rows:-1:1
            Δ = 1
            num_remaining_lines = display_number_of_rows - current_line

            if i ∈ horizontal_lines_at_data_rows
                Δ += 1

                if num_remaining_lines <= 0
                    break

                elseif num_remaining_lines <= 2
                    suppress_vline_before_continuation_row = num_remaining_lines == 1
                    num_data_rows += 1
                    break
                end

            else
                (num_remaining_lines < 1) && break
            end

            num_data_rows += 1
            current_line += Δ
        end
    end

    return num_data_rows, suppress_vline_before_continuation_row
end
