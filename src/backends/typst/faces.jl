## Description #############################################################################
#
# Conversion of faces into Typst decorations.
#
############################################################################################

export typst_decoration

# Typst names of the weights of a face.
const _TYPST__FACE_WEIGHTS = Dict{Symbol, String}(
    :thin       => "thin",
    :extralight => "extralight",
    :light      => "light",
    :semilight  => "light",
    :normal     => "regular",
    :medium     => "medium",
    :semibold   => "semibold",
    :bold       => "bold",
    :extrabold  => "extrabold",
    :black      => "black",
)

"""
    typst_decoration(face::Face) -> Vector{TypstPair}

Convert the `face` of StyledStrings.jl into the Typst properties used by the Typst back end,
which can be passed to a [`TypstHighlighter`](@ref) or to a field of
[`TypstTableStyle`](@ref).

The conversion is:

| Face Attribute                | Typst Property                                       |
|:------------------------------|:-----------------------------------------------------|
| `font`                        | `text-font`                                          |
| `height` (`Int`, deci-points) | `text-size: <pt>pt`                                  |
| `height` (`Float64`, factor)  | `text-size: <factor>em`                              |
| `weight`                      | `text-weight` (`:normal` → `regular`, `:semilight` → `light`) |
| `slant`                       | `text-style: normal`, `italic`, or `oblique`         |
| `foreground`                  | `text-fill: rgb("#rrggbb")`                          |
| `background`                  | `fill: rgb("#rrggbb")` (cell property)               |

The colors are resolved with `StringManipulation.face_color_rgb`, so that the default color
of the terminal and unknown names are ignored. The attributes `underline` and
`strikethrough` are ignored because Typst renders them with the functions `underline` and
`strike` instead of text properties, as well as `inverse` and `inherit`.

# Examples

```julia
julia> typst_decoration(Face(; weight = :bold, foreground = "#ff0000"))
2-element Vector{Pair{String, String}}:
 "text-weight" => "bold"
   "text-fill" => "rgb(\\"#ff0000\\")"
```
"""
function typst_decoration(face::Face)
    d = TypstPair[]

    isnothing(face.font) || push!(d, "text-font" => face.font)

    isnothing(face.height) ||
        push!(d, "text-size" => _face_height_string(face.height, "pt", "em"))

    weight = get(_TYPST__FACE_WEIGHTS, face.weight, nothing)
    isnothing(weight) || push!(d, "text-weight" => weight)

    slant = face.slant
    (slant ∈ (:normal, :italic, :oblique)) && push!(d, "text-style" => String(slant))

    fg = _face_color_hex(face.foreground)
    isnothing(fg) || push!(d, "text-fill" => "rgb(\"#$fg\")")

    bg = _face_color_hex(face.background)
    isnothing(bg) || push!(d, "fill" => "rgb(\"#$bg\")")

    return d
end

# Convert a decoration passed to `TypstTableStyle` into Typst properties.
_typst__decoration(decoration::Vector{TypstPair}) = decoration
_typst__decoration(face::Face)                    = typst_decoration(face)

# Convert a decoration, or a vector with one decoration per column, passed to
# `TypstTableStyle` into Typst properties.
_typst__column_label_decoration(decoration::Vector{TypstPair})          = decoration
_typst__column_label_decoration(decorations::Vector{Vector{TypstPair}}) = decorations
_typst__column_label_decoration(face::Face)                             = typst_decoration(face)

function _typst__column_label_decoration(decorations::AbstractVector)
    return Vector{TypstPair}[_typst__decoration(d) for d in decorations]
end
