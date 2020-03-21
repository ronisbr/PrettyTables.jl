Text back-end
=============

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

The following options are available when the text backend is used. Those can be
passed as keywords when calling the function `pretty_table`:

* `border_crayon`: Crayon to print the border.
* `header_crayon`: Crayon to print the header.
* `subheaders_crayon`: Crayon to print sub-headers.
* `rownum_header_crayon`: Crayon for the header of the column with the row
                          numbers.
* `text_crayon`: Crayon to print default text.
* `alignment`: Select the alignment of the columns (see the section
               [Alignment](@ref)).
* `autowrap`: If `true`, then the text will be wrapped on spaces to fit the
              column. Notice that this function requires `linebreaks = true` and
              the column must have a fixed size (see `columns_width`).
* `body_hlines`: A vector of `Int` indicating row numbers in which an additional
                 horizontal line should be drawn after the row. Notice that
                 numbers lower than 1 and equal or higher than the number of
                 printed rows will be neglected. This vector will be appended to
                 the one in `hlines`, but the indices here are related to the
                 printed rows of the body. Thus, if `1` is added to
                 `body_hlines`, then a horizontal line will be drawn after the
                 first data row. (**Default** = `Int[]`)
* `body_hlines_format`: A tuple of 4 characters specifying the format of the
                        horizontal lines that will be drawn by `body_hlines`.
                        The characters must be the left intersection, the middle
                        intersection, the right intersection, and the row. If it
                        is `nothing`, then it will use the same format specified
                        in `tf`. (**Default** = `nothing`)
* `cell_alignment`: A dictionary of type `(i,j) => a` that overrides that
                    alignment of the cell `(i,j)` to `a` regardless of the
                    columns alignment selected. `a` must be a symbol like
                    specified in the section [Alignment](@ref).
* `columns_width`: A set of integers specifying the width of each column. If the
                   width is equal or lower than 0, then it will be automatically
                   computed to fit the large cell in the column. If it is
                   a single integer, then this number will be used as the size
                   of all columns. (**Default** = 0)
* `crop`: Select the printing behavior when the data is bigger than the
          available screen size (see `screen_size`). It can be `:both` to crop
          on vertical and horizontal direction, `:horizontal` to crop only on
          horizontal direction, `:vertical` to crop only on vertical direction,
          or `:none` to do not crop the data at all.
* `filters_row`: Filters for the rows (see the section [Filters](@ref)).
* `filters_col`: Filters for the columns (see the section [Filters](@ref)).
* `highlighters`: An instance of `Highlighter` or a tuple with a list of
                  highlighters (see the section [Text highlighters](@ref)).
* `hlines`: This variable controls where the horizontal lines will be drawn. It
            can be `nothing`, `:all`, `:none` or a vector of integers.
    - If it is `nothing`, which is the default, then the configuration will be
      obtained from the table format in the variable `tf` (see `TextFormat`).
    - If it is `:all`, then all horizontal lines will be drawn.
    - If it is `:none`, then no horizontal line will be drawn.
    - If it is a vector of integers, then the horizontal lines will be drawn
      only after the rows in the vector. Notice that the top line will be drawn
      if `0` is in `hlines`, and the header and subheaders are considered as
      only 1 row. Furthermore, it is important to mention that the row number in
      this variable is related to the **printed rows**. Thus, it is affected by
      filters, and by the option to suppress the header `noheader`. Finally, for
      convenience, the top and bottom lines can be drawn by adding the symbols
      `:begin` and `:end` to this vector, respectively, and the line after the
      header can be drawn by adding the symbol `:header`.
  !!! info

      The values of `body_hlines` will be appended to this vector. Thus,
      horizontal lines can be drawn even if `hlines` is `:none`.

  (**Default** = `nothing`)
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
* `tf`: Table format used to print the table (see the section
        [Text table formats](@ref)). (**Default** = `unicode`)
* `vlines`: This variable controls where the vertical lines will be drawn. It
            can be `:all`, `:none` or a vector of integers. In the first case
            (the default behavior), all vertical lines will be drawn. In the
            second case, no vertical line will be drawn. In the third case,
            the vertical lines will be drawn only after the columns in the
            vector. Notice that the left border will be drawn if `0` is in
            `vlines`. Furthermore, it is important to mention that the column
            number in this variable is related to the **printed columns**. Thus,
            it is affected by filters, and by the columns added using the
            variables `show_row_number` and `row_names`. Finally, for
            convenience, the left and right border can be drawn by adding the
            symbols `:begin` and `:end` to this vector, respectively.
            (**Default** = `:all`)

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

If the user selects a fixed size for the columns (using the keyword
`columns_width`), enables line breaks (using the keyword `linebreaks`), and sets
`autowrap = true`, then the algorithm wraps the text on spaces to automatically
fit the space.

```jldoctest
julia> data = ["One very very very big long long line"; "Another very very very big big long long line"];

julia> pretty_table(data, columns_width = 10, autowrap = true, linebreaks = true, show_row_number = true)
┌─────┬────────────┐
│ Row │     Col. 1 │
├─────┼────────────┤
│   1 │   One very │
│     │  very very │
│     │   big long │
│     │  long line │
│   2 │    Another │
│     │  very very │
│     │   very big │
│     │   big long │
│     │  long line │
└─────┴────────────┘
```

## Text highlighters

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

```julia-repl
julia> h1 = Highlighter( f      = (data,i,j) -> (data[i,j] < 0.5),
                         crayon = crayon"red bold" )

julia> h2 = Highlighter( (data,i,j) -> (data[i,j] > 0.5),
                         bold       = true,
                         foreground = :blue )

julia> h3 = Highlighter( f          = (data,i,j) -> (data[i,j] == 0.5),
                         crayon     = Crayon(bold = true, foreground = :yellow) )

julia> pretty_table(data, highlighters = (h1, h2, h3))
```

![](../assets/ex_highlighters_00001.png)

If only a single highlighter is wanted, then it can be passed directly to the
keyword `highlighter` of `pretty_table` without being inside a `Tuple`.

```julia-repl
julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand) ]

julia> hl_odd = Highlighter( f      = (data,i,j) -> i % 2 == 0,
                             crayon = Crayon(background = :light_blue))

julia> pretty_table(data, highlighters = hl_odd, formatters = ft_printf("%10.5f"))
```

![](../assets/ex_highlighters_00002.png)

!!! note

    If the highlighters are used together with [Formatters](@ref), then the
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

## Text table formats

The following table formats are available when using the text back-end:

`unicode` (**Default**)

```
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
└────────┴────────┴────────┴────────┘
```

`ascii_dots`

```
.....................................
: Col. 1 : Col. 2 : Col. 3 : Col. 4 :
:........:........:........:........:
:      1 :  false :    1.0 :      1 :
:      2 :   true :    2.0 :      2 :
:      3 :  false :    3.0 :      3 :
:........:........:........:........:
```

`ascii_rounded`

```
.--------.--------.--------.--------.
| Col. 1 | Col. 2 | Col. 3 | Col. 4 |
:--------+--------+--------+--------:
|      1 |  false |    1.0 |      1 |
|      2 |   true |    2.0 |      2 |
|      3 |  false |    3.0 |      3 |
'--------'--------'--------'--------'
```

`borderless`

```
  Col. 1   Col. 2   Col. 3   Col. 4

       1    false      1.0        1
       2     true      2.0        2
       3    false      3.0        3
```

`compact`

```
 -------- -------- -------- --------
  Col. 1   Col. 2   Col. 3   Col. 4
 -------- -------- -------- --------
       1    false      1.0        1
       2     true      2.0        2
       3    false      3.0        3
 -------- -------- -------- --------
```

`markdown`

```
| Col. 1 | Col. 2 | Col. 3 | Col. 4 |
|--------|--------|--------|--------|
|      1 |  false |    1.0 |      1 |
|      2 |   true |    2.0 |      2 |
|      3 |  false |    3.0 |      3 |
```

`matrix`

```
┌                     ┐
│ 1   false   1.0   1 │
│ 2    true   2.0   2 │
│ 3   false   3.0   3 │
└                     ┘
```

!!! info

    In this case, the table format `matrix` was printed with the option
    `noheader = true`.

`mysql`

```
+--------+--------+--------+--------+
| Col. 1 | Col. 2 | Col. 3 | Col. 4 |
+--------+--------+--------+--------+
|      1 |  false |    1.0 |      1 |
|      2 |   true |    2.0 |      2 |
|      3 |  false |    3.0 |      3 |
+--------+--------+--------+--------+
```

`simple`

```
========= ======== ======== =========
  Col. 1   Col. 2   Col. 3   Col. 4
========= ======== ======== =========
       1    false      1.0        1
       2     true      2.0        2
       3    false      3.0        3
========= ======== ======== =========
```

`unicode_rounded`

```
╭────────┬────────┬────────┬────────╮
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
╰────────┴────────┴────────┴────────╯
```

!!! note

    The format `unicode_rounded` should look awful on your browser, but it
    should be printed fine on your terminal.

```jldoctest
julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand)];

julia> pretty_table(data, tf = ascii_dots)
..................................................................
:              Col. 1 :              Col. 2 :             Col. 3 :
:.....................:.....................:....................:
:                 0.0 :                 1.0 :                0.0 :
: 0.25881904510252074 :  0.9659258262890683 : 0.2679491924311227 :
:                 0.5 :  0.8660254037844386 : 0.5773502691896258 :
:  0.7071067811865476 :  0.7071067811865476 :                1.0 :
:  0.8660254037844386 :                 0.5 : 1.7320508075688772 :
:  0.9659258262890683 : 0.25881904510252074 : 3.7320508075688776 :
:                 1.0 :                 0.0 :                Inf :
:.....................:.....................:....................:

julia> pretty_table(data, tf = compact)
 --------------------- --------------------- --------------------
               Col. 1                Col. 2               Col. 3
 --------------------- --------------------- --------------------
                  0.0                   1.0                  0.0
  0.25881904510252074    0.9659258262890683   0.2679491924311227
                  0.5    0.8660254037844386   0.5773502691896258
   0.7071067811865476    0.7071067811865476                  1.0
   0.8660254037844386                   0.5   1.7320508075688772
   0.9659258262890683   0.25881904510252074   3.7320508075688776
                  1.0                   0.0                  Inf
 --------------------- --------------------- --------------------

```

It is also possible to define you own custom table by creating a new instance of
the structure [`TextFormat`](@ref). For example, let's say that you want a table
like `simple` that does not print the bottom line:

```julia-repl
julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand)];

julia> tf = TextFormat(simple, bottom_line = false);

julia> pretty_table(data, tf = tf)
====================== ===================== =====================
               Col. 1                Col. 2               Col. 3
====================== ===================== =====================
                  0.0                   1.0                  0.0
  0.25881904510252074    0.9659258262890683   0.2679491924311227
                  0.5    0.8660254037844386   0.5773502691896258
   0.7071067811865476    0.7071067811865476                  1.0
   0.8660254037844386                   0.5   1.7320508075688772
   0.9659258262890683   0.25881904510252074   3.7320508075688776
                  1.0                   0.0                  Inf

```

or that does not print the header line:

```julia-repl
julia> data = Any[ f(a) for a = 0:15:90, f in (sind,cosd,tand)];

julia> tf = TextFormat(simple, header_line = false);

julia> pretty_table(data, tf = tf)
====================== ===================== =====================
               Col. 1                Col. 2               Col. 3
                  0.0                   1.0                  0.0
  0.25881904510252074    0.9659258262890683   0.2679491924311227
                  0.5    0.8660254037844386   0.5773502691896258
   0.7071067811865476    0.7071067811865476                  1.0
   0.8660254037844386                   0.5   1.7320508075688772
   0.9659258262890683   0.25881904510252074   3.7320508075688776
                  1.0                   0.0                  Inf
====================== ===================== =====================
```

For more information, see the documentation of the structure
[`TextFormat`](@ref).
