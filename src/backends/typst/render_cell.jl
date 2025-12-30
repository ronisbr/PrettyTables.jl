

"""
    _typst__cell_to_str(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _typst__cell_to_str(cell::Any, context::IOContext, ::Val{:print})
    return sprint(print, cell; context)
end

function _typst__cell_to_str(cell::Any, context::IOContext, ::Val{:show})
    if showable(MIME("text/html"), cell)
        cell_str = sprint(show, MIME("text/html"), cell; context)
    else
        cell_str = sprint(show, cell; context)
    end

    return cell_str
end

function _typst__cell_to_str(cell::AbstractString, context::IOContext, ::Val{:show})
    if showable(MIME("text/html"), cell)
        # This code handles, for example, StyledStrings.jl objects.
        cell_str = sprint(show, MIME("text/html"), cell; context)
    else
        cell_str = string(cell)
    end

    return cell_str
end

_typst__cell_to_str(cell::HTML, context::IOContext, ::Val{:print}) = cell.content

_typst__cell_to_str(cell::HTML, context::IOContext, ::Val{:show}) = cell.content

_typst__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:print}) = "#undef"

_typst__cell_to_str(cell::UndefinedCell, context::IOContext, ::Val{:show}) = "#undef"


"""
    _typst__render_cell(cell::Any, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Render the `cell` in Typst back end using a specific `context` and `renderer`.
"""
function _typst__render_cell(
    cell::Any,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    cell_str = _typst__cell_to_str(cell, context, renderer)

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _typst__escape_str(cell_str)
end

function _typst__render_cell(
    cell::AbstractString,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    cell_str = _typst__cell_to_str(cell, context, renderer)

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _typst__escape_str(cell_str)
end

function _typst__render_cell(
    cell::HTML,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    return _typst__cell_to_str(cell, context, renderer)
end

# For Markdown cells, we must render always using `show` to obtain the correct decoration.
function _typst__render_cell(
    cell::Markdown.MD,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    line_breaks::Bool = false,
)
    return replace(sprint(show, MIME("text/html"), cell), "\n" => "")
end