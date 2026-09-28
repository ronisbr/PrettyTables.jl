## Description #############################################################################
#
# Private functions.
#
############################################################################################

"""
    _guess_column_labels(data) -> Vector{Vector{String}}

Guess the column label associated with `data` in case the user did not pass a default value.
"""
Base.@nospecializeinfer function _guess_column_labels(
    @nospecialize(data::Union{ColumnTable, RowTable})
)
    column_labels = [string.(data.column_names)]
    sch           = Tables.schema(_get_data(data))

    # NOTE: The vector must be built explicitly, asserting the type of its elements, because
    # the schema is not inferred. Otherwise, the result would be converted, and the conversion
    # is invalidated by methods defined by other packages, such as `convert(::Type{String},
    # ::T)`.
    if !isnothing(sch)
        types = String[]

        for T in _schema_types(sch)
            push!(types, _compact_type_str(T)::String)
        end

        push!(column_labels, types)
    end

    return column_labels
end

"""
    _schema_types(sch::Tables.Schema) -> Any

Return the column types of the Tables.jl schema `sch`. Notice that the property `types` of
the schema builds the tuple of types using a generator, which is compiled for each schema
type. Hence, we obtain the types from the type parameter of the schema when it is available.
"""
function _schema_types(sch::Tables.Schema{names, types}) where {names, types}
    types === nothing && return sch.types
    return fieldtypes(types)
end

function _guess_column_labels(data::AbstractVector)
    # A vector without elements is treated as having no columns, exactly like in
    # `_pretty_table`. A matrix, on the other hand, always has `size(data, 2)` columns, even
    # when it has no rows at all.
    #
    # NOTE: This check must not be `isempty(data)`. Since `isempty` is length-based, it is
    # also true for a matrix with zero rows and a positive number of columns, which used to
    # produce an empty column label row that then failed the "one label per column"
    # validation.
    isempty(data) && return [String[]]

    return [String["Col. 1"]]
end

Base.@nospecializeinfer function _guess_column_labels(@nospecialize(data::AbstractMatrix))
    return [parent(["Col. $i" for i in axes(data, 2)])]
end

function _guess_column_labels(::AbstractDict{K, V}) where {K, V}
    return [["Keys", "Values"], [_compact_type_str(K), _compact_type_str(V)]]
end

"""
    _vector_any(v::AbstractVector) -> Vector{Any}

Copy the elements of `v` to a new `Vector{Any}`. This function is compiled only once. Hence,
it must be used to store the vectors whose element types depend on the user input, e.g., the
vectors of functions, avoiding the compilation of `convert` for each new type.
"""
Base.@nospecializeinfer function _vector_any(@nospecialize(v::AbstractVector))
    # The most common vectors are converted directly. Otherwise, each element would require
    # a dynamic dispatch, which is expensive compared to the time to print a small table.
    v isa Vector{Any} && return copy(v)
    v isa Vector{String} && return Vector{Any}(v)
    v isa Vector{Symbol} && return Vector{Any}(v)

    # Notice that we must not iterate over `eachindex(v)` because its type is not inferred,
    # leading to one dynamic dispatch per iteration.
    n  = length(v)::Int
    i₀ = firstindex(v)::Int
    r  = Vector{Any}(undef, n)

    for k in 1:n
        r[k] = v[i₀ + k - 1]
    end

    return r
end

"""
    _preprocess_data(data::Any) -> Any

Preprocess the `data` for printing. This function throws an error if `data` is not supported
by PrettyTables.jl.
"""
Base.@nospecializeinfer function _preprocess_data(@nospecialize(data::AbstractVecOrMat))
    # If the data vector or matrix follows the Tables.jl API, we must use it directly.
    Tables.istable(data) &&
        return Tables.columnaccess(data) ? ColumnTable(data) : RowTable(data)

    return data
end

function _preprocess_data(@nospecialize(data::AbstractArray))
    return throw(
        ArgumentError("`pretty_table` does not support data with more than 2 dimensions.")
    )
end

function _preprocess_data(dict::AbstractDict)
    # A dictionary that complies with the Tables.jl API, e.g., a dictionary of column
    # vectors, is printed as a table. Otherwise, we print its keys and values.
    Tables.istable(dict) &&
        return Tables.columnaccess(dict) ? ColumnTable(dict) : RowTable(dict)

    return hcat(collect(keys(dict)), collect(values(dict)))
end

Base.@nospecializeinfer function _preprocess_data(@nospecialize(data::Any))
    # This is the fallback action to guess the column label. Hence, if data does not support
    # Tables.jl API, we must throw an error.
    !Tables.istable(data) &&
        error("`pretty_table` does not support objects of type `$(typeof(data))`.")
    return Tables.columnaccess(data) ? ColumnTable(data) : RowTable(data)
end

"""
    _process_merge_column_label_specification(
        column_labels::Vector{T},
        num_columns::Int
    ) where T <: AbstractVector -> Vector{Vector{Any}}, Vector{MergeCells}

Process the column label specification by replacing `MultiColumn` objects in `column_labels`
and adding the correct specification to `merge_column_label_cells`. This function returns
the new objects that must replace the old `column_labels` and the
`merge_column_label_cells`.

The number of columns in the table must be passed in `num_columns` so the function can verify
the correctness of the specification.
"""
function _process_merge_column_label_specification(
    column_labels::Vector{T}, num_columns::Int
) where {T <: AbstractVector}
    # We only need to process the column labels if we have elements of type `MultiColumn`
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

    processed_column_labels = Vector{Vector{Any}}(undef, length(column_labels))

    merge_column_label_cells = MergeCells[]

    for l in eachindex(column_labels)
        column_label_line = Any[]
        line = column_labels[l]

        for c in eachindex(line)
            column = line[c]

            if column isa MultiColumn
                push!(
                    merge_column_label_cells,
                    MergeCells(
                        l,
                        length(column_label_line) + 1,
                        column.column_span,
                        column.data,
                        column.alignment,
                    ),
                )

                for _ in 1:(column.column_span)
                    push!(column_label_line, "")
                end

                continue

            elseif column isa EmptyCells
                for _ in 1:(column.number_of_cells)
                    push!(column_label_line, "")
                end

                continue
            end

            push!(column_label_line, column)
        end

        # Check if the number of processed columns is correct.
        npc = length(column_label_line)
        npc != num_columns && throw(
            ArgumentError(
                "The number of columns ($npc) obtained from the specifications in the line #$(l) of `column_labels` does not match the number of columns in the table ($num_columns).",
            ),
        )

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

        mi.column_span < 2 &&
            throw(ArgumentError("The specification #$i has a column span lower than 2."))

        mi.i < 1 && throw(
            ArgumentError(
                "The row index must be greater than 0 in the specification #$i for merging cells.",
            ),
        )

        mi.i > num_column_label_rows && throw(
            ArgumentError(
                "The row index is larger than the number of column label rows in the specification #$i for merging cells.",
            ),
        )

        mi.j < 1 && throw(
            ArgumentError(
                "The column index must be greater than 0 in the specification #$i for merging cells.",
            ),
        )

        mi.j > table_data.num_columns && throw(
            ArgumentError(
                "The column index is larger than the number of table columns in the specification #$i for merging cells.",
            ),
        )

        mi_end > table_data.num_columns && throw(
            ArgumentError(
                "The specification #$i for merging cells references a cell outside the table column range.",
            ),
        )

        for j in (i + 1):lastindex(mc)
            mj = mc[j]

            mi.i != mj.i && continue

            mj_beg = mj.j
            mj_end = mj.j + mj.column_span - 1

            ((mi_end >= mj_beg) && (mj_end >= mi_beg)) && throw(
                ArgumentError("The specifications #$i and #$j for merging cells overlap."),
            )
        end
    end

    return nothing
end

"""
    _check_backend_keywords(options::Type, kwargs, backend::String) -> Nothing

Throw an `ArgumentError` if `kwargs` has a keyword that is not a field of the structure
`options`, which holds the options of the `backend`. Otherwise, a misspelled keyword would
throw a `MethodError` about the internal constructor of `options`.
"""
function _check_backend_keywords(
    @nospecialize(options::Type), @nospecialize(kwargs), backend::String
)
    valid = fieldnames(options)

    for k in keys(kwargs)
        k ∈ valid && continue
        throw(ArgumentError("The keyword `$k` is not supported by the $backend back end."))
    end

    return nothing
end

"""
    _check_column_label_styles(first_line_column_label, column_label, per_column::Type, num_columns::Int) -> Nothing

Throw an `ArgumentError` if the style `first_line_column_label` or `column_label` of a back
end is a vector with one decoration per column, i.e., an object of type `per_column`, whose
length is not `num_columns`.
"""
function _check_column_label_styles(
    @nospecialize(first_line_column_label),
    @nospecialize(column_label),
    @nospecialize(per_column::Type),
    num_columns::Int,
)
    for (name, s) in (
        ("first_line_column_label", first_line_column_label), ("column_label", column_label)
    )
        (s isa per_column) &&
            (length(s) != num_columns) &&
            throw(
                ArgumentError(
                    "The length of `$name` in `style` must be equal to the number of columns ($num_columns).",
                ),
            )
    end

    return nothing
end
