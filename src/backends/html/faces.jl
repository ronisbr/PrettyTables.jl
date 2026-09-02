## Description #############################################################################
#
# Conversion of faces into HTML decorations.
#
############################################################################################

export html_decoration

"""
    html_decoration(face::Face) -> Vector{HtmlPair}

Convert the `face` of StyledStrings.jl into the CSS properties used by the HTML back end,
which can be passed to an [`HtmlHighlighter`](@ref) or to a field of
[`HtmlTableStyle`](@ref).

The conversion is:

| Face Attribute                | CSS Property                                   |
|:------------------------------|:-----------------------------------------------|
| `font`                        | `font-family`                                  |
| `height` (`Int`, deci-points) | `font-size: <pt>pt`                            |
| `height` (`Float64`, factor)  | `font-size: <factor>em`                        |
| `weight`                      | `font-weight: bold`, `lighter`, or `normal`    |
| `slant`                       | `font-style: italic`, `oblique`, or `normal`   |
| `foreground`                  | `color: #rrggbb`                               |
| `background`                  | `background-color: #rrggbb`                    |
| `underline`                   | `text-decoration: underline`                   |
| `strikethrough`               | `text-decoration: line-through`                |

`underline` and `strikethrough` are merged into a single `text-decoration` property. The
colors are resolved with `StringManipulation.face_color_rgb`, so that the default color of
the terminal and unknown names are ignored. The attributes `inverse` and `inherit`, and the
color and style of the underline, are ignored.

# Examples

```julia
julia> html_decoration(Face(; weight = :bold, foreground = "#ff0000"))
2-element Vector{Pair{String, String}}:
       "color" => "#ff0000"
 "font-weight" => "bold"
```
"""
function html_decoration(face::Face)
    d = HtmlPair[]

    fg = _face_color_hex(face.foreground)
    isnothing(fg) || push!(d, "color" => "#" * fg)

    bg = _face_color_hex(face.background)
    isnothing(bg) || push!(d, "background-color" => "#" * bg)

    if _face_is_bold(face)
        push!(d, "font-weight" => "bold")
    elseif _face_is_light(face)
        push!(d, "font-weight" => "lighter")
    elseif face.weight === :normal
        push!(d, "font-weight" => "normal")
    end

    if _face_is_italic(face)
        push!(d, "font-style" => String(face.slant))
    elseif face.slant === :normal
        push!(d, "font-style" => "normal")
    end

    isnothing(face.font) || push!(d, "font-family" => face.font)

    isnothing(face.height) ||
        push!(d, "font-size" => _face_height_string(face.height, "pt", "em"))

    underlined = _face_is_underlined(face)
    struck     = _face_is_struck(face)

    if underlined && struck
        push!(d, "text-decoration" => "underline line-through")
    elseif underlined
        push!(d, "text-decoration" => "underline")
    elseif struck
        push!(d, "text-decoration" => "line-through")
    end

    return d
end

# Define `_html__decoration`, `_html__column_label_decoration`, and
# `_html__highlighter_decoration`.
@_define_decoration_converters(html, "HTML", html_decoration, Vector{HtmlPair}, Pair)
