# LaTeX Backend

The LaTeX backend can be selected by passing the keyword `backend = :latex` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output.

## Keywords

- `highlighters::Vector{LatexHighlighter}`: Highlighters to apply to the table. For more
    information, see the section [LaTeX Highlighters]@(ref).
- `style::LatexTableStyle`: Style of the table. For more information, see the section
    [LaTeX Table Style](@ref).
- `table_format::LatexTableFormat`: LaTeX table format used to render the table. For more
    information, see the section [LaTeX Table Format](@ref).

## LaTeX Highlighters

A set of highlighters can be passed as a `Vector{LatexHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`LatexHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{String}` with the LaTeX environments to
    be applied to the cell.

A LaTeX highlighter can be constructed using two helpers:

```julia
LatexHighlighter(f::Function, envs::Vector{String})
```

where it will apply recursively all the LaTeX environments in `envs` to the highlighted
text, and

```julia
LatexHighlighter(f::Function, fd::Function)
```

where the user select the desired decoration by specifying the function `fd`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to make the cells with value greater than 5 bold, and all the
cells with value less than 5 small, we can define:

```julia
hl_gt5 = LatexHighlighter(
    (data, i, j) -> data[i, j] > 5,
    ["textbf"]
)

hl_lt5 = LatexHighlighter(
    (data, i, j) -> data[i, j] < 5,
    ["small"]
)

highlighters = [hl_gt5, hl_lt5]
```

## LaTeX Table Format

The LaTeX table format is defined using an object of type [`LatexTableFormat`](@ref) that
contains the following fields:

- `borders::LatexTableBorders`: Format of the borders.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_line_at_merged_column_labels::Bool`: If `true`, a horizontal line will be
    drawn on bottom of the merged column labels using `\\cline`.
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the column labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data column. If the symbol `:none` is passed,
    no horizontal lines will be drawn after the data rows.
- `horizontal_line_before_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn before the row group label.
- `horizontal_line_after_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn after the row group label.
- `horizontal_line_after_data_rows::Bool`: If `true`, a horizontal line will be drawn
    after the data rows.
- `horizontal_line_before_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    before the summary rows. Notice that this line is the same as the one drawn if
    `horizontal_line_after_data_rows` is `true`. However, in this case, the line is omitted
    if there are no summary rows.
- `horizontal_line_after_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    after the summary rows.
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will be
    drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data column. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.

We provide a few helpers to configure the table format. For more information, see the
documentation of the following macros:

- [`@latex__all_horizontal_lines`](@ref).
- [`@latex__all_vertical_lines`](@ref).
- [`@latex__no_horizontal_lines`](@ref).
- [`@latex__no_vertical_lines`](@ref).

## LaTeX Table Style

The LaTeX table style is defined using an object of type [`LatexTableStyle`](@ref) that
contains the following fields:

- `title::LatexEnvironments`: Latex environments with the style for the title.
- `subtitle::LatexEnvironments`: Latex environments with the style for the subtitle.
- `row_number_label::LatexEnvironments`: Latex environments with the style for the row
    number label.
- `row_number::LatexEnvironments`: Latex environments with the style for the row numbers.
- `stubhead_label::LatexEnvironments`:  Latex environments with the style for the stubhead
    label.
- `row_label::LatexEnvironments`: Latex environments with the style for the row labels.
- `row_group_label::LatexEnvironments`: Latex environments with the style for the row group
    label.
- `first_line_column_label::LatexEnvironments`: Latex environments with the style for the
    first column label lines.
- `column_label::LatexEnvironments`: Latex environments with the style for the rest of the
    column labels.
- `first_line_merged_column_label::LatexEnvironments`: Latex environments with the style for
    the merged cells at the first column label line.
- `merged_column_label::LatexEnvironments`: Latex environments with the style for the merged
    cells at the rest of the column labels.
- `summary_row_cell::LatexEnvironments`: Latex environments with the style for the summary
    row cell.
- `summary_row_label::LatexEnvironments`: Latex environments with the style for the summary
    row label.
- `footnote::LatexEnvironments`: Latex environments with the style for the footnotes.
- `source_note::LatexEnvironments`: Latex environments with the style for the source notes.
- `omitted_cell_summary::LatexEnvironments`: Latex environments with the style for the
    omitted cell summary.

Each field is a `LatexEnvironments` object, which is a vector of strings with the LaTeX
environments to be applied to the corresponding element.

For example, if we want to make the stubhead label bold and red, we must define:

```julia
style = LatexTableStyle(
    stubhead_label = ["textbf", "color{red}"]
)
```
