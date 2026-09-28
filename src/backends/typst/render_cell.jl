## Description #############################################################################
#
# Functions to render the table cells in the Typst back end.
#
############################################################################################

"""
    _typst__render_cell(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}}
    ) -> String

Render the `cell` in Typst back end using a specific `context` and `renderer`.
"""
function _typst__render_cell(
    cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    cell_str, is_typst = _cell_to_str(cell, context, renderer, MIME("text/typst"))

    # If the cell was rendered using its Typst representation, we must emit it unchanged.
    # Otherwise, the content must be escaped, since it is emitted inside a Typst content
    # block.
    return is_typst ? cell_str : _typst__escape_str(cell_str)
end

function PrettyTables._typst__render_cell(
    cell::Markdown.MD, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    # We will always render Markdown cells using `#raw` until we can obtain a good way to
    # convert Markdown to Typst. Notice that each line is emitted inside a Typst string
    # literal. Hence, the backslashes and the double quotes must be escaped.
    lines = split(chomp(string(cell)), '\n')
    str   = "\"" * join(map(_typst__escape_string_literal, lines), "\\n\" + \n  \"") * "\""

    return """
        #raw(
          $str,
          block: false,
          lang: "markdown",
        )"""
end

@static if VERSION >= v"1.11"
    # Styled strings are rendered region by region, wrapping the styled ones in a `#text`
    # component with the text properties of the face. The cell properties, like the
    # background, cannot be applied to a region and they are ignored.
    function _typst__render_cell(
        cell::_StyledString,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}},
    )
        return _render_face_regions(cell) do text, face
            escaped = _typst__escape_str(text)
            isnothing(face) && return escaped
            _, text_properties = _typst__cell_and_text_properties(typst_decoration(face))
            return _typst__text(escaped, text_properties)
        end
    end
end
