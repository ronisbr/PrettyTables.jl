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
    return ptable._num_data_rows, ptable._num_data_columns
end

"""
    _filtered_data_size(ptable::ProcessedTable)

Return a tuple with the filtered data size.
"""
function _filtered_data_size(ptable::ProcessedTable)
    return ptable._num_filtered_rows, ptable._num_filtered_columns
end

"""
    _header_size(ptable::ProcessedTable)

Return a tuple with the header size.
"""
function _header_size(ptable::ProcessedTable)

    return ptable._num_header_rows, ptable._num_header_columns
end

"""
    _num_additional_columns(ptable::ProcessedTable)

Return the number of additional columns.
"""
function _num_additional_columns(ptable::ProcessedTable)
    return length(ptable._additional_data_columns)
end

"""
    _size(ptable::ProcessedTable)

Return a tuple with the current size of the table, considering the header,
filtered data, and the additional columns.
"""
function _size(ptable::ProcessedTable)
    total_columns =
        ptable._num_filtered_columns +
        length(ptable._additional_data_columns)

    total_rows = ptable._num_header_rows + ptable._num_filtered_rows

    return total_rows, total_columns
end
