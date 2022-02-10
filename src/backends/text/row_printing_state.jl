# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to the row printing state machine.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#                      State machine for bottom cropping
# ==============================================================================

# Iterate the row printing state machine.
function _iterate_row_printing_state_vcrop_bottom!(
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

#                      State machine for middle cropping
# ==============================================================================

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
                if _check_hline(ptable, hlines, body_hlines, num_rows - Δi)
                    total_lines += 1

                    if total_lines ≥ Δrows
                        rps.state = :row_finished
                        break
                    end
                end

                total_lines += num_lines_in_row[num_rendered_rows - Δi]

                if total_lines ≥ Δrows
                    new_l = total_lines - Δrows
                    rps.state = :table_line
                    break
                else
                    Δi += 1
                    new_l = 0
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
