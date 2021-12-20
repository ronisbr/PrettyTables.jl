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
function _apply_alignment_anchor_regex!(
    data_str::Matrix{Vector{String}},
    cols_width::Vector{Int},
    id_cols::AbstractVector{Int},
    id_rows::AbstractVector{Int},
    Δc::Int,
    # Configurations.
    alignment_anchor_fallback::Symbol,
    alignment_anchor_fallback_override::Dict{Int, Symbol},
    alignment_anchor_regex::Dict{Int, T} where T<:AbstractVector{Regex},
    cell_alignment_override::Dict{Tuple{Int, Int}, Symbol},
    columns_width::Vector{Int},
    maximum_columns_width::Vector{Int},
    minimum_columns_width::Vector{Int}
)

    num_printed_rows, num_printed_cols = size(data_str)

    # If we have a key `0`, then it will be used to align all the columns.
    if haskey(alignment_anchor_regex, 0)
        max_id_cols    = maximum(id_cols)::Int
        alignment_keys = collect(1:max_id_cols)
        global_regex   = true
    else
        alignment_keys = sort(collect(keys(alignment_anchor_regex)))
        global_regex   = false
    end

    @inbounds for jc in alignment_keys
        j = findfirst(==(jc), id_cols)::Union{Nothing, Int}
        j === nothing && continue
        j += Δc

        # If `j` is larger than `num_printed_cols`, then we can stop the
        # processing, because the keys are ordered and anything larger than
        # `num_printed_cols` will not be printed.
        j > num_printed_cols && break

        regex = global_regex ? alignment_anchor_regex[0] : alignment_anchor_regex[jc]

        # Store in which column we must align the match.
        alignment_column = 0

        # We need to pass through the entire row searching for matches to
        # compute in which column we need to align the matches.
        for i in 1:num_printed_rows
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
                    alignment_column_i = textwidth(@views(line[1:first(m)]))
                else
                    # If a match is not found, then the alignment column
                    # depends on the user selection.

                    fallback = haskey(alignment_anchor_fallback_override, jc) ?
                        alignment_anchor_fallback_override[jc] :
                        alignment_anchor_fallback

                    if fallback == :c
                        data_ijl_len = textwidth(line)
                        alignment_column_i = cld(data_ijl_len, 2)
                    elseif fallback == :r
                        data_ijl_len = textwidth(line)
                        alignment_column_i = data_ijl_len + 1
                    else
                        alignment_column_i = 0
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
                    match_column_k = textwidth(@views(line[1:first(m)]))
                    pad = alignment_column - match_column_k
                else
                    # If a match is not found, then the alignment column
                    # depends on the user selection.

                    fallback = haskey(alignment_anchor_fallback_override, jc) ?
                        alignment_anchor_fallback_override[jc] :
                        alignment_anchor_fallback

                    if fallback == :c
                        data_ijl_len = textwidth(line)
                        pad = alignment_column - cld(data_ijl_len, 2)
                    elseif fallback == :r
                        data_ijl_len = textwidth(line)
                        pad = alignment_column - data_ijl_len - 1
                    else
                        pad = alignment_column
                    end
                end

                # Make sure `pad` is positive.
                pad < 0 && (pad = 0)

                data_str[i, j][l]  = " "^pad * line
                data_ijl_len = textwidth(data_str[i, j][l])

                if data_ijl_len > largest_cell_width
                    largest_cell_width = data_ijl_len
                end
            end
        end

        # The third pass aligns the elements correctly. This is performed by
        # adding spaces to the right so that all the cells have the same width.
        for i = 1:num_printed_rows
            !isassigned(data_str, i, j) && continue
            haskey(cell_alignment_override, (id_rows[i], jc)) && continue

            for l = 1:length(data_str[i, j])
                pad = largest_cell_width - textwidth(data_str[i, j][l])
                pad < 0 && (pad = 0)
                data_str[i, j][l] = data_str[i, j][l] * " "^pad
            end
        end

        # Since the alignemnt can change the column size, we need to recompute
        # it considering the user's configuration. Notice that the old value in
        # `cols_width` must be considered here because the header width is not
        # taken into account when calculating `largest_cell_width`.
        cols_width[j] = _update_column_width(
            cols_width[j],
            largest_cell_width,
            columns_width[jc],
            maximum_columns_width[jc],
            minimum_columns_width[jc]
        )
    end

    return nothing
end

# Compute a list of cells in which the alignment is overridden by the user.
function _compute_cell_alignment_override(
    data::Any,
    id_cols::AbstractVector{Int},
    id_rows::AbstractVector{Int},
    Δc::Int,
    num_printed_cols::Int,
    num_printed_rows::Int,
    # Configurations.
    cell_alignment::Ref{Any}
)
    # Dictionary with the cells in which the alignment is overridden.
    cell_alignment_override = Dict{Tuple{Int, Int}, Symbol}()

    for j = (1 + Δc):num_printed_cols
        jc = id_cols[j - Δc]

        for i = 1:num_printed_rows
            ir = id_rows[i]

            for f in cell_alignment.x
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
