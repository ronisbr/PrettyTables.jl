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

    # Those variables are used to verify how many rows and columns were omitted.
    fully_printed_columns = 0
    fully_printed_rows = 0

    # Initialize the row printing state machine.
    rps = RowPrintingState()

    while rps.state ≠ :finish
        # Row printing state machine
        # ======================================================================

        if vcrop_mode != :middle
            continuation_row_line = _compute_continuation_row_in_bottom_vcrop(
                display,
                table_height,
                draw_last_hline,
                Δdisplay_lines
            )

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
        else
            continuation_row_line = _compute_continuation_row_in_middle_vcrop(
                display,
                table_height,
                num_lines_in_row,
                num_header_rows,
                Δdisplay_lines
            )

            action = _iterate_row_printing_state_vcrop_middle!(
                rps,
                ptable,
                display,
                num_lines_in_row,
                num_rendered_rows,
                hlines,
                body_hlines,
                draw_last_hline,
                Δdisplay_lines,
                table_height,
                continuation_row_line
            )
        end

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

            # TODO: This variable must be computed only one time.
            fully_printed_columns = 0

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
                    _p!(display, _default_crayon, " ", false, 1) && break

                    _p!(
                        display,
                        _default_crayon,
                        cell_processed_str,
                        false,
                        actual_columns_width[j]
                    ) && break

                    if row_id == :__ORIGINAL_DATA__
                        fully_printed_columns += 1
                    end

                    _p!(display, _default_crayon, " ", final_line_print, 1) && break

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
                        _p!(display, _default_crayon, " ", false, 1) && break

                        _p!(
                            display,
                            cell_crayon,
                            cell_processed_str,
                            false,
                            actual_columns_width[j]
                        ) && break

                        _p!(display, _default_crayon, " ", final_line_print, 1) && break

                    else
                        # In this case, we need to process the cell to apply the
                        # correct alignment and highlighters before rendering
                        # it.
                        cell_data = _get_element(ptable, i, j)

                        cell_processed_str, cell_crayon = _process_data_cell_text(
                            ptable,
                            cell_data,
                            table_str[i, j][l],
                            i,
                            j,
                            l,
                            actual_columns_width[j],
                            text_crayon,
                            cell_alignment,
                            highlighters
                        )

                        _p!(display, _default_crayon, " ", false, 1) && break

                        if !(cell_data isa CustomTextCell)
                            _p!(
                                display,
                                cell_crayon,
                                cell_processed_str,
                                false,
                                actual_columns_width[j]
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

                        fully_printed_columns += 1

                        _p!(display, _default_crayon, " ", false, 1) && break
                    end
                end

                # Check if we need to print a vertical line after the column.
                if has_vline
                    final_line_print = j == num_rendered_columns
                    _p!(display, border_crayon, tf.column, final_line_print, 1)
                end
            end

            _nl!(display)

            # Actions after a row is finished (all the lines are printed)
            # ----------------------------------------------------------------------

            if action == :table_line_row_finished
                if !_is_header_row(ptable, rps.i)
                    fully_printed_rows += 1
                end
            end

        # End state
        # ======================================================================

        elseif action == :finish
            break
        end
    end

    return fully_printed_rows, fully_printed_columns
end

# Iterate the row printing state machine.
function _iterate_row_printing_state!(
    rps::RowPrintingState,
    ptable::ProcessedTable,
    display::Display,
    num_lines_in_row::Vector{Int},
    num_rendered_rows::Int,
    hlines::Union{Symbol, AbstractVector},
    body_hlines::Vector{Int},
    draw_last_hline::Bool,
    Δdisplay_lines::Int,
    continuation_row_line::Int
)
    # Loop until we find a state that must generate an action.
    action = :nop

    if display.size[1] ≤ 0
        vcrop = false
    else
        vcrop = true
    end

    while action == :nop
        # Compute the number of remaining rows.
        Δrows = _available_rows(display) - Δdisplay_lines

        if rps.printed_lines == continuation_row_line
            action = :continuation_line
            rps.state = :continuation_line
            rps.printed_lines += 1
            break

        elseif rps.state == :top_horizontal_line
            rps.state = :table_line
            rps.i = 1
            rps.l = 0

            if _check_hline(ptable, hlines, body_hlines, 0)
                action = :top_horizontal_line
                rps.printed_lines += 1
                break
            else
                continue
            end

        elseif rps.state == :middle_horizontal_line
            rps.state = :table_line
            rps.i += 1
            rps.l = 0
            continue

        elseif rps.state == :table_line
            rps.l += 1

            if rps.i ≤ num_rendered_rows
                if rps.l < num_lines_in_row[rps.i]
                    action = :table_line
                    rps.printed_lines += 1
                    break
                elseif rps.l == num_lines_in_row[rps.i]
                    action = :table_line_row_finished
                    rps.printed_lines += 1
                    break
                else
                    rps.state = :row_finished
                    continue
                end
            end

        elseif rps.state == :continuation_line
            if draw_last_hline
                rps.state = :bottom_horizontal_line
                action = :bottom_horizontal_line
                rps.printed_lines += 1
                break
            else
                rps.state = :finish
                action = :finish
                rps.printed_lines += 1
                break
            end

        elseif rps.state == :row_finished
            has_hline = _check_hline(ptable, hlines, body_hlines, rps.i)

            if rps.i < num_rendered_rows
                if has_hline
                    action = :middle_horizontal_line
                    rps.state = :middle_horizontal_line
                    rps.printed_lines += 1
                    break
                else
                    rps.state = :table_line
                    rps.i += 1
                    rps.l = 0
                    continue
                end
            else
                rps.state = :finish

                if draw_last_hline
                    action = :bottom_horizontal_line
                else
                    action = :finish
                end
            end

        elseif rps.state == :bottom_horizontal_line
            action = :finish
            rps.state = :finish
            break
        end
    end

    return action
end

# Iterate the row printing state machine.
function _iterate_row_printing_state_vcrop_middle!(
    rps::RowPrintingState,
    ptable::ProcessedTable,
    display::Display,
    num_lines_in_row::Vector{Int},
    num_rendered_rows::Int,
    hlines::Union{Symbol, AbstractVector},
    body_hlines::Vector{Int},
    draw_last_hline::Bool,
    Δdisplay_lines::Int,
    table_height::Int,
    continuation_row_line::Int
)
    # Loop until we find a state that must generate an action.
    action = :nop

    if display.size[1] ≤ 0
        vcrop = false
    else
        vcrop = true
    end

    while action == :nop
        if rps.printed_lines == continuation_row_line
            rps.state = :continuation_line
            action = :continuation_line
            rps.printed_lines += 1
            break

        elseif rps.state == :top_horizontal_line
            rps.state = :table_line
            rps.i = 1
            rps.i_pt = 1
            rps.l = 0

            if _check_hline(ptable, hlines, body_hlines, 0)
                action = :top_horizontal_line
                rps.printed_lines += 1
                break
            else
                continue
            end

        elseif rps.state == :middle_horizontal_line
            rps.state = :table_line
            rps.i += 1
            rps.i_pt += 1
            rps.l = 0
            continue

        elseif rps.state == :table_line
            rps.l += 1

            if rps.i ≤ num_rendered_rows
                if (rps.l < num_lines_in_row[rps.i])
                    action = :table_line
                    rps.printed_lines += 1
                    break
                elseif rps.l == num_lines_in_row[rps.i]
                    action = :table_line_row_finished
                    rps.printed_lines += 1
                    break
                else
                    rps.state = :row_finished
                    continue
                end
            else
                rps.state = :row_finished
                continue
            end

        elseif rps.state == :continuation_line
            num_rows = _size(ptable)[1]
            Δrows = _available_rows(display) - Δdisplay_lines
            Δi = 0
            new_l = 0
            total_lines = 0

            if Δrows ≤ 0
                if draw_last_hline
                    rps.state = :bottom_horizontal_line
                    action = :bottom_horizontal_line
                else
                    rps.state = :finish
                    action = :finish
                end
                break
            end

            while (Δrows - total_lines) > 0
                total_lines += num_lines_in_row[num_rendered_rows - Δi]

                if total_lines ≥ Δrows
                    new_l = total_lines - Δrows
                    rps.state = :table_line
                    break
                else
                    Δi += 1
                    new_l = 0
                end

                if _check_hline(ptable, hlines, body_hlines, num_rows - Δi)
                    total_lines += 1

                    if total_lines ≥ Δrows
                        rps.state = :row_finished
                        break
                    end
                end
            end

            rps.i = num_rendered_rows - Δi
            rps.i_pt = num_rows - Δi
            rps.l = new_l

            continue

        elseif rps.state == :row_finished
            has_hline = _check_hline(ptable, hlines, body_hlines, rps.i_pt)

            if rps.i < num_rendered_rows
                if has_hline
                    action = :middle_horizontal_line
                    rps.state = :middle_horizontal_line
                    rps.printed_lines += 1
                    break
                else
                    rps.state = :table_line
                    rps.i += 1
                    rps.i_pt += 1
                    rps.l = 0
                    continue
                end
            else
                rps.state = :finish

                if draw_last_hline
                    action = :bottom_horizontal_line
                else
                    action = :finish
                end
            end

        elseif rps.state == :bottom_horizontal_line
            action = :finish
            rps.state = :finish
            break
        end
    end

    return action
end
