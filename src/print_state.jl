## Description #############################################################################
#
# Function to handle the state-machine to print the table.
#
############################################################################################

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
    if action == :row_number_label
        # We should not print anything if we are not at the first line of column labels.
        if state.i == 1
            return table_data.row_number_column_label
        else
            return ""
        end
    elseif action == :row_number
        return state.i
    elseif action == :summary_row_number
        return state.i
    elseif action == :stubhead_label
        # We should not print anything if we are not at the first line of column labels.
        if state.i == 1
            return table_data.stubhead_label
        else
            return ""
        end
    elseif action == :row_label
        rl = table_data.row_labels
        return isnothing(rl) ? "" : table_data.row_labels[state.i]
    elseif action == :summary_row_label
        return table_data.summary_row_label
    elseif action == :column_label
        return table_data.column_labels[state.i][state.j]
    elseif action == :data
        cell_data = table_data.data[state.i, state.j]

        if !isnothing(table_data.formatters)
            for f in table_data.formatters
                cell_data = f(cell_data, state.i, state.j)
            end
        end

        return cell_data

    elseif action == :summary_cell
        return table_data.summary_cell(table_data.data, state.j)

    elseif action == :footnote
        return table_data.footnotes[state.i].second

    elseif action == :source_notes
        return table_data.source_notes

    else
        throw(ArgumentError("Invalid action found: `$action`!"))
    end
end

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
    if (action == :row_number_label) || (action == :row_number)
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
    elseif (action == :data) || (action == :summary_cell)
        # First, we check if we have a special cell alignment.
        if !isnothing(table_data.cell_alignment)
            for f in table_data.cell_alignment
                fa = f(_getdata(table_data.data), state.i, state.j)::Union{Nothing, Symbol}
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
        return :l

    elseif action == :source_notes
        return :l

    else
        throw(ArgumentError("Invalid action found: `$action`!"))
    end
end

"""
    _current_cell_footnotes(table_data::TableData, cell_type::Symbol, i::Int, j::Int) -> Union{Nothing, Vector{Int}}

Return an array of integers with the footnotes defined in `table_data` for the `cell_type`
at position `(i, j)`.
"""
function _current_cell_footnotes(table_data::TableData, cell_type::Symbol, i::Int, j::Int)
    isnothing(table_data.footnotes) && return nothing

    current_footnotes = Int[]

    for k in 1:length(table_data.footnotes)
        f, _ = table_data.footnotes[k - 1 + begin]
        ct, fi, fj = f

        if ct == cell_type
            if (
                # Cell types that only requires testing the row index.
                ((ct ∈ (:row_number, :row_label, :summary_row_number)) && (fi == i)) ||
                # Cell types that only requires testing the column index.
                ((ct == :summary_cell) && (fj == j)) ||
                ((fi == i) && (fj == j))
            )
                push!(current_footnotes, k)
            end
        end
    end

    return current_footnotes
end

"""
    _next(state::PrintingTableState, table_data::TableData) -> Union{Symbol, Nothing}, PrintingTableState

Return the action the back end must perform and the new print table state given the current
`state` and the `table_data`.
"""
function _next(state::PrintingTableState, table_data::TableData)
    ps = state.state
    rs = state.row_section

    i     = state.i
    j     = state.j
    max_i = table_data.num_rows
    max_j = table_data.num_columns

    # == Table Header ======================================================================

    if ps < _TITLE
        if !isempty(table_data.title)
            return :title, :table_header, PrintingTableState(_TITLE, 0, 0, rs)
        end
    end

    if ps < _SUBTITLE
        if !isempty(table_data.subtitle)
            return :subtitle, :table_header, PrintingTableState(_SUBTITLE, 0, 0, rs)
        end
    end

    # == Column Labels and Table Body ======================================================

    if ps < _NEW_ROW
        return :new_row, rs, PrintingTableState(_NEW_ROW, i + 1, 0, rs)
    end

    if ps < _ROW_NUMBER_COLUMN && table_data.show_row_number_column
        # TODO: Check if the user wants the row number.
        action = if rs == :column_labels
            :row_number_label
        elseif rs == :data
            :row_number
        elseif rs == :continuation_row
            :row_number_vertical_continuation_cell
        else
            :summary_row_number
        end

        return action, rs, PrintingTableState(_ROW_NUMBER_COLUMN, i, 0, rs)
    end

    if (ps < _ROW_LABEL_COLUMN) &&
        (!isnothing(table_data.row_labels) || !isempty(table_data.summary_row_label))

        action = if rs == :column_labels
            :stubhead_label
        elseif rs == :data
            :row_label
        elseif rs == :continuation_row
            :row_label_vertical_continuation_cell
        else
            :summary_row_label
        end

        return action, rs, PrintingTableState(_ROW_LABEL_COLUMN, i, 0, rs)
    end

    if ps < _DATA
        mc = table_data.maximum_number_of_columns

        # Check if we reached the maximum number of columns or the end of line.
        if ((mc > 0) && (j >= mc)) || (j >= max_j)
            return _next(PrintingTableState(_DATA, i, j, rs), table_data)
        end

        action = if rs == :column_labels
            :column_label
        elseif rs == :data
            :data
        elseif rs == :continuation_row
            :vertical_continuation_cell
        else
            :summary_cell
        end

        return action, rs, PrintingTableState(ps, i, j + 1, rs)
    end

    if ps < _CONTINUATION_COLUMN
        # Check if a continuation cell is necessary.
        if (j >= max_j)
            return _next(PrintingTableState(_CONTINUATION_COLUMN, i, j, rs), table_data)
        else
            mr = table_data.maximum_number_of_rows

            action = rs == :continuation_row ?
                :diagonal_continuation_cell :
                :horizontal_continuation_cell

            return action, rs, PrintingTableState(_CONTINUATION_COLUMN, i, 0, rs)
        end
    end

    if ps < _END_ROW
        if rs == :column_labels
            num_column_labels = length(table_data.column_labels)

            if i >= num_column_labels
                # If we reached the number of column labels, we must go to the data.
                return :end_row, rs, PrintingTableState(_NEW_ROW - 1, 0, 0, :data)
            else
                # Otherwise, print the next line with column labels.
                return :end_row, rs, PrintingTableState(_NEW_ROW - 1, i, 0, rs)
            end

        elseif rs == :data
            mr = table_data.maximum_number_of_rows

            cont_row = if (mr > 0) && (mr < max_i)
                if table_data.vertical_crop_mode == :bottom
                    i >= mr
                else
                    i == div(mr, 2, RoundUp)
                end
            else
                false
            end

            if cont_row
                # The user limited the number of rows and we printed the requested number.
                return :end_row, rs, PrintingTableState(_NEW_ROW - 1, i, 0, :continuation_row)

            elseif i >= max_i
                # If we reached the number of data lines, we must go to the summary row if
                # the user wants it.
                if !isnothing(table_data.summary_cell)
                    return :end_row, rs, PrintingTableState(_NEW_ROW - 1, i, 0, :summary_row)
                else
                    return :end_row, rs, PrintingTableState(_END_ROW, 0, 0, :table_footer)
                end
            else
                # Otherwise, print the next data line.
                return :end_row, rs, PrintingTableState(_NEW_ROW - 1, i, 0, rs)
            end

        elseif rs == :continuation_row
            # Treat the case where we must perform a middle cropping.
            if table_data.vertical_crop_mode == :middle
                mr = table_data.maximum_number_of_rows
                next_i = max_i - (mr - div(mr, 2, RoundUp)) + 1

                # Check if we have more rows to be printed.
                next_i <= max_i &&
                    return :end_row, rs, PrintingTableState(_NEW_ROW - 1, next_i - 1, 0, :data)

                # If there is no more rows to be printed, we can treat as we are in a bottom
                # cropping.
            end

            # After the continuation row, we must check if we need to print the summary
            # cell.
            if !isnothing(table_data.summary_cell)
                return :end_row, rs, PrintingTableState(_NEW_ROW - 1, max_i, 0, :summary_row)
            else
                return :end_row, rs, PrintingTableState(_END_ROW, 0, 0, :table_footer)
            end

        else
            # We support only one data line. Hence, we must move to the table footer.
            return :end_row, rs, PrintingTableState(_END_ROW, 0, 0, :table_footer)
        end
    end

    # ==  Table Footer =====================================================================

    if ps < _FOOTNOTES && !isnothing(table_data.footnotes)
        if j == 0
            i >= length(table_data.footnotes) &&
                return _next(PrintingTableState(_FOOTNOTES, 0, 0, rs), table_data)

            return :new_row, :table_footer, PrintingTableState(ps, i + 1, j + 1, rs)
        elseif j == 1
            return :footnote, :table_footer, PrintingTableState(ps, i, j + 1, rs)
        else
            return :end_row, :table_footer, PrintingTableState(ps, i, 0, rs)
        end
    end

    if ps < _SOURCENOTES && !isempty(table_data.source_notes)
        if j == 0
            return :new_row, :table_footer, PrintingTableState(ps, i, j + 1, rs)
        elseif j == 1
            return :source_notes, :table_footer, PrintingTableState(ps, i, j + 1, rs)
        else
            return :end_row, :table_footer, PrintingTableState(_SOURCENOTES, i, 0, :end_printing)
        end
    end

    return :end_printing, rs, PrintingTableState(_END_PRINTING, 0, 0, :end_printing)
end

"""
    _number_of_printed_columns(table_data::TableData) -> Int

Return the number of printed columns in `table_data`.
"""
function _number_of_printed_columns(table_data::TableData)
    data_columns = table_data.maximum_number_of_columns > 0 ?
        # If we are cropping the table, we have one additional column for the continuation
        # characters.
        min(table_data.maximum_number_of_columns + 1, table_data.num_columns) :
        table_data.num_columns

    total_columns =
        data_columns +
        table_data.show_row_number_column +
        !isnothing(table_data.row_labels)

    return total_columns
end
