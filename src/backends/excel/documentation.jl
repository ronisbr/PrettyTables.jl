## Description #############################################################################
#
# Documentation for the Typst backend.
#
############################################################################################

"""
# PrettyTables.jl Excel Backend

The Excel backend can be selected by passing the keyword `backend = :excel` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output.

# Keywords

- `column_label_titles::Union{Nothing, AbstractVector}`: Titles for the column labels. If
    `nothing`, no titles are added. If a vector is passed, it must have the same length as
    the number of column label rows. Each element in the vector can be `nothing` (no title
    for that row) or an element with the title for that row. Notice that this element will
    be converted to string using the function `string`.
    (**Default**: `nothing`)
- `highlighters::Vector{TypstHighlighter}`: Highlighters to apply to the table. For more
    information, see the section **Excel Highlighters** in the **Extended Help**.
- `caption::Untion{Nothing,AbstractString}`: String with the caption for the table.
- `wrap_column::Integer`: indicate in which column the output will be wrapped
- `annotate::Bool`: Boolean indicating if typst code should be annotated. 

# Extended Help

## Excel Highlighters

A set of highlighters can be passed as a `Vector{ExcelHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`ExcelHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{Pair{String, String}}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.

An Excel highlighter can be constructed using three helpers:

```julia
ExcelHighlighter(f::Function, decoration::Vector{Pair{String, String}})

ExcelHighlighter(f::Function, decorations::NTuple{N, Pair{String, String}})

ExcelHighlighter(f::Function, fd::Function)
```

 The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
 the second allows specifying decorations as a `Tuple`, and the third lets the user select
 the desired decoration by specifying the function `fd`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells with value greater than 5 in bold, red text, and all
cells with values less than 5 in blue, we can define:

```julia
hl_gt5 = ExcelHighlighter(
    (data, i, j) -> data[i, j] > 5,
    ["color" => "red", "bold" = "true"]
)

hl_lt5 = ExcelHighlighter(
    (data, i, j) -> data[i, j] < 5,
    ["color" => "blue"]
)

highlighters = [hl_gt5, hl_lt5]
```
"""
pretty_table_excel_backend
