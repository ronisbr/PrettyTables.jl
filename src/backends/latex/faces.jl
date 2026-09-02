## Description #############################################################################
#
# Conversion of faces into LaTeX decorations.
#
############################################################################################

export latex_decoration

"""
    latex_decoration(face::Face) -> Vector{String}

Convert the `face` of StyledStrings.jl into the LaTeX environments used by the LaTeX back
end, which can be passed to a [`LatexHighlighter`](@ref) or to a field of
[`LatexTableStyle`](@ref).

The environments are returned from the innermost to the outermost:

| Face Attribute  | LaTeX Environment                                          |
|:----------------|:-----------------------------------------------------------|
| `weight`        | `textbf` (bold weights)                                    |
| `slant`         | `textit` (`:italic` and `:oblique`)                        |
| `underline`     | `underline`                                                |
| `strikethrough` | `sout` (requires the package **ulem**)                     |
| `foreground`    | `textcolor[HTML]{RRGGBB}` (requires the package **xcolor**) |
| `background`    | `colorbox[HTML]{RRGGBB}` (requires the package **xcolor**)  |

The colors are resolved with `StringManipulation.face_color_rgb`, so that the default color
of the terminal and unknown names are ignored. The light weights, and the attributes `font`,
`height`, `inverse`, and `inherit`, are ignored, as well as the color and style of the
underline.

!!! note

    The LaTeX back end does not write any preamble. Hence, the packages **xcolor** and
    **ulem** must be loaded in the document if the face has colors or a strikethrough.

# Examples

```julia
julia> latex_decoration(Face(; weight = :bold, foreground = "#ff0000"))
2-element Vector{String}:
 "textbf"
 "textcolor[HTML]{FF0000}"
```
"""
function latex_decoration(face::Face)
    envs = String[]

    _face_is_bold(face) && push!(envs, "textbf")
    _face_is_italic(face) && push!(envs, "textit")
    _face_is_underlined(face) && push!(envs, "underline")
    _face_is_struck(face) && push!(envs, "sout")

    fg = _face_color_hex(face.foreground; uppercase = true)
    isnothing(fg) || push!(envs, "textcolor[HTML]{$fg}")

    bg = _face_color_hex(face.background; uppercase = true)
    isnothing(bg) || push!(envs, "colorbox[HTML]{$bg}")

    return envs
end

# Define `_latex__decoration`, `_latex__column_label_decoration`, and
# `_latex__highlighter_decoration`.
@_define_decoration_converters(
    latex, "LaTeX", latex_decoration, LatexEnvironments, AbstractString
)
