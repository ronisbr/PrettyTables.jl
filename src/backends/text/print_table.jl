## Description #############################################################################
#
# Auxiliary functions to print the table.
#
############################################################################################

# Print the entire table data.
function _text_print_table!(
    display::Display,
    ptable::ProcessedTable,
    table_str::Matrix{Vector{String}},
    actual_columns_width::Vector{Int},
    continuation_row_line::Int,
    num_lines_in_row::Vector{Int},
    num_lines_around_table::Int,
    # Configurations.
    body_hlines::Vector{Int},
    body_hlines_format::NTuple{4, Char},
    continuation_row_alignment::Symbol,
    ellipsis_line_skip::Integer,
    @nospecialize(highlighters::Ref{Any}),
    hlines::Union{Symbol, AbstractVector},
    tf::TextFormat,
    text_crayons::TextCrayons,
    vlines::Union{Symbol, AbstractVector}
)
    # Get size information from the processed table.
    num_rows = _size(ptable)[1]
    num_rendered_rows, num_rendered_columns = size(table_str)

    # Check if the last horizontal line must be drawn, which must happen **after** the
    # continuation line in `vcrop_mode = :bottom`.
    draw_last_hline = _check_hline(ptable, hlines, body_hlines, num_rows)

    # This variable is used to decide whether to print the continuation
    # characters.
    line_count = 0

    # Initialize the row printing state machine.
    rps = RowPrintingState()

    while rps.state ≠ :finish

        # == Row Printing State Machine ====================================================

        action = _iterate_row_printing_state!(
            rps,
            ptable,
            display,
            num_lines_in_row,
            num_rendered_rows,
            hlines,
            body_hlines,
            draw_last_hline,
            num_lines_around_table,
            continuation_row_line
        )

        # == Render the Top Line ===========================================================

        if action == :top_horizontal_line
            _draw_line!(
                display,
                ptable,
                tf.up_left_corner,
                tf.up_intersection,
                tf.up_right_corner,
                tf.row,
                text_crayons.border_crayon,
                actual_columns_width,
                vlines
            )

        # == Render the Middle Line ========================================================

        elseif action == :middle_horizontal_line
            # If the row is from the header, we must draw the line from the table format.
            # Otherwise, we must use the user configuration in `body_hlines_format`.
            if _is_header_row(ptable, rps.i)
                _draw_line!(
                    display,
                    ptable,
                    tf.left_intersection,
                    tf.middle_intersection,
                    tf.right_intersection,
                    tf.row,
                    text_crayons.border_crayon,
                    actual_columns_width,
                    vlines
                )
            else
                _draw_line!(
                    display,
                    ptable,
                    body_hlines_format...,
                    text_crayons.border_crayon,
                    actual_columns_width,
                    vlines
                )
            end

        # == Render the Bottom Line ========================================================

        elseif action == :bottom_horizontal_line
            _draw_line!(
                display,
                ptable,
                tf.bottom_left_corner,
                tf.bottom_intersection,
                tf.bottom_right_corner,
                tf.row,
                text_crayons.border_crayon,
                actual_columns_width,
                vlines
            )

        # == Render the Continuation Line ==================================================

        elseif action == :continuation_line
            _draw_continuation_line(
                display,
                ptable,
                tf,
                text_crayons.text_crayon,
                text_crayons.border_crayon,
                actual_columns_width,
                vlines,
                continuation_row_alignment
            )

        # == Render a Table Line ===========================================================

        elseif (action == :table_line) || (action == :table_line_row_finished)
            i = rps.i
            l = rps.l
            row_id = _get_row_id(ptable, i)

            ir = (row_id == :__ORIGINAL_DATA__) ?
                _get_data_row_index(ptable, rps.i_pt) :
                0

            # Select the continuation character for this line.
            if (ellipsis_line_skip ≤ 0) || _is_header_row(row_id)
                display.cont_char = '⋯'
            else
                display.cont_char = line_count % (ellipsis_line_skip + 1) == 0 ?
                    '⋯' :
                    ' '
                line_count += 1
            end

            # Check if we need to print a vertical line at the beginning of the line.
            if _check_vline(ptable, vlines, 0)
                _p!(display, text_crayons.border_crayon, tf.column, false, 1)
            end

            # -- Render the Cells in Each Column -------------------------------------------

            for j in 1:num_rendered_columns
                has_vline = _check_vline(ptable, vlines, j)
                final_line_print = j == num_rendered_columns && !has_vline

                # If this cell has less than `l` lines, then we just need to align it.
                if length(table_str[i, j]) < l
                    # Align the text in the column.
                    cell_processed_str = " "^actual_columns_width[j]

                    # Print the cell with the spacing.
                    _p!(
                        display,
                        _default_crayon,
                        " " * cell_processed_str * " ",
                        false,
                        actual_columns_width[j] + 2
                    ) && break

                else
                    column_id = _get_column_id(ptable, j)

                    jr = (column_id == :__ORIGINAL_DATA__) ?
                        _get_data_column_index(ptable, j) :
                        0

                    # Get the correct crayon for this cell.
                    cell_crayon = _select_default_cell_crayon(
                        row_id,
                        column_id,
                        text_crayons,
                        jr
                    )

                    # Get the alignment for this cell.
                    cell_alignment = _get_cell_alignment(ptable, rps.i_pt, j)

                    # Select the rendering algorithm based on the type of the
                    # cell.
                    if _is_header_row(row_id) || (column_id != :__ORIGINAL_DATA__)
                        table_str_ij_l = table_str[i, j][l]
                        actual_columns_width_j = actual_columns_width[j]

                        # Get the string printable width. Notice that, in this case, we know
                        # that we do not have any invisible characters inside the string.
                        str_printable_width = textwidth(table_str_ij_l)

                        # Align the text in the column.
                        cell_processed_str = align_string(
                            table_str_ij_l,
                            actual_columns_width_j,
                            cell_alignment;
                            fill = true,
                            printable_string_width = str_printable_width
                        )

                        # Crop the string the make sure it fits the cell. Notice that we
                        # ensure that there is not ANSI escape sequences inside this string.
                        cell_processed_str = fit_string_in_field(
                            cell_processed_str,
                            actual_columns_width_j;
                            keep_ansi = false,
                            printable_string_width = str_printable_width
                        )

                        # Print the cell with the spacing.
                        _p!(
                            display,
                            cell_crayon,
                            " " * cell_processed_str * " ",
                            false,
                            actual_columns_width[j] + 2
                        ) && break

                    else
                        # In this case, we need to process the cell to apply the correct
                        # alignment and highlighters before rendering it.
                        cell_data = _get_element(ptable, rps.i_pt, j)

                        cell_processed_str, cell_crayon = _text_process_data_cell(
                            ptable,
                            cell_data,
                            table_str[i, j][l],
                            ir,
                            jr,
                            l,
                            actual_columns_width[j],
                            text_crayons.text_crayon,
                            cell_alignment,
                            highlighters
                        )

                        if !(cell_data isa CustomTextCell)
                            _p!(
                                display,
                                cell_crayon,
                                " " * cell_processed_str * " ",
                                false,
                                actual_columns_width[j] + 2
                            ) && break
                        else
                            # If we have a custom cell, we need a custom printing function.
                            _print_custom_text_cell!(
                                display,
                                cell_data,
                                cell_processed_str,
                                cell_crayon,
                                l,
                                highlighters
                            ) && break
                        end
                    end
                end

                # Check if we need to print a vertical line after the column.
                if has_vline
                    final_line_print = j == num_rendered_columns
                    _p!(
                        display,
                        text_crayons.border_crayon,
                        tf.column,
                        final_line_print,
                        1
                    )
                end
            end

            _nl!(display)

        # == End State =====================================================================

        elseif action == :finish
            break
        end
    end

    return nothing
end
