## Description #############################################################################
#
# Functions to render the table cells in the LaTeX back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `IOContext` because we
# need to check for circular dependency. We store the information about the objects being
# printed inside the key `__PRETTY_TABLES__DATA__` in the IO context. Hence, we must pass it
# forward when rendering the cells.

"""
    _latex__cell_to_str(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _latex__cell_to_str(cell::Any, context::IOContext, ::Val{:print})
    return sprint(print, cell; context)
end

function _latex__cell_to_str(cell::Any, context::IOContext, ::Val{:show})
    if showable(MIME("text/latex"), cell)
        cell_str = sprint(show, MIME("text/latex"), cell; context)
    else
        cell_str = sprint(show, cell; context)
    end

    return cell_str
end

function _latex__cell_to_str(cell::AbstractString, context::IOContext, ::Val{:show})
    return string(cell)
end

_latex__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:print}) = "#undef"
_latex__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:show}) = "#undef"

"""
    _latex__render_cell(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}; kwargs...) -> String

Render the `cell` in latex back end using a specific `context` and `renderer`.
"""
function _latex__render_cell(
    cell::Any,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    cell_str = _latex__cell_to_str(cell, context, renderer)

    # If the user wants latex code inside cell, we must not escape the latex characters.
    return _latex__escape_str(cell_str)
end
