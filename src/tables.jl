## Description #############################################################################
#
# Functions to define interfaces with Tables.jl.
#
# This file contains some overloads related to the structures `ColumnTable` and `RowTable`
# so that an element can be accessed by `table[i,j]`. This is required for the low-level
# interface of PrettyTables.jl when printing.
#
############################################################################################

import Base: getindex, isassigned, length, size

############################################################################################
#                             Functions Related to ColumnTable                             #
############################################################################################

Base.@nospecializeinfer function ColumnTable(@nospecialize(data::Any))
    # Access the table using the columns.
    table = Tables.columns(data)

    # Get the column names.
    names = collect(Symbol, Tables.columnnames(table))

    # Compute the table size and get the column types.
    size_j = length(names)::Int
    size_i = Tables.rowcount(table)::Int

    return ColumnTable(data, table, names, (size_i, size_j))
end

function getindex(ctable::ColumnTable, i, j)
    # Get the column name.
    column_name = ctable.column_names[j]

    # Get the element.
    element = Tables.getcolumn(ctable.table, column_name)[i]

    return element
end

function getindex(ctable::ColumnTable, inds...)
    if length(inds) != 2
        error("A element of type `ColumnTable` must be accesses using 2 indices.")
    end

    return getindex(ctable, inds[1], inds[2])
end

function isassigned(ctable::ColumnTable, i, j)
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

function isassigned(ctable::ColumnTable, inds...)
    if length(inds) != 2
        error("A element of type `ColumnTable` must be accesses using 2 indices.")
    end

    return isassigned(ctable, inds[1], inds[2])
end

axes(ctable::ColumnTable) = (Base.OneTo(ctable.size[1]), Base.OneTo(ctable.size[2]))

function axes(ctable::ColumnTable, dim::Int)
    dim == 1 && return Base.OneTo(ctable.size[1])
    return Base.OneTo(ctable.size[2])
end

length(ctable::ColumnTable) = ctable.size[1] * ctable.size[2]

size(ctable::ColumnTable) = ctable.size

Base.maybeview(ctable::ColumnTable, inds...) = Base.maybeview(ctable.data, inds...)

_get_data(ctable::ColumnTable) = ctable.data

############################################################################################
#                              Functions Related to RowTable                               #
############################################################################################

Base.@nospecializeinfer function RowTable(@nospecialize(data::Any))
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

    return RowTable(data, table, names, (size_i, size_j), RowTableAccessState())
end

"""
    _row_table_subset(rtable::RowTable, i::Integer) -> Tuple{Bool, Any}

Acquire and cache the subset row for row `i`, including acquisition failures.
"""
function _row_table_subset(rtable::RowTable, i::Integer)
    access_state = rtable.access_state

    # Reset the row-local subset cache for a new requested row.
    if access_state.requested_row != i
        access_state.requested_row = i
        access_state.subset_attempted = false
        access_state.subset_succeeded = false
        access_state.subset_row = nothing
    end

    # Return a previously cached subset acquisition result.
    access_state.subset_attempted &&
        return access_state.subset_succeeded, access_state.subset_row

    # Mark the attempt before invoking user-provided table code.
    access_state.subset_attempted = true
    try
        access_state.subset_row = Tables.subset(rtable.data, i; viewhint = true)

        # Record a successful subset acquisition.
        access_state.subset_succeeded = true
    catch
        # Record a failed subset acquisition.
        access_state.subset_row = nothing
        access_state.subset_succeeded = false
    end

    # Return the cached subset acquisition status and row.
    return access_state.subset_succeeded, access_state.subset_row
end

"""
    _row_table_iterator_row(rtable::RowTable, i::Integer) -> Any

Acquire row `i` from the iterator, advancing forward or restarting for backward requests.
"""
function _row_table_iterator_row(rtable::RowTable, i::Integer)
    access_state = rtable.access_state

    if !access_state.iterator_started || i < access_state.iterator_row_index
        step = iterate(rtable.table)
        step === nothing && error("The row `i` does not exist.")

        access_state.iterator_row, access_state.iterator_state = step
        access_state.iterator_row_index = 1
        access_state.iterator_started = true
    end

    while access_state.iterator_row_index < i
        step = iterate(rtable.table, access_state.iterator_state)
        step === nothing && error("The row `i` does not exist.")

        access_state.iterator_row, access_state.iterator_state = step
        access_state.iterator_row_index += 1
    end

    return access_state.iterator_row
end

function getindex(rtable::RowTable, i, j)
    column_name = rtable.column_names[j]
    subset_succeeded, subset_row = _row_table_subset(rtable, i)

    if subset_succeeded
        try
            return Tables.getcolumn(subset_row, column_name)
        catch
            # Preserve the broad subset-to-iterator fallback semantics.
        end
    end

    row = _row_table_iterator_row(rtable, i)
    return Tables.getcolumn(row, column_name)
end

function getindex(rtable::RowTable, inds...)
    if length(inds) != 2
        error("A element of type `RowTable` must be accesses using 2 indices.")
    end

    return getindex(rtable, inds[1], inds[2])
end

function isassigned(rtable::RowTable, i, j)
    try
        getindex(rtable, i, j)
        return true
    catch e
        if isa(e, UndefRefError)
            return false
        else
            throw(e)
        end
    end
end

function isassigned(rtable::RowTable, inds...)
    if length(inds) != 2
        error("A element of type `RowTable` must be accesses using 2 indices.")
    end

    return isassigned(rtable, inds[1], inds[2])
end

axes(rtable::RowTable) = (Base.OneTo(rtable.size[1]), Base.OneTo(rtable.size[2]))

function axes(rtable::RowTable, dim::Int)
    dim == 1 && return Base.OneTo(rtable.size[1])
    return Base.OneTo(rtable.size[2])
end

length(rtable::RowTable) = rtable.size[1] * rtable.size[2]

size(rtable::RowTable) = rtable.size

Base.maybeview(rtable::RowTable, inds...) = Base.maybeview(rtable.data, inds...)

_get_data(rtable::RowTable) = rtable.data

############################################################################################
#                                     Other Overloads                                      #
############################################################################################

# `_getdata` is a function that returns the original matrix passed to `pretty_table`
# function. This is required because when printing something compliant with Tables.jl, we
# modify its type to be `ColumnTable` or `RowTable`. In this case, functions like
# highlighters must receive the original data, not the transformed one.
_get_data(data) = data
