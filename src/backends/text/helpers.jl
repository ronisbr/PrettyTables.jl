## Description #############################################################################
#
# Helpers for designing tables in the text backend.
#
############################################################################################

export text__all_horizontal_lines, text__all_vertical_lines
export text__no_horizontal_lines, text__no_vertical_lines

"""
    text__all_horizontal_lines() -> NamedTuple

Return a named tuple with the arguments to be passed to [`TextTableFormat`](@ref) to show
all horizontal lines.

We can use the output of this function when creating the text table format object by using
the splat (`...`) operator. For example, the following code creates a text table format
with all horizontal lines:

```julia
tf = TextTableFormat(; text__all_horizontal_lines()...)
```

Any option can be overridden by merging the named tuples. For example, the following code
shows all the horizontal lines but the first one:

```julia
tf = TextTableFormat(; (text__all_horizontal_lines()..., horizontal_line_at_beginning = false)...)
```

# Extended Help

## Example

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TextTableFormat(; text__all_horizontal_lines()...))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
└────────┴────────┴────────┘

julia> pretty_table(
    A;
    table_format = TextTableFormat(
        ;
        (
            text__all_horizontal_lines()...,
            horizontal_line_after_column_labels = false
        )...
    )
)
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
│    1.0 │    1.0 │    1.0 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
└────────┴────────┴────────┘
```
"""
function text__all_horizontal_lines()
    return (
        horizontal_line_at_beginning           = true,
        horizontal_line_after_column_labels    = true,
        horizontal_lines_at_data_rows          = :all,
        horizontal_line_before_row_group_label = true,
        horizontal_line_after_row_group_label  = true,
        horizontal_line_after_data_rows        = true,
        horizontal_line_after_summary_rows     = true,
    )
end

"""
    text__all_vertical_lines() -> NamedTuple

Return a named tuple with the arguments to be passed to [`TextTableFormat`](@ref) to show
all vertical lines.

We can use the output of this function when creating the text table format object by using
the splat (`...`) operator. For example, the following code creates a text table format
with all vertical lines:

```julia
tf = TextTableFormat(; text__all_vertical_lines()...)
```

Any option can be overridden by merging the named tuples. For example, the following code
shows all the vertical lines but the first one:

```julia
tf = TextTableFormat(; (text__all_vertical_lines()..., vertical_line_at_beginning = false)...)
```

# Extended Help

## Examples

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TextTableFormat(; text__all_vertical_lines()...))
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
└────────┴────────┴────────┘

julia> pretty_table(
    A;
    show_row_number_column = true,
    table_format = TextTableFormat(
        ;
        (
            text__all_vertical_lines()...,
            vertical_line_after_row_number_column = false
        )...
    )
)
┌─────────────┬────────┬────────┐
│ Row  Col. 1 │ Col. 2 │ Col. 3 │
├─────────────┼────────┼────────┤
│   1     1.0 │    1.0 │    1.0 │
│   2     1.0 │    1.0 │    1.0 │
│   3     1.0 │    1.0 │    1.0 │
└─────────────┴────────┴────────┘
```
"""
function text__all_vertical_lines()
    return (
        right_vertical_lines_at_data_columns     = :all,
        suppress_vertical_lines_at_column_labels = false,
        vertical_line_after_continuation_column  = true,
        vertical_line_after_data_columns         = true,
        vertical_line_after_row_label_column     = true,
        vertical_line_after_row_number_column    = true,
        vertical_line_at_beginning               = true,
    )
end

"""
    text__no_horizontal_lines() -> NamedTuple

Return a named tuple with the arguments to be passed to [`TextTableFormat`](@ref) to
suppress all horizontal lines.

We can use the output of this function when creating the text table format object by using
the splat (`...`) operator. For example, the following code creates a text table format
without horizontal lines:

```julia
tf = TextTableFormat(; text__no_horizontal_lines()...)
```

Any option can be overridden by merging the named tuples. For example, the following code
draws only the horizontal line at the beginning of the table:

```julia
tf = TextTableFormat(; (text__no_horizontal_lines()..., horizontal_line_at_beginning = true)...)
```

# Extended Help

## Example

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TextTableFormat(; text__no_horizontal_lines()...))
│ Col. 1 │ Col. 2 │ Col. 3 │
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │

julia> pretty_table(
    A;
    table_format = TextTableFormat(
        ;
        (
            text__no_horizontal_lines()...,
            horizontal_line_after_column_labels = true
        )...
    )
)
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
```
"""
function text__no_horizontal_lines()
    return (
        horizontal_line_at_beginning           = false,
        horizontal_line_after_column_labels    = false,
        horizontal_lines_at_data_rows          = :none,
        horizontal_line_before_row_group_label = false,
        horizontal_line_after_row_group_label  = false,
        horizontal_line_after_data_rows        = false,
        horizontal_line_after_summary_rows     = false,
    )
end

"""
    text__no_vertical_lines() -> NamedTuple

Return a named tuple with the arguments to be passed to [`TextTableFormat`](@ref) to
suppress all vertical lines.

We can use the output of this function when creating the text table format object by using
the splat (`...`) operator. For example, the following code creates a text table format
without vertical lines:

```julia
tf = TextTableFormat(; text__no_vertical_lines()...)
```

Any option can be overridden by merging the named tuples. For example, the following code
draws only the vertical line at the beginning of the table:

```julia
tf = TextTableFormat(; (text__no_vertical_lines()..., vertical_line_at_beginning = true)...)
```

# Extended Help

## Examples

```julia-repl
julia> A = ones(3, 3);

julia> pretty_table(A; table_format = TextTableFormat(; text__no_vertical_lines()...))
────────────────────────
 Col. 1  Col. 2  Col. 3
────────────────────────
    1.0     1.0     1.0
    1.0     1.0     1.0
    1.0     1.0     1.0
────────────────────────

julia> pretty_table(
    A;
    show_row_number_column = true,
    table_format = TextTableFormat(
        ;
        (
            text__no_vertical_lines()...,
            vertical_line_after_row_number_column = true
        )...
    )
)
─────┬────────────────────────
 Row │ Col. 1  Col. 2  Col. 3
─────┼────────────────────────
   1 │    1.0     1.0     1.0
   2 │    1.0     1.0     1.0
   3 │    1.0     1.0     1.0
─────┴────────────────────────
```
"""
function text__no_vertical_lines()
    return (
        right_vertical_lines_at_data_columns     = :none,
        suppress_vertical_lines_at_column_labels = true,
        vertical_line_after_continuation_column  = false,
        vertical_line_after_data_columns         = false,
        vertical_line_after_row_label_column     = false,
        vertical_line_after_row_number_column    = false,
        vertical_line_at_beginning               = false,
    )
end
