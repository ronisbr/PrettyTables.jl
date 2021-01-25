# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Miscellaneous functions related to the Text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function _update_text_table_lengths!(header_str::Matrix{String},
                                     header_len::Matrix{Int},
                                     data_str::Matrix{Vector{String}},
                                     data_len::Matrix{Vector{Int}},
                                     id_cols::Vector{Int},
                                     Δc::Int,
                                     cols_width::Vector{Int},
                                     num_lines_in_row::Vector{Int},
                                     # Configurations
                                     columns_width::Vector{Int},
                                     crop_subheader::Bool,
                                     fixed_col_width::Vector{Bool},
                                     maximum_columns_width::Vector{Int},
                                     minimum_columns_width::Vector{Int},
                                     noheader::Bool)

    num_printed_rows, num_printed_cols = size(data_str)
    num_header_printed_rows, ~         = size(header_str)

    # The column width must be updated.
    cols_width .= zeros(Int, num_printed_cols)

    # The number of lines in each row must be updated.
    num_lines_in_row .= ones(Int, num_printed_rows)

    # Regex to remove ANSI escape sequences so that we can compute the printable
    # size of the cell. This is required for Markdown cells.
    r_ansi_escape = r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])"

    @inbounds for j = 1:num_printed_cols
        largest_cell_width = 0

        # Header
        # ----------------------------------------------------------------------

        if !noheader
            for i = 1:num_header_printed_rows
                !isassigned(header_str, i, j) && continue

                # Remove the escape sequences to obtain only printable
                # characters.
                str_p = replace(header_str[i,j], r_ansi_escape => "")

                header_ij_len   = textwidth(str_p)
                header_len[i,j] = header_ij_len

                # If the user wants to crop the subheader, then it should not be
                # used to compute the largest cell width of this column.
                ((i == 1) || (!crop_subheader)) &&
                    (largest_cell_width = max(largest_cell_width, header_ij_len))
            end
        end

        # Data
        # ----------------------------------------------------------------------

        for i = 1:num_printed_rows
            !isassigned(data_str, i, j) && continue

            num_lines = length(data_str[i,j])

            num_lines_in_row[i] = max(num_lines_in_row[i], num_lines)

            # Make sure the number of lines in `data_len` match the number of
            # lines in `data_str`.
            (!isassigned(data_len, i, j) || num_lines ≠ length(data_len[i,j])) &&
                (data_len[i,j] = zeros(Int, num_lines))

            for k = 1:num_lines
                # Remove the escape sequences to obtain only printable
                # characters.
                str_p = replace(data_str[i,j][k], r_ansi_escape => "")

                data_ijk_len     = textwidth(str_p)
                data_len[i,j][k] = data_ijk_len

                largest_cell_width = max(largest_cell_width, data_ijk_len)
            end
        end

        # If we are in data columns, then we need to check the user preferences
        # before updating the table widths. Otherwise, we are in the added
        # columns (row number or row name) and we always need to update the
        # widths.
        if j ≤ Δc
            cols_width[j] = max(cols_width[j], largest_cell_width)
        else
            jc = id_cols[j-Δc]

            # Check if we need to replace the column width.
            if !fixed_col_width[jc]
                cols_width[j] = max(cols_width[j], largest_cell_width)

                # Make sure that the maximum column width is respected.
                if maximum_columns_width[jc] > 0 &&
                    maximum_columns_width[jc] < cols_width[j]
                    cols_width[j] = maximum_columns_width[jc]
                end

                # Make sure that the minimum column width is respected.
                if minimum_columns_width[jc] > 0 &&
                    minimum_columns_width[jc] > cols_width[j]
                    cols_width[j] = minimum_columns_width[jc]
                end
            else
                cols_width[j] = columns_width[jc]
            end
        end
    end

    return nothing
end
