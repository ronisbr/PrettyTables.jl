## Description #############################################################################
#
# Define the main function for printing tables.
#
############################################################################################

export pretty_table

function pretty_table(data::Any; kwargs...)
    io = stdout isa Base.TTY ? IOContext(stdout, :limit => true) : stdout
    return pretty_table(io, data; kwargs...)
end

function pretty_table(::Type{String}, data::Any; color::Bool = false, kwargs...)
    io = IOContext(IOBuffer(), :color => color)
    pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(
    @nospecialize(io::IO),
    data::Any;

    # == Table Sections ====================================================================

    title::String = "",
    subtitle::String = "",
    column_labels::Union{Nothing, AbstractVector} = nothing,
    stubhead_label::String = "",
    row_number_column_label::String = "Row",
    row_labels::Union{Nothing, Vector{String}} = nothing,
    row_group_labels::Union{Nothing, Vector{Pair{Int, String}}} = nothing,
    summary_cell::Union{Nothing, Function, AbstractVector{Any}} = nothing,
    summary_row_label::String = "",
    footnotes::Union{Nothing, Vector{Pair{NTuple{2, Int}, String}}} = nothing,
    source_notes::String = "",

    # == Alignments ========================================================================

    alignment::Union{Symbol, Vector{Symbol}} = :r,
    continuation_row_alignment = nothing,
    column_label_alignment::Union{Nothing, Symbol, Vector{Symbol}} = nothing,
    row_number_column_alignment::Symbol = :r,
    row_label_alignment::Symbol = :r,

    # == Other Configurations ==============================================================

    cell_alignment::Union{Nothing, Dict{NTuple{2, Int}, Symbol}, Vector{Function}} = nothing,
    compact_printing::Bool = true,
    formatters::Union{Nothing, Vector{T} where T <: Any} = nothing,
    limit_printing::Bool = true,
    maximum_number_of_columns::Int = -1,
    maximum_number_of_rows::Int = -1,
    renderer::Symbol = :print,
    show_omitted_cell_summary::Bool = true,
    show_row_number_column::Bool = false,
    vertical_crop_mode::Symbol = :bottom,
    kwargs...
)
    # == Table Preprocessing ===============================================================

    # Check for circular dependency.
    ptd = get(io, :__PRETTY_TABLES__DATA__, nothing)

    if !isnothing(ptd)
        context = IOContext(
            io,
            :compact => compact_printing,
            :limit   => limit_printing
        )

        # In this case, `ptd` is a vector with the data printed by PrettyTables.jl. Hence,
        # we need to search if the current one is inside this vector. If true, we have a
        # circular dependency.
        for d in ptd
            if d === data
                return _html__circular_reference(context)
            end
        end

        # Otherwise, we must push the current data to the vector.
        push!(ptd, data)
    else
        context = IOContext(
            io,
            :__PRETTY_TABLES__DATA__ => Any[data],
            :compact                 => compact_printing,
            :limit                   => limit_printing
        )
    end

    pdata = _preprocess_data(data)

    ax = axes(pdata)

    if length(ax) == 1
        num_columns = 1
        num_rows = length(pdata)
    elseif length(ax) == 2
        num_rows, num_columns = size(pdata)
    else
        throw(ArgumentError("`pretty_table` does not support data with more than 2 dimensions."))
    end

    if isnothing(column_labels)
        column_labels = _guess_column_labels(pdata)
    else
        for cl in column_labels
            length(cl) != num_columns &&
                error("Each vector in `column_labels` must have the same number of elements as the table columns ($num_columns).")
        end
    end

    # == Check and Process Inputs ==========================================================

    if (alignment isa AbstractVector) && (length(alignment) != num_columns)
        error("The length of vector `alignment` ($(length(alignment))) must be equal to the number of columns ($num_columns).")
    end

    if cell_alignment isa Dict
        # If it is a `Dict`, `cell_alignment[(i,j)]` contains the desired alignment for the
        # cell `(i,j)`. Thus, we need to create a wrapper function.
        cell_alignment_dict = copy(cell_alignment)

        cell_alignment = [
            (_, i, j) -> begin
                if haskey(cell_alignment_dict, (i, j))
                    return cell_alignment_dict[(i, j)]
                else
                    return nothing
                end
            end
        ]
    end

    if isnothing(column_label_alignment)
        column_label_alignment = alignment
    end

    if summary_cell isa AbstractVector
        summary_cell_func = (data::Any, j::Int) -> summary_cell[j + begin]
    else
        summary_cell_func = summary_cell
    end

    if (renderer != :print) && (renderer != :show)
        error("The renderer must be `:print` or `:show`.")
    end

    # == Table Data and Printing Specification =============================================

    table_data = TableData(
        pdata,
        title,
        subtitle,
        column_labels,
        stubhead_label,
        show_row_number_column,
        row_number_column_label,
        row_labels,
        row_group_labels,
        summary_row_label,
        summary_cell_func,
        footnotes,
        source_notes,
        cell_alignment,
        column_label_alignment,
        continuation_row_alignment,
        alignment,
        row_number_column_alignment,
        row_label_alignment,
        formatters,
        num_rows,
        num_columns,
        maximum_number_of_columns,
        maximum_number_of_rows,
        vertical_crop_mode
    )

    pspec = PrintingSpec(
        context,
        table_data,
        renderer,
        show_omitted_cell_summary
    )

    # When wrapping `stdout` in `IOContext` in Jupyter, `io.io` is not equal to `stdout`
    # anymore. Hence, we need to check if `io` is `stdout` before calling the HTML back end.
    is_stdout = (io === stdout) || ((io isa IOContext) && (io.io === stdout))
    _html__print(pspec; is_stdout, kwargs...)

    return nothing
end

############################################################################################
#                                    Private Functions                                     #
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

function _preprocess_data(data::Any)
    # This is the fallback action to guess the column label. Hence, if data does not support
    # Tables.jl API, we must throw an error.
    !Tables.istable(data) && error("`pretty_table` does not support objects of type `$(typeof(data))`.")

    if Tables.columnaccess(data)
        return ColumnTable(data)
    else
        return RowTable(data)
    end
end
