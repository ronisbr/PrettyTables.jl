Highlighters
============

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

A highlighter is an instance of the structure [`Highlighter`](@ref) that
contains information about which elements a highlight style should be applied.
The structure contains three fields:

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

![](../assets/ex_highlighters_00002.png)

!!! note

    If the highlighters are used together with [Formatter](@ref), then the
    change in the format **will not** affect that parameter `data` passed to the
    highlighter function `f`. It will always receive the original, unformatted
    value.

There are a set of pre-defined highlighters (with names `hl_*`) to make the
usage simpler. They are defined in the file `./src/predefined_highlighters.jl`.

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

