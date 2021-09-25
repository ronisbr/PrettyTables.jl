# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to define interfaces with Tables.jl.
#
#   This file contains some overloads related to the structures `ColumnTable`
#   `RowTable` so that an element can be accessed by `table[i,j]`. This is
#   required for the low-level interface of PrettyTables.jl when printing.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import Base: getindex, isassigned, length, size

#                       Functions related to ColumnTable
# ==============================================================================

function getindex(ctable::ColumnTable, inds...)
    if length(inds) != 2
        error("A element of type `ColumnTable` must be accesses using 2 indices.")
    end

    # Access index.
    i, j = inds[1], inds[2]

    # Get the column name.
    column_name = ctable.column_names[j]

    # Get the element.
    element = Tables.getcolumn(ctable.table, column_name)[i]

    return element
end

function isassigned(ctable::ColumnTable, inds...)
    if length(inds) != 2
        error("A element of type `ColumnTable` must be accesses using 2 indices.")
    end

    # Access index.
    i, j = inds[1], inds[2]

    # Get the column name.
    column_name = ctable.column_names[j]

    # Get the column.
    col = Tables.getcolumn(ctable.table, column_name)

    # If the column is a `Tuple`, then all the elements must be defined.
    if col isa Tuple
        return true
    else
        return isassigned(col, i)
    end
end

length(ctable::ColumnTable) = ctable.size[1] * ctable.size[2]

size(ctable::ColumnTable) = ctable.size

_getdata(ctable::ColumnTable) = ctable.data

#                         Functions related to RowTable
# ==============================================================================

function getindex(rtable::RowTable, inds...)
    if length(inds) != 2
        error("A element of type `RowTable` must be accesses using 2 indices.")
    end

    # Access index.
    i, j = inds[1], inds[2]

    # Get the column name.
    column_name = rtable.column_names[j]

    # Get the element.
    it, ~ = iterate(rtable.table, i)

    it === nothing && error("The row `i` does not exist.")

    element = it[column_name]

    return element
end

function isassigned(rtable::RowTable, inds...)
    if length(inds) != 2
        error("A element of type `RowTable` must be accesses using 2 indices.")
    end

    # Access index.
    i, j = inds[1], inds[2]

    # Get the column name.
    column_name = rtable.column_names[j]

    # Get the element.
    it, ~ = iterate(rtable.table, i)

    it === nothing && error("The row `i` does not exist.")

    try
        element = it[column_name]
        return true
    catch e
        if isa(e, UndefRefError)
            return false
        else
            throw(e)
        end
    end
end

length(rtable::RowTable) = rtable.size[1] * rtable.size[2]

size(rtable::RowTable) = rtable.size

_getdata(rtable::RowTable) = rtable.data

#                               Other overloads
# ==============================================================================

# `_getdata` is a function that returns the original matrix passed to
# `pretty_table` function. This is required because when printing something
# compliant with Tables.jl, we modify its type to be `ColumnTable` or
# `RowTable`. In this case, functions like filters and highlighters must receive
# the original data, not the transformed one.
_getdata(data) = data
