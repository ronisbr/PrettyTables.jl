## Description #############################################################################
#
# Functions to render the table cells in the HTML back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `RenderContext` because
# its `IOContext` carries the information required to check for circular dependency. We
# store the objects being printed inside the key `__PRETTY_TABLES__DATA__` in the IO
# context. Hence, we must pass it forward when rendering the cells.

"""
    _html__cell_to_str(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}}
    ) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _html__cell_to_str(cell::Any, context::RenderContext, ::Val{:print})
    return _sprint_with_context(print, context, cell)
end

function _html__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:print})
    # Escaping is performed afterward in `_html__render_cell`. Hence, we can return the
    # string here without any allocation, avoiding the `sprint` overhead.
    cell isa String && return cell
    return String(cell)
end

function _html__cell_to_str(cell::Any, context::RenderContext, ::Val{:show})
    if showable(MIME("text/html"), cell)
        cell_str = _sprint_with_context(show, context, MIME("text/html"), cell)
    else
        cell_str = _sprint_with_context(show, context, cell)
    end

    return cell_str
end

function _html__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:show})
    if showable(MIME("text/html"), cell)
        # This code handles, for example, StyledStrings.jl objects.
        cell_str = _sprint_with_context(show, context, MIME("text/html"), cell)
    else
        cell_str = string(cell)
    end

    return cell_str
end

_html__cell_to_str(cell::HTML, context::RenderContext, ::Val{:print}) = cell.content
_html__cell_to_str(cell::HTML, context::RenderContext, ::Val{:show}) = cell.content

_html__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:print}) = "#undef"
_html__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:show}) = "#undef"

"""
    _html__render_cell(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}};
        kwargs...
    ) -> String

Render the `cell` in HTML back end using a specific `context` and `renderer`.

# Keywords

- `allow_html_in_cells::Bool`: If `true`, we will not escape HTML sequences in the rendered
    string.
    (**Default**: `false`)
- `line_breaks::Bool`: If `true`, we will replace `\\n` with `<br>`.
    (**Default**: `false`)
"""
function _html__render_cell(
    cell::Any,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    cell_str = _html__cell_to_str(cell, context, renderer)

    # Check if we need to replace `\n` with `<br>`.
    replace_newline = line_breaks

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _html__escape_str(cell_str, replace_newline, !allow_html_in_cells)
end

function _html__render_cell(
    cell::AbstractString,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    cell_str = _html__cell_to_str(cell, context, renderer)

    # Check if we need to replace `\n` with `<br>`.
    replace_newline = line_breaks

    # If the string is showable as HTML, we assume it contains HTML code and we do not
    # escape it.
    if showable(MIME("text/html"), cell)
        allow_html_in_cells = true
    end

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _html__escape_str(cell_str, replace_newline, !allow_html_in_cells)
end

function _html__render_cell(
    cell::HTML,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return _html__cell_to_str(cell, context, renderer)
end

# For Markdown cells, we must render always using `show` to obtain the correct decoration.
function _html__render_cell(
    cell::Markdown.MD,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return replace(sprint(show, MIME("text/html"), cell), "\n" => "")
end
