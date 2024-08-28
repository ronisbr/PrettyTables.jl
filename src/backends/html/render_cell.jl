## Description #############################################################################
#
# Functions to render the table cells in the HTML back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `IOContext` because we
# need to check for circular dependency. We store the information about the objects being
# printed inside the key `__PRETTY_TABLES__DATA__` in the IO context. Hence, we must pass it
# forward when rendering the cells.

"""
    _html__cell_to_str(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _html__cell_to_str(cell::Any, context::IOContext, ::Val{:print})
    return sprint(print, cell; context)
end

function _html__cell_to_str(cell::AbstractString, context::IOContext, ::Val{:show})
    return string(cell)
end

_html__cell_to_str(cell::HTML, context::IOContext, ::Val{:print}) = cell.content
_html__cell_to_str(cell::HTML, context::IOContext, ::Val{:show}) = cell.content

function _html__cell_to_str(cell::Any, context::IOContext, ::Val{:show})
    if showable(MIME("text/html"), cell)
        cell_str = sprint(show, MIME("text/html"), cell; context)
    else
        cell_str = sprint(show, cell; context)
    end

    return cell_str
end

"""
    _html__render_cell(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}; kwargs...) -> String

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
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    cell_str = _html__cell_to_str(cell, context, renderer)

    # Check if we need to replace `\n` with `<br>`.
    replace_newline = line_breaks

    # If the cell type is `HTML`, we should not escape the string.
    cell isa HTML && return cell_str

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _html__escape_str(cell_str, replace_newline, !allow_html_in_cells)
end

function _html__render_cell(
    cell::HTML,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return _html__cell_to_str(cell, context, renderer)
end

# For Markdown cells, we must render always using `show` to obtain the correct decoration.
function _html__render_cell(
    cell::Markdown.MD,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return replace(sprint(show, MIME("text/html"), cell), "\n" => "")
end
