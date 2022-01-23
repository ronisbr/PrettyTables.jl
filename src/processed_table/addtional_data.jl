# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to add additional data into a `ProcessedTable`.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _add_column!(ptable::ProcessedTable, new_column::AbstractVector, new_header::Vector{String} = String[""])

Add a new column `new_column` with header `new_header` to `ptable`. The `id` can
be set to a symbol so that the additional column can be identified easily.
"""
function _add_column!(
    ptable::ProcessedTable,
    new_column::AbstractVector,
    new_header::Vector{String} = String[""],
    id::Symbol = :additional_column
)

    # The length of the new column must match the number of rows in the initial
    # data.
    num_rows, ~ = size(ptable.data)

    if num_rows != length(new_column)
        error("The size of the new column does not match the size of the table.")
    end

    # The symbol cannot be `:__ORIGINAL_DATA__` because it is used to identified
    # if a column is part of the original data.
    if id == :__ORIGINAL_DATA__
        error("The new column identification symbol cannot be `:__ORIGINAL_DATA__`.")
    end

    push!(ptable._additional_column_id, id)
    push!(ptable._additional_data_columns, new_column)
    push!(ptable._additional_header_columns, new_header)

    return nothing
end

"""
    _get_column_id(ptable::ProcessedTable, j::Int)

Return the identification symbol of the column `j` of `ptable`. If the column is
from the original data, then `:__ORIGINAL_DATA__` is returned.
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
