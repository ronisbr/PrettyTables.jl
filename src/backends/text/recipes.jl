# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   This file contains functions to create printing recipes.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Constants that identify some actions inside the column receipes. They **must
# be** lower than zero.
const _LEFT_LINE = -1
const _COLUMN_LINE = -2
const _RIGHT_LINE = -3

# Constants that identify some actions inside the row receipes. They **must be**
# a `NTuple{4, Int}` with the first index lower than 0.
const _ROW_LINE = (-1, 0, 0, 0)
const _CONTINUATION_LINE = (-2, 0, 0, 0)

# Create the printing recipes for the rows and columns of the table. This
# function also computed how many rows and columns are omitted in the printing.
function _create_printing_recipe(
    display::Display,
    header_num_rows::Int,
    num_filtered_rows::Int,
    num_filtered_cols::Int,
    num_printed_rows::Int,
    num_printed_cols::Int,
    num_lines_in_row::Vector{Int},
    cols_width::Vector{Int},
    id_rows::AbstractVector{Int},
    hlines::Vector{Int},
    vlines::Vector{Int},
    Δdisplay_lines::Int,
    Δc::Int,
    # Configurations
    crop::Symbol,
    noheader::Bool,
    show_omitted_cell_summary::Bool,
    vcrop_mode::Symbol
)
    # Column printing recipe
    # ==========================================================================

    col_printing_recipe   = Vector{Int}(undef, 0)
    data_horizontal_limit = 0
    fully_printed_cols    = 0

    # Verify if the output must be cropped.
    if crop == :both || crop == :horizontal
        data_horizontal_limit = display.size[2] - 1
    end

    # The variable stores the current line length to check how many columns we
    # can print.
    line_length = 0

    if 0 ∈ vlines
        line_length += 1
        push!(col_printing_recipe, _LEFT_LINE)
    end

    @inbounds for i in 1:num_printed_cols
        # Space before the next row.
        line_length += 1

        # Width of the column.
        line_length += cols_width[i]
        push!(col_printing_recipe, i)

        Δ = data_horizontal_limit > 0 ? data_horizontal_limit - line_length : 1
        Δ ≤ 0 && break

        fully_printed_cols += 1

        # Space after the row printing.
        line_length += 1

        if i ∈ vlines
            if i != num_printed_cols
                push!(col_printing_recipe, _COLUMN_LINE)
            else
                push!(col_printing_recipe, _RIGHT_LINE)
            end
            line_length += 1
        end
    end

    # Compute the number of omitted columns.
    num_omitted_cols = clamp(
        num_filtered_cols - (fully_printed_cols - Δc),
        0,
        num_filtered_cols
    )

    # Row printing recipe
    # ==========================================================================

    # The row printing recipe can be a symbol, which indicates a type of line
    # that must be drawn, or a tuple of three integers that describe:
    #
    #     1. The index of the row that must be printed in `data_str`.
    #     2. The index of the row that must be printed in `data`.
    #     3. How many lines must be printed.
    #     4. The initial printing line.

    row_printing_recipe = Vector{NTuple{4, Int}}(undef, 0)
    data_vertical_limit = 0
    fully_printed_rows  = 0

    # Compute how many additional lines we need to print the cropping
    # information.
    crop_space = show_omitted_cell_summary ? 2 : 1

    # Verify if the output must be vertically cropped.
    data_vcropped = false

    if (display.size[1] > 0) && ( (crop == :both) || (crop == :vertical) )
        # Compute the number of lines required to print the table. Notice that
        # we need to omit the last line since it is always printed.
        total_hlines = count(x -> 0 ≤ x < (!noheader + num_printed_rows), hlines)
        total_table_lines  = !noheader ? header_num_rows : 0
        total_table_lines += total_hlines + sum(num_lines_in_row)

        # Check if we can print all the table lines in the available space.
        data_vertical_limit = display.size[1] - Δdisplay_lines - crop_space
        Δ = data_vertical_limit - total_table_lines

        # Given the additional space we have when printing the continuation
        # line and possibly the summary information, we need to check if
        # the remaining lines fit on it.
        data_vcropped = true

        if Δ > -crop_space
            data_vcropped = false
        else
            if show_omitted_cell_summary && (num_omitted_cols == 0) && (Δ+2 ≥ 0)
                data_vcropped = false
            elseif (Δ+1 ≥ 0)
                data_vcropped = false
            end
        end
    end

    # If data is not cropped, then we just need to add all the columns to the
    # recipe.
    if !data_vcropped
        fully_printed_rows = num_printed_rows

        @inbounds for i in 1:num_printed_rows
            # Index of this row in `data`.
            ir = id_rows[i]

            push!(row_printing_recipe, (i, ir, num_lines_in_row[i], 1))

            if (i != num_printed_rows) && ((i+!noheader) ∈ hlines)
                push!(row_printing_recipe, _ROW_LINE)
            end
        end
    else
        # Compute the required size for the header.
        header_length  = 0 ∈ hlines ? 1 : 0

        if !noheader
            header_length += header_num_rows
            header_length += 1 ∈ hlines ? 1 : 0
        end

        # This variable stores the number of printed lines to verify how many we
        # can print.
        printed_lines = header_length

        fully_printed_rows = 0

        if vcrop_mode == :bottom
            @inbounds for i in 1:num_printed_rows
                num_lines_row_i = num_lines_in_row[i]

                # Index of this row in `data`.
                ir = id_rows[i]

                # This variable contains the number of available lines we have
                # to print the data.
                Δ = data_vertical_limit - (num_lines_row_i + printed_lines)

                # Verify if the entire row can be printed.
                if Δ < 0
                    remaining_rows = data_vertical_limit - printed_lines

                    if remaining_rows > 0
                        push!(row_printing_recipe, (i, ir, remaining_rows, 1))
                    end

                    push!(row_printing_recipe, _CONTINUATION_LINE)
                    break
                else
                    push!(row_printing_recipe, (i, ir, num_lines_row_i, 1))
                    printed_lines += num_lines_row_i
                    fully_printed_rows += 1

                    # Check if we have space for drawing the row line.
                    Δ = data_vertical_limit - printed_lines

                    if (Δ < 0)
                        push!(row_printing_recipe, _CONTINUATION_LINE)
                        break
                    else
                        if (Δ > 0) && (i != num_printed_rows) && ((i+!noheader) ∈ hlines)
                            push!(row_printing_recipe, _ROW_LINE)
                            printed_lines += 1
                        end
                    end
                end
            end

        elseif vcrop_mode == :middle
            # In this mode, we will fill the printing using two passes. In the
            # first, we compute the top of the table and, in the second, the
            # bottom of the table. In the latter, it is easier to fill from the
            # end to the beginning of the table. Hence, we create a temporary
            # vector of the recipe that will be reversed and merged into the
            # main one.
            row_printing_recipe_end = Vector{NTuple{4, Int}}(undef, 0)

            # Compute the amount of space left to print the table data.
            table_data_space = data_vertical_limit - header_length

            Δs = cld(table_data_space, 2)
            Δr = cld(num_printed_rows, 2)

            printed_lines = 0

            # Fill the top of the table.
            @inbounds for i in 1:Δr
                num_lines_row_i = num_lines_in_row[i]

                # Index of this row in `data`.
                ir = id_rows[i]

                # This variable contains the number of available lines we have
                # to print the data.
                Δ = Δs - (num_lines_row_i + printed_lines)

                # Verify if the entire row can be printed.
                if Δ < 0
                    remaining_rows = Δs - printed_lines

                    if remaining_rows > 0
                        push!(row_printing_recipe, (i, ir, remaining_rows, 1))
                    end

                    break
                else
                    push!(row_printing_recipe, (i, ir, num_lines_row_i, 1))
                    printed_lines += num_lines_row_i
                    fully_printed_rows += 1

                    # Check if we have space for drawing the row line.
                    Δ = Δs - printed_lines

                    if (Δ < 0)
                        break
                    else
                        if (Δ > 0) && (i != num_printed_rows) && ((i+!noheader) ∈ hlines)
                            push!(row_printing_recipe, _ROW_LINE)
                            printed_lines += 1
                        end
                    end
                end
            end

            # In this case, we know that the data is cropped. Hence, we print
            # the continuation line in the middle.
            push!(row_printing_recipe, _CONTINUATION_LINE)

            Δs = table_data_space - Δs

            printed_lines = 0

            @inbounds for i in num_printed_rows:-1:Δr+1
                num_lines_row_i = num_lines_in_row[i]

                # Index of this row in the filtered table.
                ifilt = num_filtered_rows - (num_printed_rows - i)

                # Index of this row in `data`.
                ir = id_rows[ifilt]

                # This variable contains the number of available lines we have
                # to print the data.
                Δ = Δs - (num_lines_row_i + printed_lines)

                # Verify if the entire row can be printed.
                if Δ < 0
                    remaining_rows = Δs - printed_lines

                    # This row is cropped and we are in the bottom part. Hence,
                    # we need to print the lower part of the row.
                    if remaining_rows > 0
                        push!(
                            row_printing_recipe_end,
                            (i, ir, remaining_rows, num_lines_row_i - remaining_rows + 1)
                        )
                    end

                    break
                else
                    push!(row_printing_recipe_end, (i, ir, num_lines_row_i, 1))
                    printed_lines += num_lines_row_i
                    fully_printed_rows += 1

                    # Check if we have space for drawing the row line.
                    Δ = Δs - printed_lines

                    if (Δ < 0)
                        break
                    else
                        if (Δ > 0) && ((ifilt - 1 + !noheader) ∈ hlines)
                            push!(row_printing_recipe_end, _ROW_LINE)
                            printed_lines += 1
                        end
                    end
                end
            end

            # Merge the top and bottom parts.
            row_printing_recipe = vcat(
                row_printing_recipe,
                reverse(row_printing_recipe_end)
            )
        else
            error("Unknown vertical crop mode.")
        end
    end

    num_omitted_rows = num_filtered_rows - fully_printed_rows

    return row_printing_recipe, col_printing_recipe, num_omitted_rows, num_omitted_cols
end
