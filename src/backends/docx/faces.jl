## Description #############################################################################
#
# Conversion of faces into Word decorations.
#
############################################################################################

export docx_decoration

"""
    docx_decoration(face::Face) -> Vector{DocxPair}

Convert the `face` of StyledStrings.jl into the attributes used by the Word back end, which
can be passed to a [`DocxHighlighter`](@ref) or to a field of [`DocxTableStyle`](@ref).

The conversion is:

| Face Attribute                | Word Attribute                  |
|:------------------------------|:--------------------------------|
| `font`                        | `font`                          |
| `height` (`Int`, deci-points) | `size` (rounded to half points) |
| `weight`                      | `bold => "true"`                |
| `slant`                       | `italic => "true"`              |
| `foreground`                  | `color => "RRGGBB"`             |
| `background`                  | `background => "RRGGBB"`        |
| `underline`                   | `underline => "single"`         |
| `strikethrough`               | `strike => "true"`              |

The colors are resolved with `StringManipulation.face_color_rgb`, so that the default color
of the terminal and unknown names are ignored. The light weights, a `Float64` `height`, the
attributes `inverse` and `inherit`, and the color and style of the underline are ignored.

# Examples

```julia
julia> docx_decoration(Face(; weight = :bold, foreground = "#ff0000"))
2-element Vector{Pair{String, String}}:
  "bold" => "true"
 "color" => "FF0000"
```
"""
function docx_decoration(face::Face)
    d = DocxPair[]

    _face_is_bold(face) && push!(d, "bold" => "true")
    _face_is_italic(face) && push!(d, "italic" => "true")
    _face_is_underlined(face) && push!(d, "underline" => "single")
    _face_is_struck(face) && push!(d, "strike" => "true")

    isnothing(face.font) || push!(d, "font" => face.font)

    if face.height isa Int
        # Word supports font sizes in half points.
        size = max(1, round(Int, face.height / 5, RoundNearestTiesUp)) / 2
        push!(d, "size" => isinteger(size) ? string(Int(size)) : string(size))
    end

    fg = _face_color_hex(face.foreground; uppercase = true)
    isnothing(fg) || push!(d, "color" => fg)

    bg = _face_color_hex(face.background; uppercase = true)
    isnothing(bg) || push!(d, "background" => bg)

    return d
end

# Define `_docx__decoration`, `_docx__column_label_decoration`, and
# `_docx__highlighter_decoration`.
@_define_decoration_converters(docx, "Word", docx_decoration, Vector{DocxPair}, Pair)
