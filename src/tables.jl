## Description #############################################################################
#
# Functions to define interfaces with Tables.jl.
#
# This file contains some overloads related to the structures `ColumnTable` `RowTable` so
# that an element can be accessed by `table[i,j]`. This is required for the low-level
# interface of PrettyTables.jl when printing.
#
############################################################################################

import Base: getindex, isassigned, length, size

##########return ==  ##################################################################################
#                             Functions Related to ColumnTable                             #
############################################################################################

function ColumnTable(data::Any)
    # Access the table using the columns.
    table = Tables.columns(data)

    # Get the column names.
    names = collect(Symbol, Tables.columnnames(table))

    # Compute the table size and get the column types.
    size_j = length(names)::Int
    size_i = Tables.rowcount(table)::Int

    return ColumnTable(data, table, names, (size_i, size_j))
end

function getindex(ctable::ColumnTable, inds...)
    length(inds) != 2 && error("A element of type `ColumnTable` must be accesses using 2 indices.")

    # Access index.
    i, j = inds[1], inds[2]

    # Get the column name.
    column_name = ctable.column_names[j]

    # Get the element.
    element = Tables.getcolumn(ctable.table, column_name)[i]

    return element
end

function isassigned(ctable::ColumnTable, inds...)
    length(inds) != 2 && error("A element of type `ColumnTable` must be accesses using 2 indices.")

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

############################################################################################
#                              Functions Related to RowTable                               #
############################################################################################

function RowTable(data::Any)
    # Access the table using the rows.
    table = Tables.rows(data)

    # Compute the number of rows.
    size_i = length(table)::Int

    # If we have at least one row, we can obtain the number of columns by fetching the row.
    # Otherwise, we try to use the schema.
    if size_i > 0
        row₁ = first(table)

        # Get the column names.
        names = collect(Symbol, Tables.columnnames(row₁))
    else
        sch = Tables.schema(data)

        if sch === nothing
            # In this case, we do not have a row and we do not have a schema.  Thus, we can
            # do nothing. Hence, we assume there is no row or column.
            names = Symbol[]
        else
            names = [sch.names...]
        end
    end

    size_j = length(names)::Int

    return RowTable(data, table, names, (size_i, size_j))
end

function getindex(rtable::RowTable, inds...)
    length(inds) != 2 && error("A element of type `RowTable` must be accesses using 2 indices.")

    # Access index.
    i, j = inds[1], inds[2]

    # Get the column name.
    column_name = rtable.column_names[j]

    # If we have `Tables.subset`, let's use it. Otherwise, we fallback to the row iteration
    # as indicated here:
    #
    #   https://github.com/ronisbr/PrettyTables.jl/issues/220

    try
        row = Tables.subset(rtable.data, i; viewhint = true)
        element = Tables.getcolumn(row, column_name)
        return element

    catch e
        # Get the i-th row by iterating the row table.
        it, state = iterate(rtable.table)

        for _ in 2:i
            it, state = iterate(rtable.table, state)
            it === nothing && error("The row `i` does not exist.")
        end

        element = Tables.getcolumn(it, column_name)

        return element
    end
end

function isassigned(rtable::RowTable, inds...)
    try
        getindex(rtable, inds...)
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

############################################################################################
#                                     Other Overloads                                      #
############################################################################################

# `_getdata` is a function that returns the original matrix passed to `pretty_table`
# function. This is required because when printing something compliant with Tables.jl, we
# modify its type to be `ColumnTable` or `RowTable`. In this case, functions like
# highlighters must receive the original data, not the transformed one.
_getdata(data) = data
