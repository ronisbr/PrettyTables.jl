## Description #############################################################################
#
# Functions to render the table cells in text back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `IOContext` because we
# need to check for circular dependency. We store the information about the objects being
# printed inside the key `__PRETTY_TABLES__DATA__` in the IO context. Hence, we must pass it
# forward when rendering the cells.

"""
    _text__cell_to_str(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _text__cell_to_str(cell::Any, context::IOContext, ::Val{:print})
    return sprint(print, cell; context)
end

function _text__cell_to_str(cell::Any, context::IOContext, ::Val{:show})
    return sprint(show, cell; context)
end

function _text__cell_to_str(cell::AbstractString, context::IOContext, ::Val{:show})
    return string(cell)
end

_text__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:print}) = "#undef"
_text__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:show}) = "#undef"

"""
    _text__render_cell(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}; kwargs...) -> String

Render the `cell` in markdown back end using a specific `context` and `renderer`.

"""
function _text__render_cell(
    cell::Any,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    cell_str = _text__cell_to_str(cell, context, renderer)

    # If the user wants markdown code inside cell, we must not escape the markdown characters.
    return escape_string(cell_str)
end

