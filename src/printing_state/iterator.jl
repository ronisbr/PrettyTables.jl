## Description #############################################################################
#
# Functions related to the printing state iterations.
#
############################################################################################

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
        isempty(table_data.title) &&
            return _next(PrintingTableState(_TITLE, 0, 0, rs), table_data)

        if j == 0
            return :new_row, :table_header, PrintingTableState(ps, 1, j + 1, rs)
        elseif j == 1
            return :title, :table_header, PrintingTableState(ps, 1, j + 1, rs)
        else
            return :end_row, :table_header, PrintingTableState(_TITLE, 0, 0, rs)
        end
    end

    if ps < _SUBTITLE
        isempty(table_data.subtitle) &&
            return _next(PrintingTableState(_SUBTITLE, 0, 0, :column_labels), table_data)

        if j == 0
            return :new_row, :table_header, PrintingTableState(ps, 1, j + 1, rs)
        elseif j == 1
            return :subtitle, :table_header, PrintingTableState(ps, 1, j + 1, rs)
        else
            return :end_row, :table_header, PrintingTableState(_SUBTITLE, 0, 0, :column_labels)
        end
    end

    # == Column Labels and Table Body ======================================================

    if ps < _NEW_ROW
        return :new_row, rs, PrintingTableState(_NEW_ROW, i + 1, 0, rs)
    end

    if ps < _ROW_GROUP && (rs == :data) && !isnothing(table_data.row_group_labels)
        # TODO: Improve row group detection. Looping through all the possible options every
        # show seems slow.
        for g in table_data.row_group_labels
            g.first == i &&
                return :row_group_label, rs, PrintingTableState(_END_ROW_AFTER_GROUP - 1, i, 0, rs)
        end
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
        (!isnothing(table_data.row_labels) || !isnothing(table_data.summary_row_labels))

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
            :summary_row_cell
        end

        return action, rs, PrintingTableState(ps, i, j + 1, rs)
    end

    if ps < _CONTINUATION_COLUMN
        # Check if a continuation cell is necessary.
        if j >= max_j
            return _next(PrintingTableState(_CONTINUATION_COLUMN, i, 0, rs), table_data)
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
                if !isnothing(table_data.summary_rows)
                    return :end_row, rs, PrintingTableState(_NEW_ROW - 1, 0, 0, :summary_row)
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
            if !isnothing(table_data.summary_rows)
                return :end_row, rs, PrintingTableState(_NEW_ROW - 1, 0, 0, :summary_row)
            else
                return :end_row, rs, PrintingTableState(_END_ROW, 0, 0, :table_footer)
            end

        else
            i >= length(table_data.summary_rows) &&
                return :end_row, rs, PrintingTableState(_END_ROW, 0, 0, :table_footer)

            return :end_row, rs, PrintingTableState(_NEW_ROW - 1, i, 0, rs)
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
            return :new_row, :table_footer, PrintingTableState(ps, i + 1, j + 1, rs)
        elseif j == 1
            return :source_notes, :table_footer, PrintingTableState(ps, i, j + 1, rs)
        else
            return :end_row, :table_footer, PrintingTableState(_SOURCENOTES, i, 0, :end_printing)
        end
    end

    # == End Printing ======================================================================

    ps < _END_PRINTING &&
        return :end_printing, rs, PrintingTableState(_END_PRINTING - 1, 0, 0, :end_printing)

    # == Row Groups ========================================================================

    # We must have special states for new and end line actions after row groups since they
    # will provide different row numbering increase and state compared to the default ones.
    ps < _END_ROW_AFTER_GROUP &&
        return :end_row, rs, PrintingTableState(_END_ROW_AFTER_GROUP, i, 0, rs)

    ps < _NEW_ROW_AFTER_GROUP &&
        return :new_row, rs, PrintingTableState(_ROW_GROUP, i, 0, rs)
end

function _update_data_cell_indices(
    action::Symbol,
    row_section::Symbol,
    state::PrintingTableState,
    i::Int,
    j::Int
)
    if (action == :new_row) && (row_section != :continuation_row)
        i += 1
        j  = 0

    elseif (action ∈ (
        :row_number_vertical_continuation_cell,
        :row_label_vertical_continuation_cell,
        :row_label,
        :row_number
    ))
        j = 0

    elseif (action == :column_label) ||
        (action == :data) ||
        (action == :summary_row_cell) ||
        (action == :vertical_continuation_cell)
        j += 1

    elseif (action == :end_row) &&
        (row_section != state.row_section) &&
        (row_section != :continuation_row) &&
        (state.row_section != :continuation_row)
        i = j = 0
    end

    return i, j
end
