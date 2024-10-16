## Description #############################################################################
#
# Define the main function for printing tables.
#
############################################################################################

export pretty_table

# TODO: Add support to Dicts.

"""
    pretty_table(table; kwargs...) -> Nothing

Print the `table` to the `stdout`.

    pretty_table(io::IO, table; kwargs...) -> Nothing
    pretty_table(String, table; kwargs...) -> String
    pretty_table(HTML,   table; kwargs...) -> HTML

Print the `table` to the output specified by the first argument.

If the first argument is of type `IO`, the function prints the table to it. If it is
`String`, a `String` with the printed table will be returned by the function. If `HTML` is
passed as the first argument, the function will return an `HTML` object with the table.

When printing, the function verifies if `table` complies with **Tables.jl** API. If it is
compliant, this interface will be used to print the table. If it is not compliant, only the
following types are supported:

1. `AbstractVector`: any vector can be printed.
2. `AbstractMatrix`: any matrix can be printed.

`pretty_table` current supports printing table for four backends: text, markdown, html, and
latex. The desired backend can be set using the `backend` keyword argument.

For more information, see the Extended Help section.

# Extended Help

## Table Sections

**PrettyTables.jl** considers the following table sections when printing a table:

```
                                      TITLE
                                     Subtitle
┌────────────┬───────────────────┬──────────────┬──────────────┬───┬──────────────┐
│ Row Number │    Stubhead Label │ Column Label │ Column Label │ ⋯ │ Column Label │
│            │                   │ Column Label │ Column Label │ ⋯ │ Column Label │
│            │                   │       ⋮      │       ⋮      │ ⋯ │       ⋮      │
│            │                   │ Column Label │ Column Label │ ⋯ │ Column Label │
├────────────┼───────────────────┼──────────────┼──────────────┼───┼──────────────┤
│          1 │         Row Label │         Data │         Data │ ⋯ │         Data │
│          2 │         Row Label │         Data │         Data │ ⋯ │         Data │
├────────────┴───────────────────┴──────────────┴──────────────┴───┴──────────────┤
│ Row Group Label                                                                 │
├────────────┬───────────────────┬──────────────┬──────────────┬───┬──────────────┤
│          3 │         Row Label │         Data │         Data │ ⋯ │         Data │
│          4 │         Row Label │         Data │         Data │ ⋯ │         Data │
├────────────┴───────────────────┴──────────────┴──────────────┴───┴──────────────┤
│ Row Group Label                                                                 │
├────────────┬───────────────────┬──────────────┬──────────────┬───┬──────────────┤
│          5 │         Row Label │         Data │         Data │ ⋯ │         Data │
│          6 │         Row Label │         Data │         Data │ ⋯ │         Data │
│      ⋮     │          ⋮        │       ⋮      │       ⋮      │ ⋱ │       ⋮      │
│        100 │         Row Label │         Data │         Data │ ⋯ │         Data │
├────────────┼───────────────────┼──────────────┼──────────────┼───┼──────────────┤
│            │ Summary Row Label │ Summary Cell │ Summary Cell │ ⋯ │ Summary Cell │
│            │ Summary Row Label │ Summary Cell │ Summary Cell │ ⋯ │ Summary Cell │
│      ⋮     │          ⋮        │       ⋮      │       ⋮      │ ⋯ │       ⋮      │
│            │ Summary Row Label │ Summary Cell │ Summary Cell │ ⋯ │ Summary Cell │
└────────────┴───────────────────┴──────────────┴──────────────┴───┴──────────────┘
Footnotes
Source notes
```

All those sections can be configured using keyword arguments as described below. Adjacent
column labels (same row) can also be merged.

## General Keywords

The following keywords are related to table configuration and are available in all backends:

- `backend::Symbol`: Backend used to print the table. The available options are `:text`,
    `:markdown`, `:html`, and `:latex`.
    (**Default**: `:text`)

### IOContext Arguments

- `compact_printing::Bool`: If `true`, the table will be printed in a compact format, *i.e*,
    we will pass the context option `:compact => true` when rendering the values.
    (**Default**: `true`)
- `limit_printing::Bool`: If `true`, the table will be printed in a limited format, *i.e*,
    we will pass the context option `:limit => true` when rendering the values.
    (**Default**: `true`)

### Printing Specification Arguments

- `show_omitted_cell_summary::Bool`: If `true`, a summary of the omitted cells will be
    printed at the end of the table.
    (**Default**: `true`)
- `renderer::Symbol`: The renderer used to print the table. The available options are
    `:print` and `:show`.
    (**Default**: `:print`)

### Table Sections Arguments

- `title::String`: Title of the table. If it is empty, the title will be omitted.
    (**Default**: "")
- `subtitle::String`: Subtitle of the table. If it is empty, the subtitle will be omitted.
    (**Default**: "")
- `stubhead_label::String`: Label of the stubhead column.
    (**Default**: "")
- `row_number_column_label::String`: Label of the row number column.
    (**Default**: "Row")
- `row_labels::Union{Nothing, AbstractVector}`: Row labels. If it is `nothing`, the column
    with row labels is omitted.
    (**Default**: `nothing`)
- `row_group_labels::Union{Nothing, Vector{Pair{Int, String}}}`: Row group labels. If it is
    `nothing`, no row group label is printed. For more information on how to specify the row
    group labels, see the section **Row Group Labels**.
    (**Default**: `nothing`)
- `column_labels::Union{Nothing, AbstractVector}`: Column labels. If it is `nothing`, the
    function uses a default value for the column labels. For more information on how to
    specify the column labels, see the section **Column Labels**.
    (**Default**: `nothing`)
- `show_column_labels::Bool`: If `true`, the column labels will be printed.
    (**Default**: `true`)
- `summary_rows::Union{Nothing, Vector{T} where T <: Any}`: Summary rows. If it is
    `nothing`, no summary rows are printed. For more information on how to specify the
    summary rows, see the section **Summary Rows**.
    (**Default**: `nothing`)
- `summary_row_labels::Union{Nothing, Vector{String}}`: Labels of the summary rows. If it is
    `nothing`, the function uses a default value for the summary row labels.
    (**Default**: `nothing`)
- `footnotes::Union{Nothing, Vector{Pair{FootnoteTuple, String}}}`: Footnotes. If it is
    `nothing`, no footnotes are printed. For more information on how to specify the
    footnotes, see the section **Footnotes**.
    (**Default**: `nothing`)
- `source_notes::String`: Source notes. If it is empty, the source notes will be omitted.
    (**Default**: "")

## Specification of Table Sections

### Column Labels

The specification of column labels must be a vector of elements. Each element in this vector
must be another vector with a row of column labels. Notice that each vector must have the
same size as the number of table columns.

For example, in a table with three columns, we can specify two rows of column labels by
passing:

```julia
column_labels = [
    ["Column #1",    "Column #2",    "Column #3"],
    ["Subcolumn #1", "Subcolumn #2", "Subcolumn #3"]
]
```

Adjacent column labels can be merged using the keyword `merge_column_label_cells`. It must
contain a vector of `MergeCells` objects. Each object defines a new merged cell. The
`MergeCells` object has the following fields:

- `row::Int`: Row index of the merged cell.
- `column::Int`: Column index of the merged cell.
- `column_span::Int`: Number of columns spanned by the merged cell.
- `data::String`: Data of the merged cell.
- `alignment::Symbol`: Alignment of the merged cell. The available options are `:l` for
    left, `:c` for center, and `:r` for right.
    (**Default**: `:c`)

Hence, in our example, if we want to merge the columns 2 and 3 of the first column label
row, we must pass:

```julia
merge_column_label_cells = [
    MergeCells(1, 2, 2, "Merged Column", :c)
]
```

We can pass the helpers `MultiColumn` and `EmptyCells` to `column_labels` to create merged
columns more easily. In this case, `MultiColumn` specify a set of columns that will be
merged, and `EmptyCells` specify a set of empty columns. However, notice that in this case
we must set `merge_column_label_cells` to `:auto`.

`MultiColumn` has the following fields:

- `column_span::Int`: Number of columns spanned by the merged cell.
- `data::String`: Data of the merged cell.

`EmptyCells` has the following field:

- `number_of_cells::Int`: Number of columns that will be filled with empty cells.

For example, we can create the following column labels:

```
┌───────────────────────────────────┬─────────────────┐
│              Group #1             │     Group #2    │
├─────────────────┬─────────────────┼────────┬────────┤
│    Group #1.1   │    Group #1.2   │        │        │
├────────┬────────┼────────┬────────┼────────┼────────┤
│ Test 1 │ Test 2 │ Test 3 │ Test 4 │ Test 5 │ Test 6 │
└────────┴────────┴────────┴────────┴────────┴────────┘
```

by passing these arguments:

```julia
column_labels = [
    [MultiColumn(4, "Group #1"), MultiColumn(2, "Group #2")],
    [MultiColumn(2, "Group #1.1"), MultiColumn(2, "Group #1.2"), EmptyCells(2)],
    ["Test 1", "Test 2", "Test 3", "Test 4", "Test 5", "Test 6"]
]

merge_column_label_cells = :auto
```

### Row Group Labels

The row group labels are specified by a `Vector{Pair{Int, String}}`. Each element defines a
new row group label. The first element of the `Pair` is the row index of the row group and
the second is the label. For example, `[3 => "Row Group #1"]` defines that before
row 3, we have the row group label named "Row Group #1".

### Summary Rows

### Footnotes

"""
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
    str = if !haskey(kwargs, :backend) && !haskey(kwargs, :tf)
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

    backend::Symbol = :text,

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

    # == Other Configurations ==============================================================

    cell_alignment::Union{Nothing, Vector{Pair{NTuple{2, Int}, Symbol}}, Vector{Function}} = nothing,
    formatters::Union{Nothing, Vector{T} where T <: Any} = nothing,
    maximum_number_of_columns::Int = -1,
    maximum_number_of_rows::Int = -1,
    merge_column_label_cells::Union{Nothing, Symbol, Vector{MergeCells}} = nothing,
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

    # If the user provided the `column_labels` and set `merge_column_label_cells` to
    # `:auto`, we will rebuild those two parameters to take into account the merged columns.
    local _merge_column_label_cells

    if isnothing(column_labels) && (merge_column_label_cells isa Symbol)
        throw(ArgumentError(
            "`merge_column_label_cells = :auto` requires `column_labels` to be provided."
         ))

    elseif !isnothing(column_labels) && (merge_column_label_cells isa Symbol)
        merge_column_label_cells != :auto &&
            throw(ArgumentError(
                "`merge_column_label_cells` has an undefined value (:$(merge_column_label_cells))."
            ))

        column_labels, _merge_column_label_cells = _process_merge_column_label_specification(
            column_labels,
            num_columns
        )

    else
        _merge_column_label_cells = merge_column_label_cells
    end

    # If we reach this point and `column_labels` is nothing, we must guess it.
    if isnothing(column_labels)
        column_labels = _guess_column_labels(pdata)
    else
        for cl in column_labels
            length(cl) != num_columns && throw(ArgumentError(
                "Each vector in `column_labels` must have the same number of elements as the table columns ($num_columns)."
            ))
        end
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

    if backend == :html
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
