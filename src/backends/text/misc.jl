## Description #############################################################################
#
# Miscellaneous functions related to the Text back end.
#
############################################################################################

# Compute the table height.
function _compute_table_height(
    ptable::ProcessedTable,
    hlines::Union{Symbol, Vector{Int}},
    body_hlines::Union{Symbol, Vector{Int}},
    num_lines_in_row::Vector{Int}
)
    table_height =
        sum(num_lines_in_row) +
        _count_hlines(ptable, hlines, body_hlines)

    return table_height
end

# Compute the table width.
function _compute_table_width(
    ptable::ProcessedTable,
    vlines::Union{Symbol, Vector{Int}},
    columns_width::Vector{Int}
)
    # Sum the width of the columns.
    table_width =
        sum(columns_width) +
        2length(columns_width) +
        _count_vlines(ptable, vlines)

    return table_width
end

# Compute the position of the continuation row if the vertical crop is selected with the
# bottom crop mode.
function _compute_continuation_row_in_bottom_vcrop(
    ptable::ProcessedTable,
    display::Display,
    hlines::Union{Symbol, Vector{Int}},
    body_hlines::Vector{Int},
    num_lines_in_row::Vector{Int},
    table_height::Int,
    draw_last_hline::Bool,
    need_omitted_cell_summary::Bool,
    show_omitted_cell_summary::Bool,
    Δdisplay_lines::Int
)
    if display.size[1] > 0
        available_display_lines = display.size[1] - Δdisplay_lines

        if table_height > available_display_lines - need_omitted_cell_summary
            # Count the number of lines in the header considering that lines before and
            # after it.
            num_header_lines = _count_header_lines(
                ptable,
                hlines,
                body_hlines,
                num_lines_in_row
            )

            # In this case, we will have to save one line to print the omitted cell summary.
            continuation_row_line =
                available_display_lines - draw_last_hline - show_omitted_cell_summary

            # We must print at least the header.
            continuation_row_line = max(continuation_row_line, num_header_lines)
        else
            continuation_row_line = -1
        end
    else
        continuation_row_line = -1
    end

    return continuation_row_line
end

# Compute the position of the continuation row if the vertical crop is selected with the
# middle crop mode.
function _compute_continuation_row_in_middle_vcrop(
    ptable::ProcessedTable,
    display::Display,
    hlines::Union{Symbol, Vector{Int}},
    body_hlines::Vector{Int},
    num_lines_in_row::Vector{Int},
    table_height::Int,
    need_omitted_cell_summary::Bool,
    show_omitted_cell_summary::Bool,
    Δdisplay_lines::Int
)
    # Get size information from the processed table.
    num_rows = _size(ptable)[1]

    if display.size[1] > 0
        available_display_lines = display.size[1] - Δdisplay_lines

        if table_height > available_display_lines - need_omitted_cell_summary
            # Count the number of lines in the header considering that lines
            # before and after it.
            num_header_lines = _count_header_lines(
                ptable,
                hlines,
                body_hlines,
                num_lines_in_row
            )

            # Number of rows available to draw table data. In this case, we will have to
            # save one line to print the omitted cell summary. In this case, the horizontal
            # lines are also considered table data. However, we must remove the last line,
            # if it must be printed, because it is always printing regardeless the display
            # size.
            draw_last_hline = _check_hline(ptable, hlines, body_hlines, num_rows)

            available_rows_for_data =
                available_display_lines -
                num_header_lines -
                show_omitted_cell_summary -
                draw_last_hline

            # If there is no available rows for data, we need to print at least the header.
            if available_rows_for_data > 0
                continuation_row_line = div(
                    available_rows_for_data + 1,
                    2,
                    RoundUp
                ) + num_header_lines
            else
                # We must print at least the header.
                continuation_row_line = num_header_lines
            end
        else
            continuation_row_line = -1
        end
    else
        continuation_row_line = -1
    end

    return continuation_row_line
end

# Compute the number of omitted columns.
function _compute_omitted_columns(
    ptable::ProcessedTable,
    display::Display,
    columns_width::Vector{Int},
    vlines::Union{Symbol, Vector{Int}},
)
    ~, num_columns         = _size(ptable)
    num_additional_columns = _num_additional_columns(ptable)
    num_rendered_columns   = length(columns_width)

    @inbounds @views if display.size[2] > 0
        available_display_columns = display.size[2]

        fully_printed_columns = 0

        if _check_vline(ptable, vlines, 0)
            available_display_columns -= 1
        end

        for j = 1:num_rendered_columns
            # Take into account the column width plus the padding before the column.
            available_display_columns -= columns_width[j] + 1

            available_display_columns < 2 && break

            # We should neglect the additional columns when computing the number of fully
            # printed columns.
            if j > num_additional_columns
                fully_printed_columns += 1
            end

            # Take into account the column width plus the padding after the column.
            available_display_columns -= 1

            # Take into account a vertical line after the columns
            if _check_vline(ptable, vlines, j)
                available_display_columns -= 1
            end
        end

        num_omitted_columns =
            (num_columns - num_additional_columns) - fully_printed_columns
    else
        num_omitted_columns = 0
    end

    return num_omitted_columns
end

# Compute the number of omitted rows.
function _compute_omitted_rows(
    ptable::ProcessedTable,
    display::Display,
    continuation_row_line::Int,
    num_lines_in_row::Vector{Int},
    body_hlines::Vector{Int},
    hlines::Union{Symbol, Vector{Int}},
    need_omitted_cell_summary::Bool,
    Δdisplay_lines::Int
)
    num_rows, ~       = _size(ptable)
    num_header_rows   = _header_size(ptable)[1]
    num_rendered_rows = length(num_lines_in_row)

    @views if continuation_row_line > 0
        # If we have a continuation line, we just need to pass the table from the beginning
        # to end until we reach this line. Then we pass the table from end to the
        # continuation line. In those passes, we count the number of fully displayed rows.
        # This algorithm works for both bottom and middle cropping.

        # Number of available line.
        available_display_lines = display.size[1] - Δdisplay_lines

        # Count the number of lines in the header.
        num_header_lines = _count_header_lines(
            ptable,
            hlines,
            body_hlines,
            num_lines_in_row
        )

        # Update the number of available lines.
        available_display_lines -= num_header_lines

        fully_printed_rows = 0
        current_line = num_header_lines

        # First pass: go from the beginning of the table to the continuation line.
        for i = (num_header_rows + 1):num_rendered_rows
            current_line += num_lines_in_row[i]

            if current_line ≥ continuation_row_line
                available_display_lines -=
                    num_lines_in_row[i] - (current_line - continuation_row_line)
                break
            end

            available_display_lines -= num_lines_in_row[i]
            fully_printed_rows += 1

            if _check_hline(ptable, hlines, body_hlines, i)
                current_line += 1
                available_display_lines -= 1
            end
        end

        # Second pass: go from the end of the table to the continuationl line. Notice that
        # we know rows are cropped, hence we must reserve a line for the omitted cell
        # summary if the user wants.

        available_display_lines -= need_omitted_cell_summary

        for i = num_rendered_rows:-1:1
            Δi = num_rendered_rows - i

            if _check_hline(ptable, hlines, body_hlines, num_rows - Δi)
                available_display_lines -= 1
            end

            available_display_lines -= num_lines_in_row[i]
            available_display_lines < 0 && break

            fully_printed_rows += 1
        end

        num_omitted_rows = (num_rows - num_header_rows) - fully_printed_rows
    else
        num_omitted_rows = 0
    end

    return num_omitted_rows
end

# Count the number of lines in the header. It contains the first horizontal line and the
# line after the last subheader.
function _count_header_lines(
    ptable::ProcessedTable,
    hlines::Union{Symbol, Vector{Int}},
    body_hlines::Vector{Int},
    num_lines_in_row::Vector{Int}
)
    num_header_lines = 0

    @inbounds @views begin
        num_header_rows = _header_size(ptable)[1]

        if _check_hline(ptable, hlines, body_hlines, 0)
            num_header_lines += 1
        end

        num_header_lines += sum(num_lines_in_row[1:num_header_rows])

        if _check_hline(ptable, hlines, body_hlines, num_header_rows)
            num_header_lines += 1
        end
    end

    return num_header_lines
end

# Return the default crayon for a cell in a row with identification `row_id` and in a column
# with identification `column_id`. It is also necessary to pass the data column index `jr`
# in case the header or subheader crayons are a vector.
function _select_default_cell_crayon(
    row_id::Symbol,
    column_id::Symbol,
    text_crayons::TextCrayons,
    jr::Int
)
    if column_id == :row_number
        if row_id == :__HEADER__
            return text_crayons.row_number_header_crayon
        else
            return text_crayons.text_crayon
        end
    elseif column_id == :row_label
        if row_id == :__HEADER__
            return text_crayons.row_label_header_crayon
        else
            return text_crayons.row_label_crayon
        end
    elseif row_id == :__HEADER__
        if text_crayons.header_crayon isa Crayon
            return text_crayons.header_crayon
        else
            return text_crayons.header_crayon[jr]
        end
    elseif row_id == :__SUBHEADER__
        if text_crayons.subheader_crayon isa Crayon
            return text_crayons.subheader_crayon
        else
            return text_crayons.subheader_crayon[jr]
        end
    else
        return text_crayons.text_crayon
    end
end

# Compute the column width `column_width` considering the largest cell width in the column
# `largest_cell_width`, the user specification in `column_width_specification`, and the
# maximum and minimum allowed column width in `maximum_column_width` and
# `minimum_column_width`, respectively.
function _update_column_width(
    column_width::Int,
    largest_cell_width::Int,
    column_width_specification::Int,
    maximum_column_width::Int,
    minimum_column_width::Int
)
    if column_width_specification ≤ 0
        # The columns width must never be lower than 1.
        column_width = max(column_width, largest_cell_width)

        # Make sure that the maximum column width is respected.
        if (maximum_column_width > 0) && (maximum_column_width < column_width)
            column_width = maximum_column_width
        end

        # Make sure that the minimum column width is respected.
        if (minimum_column_width > 0) && (minimum_column_width > column_width)
            column_width = minimum_column_width
        end
    else
        column_width = column_width_specification
    end

    return column_width
end

# Return the indices in the `table_str` and `ptable` related to the `i`th processed row.
function _vcrop_row_number(
    vcrop_mode::Symbol,
    num_rows::Int,
    num_header_rows::Int,
    num_printed_rows::Int,
    i::Int
)
    if (vcrop_mode != :middle)
        return i, i
    else
        if i ≤ num_header_rows
            return i, i
        else
            i = i - num_header_rows

            if i % 2 == 1
                i_ts = div(i, 2, RoundDown) + num_header_rows + 1
                i_pt = i_ts
                return i_ts, i_pt
            else
                Δi = div(i, 2) - 1
                i_ts = num_printed_rows - Δi
                i_pt = num_rows - Δi
                return i_ts, i_pt
            end
        end
    end
end
