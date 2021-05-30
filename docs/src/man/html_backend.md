HTML back-end
=============

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

```@raw html
<script language="javascript" type="text/javascript">
 function resizeIframe(obj)
 {
   obj.style.height = obj.contentWindow.document.body.scrollHeight + 10 + 'px';
   obj.style.width = obj.contentWindow.document.body.scrollWidth + 100 + 'px';
 }
</script>
```

The following options are available when the HTML backend is used. Those can be
passed as keywords when calling the function [`pretty_table`](@ref):

- `highlighters::Union{HTMLHighlighter, Tuple}`: An instance of
    [`HTMLHighlighter`](@ref) or a tuple with a list of HTML highlighters (see
    the section [HTML highlighters](@ref)).
- `linebreaks::Bool`: If `true`, then `\\n` will be replaced by `<br>`.
    (**Default** = `false`)
- `noheader::Bool`: If `true`, then the header will not be printed. Notice that
    all keywords and parameters related to the header and sub-headers will be
    ignored. (**Default** = `false`)
- `nosubheader::Bool`: If `true`, then the sub-header will not be printed,
    *i.e.* the header will contain only one line. Notice that this option has no
    effect if `noheader = true`. (**Default** = `false`)
- `standalone::Bool`: If `true`, then a complete HTML page will be generated.
    Otherwise, only the content between the tags `<table>` and `</table>` will
    be printed (with the tags included). (**Default** = `true`)
- `tf::HTMLTableFormat`: An instance of the structure [`HTMLTableFormat`](@ref)
    that defines the general format of the HTML table.

## HTML highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.
Each highlighter is an instance of the structure [`HTMLHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should
    return `true` if the element `(i,j)` in `data` must be highlighted, or
    `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is
    the highlighter. This function must return the `HTMLDecoration` to be
    applied to the cell that must be highlighted.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, and `i` and
`j` are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i, j)` element.
Otherwise, the default style will be used.

If the function `f` returns true, then the function `fd(h, data, i, j)` will be
called and must return an element of type [`HTMLDecoration`](@ref) that contains
the decoration to be applied to the cell.

A HTML highlighter can be constructed using two helpers:

```julia
HTMLHighlighter(f::Function, decoration::HTMLDecoration)
HTMLHighlighter(f::Function, fd::Function)
```

The first will apply a fixed decoration to the highlighted cell specified in
`decoration` whereas the second let the user select the desired decoration by
specifying the function `fd`.

!!! info
    If only a single highlighter is wanted, then it can be passed directly to
    the keyword `highlighter` without being inside a `Tuple`.

!!! note
    If multiple highlighters are valid for the element `(i, j)`, then the
    applied style will be equal to the first match considering the order in the
    tuple `highlighters`.

!!! note
    If the highlighters are used together with [Formatters](@ref), then the
    change in the format **will not** affect the parameter `data` passed to the
    highlighter function `f`. It will always receive the original, unformatted
    value.

There are a set of pre-defined highlighters (with names `hl_*`) to make the
usage simpler. They are defined in the file
`./src/backends/html/predefined_highlighters.jl`.

```julia
julia> t = 0:1:20;

julia> data = hcat(t, ones(length(t)) * 1, 1 * t, 0.5 .* t.^2);

julia> header = (["Time", "Acceleration", "Velocity", "Distance"],
                 [ "[s]",       "[m/s²]",    "[m/s]",      "[m]"]);

julia> hl_v = HTMLHighlighter((data, i, j) -> (j == 3) && data[i, 3] > 9, HTMLDecoration(color = "blue", font_weight = "bold"));

julia> hl_p = HTMLHighlighter((data, i, j) -> (j == 4) && data[i, 4] > 10, HTMLDecoration(color = "red"));

julia> hl_e = HTMLHighlighter((data, i, j) -> data[i, 1] == 10, HTMLDecoration(background = "black", color = "white"))

julia> pretty_table(data; backend = Val(:html), header = header, highlighters = (hl_e, hl_p, hl_v))
```

```@raw html
<iframe src="html_highlighters_example.html" frameborder="0" scrolling="no" onload="javascript:resizeIframe(this)">
  <p>Your browser does not support iframes. Click <a href="html_highlighters_example.html>here</a> to see the table.</p>
</iframe>
```

## HTML table formats

The following table formats are available when using the html back-end:

`tf_html_default` (**Default**)

```@raw html
<iframe src="html_format_default.html" frameborder="0" scrolling="no" onload="javascript:resizeIframe(this)">
  <p>Your browser does not support iframes. Click <a href="html_format_default.html>here</a> to see the table.</p>
</iframe>
```

`tf_html_dark`

```@raw html
<iframe src="html_format_dark.html" frameborder="0" scrolling="no" onload="javascript:resizeIframe(this)">
  <p>Your browser does not support iframes. Click <a href="html_format_dark.html>here</a> to see the table.</p>
</iframe>
```

`tf_html_minimalist`

```@raw html
<iframe src="html_format_minimalist.html" frameborder="0" scrolling="no" onload="javascript:resizeIframe(this)">
  <p>Your browser does not support iframes. Click <a href="html_format_minimalist.html>here</a> to see the table.</p>
</iframe>
```

`tf_html_matrix`

```@raw html
<iframe src="html_format_matrix.html" frameborder="0" scrolling="no" onload="javascript:resizeIframe(this)">
  <p>Your browser does not support iframes. Click <a href="html_format_matrix.html>here</a> to see the table.</p>
</iframe>
```

!!! info
    In this case, the table format `html_matrix` was printed with the option
    `noheader = true`.

`tf_html_simple`

```@raw html
<iframe src="html_format_simple.html" frameborder="0" scrolling="no" onload="javascript:resizeIframe(this)">
  <p>Your browser does not support iframes. Click <a href="html_format_simple.html>here</a> to see the table.</p>
</iframe>
```
