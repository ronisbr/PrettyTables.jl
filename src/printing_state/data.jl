## Description #############################################################################
#
# Functions to retrieve the current cell data.
#
############################################################################################

"""
    _get_data_cell(data, i::Int, j::Int) -> Any

Return the normalized data cell at `(i, j)`, or `_UNDEFINED_CELL` if it is unassigned.
"""
function _get_data_cell(data::Union{AbstractVecOrMat, ColumnTable}, i::Int, j::Int)
    return isassigned(data, i, j) ? getindex(data, i, j) : _UNDEFINED_CELL
end

"""
    _get_data_cell(data::RowTable, i::Int, j::Int) -> Any

Return a row-table cell using one retrieval, mapping an undefined reference to the undefined
cell marker.
"""
function _get_data_cell(data::RowTable, i::Int, j::Int)
    try
        return getindex(data, i, j)
    catch e
        e isa UndefRefError && return _UNDEFINED_CELL
        rethrow()
    end
end

"""
    _current_cell(action::Symbol, state::PrintingTableState, table_data::TableData) -> Any

Return the current data specified by the `action` and the current printing table `state` of
`table_data`.
"""
function _current_cell(
    action::Symbol,
    state::PrintingTableState,
    table_data::TableData
)
    if action == :title
        return table_data.title

    elseif action == :subtitle
        return table_data.subtitle

    elseif action == :row_number_label
        # We should not print anything if we are not at the first line of column labels.
        if state.i == 1
            return table_data.row_number_column_label
        else
            return ""
        end

    elseif action == :row_number
        return state.i - 1 + table_data.first_row_index

    elseif action == :summary_row_number
        return ""

    elseif action == :stubhead_label
        # We should not print anything if we are not at the first line of column labels.
        if state.i == 1
            return table_data.stubhead_label
        else
            return ""
        end

    elseif action == :row_group_label
        for g in table_data.row_group_labels
            g.first == state.i && return g.second
        end

        return ""

    elseif action == :row_label
        rl = table_data.row_labels
        return isnothing(rl) ? "" : table_data.row_labels[state.i - 1 + begin]

    elseif action == :summary_row_label
        return table_data.summary_row_labels[state.i - 1 + begin]

    elseif action == :column_label
        # Check if this cell must be merged or if is is part of a merged cell.
        if !isnothing(table_data.merge_column_label_cells)
            for mc in table_data.merge_column_label_cells
                if (mc.i == state.i)
                    if (mc.j == state.j)
                        return mc
                    elseif (mc.j <= state.j <= mc.j + mc.column_span - 1)
                        return _IGNORE_CELL
                    end
                end
            end
        end

        return table_data.column_labels[state.i - 1 + begin][state.j - 1 + begin]

    elseif action == :data
        i₀ = table_data.first_row_index
        j₀ = table_data.first_column_index

        cell_data = _get_data_cell(
            table_data.data,
            state.i - 1 + i₀,
            state.j - 1 + j₀
        )

        if !isnothing(table_data.formatters)
            for f in table_data.formatters
                cell_data = f(cell_data, state.i, state.j)
            end
        end

        return cell_data

    elseif action == :summary_row_cell
        f = table_data.summary_rows[state.i - 1 + begin]

        col = @views table_data.data[:, state.j]

        applicable(f, col) && return f(col)

        return f(table_data.data, state.j)

    elseif action == :footnote
        return table_data.footnotes[state.i - 1 + begin].second

    elseif action == :source_notes
        return table_data.source_notes

    elseif action == :empty_cell
        return ""

    else
        throw(ArgumentError("Invalid action found: `$action`!"))
    end
end

"""
    _current_cell_footnotes(
        table_data::TableData,
        cell_type::Symbol,
        i::Int,
        j::Int
    ) -> Union{Nothing, Vector{Int}}

Return the ordered footnote indices for the `cell_type` at `(i, j)`, or `nothing` if there
are no matches.
"""
function _current_cell_footnotes(table_data::TableData, cell_type::Symbol, i::Int, j::Int)
    isnothing(table_data.footnotes) && return nothing

    current_footnotes = nothing

    for k in 1:length(table_data.footnotes)
        f, _ = table_data.footnotes[k - 1 + begin]
        ct, fi, fj = f

        if (ct == cell_type) && (fi == i)
            if (
                # Cell types that only requires testing the row index.
                (ct ∈ (:title, :subtitle, :row_number, :row_label, :summary_row_number)) ||
                (fj == j)
            )
                if isnothing(current_footnotes)
                    current_footnotes = Int[k]
                else
                    push!(current_footnotes, k)
                end
            end
        end
    end

    return current_footnotes
end
