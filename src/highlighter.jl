## Description #############################################################################
#
# Definition of the general highlighter, which works with every back end.
#
############################################################################################

export Highlighter

"""
    mutable struct Highlighter <: AbstractHighlighter

Highlighter defined by a `Face` of StyledStrings.jl, which can be used with every back end.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true` if
    the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `fd(h, data, i, j)` in which `h` is the
    highlighter. This function must return the `Face` to be applied to the cell that must be
    highlighted. It can also return the native decoration of the back end that is printing
    the table (a `Crayon` for the text back end, CSS properties for the HTML back end, and
    so on).
- `_decoration::Face`: The `Face` to be applied to the highlighted cell if the default `fd`
    is used.

The other fields are private caches with the decoration of each back end, converted from
`_decoration` the first time the highlighter is used with that back end. The conversion is
pure, so that a concurrent use of the same highlighter can only convert it twice.

# Remarks

This structure can be constructed using the following helpers:

```julia
Highlighter(f::Function; kwargs...)
```

where it will construct a `Face` using the keywords in `kwargs` and apply it to the
highlighted cell. The keywords can be the ones of `Face` (`weight`, `slant`, `foreground`,
`background`, `underline`, `strikethrough`, `inverse`, ...) or the ones of `Crayon` (`bold`,
`faint`, `italics`, `negative`, `foreground`, `background`, `underline`, `strikethrough`),
which are translated to the equivalent face attributes,

```julia
Highlighter(f::Function, face::Face)
Highlighter(f::Function, crayon::Crayon)
```

where it will apply the `face` (or the `crayon`, converted to a face) to the highlighted
cell, and

```julia
Highlighter(f::Function, fd::Function)
```

where it will apply the decoration returned by the function `fd` to the highlighted cell.

The conversion of the face into the decoration of each back end is described in
[`html_decoration`](@ref), [`latex_decoration`](@ref), [`markdown_decoration`](@ref),
[`typst_decoration`](@ref), and [`excel_decoration`](@ref). The text back end renders the
face using its escape sequence.

# Examples

```julia
julia> hl = Highlighter((data, i, j) -> data[i, j] > 5, Face(; weight = :bold, foreground = :red));

julia> pretty_table([1 10; 3 7]; highlighters = [hl])

julia> pretty_table([1 10; 3 7]; backend = :html, highlighters = [hl])
```
"""
mutable struct Highlighter <: AbstractHighlighter
    const f::Function
    const fd::Function

    # == Private Fields ====================================================================

    const _decoration::Face

    # Decoration of each back end, converted from `_decoration` when first used.
    _text::Union{Nothing, String}
    _html::Union{Nothing, Vector{HtmlPair}}
    _latex::Union{Nothing, LatexEnvironments}
    _markdown::Union{Nothing, MarkdownStyle}
    _typst::Union{Nothing, Vector{TypstPair}}
    _excel::Union{Nothing, Vector{ExcelPair}}

    # == Constructors ======================================================================

    function Highlighter(f::Function, fd::Function)
        return new(f, fd, Face(), nothing, nothing, nothing, nothing, nothing, nothing)
    end

    function Highlighter(f::Function, face::Face)
        return new(
            f,
            _default_highlighter_fd,
            face,
            nothing,
            nothing,
            nothing,
            nothing,
            nothing,
            nothing,
        )
    end

    function Highlighter(f::Function, crayon::Crayon)
        return Highlighter(f, _face_from_crayon(crayon))
    end

    function Highlighter(f::Function; kwargs...)
        return Highlighter(f, _face_from_kwargs(; kwargs...))
    end
end

_default_highlighter_fd(h::Highlighter, ::Any, ::Int, ::Int) = h._decoration

# Return `true` if the highlighter `h` uses the default decoration function, in which case
# the converted decoration can be cached.
_has_default_fd(h::Highlighter) = h.fd === _default_highlighter_fd
