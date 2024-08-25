## Description #############################################################################
#
# Private functions.
#
############################################################################################

"""
    _guess_column_labels(data) -> Vector{Vector{String}}

Guess the column label associated with `data` in case the user did not pass a default value.
"""
_guess_column_labels(data::ColumnTable) = [string.(data.column_names)]
_guess_column_labels(data::RowTable) = [string.(data.column_names)]

function _guess_column_labels(data::AbstractVecOrMat)
    return [["Col. " * string(i) for i in axes(data, 2)]]
end

function _guess_column_labels(::AbstractDict{K, V}) where {K, V}
    return [
        ["Keys", "Values"],
        [_compact_type_str(K), _compact_type_str(V)]
    ]
end

"""
    _preprocess_data(data::Any) -> Any

Preprocess the `data` for printing. This function throws an error if `data` is not supported
by PrettyTables.jl.
"""
_preprocess_data(data::AbstractVecOrMat) = data
_preprocess_data(dict::AbstractDict) = dict

function _preprocess_data(@nospecialize(data::Any))
    # This is the fallback action to guess the column label. Hence, if data does not support
    # Tables.jl API, we must throw an error.
    !Tables.istable(data) && error("`pretty_table` does not support objects of type `$(typeof(data))`.")

    if Tables.columnaccess(data)
        return ColumnTable(data)
    else
        return RowTable(data)
    end
end

"""
    _validate_merge_cell_specification(table_data::TableData) -> Nothing

Validate the merge cell specification in `table_data`. If something is wrong, this function
throws an error.
"""
function _validate_merge_cell_specification(table_data::TableData)
    isnothing(table_data.merge_cells) && return nothing

    mc = table_data.merge_cells

    for i in eachindex(mc)
        mi = mc[i]

        mi_beg = mi.j
        mi_end = mi.j + mi.column_span - 1

        mi.column_span < 2 && throw(ArgumentError(
            "The specification #$i has a column span lower than 2."
        ))


        mi.i < 0 && throw(ArgumentError(
            "The row index is negative in the specification #$i for merging cells."
        ))

        mi.i > table_data.num_rows && throw(ArgumentError(
            "The row index is larger than the number of column label rows in the specification #$i for merging cells."
        ))

        mi.j < 0 && throw(ArgumentError(
            "The column index is negative in the specification #$i for merging cells."
        ))

        mi.j > table_data.num_columns && throw(ArgumentError(
            "The column index is larger than the number of table columns in the specification #$i for merging cells."
        ))

        mi_end > table_data.num_columns && throw(ArgumentError(
            "The specification #$i for merging cells references a cell outside the table column range."
        ))

        for j in eachindex(mc)
            i == j && continue

            mj = mc[j]

            mj_beg = mj.j
            mj_end = mj.j + mj.column_span - 1

            ((mi_end >= mj_beg) && (mj_end >= mi_beg)) && throw(ArgumentError(
                "The specifications #$i and #$j for merging cells overlap."
            ))
        end
    end

    return nothing
end
