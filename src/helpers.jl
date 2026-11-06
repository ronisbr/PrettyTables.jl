## Description #############################################################################
#
# Helpers for designing tables using the backend-agnostic table format.
#
############################################################################################

export @all_horizontal_lines, @all_vertical_lines
export @no_horizontal_lines, @no_vertical_lines

############################################################################################
#                                     Private Functions                                    #
############################################################################################

# Line presence fields that select a set of indices instead of holding a `Bool`.
const _LINE_INDICES_PRESENCE_FIELDS = (
    :horizontal_lines_at_column_labels,
    :horizontal_lines_at_data_rows,
    :vertical_lines_at_data_columns,
)

"""
    _line_presence_keywords(show::Bool, fields::Symbol...; kwargs...) -> Expr

Return the expression that splats the keywords setting every line presence field in `fields`
to show (`show = true`) or hide (`show = false`) its lines. The fields that select a set of
indices (see `_LINE_INDICES_PRESENCE_FIELDS`) are set to `:all` or `:none`, whereas the
others are set to `show`. The keywords in `kwargs` are appended unchanged, allowing a back
end to add fields with other semantics.

This function builds the body of the helper macros, such as [`@all_horizontal_lines`](@ref),
so that the shared fields are listed only once (see `_HORIZONTAL_LINE_PRESENCE_FIELDS` and
`_VERTICAL_LINE_PRESENCE_FIELDS`).

# Examples

```julia
macro text__no_vertical_lines()
    return _line_presence_keywords(
        false,
        _VERTICAL_LINE_PRESENCE_FIELDS...;
        suppress_vertical_lines_at_column_labels = true,
    )
end
```
"""
function _line_presence_keywords(show::Bool, fields::Symbol...; kwargs...)
    values = map(fields) do f
        (f ∈ _LINE_INDICES_PRESENCE_FIELDS) && return show ? :all : :none
        return show
    end

    return Expr(:..., (; NamedTuple{fields}(values)..., kwargs...))
end

############################################################################################
#                                          Macros                                          #
############################################################################################

"""
    @all_horizontal_lines() -> Keywords for `TableFormat`

Return the keyword arguments to be passed to [`TableFormat`](@ref) to show all horizontal
lines in any back end.

We can use the output of this function when creating the backend-agnostic table format
object. For example, the following code creates a table format with all horizontal lines:

```julia
tf = TableFormat(; @all_horizontal_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the horizontal lines but the first one:

```julia
tf = TableFormat(; @all_horizontal_lines, horizontal_line_at_beginning = false)
```
"""
macro all_horizontal_lines()
    return _line_presence_keywords(true, _TABLE_FORMAT_HORIZONTAL_LINE_PRESENCE_FIELDS...)
end

"""
    @all_vertical_lines() -> Keywords for `TableFormat`

Return the keyword arguments to be passed to [`TableFormat`](@ref) to show all vertical
lines in any back end.

We can use the output of this function when creating the backend-agnostic table format
object. For example, the following code creates a table format with all vertical lines:

```julia
tf = TableFormat(; @all_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code shows all the vertical lines but the first one:

```julia
tf = TableFormat(; @all_vertical_lines, vertical_line_at_beginning = false)
```
"""
macro all_vertical_lines()
    return _line_presence_keywords(true, _VERTICAL_LINE_PRESENCE_FIELDS...)
end

"""
    @no_horizontal_lines() -> Keywords for `TableFormat`

Return the keyword arguments to be passed to [`TableFormat`](@ref) to suppress all
horizontal lines in any back end.

We can use the output of this function when creating the backend-agnostic table format
object. For example, the following code creates a table format without horizontal lines:

```julia
tf = TableFormat(; @no_horizontal_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the horizontal line at the beginning of the table:

```julia
tf = TableFormat(; @no_horizontal_lines, horizontal_line_at_beginning = true)
```
"""
macro no_horizontal_lines()
    return _line_presence_keywords(false, _TABLE_FORMAT_HORIZONTAL_LINE_PRESENCE_FIELDS...)
end

"""
    @no_vertical_lines() -> Keywords for `TableFormat`

Return the keyword arguments to be passed to [`TableFormat`](@ref) to suppress all vertical
lines in any back end.

We can use the output of this function when creating the backend-agnostic table format
object. For example, the following code creates a table format without vertical lines:

```julia
tf = TableFormat(; @no_vertical_lines)
```

Any option can be overridden by merging the keyword arguments. For example, the following
code draws only the vertical line at the beginning of the table:

```julia
tf = TableFormat(; @no_vertical_lines, vertical_line_at_beginning = true)
```
"""
macro no_vertical_lines()
    return _line_presence_keywords(false, _VERTICAL_LINE_PRESENCE_FIELDS...)
end
