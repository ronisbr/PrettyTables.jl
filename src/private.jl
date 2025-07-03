## Description #############################################################################
#
# Private functions.
#
############################################################################################

"""
    _guess_column_labels(data) -> Vector{Vector{String}}

Guess the column label associated with `data` in case the user did not pass a default value.
"""
function _guess_column_labels(data::Union{ColumnTable, RowTable})
    column_labels = [string.(data.column_names)]
    sch           = Tables.schema(_get_data(data))

    if !isnothing(sch)
        types::Vector{String} = _compact_type_str.([sch.types...])
        push!(column_labels, types)
    end

    return column_labels
end

function _guess_column_labels(data::AbstractVecOrMat)
    return [parent(["Col. $(string(i))" for i in axes(data, 2)])]
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
function _preprocess_data(data::AbstractVecOrMat)
    # If the data vector or matrix follows the Tables.jl API, we must use it directly.
    Tables.istable(data) &&
        return Tables.columnaccess(data) ? ColumnTable(data) : RowTable(data)

    return data
end

function _preprocess_data(dict::AbstractDict)
    return hcat(collect(keys(dict)), collect(values(dict)))
end

function _preprocess_data(@nospecialize(data::Any))
    # This is the fallback action to guess the column label. Hence, if data does not support
    # Tables.jl API, we must throw an error.
    !Tables.istable(data) && error("`pretty_table` does not support objects of type `$(typeof(data))`.")
    return Tables.columnaccess(data) ? ColumnTable(data) : RowTable(data)
end

"""
    _process_merge_column_label_specification(column_labels::Vector{T}, num_columns::Int) where T <: AbstractVector -> Vector{Vector{Any}}, Vector{MergeCells}

Process the column label specification by replacing `MultiColumn` objects in `column_labels`
and adding the correct specification to `merge_column_label_cells`. This function returns
the new objects that must replace the olds `column_labels` and the
`merge_column_label_cells`.

The number of columns in the table must be passed in `num_column` so the function can verify
the correctness of the specification.
"""
function _process_merge_column_label_specification(
    column_labels::Vector{T},
    num_columns::Int
) where T <: AbstractVector
    # We only need to process the column labels if we have an elements of type `MultiColumn`
    # or `EmptyCells` in the column labels. Otherwise, we can return the current column
    # label, reducing the allocations.
    need_processing = false

    for line in column_labels
        for column in line
            if (column isa MultiColumn) || (column isa EmptyCells)
                need_processing = true
                break
            end
        end

        need_processing && break
    end

    !need_processing && return column_labels, nothing

    processed_column_labels = Vector{Any}(undef, length(column_labels))

    merge_column_label_cells = MergeCells[]

    for l in eachindex(column_labels)
        column_label_line = Any[]
        line = column_labels[l]

        for c in eachindex(line)
            column = line[c]

            if column isa MultiColumn
                push!(merge_column_label_cells, MergeCells(
                    l,
                    length(column_label_line) + 1,
                    column.column_span,
                    column.data,
                    column.alignment
                ))

                for _ in 1:column.column_span
                    push!(column_label_line, "")
                end

                continue

            elseif column isa EmptyCells
                for _ in 1:column.number_of_cells
                    push!(column_label_line, "")
                end

                continue
            end

            push!(column_label_line, column)
        end

        # Check if the number of processed columns is correct.
        npc = length(column_label_line)
        npc != num_columns && throw(ArgumentError(
            "The number of columns ($npc) obtained from the specifications in the line #$(l) of `column_label` does not match the number of columns in the table ($num_columns)."
        ))

        processed_column_labels[l] = column_label_line
    end

    return processed_column_labels, merge_column_label_cells
end

"""
    _validate_merge_cell_specification(table_data::TableData) -> Nothing

Validate the merge cell specification in `table_data`. If something is wrong, this function
throws an error.
"""
function _validate_merge_cell_specification(table_data::TableData)
    isnothing(table_data.merge_column_label_cells) && return nothing

    num_column_label_rows = length(table_data.column_labels)
    mc = table_data.merge_column_label_cells

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

        mi.i > num_column_label_rows && throw(ArgumentError(
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

            mi.i != mj.i && continue

            mj_beg = mj.j
            mj_end = mj.j + mj.column_span - 1

            ((mi_end >= mj_beg) && (mj_end >= mi_beg)) && throw(ArgumentError(
                "The specifications #$i and #$j for merging cells overlap."
            ))
        end
    end

    return nothing
end
