## Description #############################################################################
#
# Functions to get the index of data in a `ProcessedTable`.
#
############################################################################################

"""
    _convert_axes(data::Any, i::Int) -> Int

Convert the axes from the printed table data `i` to the axes in `data`.

!!! note

    `i` refers to the i-th element that will be printed.

---

    _convert_axes(data::Any, i::Int, j::Int) -> Int

Convert the axes from the printed table data `(i, j)` to the axes in `data`.

!!! note

    `(i, j)` refers to the i-th data row and j-th data column that will be printed.
"""
function _convert_axes(data::Any, i::Int)
    ax  = axes(data)
    ti = first(ax[1]) + i - 1
    return ti
end

function _convert_axes(data::Any, i::Int, j::Int)
    ax  = axes(data)
    ti = first(ax[1]) + i - 1
    tj = (length(ax) == 1) ? 1 : first(ax[2]) + j - 1
    return ti, tj
end

"""
    _get_cell_alignemnt(ptable::ProcessedTable, i::Int, j::Int) -> Symbol

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

            # Get the cell index in the original table.
            jr  = _get_data_column_index(ptable, j)

            # Get the data index inside the header.
            ajr = _convert_axes(ptable.header[i], jr)

            # Search for alignment overrides in this cell.
            for f in ptable._header_cell_alignment
                header_alignment_override =
                    f(ptable.header, i, ajr)::Union{Nothing, Symbol}

                if _is_alignment_valid(header_alignment_override)
                    return header_alignment_override
                end
            end

            # The apparently unnecessary conversion to `Symbol` avoids type
            # instability.
            ptable_header_alignment = ptable._header_alignment

            header_alignment = ptable_header_alignment isa Symbol ?
                Symbol(ptable_header_alignment) :
                Symbol(ptable_header_alignment[jr])

            if (header_alignment == :s) || (header_alignment == :S)
                # The apparently unnecessary conversion to `Symbol` avoids type
                # instability.
                ptable_data_alignment = ptable._data_alignment

                header_alignment = ptable_data_alignment isa Symbol ?
                    Symbol(ptable_data_alignment) :
                    Symbol(ptable_data_alignment[jr])
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

            # Get the data index inside the table.
            air, ajr = _convert_axes(ptable.data, ir, jr)

            # Search for alignment overrides in this cell.
            for f in ptable._data_cell_alignment
                alignment_override =
                    f(_getdata(ptable.data), air, ajr)::Union{Nothing, Symbol}

                if _is_alignment_valid(alignment_override)
                    return alignment_override
                end
            end

            # The apparently unnecessary conversion to `Symbol` avoids type
            # instability.
            ptable_data_alignment = ptable._data_alignment

            alignment = ptable_data_alignment isa Symbol ?
                Symbol(ptable_data_alignment) :
                Symbol(ptable_data_alignment[jr])

            return alignment
        else
            return ptable._additional_column_alignment[j]
        end
    end
end

"""
    _get_column_alignment(ptable::ProcessedTable, j::Int) -> Symbol

Return the alignment of the `j`th column in `ptable`.
"""
function _get_column_alignment(ptable::ProcessedTable, j::Int)
    # Get the identification of the row and column.
    column_id = _get_column_id(ptable, j)

    # Verify if we are at header.
    if column_id == :__ORIGINAL_DATA__
        # In this case, we must find the column index in the original data.
        jr = _get_data_column_index(ptable, j)

        # The apparently unnecessary conversion to `Symbol` avoids type
        # instability.
        ptable_data_alignment = ptable._data_alignment

        alignment = ptable_data_alignment isa Symbol ?
            Symbol(ptable_data_alignment) :
            Symbol(ptable_data_alignment[jr])

        return alignment
    else
        return ptable._additional_column_alignment[j]
    end
end

"""
    _get_column_id(ptable::ProcessedTable, j::Int) -> Symbol

Return the identification symbol of the column `j` of `ptable`. If the column is from the
original data, `:__ORIGINAL_DATA__` is returned.
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

# Function related to the API of Tables.jl inside PrettyTables.jl.
_getdata(ptable::ProcessedTable) = _getdata(ptable.data)

"""
    _get_element(ptable::ProcessedTable, i::Int, j::Int) -> Any

Get the element `(i, j)` if `ptable`. This function always considers the additional columns
and the header.

Notice that `i` and `j` must be related to the row and column that will be printed. The
actual index inside the data is handle internally in this function.
"""
function _get_element(ptable::ProcessedTable, i::Int, j::Int)
    Δc = length(ptable._additional_data_columns)

    # Check if we need to return an additional column or the real data.
    if j ≤ Δc

        if i ≤ ptable._num_header_rows
            aj = _convert_axes(ptable._additional_header_columns, j)
            hj = ptable._additional_header_columns[aj]
            l  = length(hj)

            if i ≤ l
                ai = _convert_axes(hj, i)
                return hj[ai]
            else
                return ""
            end
        else
            aj  = _convert_axes(ptable._additional_data_columns, j)
            dj  = ptable._additional_data_columns[aj]
            id  = _get_data_row_index(ptable, i)
            aid = _convert_axes(dj, id)

            if isassigned(dj, aid)
                return dj[aid]
            else
                return _UNDEFINED_CELL
            end
        end
    else
        jd = _get_data_column_index(ptable, j)

        if i ≤ ptable._num_header_rows
            hi = ptable.header[i]

            # Get the data index inside the header.
            ajd = _convert_axes(hi, jd)

            return hi[ajd]
        else
            id = _get_data_row_index(ptable, i)

            # Get the data index inside the table.
            aid, ajd = _convert_axes(ptable.data, id, jd)

            if isassigned(ptable.data, aid, ajd)
                return ptable.data[aid, ajd]
            else
                return _UNDEFINED_CELL
            end
        end
    end
end

"""
    _get_header_element(ptable::ProcessedTable, j::Int) -> Any

Get the `j`th header element in `ptable`. This function always considers the additional
columns.
"""
function _get_header_element(ptable::ProcessedTable, j::Int)
    Δc = length(ptable._additional_data_columns)

    # Check if we need to return an additional column or the real data.
    if j ≤ Δc
        return ptable._additional_header_columns[j]
    else
        # Get the data index inside the header.
        jd  = _get_data_column_index(ptable, j - Δc)
        ajd = _convert_axes(first(ptable.header), jd)

        return ptable.header[ajd]
    end
end

"""
    _get_data_column_index(ptable::ProcessedTable, j::Int) -> Int

Get the index of the `j`th data column in `ptable`.
"""
function _get_data_column_index(ptable::ProcessedTable, j::Int)
    Δc = length(ptable._additional_data_columns)
    return j - Δc
end

"""
    _get_data_row_index(ptable::ProcessedTable, i::Int) -> Int

Get the index of the `i`th data row in `ptable`.
"""
function _get_data_row_index(ptable::ProcessedTable, i::Int)
    return i - ptable._num_header_rows
end

"""
    _get_num_of_hidden_columns(ptable::ProcessedTable) -> Int

Return the number of hidden columns (see option `max_num_of_columns`).
"""
function _get_num_of_hidden_columns(ptable::ProcessedTable)
    if ptable._max_num_of_columns > 0
        return ptable._num_data_columns - ptable._max_num_of_columns
    else
        return 0
    end
end

"""
    _get_num_of_hidden_rows(ptable::ProcessedTable) -> Int

Return the number of hidden rows (see option `max_num_of_rows`).
"""
function _get_num_of_hidden_rows(ptable::ProcessedTable)
    if ptable._max_num_of_rows > 0
        return ptable._num_data_rows - ptable._max_num_of_rows
    else
        return 0
    end
end

"""
    _get_row_id(ptable::ProcessedTable, j::Int) -> Symbol

Return the identification symbol of the row `i` of `ptable`. If the row is part of the
header, it returns `:__HEADER__:` or `:__SUBHEADER__`. Otherwise it returns
`:__ORIGINAL_DATA__` because we do not have the functionality to add new rows yet.
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

"""
    _get_table_column_index(ptable::ProcessedTable, jr::Int) -> Union{Nothing, Int}

Get the table column index related to a data table index `jr` in `ptable`.
"""
function _get_table_column_index(ptable::ProcessedTable, jr::Int)
    if 0 < jr ≤ ptable._num_data_columns
        return jr + length(ptable._additional_data_columns)
    else
        return nothing
    end
end
