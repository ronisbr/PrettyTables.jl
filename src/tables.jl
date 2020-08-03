# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Functions to define interfaces with Tables.jl.
#
#   This file contains some overloads related to the structures `ColumnTable`
#   `RowTable` so that an element can be accessed by `table[i,j]`. This is
#   required for the low-level interface of PrettyTables.jl when printing.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import Base: getindex, isassigned, length, size

#                       Fuctions related to ColumnTable
# ==============================================================================

function getindex(ctable::ColumnTable, inds...)
    length(inds) != 2 &&
    error("A element of type `ColumnTable` must be accesses using 2 indices.")

    # Access index.
    i,j = inds[1], inds[2]

    # Get the column name.
    column_name = ctable.column_names[j]

    # Get the element.
    element = Tables.getcolumn(ctable.table, column_name)[i]

    return element
end

function isassigned(ctable::ColumnTable, inds...)
    length(inds) != 2 &&
    error("A element of type `ColumnTable` must be accesses using 2 indices.")

    # Access index.
    i,j = inds[1], inds[2]

    # Get the column name.
    column_name = ctable.column_names[j]

    # Get the element.
    return isassigned(Tables.getcolumn(ctable.table, column_name),i)
end

length(ctable::ColumnTable) = ctable.size[1] * ctable.size[2]

size(ctable::ColumnTable) = ctable.size

#                         Fuctions related to RowTable
# ==============================================================================

function getindex(rtable::RowTable, inds...)
    length(inds) != 2 &&
    error("A element of type `RowTable` must be accesses using 2 indices.")

    # Access index.
    i,j = inds[1], inds[2]

    # Get the column name.
    column_name = rtable.column_names[j]

    # Get the element.
    it,~ = iterate(rtable.table, i)

    it == nothing &&
    error("The row `i` does not exist.")

    element = it[column_name]

    return element
end

function isassigned(rtable::RowTable, inds...)
    length(inds) != 2 &&
    error("A element of type `RowTable` must be accesses using 2 indices.")

    # Access index.
    i,j = inds[1], inds[2]

    # Get the column name.
    column_name = rtable.column_names[j]

    # Get the element.
    it,~ = iterate(rtable.table, i)

    it == nothing &&
    error("The row `i` does not exist.")

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
