# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to get the index of data in a `ProcessedTable`.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _get_element(ptable::ProcessedTable, i::Int, j::Int)

Get the element `(i, j)` if `ptable`. This function always considers the
additional columns.
"""
function _get_element(ptable::ProcessedTable, i::Int, j::Int)
    Δc = length(ptable._additional_data_columns)

    # Check if we need to return an additional column or the real data.
    if j ≤ Δc
        id = _get_data_row_index(ptable, i)
        return ptable._additional_data_columns[j][id]
    else
        id = _get_data_row_index(ptable, i)
        jd = _get_data_column_index(ptable, j - Δc)
        return ptable.data[id, jd]
    end
end

"""
    _get_header_element(ptable::ProcessedTable, j::Int)

Get the `j`th header element in `ptable`. This function always considers the
additional columns.
"""
function _get_header_element(ptable::ProcessedTable, j::Int)
    Δc = length(ptable._additional_data_columns)

    # Check if we need to return an additional column or the real data.
    if j ≤ Δc
        return ptable._additional_header_columns[j]
    else
        jd = _get_data_column_index(ptable, j - Δc)
        return ptable.header[jd]
    end
end

"""
    _get_data_column_index(ptable::ProcessedTable, j::Int)

Get the index of the `j`th filtered column in `ptable`.
"""
function _get_data_column_index(ptable::ProcessedTable, j::Int)
    if ptable._id_columns !== nothing
        return ptable._id_columns[j]
    else
        return j
    end
end

"""
    _get_data_row_index(ptable::ProcessedTable, i::Int)

Get the index of the `i`th filtered row in `ptable`.
"""
function _get_data_row_index(ptable::ProcessedTable, i::Int)
    if ptable._id_rows !== nothing
        return ptable._id_rows[i]
    else
        return i
    end
end
