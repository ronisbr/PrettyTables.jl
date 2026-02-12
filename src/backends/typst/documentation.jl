## Description #############################################################################
#
# Documentation for the Typst backend.
#
############################################################################################

"""
# PrettyTables.jl Typst Backend

The Typst backend can be selected by passing the keyword `backend = :typst` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output:

# Keywords

- `column_label_titles::Union{Nothing, AbstractVector}`: Titles for the column labels. If
    `nothing`, no titles are added. If a vector is passed, it must have the same length as
    the number of column label rows. Each element in the vector can be `nothing` (no title
    for that row) or an element containing the title for that row. Note that this element
    will be converted to a string using the function `string`.
    (**Default**: `nothing`)
- `highlighters::Vector{TypstHighlighter}`: Highlighters to apply to the table. For more
    information, see the section **Typst Highlighters** in the **Extended Help**.
- `caption::Union{Nothing, AbstractString}`: String containing the table caption.
- `wrap_column::Integer`: Indicates the column where the output will be wrapped.
- `annotate::Bool`: Boolean indicating whether Typst code should be annotated.

# Extended Help

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

For example, if we want to highlight the cells with value greater than 5 in red, and all
cells with values less than 5 in blue, we can define:

```julia
hl_gt5 = TypstHighlighter(
    (data, i, j) -> data[i, j] > 5,
    ["text-fill" => "red"]
)

hl_lt5 = TypstHighlighter(
    (data, i, j) -> data[i, j] < 5,
    ["text-fill" => "blue"]
)

highlighters = [hl_gt5, hl_lt5]
```
"""
pretty_table_typst_backend
