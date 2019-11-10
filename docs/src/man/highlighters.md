Highlighters
============

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

The highlighters are special structure used to highlight fields in the printed
table. The definition depends on the back-end.

# Text highlighters

A highlighter of the text backend is an instance of the structure
[`Highlighter`](@ref) that contains information about which elements a highlight
style should be applied when using the text backend. The structure contains
three fields:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighted, or `false`
       otherwise.
* `crayon`: Crayon with the style of a highlighted element.

The function `f` must have the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j`
are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i,j)` element.
Otherwise, the default style will be used.

A set of highlighters can be passed as a `Tuple` to the `highlighter` keyword.
Notice that if multiple highlighters are valid for the element `(i,j)`, then the
applied style will be equal to the first match considering the order in the
Tuple `highlighters`.

![](../assets/ex_highlighters_00001.png)

If only a single highlighter is wanted, then it can be passed directly to the
keyword `highlighter` of `pretty_table` without being inside a `Tuple`.

![](../assets/ex_highlighters_00002.png)

!!! note

    If the highlighters are used together with [Formatter](@ref), then the
    change in the format **will not** affect that parameter `data` passed to the
    highlighter function `f`. It will always receive the original, unformatted
    value.

There are a set of pre-defined highlighters (with names `hl_*`) to make the
usage simpler. They are defined in the file
`./src/backends/text/predefined_highlighters.jl`.

To make the syntax less cumbersome, the following helper function is available:

```julia
function Highlighter(f; kwargs...)
```

It creates a `Highlighter` with the function `f` and pass all the keyword
arguments `kwargs` to the `Crayon`. Hence, the following code:

```julia-repl
julia> Highlighter((data,i,j)->isodd(i), Crayon(bold = true, background = :dark_gray))
```

can be replaced by:

```julia-repl
julia> Highlighter((data,i,j)->isodd(i); bold = true, background = :dark_gray)
```

# HTML highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighter` keyword.
Each highlighter is an instance of a structure that is a subtype of
`AbstractHTMLHighlighter`. It also must also contain at least the following two
fields to comply with the API:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighter, or `false`
       otherwise.
* `fd`: Function with the signature `f(h,data,i,j)` in which `h` is the
        highlighter. This function must return the `HTMLDecoration` to be
        applied to the cell that must be highlighted.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j`
are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i,j)` element.
Otherwise, the default style will be used.

Notice that if multiple highlighters are valid for the element `(i,j)`, then the
applied style will be equal to the first match considering the order in the
Tuple `highlighters`.

If the function `f` returns true, then the function `fd(h,data,i,j)` will be
called and must return an element of type `HTMLDecoration` that contains the
decoration to be applied to the cell.

If only a single highlighter is wanted, then it can be passed directly to the
keyword `highlighter` without being inside a `Tuple`.

A default HTML highlighter `HTMLHighlighter` is available. It can be constructed
using the following functions:

```
HTMLHighlighter(f::Function, decoration::HTMLDecoration)
HTMLHighlighter(f::Function, fd::Function)
```

The first will apply a fixed decoration to the highlighted cell specified in
`decoration` whereas the second let the user select the desired decoration by
specifying the function `fd`.

!!! note

    If the highlighters are used together with [Formatter](@ref), then the
    change in the format **will not** affect that parameter `data` passed to the
    highlighter function `f`. It will always receive the original, unformatted
    value.

There are a set of pre-defined highlighters (with names `hl_*`) to make the
usage simpler. They are defined in the file
`./src/backends/html/predefined_highlighters.jl`.

```julia
julia> t = 0:1:20;

julia> data = hcat(t, ones(length(t))*1, 1*t, 0.5.*t.^2);

julia> header = ["Time" "Acceleration" "Velocity" "Distance";
                  "[s]"       "[m/s²]"    "[m/s]"      "[m]"];

julia> hl_v = HTMLHighlighter( (data,i,j)->(j == 3) && data[i,3] > 9, HTMLDecoration(color = "blue", font_weight = "bold"));

julia> hl_p = HTMLHighlighter( (data,i,j)->(j == 4) && data[i,4] > 10, HTMLDecoration(color = "red"));
```

```@raw html
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr><th style = "color: white; text-align: right; background: navy; ">Col. 1</th>
<th style = "color: white; text-align: right; background: navy; ">Col. 2</th>
<th style = "color: white; text-align: right; background: navy; ">Col. 3</th>
<th style = "color: white; text-align: right; background: navy; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: right; ">0.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">0.0</td>
<td style = "text-align: right; ">0.0</td>
</tr>
<tr>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">0.5</td>
</tr>
<tr>
<td style = "text-align: right; ">2.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">2.0</td>
<td style = "text-align: right; ">2.0</td>
</tr>
<tr>
<td style = "text-align: right; ">3.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">3.0</td>
<td style = "text-align: right; ">4.5</td>
</tr>
<tr>
<td style = "text-align: right; ">4.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">4.0</td>
<td style = "text-align: right; ">8.0</td>
</tr>
<tr>
<td style = "text-align: right; ">5.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">5.0</td>
<td style = "color: red; text-align: right; ">12.5</td>
</tr>
<tr>
<td style = "text-align: right; ">6.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">6.0</td>
<td style = "color: red; text-align: right; ">18.0</td>
</tr>
<tr>
<td style = "text-align: right; ">7.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">7.0</td>
<td style = "color: red; text-align: right; ">24.5</td>
</tr>
<tr>
<td style = "text-align: right; ">8.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">8.0</td>
<td style = "color: red; text-align: right; ">32.0</td>
</tr>
<tr>
<td style = "text-align: right; ">9.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">9.0</td>
<td style = "color: red; text-align: right; ">40.5</td>
</tr>
<tr>
<td style = "text-align: right; ">10.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">10.0</td>
<td style = "color: red; text-align: right; ">50.0</td>
</tr>
<tr>
<td style = "text-align: right; ">11.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">11.0</td>
<td style = "color: red; text-align: right; ">60.5</td>
</tr>
<tr>
<td style = "text-align: right; ">12.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">12.0</td>
<td style = "color: red; text-align: right; ">72.0</td>
</tr>
<tr>
<td style = "text-align: right; ">13.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">13.0</td>
<td style = "color: red; text-align: right; ">84.5</td>
</tr>
<tr>
<td style = "text-align: right; ">14.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">14.0</td>
<td style = "color: red; text-align: right; ">98.0</td>
</tr>
<tr>
<td style = "text-align: right; ">15.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">15.0</td>
<td style = "color: red; text-align: right; ">112.5</td>
</tr>
<tr>
<td style = "text-align: right; ">16.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">16.0</td>
<td style = "color: red; text-align: right; ">128.0</td>
</tr>
<tr>
<td style = "text-align: right; ">17.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">17.0</td>
<td style = "color: red; text-align: right; ">144.5</td>
</tr>
<tr>
<td style = "text-align: right; ">18.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">18.0</td>
<td style = "color: red; text-align: right; ">162.0</td>
</tr>
<tr>
<td style = "text-align: right; ">19.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">19.0</td>
<td style = "color: red; text-align: right; ">180.5</td>
</tr>
<tr>
<td style = "text-align: right; ">20.0</td>
<td style = "text-align: right; ">1.0</td>
<td style = "font-weight: bold; color: blue; text-align: right; ">20.0</td>
<td style = "color: red; text-align: right; ">200.0</td>
</tr>
</table></body></html>
```
