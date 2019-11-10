Backends
========

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

# Text back-end

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
* `formatter`: See the section [Formatter](@ref).
* `highlighters`: An instance of `Highlighter` or a tuple with a list of
                  highlighters (see the section `Highlighters`).
* `hlines`: A vector of `Int` indicating row numbers in which an additional
            horizontal line should be drawn after the row. Notice that numbers
            lower than 1 and equal or higher than the number of rows will be
            neglected.
* `hlines_format`: A tuple of 4 characters specifying the format of the
                   horizontal lines. The characters must be the left
                   intersection, the middle intersection, the right
                   intersection, and the row. If it is `nothing`, then it will
                   use the same format specified in `tf`.
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
* `tf`: Table format used to print the table (see the section `TextFormat`).
        (**Default** = `unicode`)

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

# HTML backend

The following options are available when the HTML backend is used. Those can be
passed as keywords when calling the function `pretty_table`:

* `table_format`: An instance of the structure `HTMLTableFormat` that defines
                  the general format of the HTML table.
* `cell_alignment`: A dictionary of type `(i,j) => a` that overrides that
                    alignment of the cell `(i,j)` to `a` regardless of the
                    columns alignment selected. `a` must be a symbol like
                    specified in the section `Alignment`.
* `formatter`: See the section `Formatter`.
* `highlighters`: An instance of `HTMLHighlighter` or a tuple with a list of
                  HTML highlighters (see the section `HTML highlighters`).
* `linebreaks`: If `true`, then `\\n` will be replaced by `<br>`.
                (**Default** = `false`)
* `noheader`: If `true`, then the header will not be printed. Notice that all
              keywords and parameters related to the header and sub-headers will
              be ignored. (**Default** = `false`)
* `nosubheader`: If `true`, then the sub-header will not be printed, *i.e.* the
                 header will contain only one line. Notice that this option has
                 no effect if `noheader = true`. (**Default** = `false`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`)


