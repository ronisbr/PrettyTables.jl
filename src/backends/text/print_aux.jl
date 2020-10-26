# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Auxiliary functions to print the parts of the table.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Print the table header without the horizontal lines.
function _print_table_header!(buf::IO,
                              screen::Screen,
                              header::Any,
                              header_str::Matrix{String},
                              header_len::Matrix{Int},
                              id_cols::Vector{Int},
                              id_rows::Vector{Int},
                              num_printed_cols::Int,
                              Δc::Int,
                              cols_width::Vector{Int},
                              vlines::Vector{Int},
                              # Configurations.
                              alignment::Vector{Symbol},
                              header_alignment::Vector{Symbol},
                              header_cell_alignment::Tuple,
                              show_row_names::Bool,
                              show_row_number::Bool,
                              tf::TextFormat,
                              # Crayons.
                              border_crayon::Crayon,
                              header_crayon::Vector{Crayon},
                              subheader_crayon::Vector{Crayon},
                              rownum_header_crayon::Crayon,
                              row_name_header_crayon::Crayon)

    header_num_rows, ~ = size(header_str)

    @inbounds @views for i = 1:header_num_rows
        0 ∈ vlines && _p!(screen, border_crayon, tf.column, false, 1)

        for j = 1:num_printed_cols
            # Get the information about the alignment and the crayon.
            if j ≤ Δc
                if show_row_number && (j == 1)
                    crayon_ij    = rownum_header_crayon
                    alignment_ij = alignment[1]
                elseif show_row_names
                    crayon_ij    = row_name_header_crayon
                    alignment_ij = alignment[Δc]
                end
            else
                jc = id_cols[j-Δc]
                crayon_ij    = (i == 1) ? header_crayon[jc] : subheader_crayon[jc]
                alignment_ij = header_alignment[jc]

                # Check for cell alignment override.
                for f in header_cell_alignment
                    aux = f(header, i, jc)

                    if aux ∈ (:l, :c, :r, :L, :C, :R, :s, :S)
                        alignment_ij = aux
                        break
                    end
                end

                # If alignment is `:s`, then we must use the column
                # alignment.
                alignment_ij ∈ (:s,:S) && (alignment_ij = alignment[jc+Δc])
            end

            # Prepare the text to be printed.
            header_ij_str, header_ij_len = _str_aligned(header_str[i,j],
                                                        alignment_ij,
                                                        cols_width[j],
                                                        header_len[i,j])
            header_ij_str  = " " * header_ij_str * " "
            header_ij_len += 2

            flp = j == num_printed_cols

            # Print the text.
            _p!(screen, crayon_ij, header_ij_str, false, header_ij_len)

            # Check if we need to draw a vertical line here.
            _pc!(j ∈ vlines, screen, border_crayon, tf.column, "", flp, 1, 0)

            _eol(screen) && break
        end

        i != header_num_rows && _nl!(screen, buf)
    end

    _nl!(screen, buf)
end

# Print the entire table data.
function _print_table_data(buf::IO,
                           screen::Screen,
                           data::Any,
                           data_str::Matrix{Vector{String}},
                           data_len::Matrix{Vector{Int}},
                           id_cols::Vector{Int},
                           id_rows::Vector{Int},
                           Δc::Int,
                           cols_width::Vector{Int},
                           vlines::Vector{Int},
                           row_printing_recipe::Vector{Union{Tuple{Int,Int,Int},Symbol}},
                           col_printing_recipe::Vector{Union{Int,Symbol}},
                           # Configurations.
                           alignment::Vector{Symbol},
                           body_hlines_format::Tuple,
                           cell_alignment::Tuple,
                           continuation_row_alignment::Symbol,
                           ellipsis_line_skip::Integer,
                           highlighters::Tuple,
                           noheader::Bool,
                           show_row_names::Bool,
                           show_row_number::Bool,
                           tf::TextFormat,
                           # Crayons.
                           border_crayon::Crayon,
                           row_name_crayon::Crayon,
                           text_crayon::Crayon)

    line_count = 0

    for r in row_printing_recipe
        if r isa Symbol
            if r == :row_line
                _draw_line!(screen, buf, body_hlines_format..., border_crayon,
                            cols_width, vlines)
            elseif r == :continuation_line
                _draw_continuation_row(screen, buf, tf, text_crayon,
                                       border_crayon, cols_width, vlines,
                                       continuation_row_alignment)
            else
                error("Internal error: wrong symbol in row printing recipe.")
            end

        else
            i, num_lines, l₀ = r
            ir = id_rows[i]

            for l = l₀:(l₀+num_lines-1)

                # Check if we should print the ellipsis here.
                screen.cont_char =
                    line_count % (ellipsis_line_skip + 1) == 0 ? '⋯' : ' '
                line_count += 1

                num_col_recipes = length(col_printing_recipe)

                for c_id = 1:num_col_recipes
                    c = col_printing_recipe[c_id]

                    flp = c_id == num_col_recipes

                    if c isa Symbol
                        if c == :left_line
                            _p!(screen, border_crayon, tf.column, flp, 1)
                        elseif c == :column_line
                            _p!(screen, border_crayon, tf.column, flp, 1)
                        elseif c == :right_line
                            _p!(screen, border_crayon, tf.column, flp, 1)
                        else
                            error("Internal error: wrong symbol in column printing recipe.")
                        end
                    else
                        j = c

                        # Get the information about the alignment and the
                        # crayon.
                        #
                        # NOTE: The variable `data_cell` is used to avoid
                        # applying formatters and highlighters to the row number
                        # and row name columns.
                        if j ≤ Δc
                            if show_row_number && (j == 1)
                                crayon_ij    = text_crayon
                                alignment_ij = alignment[1]
                            elseif show_row_names
                                crayon_ij    = row_name_crayon
                                alignment_ij = alignment[Δc]
                            end
                            jc = 0
                            data_cell = false
                        else
                            jc = id_cols[j-Δc]
                            crayon_ij    = text_crayon
                            alignment_ij = alignment[jc+Δc]
                            data_cell    = true
                        end

                        # String to be processed.
                        if length(data_str[i,j]) >= l
                            data_ij_str = data_str[i,j][l]
                            data_ij_len = data_len[i,j][l]
                        else
                            data_ij_str = ""
                            data_ij_len = 0
                        end

                        # Process the string with the correct alignment and also
                        # apply the highlighters.
                        data_ij_str, data_ij_len, crayon_ij =
                            _process_cell_text(data,
                                               ir,
                                               jc,
                                               data_cell,
                                               data_ij_str,
                                               data_ij_len,
                                               cols_width[j],
                                               crayon_ij,
                                               alignment_ij,
                                               cell_alignment,
                                               highlighters)

                        _p!(screen, crayon_ij, data_ij_str, false, data_ij_len)
                    end
                end
                _nl!(screen, buf)
            end
        end
    end
end
