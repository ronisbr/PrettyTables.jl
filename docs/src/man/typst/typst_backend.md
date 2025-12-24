# Typst Backend

The Typst backend can be selected by passing the keyword `backend = :typst` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output.

## Keywords

- `column_label_titles::Union{Nothing, AbstractVector}`: Titles for the column labels. If
  `nothing`, no titles are added. If a vector is passed, it must have the same length as the
  number of column label rows. Each element in the vector can be `nothing` (no title for
  that row) or an element with the title for that row. Notice that this element will be
  converted to string using the function `string`.
  (**Default**: `nothing`)
- `highlighters::Vector{TypstHighlighters}`: Highlighters to apply to the table. For more
  information, see the section [Typst Highlighters](@ref).
- `style::TypstTableStyle`: Style of the table. For more information, see the section
  [Typst Table Style](@ref).
- `top_left_string::String`: String to put in the top left corner div.
  (**Default**: "")
- `caption::String`: String with table caption, to be used by `#Figure` typst function. 
- 

## Typst Highlighters

A set of highlighters can be passed as a `Vector{TypstHighlighters}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`TypstHighlighters`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
  if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
  highlighter. This function must return a `Vector{Pair{String, String}}` with properties
  compatible with the `style` field that will be applied to the highlighted cell.

A Typst highlighter can be constructed using three helpers:

```julia
TypstHighlighters(f::Function, decoration::Vector{Pair{String, String}})

TypstHighlighters(f::Function, decorations::NTuple{N, Pair{String, String})

TypstHighlighters(f::Function, fd::Function)
```

The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
whereas the second lets the user select the desired decoration by specifying the function
`fd`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells with values greater than 5 in red, and all
the cells with values less than 5 in blue, we can define:

```julia
hl_gt5 = TypstHighlighters(
    (data, i, j) -> data[i, j] > 5,
    ["fill" => "red", "text-fill"=>"white"]
)

hl_lt5 = TypstHighlighters(
    (data, i, j) -> data[i, j] < 5,
    ["fill" => "blue"]
)

highlighters = [hl_gt5, hl_lt5]
```

Each cell will be rendered with one call of `#text` inside a `table.cell` function, like below: 
```typst
  table.cell()[#text()[Cell Content]]
```

!!! note 

    As `table.cell` and `#text()` shares some attributes names, those attributes used by `#text` function will be defined with `text-` prefix. 
    Ex.: to make an table style (or highlighter) that set background ground color blue and font color white would be 
    
    ```julia 
    ["fill"=>"blue","text-fill"=>"white"]
    ```


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
  the first line of the column labels. If a vector of `Vector{TypstPair}}` is provided, each
  column label in the first line will use the corresponding style.
- `column_label::Union{Vector{TypstPair}, Vector{Vector{TypstPair}}}`: Style for the rest of
  the column labels. If a vector of `Vector{TypstPair}}` is provided, each column label will
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
    stubhead_label = ["text-weight" => "bold", "fill" => "red", "text-fill"=>"white"]
)
```
