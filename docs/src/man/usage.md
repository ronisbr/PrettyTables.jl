Usage
=====

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

The following functions can be used to print data.

```julia
function pretty_table(data::AbstractMatrix{T1}, header::AbstractVector{T2}; kwargs...) where {T1,T2}
```

Print to `io` the matrix `data` with header `header` using the format `tf` (see
[Formats](@ref)). If `io` is omitted, then it defaults to `stdout`. If `header`
is empty, then it will be automatically filled with "Col. i" for the *i*-th
column.

```jldoctest
julia> data = [1 2 3; 4 5 6];

julia> pretty_table(data, ["Column 1", "Column 2", "Column 3"])
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘
```

``` julia
function pretty_table([io,] data::AbstractMatrix{T}, tf::PrettyTableFormat = unicode; ...) where T
```

Print to `io` the matrix `data` using the format `tf` (see `PrettyTableFormat`).
If `io` is omitted, then it defaults to `stdout`. The header will be
automatically filled with "Col. i" for the *i*-th column.

```jldoctest
julia> data = Any[1 2 3; true false true];

julia> pretty_table(data)
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │      3 │
│   true │  false │   true │
└────────┴────────┴────────┘
```

```julia
function pretty_table([io,] table, tf::PrettyTableFormat = unicode; ...)
```

Print to `io` the table `table` using the format `tf` (see [Formats](@ref)).  In
this case, `table` must comply with the API of
[Tables.jl](https://github.com/JuliaData/Tables.jl). If `io` is omitted, then it
defaults to `stdout`.

In all cases, the following keywords are available:

* `alignment`: Select the alignment of the columns (see the section
               [Alignment](@ref)).
* `border_bold`: If `true`, then the border will be printed in **bold**
                 (**Default** = `false`).
* `border_color`: The color in which the border will be printed using the same
                  convention as in the function `printstyled`. (**Default** =
                  `:normal`)
* `formatter`: See the section [Formatter](@ref).
* `header_bold`: If `true`, then the header will be printed in **bold**
                 (**Default** = `false`).
* `header_color`: The color in which the header will be printed using the same
                  convention as in the function `printstyled`. (**Default** =
                  `:normal`)
* `highlighters`: A tuple with a list of highlighters (see the section
                  [Highlighters](@ref)).
* `same_column_size`: If `true`, then all the columns will have the same size.
                      (**Default** = `false`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`.)
