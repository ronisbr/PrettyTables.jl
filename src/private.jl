# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Private functions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

################################################################################
#                                Preprocessing
################################################################################

# Those functions apply a preprocessing to the data that will be printed
# depending on its type.

function _preprocess_vec_or_mat(data::AbstractVecOrMat,
                                header::AbstractVecOrMat)
    if isempty(header)
        pheader = ["Col. " * string(i) for i = 1:size(data,2)]
    else
        pheader = header
    end

    return data, pheader
end

function _preprocess_dict(dict::Dict{K,V}; sortkeys::Bool = false) where {K,V}
    pheader::Matrix{String} = ["Keys"              "Values";
                               compact_type_str(K) compact_type_str(V)]

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

function _preprocess_Tables_column(data, header::AbstractVecOrMat)
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
    #     2. Otherwise, check if the table defines a schema to create the
    #        header.
    #     3. If the table does not have a schema, then build a default header
    #        based on the column name and type.
    if isempty(header)
        sch = Tables.schema(data)

        if sch != nothing
            types::Vector{String} = compact_type_str.([sch.types...])

            # Check if we have only one column. In this case, the header must be
            # a `Vector`.
            if length(names) == 1
                pheader = [names[1]; types[1]]
            else
                pheader = [permutedims(names); permutedims(types)]
            end
        else
            pheader = pdata.column_names
        end
    else
        pheader = header
    end

    return pdata, pheader
end

function _preprocess_Tables_row(data, header::AbstractVecOrMat)
    # Access the table using the rows.
    table = Tables.rows(data)

    # We need to fetch the first row to get information about the columns.
    row₁,~ = iterate(table, 1)

    # Get the column names.
    names = collect(Symbol, Tables.columnnames(row₁))

    # Compute the table size.
    size_i::Int = length(table)
    size_j::Int = length(names)

    pdata = RowTable(data, table, names, (size_i, size_j))

    # For the header, we have the following priority:
    #
    #     1. If the user passed a vector `header`, then use it.
    #     2. Otherwise, check if the table defines a schema to create the
    #        header.
    #     3. If the table does not have a schema, then build a default header
    #        based on the column name and type.
    if isempty(header)
        sch = Tables.schema(data)

        if sch != nothing
            types::Vector{String} = compact_type_str.([sch.types...])

            # Check if we have only one column. In this case, the header must be
            # a `Vector`.
            if length(names) == 1
                pheader = [names[1]; types[1]]
            else
                pheader = [permutedims(names); permutedims(types)]
            end
        else
            pheader = pdata.column_names
        end
    else
        pheader = header
    end

    return pdata, pheader
end

################################################################################
#                              Print information
################################################################################

# This function creates the structure that holds the global print information.
function _print_info(data, header::AbstractVecOrMat;
                     alignment::Union{Symbol,Vector{Symbol}} = :r,
                     backend::Union{Nothing,Symbol} = nothing,
                     cell_alignment::Union{Nothing,
                                           Dict{Tuple{Int,Int},Symbol},
                                           Function,
                                           Tuple} = nothing,
                     cell_first_line_only::Bool = false,
                     compact_printing::Bool = true,
                     filters_row::Union{Nothing,Tuple} = nothing,
                     filters_col::Union{Nothing,Tuple} = nothing,
                     formatters::Union{Nothing,Function,Tuple} = nothing,
                     header_alignment::Union{Symbol,Vector{Symbol}} = :s,
                     header_cell_alignment::Union{Nothing,
                                                  Dict{Tuple{Int,Int},Symbol},
                                                  Function,
                                                  Tuple} = nothing,
                     row_names::Union{Nothing,AbstractVector} = nothing,
                     row_name_alignment::Symbol = :r,
                     row_name_column_title::AbstractString = "",
                     row_number_column_title::AbstractString = "Row",
                     show_row_number::Bool = false,
                     title::AbstractString = "",
                     title_alignment::Symbol = :l,
                     kwargs...)

    # Get information about the table we have to print based on the format of
    # `data`, which must be an `AbstractMatrix` or an `AbstractVector`.
    dims     = size(data)
    num_dims = length(dims)

    if num_dims == 1
        num_rows = dims[1]
        num_cols = 1
    elseif num_dims == 2
        num_rows = dims[1]
        num_cols = dims[2]
    else
        throw(ArgumentError("`data` must not have more than 2 dimensions."))
    end

    num_rows < 1 && error("The table must contain at least 1 row.")

    # The way we get the number of columns of the header depends on its
    # dimension, because the header can be a vector or a matrix. It also depends
    # on the dimension of the `data`. If `data` is a vector, then `header` must
    # be a vector, in which the first elements if the header and the others are
    # sub-headers.

    header_size     = size(header)
    header_num_dims = length(header_size)

    # Check if it is vector or a matrix with only one column.
    if (num_dims == 1) || (num_dims == 2 && num_cols == 1)
        if (header_num_dims != 1) && (header_size[2] != 1)
            error("If the input data has only one column, then the header must be a vector.")
        end

        header_num_cols = 1
        header_num_rows = header_size[1]
    elseif length(header_size) == 2
        header_num_rows = header_size[1]
        header_num_cols = header_size[2]
    else
        header_num_rows = 1
        header_num_cols = header_size[1]
    end

    if typeof(alignment) == Symbol
        alignment = [alignment for i = 1:num_cols]
    else
        length(alignment) != num_cols && error("The length of `alignment` must be the same as the number of rows.")
    end

    if typeof(header_alignment) == Symbol
        header_alignment = [header_alignment for i = 1:num_cols]
    else
        length(header_alignment) != num_cols && error("The length of `header_alignment` must be the same as the number of rows.")
    end

    # If there is a vector of row names, then it must have the same size of the
    # number of rows.
    if row_names != nothing
        length(row_names) != num_rows &&
        error("The number of lines in `row_names` must match the number of lines in the matrix.")
        show_row_names = true
    else
        show_row_names = false
    end

    # If the user wants to filter the data, then check which columns and rows
    # must be printed. Notice that if a data is filtered, then it means that it
    # passed the filter and must be printed.
    filtered_rows = ones(Bool, num_rows)
    filtered_cols = ones(Bool, num_cols)

    if filters_row != nothing
        @inbounds for i = 1:num_rows
            filtered_i = true

            for filter in filters_row
                !filter(_getdata(data),i) && (filtered_i = false) && break
            end

            filtered_rows[i] = filtered_i
        end
    end

    if filters_col != nothing
        @inbounds for i = 1:num_cols
            filtered_i = true

            for filter in filters_col
                !filter(_getdata(data),i) && (filtered_i = false) && break
            end

            filtered_cols[i] = filtered_i
        end
    end

    # `id_cols` and `id_rows` contains the indices of the data array that will
    # be printed.
    id_cols          = findall(filtered_cols)
    id_rows          = findall(filtered_rows)
    num_printed_cols = length(id_cols)
    num_printed_rows = length(id_rows)

    # If there is no data to print, then print a blank line and exit.
    if (num_printed_cols == 0) || (num_printed_rows == 0)
        println(io, "")
        return nothing
    end

    # Make sure that `cell_alignment` is a tuple.
    if cell_alignment == nothing
        cell_alignment = ()
    elseif typeof(cell_alignment) <: Dict
        # If it is a `Dict`, then `cell_alignment[(i,j)]` contains the desired
        # alignment for the cell `(i,j)`. Thus, we need to create a wrapper
        # function.
        cell_alignment_dict = copy(cell_alignment)
        cell_alignment = ((data,i,j) -> begin
            if haskey(cell_alignment_dict, (i,j))
                return cell_alignment_dict[(i,j)]
            else
                return nothing
            end
        end,)
    elseif typeof(cell_alignment) <: Function
        cell_alignment = (cell_alignment,)
    end

    # Make sure that `header_cell_alignment` is a tuple.
    if header_cell_alignment == nothing
        header_cell_alignment = ()
    elseif typeof(header_cell_alignment) <: Dict
        # If it is a `Dict`, then `header_cell_alignment[(i,j)]` contains the
        # desired alignment for the cell `(i,j)`. Thus, we need to create a
        # wrapper function.
        header_cell_alignment_dict = copy(header_cell_alignment)
        header_cell_alignment = ((data,i,j) -> begin
            if haskey(header_cell_alignment_dict, (i,j))
                return header_cell_alignment_dict[(i,j)]
            else
                return nothing
            end
        end,)
    elseif typeof(header_cell_alignment) <: Function
        header_cell_alignment = (header_cell_alignment,)
    end

    # Make sure that `formatters` is a tuple.
    formatters == nothing  && (formatters = ())
    typeof(formatters) <: Function && (formatters = (formatters,))

    # Create the structure that stores the print information.
    pinfo = PrintInfo(data, header, id_cols, id_rows, num_rows, num_cols,
                      num_printed_cols, num_printed_rows, header_num_rows,
                      header_num_cols, show_row_number, row_number_column_title,
                      show_row_names, row_names, row_name_alignment,
                      row_name_column_title, alignment, cell_alignment,
                      formatters, compact_printing, title, title_alignment,
                      header_alignment, header_cell_alignment,
                      cell_first_line_only)

    return pinfo
end

################################################################################
#                                   Printing
################################################################################

# Dictionary to hold the information between the table format type and the
# backend.
const _type_backend_dict = Dict{DataType, Symbol}(TextFormat       => :text,
                                                  HTMLTableFormat  => :html,
                                                  LatexTableFormat => :latex)

# This is a middleware function to apply the preprocess step to the data that
# will be printed.
function _pretty_table(io::IO, data, header::AbstractVecOrMat; kwargs...)
    if Tables.istable(data)
        if Tables.columnaccess(data)
            pdata, pheader = _preprocess_Tables_column(data, header)
        elseif Tables.rowaccess(data)
            pdata, pheader = _preprocess_Tables_row(data,header)
        else
            error("The object does not have a valid Tables.jl implementation.")
        end

    elseif typeof(data) <: AbstractVecOrMat
        pdata, pheader = _preprocess_vec_or_mat(data, header)
    elseif typeof(data) <: Dict
        sortkeys = get(kwargs, :sortkeys, false)
        pdata, pheader = _preprocess_dict(data; sortkeys = sortkeys)
    else
        error("The type $(typeof(data)) is not supported.")
    end

    return _pt(io, pdata, pheader; kwargs...)
end

# This is the low level function that prints the table. In this case, `data`
# must be accessed by `[i,j]` and the size of the `header` must be equal to the
# number of columns in `data`.
function _pt(io::IO, data, header::AbstractVecOrMat; kwargs...)

    backend = get(kwargs, :backend, nothing)

    if backend == nothing
        # In this case, if we do not have the `tf` keyword, then we just
        # fallback to the text backend. Otherwise, check if the type is
        # listed in the dictionary `_type_backend_dict`.
        tf = get(kwargs, :tf, nothing)
        if haskey(kwargs, :tf) && haskey(_type_backend_dict, typeof(kwargs[:tf]))
            backend = _type_backend_dict[typeof(kwargs[:tf])]
        else
            backend = :text
        end
    end

    # Create the structure that stores the print information.
    pinfo = _print_info(data, header; kwargs...)

    # Select the appropriate backend.
    if backend == :text
        _pt_text(io, pinfo; kwargs...)
    elseif backend == :html
        _pt_html(io, pinfo; kwargs...)
    elseif backend == :latex
        _pt_latex(io, pinfo; kwargs...)
    else
        error("Unknown backend `$backend`.")
    end

    return nothing
end
