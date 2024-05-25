## Description #############################################################################
#
# Functions related to cell alignment.
#
############################################################################################

# Apply the column alignment obtained from regex to the data after conversion to string.
function _apply_alignment_anchor_regex!(
    ptable::ProcessedTable,
    table_str::Matrix{Vector{String}},
    actual_column_width::Vector{Int},
    # Configurations.
    alignment_anchor_fallback::Symbol,
    alignment_anchor_fallback_override::Dict{Int, Symbol},
    alignment_anchor_regex::Dict{Int, T} where T<:AbstractVector{Regex},
    columns_width::Vector{Int},
    maximum_columns_width::Vector{Int},
    minimum_columns_width::Vector{Int}
)
    num_rendered_rows, num_rendered_columns = size(table_str)

    # If we have a key `0`, then it will be used to align all the columns.
    alignment_keys = sort(collect(keys(alignment_anchor_regex)))

    @inbounds for key in alignment_keys
        if key == 0
            regex = alignment_anchor_regex[0]
            column_vector = 1:num_rendered_columns

        else
            j = _get_table_column_index(ptable, key)
            isnothing(j) && continue
            j > num_rendered_columns && continue
            regex = alignment_anchor_regex[key]
            column_vector = j:j
        end

        for j in column_vector
            # We must not process a columns that is not part of the data, i.e., the row
            # labels or the row numbers.
            _get_column_id(ptable, j) !== :__ORIGINAL_DATA__ && continue

            # Store in which column we must align the match.
            alignment_column = 0

            jr = _get_data_column_index(ptable, j)

            # We need to pass through the entire row searching for matches to compute in
            # which column we need to align the matches.
            for i in 1:num_rendered_rows
                # We must not process a row that is a header.
                _get_row_id(ptable, i) != :__ORIGINAL_DATA__ && continue

                !isassigned(table_str, i, j) && continue
                _is_cell_alignment_overridden(ptable, i, j) && continue

                for l in 1:length(table_str[i, j])
                    line = table_str[i, j][l]

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
                        # If a match is not found, the alignment column depends on the user
                        # selection.

                        fallback = haskey(alignment_anchor_fallback_override, jr) ?
                            alignment_anchor_fallback_override[jr] :
                            alignment_anchor_fallback

                        if fallback == :c
                            line_len = textwidth(line)
                            alignment_column_i = cld(line_len, 2)

                        elseif fallback == :r
                            line_len = textwidth(line)
                            alignment_column_i = line_len + 1

                        else
                            alignment_column_i = 0
                        end
                    end

                    if alignment_column_i > alignment_column
                        alignment_column = alignment_column_i
                    end
                end
            end

            # Variable to store the largest width of a cell.
            largest_cell_width = 0

            # Now, we need to pass again applying the alignments.
            for i in 1:num_rendered_rows
                # We must not process a row that is a header.
                _get_row_id(ptable, i) != :__ORIGINAL_DATA__ && continue

                !isassigned(table_str, i, j) && continue
                _is_cell_alignment_overridden(ptable, i, j) && continue

                for l in 1:length(table_str[i, j])
                    line = table_str[i, j][l]

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
                        # If a match is not found, the alignment column depends on the user
                        # selection.

                        fallback = haskey(alignment_anchor_fallback_override, jr) ?
                            alignment_anchor_fallback_override[jr] :
                            alignment_anchor_fallback

                        if fallback == :c
                            line_len = textwidth(line)
                            pad = alignment_column - cld(line_len, 2)
                        elseif fallback == :r
                            line_len = textwidth(line)
                            pad = alignment_column - line_len - 1
                        else
                            pad = alignment_column
                        end
                    end

                    # Make sure `pad` is positive.
                    if pad < 0
                        pad = 0
                    end

                    table_str[i, j][l]  = " "^pad * line
                    line_len = textwidth(table_str[i, j][l])

                    if line_len > largest_cell_width
                        largest_cell_width = line_len
                    end
                end
            end

            # The third pass aligns the elements correctly. This is performed by adding
            # spaces to the right so that all the cells have the same width.
            for i in 1:num_rendered_rows
                # We must not process a row that is a header.
                _get_row_id(ptable, i) != :__ORIGINAL_DATA__ && continue

                !isassigned(table_str, i, j) && continue
                _is_cell_alignment_overridden(ptable, i, j) && continue

                for l in 1:length(table_str[i, j])
                    pad = largest_cell_width - textwidth(table_str[i, j][l])
                    pad < 0 && (pad = 0)
                    table_str[i, j][l] = table_str[i, j][l] * " "^pad
                end
            end

            # Since the alignemnt can change the column size, we need to recompute it
            # considering the user's configuration. Notice that the old value in
            # `cols_width` must be considered here because the header width is not taken
            # into account when calculating `largest_cell_width`.
            actual_column_width[j] = _update_column_width(
                actual_column_width[j],
                largest_cell_width,
                columns_width[jr],
                maximum_columns_width[jr],
                minimum_columns_width[jr]
            )
        end

        # If the key 0 is present, we should not process any other regex.
        # TODO: Can we allow this here?
        key == 0 && break
    end

    return nothing
end
