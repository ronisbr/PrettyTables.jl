# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to cell alignment.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Apply the column alignment obtained from regex to the data after conversion to
# string.
function _apply_alignment_anchor_regex!(data_str::Matrix{Vector{String}},
                                        data_len::Matrix{Vector{Int}},
                                        cols_width::Vector{Int},
                                        alignment::Vector{Symbol},
                                        id_cols::Vector{Int},
                                        id_rows::Vector{Int},
                                        Δc::Int,
                                        # Configurations.
                                        alignment_anchor_fallback::Symbol,
                                        alignment_anchor_fallback_override::Dict{Int, Symbol},
                                        alignment_anchor_regex::Dict{Int, T} where T<:AbstractVector{Regex},
                                        cell_alignment_override::Dict{Tuple{Int, Int}, Symbol},
                                        fixed_col_width::Vector{Bool},
                                        maximum_columns_width::Vector{Int})

    num_printed_rows, ~ = size(data_str)

    @inbounds for jc in keys(alignment_anchor_regex)
        j = findfirst(x->x == jc, id_cols)
        j === nothing && continue
        j += Δc
        regex = alignment_anchor_regex[jc]

        # Store in which column we must align the match.
        alignment_column = 0

        # We need to pass through the entire row searching for matches to
        # compute in which column we need to align the matches.
        for i = 1:num_printed_rows
            !isassigned(data_str, i, j) && continue
            haskey(cell_alignment_override, (id_rows[i], jc)) && continue

            for l = 1:length(data_str[i, j])
                line = data_str[i, j][l]

                m = nothing

                for r in regex
                    m_r = findfirst(r, line)
                    if m_r !== nothing
                        m = m_r
                        break
                    end
                end

                if m !== nothing
                    alignment_column_i = first(m)
                else
                    # If a match is not found, then the alignment column
                    # depends on the user selection.

                    fallback = haskey(alignment_anchor_fallback_override, jc) ?
                        alignment_anchor_fallback_override[jc] :
                        alignment_anchor_fallback

                    if fallback == :c
                        alignment_column_i = div(data_len[i, j][l], 2)
                    elseif fallback == :r
                        alignment_column_i = data_len[i, j][l]
                    else
                        alignment_column_i = 1
                    end
                end

                alignment_column_i > alignment_column &&
                    (alignment_column = alignment_column_i)
            end
        end

        # Variable to store the largest width of a cell.
        largest_cell_width = 0

        # Now, we need to pass again applying the alignments.
        for i = 1:num_printed_rows
            !isassigned(data_str, i, j) && continue
            haskey(cell_alignment_override, (id_rows[i], jc)) && continue

            for l = 1:length(data_str[i, j])
                line = data_str[i, j][l]

                m = nothing

                for r in regex
                    m_r = findfirst(r, line)
                    if m_r !== nothing
                        m = m_r
                        break
                    end
                end

                if m !== nothing
                    match_column_k = first(m)
                    pad = alignment_column - match_column_k
                else
                    # If a match is not found, then the alignment column
                    # depends on the user selection.

                    fallback = haskey(alignment_anchor_fallback_override, jc) ?
                        alignment_anchor_fallback_override[jc] :
                        alignment_anchor_fallback

                    if fallback == :c
                        pad = alignment_column - div(data_len[i, j][l], 2)
                    elseif fallback == :r
                        pad = alignment_column - data_len[i, j][l]
                    else
                        pad = alignment_column - 1
                    end
                end

                # Make sure `pad` is positive.
                pad < 0 && (pad = 0)

                data_str[i, j][l]  = " "^pad * line
                data_len[i, j][l] += pad

                if data_len[i, j][l] > largest_cell_width
                    largest_cell_width = data_len[i, j][l]
                end
            end
        end

        # The third pass aligns the elements correctly. This is performed by
        # adding spaces to the right so that all the cells have the same width.
        for i = 1:num_printed_rows
            !isassigned(data_str, i, j) && continue
            haskey(cell_alignment_override, (id_rows[i], jc)) && continue

            for l = 1:length(data_str[i, j])
                pad = largest_cell_width - data_len[i, j][l]
                pad < 0 && (pad = 0)
                data_str[i, j][l] = data_str[i, j][l] * " "^pad
                data_len[i, j][l] = largest_cell_width
            end
        end

        # Check if we need to replace the column width.
        if !fixed_col_width[jc]
            cols_width[j] < largest_cell_width &&
                (cols_width[j] = largest_cell_width)

            # Make sure that the maximum column width is respected.
            if maximum_columns_width[jc] > 0 &&
                maximum_columns_width[jc] < cols_width[j]
                cols_width[j] = maximum_columns_width[jc]
            end
        end
    end

    return nothing
end

# Compute a list of cells in which the alignment is overridden by the user.
function _compute_cell_alignment_override(data::Any,
                                          id_cols::Vector{Int},
                                          id_rows::Vector{Int},
                                          Δc::Int,
                                          num_printed_cols::Int,
                                          num_printed_rows::Int,
                                          # Configurations.
                                          cell_alignment::Tuple)

    # Dictionary with the cells in which the alignment is overridden.
    cell_alignment_override = Dict{Tuple{Int, Int}, Symbol}()

    for j = (1 + Δc):num_printed_cols
        jc = id_cols[j - Δc]

        for i = 1:num_printed_rows
            ir = id_rows[i]

            for f in cell_alignment
                aux = f(_getdata(data), ir, jc)

                if (aux == :l) || (aux == :c) || (aux == :r) ||
                   (aux == :L) || (aux == :C) || (aux == :R)
                    cell_alignment_override[(ir, jc)] = aux
                end
            end
        end
    end

    return cell_alignment_override
end
