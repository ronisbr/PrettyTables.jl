## Description #############################################################################
#
# Private functions for the text back end.
#
############################################################################################

# == Footnotes =============================================================================

const _TEXT__EXPONENTS = ("⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹")

"""
    _text__footnote_marks(table_data::TableData, section::Symbol, i::Int, j::Int) -> String

Return the superscripts of the footnotes in the cell `(i, j)` of the table `section`, joined
with `ʼ`, or an empty string if the cell has no footnotes.
"""
function _text__footnote_marks(table_data::TableData, section::Symbol, i::Int, j::Int)
    return _current_cell_footnote_marks(
        _text__render_footnote_superscript, table_data, section, i, j, "ʼ"
    )
end

"""
    _text__render_footnote_superscript(number::Int) -> String

Render the superscript of a footnote.
"""
function _text__render_footnote_superscript(number::Int)
    # NOTE: `divrem` keeps the arithmetic in `Int`. The previous `floor(aux / 10)` promoted
    # `aux` to `Float64`, which made both `aux` and the digit a `Union{Int, Float64}` and
    # indexed the tuple with a float.
    aux = abs(number)
    str = ""

    while aux ≥ 1
        aux, r = divrem(aux, 10)
        str = _TEXT__EXPONENTS[r + 1] * str
    end

    # The minus sign must not be silently dropped.
    number < 0 && (str = "⁻" * str)

    return str
end

# == Horizontal Cropping ===================================================================

"""
    _text__is_printing_horizontally_limited(
        table_data::TableData,
        fit_table_in_display_horizontally::Bool,
        display_width::Int,
        num_printed_data_columns::Int,
        table_width_wo_cont_col::Int
    ) -> Bool

Return `true` if the table printing is horizontally limited by the display, meaning that it
will be cropped.

The table is limited by the display if its width without the continuation column,
`table_width_wo_cont_col`, exceeds the `display_width`, or if it fills the display but some
data columns are not printed, meaning that the continuation column does not fit.

# Arguments

- `table_data::TableData`: Table data.
- `fit_table_in_display_horizontally::Bool`: If `true`, the table must fit in the display
    horizontally.
- `display_width::Int`: Display width.
- `num_printed_data_columns::Int`: Number of printed data columns.
- `table_width_wo_cont_col::Int`: Width of the table without the continuation column.
"""
function _text__is_printing_horizontally_limited(
    table_data::TableData,
    fit_table_in_display_horizontally::Bool,
    display_width::Int,
    num_printed_data_columns::Int,
    table_width_wo_cont_col::Int,
)
    (fit_table_in_display_horizontally && (display_width > 0)) || return false

    num_remaining_columns = display_width - table_width_wo_cont_col

    return (num_remaining_columns < 0) || (
        (num_remaining_columns == 0) &&
        (num_printed_data_columns != table_data.num_columns)
    )
end

"""
    _text__number_of_printed_data_columns(
        display_width::Int,
        table_data::TableData,
        tf::TextTableFormat,
        vertical_lines_at_data_columns::_LineIndices,
        row_number_column_width::Int,
        row_label_column_width::Int,
        printed_data_column_widths::Vector{Int}
    ) -> Int

Compute the number of printed data columns.

# Arguments

- `display_width::Int`: Display width.
- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `vertical_lines_at_data_columns::_LineIndices`: List of columns where a vertical
    line must be drawn after the cell.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
"""
function _text__number_of_printed_data_columns(
    display_width::Int,
    table_data::TableData,
    tf::TextTableFormat,
    vertical_lines_at_data_columns::_LineIndices,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
)
    display_width <= 0 && return table_data.num_columns

    current_column = _text__width_before_data_columns(
        table_data, tf, row_number_column_width, row_label_column_width
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

# NOTE: The functions below must count exactly the lines drawn by the printing loop in
# `_text__print_table_core`. Each line is counted only once, by the element that owns it:
#
#   - The line after the column labels is owned by the column labels, even if the first data
#     row has a row group label, in which case it is drawn as the line before the label.
#   - The horizontal line after a data row is owned by that row, unless the next data row
#     has a row group label. In this case, the line is drawn as the line before the label, if
#     the label is printed, and it is owned by the label.
#   - The line after the last data row is owned by the section after the data rows.
#   - In the middle cropping, each row printed after the continuation row owns the line
#     above it instead of the line after it.

"""
    _text__count_horizontal_lines(horizontal_lines::_LineIndices, last_row::Int) -> Int

Return how many of the rows in `1:last_row` have a horizontal line drawn after them
according to `horizontal_lines`. Notice that a row is counted only once, even if it appears
more than once in the indices.

This function must be `O(number of indices)`, never `O(last_row)`, because `last_row` can
be the number of rows of a very large table that is only shown cropped.
"""
function _text__count_horizontal_lines(horizontal_lines::_LineIndices, last_row::Int)
    (last_row < 1) && return 0
    horizontal_lines.all && return min(horizontal_lines.n, last_row)
    return count(i -> 1 <= i <= last_row, unique(horizontal_lines.indices))
end

"""
    _text__row_group_label_lines(
        table_data::TableData,
        tf::TextTableFormat,
        horizontal_lines_at_data_rows::_LineIndices,
        i::Int
    ) -> Int

Return the number of lines owned by the row group label before the data row `i`, including
the label itself and the lines around it, or 0 if this row has no row group label.
"""
function _text__row_group_label_lines(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_data_rows::_LineIndices,
    i::Int,
)
    _print_row_group_label(table_data, i) || return 0

    line_before = if i == 1
        # At the first data row, the line before the label is the line after the column
        # labels, which is owned by the column labels if the user wants it. If the column
        # labels are hidden, there is no line before the label.
        table_data.show_column_labels &&
            tf.horizontal_line_before_row_group_label &&
            !tf.horizontal_line_after_column_labels
    else
        # The horizontal line after the previous data row is drawn as the line before the
        # label.
        tf.horizontal_line_before_row_group_label ||
            ((i - 1) ∈ horizontal_lines_at_data_rows)
    end

    return 1 + line_before + tf.horizontal_line_after_row_group_label
end

"""
    _text__data_row_lines(
        table_data::TableData,
        tf::TextTableFormat,
        horizontal_lines_at_data_rows::_LineIndices,
        i::Int,
        num_lines::Int
    ) -> Tuple{Int, Bool}

Return the number of lines owned by the data row `i`, which has `num_lines` lines, when it is
printed before the continuation row. It includes the row group label before the row and the
horizontal line after it. The second returned value indicates whether this horizontal line
was included, meaning that it can be suppressed before the continuation row.
"""
function _text__data_row_lines(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_data_rows::_LineIndices,
    i::Int,
    num_lines::Int,
)
    hline =
        (i < table_data.num_rows) &&
        (i ∈ horizontal_lines_at_data_rows) &&
        !_print_row_group_label(table_data, i + 1)

    group_lines = _text__row_group_label_lines(
        table_data, tf, horizontal_lines_at_data_rows, i
    )

    return num_lines + group_lines + hline, hline
end

"""
    _text__bottom_data_row_lines(
        table_data::TableData,
        tf::TextTableFormat,
        horizontal_lines_at_data_rows::_LineIndices,
        i::Int,
        num_lines::Int = 1
    ) -> Tuple{Int, Bool}

Return the number of lines owned by the data row `i`, which has `num_lines` lines, when it
is printed after the continuation row in the middle cropping. It includes the row group label before the row and
the line above it. The second returned value indicates whether the line above the row was
included and can be suppressed if the row is the first one after the continuation row.
"""
function _text__bottom_data_row_lines(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_data_rows::_LineIndices,
    i::Int,
    num_lines::Int = 1,
)
    # A row group label draws the line before it, which cannot be suppressed.
    if _print_row_group_label(table_data, i)
        group_lines = _text__row_group_label_lines(
            table_data, tf, horizontal_lines_at_data_rows, i
        )

        return num_lines + group_lines, false
    end

    hline = (i - 1) ∈ horizontal_lines_at_data_rows

    return num_lines + hline, hline
end

"""
    _text__number_of_required_lines(
        table_data::TableData,
        tf::TextTableFormat,
        horizontal_lines_at_column_labels::_LineIndices,
        horizontal_lines_at_data_rows::_LineIndices,
        new_line_at_end::Bool
    ) -> NTuple{3, Int}

Compute the total number of lines required to print the table, assuming that each data row
has one line.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_column_labels::_LineIndices`: Horizontal lines at column
    labels.
- `horizontal_lines_at_data_rows::_LineIndices`: Horizontal lines at data rows.
- `new_line_at_end::Bool`: If `true`, we must add a new line at the end of the table.

# Returns

- `Int`: Total number of lines required to print the table.
- `Int`: Number of lines required before printing the data.
- `Int`: Number of lines required after printing the data.
"""
function _text__number_of_required_lines(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_column_labels::_LineIndices,
    horizontal_lines_at_data_rows::_LineIndices,
    new_line_at_end::Bool,
)
    # Compute the number of lines we must have before printing the data.
    num_lines_before_data =
        !isempty(table_data.title) +
        !isempty(table_data.subtitle) +
        tf.horizontal_line_at_beginning

    if table_data.show_column_labels
        num_column_label_rows = length(table_data.column_labels)

        num_lines_before_data +=
            num_column_label_rows +
            _text__count_horizontal_lines(
                horizontal_lines_at_column_labels, num_column_label_rows - 1
            ) +
            tf.horizontal_line_after_column_labels

        # The lines at the merged column labels are only drawn after the rows without a
        # horizontal line.
        if tf.horizontal_line_at_merged_column_labels
            for i in 1:(num_column_label_rows - 1)
                (i ∉ horizontal_lines_at_column_labels) &&
                    _has_merged_cells(table_data, i) &&
                    (num_lines_before_data += 1)
            end
        end
    end

    # Compute the number of lines we must have after printing the data.
    num_lines_after_data =
        tf.horizontal_line_after_data_rows +
        (
            if _has_summary_rows(table_data)
                # The horizontal line after data rows is already counted.
                (
                    !tf.horizontal_line_after_data_rows &&
                    tf.horizontal_line_before_summary_rows
                ) +
                length(table_data.summary_rows) +
                tf.horizontal_line_after_summary_rows
            else
                0
            end
        ) +
        (_has_footnotes(table_data) ? length(table_data.footnotes) : 0) +
        !isempty(table_data.source_notes) +
        new_line_at_end +
        1 # ............................................................... Margin at bottom

    # Count how many non-data lines we must print in data row section. This number includes
    # the horizontal lines and the row group labels.
    #
    # NOTE: This computation must never iterate over the rows of the source table. Otherwise,
    # printing a cropped view of a table with millions of rows would be `O(num_rows)` even
    # though only a screenful is ever shown.
    num_rows = table_data.num_rows

    # The horizontal line after the last data row is not counted here.
    num_non_data_lines =
        _text__count_horizontal_lines(horizontal_lines_at_data_rows, num_rows - 1)

    if _has_row_group_labels(table_data)
        row_group_labels = table_data.row_group_labels

        for (k, rg) in enumerate(row_group_labels)
            i = first(rg)

            (1 <= i <= num_rows) || continue

            # If two groups start at the same row, only one label is printed. Hence, we must
            # count that row only once.
            any(m -> first(row_group_labels[m]) == i, 1:(k - 1)) && continue

            num_non_data_lines += _text__row_group_label_lines(
                table_data, tf, horizontal_lines_at_data_rows, i
            )

            # The horizontal line after the previous data row is owned by the label, but it
            # was counted above.
            ((i > 1) && ((i - 1) ∈ horizontal_lines_at_data_rows)) &&
                (num_non_data_lines -= 1)
        end
    end

    # Obtain the total number of lines required to print the table.
    total_table_lines =
        num_lines_before_data +
        table_data.num_rows +
        num_non_data_lines +
        num_lines_after_data

    return (total_table_lines, num_lines_before_data, num_lines_after_data)
end

"""
    _text__design_vertical_cropping(
        table_data::TableData,
        tf::TextTableFormat,
        horizontal_lines_at_column_labels::_LineIndices,
        horizontal_lines_at_data_rows::_LineIndices,
        show_omitted_row_summary::Bool,
        display_number_of_rows::Int,
        new_line_at_end::Bool = true,
        omitted_columns::Bool = false
    ) -> Int, Bool, Bool

Design the vertical cropping of the table by computing how many data lines we can print and
if we must suppress the horizontal line before or after the continuation line.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_column_labels::_LineIndices`: Horizontal lines at column
    labels.
- `horizontal_lines_at_data_rows::_LineIndices`: Horizontal lines at data rows.
- `show_omitted_row_summary::Bool`: If `true`, we must show the omitted row summary.
- `display_number_of_rows::Int`: Number of rows in the display.
- `new_line_at_end::Bool`: If `true`, we must add a new line at the end of the table.
- `omitted_columns::Bool`: If `true`, some data columns are omitted. Hence, the omitted
    cell summary is printed even if the table is not cropped vertically.

# Returns

- `Int`: Number of data rows we can print.
- `Bool`: If `true`, we must suppress the horizontal line before the continuation line.
- `Bool`: If `true`, we must suppress the horizontal line after the continuation line.
"""
function _text__design_vertical_cropping(
    table_data::TableData,
    tf::TextTableFormat,
    horizontal_lines_at_column_labels::_LineIndices,
    horizontal_lines_at_data_rows::_LineIndices,
    show_omitted_row_summary::Bool,
    display_number_of_rows::Int,
    new_line_at_end::Bool,
    omitted_columns::Bool = false,
)
    num_rows      = table_data.num_rows
    num_data_rows = 0

    # This variable indicates if we must suppress the horizontal line before the
    # continuation row if it exists.
    suppress_hline_before_continuation_row = false

    # This variable indicates if we must suppress the horizontal line after the
    # continuation row if it exists.
    suppress_hline_after_continuation_row = false

    # Compute the number of required lines to print the table.
    total_table_lines, num_lines_before_data, num_lines_after_data = _text__number_of_required_lines(
        table_data,
        tf,
        horizontal_lines_at_column_labels,
        horizontal_lines_at_data_rows,
        new_line_at_end,
    )

    # The user can limit the number of printed rows, in which case the table is cropped
    # even if it fits in the display.
    mr_user  = table_data.maximum_number_of_rows
    max_rows = (0 <= mr_user < num_rows) ? mr_user : num_rows

    # Check if we can draw the entire table, meaning that a continuation line is not
    # necessary. Notice that the omitted cell summary is printed if data columns are
    # omitted.
    total_table_lines += show_omitted_row_summary && omitted_columns

    (max_rows == num_rows) && (total_table_lines <= display_number_of_rows) &&
        return num_rows, false, false

    # We need one additional line to show the omitted row summary, if required, and one line
    # for the continuation row, since we must crop the table here.
    available_lines =
        display_number_of_rows -
        num_lines_before_data -
        num_lines_after_data -
        show_omitted_row_summary -
        1

    num_printed_lines = 0

    # In the bottom cropping, we only add the rows from the beginning of the table. In the
    # middle cropping, we alternately add one row from the beginning and one row from the
    # end of the table until we reach the number of available lines. Notice that sometimes
    # we might have a blank space because we have non-data lines to print that consume
    # display lines, such as row group labels and horizontal lines.
    num_iterations = table_data.vertical_crop_mode == :bottom ? num_rows : div(num_rows, 2)

    for row in 1:num_iterations
        num_data_rows >= max_rows && break

        # == Row at the Beginning of the Table =============================================

        Δ, hline = _text__data_row_lines(
            table_data, tf, horizontal_lines_at_data_rows, row, 1
        )

        num_remaining_lines = available_lines - num_printed_lines

        # Check if we have enough vertical space to display the row. If not, try to remove
        # the horizontal line before the continuation line to make it fit.
        if num_remaining_lines < Δ
            if hline && (Δ - num_remaining_lines == 1)
                suppress_hline_before_continuation_row = true
                num_data_rows += 1
            end

            break
        end

        num_data_rows     += 1
        num_printed_lines += Δ

        (table_data.vertical_crop_mode == :bottom) && continue
        (num_data_rows >= max_rows) && break

        # == Row at the End of the Table ===================================================

        Δ, hline = _text__bottom_data_row_lines(
            table_data, tf, horizontal_lines_at_data_rows, num_rows - row + 1
        )

        num_remaining_lines = available_lines - num_printed_lines

        # Check if we have enough vertical space to display the row. If not, try to remove
        # the horizontal line after the continuation line to make it fit.
        if num_remaining_lines < Δ
            if hline && (Δ - num_remaining_lines == 1)
                suppress_hline_after_continuation_row = true
                num_data_rows += 1
            end

            break
        end

        num_data_rows     += 1
        num_printed_lines += Δ
    end

    return (
        num_data_rows,
        suppress_hline_before_continuation_row,
        suppress_hline_after_continuation_row,
    )
end

"""
    _text__row_lines(table_str::AbstractMatrix{String}, i::Int, last_column::Int) -> Int

Return the number of lines of the rendered row `i` in `table_str` considering the columns
up to `last_column`.
"""
function _text__row_lines(table_str::AbstractMatrix{String}, i::Int, last_column::Int)
    n = 0

    for j in 1:last_column
        n = max(n, count(==('\n'), table_str[i, j]))
    end

    return n + 1
end

"""
    _text__middle_cropped_table_lines(
        table_data::TableData,
        table_str::Matrix{String},
        tf::TextTableFormat,
        horizontal_lines_at_column_labels::_LineIndices,
        horizontal_lines_at_data_rows::_LineIndices,
        show_omitted_row_summary::Bool,
        new_line_at_end::Bool,
        last_printed_column_index::Int
    ) -> Int

Return the number of lines required to print the table cropped in the middle by the user
when it has line breaks. `table_str` must contain the rendered rows, which are the ones at
the beginning and at the end of the table, and the columns up to
`last_printed_column_index` are considered to compute the row heights.
"""
function _text__middle_cropped_table_lines(
    table_data::TableData,
    table_str::Matrix{String},
    tf::TextTableFormat,
    horizontal_lines_at_column_labels::_LineIndices,
    horizontal_lines_at_data_rows::_LineIndices,
    show_omitted_row_summary::Bool,
    new_line_at_end::Bool,
    last_printed_column_index::Int,
)
    _, num_lines_before_data, num_lines_after_data = _text__number_of_required_lines(
        table_data,
        tf,
        horizontal_lines_at_column_labels,
        horizontal_lines_at_data_rows,
        new_line_at_end,
    )

    num_rendered_rows = size(table_str, 1)
    num_top_rows      = div(num_rendered_rows, 2, RoundUp)
    last_column       = clamp(last_printed_column_index, 0, size(table_str, 2))

    # The continuation row and the omitted cell summary are always printed.
    num_lines =
        num_lines_before_data + num_lines_after_data + show_omitted_row_summary + 1

    for r in 1:num_rendered_rows
        row_lines = _text__row_lines(table_str, r, last_column)

        num_lines += if r <= num_top_rows
            first(_text__data_row_lines(
                table_data, tf, horizontal_lines_at_data_rows, r, row_lines
            ))
        else
            i = table_data.num_rows - num_rendered_rows + r

            first(_text__bottom_data_row_lines(
                table_data, tf, horizontal_lines_at_data_rows, i, row_lines
            ))
        end
    end

    return num_lines
end

"""
    _text__design_vertical_cropping_with_line_breaks(
        table_data::TableData,
        table_str::AbstractMatrix{String},
        tf::TextTableFormat,
        horizontal_lines_at_column_labels::_LineIndices,
        horizontal_lines_at_data_rows::_LineIndices,
        show_omitted_row_summary::Bool,
        display_number_of_rows::Int,
        new_line_at_end::Bool,
        last_printed_column_index::Int,
        omitted_columns::Bool = false
    ) -> Tuple{Int, Bool, Bool}

Design the vertical cropping of the table when the user wants line breaks by computing how
many data lines we can print and if we must suppress the horizontal line before the
continuation line. Notice that middle vertical cropping is not supported when we have line
breaks.

# Arguments

- `table_data::TableData`: Table data.
- `table_str::AbstractMatrix{String}`: Rendered table cells, whose rows must be the data
    rows at the beginning of the table.
- `tf::TextTableFormat`: Table format.
- `horizontal_lines_at_column_labels::_LineIndices`: Horizontal lines at column
    labels.
- `horizontal_lines_at_data_rows::_LineIndices`: Horizontal lines at data rows.
- `show_omitted_row_summary::Bool`: If `true`, we must show the omitted row summary.
- `display_number_of_rows::Int`: Number of rows in the display.
- `new_line_at_end::Bool`: If `true`, we must add a new line at the end of the table.
- `last_printed_column_index::Int`: Index of the last printed data column, including the
    one that is partially printed, since all of them contribute to the row heights.
- `omitted_columns::Bool`: If `true`, some data columns are omitted. Hence, the omitted
    cell summary is printed even if the table is not cropped vertically.

# Returns

- `Int`: Number of data rows we can fully print.
- `Bool`: If `true`, the printing process will crop the last row.
- `Bool`: If `true`, we must suppress the horizontal line before the continuation line.
"""
function _text__design_vertical_cropping_with_line_breaks(
    table_data::TableData,
    table_str::AbstractMatrix{String},
    tf::TextTableFormat,
    horizontal_lines_at_column_labels::_LineIndices,
    horizontal_lines_at_data_rows::_LineIndices,
    show_omitted_row_summary::Bool,
    display_number_of_rows::Int,
    new_line_at_end::Bool,
    last_printed_column_index::Int,
    omitted_columns::Bool = false,
)
    num_rows      = table_data.num_rows
    num_data_rows = 0

    # If the table has no columns, no data row can be cropped.
    size(table_str, 2) == 0 && return num_rows, false, false

    # This variable indicates if we must suppress the horizontal line before the
    # continuation row if it exists.
    suppress_hline_before_continuation_row = false

    # Compute the number of required lines to print the table assuming one line per row.
    total_table_lines, num_lines_before_data, num_lines_after_data = _text__number_of_required_lines(
        table_data,
        tf,
        horizontal_lines_at_column_labels,
        horizontal_lines_at_data_rows,
        new_line_at_end,
    )

    # Notice that the upper clamp is required because the table can have more columns than
    # the rendered ones.
    last_column = clamp(last_printed_column_index, 1, size(table_str, 2))

    num_rendered_rows = min(size(table_str, 1), num_rows)

    # If all the rows were rendered, we must check if we can draw the entire table, meaning
    # that a continuation line is not necessary. In this case, we replace the one line per
    # row in the total number of lines by the actual number of lines. Notice that the
    # omitted cell summary is printed if data columns are omitted.
    if num_rendered_rows == num_rows
        total_table_lines += show_omitted_row_summary && omitted_columns

        for i in 1:num_rows
            total_table_lines += _text__row_lines(table_str, i, last_column) - 1
        end

        (total_table_lines <= display_number_of_rows) && return num_rows, false, false
    end

    # We need one additional line to show the omitted row summary, if required, and one line
    # for the continuation row, since we must crop the table here.
    available_lines =
        display_number_of_rows -
        num_lines_before_data -
        num_lines_after_data -
        show_omitted_row_summary -
        1

    num_printed_lines = 0
    last_row_cropped  = false

    for i in 1:num_rendered_rows
        row_lines = _text__row_lines(table_str, i, last_column)
        Δ, hline  = _text__data_row_lines(
            table_data, tf, horizontal_lines_at_data_rows, i, row_lines
        )

        num_remaining_lines = available_lines - num_printed_lines

        # Check if we have enough vertical space to display the row. If not, try to remove
        # the horizontal line before the continuation line to make it fit. Otherwise, the
        # row is printed partially if at least one of its lines fits after the row group
        # label before it. Otherwise, the label would be printed without data.
        if num_remaining_lines == Δ
            num_data_rows += 1
            break

        elseif num_remaining_lines < Δ
            if hline && (Δ - num_remaining_lines == 1)
                suppress_hline_before_continuation_row = true
                num_data_rows += 1
                break
            end

            last_row_cropped =
                num_remaining_lines > _text__row_group_label_lines(
                    table_data, tf, horizontal_lines_at_data_rows, i
                )

            break
        end

        num_data_rows     += 1
        num_printed_lines += Δ
    end

    return num_data_rows, last_row_cropped, suppress_hline_before_continuation_row
end

# == Alignment Regex =======================================================================

"""
    _text__align_column_with_regex!(
        table_str::Matrix{String},
        summary_rows::Union{Nothing, Matrix{String}},
        column_str::Vector{String},
        j::Int,
        regex::Vector{Regex},
        fallback::Symbol,
        apply_to_summary_rows::Bool,
        maximum_width::Int,
        line_breaks::Bool
    ) -> Nothing

Align the rendered cells of the data column `j` in `table_str`, and in `summary_rows` if
`apply_to_summary_rows` is `true`, using the alignment anchor `regex` and the `fallback`
alignment. `column_str` is a buffer with one element for each aligned cell. Since the
alignment changes the cell widths, the cells are cropped again to the `maximum_width` of the
column.
"""
function _text__align_column_with_regex!(
    table_str::Matrix{String},
    summary_rows::Union{Nothing, Matrix{String}},
    column_str::Vector{String},
    j::Int,
    regex::Vector{Regex},
    fallback::Symbol,
    apply_to_summary_rows::Bool,
    maximum_width::Int,
    line_breaks::Bool,
)
    num_rows = size(table_str, 1)

    @views column_str[1:num_rows] .= table_str[:, j]

    if apply_to_summary_rows
        @views column_str[(num_rows + 1):end] .= summary_rows[:, j]
    end

    if !line_breaks
        _align_column_with_regex!(column_str, regex, fallback)
    else
        _align_multline_column_with_regex!(column_str, regex, fallback)
    end

    for (k, str) in enumerate(column_str)
        cropped_str = _text__fit_cell_in_maximum_cell_width(str, maximum_width, line_breaks)

        if k <= num_rows
            table_str[k, j] = cropped_str
        else
            summary_rows[k - num_rows, j] = cropped_str
        end
    end

    return nothing
end

# == Table Dimensions ======================================================================

"""
    _text__width_before_data_columns(
        table_data::TableData,
        tf::TextTableFormat,
        row_number_column_width::Int,
        row_label_column_width::Int
    ) -> Int

Return the width of the table before the first data column, which contains the vertical line
at the beginning of the table, the row number column, and the row label column, including
their margins and vertical lines.
"""
function _text__width_before_data_columns(
    table_data::TableData,
    tf::TextTableFormat,
    row_number_column_width::Int,
    row_label_column_width::Int,
)
    w = Int(tf.vertical_line_at_beginning)

    if table_data.show_row_number_column
        w += row_number_column_width + tf.vertical_line_after_row_number_column + 2
    end

    if _has_row_labels(table_data)
        w += row_label_column_width + tf.vertical_line_after_row_label_column + 2
    end

    return w
end

"""
    _text__table_width_wo_cont_column(
        table_data::TableData,
        tf::TextTableFormat,
        vertical_lines_at_data_columns::_LineIndices,
        row_number_column_width::Int,
        row_label_column_width::Int,
        printed_data_column_widths::Vector{Int}
    ) -> Int

Compute the width of the table without the continuation column.

# Arguments

- `table_data::TableData`: Table data.
- `tf::TextTableFormat`: Table format.
- `vertical_lines_at_data_columns::_LineIndices`: List of columns where a vertical
    line must be drawn after the cell.
- `row_number_column_width::Int`: Row number column width.
- `row_label_column_width::Int`: Row label column width.
- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
"""
function _text__table_width_wo_cont_column(
    table_data::TableData,
    tf::TextTableFormat,
    vertical_lines_at_data_columns::_LineIndices,
    row_number_column_width::Int,
    row_label_column_width::Int,
    printed_data_column_widths::Vector{Int},
)
    current_column = _text__width_before_data_columns(
        table_data, tf, row_number_column_width, row_label_column_width
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
