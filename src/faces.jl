## Description #############################################################################
#
# Functions to handle the faces of StyledStrings.jl and to convert crayons into faces.
#
############################################################################################

############################################################################################
#                                        Constants                                         #
############################################################################################

# Weights of a face that are rendered as bold, and the ones rendered as light (faint).
const _FACE_BOLD_WEIGHTS  = (:medium, :semibold, :bold, :extrabold, :black)
const _FACE_LIGHT_WEIGHTS = (:semilight, :light, :extralight, :thin)

# Slants of a face that are rendered in italics.
const _FACE_ITALIC_SLANTS = (:italic, :oblique)

# Names of the 16 terminal colors in StyledStrings.jl, indexed by the color number.
const _FACE_16_COLOR_NAMES = (
    :black,
    :red,
    :green,
    :yellow,
    :blue,
    :magenta,
    :cyan,
    :white,
    :bright_black,
    :bright_red,
    :bright_green,
    :bright_yellow,
    :bright_blue,
    :bright_magenta,
    :bright_cyan,
    :bright_white,
)

# Face names of the color names in Crayons.jl.
const _CRAYON_COLOR_NAME_TO_FACE = Dict{Symbol, Symbol}(
    :black         => :black,
    :red           => :red,
    :green         => :green,
    :yellow        => :yellow,
    :blue          => :blue,
    :magenta       => :magenta,
    :cyan          => :cyan,
    :light_gray    => :white,
    :default       => :default,
    :dark_gray     => :bright_black,
    :light_red     => :bright_red,
    :light_green   => :bright_green,
    :light_yellow  => :bright_yellow,
    :light_blue    => :bright_blue,
    :light_magenta => :bright_magenta,
    :light_cyan    => :bright_cyan,
    :white         => :bright_white,
)

# Levels of the color cube of the xterm 256-color palette.
const _XTERM_CUBE_LEVELS = (0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff)

############################################################################################
#                                     Face Attributes                                      #
############################################################################################

"""
    _face_is_bold(face::Face) -> Bool

Return `true` if the weight of `face` is rendered as bold, or `false` otherwise.
"""
_face_is_bold(face::Face) = face.weight ∈ _FACE_BOLD_WEIGHTS

"""
    _face_is_light(face::Face) -> Bool

Return `true` if the weight of `face` is rendered as light (faint), or `false` otherwise.
"""
_face_is_light(face::Face) = face.weight ∈ _FACE_LIGHT_WEIGHTS

"""
    _face_is_italic(face::Face) -> Bool

Return `true` if the slant of `face` is rendered in italics, or `false` otherwise.
"""
_face_is_italic(face::Face) = face.slant ∈ _FACE_ITALIC_SLANTS

"""
    _face_is_underlined(face::Face) -> Bool

Return `true` if `face` turns the underline on, or `false` otherwise. Notice that the
underline can also be a color or a tuple with a color and a style, both of which turn it on.
"""
_face_is_underlined(face::Face) = !isnothing(face.underline) && (face.underline !== false)

"""
    _face_is_struck(face::Face) -> Bool

Return `true` if `face` turns the strikethrough on, or `false` otherwise.
"""
_face_is_struck(face::Face) = face.strikethrough === true

"""
    _face_color_hex(color::Union{Nothing, SimpleColor}; uppercase::Bool = false) -> Union{Nothing, String}

Return `color` as the hexadecimal string `"rrggbb"` (without `#`), or `nothing` if `color`
is `nothing`, the default color of the terminal, or an unknown name. If `uppercase` is
`true`, the string is written with uppercase digits.
"""
function _face_color_hex(color::Union{Nothing, SimpleColor}; uppercase::Bool = false)
    rgb = face_color_rgb(color)
    isnothing(rgb) && return nothing

    str =
        string(rgb.r; base = 16, pad = 2) *
        string(rgb.g; base = 16, pad = 2) *
        string(rgb.b; base = 16, pad = 2)

    return uppercase ? Base.uppercase(str) : str
end

"""
    _face_height_string(height::Union{Int, Float64}, absolute_unit::String, relative_unit::String) -> String

Format the `height` of a face: an `Int` is in deci-points and it is written with the
`absolute_unit` (`120` → `"12pt"` and `125` → `"12.5pt"`), whereas a `Float64` is a factor of
the parent size and it is written with the `relative_unit` (`1.5` → `"1.5em"`).
"""
function _face_height_string(height::Int, absolute_unit::String, ::String)
    q, r = divrem(height, 10)
    return r == 0 ? "$(q)$(absolute_unit)" : "$(q).$(r)$(absolute_unit)"
end

function _face_height_string(height::Float64, ::String, relative_unit::String)
    return "$(height)$(relative_unit)"
end

############################################################################################
#                                  Conversion of Crayons                                   #
############################################################################################

"""
    _face_from_crayon(crayon::Crayon) -> Face

Convert `crayon` into the face with the same attributes.

The conversion is lossy: the blink, conceal, and reset attributes of the crayon have no
counterpart in a face and they are dropped. A color of the 256-color palette is converted to
its 24-bit value, except for the 16 system colors, which are converted to their names.
"""
function _face_from_crayon(crayon::Crayon)
    bold  = _face_state_from_crayon(crayon.bold)
    faint = _face_state_from_crayon(crayon.faint)

    weight = if bold === true
        :bold
    elseif faint === true
        :light
    elseif (bold === false) || (faint === false)
        :normal
    else
        nothing
    end

    italics = _face_state_from_crayon(crayon.italics)
    slant   = isnothing(italics) ? nothing : (italics ? :italic : :normal)

    # We call the positional constructor of `Face` (see `_face_from_pairs`).
    return Face(
        nothing,
        nothing,
        weight,
        slant,
        _face_simple_color(_face_color_from_crayon(crayon.fg)),
        _face_simple_color(_face_color_from_crayon(crayon.bg)),
        _face_state_from_crayon(crayon.underline),
        _face_state_from_crayon(crayon.strikethrough),
        _face_state_from_crayon(crayon.negative),
        Symbol[],
    )
end

"""
    _face_from_kwargs(; kwargs...) -> Face

Create a face from the keywords `kwargs`, which can be the keywords of `Face` or the ones of
`Crayon`. The latter are translated: `bold` and `faint` select the `weight`, `italics`
selects the `slant`, `negative` selects the `inverse`, and `foreground` and `background`
also accept the color names of Crayons.jl, the indices of the 256-color palette, tuples
`(r, g, b)`, and `UInt32` values. The keywords `blink`, `conceal`, and `reset` have no
counterpart in a face: they are ignored with a warning, shown once per session. The other
keywords are forwarded to `Face`.

The keywords are passed to `_face_from_pairs` without specialization, which is compiled
once. Otherwise, each distinct set of keywords would compile the conversion again.
"""
_face_from_kwargs(; kwargs...) = _face_from_pairs(kwargs)

"""
    _face_from_pairs(kwargs::Any) -> Face

Create a face from the keyword `kwargs`, which can be any iterable of pairs (see
`_face_from_kwargs`). This function only gathers the pairs and forwards them to
`_face_from_pairs_core`, keeping the method called by `_face_from_kwargs` tiny (see
`_text__build_table_style` for the rationale).
"""
Base.@nospecializeinfer @noinline function _face_from_pairs(@nospecialize(kwargs))
    pairs = Pair{Symbol, Any}[]

    for (k, v) in kwargs
        push!(pairs, k => v)
    end

    return _face_from_pairs_core(pairs)
end

"""
    _face_from_pairs_core(pairs::Vector{Pair{Symbol, Any}}) -> Face

Create a face from the keyword `pairs` (see `_face_from_kwargs`).
"""
@noinline function _face_from_pairs_core(pairs::Vector{Pair{Symbol, Any}})
    font          = nothing
    height        = nothing
    weight        = nothing
    slant         = nothing
    foreground    = nothing
    background    = nothing
    underline     = nothing
    strikethrough = nothing
    inverse       = nothing
    inherit       = Symbol[]

    for (k, v) in pairs
        isnothing(v) && continue

        if k === :bold
            weight = v ? :bold : :normal

        elseif k === :faint
            # The bold has priority over the faint if both are set.
            (weight === :bold) && continue
            weight = v ? :light : :normal

        elseif k === :italics
            slant = v ? :italic : :normal

        elseif k === :negative
            inverse = v

        elseif k === :foreground
            foreground = _face_simple_color(_face_color_from_value(v))

        elseif k === :background
            background = _face_simple_color(_face_color_from_value(v))

        elseif (k === :blink) || (k === :conceal) || (k === :reset)
            @warn(
                "The keyword `$k` of `Crayon` has no counterpart in `Face` and it is ignored.",
                maxlog = 1
            )

        elseif k === :font
            font = v

        elseif k === :height
            height = v

        elseif k === :weight
            weight = v

        elseif k === :slant
            slant = v

        elseif k === :underline
            underline = _face_underline(v)

        elseif k === :strikethrough
            strikethrough = v

        elseif k === :inverse
            inverse = v

        elseif k === :inherit
            inherit = v isa Symbol ? [v] : v

        # The keyword constructor of `Face` ignores the unknown keywords. We do the same.
        end
    end

    # We call the positional constructor of `Face` so that the conversion does not depend on
    # the keyword constructor of StyledStrings.jl, which is compiled for each set of
    # keywords.
    return Face(
        font,
        height,
        weight,
        slant,
        foreground,
        background,
        underline,
        strikethrough,
        inverse,
        inherit,
    )
end

"""
    _face_simple_color(color::Any) -> Union{Nothing, SimpleColor}

Convert `color` to the object stored in the color fields of `Face`, mirroring the conversion
performed by the keyword constructor of `Face`.
"""
_face_simple_color(::Nothing)                = nothing
_face_simple_color(color::SimpleColor)       = color
_face_simple_color(color::AbstractString)    = parse(SimpleColor, color)
_face_simple_color(color::Any)               = convert(SimpleColor, color)

"""
    _face_underline(underline::Any) -> Any

Convert `underline` to the object stored in the field `underline` of `Face`, mirroring the
conversion performed by the keyword constructor of `Face`: a `Bool`, a color, a style name
(`:straight`, `:double`, `:curly`, `:dotted`, or `:dashed`), or a tuple with a color and a
style name.
"""
_face_underline(underline::Union{Nothing, Bool}) = underline
_face_underline(underline::Tuple{Any, Symbol}) =
    (_face_simple_color(underline[1]), underline[2])

function _face_underline(underline::Any)
    (underline in (:straight, :double, :curly, :dotted, :dashed)) &&
        return (nothing, underline)
    return _face_simple_color(underline)
end

# == Private Functions =====================================================================

"""
    _face_state_from_crayon(style::Crayons.ANSIStyle) -> Union{Nothing, Bool}

Return the state of a face attribute given the Crayons.jl `style`: `nothing` if the style is
not set, or `true` / `false` if it is turned on / off.
"""
_face_state_from_crayon(style::Crayons.ANSIStyle) = style.active ? style.on : nothing

"""
    _face_color_from_crayon(color::Crayons.ANSIColor) -> Union{Nothing, Symbol, NamedTuple}

Return the face color of the Crayons.jl `color`, which is the name of a terminal color, the
named tuple `(; r, g, b)` of a 24-bit color, or `nothing` if the color is not set.
"""
function _face_color_from_crayon(color::Crayons.ANSIColor)
    color.active || return nothing

    if color.style == Crayons.COLORS_16
        v = Int(color.r)
        (v == 9) && return :default
        (v < 8) && return _FACE_16_COLOR_NAMES[v + 1]
        (60 <= v <= 67) && return _FACE_16_COLOR_NAMES[v - 60 + 9]
        return nothing

    elseif color.style == Crayons.COLORS_256
        return _face_color_from_xterm_256(color.r)

    elseif color.style == Crayons.COLORS_24BIT
        return (r = color.r, g = color.g, b = color.b)
    end

    return nothing
end

"""
    _face_color_from_xterm_256(index::Integer) -> Union{Symbol, NamedTuple}

Return the face color of the `index` of the xterm 256-color palette. The 16 system colors are
returned by name so that they follow the terminal theme, whereas the other colors are
returned as the named tuple `(; r, g, b)` of their fixed 24-bit value. It throws an
`ArgumentError` if `index` is not between 0 and 255.
"""
function _face_color_from_xterm_256(index::Integer)
    (0 <= index <= 255) || throw(
        ArgumentError("The index of the 256-color palette must be between 0 and 255.")
    )

    (index < 16) && return _FACE_16_COLOR_NAMES[index + 1]

    if index < 232
        i = index - 16
        r = _XTERM_CUBE_LEVELS[div(i, 36) + 1]
        g = _XTERM_CUBE_LEVELS[div(i % 36, 6) + 1]
        b = _XTERM_CUBE_LEVELS[(i % 6) + 1]
        return (r = r, g = g, b = b)
    end

    v = UInt8(8 + 10 * (index - 232))
    return (r = v, g = v, b = v)
end

"""
    _face_color_from_value(v::Any) -> Any

Return the face color of the value `v` passed to the keywords `foreground` and `background`,
translating the forms accepted by `Crayon`: the color names of Crayons.jl, the indices of
the 256-color palette, tuples `(r, g, b)`, and `UInt32` values. The other values are
forwarded to `Face` unchanged.
"""
_face_color_from_value(v::Symbol) = get(_CRAYON_COLOR_NAME_TO_FACE, v, v)
_face_color_from_value(v::UInt32) = SimpleColor(v)
_face_color_from_value(v::Integer) = _face_color_from_xterm_256(v)
_face_color_from_value(v::NTuple{3, Integer}) =
    (r = UInt8(v[1]), g = UInt8(v[2]), b = UInt8(v[3]))
_face_color_from_value(v) = v

############################################################################################
#                                     Styled Strings                                      #
############################################################################################

@static if VERSION >= v"1.11"
    """
        _face_regions(str::Base.AnnotatedString) -> Vector{Tuple{String, Union{Nothing, Face}}}

    Split the styled string `str` into regions with the same annotations, returning the text
    of each region and its face, or `nothing` if the region has no face. The face only
    contains the attributes set by the annotations; the default face is not merged.
    """
    function _face_regions(str::Base.AnnotatedString)
        regions = Tuple{String, Union{Nothing, Face}}[]

        for (text, annotations) in StyledStrings.eachregion(str)
            face = nothing

            for annotation in annotations
                (annotation.label === :face) || continue
                region_face = _annotation_face(annotation.value)
                isnothing(region_face) && continue
                face = isnothing(face) ? region_face : merge(face, region_face)
            end

            push!(regions, (String(text), face))
        end

        return regions
    end

    """
        _annotation_face(value::Any) -> Union{Nothing, Face}

    Return the face of the `value` of a `:face` annotation, which can be a face or the name
    of a face, or `nothing` if the name is unknown or the value is not a face.
    """
    _annotation_face(face::Face)   = face
    _annotation_face(name::Symbol) = get(StyledStrings.FACES.current[], name, nothing)
    _annotation_face(::Any)        = nothing
end
