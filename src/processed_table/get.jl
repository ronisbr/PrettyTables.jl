# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to get the index of data in a `ProcessedTable`.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _get_cell_alignemnt(ptable::ProcessedTable, i::Int, j::Int)

Get the alignment of the `ptable` cell in `i`th row and `j`th column.
"""
function _get_cell_alignment(ptable::ProcessedTable, i::Int, j::Int)
    # Get the identification of the row and column.
    row_id = _get_row_id(ptable, i)
    column_id = _get_column_id(ptable, j)

    # Verify if we are at header.
    if (row_id == :__HEADER__) || (row_id == :__SUBHEADER__)
        if column_id == :__ORIGINAL_DATA__
            header_alignment_override = nothing

            # Get the cell index in the original table. Notice that there is no
            # filter for header rows. Hence, we just need to verify the column
            # here.
            jr = _get_data_column_index(ptable, j)

            # Search for alignment overrides in this cell.
            for f in ptable._header_cell_alignment
                header_alignment_override = f(ptable.header, i, jr)

                if _is_alignment_valid(header_alignment_override)
                    return header_alignment_override
                end
            end

            header_alignment = ptable._header_alignment isa Symbol ?
                ptable._header_alignment :
                ptable._header_alignment[jr]

            if (header_alignment == :s) || (header_alignment == :S)
                header_alignment = ptable._data_alignment isa Symbol ?
                    ptable._data_alignment :
                    ptable._data_alignment[jr]
            end

            return header_alignment
        else
            header_alignment = ptable._additional_column_header_alignment[j]

            if (header_alignment == :s) || (header_alignment == :S)
                header_alignment = ptable._additional_column_alignment[j]
            end

            return header_alignment
        end
    else
        if column_id == :__ORIGINAL_DATA__
            alignment_override = nothing

            # Get the cell index in the original table.
            ir = _get_data_row_index(ptable, i)
            jr = _get_data_column_index(ptable, j)

            # Search for alignment overrides in this cell.
            for f in ptable._data_cell_alignment
                alignment_override = f(_getdata(ptable.data), ir, jr)

                if _is_alignment_valid(alignment_override)
                    return alignment_override
                end
            end

            alignment = ptable._data_alignment isa Symbol ?
                ptable._data_alignment :
                ptable._data_alignment[jr]

            return alignment
        else
            return ptable._additional_column_alignment[j]
        end
    end
end

"""
    _get_column_alignment(ptable::ProcessedTable, j::Int)

Return the alignment of the `j`th column in `ptable`.
"""
function _get_column_alignment(ptable::ProcessedTable, j::Int)
    # Get the identification of the row and column.
    column_id = _get_column_id(ptable, j)

    # Verify if we are at header.
    if column_id == :__ORIGINAL_DATA__
        # In this case, we must find the column index in the original data.
        jr = _get_data_column_index(ptable, j)

        alignment = ptable._data_alignment isa Symbol ?
            ptable._data_alignment :
            ptable._data_alignment[jr]

        return alignment
    else
        return ptable._additional_column_alignment[j]
    end
end

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
            l = length(ptable._additional_header_columns[j])

            if i ≤ l
                return ptable._additional_header_columns[j][i]
            else
                return ""
            end
        else
            id = _get_data_row_index(ptable, i)
            return ptable._additional_data_columns[j][id]
        end
    else
        jd = _get_data_column_index(ptable, j)

        if i ≤ ptable._num_header_rows
            return ptable.header[i][jd]
        else
            id = _get_data_row_index(ptable, i)
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
    Δc = length(ptable._additional_data_columns)

    if ptable._id_columns !== nothing
        return ptable._id_columns[j - Δc]
    else
        return j - Δc
    end
end

"""
    _get_data_row_index(ptable::ProcessedTable, i::Int)

Get the index of the `i`th filtered row in `ptable`.
"""
function _get_data_row_index(ptable::ProcessedTable, i::Int)
    if ptable._id_rows !== nothing
        return ptable._id_rows[i - ptable._num_header_rows]
    else
        return i - ptable._num_header_rows
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
