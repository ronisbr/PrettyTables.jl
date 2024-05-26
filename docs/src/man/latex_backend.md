# LaTeX Back End

```@meta
CurrentModule = PrettyTables
```

```@setup latex
using PrettyTables
using LaTeXStrings
using Latexify
```

The following options are available when the LaTeX back end is used. Those can be passed as
keywords when calling the function [`pretty_table`](@ref):

- `body_hlines::Vector{Int}`: A vector of `Int` indicating row numbers in which an
    additional horizontal line should be drawn after the row. Notice that numbers lower than
    1 and equal or higher than the number of printed rows will be neglected. This vector
    will be appended to the one in `hlines`, but the indices here are related to the printed
    rows of the body. Thus, if `1` is added to `body_hlines`, a horizontal line will be
    drawn after the first data row.
    (**Default** = `Int[]`)
- `highlighters::Union{LatexHighlighter, Tuple}`: An instance of `LatexHighlighter` or a
    tuple with a list of LaTeX highlighters (see the section [LaTeX Highlighters](@ref)).
- `hlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where the
    horizontal lines will be drawn. It can be `nothing`, `:all`, `:none` or a vector of
    integers.
    (**Default** = `nothing`)
    - If it is `nothing`, which is the default, the configuration will be obtained from the
        table format in the variable `tf` (see [`LatexTableFormat`](@ref)).
    - If it is `:all`, all horizontal lines will be drawn.
    - If it is `:none`, no horizontal line will be drawn.
    - If it is a vector of integers, the horizontal lines will be drawn only after the rows
        in the vector. Notice that the top line will be drawn if `0` is in `hlines`, and the
        header and sub-headers are considered as only 1 row. Furthermore, it is important to
        mention that the row number in this variable is related to the **printed rows**.
        Thus, it is affected by the option to suppress the header `noheader`.  Finally, for
        convenience, the top and bottom lines can be drawn by adding the symbols `:begin`
        and `:end` to this vector, respectively, and the line after the header can be drawn
        by adding the symbol `:header`.

!!! info

    The values of `body_hlines` will be appended to this vector. Thus, horizontal lines can
    be drawn even if `hlines` is `:none`.

- `label::AbstractString`: The label of the table. If empty, no label will be added.
    (**Default** = "")
- `longtable_footer::Union{Nothing, AbstractString}`: The string that will be drawn in the
    footer of the tables before a page break. This only works if `table_type` is
    `:longtable`. If it is `nothing`, no footer will be used.
    (**Default** = `nothing`)
- `row_number_alignment::Symbol`: Select the alignment of the row number column (see the
    section [Alignment](@ref)).
    (**Default** = `:r`)
- `table_type::Union{Nothing, Symbol}`: Select which LaTeX environment will be used to print
    the table. Currently supported options are `:tabular` for `tabular` or `:longtable` for
    `longtable`. If it is `nothing`, the default option of the table format will be used.
    (**Default** = `nothing`)
- `tf::LatexTableFormat`: An instance of the structure [`LatexTableFormat`](@ref) that
    defines the general format of the LaTeX table.
- `vlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where the
    vertical lines will be drawn. It can be `:all`, `:none` or a vector of integers. In the
    first case (the default behavior), all vertical lines will be drawn. In the second case,
    no vertical line will be drawn. In the third case, the vertical lines will be drawn only
    after the columns in the vector.  Notice that the left border will be drawn if `0` is in
    `vlines`.  Furthermore, it is important to mention that the column number in this
    variable is related to the **printed columns**. Thus, it is affected by the columns
    added using the variable `show_row_number`. Finally, for convenience, the left and right
    border can be drawn by adding the symbols `:begin` and `:end` to this vector,
    respectively.
    (**Default** = `:none`)
- `wrap_table::Union{Nothing, String}`: This variable controls whether to wrap the table in
    a environment defined by the variable `wrap_table_environment`.  Defaults to `true`.
    When `false`, the printed table begins with `\\begin{tabular}`. This option does not
    work with `:longtable`. If it is `nothing`, the default option of the table format will
    be used.
    (**Default** = `nothing`)
- `wrap_table_environment::Union{Nothing, String}`: Environment that will be used to wrap
    the table if the option `wrap_table` is `true`. If it is `nothing`, the default option
    of the table format will be used.
    (**Default** = `nothing`)

## LaTeX Highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword. Each
highlighter is an instance of the structure [`LatexHighlighter`](@ref). It contains the
following two fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Functions`: A function with the signature `f(data, i, j, str)::String` in which
    `data` is the matrix, `(i, j)` is the element position in the table, and `str` is the
    data converted to string. This function must return a string that will be placed in the
    cell.

The function `f` has the following signature:

```julia
f(data, i, j)
```

in which `data` is a reference to the data that is being printed, `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the highlight
style will be applied to the `(i, j)` element.  Otherwise, the default style will be used.

Notice that if multiple highlighters are valid for the element `(i, j)`,  the applied style
will be equal to the first match considering the order in the Tuple `highlighters`.

If the function `f` returns true, the function `fd(data, i, j, str)` will be called and must
return the LaTeX string that will be placed in the cell.

If only a single highlighter is wanted, it can be passed directly to the keyword
`highlighter` without being inside a `Tuple`.

There are two helpers that can be used to create LaTeX highlighters:

```julia
LatexHighlighter(f::Function, envs::Union{String,Vector{String}})
LatexHighlighter(f::Function, fd::Function)
```

The first will apply recursively all the LaTeX environments in `envs` to the highlighted
text whereas the second let the user select the desired decoration by specifying the
function `fd`.

Thus, for example:

```julia
LatexHighlighter((data,i,j)->true, ["textbf", "small"])
```

will wrap all the cells in the table in the following environment:

```tex
\textbf{\small{<Cell text>}}
```

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

```@repl latex
t = 0:1:20

data = hcat(t, ones(length(t)) * 1, 1 * t, 0.5 .* t.^2)

header = (
    ["Time", "Acceleration",         "Velocity", "Distance"],
    [ "[s]",  latex_cell"[m/s$^2$]", "[m/s]",    "[m]"]
)

hl_v = LatexHighlighter((data, i, j) -> (j == 3) && data[i, 3] > 9, ["color{blue}","textbf"]);

hl_p = LatexHighlighter((data, i, j) -> (j == 4) && data[i, 4] > 10, ["color{red}", "textbf"])

hl_e = LatexHighlighter((data, i, j) -> (i == 10), ["cellcolor{black}", "color{white}", "textbf"])

pretty_table(data; backend = Val(:latex), header = header, highlighters = (hl_e, hl_p, hl_v))
```

```@setup latex
str = pretty_table(
    String,
    data;
    backend = Val(:latex),
    header = header,
    highlighters = (hl_e, hl_p, hl_v)
)

render(
    LaTeXString(str),
    MIME("image/png");
    name = "latex_highlighter",
    packages = ("colortbl", "xcolor"),
    open = false
)
```

![LaTeX highlighter example](./latex_highlighter.png)

!!! note

    The following LaTeX packages are required to render this example: `colortbl` and
    `xcolor`.

## PrettyTables and Latexify (LaTeXStrings)

To work with `LaTeXString`s, you must wrap them in `LatexCell`s. Otherwise, special LaTeX
characters are converted or escaped.

```@repl latex
using PrettyTables, Latexify

c1 = LatexCell.([latexify("α"), latexify("β")]);

c2 = [0.0, 1.0];

pretty_table([c1 c2], backend = Val(:latex))
```

## LaTeX Table Formats

The following table formats are available when using the LaTeX back end:

```@setup latex
header = [
  "Header 1" "Header 2" "Header 3" "Header 4"
  "Sub 1"    "Sub 2"    "Sub 3"    "Sub 4"
]

data = [
    true  100.0 0x8080 "String"
    false 200.0 0x0808 "String"
    true  300.0 0x1986 "String"
    false 400.0 0x1987 "String"
]

for prefix in (
    "default",
    "double",
    "modern",
    "booktabs",
)
    local str

    filename = "latex_format_$prefix"
    tf       = Symbol("tf_latex_" * prefix)

    str = pretty_table(
        String,
        data;
        backend = Val(:latex),
        tf = @eval($tf),
    )

    render(
      LaTeXString(str),
      MIME("image/png");
      name = filename,
      packages = ("array", "booktabs"),
      open = false
    )
end
```

### `tf_latex_default` (**Default**)

![`tf_latex_default`](./latex_format_default.png)

### `tf_latex_double`

![`tf_latex_double`](./latex_format_double.png)

### `tf_latex_modern`

![`tf_latex_modern`](./latex_format_modern.png)

!!! note

    You need the LaTeX package `array` to use the vertical divisions with this
    format.

### `tf_latex_booktabs`

![`tf_latex_booktabs`](./latex_format_booktabs.png)

!!! note

    You need the LaTeX package `booktabs` to render this format.
