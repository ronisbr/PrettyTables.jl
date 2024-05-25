## Description #############################################################################
#
# Fill the string matrix that will be printed in the text back end.
#
############################################################################################

# Fill the the string matrix table.
function _text_fill_string_matrix!(
    @nospecialize(io::IOContext),
    table_str::Matrix{Vector{String}},
    ptable::ProcessedTable,
    actual_columns_width::Vector{Int},
    display::Display,
    @nospecialize(formatters::Ref{Any}),
    num_lines_in_row::Vector{Int},
    # Configuration options.
    autowrap::Bool,
    cell_first_line_only::Bool,
    columns_width::Vector{Int},
    compact_printing::Bool,
    crop_subheader::Bool,
    limit_printing::Bool,
    linebreaks::Bool,
    maximum_columns_width::Vector{Int},
    minimum_columns_width::Vector{Int},
    renderer::Union{Val{:print}, Val{:show}},
    vcrop_mode::Symbol
)
    num_rows, ~ = _size(ptable)
    num_header_rows, ~ = _header_size(ptable)
    num_rendered_rows, num_rendered_columns = size(table_str)

    # This variable stores the predicted table width. If the user wants horizontal cropping,
    # it can be use to avoid unnecessary processing of columns that will not be displayed.
    pred_table_width = 0

    @inbounds for j in 1:num_rendered_columns
        # Get the identification of the current column.
        column_id = _get_column_id(ptable, j)

        # Here we store the number of processed lines. This is used to save processing if
        # the user wants to crop the output and has cells with multiple lines.
        num_processed_lines = 0

        # Get the column index in the original data. Notice that this is ignored if the
        # column is not from the original data.
        jr = _get_data_column_index(ptable, j)

        # Store the largest cell width in this column. This leads to a double computation of
        # the cell size, here and in the `_compute_table_size_data`. However, we need this
        # to stop processing columns when cropping horizontally.
        if (column_id == :__ORIGINAL_DATA__)
            largest_cell_width = minimum_columns_width[jr] ≤ 0 ?
                0 :
                minimum_columns_width[jr]
        else
            largest_cell_width = 0
        end

        for i in 1:num_rendered_rows
            # We need to force `cell_str` to `Vector{String}` to avoid type instabilities.
            local cell_str::Vector{String}

            # Get the identification of the current row.
            row_id = _get_row_id(ptable, i)

            # Get the row number given the crop mechanism. `i_ts` is the row index in the
            # `table_str` whereas `i_pt` is the row index in the `ptable`.
            i_ts, i_pt = _vcrop_row_number(
                vcrop_mode,
                num_rows,
                num_header_rows,
                num_rendered_rows,
                i
            )

            # Get the cell data.
            cell_data = _get_element(ptable, i_pt, j);

            if (row_id == :__HEADER__) || (row_id == :__SUBHEADER__)
                cell_str = _text_parse_cell(
                    io,
                    cell_data;
                    autowrap = false,
                    cell_first_line_only = false,
                    column_width = -1,
                    compact_printing = compact_printing,
                    has_color = display.has_color,
                    limit_printing = limit_printing,
                    linebreaks = false,
                    renderer = Val(:print)
                )

            elseif (column_id == :row_label)
                cell_str = _text_parse_cell(
                    io,
                    cell_data;
                    autowrap = false,
                    cell_first_line_only = false,
                    column_width = -1,
                    compact_printing = compact_printing,
                    has_color = display.has_color,
                    limit_printing = limit_printing,
                    linebreaks = false,
                    renderer = Val(:print)
                )

            elseif (column_id == :__ORIGINAL_DATA__) && (row_id == :__ORIGINAL_DATA__)
                # Get the row index in the original data.
                ir = _get_data_row_index(ptable, i_pt)

                # Check if this is a column with fixed size.
                fixed_column_width = columns_width[jr] > 0

                # Get the original type of the cell, which is used in some
                # special cases in the renderers.
                cell_data_type = typeof(cell_data)

                # Apply the formatters.

                # Notice that `(ir, jr)` are the indices of the printed data. It means that
                # it refers to the ir-th data row and jr-th data column that will be
                # printed. We need to convert those indices to the actual indices in the
                # input table.
                tir, tjr = _convert_axes(ptable.data, ir, jr)

                for f in formatters.x
                    cell_data = f(cell_data, tir, tjr)
                end

                # Render the cell.
                cell_str = _text_parse_cell(
                    io,
                    cell_data,
                    autowrap = autowrap && fixed_column_width,
                    cell_data_type = cell_data_type,
                    cell_first_line_only = cell_first_line_only,
                    column_width = columns_width[jr],
                    compact_printing = compact_printing,
                    has_color = display.has_color,
                    limit_printing = limit_printing,
                    linebreaks = linebreaks,
                    renderer = renderer
                )

            else
                cell_str = [string(cell_data)]

            end

            table_str[i_ts, j] = cell_str

            # Update the size of the largest cell in this column to draw the table.
            if cell_data isa Markdown.MD
                largest_cell_width = max(
                    largest_cell_width,
                    maximum(printable_textwidth.(cell_str))
                )
            else
                # If we are at the subheader and the user wants to crop it, just skip this
                # computation.
                if (row_id != :__SUBHEADER__) || !crop_subheader
                    largest_cell_width = max(
                        largest_cell_width,
                        maximum(textwidth.(cell_str))
                    )
                end
            end

            # Compute the number of lines so that we can avoid process unnecessary cells due
            # to cropping.
            num_lines = length(cell_str)
            num_processed_lines += num_lines
            num_lines_in_row[i_ts] = max(num_lines_in_row[i_ts], num_lines)

            # We must ensure that all header lines are processed.
            if !_is_header_row(row_id)
                # If the crop mode if `:middle`, then we need to always process a row in the
                # top and in another in the bottom before stopping due to display size. This
                # is required to avoid printing from a cell that is undefined. Notice that
                # due to the printing order in `jvec` we just need to check if `k` is even.
                if ((vcrop_mode == :bottom) || ((vcrop_mode == :middle))) &&
                    (display.size[1] > 0) &&
                    (num_processed_lines ≥ display.size[1])
                    break
                end
            end
        end

        if (column_id == :__ORIGINAL_DATA__)
            # Compute the column width given the user's configuration.
            actual_columns_width[j] = _update_column_width(
                actual_columns_width[j],
                largest_cell_width,
                columns_width[jr],
                maximum_columns_width[jr],
                minimum_columns_width[jr]
            )
        else
            actual_columns_width[j] = max(
                actual_columns_width[j],
                largest_cell_width
            )
        end

        # If the user horizontal cropping, check if we need to process another column.
        #
        # TODO: Should we take into account the dividers?
        if display.size[2] > 0
            pred_table_width += actual_columns_width[j]

            if pred_table_width > display.size[2]
                num_rendered_columns = j
                break
            end
        end
    end

    return num_rendered_rows, num_rendered_columns
end
