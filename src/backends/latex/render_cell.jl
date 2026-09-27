## Description #############################################################################
#
# Functions to render the table cells in the LaTeX back end.
#
############################################################################################

# NOTE: The functions to render the cell must receive the current `RenderContext` because
# its `IOContext` carries the information required to check for circular dependency. We
# store the objects being printed inside the key `__PRETTY_TABLES__DATA__` in the IO
# context. Hence, we must pass it forward when rendering the cells.

"""
    _latex__render_cell(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}};
        kwargs...
    ) -> String

Render the `cell` in latex back end using a specific `context` and `renderer`.
"""
function _latex__render_cell(
    cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    cell_str, is_latex = _cell_to_str(cell, context, renderer, MIME("text/latex"))

    # If the cell was rendered using its LaTeX representation, we must emit it unchanged.
    return is_latex ? cell_str : _latex__escape_str(cell_str)
end

function _latex__render_cell(
    cell::LatexCell, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    return first(_cell_to_str(cell.data, context, renderer, MIME("text/latex")))
end

function _latex__render_cell(
    cell::LaTeXString, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    return first(_cell_to_str(cell, context, renderer, nothing))
end

# For Markdown cells, we must render always using `show` to obtain the correct decoration.
function _latex__render_cell(
    cell::Markdown.MD, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    return replace(sprint(show, MIME("text/latex"), cell), "\n" => "")
end

@static if VERSION >= v"1.11"
    # Styled strings are rendered region by region, wrapping the styled ones in the LaTeX
    # environments of the face.
    function _latex__render_cell(
        cell::Base.AnnotatedString,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}},
    )
        return _render_face_regions(cell) do text, face
            escaped = _latex__escape_str(text)
            envs    = isnothing(face) ? _LATEX__DEFAULT : latex_decoration(face)
            return _latex__add_environments(escaped, envs)
        end
    end
end
