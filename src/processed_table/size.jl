## Description #############################################################################
#
# Functions to compute sizes related to `ProcessedTable`.
#
############################################################################################

"""
    _data_size(ptable::ProcessedTable) -> Int, Int

Return a tuple with the original data size.
"""
function _data_size(ptable::ProcessedTable)
    return ptable._num_data_rows, ptable._num_data_columns
end

"""
    _header_size(ptable::ProcessedTable) -> Int, Int

Return a tuple with the header size.
"""
function _header_size(ptable::ProcessedTable)

    return ptable._num_header_rows, ptable._num_header_columns
end

"""
    _num_additional_columns(ptable::ProcessedTable) -> Int

Return the number of additional columns.
"""
function _num_additional_columns(ptable::ProcessedTable)
    return length(ptable._additional_data_columns)
end

"""
    _size(ptable::ProcessedTable) -> Int, Int

Return a tuple with the current size of the table, considering the header, and the
additional columns, but also the maximum number of rows and columns that user wants.
"""
function _size(ptable::ProcessedTable)
    total_columns = ptable._max_num_of_columns > 0 ?
        ptable._max_num_of_columns :
        ptable._num_data_columns

    total_columns += length(ptable._additional_data_columns)

    total_rows = ptable._max_num_of_rows > 0 ?
        ptable._max_num_of_rows :
        ptable._num_data_rows

    total_rows += ptable._num_header_rows

    return total_rows, total_columns
end

"""
    _total_size(ptable::ProcessedTable) -> Int

Return the total table size neglecting the options `max_num_of_columns` and
`max_num_of_rows`.
"""
function _total_size(ptable::ProcessedTable)
    total_columns = ptable._num_data_columns + length(ptable._additional_data_columns)
    total_rows = ptable._num_data_rows + ptable._num_header_rows
    return total_rows, total_columns
end
