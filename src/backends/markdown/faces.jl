## Description #############################################################################
#
# Conversion of faces into Markdown decorations.
#
############################################################################################

export markdown_decoration

"""
    markdown_decoration(face::Face) -> MarkdownStyle

Convert the `face` of StyledStrings.jl into the [`MarkdownStyle`](@ref) used by the Markdown
back end, which can be passed to a [`MarkdownHighlighter`](@ref) or to a field of
[`MarkdownTableStyle`](@ref).

The bold weights set `bold`, the slants `:italic` and `:oblique` set `italic`, and
`strikethrough = true` sets `strikethrough`. Every other attribute is ignored because it
cannot be represented in Markdown.

# Examples

```julia
julia> markdown_decoration(Face(; weight = :bold, foreground = :red))
MarkdownStyle(true, false, false, false)
```
"""
function markdown_decoration(face::Face)
    return MarkdownStyle(;
        bold          = _face_is_bold(face),
        italic        = _face_is_italic(face),
        strikethrough = _face_is_struck(face),
    )
end

"""
    _markdown__decoration(decoration::Union{MarkdownStyle, Face}) -> MarkdownStyle

Convert the `decoration` passed to `MarkdownTableStyle`, a Markdown style or a face, into a Markdown style.
"""
_markdown__decoration(decoration::MarkdownStyle) = decoration
_markdown__decoration(face::Face)                = markdown_decoration(face)

"""
    _markdown__column_label_decoration(decorations::Any) -> Union{MarkdownStyle, Vector{MarkdownStyle}}

Convert the `decorations` passed to the column label fields of `MarkdownTableStyle`, which can
be a Markdown style, a face, or a vector with one of them per column, into a Markdown style or a vector of them.
"""
_markdown__column_label_decoration(decoration::MarkdownStyle)          = decoration
_markdown__column_label_decoration(decorations::Vector{MarkdownStyle}) = decorations
_markdown__column_label_decoration(face::Face)                         = markdown_decoration(face)

function _markdown__column_label_decoration(decorations::AbstractVector)
    return MarkdownStyle[_markdown__decoration(d) for d in decorations]
end

"""
    _markdown__highlighter_decoration(h::AbstractHighlighter, data, i::Int, j::Int) -> MarkdownStyle

Return the Markdown style of the highlighter `h` for the cell `(i, j)` of `data`.
"""
function _markdown__highlighter_decoration(h::MarkdownHighlighter, data, i::Int, j::Int)
    return h.fd(h, data, i, j)::MarkdownStyle
end

function _markdown__highlighter_decoration(h::AbstractHighlighter, ::Any, ::Int, ::Int)
    throw(
        ArgumentError(
            "The Markdown back end does not support highlighters of type `$(typeof(h))`."
        )
    )
end
