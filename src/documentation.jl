## Description #############################################################################
#
# Documentation for the function `pretty_table`.
#
############################################################################################

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

For more information, see the **Extended Help** section.

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

All those sections can be configured using keyword arguments as described below.

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

## Backend-Specific Keywords

The keywords and information specific to each backend can be seen in the docstrings of the
following methods:

- **Text backend**: `pretty_table_text_backend`.
- **Markdown backend**: `pretty_table_markdown_backend`.
- **HTML backend**: `pretty_table_html_backend`.

!!! warning

    Those methods **must not** be called directly. They are only defined to split the
    documentation, providing a better organization.

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
pretty_table
