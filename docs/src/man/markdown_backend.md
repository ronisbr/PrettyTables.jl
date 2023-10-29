Markdown Back End
=================

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```
The following options are available when the markdown back end is used. Those can be passed
as keywords when calling the function [`pretty_table`](@ref):

- `allow_markdown_in_cells::Bool`: By default, special markdown characters like `*`, `_`,
    `~`, etc. are escaped in markdown back end to generate valid output. However, this
    algorithm blocks the usage of markdown code inside of the cells. If this keyword is
    `true`, the escape algorithm **will not** be applied, allowing markdown code inside all
    the cells. In this case, the user must ensure that the output code is valid.
    (**Default** = `false`)
- `highlighters::Union{MarkdownHighlighter, Tuple}`: An instance of `MarkdownHighlighter` or
    a tuple with a list of Markdown highlighters (see the section
    [Markdown Highlighters](@ref)).
- `show_omitted_cell_summary::Bool`: If `true`, a summary will be printed after the table
    with the number of columns and rows that were omitted. (**Default** = `false`)

## Markdown Highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.  Each
highlighter is an instance of the structure [`MarkdownHighlighter`](@ref). It contains the
following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i,j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `fd(h, data, i, j)` in which `h` is the
    highlighter. This function must return the [`MarkdownDecoration`](@ref) to be applied to
    the cell that must be highlighted.

The function `f` has the following signature:

```julia
f(data, i, j)
```

in which `data` is a reference to the data that is being printed, and `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the highlight
style will be applied to the `(i, j)` element. Otherwise, the default style will be used.

If the function `f` returns true, the function `fd(h, data, i, j)` will be called and must
return an element of type [`MarkdownDecoration`](@ref) that contains the decoration to be
applied to the cell.

A markdown highlighter can be constructed using two helpers:

```julia
MarkdownHighlighter(f::Function, decoration::MarkdownDecoration)

MarkdownHighlighter(f::Function, fd::Function)
```

The first will apply a fixed decoration to the highlighted cell specified in `decoration`
whereas the second let the user select the desired decoration by specifying the function
`fd`.

!!! info
    If only a single highlighter is wanted, it can be passed directly to the keyword
    `highlighter` without being inside a `Tuple`.

!!! note
    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note
    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

```julia
julia> t = 0:1:20;

julia> data = hcat(t, ones(length(t)) * 1, 1 * t, 0.5 .* t.^2);

julia> header = (["Time", "Acceleration", "Velocity", "Distance"],
                 [ "[s]",       "[m/s²]",    "[m/s]",      "[m]"]);

julia> hl_v = MarkdownHighlighter((data, i, j) -> (j == 3) && data[i, 3] > 9, MarkdownDecoration(bold = true));

julia> hl_p = MarkdownHighlighter((data, i, j) -> (j == 4) && data[i, 4] > 10, MarkdownDecoration(italic = true));

julia> pretty_table(
    data;
    alignment = [:c, :r, :c, :l],
    backend = Val(:markdown),
    header = header,
    highlighters = (hl_p, hl_v)
)
| **Time**<br>`[s]` | **Acceleration**<br>`[m/s²]` | **Velocity**<br>`[m/s]` | **Distance**<br>`[m]` |
|:-----------------:|-----------------------------:|:-----------------------:|:----------------------|
| 0.0               | 1.0                          | 0.0                     | 0.0                   |
| 1.0               | 1.0                          | 1.0                     | 0.5                   |
| 2.0               | 1.0                          | 2.0                     | 2.0                   |
| 3.0               | 1.0                          | 3.0                     | 4.5                   |
| 4.0               | 1.0                          | 4.0                     | 8.0                   |
| 5.0               | 1.0                          | 5.0                     | _12.5_                |
| 6.0               | 1.0                          | 6.0                     | _18.0_                |
| 7.0               | 1.0                          | 7.0                     | _24.5_                |
| 8.0               | 1.0                          | 8.0                     | _32.0_                |
| 9.0               | 1.0                          | 9.0                     | _40.5_                |
| 10.0              | 1.0                          | **10.0**                | _50.0_                |
| 11.0              | 1.0                          | **11.0**                | _60.5_                |
| 12.0              | 1.0                          | **12.0**                | _72.0_                |
| 13.0              | 1.0                          | **13.0**                | _84.5_                |
| 14.0              | 1.0                          | **14.0**                | _98.0_                |
| 15.0              | 1.0                          | **15.0**                | _112.5_               |
| 16.0              | 1.0                          | **16.0**                | _128.0_               |
| 17.0              | 1.0                          | **17.0**                | _144.5_               |
| 18.0              | 1.0                          | **18.0**                | _162.0_               |
| 19.0              | 1.0                          | **19.0**                | _180.5_               |
| 20.0              | 1.0                          | **20.0**                | _200.0_               |
```
