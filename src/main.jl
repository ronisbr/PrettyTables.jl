## Description #############################################################################
#
# Define the main function for printing tables.
#
############################################################################################

# TODO: Add support to Dicts.

export pretty_table

function pretty_table(@nospecialize(data::Any); kwargs...)
    io = stdout isa Base.TTY ? IOContext(stdout, :limit => true) : stdout
    return pretty_table(io, data; kwargs...)
end

function pretty_table(::Type{String}, @nospecialize(data::Any); color::Bool = false, kwargs...)
    io = IOContext(IOBuffer(), :color => color, :displaysize =>  (-1, -1))
    pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(::Type{HTML}, @nospecialize(data::Any); kwargs...)
    # If the keywords does not set the back end or the table format, use the HTML back end
    # by default.
    str = if !haskey(kwargs, :backend) && !haskey(kwargs, :table_format)
        pretty_table(String, data; backend = :html, kwargs...)
    else
        pretty_table(String, data; kwargs...)
    end

    return HTML(str)
end

# We declare this function with all the common keywords and after we call an internal
# function where all those keywords are arguments. In this case, we can use `@nospecialize`
# in the first two arguments. The other options would be wrap the keywords inside a
# `kwargs...`. However, in the latter, we will not have keyword completion in REPL.
function pretty_table(
    io::IO,
    data::Any;

    backend::Symbol = :auto,

    # == Arguments for the IOContext =======================================================

    compact_printing::Bool = true,
    limit_printing::Bool = true,

    # == Arguments for the Printing Specification ==========================================

    show_omitted_cell_summary::Bool = true,
    renderer::Symbol = :print,

    # == Table Sections ====================================================================

    title::String = "",
    subtitle::String = "",
    stubhead_label::String = "",
    row_number_column_label::String = "Row",
    row_labels::Union{Nothing, AbstractVector} = nothing,
    row_group_labels::Union{Nothing, Vector{Pair{Int, String}}} = nothing,
    column_labels::Union{Nothing, AbstractVector} = nothing,
    show_column_labels::Bool = true,
    summary_rows::Union{Nothing, Vector{T} where T <: Any} = nothing,
    summary_row_labels::Union{Nothing, Vector{String}} = nothing,
    footnotes::Union{Nothing, Vector{Pair{FootnoteTuple, String}}} = nothing,
    source_notes::String = "",

    # == Alignments ========================================================================

    alignment::Union{Symbol, Vector{Symbol}} = :r,
    column_label_alignment::Union{Nothing, Symbol, Vector{Symbol}} = nothing,
    continuation_row_alignment::Union{Nothing, Symbol} = nothing,
    footnote_alignment::Symbol = :l,
    row_label_alignment::Symbol = :r,
    row_group_label_alignment::Symbol = :l,
    row_number_column_alignment::Symbol = :r,
    source_note_alignment::Symbol = :l,
    subtitle_alignment::Symbol = :c,
    title_alignment::Symbol = :c,
    cell_alignment::Union{Nothing, Vector{Pair{NTuple{2, Int}, Symbol}}, Vector{Function}} = nothing,

    # == Other Configurations ==============================================================

    formatters::Union{Nothing, Vector{T} where T <: Any} = nothing,
    maximum_number_of_columns::Int = -1,
    maximum_number_of_rows::Int = -1,
    merge_column_label_cells::Union{Symbol, Vector{MergeCells}} = :auto,
    show_first_column_label_only::Bool = false,
    show_row_number_column::Bool = false,
    vertical_crop_mode::Symbol = :bottom,
    kwargs...
)
    return _pretty_table(
        io,
        data,

        backend,

        # == Arguments for the IOContext ===================================================

        compact_printing,
        limit_printing,

        # == Arguments for the Printing Specification ======================================

        show_omitted_cell_summary,
        renderer,

        # == Table Sections ================================================================

        title,
        subtitle,
        stubhead_label,
        row_number_column_label,
        row_labels,
        row_group_labels,
        column_labels,
        show_column_labels,
        summary_rows,
        summary_row_labels,
        footnotes,
        source_notes,

        # == Alignments ====================================================================

        alignment,
        column_label_alignment,
        continuation_row_alignment,
        footnote_alignment,
        row_label_alignment,
        row_group_label_alignment,
        row_number_column_alignment,
        source_note_alignment,
        subtitle_alignment,
        title_alignment,

        # == Other Configurations ==========================================================

        cell_alignment,
        formatters,
        maximum_number_of_columns,
        maximum_number_of_rows,
        merge_column_label_cells,
        show_first_column_label_only,
        show_row_number_column,
        vertical_crop_mode;

        # == Other Keyword Arguments =======================================================

        kwargs...
    )
end

# == PrettyTable Structure =================================================================

function pretty_table(pt::PrettyTable; kwargs...)
    return pretty_table(stdout, pt; kwargs...)
end

function pretty_table(io::IO, pt::PrettyTable; kwargs...)
    # Get the named tuple with the configurations.
    dictkeys = (collect(keys(pt.configurations))...,)
    dictvals = (collect(values(pt.configurations))...,)
    nt = NamedTuple{dictkeys}(dictvals)

    return pretty_table(io, pt.data; merge(nt, kwargs)...)
end

function pretty_table(::Type{String}, pt::PrettyTable; color::Bool = false, kwargs...)
    # Get the named tuple with the configurations.
    dictkeys = (collect(keys(pt.configurations))...,)
    dictvals = (collect(values(pt.configurations))...,)
    nt = NamedTuple{dictkeys}(dictvals)

    return pretty_table(String, pt.data; color = color, merge(nt, kwargs)...)
end

function pretty_table(::Type{HTML}, pt::PrettyTable; kwargs...)
    # Get the named tuple with the configurations.
    dictkeys = (collect(keys(pt.configurations))...,)
    dictvals = (collect(values(pt.configurations))...,)
    nt = NamedTuple{dictkeys}(dictvals)

    return pretty_table(HTML, pt.data; merge(nt, kwargs)...)
end

############################################################################################
#                                         Private                                          #
############################################################################################

# This function converts the common keywords to positional arguments. Hence, we can use
# `@nospecialize` at the first two arguments, improving the time to print the first table.
function _pretty_table(
    @nospecialize(io::IO),
    @nospecialize(data::Any),

    backend::Symbol,

    # == Arguments for the IOContext =======================================================

    compact_printing::Bool,
    limit_printing::Bool,

    # == Arguments for the Printing Specification ==========================================

    show_omitted_cell_summary::Bool,
    renderer::Symbol,

    # == Table Sections ====================================================================

    title::String,
    subtitle::String,
    stubhead_label::String,
    row_number_column_label::String,
    row_labels::Union{Nothing, AbstractVector},
    row_group_labels::Union{Nothing, Vector{Pair{Int, String}}},
    column_labels::Union{Nothing, AbstractVector},
    show_column_labels::Bool,
    summary_rows::Union{Nothing, Vector{T} where T <: Any},
    summary_row_labels::Union{Nothing, Vector{String}},
    footnotes::Union{Nothing, Vector{Pair{FootnoteTuple, String}}},
    source_notes::String,

    # == Alignments ========================================================================

    alignment::Union{Symbol, Vector{Symbol}},
    column_label_alignment::Union{Nothing, Symbol, Vector{Symbol}},
    continuation_row_alignment::Union{Nothing, Symbol},
    footnote_alignment::Symbol,
    row_label_alignment::Symbol,
    row_group_label_alignment::Symbol,
    row_number_column_alignment::Symbol,
    source_note_alignment::Symbol,
    subtitle_alignment::Symbol,
    title_alignment::Symbol,

    # == Other Configurations ==============================================================

    cell_alignment::Union{Nothing, Vector{Pair{NTuple{2, Int}, Symbol}}, Vector{Function}},
    formatters::Union{Nothing, Vector{T} where T <: Any},
    maximum_number_of_columns::Int,
    maximum_number_of_rows::Int,
    merge_column_label_cells::Union{Nothing, Symbol, Vector{MergeCells}},
    show_first_column_label_only::Bool,
    show_row_number_column::Bool,
    vertical_crop_mode::Symbol;
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
                print(io, "#= circular reference =#")
                return nothing
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

    # == Check Inputs ======================================================================

    ax = axes(pdata)

    if length(ax) == 1
        num_columns = 1
        num_rows = length(pdata)

        first_row_index = first(first(ax))
        first_column_index = 1
    elseif length(ax) == 2
        num_rows, num_columns = size(pdata)

        first_row_index = first(first(ax))
        first_column_index = first(last(ax))
    else
        throw(ArgumentError("`pretty_table` does not support data with more than 2 dimensions."))
    end

    # If we reach this point and `column_labels` is nothing, we must guess it.
    if isnothing(column_labels)
        column_labels = _guess_column_labels(pdata)
    end

    # If the element type of column labels is not an `AbstractVector`, we must wrap it into
    # a vector because the user probably only wants one row for the column label.
    if !(eltype(column_labels) <: AbstractVector)
        column_labels = [column_labels]
    end

    # If the user provided the `column_labels` and set `merge_column_label_cells` to
    # `:auto`, we will rebuild those two parameters to take into account the merged columns.
    local _merge_column_label_cells

    if merge_column_label_cells isa Symbol
        if merge_column_label_cells == :auto
            column_labels, _merge_column_label_cells =
                _process_merge_column_label_specification(
                    column_labels,
                    num_columns
                )
        else
            _merge_column_label_cells = nothing
        end
    else
        _merge_column_label_cells = merge_column_label_cells
    end

    # Check the column labels.
    for cl in column_labels
        length(cl) != num_columns && throw(ArgumentError(
            "Each vector in `column_labels` must have the same number of elements as the table columns ($num_columns)."
        ))
    end

    if (renderer != :print) && (renderer != :show)
        throw(ArgumentError("The renderer must be `:print` or `:show`."))
    end

    if (alignment isa AbstractVector) && (length(alignment) != num_columns)
        throw(ArgumentError(
            "The length of vector `alignment` ($(length(alignment))) must be equal to the number of columns ($num_columns)."
        ))
    end

    if cell_alignment isa Vector
        # If it is a `Vector`, it contains a set of `(i, j) => alignment` with the desired
        # `alignment` for the cell `(i, j)`. Thus, we need to create a wrapper function.
        cell_alignment_vect = copy(cell_alignment)

        cell_alignment = [
            (_, i, j) -> begin
                for p in cell_alignment_vect
                    if first(p) == (i, j)
                        return last(p)
                    end
                end

                return nothing
            end
        ]
    end

    if isnothing(column_label_alignment)
        column_label_alignment = alignment
    end

    if !isnothing(summary_rows) && !isnothing(summary_row_labels)
        length(summary_rows) != length(summary_row_labels) && throw(ArgumentError(
            "The length of `summary_rows` ($length(summary_rows)) must be equal to the length of `summary_row_labels` ($length(summary_row_labels))."
        ))
    end

    if !isnothing(summary_rows) && isnothing(summary_row_labels)
        summary_row_labels = SummaryLabelIterator(length(summary_rows))
    end

    if show_first_column_label_only
        column_labels = [column_labels[1]]
    end

    # == Table Data and Printing Specification =============================================

    table_data = TableData(
        pdata,
        title,
        subtitle,
        stubhead_label,
        show_row_number_column,
        row_number_column_label,
        column_labels,
        show_column_labels,
        row_labels,
        row_group_labels,
        summary_rows,
        summary_row_labels,
        _merge_column_label_cells,
        footnotes,
        source_notes,
        title_alignment,
        subtitle_alignment,
        cell_alignment,
        column_label_alignment,
        continuation_row_alignment,
        alignment,
        row_number_column_alignment,
        row_label_alignment,
        row_group_label_alignment,
        footnote_alignment,
        source_note_alignment,
        formatters,
        num_rows,
        num_columns,
        first_row_index,
        first_column_index,
        maximum_number_of_columns,
        maximum_number_of_rows,
        vertical_crop_mode
    )

    _validate_merge_cell_specification(table_data)

    pspec = PrintingSpec(
        context,
        table_data,
        renderer,
        show_omitted_cell_summary
    )

    # If backend is `:auto`, obtain the backend from the `table_format` keyword. It it does
    # not exist, use `:text`.
    if backend == :auto
        table_format = get(kwargs, :table_format, nothing)

        if isnothing(table_format)
            backend = :text
        elseif table_format isa HtmlTableFormat
            backend = :html
        elseif table_format isa LatexTableFormat
            backend = :latex
        elseif table_format isa MarkdownTableFormat
            backend = :markdown
        else
            backend = :text
        end
    end

    if backend == :latex
        _latex__print(pspec; kwargs...)
    elseif backend == :html
        # When wrapping `stdout` in `IOContext` in Jupyter, `io.io` is not equal to `stdout`
        # anymore. Hence, we need to check if `io` is `stdout` before calling the HTML back
        # end.
        is_stdout = (io === stdout) || ((io isa IOContext) && (io.io === stdout))
        _html__print(pspec; is_stdout, kwargs...)
    elseif backend == :markdown
        _markdown__print(pspec; kwargs...)
    elseif backend == :text
        _text__print_table(pspec; kwargs...)
    end

    return nothing
end

## == Custom Backend Functions =============================================================

export pretty_table_html_backend
export pretty_table_latex_backend
export pretty_table_markdown_backend
export pretty_table_text_backend

function pretty_table_text_backend(args...; kwargs...)
    return pretty_table(args...; backend = :text, kwargs...)
end

function pretty_table_latex_backend(args...; kwargs...)
    return pretty_table(args...; backend = :latex, kwargs...)
end

function pretty_table_markdown_backend(args...; kwargs...)
    return pretty_table(args...; backend = :markdown, kwargs...)
end

function pretty_table_html_backend(args...; kwargs...)
    return pretty_table(args...; backend = :html, kwargs...)
end
