# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to compute sizes related to `ProcessedTable`.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _data_size(ptable::ProcessedTable)

Return a tuple with the original data size.
"""
function _data_size(ptable::ProcessedTable)
    return size(ptable.data)
end

"""
    _filtered_data_size(ptable::ProcessedTable)

Return a tuple with the filtered data size.
"""
function _filtered_data_size(ptable::ProcessedTable)

    return ptable._num_filtered_rows, ptable._num_filtered_columns
end

"""
    _size(ptable::ProcessedTable)

Return a tuple with the current size of the table, considering the filtered data
plus the additional columns.
"""
function _size(ptable::ProcessedTable)
    return ptable._num_filtered_rows,
        ptable._num_filtered_columns + length(ptable._additional_data_columns)
end
