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
    cell_str, _ = _cell_to_str(cell, context, renderer, nothing)

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
        return _render_face_regions(cell) do text, face
            escaped = _markdown__escape_str(text, line_breaks, !allow_markdown_in_cells)
            style   = isnothing(face) ? _MARKDOWN__NO_DECORATION : markdown_decoration(face)
            return _markdown__apply_style(style, escaped)
        end
    end
end
