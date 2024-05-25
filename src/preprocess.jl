## Description #############################################################################
#
# Functions to pre-process the supported objects to be printed.
#
############################################################################################

# Those functions apply some pre-processing algorithms to the supported data types in
# PrettyTables.jl.

# == Vector or Matrices ====================================================================

function _preprocess_vec_or_mat(
    data::AbstractVecOrMat,
    header::Union{Nothing, AbstractVector, Tuple}
)
    if header === nothing
        pheader = (["Col. " * string(i) for i in axes(data, 2)],)
    elseif header isa AbstractVector
        pheader = (header,)
    else
        pheader = header
    end

    return data, pheader
end

# == Dictionaries ==========================================================================

function _preprocess_dict(
    dict::AbstractDict{K, V},
    header::Union{Nothing, AbstractVector, Tuple};
    sortkeys::Bool = false
) where {K, V}
    if header === nothing
        pheader = (
            ["Keys", "Values"],
            [compact_type_str(K), compact_type_str(V)]
        )
    elseif header isa AbstractVector
        pheader = (header,)
    else
        pheader = header
    end

    k = collect(keys(dict))
    v = collect(values(dict))

    if sortkeys
        ind = sortperm(collect(keys(dict)))
        vk  = k[ind]
        vv  = v[ind]
    else
        vk = k
        vv = v
    end

    pdata = hcat(vk, vv)

    return pdata, pheader
end

# == Tables.jl =============================================================================

# -- Tables.jl with Column Access ----------------------------------------------------------

function _preprocess_column_tables_jl(data::Any, header::Union{Nothing, AbstractVector, Tuple})
    # Access the table using the columns.
    table = Tables.columns(data)

    # Get the column names.
    names = collect(Symbol, Tables.columnnames(table))

    # Compute the table size and get the column types.
    size_j::Int = length(names)
    size_i::Int = Tables.rowcount(table)

    pdata = ColumnTable(data, table, names, (size_i, size_j))

    # For the header, we have the following priority:
    #
    #     1. If the user passed a vector `header`, then use it.
    #     2. Otherwise, check if the table defines a schema to create the header.
    #     3. If the table does not have a schema, then build a default header based on the
    #        column name and type.
    if header === nothing
        sch = Tables.schema(data)

        if sch !== nothing
            types::Vector{String} = compact_type_str.([sch.types...])
            pheader = (names, types)
        else
            pheader = (pdata.column_names,)
        end
    elseif header isa AbstractVector
        pheader = (header,)
    else
        pheader = header
    end

    return pdata, pheader
end

# -- Tables.jl with Row Access -------------------------------------------------------------

function _preprocess_row_tables_jl(data::Any, header::Union{Nothing, AbstractVector, Tuple})
    # Access the table using the rows.
    table = Tables.rows(data)

    # Compute the number of rows.
    size_i::Int = length(table)

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

    size_j::Int = length(names)

    pdata = RowTable(data, table, names, (size_i, size_j))

    # For the header, we have the following priority:
    #
    #     1. If the user passed a vector `header`, then use it.
    #     2. Otherwise, check if the table defines a schema to create the header.
    #     3. If the table does not have a schema, then build a default header based on the
    #        column name and type.
    if header === nothing
        sch = Tables.schema(data)

        if sch !== nothing
            types::Vector{String} = compact_type_str.([sch.types...])
            pheader = (names, types)
        else
            pheader = (pdata.column_names,)
        end
    elseif header isa AbstractVector
        pheader = (header,)
    else
        pheader = header
    end

    return pdata, pheader
end
