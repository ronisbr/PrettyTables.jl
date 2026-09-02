## Description #############################################################################
#
# Conversion of faces into Excel decorations.
#
############################################################################################

export excel_decoration

"""
    excel_decoration(face::Face) -> Vector{ExcelPair}

Convert the `face` of StyledStrings.jl into the attributes used by the Excel back end, which
can be passed to an [`ExcelHighlighter`](@ref) or to a field of [`ExcelTableStyle`](@ref).

The conversion is:

| Face Attribute                | Excel Attribute                                                 |
|:------------------------------|:----------------------------------------------------------------|
| `font`                        | `name`                                                          |
| `height` (`Int`, deci-points) | `size` (rounded to points)                                      |
| `weight`                      | `bold => "true"` (bold weights)                                 |
| `slant`                       | `italic => "true"` (`:italic` and `:oblique`)                   |
| `foreground`                  | `color => "FFRRGGBB"`                                           |
| `background`                  | `cell_fill_pattern => "solid"` and `cell_fill_fgColor => "FFRRGGBB"` |
| `underline`                   | `under => "single"`                                             |
| `strikethrough`               | `strike => "true"`                                              |

The colors are resolved with `StringManipulation.face_color_rgb`, so that the default color
of the terminal and unknown names are ignored. The light weights, a `Float64` `height`, and
the attributes `inverse` and `inherit` are ignored, as well as the color and style of the
underline.

# Examples

```julia
julia> excel_decoration(Face(; weight = :bold, foreground = "#ff0000"))
2-element Vector{Pair{String, String}}:
  "bold" => "true"
 "color" => "FFFF0000"
```
"""
function excel_decoration(face::Face)
    d = ExcelPair[]

    _face_is_bold(face) && push!(d, "bold" => "true")
    _face_is_italic(face) && push!(d, "italic" => "true")
    _face_is_underlined(face) && push!(d, "under" => "single")
    _face_is_struck(face) && push!(d, "strike" => "true")

    isnothing(face.font) || push!(d, "name" => face.font)

    if face.height isa Int
        size = max(1, round(Int, face.height / 10, RoundNearestTiesUp))
        push!(d, "size" => string(size))
    end

    fg = _face_color_hex(face.foreground; uppercase = true)
    isnothing(fg) || push!(d, "color" => "FF" * fg)

    bg = _face_color_hex(face.background; uppercase = true)
    isnothing(bg) ||
        push!(d, "cell_fill_pattern" => "solid", "cell_fill_fgColor" => "FF" * bg)

    return d
end

# Define `_excel__decoration`, `_excel__column_label_decoration`, and
# `_excel__highlighter_decoration`.
@_define_decoration_converters(excel, "Excel", excel_decoration, Vector{ExcelPair}, Pair)
