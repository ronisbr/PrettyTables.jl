# Typst Backend

The Typst backend can be selected by passing the keyword `backend = :typst` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output:

## Keywords

- `column_label_titles::Union{Nothing, AbstractVector}`: Titles for the column labels. If
  `nothing`, no titles are added. If a vector is passed, it must have the same length as the
  number of column label rows. Each element in the vector can be `nothing` (no title for
  that row) or an element containing the title for that row. Note that this element will be
  converted to a string using the function `string`.
  (**Default**: `nothing`)
- `highlighters::Vector{TypstHighlighter}`: Highlighters to apply to the table. For more
  information, see the section [Typst Highlighters](@ref).
- `style::TypstTableStyle`: Style of the table. For more information, see the section
  [Typst Table Style](@ref).
- `top_left_string::String`: String to put in the top left corner div.
  (**Default**: "")
- `caption::String`: String containing the table caption, to be used by the Typst
  `#figure` function.

## Typst Highlighters

A set of highlighters can be passed as a `Vector{TypstHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`TypstHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)`, which should return `true`
  if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)`, where `h` is the
  highlighter. This function must return a `Vector{Pair{String, String}}` with properties
  compatible with the `style` field that will be applied to the highlighted cell.

A Typst highlighter can be constructed using three helpers:

```julia
TypstHighlighter(f::Function, decoration::Vector{Pair{String, String}})

TypstHighlighter(f::Function, decorations::NTuple{N, Pair{String, String}})

TypstHighlighter(f::Function, fd::Function)
```

The first applies a fixed decoration to the highlighted cell specified in `decoration`, the
second allows specifying decorations as a `Tuple`, and the third lets the user select the
desired decoration by specifying the function `fd`.

!!! note

    If multiple highlighters are valid for element `(i, j)`, the applied style is the first
    match according to the order in the vector `highlighters`.

!!! note

    If highlighters are used together with [Formatters](@ref), formatting changes
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells with values greater than 5 in red, and all
the cells with values less than 5 in blue, we can define:

```julia
hl_gt5 = TypstHighlighter(
    (data, i, j) -> data[i, j] > 5,
    ["fill" => "red", "text-fill" => "white"]
)

hl_lt5 = TypstHighlighter(
    (data, i, j) -> data[i, j] < 5,
    ["fill" => "blue"]
)

highlighters = [hl_gt5, hl_lt5]
```

Each cell is rendered with one call to `#text` inside a `table.cell` function, as shown
below:

```typst
table.cell()[#text()[Cell Content]]
```

!!! note

    Since `table.cell` and `#text()` share some attribute names, attributes used by the
    `#text` function must be defined with the `text-` prefix. For example, to create a table
    style (or highlighter) that sets a blue background and white font color:

    ```julia
    ["fill" => "blue", "text-fill" => "white"]
    ```

!!! note

    The content is always escaped and wrapped in a `#text` function. If you want to use a
    raw Typst component as cell, load the package Typstry.jl and pass the cell content as a
    `TypstString`. In this case, the content will not be wrapped in a `#text` function and
    will be treated as a raw Typst component.

## Typst Table Style

The Typst table style is defined using an object of type [`TypstTableStyle`](@ref) that
contains the following fields:

- `top_left_string::Vector{TypstPair}`: Style for the top left string.
- `top_right_string::Vector{TypstPair}`: Style for the top right string.
- `table::Vector{TypstPair}`: Style for the table.
- `title::Vector{TypstPair}`: Style for the title.
- `subtitle::Vector{TypstPair}`: Style for the subtitle.
- `row_number_label::Vector{TypstPair}`: Style for the row number label.
- `row_number::Vector{TypstPair}`: Style for the row number.
- `stubhead_label::Vector{TypstPair}`: Style for the stubhead label.
- `row_label::Vector{TypstPair}`: Style for the row label.
- `row_group_label::Vector{TypstPair}`: Style for the row group label.
- `first_line_column_label::Union{Vector{TypstPair}, Vector{Vector{TypstPair}}}`: Style for
  the first line of the column labels. If a vector of `Vector{TypstPair}` is provided, each
  column label in the first line will use the corresponding style.
- `column_label::Union{Vector{TypstPair}, Vector{Vector{TypstPair}}}`: Style for the rest of
  the column labels. If a vector of `Vector{TypstPair}` is provided, each column label will
  use the corresponding style.
- `first_line_merged_column_label::Vector{TypstPair}`: Style for the merged cells at the
  first column label line.
- `merged_column_label::Vector{TypstPair}`: Style for the merged cells at the rest of the
  column labels.
- `summary_row_cell::Vector{TypstPair}`: Style for the summary row cell.
- `summary_row_label::Vector{TypstPair}`: Style for the summary row label.
- `footnote::Vector{TypstPair}`: Style for the footnote.
- `source_notes::Vector{TypstPair}`: Style for the source notes.
- `first_line_of_column_labels::Vector{TypstPair}`: Style for the first line of the column
  labels.

Each field is a vector of [`TypstPair`](@ref), *i.e.* `Pair{String, String}`, describing
properties and values compatible with the Typst style attribute.

For example, if we want the stubhead label to be bold and red, we must define:

```julia
style = TypstTableStyle(
    stubhead_label = ["text-weight" => "bold", "fill" => "red", "text-fill" => "white"]
)
```
