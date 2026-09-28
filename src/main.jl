## Description #############################################################################
#
# Define the main function for printing tables.
#
############################################################################################

export pretty_table

# Back ends that can be selected using the keyword `backend`.
const _AVAILABLE_BACKENDS = (:text, :markdown, :html, :latex, :typst, :excel, :docx)

function pretty_table(@nospecialize(data::Any); kwargs...)
    io = stdout isa Base.TTY ? IOContext(stdout, :limit => true) : stdout
    return pretty_table(io, data; kwargs...)
end

function pretty_table(
    ::Type{String}, @nospecialize(data::Any); color::Bool = false, kwargs...
)
    io = IOContext(IOBuffer(), :color => color, :displaysize => (-1, -1))
    pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(::Type{HTML}, @nospecialize(data::Any); kwargs...)
    # If the keywords do not set the back end, or set it to `:auto`, resolve it from the table
    # format, using the HTML back end by default. Notice that a backend-agnostic
    # `TableFormat` does not select a back end.
    str = if get(kwargs, :backend, :auto) == :auto
        pretty_table(
            String,
            data;
            kwargs...,
            backend = _resolve_printing_backend(kwargs; default = :html),
        )
    else
        pretty_table(String, data; kwargs...)
    end

    return HTML(str)
end

# We declare this function with all the common keywords and after we call an internal
# function where all those keywords are arguments. In this case, we can use `@nospecialize`
# in the first two arguments. The other option would be to wrap the keywords inside a
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
    row_label_column_alignment::Symbol = :r,
    row_group_label_alignment::Symbol = :l,
    row_number_column_alignment::Symbol = :r,
    source_note_alignment::Symbol = :l,
    subtitle_alignment::Symbol = :c,
    title_alignment::Symbol = :c,
    cell_alignment::Union{
        Nothing, Vector{Pair{NTuple{2, Int}, Symbol}}, Vector{F} where F <: Function
    } = nothing,

    # == Other Configurations ==============================================================

    formatters::Union{Nothing, Vector{T} where T <: Any} = nothing,
    maximum_number_of_columns::Int = -1,
    maximum_number_of_rows::Int = -1,
    merge_column_label_cells::Union{Symbol, Vector{MergeCells}} = :auto,
    new_line_at_end::Bool = true,
    show_first_column_label_only::Bool = false,
    show_row_number_column::Bool = false,
    vertical_crop_mode::Symbol = :bottom,
    kwargs...,
)
    return _pretty_table(
        io,
        data,
        backend,

        # == Other Keyword Arguments =======================================================

        kwargs,

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
        row_label_column_alignment,
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
        new_line_at_end,
        show_first_column_label_only,
        show_row_number_column,
        vertical_crop_mode,
    )
end

# == PrettyTable Structure =================================================================

# The configurations stored in the table are passed as keywords. Notice that the keywords
# passed to the function have precedence over them. The method without the IO is not
# required because the generic one already dispatches to the method with the IO.

function pretty_table(@nospecialize(io::IO), pt::PrettyTable; kwargs...)
    return pretty_table(io, pt.data; pt.configurations..., kwargs...)
end

function pretty_table(::Type{String}, pt::PrettyTable; color::Bool = false, kwargs...)
    return pretty_table(String, pt.data; color, pt.configurations..., kwargs...)
end

function pretty_table(::Type{HTML}, pt::PrettyTable; kwargs...)
    return pretty_table(HTML, pt.data; pt.configurations..., kwargs...)
end

function show(io::IO, pt::PrettyTable)
    backend = get(pt.configurations, :backend, :auto)

    if backend == :auto
        # If the backend is `:auto`, we need to resolve it from the `table_format` keyword.
        backend = _resolve_printing_backend(pt.configurations)
    end

    # For the text backend, we need to reserve one display line because the `show` function
    # adds a new line at the end. Notice that we must keep the lines reserved by the user.
    if backend == :text
        reserved_display_lines = get(pt.configurations, :reserved_display_lines, 0) + 1

        return pretty_table(io, pt; new_line_at_end = false, reserved_display_lines)
    else
        return pretty_table(io, pt; new_line_at_end = false)
    end
end

############################################################################################
#                                         Private                                          #
############################################################################################

# This function converts the common keywords to positional arguments. Hence, we can use
# `@nospecialize` at the first two arguments and at the back end keywords, improving the
# time to print the first table.
#
# NOTE: The constant propagation is disabled because the keyword entry point calls this
# function with many constant default values. Otherwise, every new call site of
# `pretty_table` would infer this entire function again with those constants.
Base.@constprop :none Base.@nospecializeinfer function _pretty_table(
    @nospecialize(io::IO),
    @nospecialize(data::Any),
    backend::Symbol,

    # == Other Keyword Arguments ===========================================================

    # NOTE: The keywords of the back end are passed as a positional argument without
    # specialization so that this function is compiled only once. Otherwise, each distinct
    # set of keywords passed by the user would compile this entire function again. This
    # argument must stay within the first 32 positional arguments because `@nospecialize`
    # is ignored (with a warning) beyond that limit.
    @nospecialize(kwargs),

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
    row_label_column_alignment::Symbol,
    row_group_label_alignment::Symbol,
    row_number_column_alignment::Symbol,
    source_note_alignment::Symbol,
    subtitle_alignment::Symbol,
    title_alignment::Symbol,

    # == Other Configurations ==============================================================

    cell_alignment::Union{
        Nothing, Vector{Pair{NTuple{2, Int}, Symbol}}, Vector{F} where F <: Function
    },
    formatters::Union{Nothing, Vector{T} where T <: Any},
    maximum_number_of_columns::Int,
    maximum_number_of_rows::Int,
    merge_column_label_cells::Union{Symbol, Vector{MergeCells}},
    new_line_at_end::Bool,
    show_first_column_label_only::Bool,
    show_row_number_column::Bool,
    vertical_crop_mode::Symbol,
)

    # == Table Preprocessing ===============================================================

    (backend == :auto) || (backend ∈ _AVAILABLE_BACKENDS) || throw(
        ArgumentError(
            "Invalid back end `:$backend`. The available back ends are `:auto`, " *
            join(("`:$b`" for b in _AVAILABLE_BACKENDS), ", ", ", and ") *
            "."
        )
    )

    # Check for circular dependency.
    ptd = get(io, :__PRETTY_TABLES__DATA__, nothing)

    if !isnothing(ptd)
        context = IOContext(io, :compact => compact_printing, :limit => limit_printing)

        # In this case, `ptd` is a vector with the data printed by PrettyTables.jl. Hence,
        # we need to search if the current one is inside this vector. If true, we have a
        # circular dependency.
        for d in ptd
            if d === data
                (backend == :auto) && (backend = _resolve_printing_backend(kwargs))
                print(io, _circular_reference_str(backend))
                return nothing
            end
        end

        # Otherwise, we must push the current data to the vector. This action is performed
        # just before calling the printing backend so we can remove the data afterward.
    else
        context = IOContext(
            io,
            :__PRETTY_TABLES__DATA__ => Any[data],
            :compact                 => compact_printing,
            :limit                   => limit_printing,
        )
    end

    pdata = _preprocess_data(data)

    # == Check Inputs ======================================================================

    ax = axes(pdata)

    if length(ax) == 1
        num_rows = length(pdata)
        num_columns = num_rows > 0 ? 1 : 0

        first_row_index = first(first(ax))
        first_column_index = 1
    else
        # Notice that `_preprocess_data` rejects data with more than 2 dimensions.
        num_rows, num_columns = size(pdata)

        first_row_index = first(first(ax))
        first_column_index = first(last(ax))
    end

    # If we reach this point and `column_labels` is nothing, we must guess it.
    if isnothing(column_labels)
        column_labels = if pdata isa Union{ColumnTable, RowTable}
            _guess_column_labels(pdata)
        else
            _guess_column_labels(data)
        end
    end

    # If the elements of the column labels are not vectors, we must wrap it into a vector
    # because the user probably only wants one row for the column label. Notice that we must
    # check the elements if the element type is abstract, e.g., in a `Vector{Any}` with one
    # vector per row.
    if !_is_vector_of_label_rows(column_labels)
        column_labels = [column_labels]
    elseif !(eltype(column_labels) <: AbstractVector)
        column_labels = AbstractVector[row for row in column_labels]
    end

    isempty(column_labels) && throw(
        ArgumentError(
            "`column_labels` must have at least one row of labels. Use `show_column_labels = false` to hide the column labels."
        )
    )

    # If the user provided the `column_labels` and set `merge_column_label_cells` to
    # `:auto`, we will rebuild those two parameters to take into account the merged columns.
    local _merge_column_label_cells

    if merge_column_label_cells isa Symbol
        if merge_column_label_cells == :auto
            column_labels, _merge_column_label_cells = _process_merge_column_label_specification(
                column_labels, num_columns
            )
        else
            _merge_column_label_cells = nothing
        end
    else
        _merge_column_label_cells = merge_column_label_cells
    end

    # Check the column labels.
    for cl in column_labels
        length(cl) != num_columns && throw(
            ArgumentError(
                "Each vector in `column_labels` must have the same number of elements as the table columns ($num_columns).",
            ),
        )
    end

    if (renderer != :print) && (renderer != :show)
        throw(ArgumentError("The renderer must be `:print` or `:show`."))
    end

    !isnothing(footnotes) && _validate_footnotes(
        footnotes,
        num_rows,
        num_columns,
        length(column_labels),
        isnothing(summary_rows) ? 0 : length(summary_rows),
    )

    if (vertical_crop_mode != :bottom) && (vertical_crop_mode != :middle)
        throw(ArgumentError("The vertical crop mode must be `:bottom` or `:middle`."))
    end

    if (alignment isa AbstractVector) && (length(alignment) != num_columns)
        throw(
            ArgumentError(
                "The length of vector `alignment` ($(length(alignment))) must be equal to the number of columns ($num_columns).",
            ),
        )
    end

    if (column_label_alignment isa AbstractVector) &&
        (length(column_label_alignment) != num_columns)
        throw(
            ArgumentError(
                "The length of vector `column_label_alignment` ($(length(column_label_alignment))) must be equal to the number of columns ($num_columns).",
            ),
        )
    end

    # Notice that the extra row labels are ignored.
    if !isnothing(row_labels) && (length(row_labels) < num_rows)
        throw(
            ArgumentError(
                "The vector `row_labels` ($(length(row_labels))) must have at least one element per row ($num_rows).",
            ),
        )
    end

    if cell_alignment isa Vector{Pair{NTuple{2, Int}, Symbol}}
        # If it is a `Vector{Pair{NTuple{2, Int}, Symbol}}`, it contains a set of `(i, j) =>
        # alignment` with the desired `alignment` for the cell `(i, j)`. Thus, we need to
        # create a wrapper function.
        cell_alignment_vect = copy(cell_alignment)

        cell_alignment = [(_, i, j) -> begin
            for p in cell_alignment_vect
                if first(p) == (i, j)
                    return last(p)
                end
            end

            return nothing
        end]
    end

    # Validate the alignments and convert them to lowercase symbols so that every back end
    # receives only `:l`, `:c`, or `:r`.
    alignment                   = _normalize_alignment(alignment)
    column_label_alignment      = _normalize_alignment(column_label_alignment)
    continuation_row_alignment  = _normalize_alignment(continuation_row_alignment)
    footnote_alignment          = _normalize_alignment(footnote_alignment)
    row_group_label_alignment   = _normalize_alignment(row_group_label_alignment)
    row_label_column_alignment  = _normalize_alignment(row_label_column_alignment)
    row_number_column_alignment = _normalize_alignment(row_number_column_alignment)
    source_note_alignment       = _normalize_alignment(source_note_alignment)
    subtitle_alignment          = _normalize_alignment(subtitle_alignment)
    title_alignment             = _normalize_alignment(title_alignment)

    if isnothing(column_label_alignment)
        column_label_alignment = alignment
    end

    if isnothing(summary_rows) && !isnothing(summary_row_labels)
        throw(ArgumentError("`summary_row_labels` requires `summary_rows`."))
    end

    if !isnothing(summary_rows) && !isnothing(summary_row_labels)
        length(summary_rows) != length(summary_row_labels) && throw(
            ArgumentError(
                "The length of `summary_rows` ($(length(summary_rows))) must be equal to the length of `summary_row_labels` ($(length(summary_row_labels))).",
            ),
        )
    end

    # An empty vector of summary rows means that there are no summary rows. Otherwise, the
    # printing state would enter the summary row section and access the first element.
    if !isnothing(summary_rows) && isempty(summary_rows)
        summary_rows       = nothing
        summary_row_labels = nothing
    end

    if !isnothing(summary_rows) && isnothing(summary_row_labels)
        summary_row_labels = SummaryLabelIterator(summary_rows)
    end

    # If the column labels are hidden, the merged column label cells can never be rendered.
    # Dropping the specification here avoids inconsistent border junctions and spurious
    # width adjustments computed for labels that are not printed.
    if !show_column_labels
        _merge_column_label_cells = nothing
    end

    if show_first_column_label_only
        column_labels = [column_labels[1]]

        # The merged cell specification can reference the dropped column label rows. Hence,
        # we must keep only the specifications related to the first one.
        if !isnothing(_merge_column_label_cells)
            _merge_column_label_cells = filter(m -> m.i == 1, _merge_column_label_cells)
        end
    end

    # If the table has only one row more than a positive `maximum_number_of_rows`, we will not
    # crop the table because we need one additional line to show the continuation marks
    # anyway.
    if (maximum_number_of_rows > 0) && (num_rows == maximum_number_of_rows + 1)
        maximum_number_of_rows = maximum_number_of_rows + 1
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
        row_label_column_alignment,
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
        vertical_crop_mode,
    )

    _validate_merge_cell_specification(table_data)

    pspec = PrintingSpec(
        context, table_data, renderer, show_omitted_cell_summary, new_line_at_end
    )

    # If backend is `:auto`, obtain the backend from the `table_format` keyword. If it does
    # not exist, use `:text`.
    if backend == :auto
        backend = _resolve_printing_backend(kwargs)
    end

    # When wrapping `stdout` in `IOContext`, sometimes `io.io` is not equal to `stdout`
    # anymore. Hence, we need to check if `io` is `stdout` before calling the backend
    # functions.
    is_stdout = (io === stdout) || ((io isa IOContext) && (io.io === stdout))

    # Register the current data in the circular reference vector while printing, removing
    # it afterward. Hence, only the ancestors of the current table stay in the vector,
    # avoiding false positives when the same object appears in two different cells.
    !isnothing(ptd) && push!(ptd, data)

    try
        # Call the printing backend.
        if backend ∈ (:excel, :docx)
            return _printing_backend(Val(backend), pspec; is_stdout, kwargs...)
        else
            _printing_backend(Val(backend), pspec; is_stdout, kwargs...)
        end
    finally
        !isnothing(ptd) && pop!(ptd)
    end

    return nothing
end

"""
    _resolve_generic_configurations(kwargs::NamedTuple, table_format_converter::F1, table_style_converter::F2) where {F1 <: Function, F2 <: Function} -> NamedTuple

Convert the `table_format` and `style` entries of `kwargs`, if present, using the back end
converters `table_format_converter` and `table_style_converter`, keeping every other entry
untouched.

This function is the single place where the backend-agnostic `TableFormat` and `TableStyle`
are converted to the back end native objects. Performing the conversion here is critical
for the time to print the first table: the back end print functions only ever see the
native types, so they reuse the method instances compiled during the package
precompilation. If the generic objects reached the back end print functions, every large
rendering body would be compiled again for the generic keyword types.
"""
function _resolve_generic_configurations(
    kwargs::NamedTuple,
    table_format_converter::F1,
    table_style_converter::F2,
) where {F1 <: Function, F2 <: Function}
    haskey(kwargs, :table_format) && (
        kwargs = merge(
            kwargs,
            (; table_format = table_format_converter(kwargs.table_format))
        )
    )

    haskey(kwargs, :style) && (
        kwargs = merge(kwargs, (; style = table_style_converter(kwargs.style)))
    )

    return kwargs
end

"""
    _validate_footnotes(footnotes::Vector{Pair{FootnoteTuple, String}}, num_rows::Int, num_columns::Int, num_column_label_rows::Int, num_summary_rows::Int) -> Nothing

Throw an `ArgumentError` if a footnote in `footnotes` references an unknown section or a cell
outside that section, considering a table with `num_rows` data rows, `num_columns` data
columns, `num_column_label_rows` rows of column labels, and `num_summary_rows` summary rows.
Notice that the footnotes referencing a cell that is not printed because the table is
cropped are valid.
"""
function _validate_footnotes(
    footnotes::Vector{Pair{FootnoteTuple, String}},
    num_rows::Int,
    num_columns::Int,
    num_column_label_rows::Int,
    num_summary_rows::Int,
)
    for ((section, i, j), _) in footnotes
        # Number of rows and columns of the section. A column range of `nothing` means that
        # the column index is not used.
        rows, columns = if section ∈ (:title, :subtitle)
            1, nothing
        elseif section === :column_label
            num_column_label_rows, num_columns
        elseif section === :data
            num_rows, num_columns
        elseif section ∈ (:row_number, :row_label)
            num_rows, nothing
        elseif section === :summary_row_label
            num_summary_rows, nothing
        elseif section === :summary_row_cell
            num_summary_rows, num_columns
        else
            throw(
                ArgumentError(
                    "Invalid footnote section `:$section`. The available sections are `:title`, `:subtitle`, `:column_label`, `:data`, `:row_number`, `:row_label`, `:summary_row_label`, and `:summary_row_cell`."
                )
            )
        end

        if !(1 <= i <= rows) || (!isnothing(columns) && !(1 <= j <= columns))
            throw(
                ArgumentError(
                    "The footnote `($(repr(section)), $i, $j)` references a cell outside the section `:$section`."
                )
            )
        end
    end

    return nothing
end

"""
    _circular_reference_str(backend::Symbol) -> String

Return the sentinel printed in place of data that references itself, escaped for the
`backend` if it is emitted as raw markup (e.g., when a cell is rendered using the MIME
representation of the nested table).
"""
function _circular_reference_str(backend::Symbol)
    str = "#= circular reference =#"
    backend == :latex && return _latex__escape_str(str)
    backend == :typst && return _typst__escape_str(str)
    return str
end

"""
    _is_vector_of_label_rows(column_labels::AbstractVector) -> Bool

Return `true` if `column_labels` is a vector in which each element is a row of column labels,
or `false` if it is a single row of column labels.
"""
function _is_vector_of_label_rows(@nospecialize(column_labels::AbstractVector))
    eltype(column_labels) <: AbstractVector && return true
    isempty(column_labels) && return false
    return all(x -> x isa AbstractVector, column_labels)
end

"""
    _printing_backend(::Val{backend}, pspec::PrintingSpec; is_stdout::Bool, kwargs...)

Call the appropriate printing `backend` using the printing specification `pspec`. The
keyword argument `is_stdout` is `true` if the user wants to output the table to the
`stdout`. Notice that the backend-agnostic `table_format` and `style` objects are converted
to the back end native types here, before the back end print function is called (see
[`_resolve_generic_configurations`](@ref)).
"""
function _printing_backend(::Val{:latex}, pspec::PrintingSpec; is_stdout::Bool, kwargs...)
    nt = _resolve_generic_configurations(
        values(kwargs), _latex__table_format, _latex__table_style
    )
    _latex__print(pspec; nt...)
    return nothing
end

function _printing_backend(::Val{:html}, pspec::PrintingSpec; is_stdout::Bool, kwargs...)
    nt = _resolve_generic_configurations(
        values(kwargs), _html__table_format, _html__table_style
    )
    _html__print(pspec; is_stdout, nt...)
    return nothing
end

function _printing_backend(::Val{:typst}, pspec::PrintingSpec; is_stdout::Bool, kwargs...)
    nt = _resolve_generic_configurations(
        values(kwargs), _typst__table_format, _typst__table_style
    )
    _typst__print(pspec; is_stdout, nt...)
    return nothing
end

function _printing_backend(::Val{:excel}, pspec::PrintingSpec; is_stdout::Bool, kwargs...)
    nt = _resolve_generic_configurations(
        values(kwargs), _excel__table_format, _excel__table_style
    )
    return _excel__print(pspec; nt...)
end

function _printing_backend(::Val{:docx}, pspec::PrintingSpec; is_stdout::Bool, kwargs...)
    nt = _resolve_generic_configurations(
        values(kwargs), _docx__table_format, _docx__table_style
    )
    return _docx__print(pspec; nt...)
end

function _printing_backend(
    ::Val{:markdown}, pspec::PrintingSpec; is_stdout::Bool, kwargs...
)
    nt = _resolve_generic_configurations(
        values(kwargs), _markdown__table_format, _markdown__table_style
    )
    _markdown__print(pspec; nt...)
    return nothing
end

function _printing_backend(::Val{:text}, pspec::PrintingSpec; is_stdout::Bool, kwargs...)
    nt = _resolve_generic_configurations(
        values(kwargs), _text__table_format, _text__table_style
    )

    # The colors of the line designs in a backend-agnostic table format must be converted
    # to the line faces of the text table style since the text table format only stores
    # characters.
    tf = get(kwargs, :table_format, nothing)
    (tf isa TableFormat) && (nt = _text__merge_line_style_colors(nt, tf))

    _text__print_table(pspec; nt...)
    return nothing
end

## == Custom Backend Functions =============================================================

export pretty_table_html_backend
export pretty_table_latex_backend
export pretty_table_markdown_backend
export pretty_table_text_backend
export pretty_table_typst_backend
export pretty_table_excel_backend
export pretty_table_docx_backend

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

function pretty_table_typst_backend(args...; kwargs...)
    return pretty_table(args...; backend = :typst, kwargs...)
end

function pretty_table_excel_backend(args...; kwargs...)
    return pretty_table(args...; backend = :excel, kwargs...)
end

function pretty_table_docx_backend(args...; kwargs...)
    return pretty_table(args...; backend = :docx, kwargs...)
end
