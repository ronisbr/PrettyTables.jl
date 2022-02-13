# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Auxiliary functions to print the table.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Print the entire table data.
function _print_table_data!(
    display::Display,
    ptable::ProcessedTable,
    table_str::Matrix{Vector{String}},
    actual_columns_width::Vector{Int},
    continuation_row_line::Int,
    num_lines_in_row::Vector{Int},
    vcrop_mode::Symbol,
    table_height::Int,
    Δdisplay_lines::Int,
    # Configurations.
    body_hlines::Vector{Int},
    body_hlines_format::NTuple{4, Char},
    continuation_row_alignment::Symbol,
    ellipsis_line_skip::Integer,
    (@nospecialize highlighters::Ref{Any}),
    hlines::Union{Symbol, AbstractVector},
    tf::TextFormat,
    vlines::Union{Symbol, AbstractVector},
    # Crayons.
    border_crayon::Crayon,
    header_crayon::Crayon,
    row_name_crayon::Crayon,
    row_name_header_crayon::Crayon,
    rownum_header_crayon::Crayon,
    subheader_crayon::Crayon,
    text_crayon::Crayon
)
    # Get size information from the processed table.
    num_rows = _size(ptable)[1]
    num_header_rows = _header_size(ptable)[1]
    num_rendered_rows, num_rendered_columns = size(table_str)

    # Check if the last horizontal line must be drawn, which must happen
    # **after** the continuation line in `vcrop_mode = :bottom`.
    draw_last_hline = _check_hline(ptable, hlines, body_hlines, num_rows)

    # This variable is used to decide whether to print the continuation
    # characters.
    line_count = 0

    # Initialize the row printing state machine.
    rps = RowPrintingState()

    while rps.state ≠ :finish
        # Row printing state machine
        # ======================================================================

        action = _iterate_row_printing_state!(
            rps,
            ptable,
            display,
            num_lines_in_row,
            num_rendered_rows,
            hlines,
            body_hlines,
            draw_last_hline,
            Δdisplay_lines,
            continuation_row_line
        )

        # Render the top line
        # ======================================================================

        if action == :top_horizontal_line
            _draw_line!(
                display,
                ptable,
                tf.up_left_corner,
                tf.up_intersection,
                tf.up_right_corner,
                tf.row,
                border_crayon,
                actual_columns_width,
                vlines
            )

        # Render the middle line
        # ======================================================================

        elseif action == :middle_horizontal_line
            # If the row is from the header, we must draw the line from the
            # table format. Otherwise, we must use the user configuration in
            # `body_hlines_format`.
            if _is_header_row(ptable, rps.i)
                _draw_line!(
                    display,
                    ptable,
                    tf.left_intersection,
                    tf.middle_intersection,
                    tf.right_intersection,
                    tf.row,
                    border_crayon,
                    actual_columns_width,
                    vlines
                )
            else
                _draw_line!(
                    display,
                    ptable,
                    body_hlines_format...,
                    border_crayon,
                    actual_columns_width,
                    vlines
                )
            end

        # Render the bottom line
        # ======================================================================

        elseif action == :bottom_horizontal_line
            _draw_line!(
                display,
                ptable,
                tf.bottom_left_corner,
                tf.bottom_intersection,
                tf.bottom_right_corner,
                tf.row,
                border_crayon,
                actual_columns_width,
                vlines
            )

        # Render the continuation line
        # ======================================================================

        elseif action == :continuation_line
            _draw_continuation_line(
                display,
                ptable,
                tf,
                text_crayon,
                border_crayon,
                actual_columns_width,
                vlines,
                continuation_row_alignment
            )

        # Render a table line
        # ======================================================================

        elseif (action == :table_line) || (action == :table_line_row_finished)
            i = rps.i
            l = rps.l
            row_id = _get_row_id(ptable, i)

            # Select the continuation character for this line.
            if (ellipsis_line_skip ≤ 0) || _is_header_row(row_id)
                display.cont_char = '⋯'
            else
                display.cont_char = line_count % (ellipsis_line_skip + 1) == 0 ?
                    '⋯' :
                    ' '
                line_count += 1
            end

            # Check if we need to print a vertical line at the beginning of the
            # line.
            if _check_vline(ptable, vlines, 0)
                _p!(display, border_crayon, tf.column, false, 1)
            end

            # Render the cells in each column
            # ------------------------------------------------------------------

            for j in 1:num_rendered_columns
                has_vline = _check_vline(ptable, vlines, j)
                final_line_print = j == num_rendered_columns && !has_vline

                # If this cell has less than `l` lines, then we just need to
                # align it.
                if length(table_str[i, j]) < l
                    # Align the text in the column.
                    cell_processed_str = _str_aligned(
                        "",
                        :l,
                        actual_columns_width[j]
                    )

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

                    # Get the correct crayon for this cell.
                    cell_crayon = _select_default_cell_crayon(
                        row_id,
                        column_id,
                        header_crayon,
                        row_name_crayon,
                        row_name_header_crayon,
                        rownum_header_crayon,
                        subheader_crayon,
                        text_crayon
                    )

                    # Get the alignment for this cell.
                    cell_alignment = _get_cell_alignment(ptable, i, j)

                    # Select the rendering algorihtm based on the type of the
                    # cell.
                    if _is_header_row(row_id) || (column_id != :__ORIGINAL_DATA__)
                        # Align the text in the column.
                        cell_processed_str = _str_aligned(
                            table_str[i, j][l],
                            cell_alignment,
                            actual_columns_width[j]
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
                        # TODO: Can we improve by moving to another part?
                        # We are getting both row and column in all cells.
                        ir = _get_data_row_index(ptable, rps.i_pt)
                        jr = _get_data_column_index(ptable, j)

                        # In this case, we need to process the cell to apply the
                        # correct alignment and highlighters before rendering
                        # it.
                        cell_data = _get_element(ptable, i, j)

                        cell_processed_str, cell_crayon = _process_data_cell_text(
                            ptable,
                            cell_data,
                            table_str[i, j][l],
                            ir,
                            jr,
                            l,
                            actual_columns_width[j],
                            text_crayon,
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
                            # If we have a custom cell, we need a custom
                            # printing function.
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
                    _p!(display, border_crayon, tf.column, final_line_print, 1)
                end
            end

            _nl!(display)

        # End state
        # ======================================================================

        elseif action == :finish
            break
        end
    end

    return nothing
end
