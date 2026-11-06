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
    return _line_presence_keywords(true, _TABLE_FORMAT_HORIZONTAL_LINE_PRESENCE_FIELDS...)
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
    return _line_presence_keywords(true, _VERTICAL_LINE_PRESENCE_FIELDS...)
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
    return _line_presence_keywords(false, _TABLE_FORMAT_HORIZONTAL_LINE_PRESENCE_FIELDS...)
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
    return _line_presence_keywords(false, _VERTICAL_LINE_PRESENCE_FIELDS...)
end
