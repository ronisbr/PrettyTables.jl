## Description #############################################################################
#
# Functions to render the table cells in text back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `RenderContext` because
# its `IOContext` carries the information required to check for circular dependency. We
# store the objects being printed inside the key `__PRETTY_TABLES__DATA__` in the IO
# context. Hence, we must pass it forward when rendering the cells.

"""
    _text__cell_to_str(cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _text__cell_to_str(cell::Any, context::RenderContext, ::Val{:print})
    cell isa String && return cell
    return _sprint_with_context(print, context, cell)
end

function _text__cell_to_str(cell::Any, context::RenderContext, ::Val{:show})
    return _sprint_with_context(show, context, MIME("text/plain"), cell)
end

function _text__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:show})
    cell isa String && return cell
    return _sprint_with_context(print, context, cell)
end

_text__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:print}) = "#undef"
_text__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:show}) = "#undef"

function _text__cell_to_str(cell::MergeCells, context::RenderContext, renderer::Val{:print})
    return _text__cell_to_str(cell.data, context, renderer)
end

function _text__cell_to_str(cell::MergeCells, context::RenderContext, renderer::Val{:show})
    return _text__cell_to_str(cell.data, context, renderer)
end

"""
    _text__render_cell(cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}, line_breaks::Bool = false, column_width::Int = -1) -> String

Render the `cell` in text back end using a specific `context` and `renderer`.

If `line_breaks` is `true`, the user wants to see line breaks in the output. The parameter
`column_width` contains the maximum column width of the current cell. Currently, it is only
used when rendering `Markdown.MD` cells.
"""
function _text__render_cell(
    cell::Any,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}},
    line_breaks::Bool = false,
    column_width::Int = -1,
)::String
    cell_str = _text__cell_to_str(cell, context, renderer)

    # `escape_string` always goes through `sprint`, allocating a fresh `IOBuffer`, its backing
    # array, and a `String` even when the input needs no escaping at all. Since that is by far
    # the most common case (numbers, plain identifiers, ordinary words), we scan the string
    # first and return it untouched when there is nothing to do.
    _text__needs_escaping(cell_str, line_breaks) || return cell_str

    # If the user wants line breaks, we should not escape the character `\n`.
    keep = line_breaks ? '\n' : ()

    return escape_string(cell_str, (); keep)
end

"""
    _text__needs_escaping(str::AbstractString, line_breaks::Bool) -> Bool

Return whether `escape_string` would change `str`. If `line_breaks` is `true`, the character
`\\n` is not considered, since it is kept verbatim.

Notice that this function is allowed to be conservative, that is, to return `true` for a
string that would in fact be left unchanged. It must never return `false` for a string that
would be modified.
"""
function _text__needs_escaping(str::AbstractString, line_breaks::Bool)
    for c in str
        (c == '\\') && return true

        isprint(c) && continue

        # A kept newline is emitted verbatim.
        (line_breaks && (c == '\n')) && continue

        return true
    end

    return false
end

function _text__render_cell(
    cell::AbstractCustomTextCell,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}},
    line_breaks::Bool = false,
    column_width::Int = -1,
)::String
    # Here, we are rendering the cell for the first time. Hence, we need to initialize it.
    CustomTextCell.init!(cell, _iocontext(context), renderer; line_breaks)

    return CustomTextCell.printable_cell_text(cell)
end

function _text__render_cell(
    cell::Markdown.MD,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}},
    line_breaks::Bool = false,
    column_width::Int = -1,
)::String
    # If the user does not want to break lines, we will set the column with equal to
    # `typemax(Int)`, which means that the text will never be broken into multiple
    # lines.
    if !line_breaks
        column_width = typemax(Int)
    elseif column_width <= 0
        column_width = 80
    end

    cell_str = _sprint_with_context(Markdown.term, context, cell, column_width)

    if !line_breaks
        cell_str = replace(cell_str, '\n' => "\\n")
    end

    return cell_str
end

@static if VERSION >= v"1.11"
    function _text__render_cell(
        cell::Base.AnnotatedString,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}},
        line_breaks::Bool = false,
        column_width::Int = -1,
    )::String
        cell_str = _text__cell_to_str(cell, context, renderer)

        if !line_breaks
            cell_str = replace(cell_str, '\n' => "\\n")
        end

        return cell_str
    end
end
