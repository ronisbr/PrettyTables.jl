# PrettyTables.jl

[![Build status](https://github.com/ronisbr/PrettyTables.jl/workflows/CI/badge.svg)](https://github.com/ronisbr/PrettyTables.jl/actions)
[![codecov](https://codecov.io/gh/ronisbr/PrettyTables.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ronisbr/PrettyTables.jl)
[![docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)][docs-stable-url]
[![docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)][docs-dev-url]
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![DOI](https://zenodo.org/badge/165340490.svg)](https://zenodo.org/doi/10.5281/zenodo.10015722)

This package has the purpose to print data in matrices using different backends. It was
orizinally inspired in the functionality provided by
[ASCII Tables](https://ozh.github.io/ascii-tables/).

**PrettyTables.jl** allows to print the data together with some table sections. They can be
modified by the user to obtain the desired output. The sections currently available are:

![Table Design](./docs/src/assets/table_design.png)

This design is heavily inspired by the R's package [gt](https://github.com/rstudio/gt/) but
the API is highly different due to the differences between the R and Julia languages.

## Installation

```julia-repl
julia> using Pkg
julia> Pkg.add("PrettyTables")
```

## Example

We present in the following an example showing some of the features available in
**PrettyTables.jl**.

```julia
julia> using PrettyTables, StyledStrings

# == Creating the Table ====================================================================

julia> v1_t = 0:5:20

julia> v1_a = ones(length(v1_t)) * 1.0

julia> v1_v = @. 0 + v1_a * v1_t

julia> v1_d = @. 0 + v1_a * v1_t^2 / 2

julia> v2_t = 0:5:20

julia> v2_a = ones(length(v2_t)) * 0.75

julia> v2_v = @. 0 + v2_a * v2_t

julia> v2_d = @. 0 + v2_a * v2_t^2 / 2

julia> table = [
  v1_t v1_a v1_v v1_d
  v2_t v2_a v2_v v2_d
];

# == Configuring the Table =================================================================

julia> title = "Table 1. Data obtained from the test procedure."

julia> subtitle = "Comparison between two vehicles"

julia> column_labels = [
    [EmptyCells(2), MultiColumn(2, "Estimated Data")],
    ["Time (s)", "Acceleration", "Velocity", "Position"],
]

julia> units = [
  styled"{(foreground=gray):[s]}",
  styled"{(foreground=gray):[m / s²]}",
  styled"{(foreground=gray):[m / s]}",
  styled"{(foreground=gray):[m]}",
]

julia> push!(column_labels, units)

julia> merge_column_label_cells = :auto

julia> row_group_labels = [
    1 => "Vehicle #1",
    6 => "Vehicle #2"
]

julia> summary_rows = [
    (data, j) -> maximum(@views data[ 1:5, j]),
    (data, j) -> maximum(@views data[6:10, j]),
]

julia> summary_row_labels = [
    "Max. for Vehicle #1",
    "Max. for Vehicle #2",
]

julia> footnotes = [
    (:column_label, 1, 3) => "Estimated data based on the acceleration measurement."
]

julia> highlighters = [
    TextHighlighter((data, i, j) -> (j == 3) && (data[i, j] > 10), crayon"fg:red bold")
    TextHighlighter((data, i, j) -> (j == 4) && (data[i, j] > 10), crayon"fg:blue bold")
]

julia> tf = TextTableFormat(
    # Remove vertical lines.
    right_vertical_lines_at_data_columns = :none,
    vertical_line_after_data_columns     = false,
    vertical_line_after_row_label_column = false,
    vertical_line_at_beginning           = false,
)

julia> style = TextTableStyle(
    column_label                   = crayon"bold",
    first_line_merged_column_label = crayon"fg:yellow bold underline",
    footnote                       = crayon"fg:cyan",
    row_group_label                = crayon"fg:magenta bold",
    subtitle                       = crayon"italics",
    title                          = crayon"fg:yellow bold",
)

# == Printing the Table ====================================================================

julia> pretty_table(
    table;
    column_labels,
    footnotes,
    highlighters,
    merge_column_label_cells,
    row_group_labels,
    style,
    subtitle,
    summary_row_labels,
    summary_rows,
    tf,
    title,
)
```

![PrettyTables.jl example](./docs/src/assets/welcome_figure.svg)

## Usage

See the [documentation][docs-stable-url].

[docs-dev-url]: https://ronisbr.github.io/PrettyTables.jl/dev
[docs-stable-url]: https://ronisbr.github.io/PrettyTables.jl/stable
