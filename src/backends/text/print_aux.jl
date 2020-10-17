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
        0 ∈ vlines && _p!(screen, buf, border_crayon, tf.column, false, 1)

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

            # If we have nothing more to print, then remove trailing spaces.
            if flp && (j ∉ vlines)
                header_ij_str = string(rstrip(header_ij_str))
                header_ij_len = textwidth(header_ij_str) + 1
            end

            # Print the text.
            _p!(screen, buf, crayon_ij, header_ij_str, false, header_ij_len)

            # Check if we need to draw a vertical line here.
            _pc!(j ∈ vlines, screen, buf, border_crayon, tf.column, "",
                 flp, 1, 0)

            _eol(screen) && break
        end

        i != header_num_rows && _nl!(screen,buf)
    end

    _nl!(screen,buf)
end

# Print the entire table data.
function _print_table_data(buf::IO,
                           screen::Screen,
                           data::Any,
                           data_str::Matrix{Vector{String}},
                           data_len::Matrix{Vector{Int}},
                           id_cols::Vector{Int},
                           id_rows::Vector{Int},
                           num_lines_in_row::Vector{Int},
                           num_printed_cols::Int,
                           Δc::Int,
                           cols_width::Vector{Int},
                           hlines::Vector{Int},
                           vlines::Vector{Int},
                           # Configurations.
                           alignment::Vector{Symbol},
                           body_hlines_format::Tuple,
                           cell_alignment::Tuple,
                           continuation_row_alignment::Symbol,
                           highlighters::Tuple,
                           noheader::Bool,
                           show_row_names::Bool,
                           show_row_number::Bool,
                           tf::TextFormat,
                           Δscreen_lines::Int,
                           # Crayons.
                           border_crayon::Crayon,
                           row_name_crayon::Crayon,
                           text_crayon::Crayon)

    num_printed_rows, ~ = size(data_str)

    draw_continuation_line = false

    for i = 1:num_printed_rows
        ir = id_rows[i]

        for l = 1:num_lines_in_row[i]
            0 ∈ vlines && _p!(screen, buf, border_crayon, tf.column, false, 1)

            for j = 1:num_printed_cols
                # Get the information about the alignment and the crayon.
                if j ≤ Δc
                    if show_row_number && (j == 1)
                        crayon_ij    = text_crayon
                        alignment_ij = alignment[1]
                    elseif show_row_names
                        crayon_ij    = row_name_crayon
                        alignment_ij = alignment[Δc]
                    end
                else
                    jc = id_cols[j-Δc]
                    crayon_ij    = text_crayon
                    alignment_ij = alignment[jc+Δc]

                    # Check for highlighters.
                    for h in highlighters
                        if h.f(_getdata(data), ir, jc)
                            crayon_ij = h.fd(h, _getdata(data), ir, jc)
                            break
                        end
                    end

                    # Check for cell alignment override.
                    for f in cell_alignment
                        aux = f(_getdata(data), ir, jc)

                        if aux ∈ [:l, :c, :r, :L, :C, :R]
                            alignment_ij = aux
                            break
                        end
                    end

                    # For Markdown cells, we will overwrite alignment and
                    # highlighters.
                    if isassigned(data,ir,jc) && (data[ir,jc] isa Markdown.MD)
                        alignment_ij = :l
                        crayon_ij = Crayon()
                    end
                end

                # Align the string to be printed.
                if length(data_str[i,j]) >= l
                    data_ij_str, data_ij_len = _str_aligned(data_str[i,j][l],
                                                            alignment_ij,
                                                            cols_width[j],
                                                            data_len[i,j][l])
                else
                    data_ij_str, data_ij_len = _str_aligned("",
                                                            alignment_ij,
                                                            cols_width[j])
                end

                # Print.
                data_ij_str  = " " * data_ij_str * " "
                data_ij_len += 2

                flp = j == num_printed_cols

                # If we have nothing more to print, then remove trailing spaces.
                if flp && (j ∉ vlines)
                    data_ij_str = string(rstrip(data_ij_str))
                    data_ij_len = textwidth(data_ij_str) + 1
                end

                _p!(screen, buf, crayon_ij, data_ij_str, false, data_ij_len)

                # Check if we need to draw a vertical line here.
                _pc!(j ∈ vlines, screen, buf, border_crayon, tf.column, "" ,
                     flp, 1, 0)

                _eol(screen) && break
            end

            _nl!(screen, buf)

            # Check if the screen is over.
            if _eos(screen, Δscreen_lines)
                # If we have only one line left, then we do not need to print
                # the continuation line.
                if (i+1 < num_printed_rows) ||
                    ( (i+1 == num_printed_rows) && (num_lines_in_row[i+1] > 1) ) ||
                    ( (i   == num_printed_rows) && (num_lines_in_row[i]   > l) )
                    draw_continuation_line = true
                    break
                end
            end
        end

        # Check if we must draw a horizontal line here.
        i != num_printed_rows && (i+!noheader) in hlines &&
            _draw_line!(screen, buf, body_hlines_format..., border_crayon,
                        cols_width, vlines)

        # Here we must check if the vertical size of the screen has been
        # reached. Notice that we must add 4 to account for the command line,
        # the continuation line, the bottom table line, and the last blank line.
        if draw_continuation_line
            _draw_continuation_row(screen, buf, tf, text_crayon, border_crayon,
                                   cols_width, vlines,
                                   continuation_row_alignment)
            break
        end
    end
end
