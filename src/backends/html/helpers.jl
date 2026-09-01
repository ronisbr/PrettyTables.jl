## Description #############################################################################
#
# Helpers for designing tables in the HTML backend.
#
############################################################################################

export @html__all_horizontal_lines, @html__all_vertical_lines
export @html__no_horizontal_lines, @html__no_vertical_lines

"""
    @html__all_horizontal_lines() -> Keywords for `HtmlTableFormat`

Return the keyword arguments to be passed to [`HtmlTableFormat`](@ref) to show all
horizontal lines.

We can use the output of this function when creating the HTML table format object. For
example, the following code creates an HTML table format with all horizontal lines:

```julia
tf = HtmlTableFormat(; @html__all_horizontal_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the horizontal lines but the first one:

```julia
tf = HtmlTableFormat(; @html__all_horizontal_lines, horizontal_line_at_beginning = false)
```
"""
macro html__all_horizontal_lines()
    return :(
        (
            horizontal_line_at_beginning            = true,
            horizontal_line_before_column_labels    = true,
            horizontal_line_at_merged_column_labels = true,
            horizontal_line_after_column_labels     = true,
            horizontal_lines_at_data_rows           = :all,
            horizontal_line_before_row_group_label  = true,
            horizontal_line_after_row_group_label   = true,
            horizontal_line_after_data_rows         = true,
            horizontal_line_before_summary_rows     = true,
            horizontal_line_after_summary_rows      = true,
            horizontal_line_after_footnotes         = true,
            horizontal_line_at_end                  = true,
        )...
    )
end

"""
    @html__all_vertical_lines() -> Keywords for `HtmlTableFormat`

Return the keyword arguments to be passed to [`HtmlTableFormat`](@ref) to show all vertical
lines.

We can use the output of this function when creating the HTML table format object. For
example, the following code creates an HTML table format with all vertical lines:

```julia
tf = HtmlTableFormat(; @html__all_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the vertical lines but the first one:

```julia
tf = HtmlTableFormat(; @html__all_vertical_lines, vertical_line_at_beginning = false)
```
"""
macro html__all_vertical_lines()
    return :(
        (
            vertical_line_after_continuation_column = true,
            vertical_lines_at_data_columns          = :all,
            vertical_line_after_data_columns        = true,
            vertical_line_after_row_label_column    = true,
            vertical_line_after_row_number_column   = true,
            vertical_line_at_beginning              = true,
        )...
    )
end

"""
    @html__no_horizontal_lines() -> Keywords for `HtmlTableFormat`

Return the keyword arguments to be passed to [`HtmlTableFormat`](@ref) to suppress all
horizontal lines.

We can use the output of this function when creating the HTML table format object. For
example, the following code creates an HTML table format without horizontal lines:

```julia
tf = HtmlTableFormat(; @html__no_horizontal_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the horizontal line at the beginning of the table:

```julia
tf = HtmlTableFormat(; @html__no_horizontal_lines, horizontal_line_at_beginning = true)
```
"""
macro html__no_horizontal_lines()
    return :(
        (
            horizontal_line_at_beginning            = false,
            horizontal_line_before_column_labels    = false,
            horizontal_line_at_merged_column_labels = false,
            horizontal_line_after_column_labels     = false,
            horizontal_lines_at_data_rows           = :none,
            horizontal_line_before_row_group_label  = false,
            horizontal_line_after_row_group_label   = false,
            horizontal_line_after_data_rows         = false,
            horizontal_line_before_summary_rows     = false,
            horizontal_line_after_summary_rows      = false,
            horizontal_line_after_footnotes         = false,
            horizontal_line_at_end                  = false,
        )...
    )
end

"""
    @html__no_vertical_lines() -> Keywords for `HtmlTableFormat`

Return the keyword arguments to be passed to [`HtmlTableFormat`](@ref) to suppress all
vertical lines.

We can use the output of this function when creating the HTML table format object. For
example, the following code creates an HTML table format without vertical lines:

```julia
tf = HtmlTableFormat(; @html__no_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the vertical line at the beginning of the table:

```julia
tf = HtmlTableFormat(; @html__no_vertical_lines, vertical_line_at_beginning = true)
```
"""
macro html__no_vertical_lines()
    return :(
        (
            vertical_line_after_continuation_column = false,
            vertical_lines_at_data_columns          = :none,
            vertical_line_after_data_columns        = false,
            vertical_line_after_row_label_column    = false,
            vertical_line_after_row_number_column   = false,
            vertical_line_at_beginning              = false,
        )...
    )
end
