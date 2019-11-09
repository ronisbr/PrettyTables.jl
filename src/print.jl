#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Functions to print the tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export pretty_table

################################################################################
#                               Public Functions
################################################################################

"""
    function pretty_table([io::IO,] data::AbstractVecOrMat{T1}, header::AbstractVecOrMat{T2};  kwargs...) where {T1,T2}

Print to `io` the vector or matrix `data` with header `header`. If `io` is
omitted, then it defaults to `stdout`. If `header` is empty, then it will be
automatically filled with "Col.  i" for the *i*-th column.

The `header` can be a `Vector` or a `Matrix`. If it is a `Matrix`, then each row
will be a header line. The first line is called *header* and the others are
called *sub-headers* .

    function pretty_table([io::IO,] data::AbstractVecOrMat{T}; ...) where T

Print to `io` the vector or matrix `data`. If `io` is omitted, then it defaults
to `stdout`. The header will be automatically filled with "Col. i" for the
*i*-th column.

    function pretty_table([io::IO,] dict::Dict{K,V}; sortkeys = true, ...) where {K,V}

Print to `io` the dictionary `dict` in a matrix form (one column for the keys
and other for the values). If `io` is omitted, then it defaults to `stdout`.

In this case, the keyword `sortkeys` can be used to select whether or not the
user wants to print the dictionary with the keys sorted. If it is `false`, then
the elements will be printed on the same order returned by the functions `keys`
and `values`. Notice that this assumes that the keys are sortable, if they are
not, then an error will be thrown.

    function pretty_table([io::IO,] table; ...)

Print to `io` the table `table`. In this case, `table` must comply with the API
of **Tables.jl**. If `io` is omitted, then it defaults to `stdout`.

                       alignment::Union{Symbol,Vector{Symbol}} = :r,
                       backend::Symbol = :text,
                       filters_row::Union{Nothing,Tuple} = nothing,
                       filters_col::Union{Nothing,Tuple} = nothing,

# Keywords

* `alignment`: Select the alignment of the columns (see the section `Alignment`).
* `backend`: Select which backend will be used to print the table (see the
             section `Backend`). Notice that the additional configuration in
             `kwargs...` depends on the selected backend. (see the section
             `Backend`).
* `filters_row`: Filters for the rows (see the section `Filters`).
* `filters_col`: Filters for the columns (see the section `Filters`).

# Alignment

The keyword `alignment` can be a `Symbol` or a vector of `Symbol`.

If it is a symbol, we have the following behavior:

* `:l` or `:L`: the text of all columns will be left-aligned;
* `:c` or `:C`: the text of all columns will be center-aligned;
* `:r` or `:R`: the text of all columns will be right-aligned;
* Otherwise it defaults to `:r`.

If it is a vector, then it must have the same number of symbols as the number of
columns in `data`. The *i*-th symbol in the vector specify the alignment of the
*i*-th column using the same symbols as described previously.

# Filters

It is possible to specify filters to filter the data that will be printed. There
are two types of filters: the row filters, which are specified by the keyword
`filters_row`, and the column filters, which are specified by the keyword
`filters_col`.

The filters are a tuple of functions that must have the following signature:

```julia
f(data,i)::Bool
```

in which `data` is a pointer to the matrix that is being printed and `i` is the
i-th row in the case of the row filters or the i-th column in the case of column
filters. If this function returns `true` for `i`, then the i-th row (in case of
`filters_row`) or the i-th column (in case of `filters_col`) will be printed.
Otherwise, it will be omitted.

A set of filters can be passed inside of a tuple. Notice that, in this case,
**all filters** for a specific row or column must be return `true` so that it
can be printed, *i.e* the set of filters has an `AND` logic.

If the keyword is set to `nothing`, which is the default, then no filtering will
be applied to the data.

!!! note

    The filters do not change the row and column numbering for the others
    modifiers such as column width specification, formatters, and highlighters.
    Thus, for example, if only the 4-th row is printed, then it will also be
    referenced inside the formatters and highlighters as 4 instead of 1.

"""
pretty_table(data::AbstractVecOrMat{T1}, header::AbstractVecOrMat{T2};
             kwargs...) where {T1,T2} =
    pretty_table(stdout, data, header; kwargs...)

function pretty_table(io::IO, data::AbstractVecOrMat{T1},
                      header::AbstractVecOrMat{T2}; kwargs...) where {T1,T2}

    isempty(header) && ( header = ["Col. " * string(i) for i = 1:size(data,2)] )
    _pretty_table(io, data, header; kwargs...)
end

pretty_table(data::AbstractVecOrMat{T}, kwargs...) where T =
    pretty_table(stdout, data; kwargs...)

pretty_table(io::IO, data::AbstractVecOrMat{T}; kwargs...) where T =
    pretty_table(io, data, []; kwargs...)

pretty_table(dict::Dict{K,V}; kwargs...) where {K,V} =
    pretty_table(stdout, dict; kwargs...)

function pretty_table(io::IO, dict::Dict{K,V}; sortkeys = false, kwargs...) where {K,V}
    header = ["Keys"     "Values";
              string(K)  string(V)]

    k = collect(keys(dict))
    v = collect(values(dict))

    if sortkeys
        ind = sortperm(collect(keys(dict)))
        vk  = @view k[ind]
        vv  = @view v[ind]
    else
        vk = k
        vv = v
    end

    pretty_table(io, [vk vv], header; kwargs...)
end

pretty_table(table; kwargs...) = pretty_table(stdout, table; kwargs...)

function pretty_table(io::IO, table; kwargs...)

    # Get the data.
    #
    # If `table` is not compatible with Tables.jl, then an error will be thrown.
    data = Tables.columns(table)

    # Get the table schema to obtain the columns names.
    sch = Tables.schema(table)

    if sch == nothing
        num_cols, num_rows = size(data)
        header = ["Col. " * string(i) for i = 1:num_cols]
    else
        names = reshape( [sch.names...], (1,:) )
        types = reshape( [sch.types...], (1,:) )

        # Check if we have only one column. In this case, the header must be a
        # `Vector`.
        if length(names) == 1
            header = [names[1]; types[1]]
        else
            header = [names; types]
        end
    end

    _pretty_table(io, data, header; kwargs...)
end

################################################################################
#                              Private Functions
################################################################################

# This is the low level function that prints the table. In this case, `data`
# must be accessed by `[i,j]` and the size of the `header` must be equal to the
# number of columns in `data`.
function _pretty_table(io, data, header;
                       alignment::Union{Symbol,Vector{Symbol}} = :r,
                       backend::Symbol = :text,
                       filters_row::Union{Nothing,Tuple} = nothing,
                       filters_col::Union{Nothing,Tuple} = nothing,
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
        header_num_dims != 1 &&
        error("If the input data has only one column, then the header must be a vector.")

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

    # If the user wants to filter the data, then check which columns and rows
    # must be printed. Notice that if a data is filtered, then it means that it
    # passed the filter and must be printed.
    filtered_rows = ones(Bool, num_rows)
    filtered_cols = ones(Bool, num_cols)

    if filters_row != nothing
        @inbounds for i = 1:num_rows
            filtered_i = true

            for filter in filters_row
                !filter(data,i) && (filtered_i = false) && break
            end

            filtered_rows[i] = filtered_i
        end
    end

    if filters_col != nothing
        @inbounds for i = 1:num_cols
            filtered_i = true

            for filter in filters_col
                !filter(data,i) && (filtered_i = false) && break
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

    # Create the structure that stores the print information.
    pinfo = PrintInfo(data, header, id_cols, id_rows, num_rows, num_cols,
                      num_printed_cols, num_printed_rows, header_num_rows,
                      header_num_cols, alignment)

    if backend == :text
        _pt_text(io, pinfo; kwargs...)
    else
        error("Unknown backend `$backend`.")
    end

    return nothing
end

