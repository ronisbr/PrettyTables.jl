## Description #############################################################################
#
# Functions to add additional data into a `ProcessedTable`.
#
############################################################################################

"""
    _add_column!(ptable::ProcessedTable, new_column::AbstractVector, new_header::Vector{String} = String[""]; kwargs...) -> Nothing

Add a new column `new_column` with header `new_header` to `ptable`.

# Keywords

- `alignment::Symbol`: Alignment for the new column. (**Default** = `:r`)
- `header_alignment::Symbol`: Alignment for the new column header. (**Default** = `:s`)
- `id::Symbol`: Identification symbol for the new column.
    (**Default** = `:additional_column`)
"""
function _add_column!(
    ptable::ProcessedTable,
    new_column::AbstractVector,
    new_header::Vector{String} = String[""];
    alignment::Symbol = :r,
    header_alignment::Symbol = :s,
    id::Symbol = :additional_column
)

    # The length of the new column must match the number of rows in the initial
    # data.
    num_rows, ~ = _data_size(ptable)

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
    push!(ptable._additional_column_alignment, alignment)
    push!(ptable._additional_column_header_alignment, header_alignment)

    return nothing
end
