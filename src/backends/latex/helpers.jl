## Description #############################################################################
#
# Helpers for designing tables in the LaTeX backend.
#
############################################################################################

export @latex__all_horizontal_lines, @latex__all_vertical_lines
export @latex__no_horizontal_lines, @latex__no_vertical_lines

"""
    @latex__all_horizontal_lines() -> Keywords for `LatexTableFormat`

Return the keyword arguments to be passed to [`LatexTableFormat`](@ref) to show all
horizontal lines.

We can use the output of this function when creating the LaTeX table format object. For
example, the following code creates a LaTeX table format with all horizontal lines:

```julia
tf = LatexTableFormat(; @latex__all_horizontal_lines())
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the horizontal lines but the first one:

```julia
tf = LatexTableFormat(; @latex__all_horizontal_lines, horizontal_line_at_beginning = false)
```

# Extended Help

## Example

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = LatexTableFormat(; @latex__all_horizontal_lines))
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}

julia> pretty_table(
           A;
           table_format = LatexTableFormat(;
               @latex__all_horizontal_lines,
               horizontal_line_after_column_labels = false
           )
       )
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  1.0 & 1.0 & 1.0 \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}
```
"""
macro latex__all_horizontal_lines()
    return _line_presence_keywords(true, _HORIZONTAL_LINE_PRESENCE_FIELDS...)
end

"""
    @latex__all_vertical_lines() -> Keywords for `LatexTableFormat`

Return the keyword arguments to be passed to [`LatexTableFormat`](@ref) to show all vertical
lines.

We can use the output of this function when creating the LaTeX table format object. For
example, the following code creates a LaTeX table format with all vertical lines:

```julia
tf = LatexTableFormat(; @latex__all_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the vertical lines but the first one:

```julia
tf = LatexTableFormat(; @latex__all_vertical_lines, vertical_line_at_beginning = false)
```

# Extended Help

## Examples

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = LatexTableFormat(; @latex__all_vertical_lines))
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}

julia> pretty_table(
           A;
           show_row_number_column = true,
           table_format = LatexTableFormat(;
               @latex__all_vertical_lines,
               vertical_line_after_row_number_column = false
           )
       )
\\begin{tabular}{|rr|r|r|}
  \\hline
  \\textbf{Row} & \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1 & 1.0 & 1.0 & 1.0 \\\\
  2 & 1.0 & 1.0 & 1.0 \\\\
  3 & 1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}
```
"""
macro latex__all_vertical_lines()
    return _line_presence_keywords(true, _VERTICAL_LINE_PRESENCE_FIELDS...)
end

"""
    @latex__no_horizontal_lines() -> Keywords for `LatexTableFormat`

Return the keyword arguments to be passed to [`LatexTableFormat`](@ref) to suppress all
horizontal lines.

We can use the output of this function when creating the LaTeX table format object. For
example, the following code creates a LaTeX table format without horizontal lines:

```julia
tf = LatexTableFormat(; @latex__no_horizontal_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the horizontal line at the beginning of the table:

```julia
tf = LatexTableFormat(; @latex__no_horizontal_lines, horizontal_line_at_beginning = true)
```

# Extended Help

## Example

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = LatexTableFormat(; @latex__no_horizontal_lines))
\\begin{tabular}{|r|r|r|}
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
\\end{tabular}

julia> pretty_table(
           A;
           table_format = LatexTableFormat(;
               @latex__no_horizontal_lines,
               horizontal_line_after_column_labels = true
           )
       )
\\begin{tabular}{|r|r|r|}
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
\\end{tabular}
```
"""
macro latex__no_horizontal_lines()
    return _line_presence_keywords(false, _HORIZONTAL_LINE_PRESENCE_FIELDS...)
end

"""
    @latex__no_vertical_lines() -> Keywords for `LatexTableFormat`

Return the keyword arguments to be passed to [`LatexTableFormat`](@ref) to suppress all
vertical lines.

We can use the output of this function when creating the LaTeX table format object. For
example, the following code creates a LaTeX table format without vertical lines:

```julia
tf = LatexTableFormat(; @latex__no_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the vertical line at the beginning of the table:

```julia
tf = LatexTableFormat(; @latex__no_vertical_lines, vertical_line_at_beginning = true)
```

# Extended Help

## Examples

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = LatexTableFormat(; @latex__no_vertical_lines))
\\begin{tabular}{rrr}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}

julia> pretty_table(
           A;
           show_row_number_column = true,
           table_format = LatexTableFormat(;
               @latex__no_vertical_lines,
               vertical_line_after_row_number_column = true
           )
       )
\\begin{tabular}{r|rrr}
  \\hline
  \\textbf{Row} & \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1 & 1.0 & 1.0 & 1.0 \\\\
  2 & 1.0 & 1.0 & 1.0 \\\\
  3 & 1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}
```
"""
macro latex__no_vertical_lines()
    return _line_presence_keywords(false, _VERTICAL_LINE_PRESENCE_FIELDS...)
end
