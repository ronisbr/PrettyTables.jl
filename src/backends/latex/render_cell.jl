## Description #############################################################################
#
# Functions to render the table cells in the LaTeX back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `RenderContext` because
# its `IOContext` carries the information required to check for circular dependency. We
# store the objects being printed inside the key `__PRETTY_TABLES__DATA__` in the IO
# context. Hence, we must pass it forward when rendering the cells.

"""
    _latex__cell_to_str(cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _latex__cell_to_str(cell::Any, context::RenderContext, ::Val{:print})
    return _sprint_with_context(print, context, cell)
end

function _latex__cell_to_str(cell::Any, context::RenderContext, ::Val{:show})
    if showable(MIME("text/latex"), cell)
        cell_str = _sprint_with_context(show, context, MIME("text/latex"), cell)
    else
        cell_str = _sprint_with_context(show, context, cell)
    end

    return cell_str
end

function _latex__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:print})
    # Notice that we must not use `string` here because it is the identity for any
    # `AbstractString`, whereas the callers require a `String`.
    return String(cell)
end

function _latex__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:show})
    return string(cell)
end

_latex__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:print}) = "#undef"
_latex__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:show}) = "#undef"

"""
    _latex__render_cell(cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}; kwargs...) -> String

Render the `cell` in latex back end using a specific `context` and `renderer`.
"""
function _latex__render_cell(
    cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    cell_str = _latex__cell_to_str(cell, context, renderer)

    # If the user wants latex code inside cell, we must not escape the latex characters.
    return _latex__escape_str(cell_str)
end

function _latex__render_cell(
    cell::LatexCell, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    return _latex__cell_to_str(cell.data, context, renderer)
end

function _latex__render_cell(
    cell::LaTeXString, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    return _latex__cell_to_str(cell, context, renderer)
end

# For Markdown cells, we must render always using `show` to obtain the correct decoration.
function _latex__render_cell(
    cell::Markdown.MD, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    return replace(sprint(show, MIME("text/latex"), cell), "\n" => "")
end
