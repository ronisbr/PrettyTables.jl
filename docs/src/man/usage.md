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
function pretty_table([io::IO,] data::AbstractVecOrMat{T1}, header::AbstractVecOrMat{T2}, tf::PrettyTableFormat = unicode; kwargs...) where {T1,T2}
```

Print to `io` the vector or matrix `data` with header `header` using the format
`tf` (see [Formats](@ref)). If `io` is omitted, then it defaults to `stdout`. If
`header` is empty, then it will be automatically filled with "Col. i" for the
*i*-th column.

The `header` can be a `Vector` or a `Matrix`. If it is a `Matrix`, then each row
will be a header line. The first line is called *header* and the others are
called *sub-headers* .

```jldoctest
julia> data = [1 2 3; 4 5 6];

julia> pretty_table(data, ["Column 1", "Column 2", "Column 3"])
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘

julia> pretty_table(data, ["Column 1" "Column 2" "Column 3"; "A" "B" "C"])
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
│        A │        B │        C │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘
```

``` julia
function pretty_table([io,] data::AbstractVecOrMat{T}, tf::PrettyTableFormat = unicode; ...) where T
```

Print to `io` the vector or matrix `data` using the format `tf` (see
`PrettyTableFormat`). If `io` is omitted, then it defaults to `stdout`. The
header will be automatically filled with "Col. i" for the *i*-th column.

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

!!! note

    If `data` is a vector, then the `header` **must** be a vector. In this case,
    the first element is considered the header and the others are the
    sub-headers.

```julia
function pretty_table([io::IO,] dict::Dict{K,V}, tf::PrettyTableFormat = unicode; sortkeys = true, ...) where {K,V}
```

Print to `io` the dictionary `dict` in a matrix form (one column for the keys
and other for the values), using the format `tf` (see `PrettyTableFormat`). If
`io` is omitted, then it defaults to `stdout`.

In this case, the keyword `sortkeys` can be used to select whether or not the
user wants to print the dictionary with the keys sorted. If it is `false`, then
the elements will be printed on the same order returned by the functions `keys`
and `values`. Notice that this assumes that the keys are sortable, if they are
not, then an error will be thrown.

```julia
julia> dict = Dict(1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr", 5 => "May", 6 => "Jun");

julia> pretty_table(dict)
┌───────┬────────┐
│  Keys │ Values │
│ Int64 │ String │
├───────┼────────┤
│     4 │    Apr │
│     2 │    Feb │
│     3 │    Mar │
│     5 │    May │
│     6 │    Jun │
│     1 │    Jan │
└───────┴────────┘

julia> pretty_table(dict, sortkeys = true)
┌───────┬────────┐
│  Keys │ Values │
│ Int64 │ String │
├───────┼────────┤
│     1 │    Jan │
│     2 │    Feb │
│     3 │    Mar │
│     4 │    Apr │
│     5 │    May │
│     6 │    Jun │
└───────┴────────┘

```

```julia
function pretty_table([io,] table, tf::PrettyTableFormat = unicode; ...)
```

Print to `io` the table `table` using the format `tf` (see [Formats](@ref)).  In
this case, `table` must comply with the API of
[Tables.jl](https://github.com/JuliaData/Tables.jl). If `io` is omitted, then it
defaults to `stdout`.

In all cases, the following keywords are available:

* `border_crayon`: Crayon to print the border.
* `header_crayon`: Crayon to print the header.
* `subheaders_crayon`: Crayon to print sub-headers.
* `rownum_header_crayon`: Crayon for the header of the column with the row
                          numbers.
* `text_crayon`: Crayon to print default text.
* `alignment`: Select the alignment of the columns (see the section
               [Alignment](@ref)).
* `crop`: Select the printing behavior when the data is bigger than the
          available screen size (see `screen_size`). It can be `:both` to crop
          on vertical and horizontal direction, `:horizontal` to crop only on
          horizontal direction, `:vertical` to crop only on vertical direction,
          or `:none` to do not crop the data at all.
* `filters_row`: Filters for the rows (see the section [Filters](@ref)).
* `filters_col`: Filters for the columns (see the section [Filters](@ref)).
* `formatter`: See the section [Formatter](@ref).
* `highlighters`: A tuple with a list of highlighters (see the section
                  [Highlighters](@ref)).
* `hlines`: A vector of `Int` indicating row numbers in which an additional
            horizontal line should be drawn after the row. Notice that numbers
            lower than 1 and equal or higher than the number of rows will be
            neglected.
* `linebreaks`: If `true`, then `\n` will break the line inside the cells.
                (**Default** = `false`)
* `noheader`: If `true`, then the header will not be printed. Notice that all
              keywords and parameters related to the header and sub-headers will
              be ignored. (**Default** = `false`)
* `nosubheader`: If `true`, then the sub-header will not be printed, *i.e.* the
                 header will contain only one line. Notice that this option has
                 no effect if `noheader = true`. (**Default** = `false`)
* `same_column_size`: If `true`, then all the columns will have the same size.
                      (**Default** = `false`)
* `screen_size`: A tuple of two integers that defines the screen size (num. of
                 rows, num. of columns) that is available to print the table. It
                 is used to crop the data depending on the value of the keyword
                 `crop`. If it is `nothing`, then the size will be obtained
                 automatically. Notice that if a dimension is not positive, then
                 it will be treated as unlimited. (**Default** = `nothing`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`)

The keywords `header_crayon` and `subheaders_crayon` can be a `Crayon` or a
`Vector{Crayon}`. In the first case, the `Crayon` will be applied to all the
elements. In the second, each element can have its own crayon, but the length of
the vector must be equal to the number of columns in the data.

## Crayons

A `Crayon` is an object that handles a style for text printed on terminals. It
is defined in the package
[Crayons.jl](https://github.com/KristofferC/Crayons.jl). There are many options
available to customize the style, such as foreground color, background color,
bold text, etc.

A `Crayon` can be created in two different ways:

```julia-repl
julia> Crayon(foreground = :blue, background = :black, bold = :true)

julia> crayon"blue bg:black bold"
```

For more information, see the [Crayon.jl
documentation](https://github.com/KristofferC/Crayons.jl/blob/master/README.md).

!!! info

    The Crayon.jl package is re-exported by PrettyTables.jl. Hence, you do not
    need `using Crayons` to create a `Crayon`.

## Cropping

By default, the data will be cropped to fit the screen. This behavior can be
changed by using the keyword `crop`.

```jldoctest
julia> data = Any[1    false      1.0     0x01 ;
                  2     true      2.0     0x02 ;
                  3    false      3.0     0x03 ;
                  4     true      4.0     0x04 ;
                  5    false      5.0     0x05 ;
                  6     true      6.0     0x06 ;];

julia> pretty_table(data, screen_size = (10,30))
┌────────┬────────┬────────┬ ⋯
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼ ⋯
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│   ⋮    │   ⋮    │   ⋮    │ ⋯
└────────┴────────┴────────┴ ⋯

julia> pretty_table(data, screen_size = (10,30), crop = :none)
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
```

If the keyword `screen_size` is not specified (or is `nothing`), then the screen
size will be obtained automatically. For files, `screen_size = (-1,-1)`, meaning
that no limit exits in both vertical and horizontal direction.

!!! note

    In vertical cropping, the header and the first table row is **always**
    printed.    

!!! note

    The highlighters will work even in partially printed data.

## Helpers

The macro `@pt` was created to make it easier to pretty print tables to
`stdout`. Its signature is:

```julia
macro pt(expr...)
```

where the expression list `expr` must be:

```
[<Set of configurations> table]*
```

in which the set of configurations are expressions like `key = value`. The keys
can be:

* `header`: Select a header for the table.
* `tf`: Select a table format.
* Any other possible keyword that can be used in the function `pretty_table`.

Notice that multiple tables can be printed. Furthermore, the configurations
persist for multiple printing **except for the header**. Hence, for example:

```julia
@pt header = header1 highlighters = hl1 formatter = ft1 table1 highlighters = hl2 table2
```

will print `table1` using the header `header1` and the configuration
`highlighters = hl1 formatter = ft1` and will print `table2` without header and
using `highlighters = hl2 formatter = ft1`.

```jldoctest
julia> data = [1 2 3; 4 5 6];

julia> @pt data
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘

julia> @pt header = ["Column 1", "Column 2", "Column 3"] data header = ["Column 1" "Column 2" "Column 3"; "A" "B" "C"] data
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘
┌──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │
│        A │        B │        C │
├──────────┼──────────┼──────────┤
│        1 │        2 │        3 │
│        4 │        5 │        6 │
└──────────┴──────────┴──────────┘
```

!!! info

    When more than one table is passed to this macro, then multiple calls to
    `pretty_table` will occur. Hence, the cropping algorithm will behave exactly
    the same as printing the tables separately.

