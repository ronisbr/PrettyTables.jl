# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   This file contains functions to create printing recipes.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _create_printing_recipe(screen::Screen, header_num_rows::Int, num_printed_rows::Int, num_printed_cols::Int, num_lines_in_row::Vector{Int}, cols_width::Vector{Int}, hlines::Vector{Int}, vlines::Vector{Int}, Δscreen_lines::Int, # Configurations crop::Symbol, noheader::Bool, show_omitted_cell_summary::Bool)

Create the printing recipes for the rows and columns of the table. This function
also computed how many rows and columns are omitted in the printing.

"""
function _create_printing_recipe(screen::Screen,
                                 header_num_rows::Int,
                                 num_printed_rows::Int,
                                 num_printed_cols::Int,
                                 num_lines_in_row::Vector{Int},
                                 cols_width::Vector{Int},
                                 hlines::Vector{Int},
                                 vlines::Vector{Int},
                                 Δscreen_lines::Int,
                                 # Configurations
                                 crop::Symbol,
                                 noheader::Bool,
                                 show_omitted_cell_summary::Bool)

    # Column printing recipe
    # ==========================================================================

    col_printing_recipe   = Vector{Union{Int,Symbol}}(undef, 0)
    data_horizontal_limit = 0
    fully_printed_cols    = 0

    # Verify if the output must be cropped.
    if crop == :both || crop == :horizontal
        data_horizontal_limit = screen.size[2] - 1
    end

    # The variable stores the current line length to check how many columns we
    # can print.
    line_length = 1

    if 0 ∈ vlines
        line_length += 2
        push!(col_printing_recipe, :left_line)
    end

    @inbounds for i = 1:num_printed_cols
        line_length += cols_width[i]
        push!(col_printing_recipe, i)

        Δ = data_horizontal_limit > 0 ?
            data_horizontal_limit - line_length :
            1
        Δ < 0 && break

        fully_printed_cols += 1

        # Space after the row printing.
        line_length += 1

        if i ∈ vlines
            line_length += 1

            if i != num_printed_cols
                push!(col_printing_recipe, :column_line)

                # Consider the space after the column line.
                line_length += 1
            else
                push!(col_printing_recipe, :right_line)
            end
        end
    end

    # Compute the number of omitted columns.
    num_omitted_cols = num_printed_cols - fully_printed_cols

    # Row printing recipe
    # ==========================================================================

    row_printing_recipe = Vector{Union{Tuple{Int,Int},Symbol}}(undef, 0)
    data_vertical_limit = 0
    fully_printed_rows  = 0
    crop_space          = show_omitted_cell_summary ? 2 : 1

    # Verify if the output must be cropped.
    if crop == :both || crop == :vertical
        data_vertical_limit = screen.size[1] - Δscreen_lines - crop_space
    end

    header_length  = 0 ∈ hlines ? 1 : 0

    if !noheader
        header_length += header_num_rows
        header_length += 1 ∈ hlines ? 1 : 0
    end

    # This variable stores the number of printed lines to verify how many we can
    # print.
    printed_lines = header_length

    @inbounds for i = 1:num_printed_rows
        num_lines_row_i = num_lines_in_row[i]

        # This variable contains the number of available lines we have to print
        # the data.
        Δ = data_vertical_limit > 0 ?
            data_vertical_limit - (num_lines_row_i + printed_lines) :
            1

        # Verify if the entire row can be printed.
        if Δ < 0
            # Compute the remaining lines to be printed.
            remaining_lines = i < num_printed_rows ? sum(num_lines_in_row[i+1:end]) : 0

            # Given the additional space we have when printing the continuation
            # line and possibly the summary information, we need to check if
            # the remaining lines fit on it.
            if (-Δ ≤ crop_space)
                if show_omitted_cell_summary && (num_omitted_cols == 0)

                    if -Δ+1 > remaining_lines
                        for j = i:num_printed_rows
                            push!(row_printing_recipe, (j, num_lines_in_row[j]))
                        end

                        fully_printed_rows = num_printed_rows
                        break
                    end
                end
            end

            # If there only one more line to be printed, check if this is the
            # last information. In this case we can suppress the continuation
            # line.
            if (-Δ + remaining_lines == 1)
                push!(row_printing_recipe, (i, num_lines_row_i))
                fully_printed_rows += 1
            else
                remaining_rows = data_vertical_limit - printed_lines
                remaining_rows > 0 && push!(row_printing_recipe, (i, remaining_rows))
                push!(row_printing_recipe, :continuation_line)
            end

            break
        else
            push!(row_printing_recipe, (i, num_lines_row_i))
            printed_lines += num_lines_row_i
            fully_printed_rows += 1

            # Check if we have space for drawing the row line.
            Δ = data_vertical_limit > 0 ? data_vertical_limit - printed_lines : 1

            if (Δ < 0)
                push!(row_printing_recipe, :continuation_line)
                break
            else
                if (Δ > 0) && (i != num_printed_rows) && ((i+!noheader) ∈ hlines)
                    push!(row_printing_recipe, :row_line)
                    printed_lines += 1
                end
            end
        end
    end

    num_omitted_rows = num_printed_rows - fully_printed_rows

    return row_printing_recipe, col_printing_recipe, num_omitted_rows,
           num_omitted_cols
end
