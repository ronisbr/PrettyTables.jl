## Description #############################################################################
#
# Functions to render the table cells in the Typst back end.
#
############################################################################################

"""
    _typst__cell_to_str(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}}
    ) -> String

Convert the `cell` to a string using a specific `context` and `renderer`.
"""
function _typst__cell_to_str(cell::Any, context::RenderContext, ::Val{:print})
    return _sprint_with_context(print, context, cell)
end

function _typst__cell_to_str(cell::Any, context::RenderContext, ::Val{:show})
    if showable(MIME("text/typst"), cell)
        cell_str = _sprint_with_context(show, context, MIME("text/typst"), cell)
    else
        cell_str = _sprint_with_context(show, context, cell)
    end

    return cell_str
end

function _typst__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:print})
    # Notice that we must not use `string` here because it is the identity for any
    # `AbstractString`, whereas the callers require a `String`.
    return String(cell)
end

function _typst__cell_to_str(cell::AbstractString, context::RenderContext, ::Val{:show})
    if showable(MIME("text/typst"), cell)
        cell_str = _sprint_with_context(show, context, MIME("text/typst"), cell)
    else
        cell_str = string(cell)
    end

    return cell_str
end

_typst__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:print}) = "#undef"

_typst__cell_to_str(cell::UndefinedCell, context::RenderContext, ::Val{:show}) = "#undef"

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
    cell_str = _typst__cell_to_str(cell, context, renderer)

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
