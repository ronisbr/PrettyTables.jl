# Usage

```@meta
CurrentModule = PrettyTables
```

```@setup usage
using PrettyTables

function create_latex_example(table, filename)
    mkdir("tmp")
    cd("tmp")

    write(
      "table.tex",
      """
      \\documentclass[a4paper, 12pt]{article}
      \\pagestyle{empty}
      \\usepackage{color}
      \\usepackage{booktabs}
      \\usepackage{xcolor}
      \\begin{document}
      $table
      \\end{document}
      """
    )

    run(`lualatex table.tex`)
    run(`lualatex table.tex`)
    run(`convert -density 600 table.pdf -flatten -trim $filename`)
    run(`mv $filename ..`)
    cd("..")
    rm("tmp"; recursive = true)
end
```

## Table Sections

**PrettyTables.jl** considers the following table sections when printing a table:

```text
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
- `summary_rows::Union{Nothing, Vector{Function}}`: Summary rows. If it is `nothing`, no
  summary rows are printed. For more information on how to specify the summary rows, see the
  section [Summary Rows](@ref).
  (**Default**: `nothing`)
- `summary_row_labels::Union{Nothing, Vector{String}}`: Labels of the summary rows. If it is
  `nothing`, the function uses a default value for the summary row labels.
  (**Default**: `nothing`)
- `footnotes::Union{Nothing, Vector{Pair{FootnoteTuple, String}}}`: Footnotes. If it is
  `nothing`, no footnotes are printed. For more information on how to specify the footnotes,
  see the section [Footnotes](@ref).
  (**Default**: `nothing`)
- `source_notes::String`: Source notes. If it is empty, the source notes will be omitted.
  (**Default**: "")

### Alignment Arguments

The following keyword arguments define the alignment of the table sections. The alignment
can be specified using a symbol: `:l` for left, `:c` for center, or `:r` for right.

- `alignment::Union{Symbol, Vector{Symbol}}`: Alignment of the table data. It can be a
  `Symbol`, which will be used for all columns, or a vector of `Symbol`s, one for each
  column.
  (**Default**: `:r`)
- `column_label_alignment::Union{Nothing, Symbol, Vector{Symbol}}`: Alignment of the column
  labels. It can be a `Symbol`, which will be used for all columns, a vector of `Symbol`s,
  one for each column, or `nothing`, which will use the value of `alignment`.
  (**Default**: `nothing`)
- `continuation_row_alignment::Union{Nothing, Symbol}`: Alignment of the columns in the
  continuation row. If it is `nothing`, we use the value of `alignment`.
  (**Default**: `nothing`)
- `footnote_alignment::Symbol`: Alignment of the footnotes.
  (**Default**: `:l`)
- `row_label_column_alignment::Symbol`: Alignment of the row labels.
  (**Default**: `:r`)
- `row_group_label_alignment::Symbol`: Alignment of the row group labels.
  (**Default**: `:l`)
- `row_number_column_alignment::Symbol`: Alignment of the row number column.
  (**Default**: `:r`)
- `source_note_alignment::Symbol`: Alignment of the source notes.
  (**Default**: `:l`)
- `subtitle_alignment::Symbol`: Alignment of the subtitle.
  (**Default**: `:c`)
- `title_alignment::Symbol`: Alignment of the title.
  (**Default**: `:c`)
- `cell_alignment::Union{Nothing, Vector{Pair{NTuple{2, Int}, Symbol}, Vector{Function}}`: A
  vector of functions with the signature `f(data, i, j)` that overrides the alignment of the
  cell `(i, j)` to the value returned by `f`. The function must return a valid alignment
  symbol or `nothing`. In the latter, the cell alignment will not be modified. If the
  function returns an invalid data, it will be discarded. For convenience, it can also be a
  vector of `Pair{NTuple{2, Int}, Symbol}`, *i.e.* `(i::Int, j::Int) => a::Symbol`, that
  overrides the alignment of the cell `(i, j)` to `a`.
  (**Default** = `nothing`)

!!! warning

    Some backends does not support all the alignment options. For example, it is impossible
    to define cell-specific alignment in the markdown backend.

### Other Arguments

- `formatters::Union{Nothing, Vector{Function}}`: Formatters used to modify the rendered
  output of the cells. For more information, see the section [Formatters](@ref).
  (**Default**: `nothing`)
- `maximum_number_of_columns::Int`: Maximum number of columns to be printed. If the table
  has more columns than this value, the table will be truncated. If it is negative, all
  columns will be printed.
  (**Default**: `-1`)
- `maximum_number_of_rows::Int`: Maximum number of rows to be printed. If the table has more
  rows than this value, the table will be truncated. If it is negative, all rows will be
  printed.
  (**Default**: `-1`)
- `merge_column_label_cells::Union{Symbol, Vector{MergeCells}}`: Merged cells in the column
  labels. For more information, see the section [Column Labels](@ref).
  (**Default**: `:auto`)
- `new_line_at_end::Bool`: If `true`, a new line will be added at the end of the table.
- `show_first_column_label_only::Bool`: If `true`, only the first row of the column labels
  will be printed.
  (**Default**: `false`)
- `vertical_crop_mode::Symbol`: Vertical crop mode. This option defines how the table will
  be vertically cropped if it has more rows than the number specified in
  `maximum_number_of_rows`. The available options are `:bottom`, when the data will be
  cropped at the bottom of the table, or `:middle`, when the data will be cropped at the
  middle of the table.
  (**Default**: `:bottom`)

## Backend-Specific Keywords

Please, see the backend sections for the keywords specific to each one.

## Specification of Table Sections

Here, we show how to specify the table sections using the keyword arguments.

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

!!! info

    If the user wants only one row in the column labels, they can pass only a vector with
    the elements. The algorithm will encapsulate it inside another vector to match the API.

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

The summary rows can be specified by a vector of `Function`s. Each element defines a summary
row and the function must have one the following signature:

```
f(col)

f(data, j)
```

where `col` is the current column, `data` is the table data, and `j` is the column index. In
the first case, it must return the summary cell value for the referenced column. In the
second case, it must return the summary cell value for the `j`th column. The algorithm will
check if there is an applicable method for the first signature and use it if it exists.
Otherwise, it will use the second signature. This verification is performed using the method
`applicable` and `col` is obtained by `@view data[:, j]`.

If we want, for example, to create two summary rows, one with the sum of the column values
and other with their mean, we can define:

```julia
summary_rows = [
    (data, j) -> sum(data[:, j]),
    (data, j) -> sum(data[:, j]) / length(data[:, j])
]
```

We can also use the first signature to simplify the code:

```julia
using Statistics
summary_rows = [sum, mean]
```

!!! note

    If both signatures are available, the algorithm will prioritize the first one. To force
    the usage of the second, we can create an anonymous functions as follows: `(data, i) ->
    f(data, i)`. This ensures that only the second method is available.

### Footnotes

The footnotes are specified by a vector of `Pair{FootnoteTuple, String}`. Each element
defines a new footnote. The `FootnoteTuple` is a `Tuple` with the following elements:

- `section::Symbol`: Section to which the footnote must be applied. The available options
  are `:column_label`, `:data`, `:row_label`, `:summary_row_label`, and `:summary_row_cell`.
- `i::Int`: Row index of the footnote considering the desired section.
- `j::Int`: Column index of the footnote considering the desired section.

The second element of the `Pair` is the footnote text.

Hence, if we want to apply a foot note to a column label, a data cell, and a summary cell,
we can define:

```julia
footnotes = [
    (:column_label, 1, 2) => "Footnote in column label",
    (:data, 2, 2) => "Footnote in data",
    (:summary_row_cell, 1, 2) => "Footnote in summary cell"
]
```

## Formatters

The keyword `formatters` can be used to pass functions to format the values in the columns.
It must be a `Vector{Function}` in which each function has the following signature:

```julia
f(v, i, j)
```

where `v` is the value in the cell, `i` is the row number, and `j` is the column number.
It must return the formatted value of the cell `(i, j)` that has the value `v`. Notice
that the returned value will be converted to string after using the function `sprint`.

This keyword can also be `nothing`, meaning that no formatter will be used.

For example, if we want to multiply all values in odd rows of the column 2 by π, the
formatter should look like:

```julia
formatters = [(v, i, j) -> (j == 2 && isodd(i)) ? v * π : v]
```

If multiple formatters are available, they will be applied in the same order as they are
located in the vector. Thus, for the following `formatters`:

```julia
formatters = [f1, f2, f3]
```

each element `v` in the table (`i`th row and `j`th column) will be formatted by:

```julia
v = f1(v, i, j)
v = f2(v, i, j)
v = f3(v, i, j)
```

Thus, the user must be ensure that the type of `v` between the calls are compatible.

PrettyTables.jl provides some predefined formatters for common tasks as described in the
next section.

### Predefined Formatters

```julia
fmt__printf(fmt_str::String[, columns::AbstractVector{Int}]) -> Function
```

Apply the format `fmt_str` (see the `Printf` standard library) to the elements in the
columns specified in the vector `columns`. If `columns` is not specified, the format will be
applied to the entire table.

!!! info

    This formatter will be applied only to the cells that are of type `Number`.

```@repl usage
data = [f(a) for a = 0:30:90, f in (sind, cosd, tand)]

pretty_table(data; formatters = [fmt__printf("%5.3f")])

pretty_table(data; formatters = [fmt__printf("%5.3f", [1, 3])])
```

---

```julia
fmt__round(digits::Int[, columns::AbstractVector{Int}]) -> Function
```

Round the elements in the columns specified in the vector `columns` to the number of
`digits`. If `columns` is not specified, the rounding will be applied to the entire table.

```@repl usage
data = [f(a) for a = 0:30:90, f in (sind, cosd, tand)]

pretty_table(data; formatters = [fmt__round(1)])

pretty_table(data; formatters = [fmt__round(1, [1, 3])])
```

---

```julia
fmt__latex_sn(m_digits::Int[, columns::AbstractVector{Int}]) -> Function
```

Format the numbers of the elements in the `columns` to a scientific notation using LaTeX.
If `columns` is not present, the formatting will be applied to the entire table.

The number is first printed using `Printf` functions with the `g` modifier and then
converted to the LaTeX format. The number of digits in the mantissa can be selected by the
argument `m_digits`.

The formatted number will be wrapped in the object `LatexCell`. Hence, this formatter only
makes sense if the selected backend is `:latex`.

!!! info

    This formatter will be applied only to the cells that are of type `Number`.

```julia-repl
julia> data = [10.0^(-i + j) for i in 1:6, j in 1:6]
6×6 Matrix{Float64}:
 1.0     10.0     100.0    1000.0   10000.0  100000.0
 0.1      1.0      10.0     100.0    1000.0   10000.0
 0.01     0.1       1.0      10.0     100.0    1000.0
 0.001    0.01      0.1       1.0      10.0     100.0
 0.0001   0.001     0.01      0.1       1.0      10.0
 1.0e-5   0.0001    0.001     0.01      0.1       1.0

julia> pretty_table(data; formatters = [fmt__latex_sn(1)], backend = :latex)
```

```@setup usage
data = [ 10.0^(-i + j) for i in 1:6, j in 1:6]

table = pretty_table(String, data; formatters = [fmt__latex_sn(1)], backend = :latex)

create_latex_example(table, "fmt__latex_sn.png")
```

![fmt__latex_sn](./fmt__latex_sn.png)
