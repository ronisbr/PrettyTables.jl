## Description #############################################################################
#
# Functions to compute the cell alignment of the current state.
#
############################################################################################

"""
    _current_cell_alignment(action::Symbol, state::PrintingTableState, table_data::TableData) -> Symbol

Return the alignment where the current cell specified by the `action` and the current
printing table `state` of `table_data`.
"""
function _current_cell_alignment(
    action::Symbol,
    state::PrintingTableState,
    table_data::TableData
)
    if (action == :title)
        return table_data.title_alignment

    elseif (action == :subtitle)
        return table_data.subtitle_alignment

    elseif (action == :row_number_label) || (action == :row_number)
        return table_data.row_number_column_alignment

    elseif action == :summary_row_number
        return table_data.row_number_column_alignment

    elseif (action == :stubhead_label) || (action == :row_label) || (action == :summary_row_label)
        return table_data.row_label_alignment

    elseif action == :column_label
        a = table_data.column_label_alignment
        if a isa Symbol
            return a
        else
            return a[state.j]
        end

    elseif action == :row_group_label
        return table_data.row_group_label_alignment

    elseif (action == :data) || (action == :summary_row_cell)
        # First, we check if we have a special cell alignment.
        if (action == :data) && !isnothing(table_data.cell_alignment)
            for f in table_data.cell_alignment
                fa = f(_get_data(table_data.data), state.i, state.j)::Union{Nothing, Symbol}
                !isnothing(fa) && return fa
            end
        end

        a = table_data.data_alignment
        if a isa Symbol
            return a
        else
            return a[state.j]
        end

    elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
        # Check if the continuation cell has a custom alignment. Otherwise, use the current
        # column alignment.
        !isnothing(table_data.continuation_row_alignment) &&
            return table_data.continuation_row_alignment

        new_action = if action == :row_number_vertical_continuation_cell
            :row_number
        elseif action == :row_label_vertical_continuation_cell
            :row_label
        else
            :data
        end

        return _current_cell_alignment(new_action, state, table_data)

    elseif action == :footnote
        return table_data.footnote_alignment

    elseif action == :source_notes
        return table_data.source_note_alignment

    elseif action == :empty_cell
        return :r

    else
        throw(ArgumentError("Invalid action found: `$action`!"))
    end
end

