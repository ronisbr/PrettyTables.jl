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
function _text__cell_to_str(cell::Any, @nospecialize(context::IOContext), ::Val{:print})
    return sprint(print, cell; context)
end

function _text__cell_to_str(cell::Any, @nospecialize(context::IOContext), ::Val{:show})
    return sprint(show, MIME("text/plain"), cell; context)
end

function _text__cell_to_str(
    cell::AbstractString,
    @nospecialize(context::IOContext),
    ::Val{:show}
)
    return sprint(print, cell; context)
end

function _text__cell_to_str(
    ::UndefinedCell,
    @nospecialize(::IOContext),
    ::Val{:print}
)
    return "#undef"
end

function _text__cell_to_str(
    ::UndefinedCell,
    @nospecialize(::IOContext),
    ::Val{:show}
)
    return "#undef"
end

function _text__cell_to_str(
    cell::MergeCells,
    @nospecialize(context::IOContext),
    renderer::Val{:print}
)
    return _text__cell_to_str(cell.data, context, renderer)
end

function _text__cell_to_str(
    cell::MergeCells,
    @nospecialize(context::IOContext),
    renderer::Val{:show}
)
    return _text__cell_to_str(cell.data, context, renderer)
end

"""
    _text__render_cell(cell::Any, @nospecialize(context::IOContext), renderer::Union{Val{:print}, Val{:show}}, line_breaks::Bool = false, column_width::Int = -1) -> String

Render the `cell` in text back end using a specific `context` and `renderer`.

If `line_breaks` is `true`, the user wants to see line breaks in the output. The parameter
`column_width` contains the maximum column width of the current cell. Currently, it is only
used when rendering `Markdown.MD` cells.
"""
function _text__render_cell(
    cell::Any,
    @nospecialize(context::IOContext),
    renderer::Union{Val{:print}, Val{:show}},
    line_breaks::Bool = false,
    column_width::Int = -1
)
    cell_str = _text__cell_to_str(cell, context, renderer)

    # We the user wants line breaks, we should not escape the character `\n`.
    keep = line_breaks ? '\n' : ()

    return escape_string(cell_str, (); keep)
end

function _text__render_cell(
    cell::AbstractCustomTextCell,
    @nospecialize(context::IOContext),
    renderer::Union{Val{:print}, Val{:show}},
    line_breaks::Bool = false,
    column_width::Int = -1
)
    # Here, we are rendering the cell for the first time. Hence, we need to initialize it.
    CustomTextCell.init!(cell, context, renderer; line_breaks)

    return CustomTextCell.printable_cell_text(cell)
end

function _text__render_cell(
    cell::Markdown.MD,
    @nospecialize(context::IOContext),
    renderer::Union{Val{:print}, Val{:show}},
    line_breaks::Bool = false,
    column_width::Int = -1
)
    # If the user does not want to break lines, we will set the column with equal to
    # `typemax(Int)`, which means that the text will never be broken into multiple
    # lines.
    if !line_breaks
        column_width = typemax(Int)
    elseif column_width <= 0
        column_width = 80
    end

    cell_str = sprint(Markdown.term, cell, column_width; context)

    if !line_breaks
        cell_str = replace(cell_str, '\n' => "\\n")
    end

    return cell_str
end

@static if VERSION >= v"1.11"
    function _text__render_cell(
        cell::Base.AnnotatedString,
        @nospecialize(context::IOContext),
        renderer::Union{Val{:print}, Val{:show}},
        line_breaks::Bool = false,
        column_width::Int = -1
    )
        cell_str = _text__cell_to_str(cell, context, renderer)

        if !line_breaks
            cell_str = replace(cell_str, '\n' => "\\n")
        end

        return cell_str
    end
end
