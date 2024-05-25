## Description #############################################################################
#
# Miscellaneous functions related to the processed tables.
#
############################################################################################

# Return `true` if the `alignment` is valid. Otherwise, return `false`.
function _is_alignment_valid(alignment::Symbol)
    return (alignment == :l) || (alignment == :c) || (alignment == :r) ||
           (alignment == :L) || (alignment == :C) || (alignment == :R)
end

_is_alignment_valid(alignment) = false

"""
    _is_cell_alignment_overridden(ptable::ProcessedTable, i::Int, j::Int) -> Bool

Return `true` is the alignment of the cell `(i, j)` is overridden using the keyword option
`cell_alignment`.
"""
function _is_cell_alignment_overridden(ptable::ProcessedTable, i::Int, j::Int)

    # Get the identification of the row and column.
    row_id = _get_row_id(ptable, i)
    column_id = _get_column_id(ptable, j)

    # Verify if we are at header.
    if (row_id == :__HEADER__) || (row_id == :__SUBHEADER__)
        if column_id == :__ORIGINAL_DATA__
            header_alignment_override = nothing

            # Get the cell index in the original table.
            jr = _get_data_column_index(ptable, j)

            # Search for alignment overrides in this cell.
            for f in ptable._header_cell_alignment
                header_alignment_override =
                    f(ptable.header, i, jr)::Union{Nothing, Symbol}

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
                alignment_override =
                    f(_getdata(ptable.data), ir, jr)::Union{Nothing, Symbol}

                if _is_alignment_valid(alignment_override)
                    return true
                end
            end
        end
    end

    return false
end

# Return `true` if the `row_id` is from the header.
function _is_header_row(row_id::Symbol)
    return (row_id == :__HEADER__) || (row_id == :__SUBHEADER__)
end

# Return `true` if the `i`th row in `ptable` is from the header.
function _is_header_row(ptable::ProcessedTable, i::Int)
    row_id = _get_row_id(ptable, i)
    return _is_header_row(row_id)
end

