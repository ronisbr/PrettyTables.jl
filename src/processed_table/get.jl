# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to get the index of data in a `ProcessedTable`.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _get_column_id(ptable::ProcessedTable, j::Int)

Return the identification symbol of the column `j` of `ptable`. If the column is
from the original data, then `:__ORIGINAL_DATA__` is returned.
"""
function _get_column_id(ptable::ProcessedTable, j::Int)
    Δc = length(ptable._additional_data_columns)

    # Check if we are in the additional columns.
    if j ≤ Δc
        return ptable._additional_column_id[j]
    else
        return :__ORIGINAL_DATA__
    end
end

"""
    _get_element(ptable::ProcessedTable, i::Int, j::Int)

Get the element `(i, j)` if `ptable`. This function always considers the
additional columns and the header.
"""
function _get_element(ptable::ProcessedTable, i::Int, j::Int)
    Δc = length(ptable._additional_data_columns)

    # Check if we need to return an additional column or the real data.
    if j ≤ Δc
        if i ≤ ptable._num_header_rows
            return ptable._additional_header_columns[j][i]
        else
            id = _get_data_row_index(ptable, i - ptable._num_header_rows)
            return ptable._additional_data_columns[j][id]
        end
    else
        jd = _get_data_column_index(ptable, j - Δc)

        if i ≤ ptable._num_header_rows
            return ptable.header[i][jd]
        else
            id = _get_data_row_index(ptable, i - ptable._num_header_rows)
            return ptable.data[id, jd]
        end
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

"""
    _get_row_id(ptable::ProcessedTable, j::Int)

Return the identification symbol of the row `i` of `ptable`. If the row is part
of the header, then it returns `:__HEADER__:` or `:__SUBHEADER__`, otherwise it
returns `:__ORIGINAL_DATA__` because we do not have the functionality to add new
rows yet.
"""
function _get_row_id(ptable::ProcessedTable, j::Int)
    # Check if we are in the header columns.
    if j ≤ ptable._num_header_rows
        if j == 1
            return :__HEADER__
        else
            return :__SUBHEADER__
        end
    else
        return :__ORIGINAL_DATA__
    end
end
