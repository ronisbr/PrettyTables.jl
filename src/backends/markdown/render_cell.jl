## Description #############################################################################
#
# Functions to render the table cells in markdown back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `RenderContext` because
# its `IOContext` carries the information required to check for circular dependency. We
# store the objects being printed inside the key `__PRETTY_TABLES__DATA__` in the IO
# context. Hence, we must pass it forward when rendering the cells.

"""
    _markdown__cell_to_str(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}}
    ) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _markdown__cell_to_str(cell::Any, context::RenderContext, ::Val{:print})
    return _sprint_with_context(print, context, cell)
end

function _markdown__cell_to_str(cell::Any, context::RenderContext, ::Val{:show})
    return _sprint_with_context(show, context, cell)
end

function _markdown__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:print})
    # Notice that we must not use `string` here because it is the identity for any
    # `AbstractString`, whereas the callers require a `String`.
    return String(cell)
end

function _markdown__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:show})
    return string(cell)
end

_markdown__cell_to_str(::UndefinedCell, ::RenderContext, ::Val{:print}) = "#undef"
_markdown__cell_to_str(::UndefinedCell, ::RenderContext, ::Val{:show}) = "#undef"

function _markdown__cell_to_str(cell::MergeCells, context::RenderContext, ::Val{:print})
    return _markdown__cell_to_str(cell.data, context, Val(:print))
end

function _markdown__cell_to_str(cell::MergeCells, context::RenderContext, ::Val{:show})
    return _markdown__cell_to_str(cell.data, context, Val(:show))
end

"""
    _markdown__render_cell(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}};
        kwargs...
    ) -> String

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
    context::RenderContext,
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
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}};
    allow_markdown_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return replace(sprint(show, MIME("text/markdown"), cell), "\n" => "")
end

@static if VERSION >= v"1.11"
    # Styled strings are rendered region by region, wrapping the styled ones in the Markdown
    # markers of the face.
    function _markdown__render_cell(
        cell::Base.AnnotatedString,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}};
        allow_markdown_in_cells::Bool = false,
        line_breaks::Bool = false,
    )
        buf = IOBuffer()

        for (text, face) in _face_regions(cell)
            escaped = _markdown__escape_str(text, line_breaks, !allow_markdown_in_cells)
            style   = isnothing(face) ? _MARKDOWN__NO_DECORATION : markdown_decoration(face)
            print(buf, _markdown__apply_style(style, escaped))
        end

        return String(take!(buf))
    end
end
