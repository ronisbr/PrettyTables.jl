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
    cell_str, _ = _cell_to_str(cell, context, renderer, MIME("text/typst"))

    # Notice that the cell content is always escaped, since it is emitted inside a Typst content block.
    return _typst__escape_str(cell_str)
end

function PrettyTables._typst__render_cell(
    cell::Markdown.MD, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    # We will always render Markdown cells using `#raw` until we can obtain a good way to
    # convert Markdown to Typst.
    str = "\"" * replace(chomp(string(cell)), "\n" => "\\n\" + \n  \"") * "\""

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
        cell::Base.AnnotatedString,
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
