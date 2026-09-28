## Description #############################################################################
#
# Functions to render the table cells in the Word back end.
#
############################################################################################

# Renderers supported by the Word back end. Notice that every `_docx__render_cell` method
# must annotate its renderer argument with this exact type so that the dispatch is decided
# solely by the cell type. Otherwise, we would introduce method ambiguities.
const _DOCX__RENDERER = Union{Val{:print}, Val{:show}}

"""
    _docx__render_cell(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}}
    ) -> Vector{DocxRun}

Render the `cell` in the Word back end, returning the text runs that form the cell content.
The cell is converted to a `String` using the `renderer` and the IO `context`, whereas a
styled string is split into one run per face region so that the faces become the properties
of the runs.
"""
function _docx__render_cell(cell::Any, context::RenderContext, renderer::_DOCX__RENDERER)
    return [DocxRun(_docx__cell_to_str(cell, context, renderer))]
end

function _docx__render_cell(
    cell::MergeCells, context::RenderContext, renderer::_DOCX__RENDERER
)
    return _docx__render_cell(cell.data, context, renderer)
end

"""
    _docx__cell_to_str(
        cell::Any,
        context::RenderContext,
        renderer::Union{Val{:print}, Val{:show}}
    ) -> String

Convert `cell` to a `String` using `renderer` and the IO `context`. Notice that this function
must not be called directly; use [`_docx__render_cell`](@ref) instead.
"""
function _docx__cell_to_str(cell::Any, context::RenderContext, ::Val{:print})
    return _sprint_with_context(print, context, cell)
end

function _docx__cell_to_str(cell::Any, context::RenderContext, ::Val{:show})
    return _sprint_with_context(show, context, MIME("text/plain"), cell)
end

@static if VERSION >= v"1.11"
    # Each face region of a styled string becomes a run with its own properties.
    function _docx__render_cell(cell::_StyledString, ::RenderContext, ::_DOCX__RENDERER)
        runs = DocxRun[]

        for (text, face) in _face_regions(cell)
            isempty(text) && continue

            decoration = isnothing(face) ? _DOCX__NO_DECORATION : docx_decoration(face)

            push!(runs, DocxRun(String(text), decoration, false))
        end

        isempty(runs) && return [DocxRun("")]

        return runs
    end
end
