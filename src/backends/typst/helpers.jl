## Description #############################################################################
#
# Helpers for designing tables in the Typst backend.
#
############################################################################################

export @typst__all_horizontal_lines, @typst__all_vertical_lines
export @typst__no_horizontal_lines, @typst__no_vertical_lines

"""
    @typst__all_horizontal_lines() -> Keywords for `TypstTableFormat`

Return the keyword arguments to be passed to [`TypstTableFormat`](@ref) to show all
horizontal lines.

We can use the output of this function when creating the Typst table format object. For
example, the following code creates a Typst table format with all horizontal lines:

```julia
tf = TypstTableFormat(; @typst__all_horizontal_lines())
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the horizontal lines but the first one:

```julia
tf = TypstTableFormat(; @typst__all_horizontal_lines, horizontal_line_at_beginning = false)
```

# Extended Help

## Example

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TypstTableFormat(; @typst__all_horizontal_lines))
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 2, stroke: 0.5pt,),
    table.hline(y: 3, stroke: 0.5pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}

julia> pretty_table(
           A;
           table_format = TypstTableFormat(;
               @typst__all_horizontal_lines,
               horizontal_line_after_column_labels = false
           )
       )
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 2, stroke: 0.5pt,),
    table.hline(y: 3, stroke: 0.5pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}
```
"""
macro typst__all_horizontal_lines()
    return _line_presence_keywords(true, _HORIZONTAL_LINE_PRESENCE_FIELDS...)
end

"""
    @typst__all_vertical_lines() -> Keywords for `TypstTableFormat`

Return the keyword arguments to be passed to [`TypstTableFormat`](@ref) to show all vertical
lines.

We can use the output of this function when creating the Typst table format object. For
example, the following code creates a Typst table format with all vertical lines:

```julia
tf = TypstTableFormat(; @typst__all_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the vertical lines but the first one:

```julia
tf = TypstTableFormat(; @typst__all_vertical_lines, vertical_line_at_beginning = false)
```

# Extended Help

## Examples

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TypstTableFormat(; @typst__all_vertical_lines))
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}

julia> pretty_table(
           A;
           show_row_number_column = true,
           table_format = TypstTableFormat(;
               @typst__all_vertical_lines,
               vertical_line_after_row_number_column = false
           )
       )
#{
  table(
    align: (right, right, right, right,),
    columns: (auto, auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 0.8pt),
    table.vline(x: 4, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Row]],
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold",)[1]],
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [#text(weight: "bold",)[2]],
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [#text(weight: "bold",)[3]],
    [1.0],
    [1.0],
    [1.0],
  )
}
```
"""
macro typst__all_vertical_lines()
    return _line_presence_keywords(true, _VERTICAL_LINE_PRESENCE_FIELDS...)
end

"""
    @typst__no_horizontal_lines() -> Keywords for `TypstTableFormat`

Return the keyword arguments to be passed to [`TypstTableFormat`](@ref) to suppress all
horizontal lines.

We can use the output of this function when creating the Typst table format object. For
example, the following code creates a Typst table format without horizontal lines:

```julia
tf = TypstTableFormat(; @typst__no_horizontal_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the horizontal line at the beginning of the table:

```julia
tf = TypstTableFormat(; @typst__no_horizontal_lines, horizontal_line_at_beginning = true)
```

# Extended Help

## Example

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TypstTableFormat(; @typst__no_horizontal_lines))
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}

julia> pretty_table(
           A;
           table_format = TypstTableFormat(;
               @typst__no_horizontal_lines,
               horizontal_line_after_column_labels = true
           )
       )
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 1, stroke: 0.8pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}
```
"""
macro typst__no_horizontal_lines()
    return _line_presence_keywords(false, _HORIZONTAL_LINE_PRESENCE_FIELDS...)
end

"""
    @typst__no_vertical_lines() -> Keywords for `TypstTableFormat`

Return the keyword arguments to be passed to [`TypstTableFormat`](@ref) to suppress all
vertical lines.

We can use the output of this function when creating the Typst table format object. For
example, the following code creates a Typst table format without vertical lines:

```julia
tf = TypstTableFormat(; @typst__no_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the vertical line at the beginning of the table:

```julia
tf = TypstTableFormat(; @typst__no_vertical_lines, vertical_line_at_beginning = true)
```

# Extended Help

## Examples

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TypstTableFormat(; @typst__no_vertical_lines))
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}

julia> pretty_table(
           A;
           show_row_number_column = true,
           table_format = TypstTableFormat(;
               @typst__no_vertical_lines,
               vertical_line_after_row_number_column = true
           )
       )
#{
  table(
    align: (right, right, right, right,),
    columns: (auto, auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Row]],
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold",)[1]],
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [#text(weight: "bold",)[2]],
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [#text(weight: "bold",)[3]],
    [1.0],
    [1.0],
    [1.0],
  )
}
```
"""
macro typst__no_vertical_lines()
    return _line_presence_keywords(false, _VERTICAL_LINE_PRESENCE_FIELDS...)
end
