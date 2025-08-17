## Description #############################################################################
#
# Private functions for the text back end.
#
############################################################################################

# == Footnotes =============================================================================

const _TEXT__EXPONENTS = ("⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹")

"""
    _text__render_footnote_superscript(number::Int) -> String

Render the superscript of a footnote.
"""
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

# == Horizontal Cropping ===================================================================

"""
    _text__is_printing_horizontally_limited(table_data::TableData, fit_table_in_display_horizontally::Bool, display_width::Int, num_printed_data_columns::Int, table_width_wo_cont_col::Int, vertical_line_after_continuation_column::Bool) -> Bool

Return `true` if the table printing is horizontally limited by the display, meaning that it
will be cropped.

# Arguments

- `table_data::TableData`: Table data.
- `fit_table_in_display_horizontally::Bool`: If `true`, the table must fit in the display
    horizontally.
- `display_width::Int`: Display width.
- `num_printed_data_columns::Int`: Number of printed data columns.
- `table_width_wo_cont_col::Int`: Width of the table without the continuation column.
- `vertical_line_after_continuation_column::Bool`: If `true`, there is a vertical line
    after the continuation column.
"""
function _text__is_printing_horizontally_limited(
    table_data::TableData,
    fit_table_in_display_horizontally::Bool,
    display_width::Int,
    num_printed_data_columns::Int,
    table_width_wo_cont_col::Int,
    vertical_line_after_continuation_column::Bool
)
    horizontally_limited_by_display = false

    if fit_table_in_display_horizontally && (display_width > 0)
        # Here we have four possibilities:
        #
        #   1. We can show the entire table. If not, we will have a continuation column.
        #   2. We cannot show the table continuation column, meaning that the table is
        #      horizontally limited by the display.
        #   3. We can partially show the continuation column, meaning that the table is
        #      horizontally limited by the display but there is a continuation column.
        #   4. We can show the continuation column, meaning that the table is horizontally
        #      cropped by the user specification.

        num_remaining_columns = display_width - table_width_wo_cont_col

        horizontally_limited_by_display =
            if (
                (num_remaining_columns > 0) ||
                (
                    (num_remaining_columns == 0) &&
                    (num_printed_data_columns == table_data.num_columns)
                )
            )
                false
            else
                num_remaining_columns < (3 + vertical_line_after_continuation_column)
            end
    end

    return horizontally_limited_by_display
end

"""
    _text__number_of_printed_data_columns(display_width::Int, table_data::TableData, tf::TextTableFormat, vertical_lines_at_data_columns::AbstractVector{Int}, row_number_column_width::Int, row_label_column_width::Int, printed_data_column_widths::Vector{Int}) -> Int

Compute the number of printed data columns.

# Arguments

- `display_width::Int`: Display width.
- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `vertical_lines_at_data_columns::AbstractVector{Int}`: List of columns where a vertical
    line must be drawn after the cell.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
"""
function _text__number_of_printed_data_columns(
    display_width::Int,
    table_data::TableData,
    tf::TextTableFormat,
    vertical_lines_at_data_columns::AbstractVector{Int},
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int}
)
    display_width <= 0 && return table_data.num_columns

    current_column  = 0
    current_column += tf.vertical_line_at_beginning + (
        if table_data.show_row_number_column
            row_number_column_width + tf.vertical_line_after_row_number_column + 2
        else
            0
        end
    ) + (
        if _has_row_labels(table_data)
            row_label_column_width + tf.vertical_line_after_row_label_column + 2
        else
            0
        end
    )

    num_printed_data_columns = 0

    for j in eachindex(printed_data_column_widths)
        current_column += 1 + printed_data_column_widths[j]
        num_remaining_columns = display_width - current_column

        num_remaining_columns <= 1 && break

        num_printed_data_columns += 1
        current_column += (j ∈ vertical_lines_at_data_columns) + 1
    end

    return num_printed_data_columns
end

# == Vertical Cropping =====================================================================

"""
    _text__number_of_required_lines(table_data::TableData, tf::TextTableFormat, horizontal_lines_at_column_lables::AbstractVector{Int}, horizontal_lines_at_data_rows::AbstractVector{Int}, new_line_at_end::Bool) -> NTuple{4, Int}

Compute the total number of lines required to print the table.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_column_labels::AbstractVector{Int}`: Horizontal lines at column
    labels.
- `horizontal_lines_at_data_rows::AbstractVector{Int}`: Horizontal lines at data rows.
- `new_line_at_end::Bool`: If `true`, we must add a new line at the end of the table.

# Returns

- `Int`: Total number of lines required to print the table.
- `Int`: Number of lines required before printing the data.
- `Int`: Number of lines required after printing the data.
"""
function _text__number_of_required_lines(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_column_lables::AbstractVector{Int},
    horizontal_lines_at_data_rows::AbstractVector{Int},
    new_line_at_end::Bool
)
    # Compute the number of lines we must have before printing the data.
    num_lines_before_data =
        !isempty(table_data.title) +
        !isempty(table_data.subtitle) +
        tf.horizontal_line_at_beginning +
        length(table_data.column_labels) +
        length(horizontal_lines_at_column_lables) +
        tf.horizontal_line_after_column_labels

    # Compute the number of lines we must have after printing the data.
    num_lines_after_data =
        tf.horizontal_line_after_data_rows +
        (
            if _has_summary_rows(table_data)
                # The horizontal line after data rows is already counted.
                (!tf.horizontal_line_after_data_rows && tf.horizontal_line_before_summary_rows) +
                length(table_data.summary_rows) +
                tf.horizontal_line_after_summary_rows
            else
                0
            end
        ) +
        (
            _has_footnotes(table_data) ? length(table_data.footnotes) : 0
        ) +
        !isempty(table_data.source_notes) +
        new_line_at_end +
        1 # ............................................................... Margin at bottom

    # Count how many non-data lines we must print in data row section. This number includes
    # the horizontal lines and the row group labels.
    num_non_data_lines = 0

    for i in 1:table_data.num_rows
        if i != table_data.num_rows
            num_non_data_lines += i ∈ horizontal_lines_at_data_rows
        end

        if _print_row_group_label(table_data, i)
            num_non_data_lines +=
                1 +
                tf.horizontal_line_before_row_group_label +
                tf.horizontal_line_after_row_group_label
        end
    end

    # Obtain the total number of lines required to print the table.
    total_table_lines =
        num_lines_before_data +
        table_data.num_rows +
        num_non_data_lines +
        num_lines_after_data

    return (
        total_table_lines,
        num_lines_before_data,
        num_lines_after_data
    )
end

"""
    _text__design_vertical_cropping(table_data::TableData, tf::TextTableFormat, horizontal_lines_at_column_labels::AbstractVector{Int}, horizontal_lines_at_data_rows::AbstractVector{Int}, show_omitted_row_summary::Bool, display_number_of_rows::Int, new_line_at_end::Bool = true) -> Int, Bool

Design the vertical cropping of the table by computing how many data lines we can print and
if we must suppress the horizontal line before or after the continuation line.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_column_labels::AbstractVector{Int}`: Horizontal lines at column
    labels.
- `horizontal_lines_at_data_rows::AbstractVector{Int}`: Horizontal lines at data rows.
- `show_omitted_row_summary::Bool`: If `true`, we must show the omitted row summary.
- `display_number_of_rows::Int`: Number of rows in the display.
- `new_line_at_end::Bool`: If `true`, we must add a new line at the end of the table.

# Returns

- `Int`: Number of data rows we can print.
- `Bool`: If `true`, we must suppress the horizontal line before the continuation line.
- `Bool`: If `true`, we must suppress the horizontal line after the continuation line.
"""
function _text__design_vertical_cropping(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_column_labels::AbstractVector{Int},
    horizontal_lines_at_data_rows::AbstractVector{Int},
    show_omitted_row_summary::Bool,
    display_number_of_rows::Int,
    new_line_at_end::Bool
)
    num_data_rows = 0

    # This variable indicates if we must suppress the horizontal line before the
    # continuation row if it exists.
    suppress_hline_before_continuation_row = false

    # This variable indicates if we must suppress the horizontal line after the
    # continuation row if it exists.
    suppress_hline_after_continuation_row = false

    # Compute the number of required lines to print the table.
    total_table_lines, num_lines_before_data, num_lines_after_data =
        _text__number_of_required_lines(
            table_data,
            tf,
            horizontal_lines_at_column_labels,
            horizontal_lines_at_data_rows,
            new_line_at_end
        )

    # Check if we can draw the entire table, meaning that a continuation line is not
    # necessary.
    (total_table_lines <= display_number_of_rows) && return table_data.num_rows, false, false

    # We need one additional line to show the omitted row summary, if required, since we
    # must crop the table here.
    num_lines_after_data += show_omitted_row_summary

    required_lines_for_row_group_label =
        1 +
        tf.horizontal_line_before_row_group_label +
        tf.horizontal_line_after_row_group_label

    if table_data.vertical_crop_mode == :bottom

        # In bottom mode, the continuation line will be at the end.
        available_lines =
            display_number_of_rows -
            num_lines_before_data -
            num_lines_after_data -
            1 # ........................................................... Continuation row

        num_printed_lines = 0

        for i in 1:table_data.num_rows
            hline               = i ∈ horizontal_lines_at_data_rows
            row_group_label     = _print_row_group_label(table_data, i)
            num_remaining_lines = available_lines - num_printed_lines

            # Compute the number of lines required for the current row.
            Δ = 1 + hline + (row_group_label ? required_lines_for_row_group_label : 0)

            # If the next line is a row group label and we must draw the horizontal line
            # here, we will need to remove this horizontal line.
            if _print_row_group_label(table_data, i + 1) &&
                tf.horizontal_line_before_row_group_label &&
                hline
                Δ -= 1
            end

            # Check if we have enough vertical space to display the line. If not, try to
            # remove horizontal line before the continuation line to make it fit.
            if num_remaining_lines < Δ
                if hline && (Δ - num_remaining_lines == 1)
                    suppress_hline_before_continuation_row = true
                    num_data_rows += 1
                end

                break
            end

            # If we reach this point, we can print the data row.
            num_data_rows     += 1
            num_printed_lines += Δ
        end

    else
        # To design the number of data rows we can print, we will process one line at the
        # beginning of the table and one line at the end of table counting the number of
        # printed lines. When it reaches the maximum number of lines we have, we stop the
        # algorithm. Notice that sometimes we might have a blank space because we have
        # non-data rows to print that consumes display lines, such as row group labels and
        # horizontal lines.
        #
        # NOTE: If we reach this point, we know that a continuation row must be printed.

        available_lines =
            display_number_of_rows -
            num_lines_before_data -
            num_lines_after_data -
            1 # ........................................................... Continuation row

        num_printed_lines = 0

        for row in 1:div(table_data.num_rows, 2, RoundDown)

            # == Line at the Beginning of the Table ========================================

            i = row

            hline               = i ∈ horizontal_lines_at_data_rows
            row_group_label     = _print_row_group_label(table_data, i)
            num_remaining_lines = available_lines - num_printed_lines

            # Compute the number of lines required for the current row.
            Δ = 1 + hline + (row_group_label ? required_lines_for_row_group_label : 0)

            # If the next line is a row group label and we must draw the horizontal line
            # here, we will need to remove this horizontal line.
            if _print_row_group_label(table_data, i + 1) &&
                tf.horizontal_line_before_row_group_label &&
                hline

                Δ -= 1
            end

            # Check if we have enough vertical space to display the line. If not, try to
            # remove horizontal line before the continuation line to make it fit.
            if num_remaining_lines < Δ
                if hline && (Δ - num_remaining_lines == 1)
                    suppress_hline_before_continuation_row = true
                    num_data_rows += 1
                end

                break
            end

            # If we reach this point, we can print the data row.
            num_data_rows     += 1
            num_printed_lines += Δ

            # == Line at the End of the Table ==============================================

            i = table_data.num_rows - row + 1

            hline               = i ∈ horizontal_lines_at_data_rows
            row_group_label     = _print_row_group_label(table_data, i)
            num_remaining_lines = available_lines - num_printed_lines

            # Compute the number of lines required for the current row.
            Δ = 1 + hline + (row_group_label ? required_lines_for_row_group_label : 0)

            # Check if we have enough vertical space to display the line. If not, try to
            # remove horizontal line before the continuation line to make it fit.
            if num_remaining_lines < Δ
                if hline && (Δ - num_remaining_lines == 1)
                    suppress_hline_after_continuation_row = true
                    num_data_rows += 1
                end

                break
            end

            # If we reach this point, we can print the data row.
            num_data_rows     += 1
            num_printed_lines += Δ
        end
    end

    return (
        num_data_rows,
        suppress_hline_before_continuation_row,
        suppress_hline_after_continuation_row
    )
end

"""
    _text__design_vertical_cropping_with_line_breaks(table_data::TableData, table_str::Matrix{String}, tf::TextTableFormat, horizontal_lines_at_column_labels::AbstractVector{Int}, horizontal_lines_at_data_rows::AbstractVector{Int}, show_omitted_row_summary::Bool, display_number_of_rows::Int, new_line_at_end::Bool, num_printed_data_columns::Int) -> Int, Int, Bool

Design the vertical cropping of the table when the user wants line breaks by computing how
many data lines we can print and if we must suppress the horizontal line before the
continuation line. Notice that middle vertical cropping is not supported when we have line
breaks.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_column_labels::AbstractVector{Int}`: Horizontal lines at column
    labels.
- `horizontal_lines_at_data_rows::AbstractVector{Int}`: Horizontal lines at data rows.
- `show_omitted_row_summary::Bool`: If `true`, we must show the omitted row summary.
- `display_number_of_rows::Int`: Number of rows in the display.
- `new_line_at_end::Bool`: If `true`, we must add a new line at the end of the table.
- `num_printed_data_columns::Int`: Number of printed data columns.

# Returns

- `Int`: Number of data rows we can fully print.
- `Bool`: If `true`, the printing process with crop the last row.
- `Bool`: If `true`, we must suppress the horizontal line before the continuation line.
"""
function _text__design_vertical_cropping_with_line_breaks(
    table_data::TableData,
    table_str::Matrix{String},
    tf::TextTableFormat,
    horizontal_lines_at_column_labels::AbstractVector{Int},
    horizontal_lines_at_data_rows::AbstractVector{Int},
    show_omitted_row_summary::Bool,
    display_number_of_rows::Int,
    new_line_at_end::Bool,
    num_printed_data_columns::Int
)
    num_data_rows = 0

    # This variable indicates if we must suppress the horizontal line before the
    # continuation row if it exists.
    suppress_hline_before_continuation_row = false

    # Compute the number of required lines to print the table.
    total_table_lines, num_lines_before_data, num_lines_after_data =
        _text__number_of_required_lines(
            table_data,
            tf,
            horizontal_lines_at_column_labels,
            horizontal_lines_at_data_rows,
            new_line_at_end
        )

    # We need one additional line to show the omitted row summary, if required, since we
    # must crop the table here.
    num_lines_after_data += show_omitted_row_summary

    required_lines_for_row_group_label =
        1 +
        tf.horizontal_line_before_row_group_label +
        tf.horizontal_line_after_row_group_label

    # In bottom mode, the continuation line will be at the end.
    available_lines =
        display_number_of_rows -
        num_lines_before_data -
        num_lines_after_data -
        1 # ............................................................... Continuation row

    num_printed_lines = 0
    last_row_cropped  = false

    # We need this verification if we are not printing one entire column to avoid problems
    # in the algorithm.
    num_printed_data_columns = max(num_printed_data_columns, 1)

    @views for i in 1:min(size(table_str, 1), table_data.num_rows)
        hline               = i ∈ horizontal_lines_at_data_rows
        row_group_label     = _print_row_group_label(table_data, i)
        num_remaining_lines = available_lines - num_printed_lines

        # Compute the number of lines in this row.
        num_lines = maximum(count.(==('\n'), table_str[i, 1:num_printed_data_columns])) + 1

        # Compute the number of lines required for the current row.
        Δ = num_lines + hline + (row_group_label ? required_lines_for_row_group_label : 0)

        # If the next line is a row group label and we must draw the horizontal line
        # here, we will need to remove this horizontal line.
        if _print_row_group_label(table_data, i + 1) &&
            tf.horizontal_line_before_row_group_label &&
            hline
            Δ -= 1
        end

        # Check if we have enough vertical space to display the line. If not, try to
        # remove horizontal line before the continuation line to make it fit.
        if num_remaining_lines == Δ
            num_data_rows += 1
            break

        elseif num_remaining_lines < Δ
            if hline && (Δ - num_remaining_lines == 1)
                suppress_hline_before_continuation_row = true
                num_data_rows += 1
                break
            end

            last_row_cropped = true
            break
        end

        # If we reach this point, we can print the data row.
        num_data_rows     += 1
        num_printed_lines += Δ
    end

    return num_data_rows, last_row_cropped, suppress_hline_before_continuation_row
end

# == Table Dimensions ======================================================================

"""
    _text__table_width_wo_cont_column(table_data::TableData, tf::TextTableFormat, vertical_lines_at_data_columns::AbstractVector{Int}, row_number_column_width::Int, row_label_column_width::Int, printed_data_column_widths::Vector{Int}) -> Int

Compute the width of the table without the continuation column.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `vertical_lines_at_data_columns::AbstractVector{Int}`: List of columns where a vertical
    line must be drawn after the cell.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
"""
function _text__table_width_wo_cont_column(
    table_data::TableData,
    tf::TextTableFormat,
    vertical_lines_at_data_columns::AbstractVector{Int},
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int}
)
    current_column  = 0
    current_column +=
    tf.vertical_line_at_beginning +
    (
        if table_data.show_row_number_column
            row_number_column_width + tf.vertical_line_after_row_number_column + 2
        else
            0
        end
    ) +
    (
        if _has_row_labels(table_data)
            row_label_column_width + tf.vertical_line_after_row_label_column + 2
        else
            0
        end
    )

    for j in eachindex(printed_data_column_widths)
        current_column += 2 + printed_data_column_widths[j]

        # We should not add the last printed column vertical line because it is taken into
        # account afterwards.
        if (j != last(eachindex(printed_data_column_widths))) &&
            (j ∈ vertical_lines_at_data_columns)
            current_column += 1
        end
    end

    current_column += tf.vertical_line_after_data_columns

    return current_column
end
