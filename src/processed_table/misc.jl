# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Miscellaneous functions related to the processed tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function _is_alignment_valid(alignment::Symbol)
    return (alignment == :l) || (alignment == :c) || (alignment == :r) ||
           (alignment == :L) || (alignment == :C) || (alignment == :R)
end

_is_alignment_valid(alignment) = false

"""
    _is_cell_alignment_overridden(ptable::ProcessedTable, i::Int, j::Int)

Return `true` is the alignment of the cell `(i, j)` is overridden using the
keyword option `cell_alignment`.
"""
function _is_cell_alignment_overridden(ptable::ProcessedTable, i::Int, j::Int)

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
                    return true
                end
            end
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
                    return true
                end
            end
        end
    end

    return false
end
