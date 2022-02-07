# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Constructors for the `ProcessedTable`.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    ProcessedTable(data::Any, header::Any; kwargs...)

Create a processed table with `data` and `header`.

# Keywords

- `column_filters::Union{Nothing, Tuple}`: Column filters.
    (**Default** = `nothing`)
- `row_filters::Union{Nothing, Tuple}`: Row filters. (**Default** = `nothing`)
"""
function ProcessedTable(
    data::Any,
    header::Any;
    alignment::Union{Symbol, Vector{Symbol}} = :r,
    cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    column_filters::Union{Nothing, Tuple} = nothing,
    header_alignment::Union{Symbol, Vector{Symbol}} = :s,
    header_cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    noheader::Bool = false,
    nosubheader::Bool = false,
    row_filters::Union{Nothing, Tuple} = nothing
)
    # Get information about the table we have to print based on the format of
    # `data`, which must be an `AbstractMatrix` or an `AbstractVector`.
    dims     = size(data)
    num_dims = length(dims)

    if num_dims == 1
        num_data_rows = dims[1]
        num_data_columns = 1
    elseif num_dims == 2
        num_data_rows = dims[1]
        num_data_columns = dims[2]
    else
        throw(ArgumentError("`data` must not have more than 2 dimensions."))
    end

    # Process the header and subheader.
    num_header_rows = 0
    num_header_columns = num_data_columns

    if header !== nothing
        if !noheader
            num_header_columns = length(first(header))

            if num_data_columns != num_header_columns
                error("The number of columns in the header must be equal to that of the table.")
            end

            num_header_rows = nosubheader ? 1 : length(header)
        end
    end

    # Make sure that `cell_alignment` is a tuple.
    if cell_alignment === nothing
        cell_alignment = ()
    elseif typeof(cell_alignment) <: Dict
        # If it is a `Dict`, then `cell_alignment[(i,j)]` contains the desired
        # alignment for the cell `(i,j)`. Thus, we need to create a wrapper
        # function.
        cell_alignment_dict = copy(cell_alignment)
        cell_alignment = ((data, i, j) -> begin
            if haskey(cell_alignment_dict, (i, j))
                return cell_alignment_dict[(i, j)]
            else
                return nothing
            end
        end,)
    elseif typeof(cell_alignment) <: Function
        cell_alignment = (cell_alignment,)
    end

    # Make sure that `header_cell_alignment` is a tuple.
    if header_cell_alignment === nothing
        header_cell_alignment = ()
    elseif typeof(header_cell_alignment) <: Dict
        # If it is a `Dict`, then `header_cell_alignment[(i,j)]` contains the
        # desired alignment for the cell `(i,j)`. Thus, we need to create a
        # wrapper function.
        header_cell_alignment_dict = copy(header_cell_alignment)
        header_cell_alignment = ((data, i, j) -> begin
            if haskey(header_cell_alignment_dict, (i, j))
                return header_cell_alignment_dict[(i, j)]
            else
                return nothing
            end
        end,)
    elseif typeof(header_cell_alignment) <: Function
        header_cell_alignment = (header_cell_alignment,)
    end

    return ProcessedTable(
        data = data,
        header = header,
        _data_alignment = alignment,
        _data_cell_alignment = cell_alignment,
        _column_filters = column_filters,
        _header_alignment = header_alignment,
        _header_cell_alignment = header_cell_alignment,
        _row_filters = row_filters,
        _num_data_rows = num_data_rows,
        _num_data_columns = num_data_columns,
        _num_header_columns = num_header_columns,
        _num_header_rows = num_header_rows
    )
end
