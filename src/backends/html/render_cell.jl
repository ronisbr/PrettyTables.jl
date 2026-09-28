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
    _html__render_cell(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}},
        allow_html_in_cells::Bool = false,
        line_breaks::Bool = false
    ) -> String

Render the `cell` in HTML back end using a specific `context` and `renderer`. If
`allow_html_in_cells` is `true`, the HTML sequences in the rendered string are not escaped.
If `line_breaks` is `true`, `\\n` is replaced with `<br>`.

Notice that the flags are positional arguments because this function is called for every
cell. A keyword call would require compiling a keyword sorter for each cell type.
"""
function _html__render_cell(
    cell::Any,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}},
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    cell_str, is_html = _cell_to_str(cell, context, renderer, MIME("text/html"))

    # If the cell was rendered using its HTML representation, we must emit it unchanged.
    is_html && return cell_str

    # Check if we need to replace `\n` with `<br>`.
    replace_newline = line_breaks

    # If the user wants HTML code inside cell, we must not escape the HTML characters.
    return _html__escape_str(cell_str, replace_newline, !allow_html_in_cells)
end

function _html__render_cell(
    cell::HTML,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}},
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return cell.content
end

# For Markdown cells, we must render always using `show` to obtain the correct decoration.
# Notice that only the line breaks between two tags can be removed because the others are
# part of the content of, e.g., code blocks, in which `<` and `>` are always escaped.
function _html__render_cell(
    cell::Markdown.MD,
    context::RenderContext,
    renderer::Union{Val{:print}, Val{:show}},
    allow_html_in_cells::Bool = false,
    line_breaks::Bool = false,
)
    return replace(sprint(show, MIME("text/html"), cell), ">\n<" => "><")
end

@static if VERSION >= v"1.11"
    # Styled strings are rendered region by region, wrapping the styled ones in a `span` with
    # the CSS properties of the face.
    function _html__render_cell(
        cell::_StyledString,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}},
        allow_html_in_cells::Bool = false,
        line_breaks::Bool = false,
    )
        return _render_face_regions(cell) do text, face
            escaped = _html__escape_str(text, line_breaks, !allow_html_in_cells)
            style   = isnothing(face) ? _HTML__NO_DECORATION : html_decoration(face)

            (isempty(style) || isempty(escaped)) && return escaped
            return _html__create_tag("span", escaped; style = style)
        end
    end
end
