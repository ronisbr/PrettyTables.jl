## Description #############################################################################
#
# Functions to render the table cells in markdown back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `IOContext` because we
# need to check for circular dependency. We store the information about the objects being
# printed inside the key `__PRETTY_TABLES__DATA__` in the IO context. Hence, we must pass it
# forward when rendering the cells.

"""
    _markdown__cell_to_str(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _markdown__cell_to_str(cell::Any, context::IOContext, ::Val{:print})
    return sprint(print, cell; context)
end

function _markdown__cell_to_str(cell::Any, context::IOContext, ::Val{:show})
    return sprint(show, cell; context)
end

function _markdown__cell_to_str(cell::AbstractString, context::IOContext, ::Val{:show})
    return string(cell)
end

_markdown__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:print}) = "#undef"
_markdown__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:show}) = "#undef"

"""
    _markdown__render_cell(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}; kwargs...) -> String

Render the `cell` in markdown back end using a specific `context` and `renderer`.

# Keywords

- `allow_markdown_in_cells::Bool`: If `true`, we will not escape markdown sequences in the rendered
    string.
    (**Default**: `false`)
- `line_breaks::Bool`: If `true`, we will replace `\\n` with `<br>`.
    (**Default**: `false`)
"""
function _markdown__render_cell(
    cell::Any,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_markdown_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    cell_str = _markdown__cell_to_str(cell, context, renderer)

    # Check if we need to replace `\n` with `<br>`.
    replace_newline = line_breaks

    # If the user wants markdown code inside cell, we must not escape the markdown characters.
    return _markdown__escape_str(cell_str, replace_newline, !allow_markdown_in_cells)
end

# For Markdown cells, we just output the string.
function _markdown__render_cell(
    cell::Markdown.MD,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_markdown_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return replace(sprint(show, MIME("text/plain"), cell), "\n" => "")
end
