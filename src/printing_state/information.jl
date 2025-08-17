## Description #############################################################################
#
# Functions to retrieve table information.
#
############################################################################################

"""
    _column_label_limits(table_data::TableData, i::Int, j::Int) -> Tuple{Int, Int}

Return the limits of the column label cell at `(i, j)` in `table_data`. If the cell is not
merged, the limits are just `(j, j)`. If the cell is merged, the limits are the start and
end of the merged cell, which is defined by the `merge_column_label_cells` field of
`table_data`.
"""
function _column_label_limits(table_data::TableData, i::Int, j::Int)
    isnothing(table_data.merge_column_label_cells) && return j, j

    # Check if we are in a merged column.
    for mc in table_data.merge_column_label_cells
        if mc.i == i && (mc.j <= j <= mc.j + mc.column_span - 1)
            return mc.j, mc.j + mc.column_span - 1
        end
    end

    # If we are not in a merged column, the limits are just the cell itself.
    return j, j
end

"""
    _has_footnotes(table_data::TableData) -> Bool

Return whether `table_data` has footnotes.
"""
function _has_footnotes(table_data::TableData)
    return !isnothing(table_data.footnotes)
end

"""
    _has_merged_cells(table_data::TableData, i::Int) -> Bool

Return whether `table_data` has merged cells in line `i`.
"""
function _has_merged_cells(table_data::TableData, i::Int)
    isnothing(table_data.merge_column_label_cells) && return false

    for mc in table_data.merge_column_label_cells
        mc.i == i && return true
    end

    return false
end

"""
    _has_row_group_labels(table_data::TableData)

Return whether `table_data` has row group lables.
"""
function _has_row_group_labels(table_data::TableData)
    return !isnothing(table_data.row_group_labels)
end

"""
    _has_row_labels(table_data::TableData) -> Bool

Return whether `table_data` has row labels.
"""
function _has_row_labels(table_data::TableData)
    return !isnothing(table_data.row_labels) || _has_summary_rows(table_data)
end

"""
    _has_summary_rows(table_data::TableData) -> Bool

Return whether `table_data` has summary rows.
"""
_has_summary_rows(table_data::TableData) = !isnothing(table_data.summary_rows)

"""
    _is_horizontally_cropped(table_data::TableData) -> Bool

Return whether `table_data` is horizontally cropped, meaning that a continuation column must
be printed.
"""
function _is_horizontally_cropped(table_data::TableData)
    return table_data.maximum_number_of_columns > 0 ?
        table_data.num_columns > table_data.maximum_number_of_columns :
        false
end

"""
    _is_column_label_cell_merged(table_data::TableData, i::Int, j::Int) -> Bool

Return whether the cell at `(i, j)` is a merged column label cell.
"""
function _is_column_label_cell_merged(table_data::TableData, i::Int, j::Int)
    j₀, j₁ = _column_label_limits(table_data, i, j)
    return j₀ != j₁
end

"""
    _is_vertically_cropped(table_data::TableData) -> Bool

Return whether `table_data` is vertically cropped, meaning that a continuation row must be
printed.
"""
function _is_vertically_cropped(table_data::TableData)
    return table_data.maximum_number_of_rows > 0 ?
        table_data.num_rows > table_data.maximum_number_of_rows :
        false
end

"""
    _number_of_printed_columns(table_data::TableData) -> Int

Return the number of printed columns in `table_data`, which includes the continuation row.
"""
function _number_of_printed_columns(table_data::TableData)
    data_columns = table_data.maximum_number_of_columns >= 0 ?
        # If we are cropping the table, we have one additional column for the continuation
        # characters.
        min(table_data.maximum_number_of_columns + 1, table_data.num_columns) :
        table_data.num_columns

    total_columns =
        data_columns +
        table_data.show_row_number_column +
        (!isnothing(table_data.row_labels) || !isnothing(table_data.summary_row_labels))

    return total_columns
end

"""
    _number_of_printed_data_columns(table_data::TableData) -> Int

Return the number of printed data columns.
"""
function _number_of_printed_data_columns(table_data::TableData)
    data_columns = table_data.maximum_number_of_columns > 0 ?
        min(table_data.maximum_number_of_columns, table_data.num_columns) :
        table_data.num_columns

    return data_columns
end

"""
    _number_of_printed_data_rows(table_data::TableData) -> Int

Return the number of printed data rows.
"""
function _number_of_printed_data_rows(table_data::TableData)
    data_rows = table_data.maximum_number_of_rows >= 0 ?
        min(table_data.maximum_number_of_rows, table_data.num_rows) :
        table_data.num_rows

    return data_rows
end

"""
    _print_row_group_label(table_data::TableData, i::Int) -> Bool

Return whether we must print a row group label of `table_data` in line `i`.
"""
function _print_row_group_label(table_data::TableData, i::Int)
    !_has_row_group_labels(table_data) && return false

    for rg in table_data.row_group_labels
        first(rg) == i && return true
    end

    return false
end
