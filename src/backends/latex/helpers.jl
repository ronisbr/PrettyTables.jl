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

We can use the output of this function when creating the text table format object. For
example, the following code creates a text table format with all horizontal lines:

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
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\hline
  1.0 & 1.0 & 1.0 \\\\hline
  1.0 & 1.0 & 1.0 \\\\hline
  1.0 & 1.0 & 1.0 \\\\hline
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
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\
  1.0 & 1.0 & 1.0 \\\\hline
  1.0 & 1.0 & 1.0 \\\\hline
  1.0 & 1.0 & 1.0 \\\\hline
\\end{tabular}
```
"""
macro latex__all_horizontal_lines()
    return :((
        horizontal_line_at_beginning            = true,
        horizontal_line_at_merged_column_labels = true,
        horizontal_line_after_column_labels     = true,
        horizontal_lines_at_data_rows           = :all,
        horizontal_line_before_row_group_label  = true,
        horizontal_line_after_row_group_label   = true,
        horizontal_line_after_data_rows         = true,
        horizontal_line_before_summary_rows     = true,
        horizontal_line_after_summary_rows      = true,
    )...)
end

"""
    @latex__all_vertical_lines() -> Keywords for `LatexTableFormat`

Return the keyword arguments to be passed to [`LatexTableFormat`](@ref) to show all vertical
lines.

We can use the output of this function when creating the text table format object. For
example, the following code creates a text table format with all vertical lines:

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
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\\\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\\\hline
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
  \\textbf{Row} & \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\\\hline
  1 & 1.0 & 1.0 & 1.0 \\\\
  2 & 1.0 & 1.0 & 1.0 \\\\
  3 & 1.0 & 1.0 & 1.0 \\\\\\hline
\\end{tabular}
```
"""
macro latex__all_vertical_lines()
    return :((
        vertical_line_after_continuation_column = true,
        vertical_lines_at_data_columns          = :all,
        vertical_line_after_data_columns        = true,
        vertical_line_after_row_label_column    = true,
        vertical_line_after_row_number_column   = true,
        vertical_line_at_beginning              = true,
    )...)
end

"""
    latex__no_horizontal_lines() -> Keywords for `LatexTableFormat`

Return the keyword arguments to be passed to [`LatexTableFormat`](@ref) to suppress all
horizontal lines.

We can use the output of this function when creating the text table format object. For
example, the following code creates a text table format without horizontal lines:

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
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\\\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
\\end{tabular}
```
"""
macro latex__no_horizontal_lines()
    return :((
        horizontal_line_at_beginning            = false,
        horizontal_line_at_merged_column_labels = false,
        horizontal_line_after_column_labels     = false,
        horizontal_lines_at_data_rows           = :none,
        horizontal_line_before_row_group_label  = false,
        horizontal_line_after_row_group_label   = false,
        horizontal_line_after_data_rows         = false,
        horizontal_line_before_summary_rows     = false,
        horizontal_line_after_summary_rows      = false,
    )...)
end

"""
    latex__no_vertical_lines() -> Keywords for `LatexTableFormat`

Return the keyword arguments to be passed to [`LatexTableFormat`](@ref) to suppress all
vertical lines.

We can use the output of this function when creating the text table format object. For
example, the following code creates a text table format without vertical lines:

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
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\\\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\\\hline
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
  \\textbf{Row} & \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\\\hline
  1 & 1.0 & 1.0 & 1.0 \\\\
  2 & 1.0 & 1.0 & 1.0 \\\\
  3 & 1.0 & 1.0 & 1.0 \\\\\\hline
\\end{tabular}
```
"""
macro latex__no_vertical_lines()
    return :((
        vertical_line_after_continuation_column = false,
        vertical_lines_at_data_columns          = :none,
        vertical_line_after_data_columns        = false,
        vertical_line_after_row_label_column    = false,
        vertical_line_after_row_number_column   = false,
        vertical_line_at_beginning              = false,
    )...)
end
