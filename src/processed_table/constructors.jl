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
    column_filters::Union{Nothing, Tuple} = nothing,
    row_filters::Union{Nothing, Tuple} = nothing
)

    ~, num_columns = size(data)

    # Check if the header dimension is correct.
    if header !== nothing
        num_header_columns = length(first(header))

        if num_columns != num_header_columns
            error("The number of columns in the header must be equal to that of the table.")
        end

        num_header_rows = length(header)
    end

    return ProcessedTable(
        data = data,
        header = header,
        _column_filters = column_filters,
        _row_filters = row_filters,
        _num_header_columns = num_header_columns,
        _num_header_rows = num_header_rows
    )
end
