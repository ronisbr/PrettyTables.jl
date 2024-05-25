# Markdown Back End

```@meta
CurrentModule = PrettyTables
```

```@setup markdown
using PrettyTables
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
    with the number of columns and rows that were omitted.
    (**Default** = `false`)

The following keywords are available to customize the output decoration:

- `header_decoration::MarkdownDecoration`: Decoration applied to the header.
    (**Default** = `MarkdownDecoration(bold = true)`)
- `row_label_decoration::MarkdownDecoration`: Decoration applied to the row label column.
    (**Default** = `MarkdownDecoration()`)
- `row_number_decoration::MarkdownDecoration`: Decoration applied to the row number column.
    (**Default** = `MarkdownDecoration(bold = true)`)
- `subheader_decoration::MarkdownDecoration`: Decoration applied to the sub-header.
    (**Default** = `MarkdownDecoration(code = true)`)

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
    `highlighters` without being inside a `Tuple`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

There are a set of pre-defined highlighters (with names `hl_*`) to make the usage simpler.
They are defined in the file `./src/backends/markdown/predefined_highlighters.jl`.

```@repl markdown
t = 0:1:20

data = hcat(t, ones(length(t)) * 1, 1 * t, 0.5 .* t.^2)

header = (
    ["Time", "Acceleration", "Velocity", "Distance"],
    [ "[s]",       "[m/s²]",    "[m/s]",      "[m]"]
)

hl_v = MarkdownHighlighter(
    (data, i, j) -> (j == 3) && data[i, 3] > 9,
    MarkdownDecoration(bold = true)
)

hl_p = MarkdownHighlighter(
    (data, i, j) -> (j == 4) && data[i, 4] > 10,
    MarkdownDecoration(italic = true)
)

pretty_table(
    data;
    alignment = [:c, :r, :c, :l],
    backend = Val(:markdown),
    header = header,
    highlighters = (hl_p, hl_v)
)
```
