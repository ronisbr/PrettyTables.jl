## Description #############################################################################
#
# Definition of the general highlighter, which works with every back end.
#
############################################################################################

export Highlighter

"""
    struct Highlighter <: AbstractHighlighter

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

Each back end converts this highlighter to its native highlighter once per printed table,
converting the face with [`html_decoration`](@ref), [`latex_decoration`](@ref),
[`markdown_decoration`](@ref), [`typst_decoration`](@ref), or [`excel_decoration`](@ref).
The text back end renders the face using its escape sequence.

# Examples

```julia
julia> hl = Highlighter((data, i, j) -> data[i, j] > 5, Face(; weight = :bold, foreground = :red));

julia> pretty_table([1 10; 3 7]; highlighters = [hl])

julia> pretty_table([1 10; 3 7]; backend = :html, highlighters = [hl])
```
"""
struct Highlighter <: AbstractHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Face

    # == Constructors ======================================================================

    function Highlighter(f::Function, fd::Function)
        return new(f, fd, Face())
    end

    function Highlighter(f::Function, face::Face)
        return new(f, _default_highlighter_fd, face)
    end

    function Highlighter(f::Function, crayon::Crayon)
        return Highlighter(f, _face_from_crayon(crayon))
    end

    function Highlighter(f::Function; kwargs...)
        return Highlighter(f, _face_from_kwargs(; kwargs...))
    end
end

"""
    _default_highlighter_fd(h::Highlighter, data::Any, i::Int, j::Int) -> Face

Return the face stored in the highlighter `h`, which is the default decoration function.
"""
_default_highlighter_fd(h::Highlighter, ::Any, ::Int, ::Int) = h._decoration

"""
    _has_default_fd(h::Highlighter) -> Bool

Return `true` if the highlighter `h` uses the default decoration function, in which case the
face can be converted to the native decoration once, or `false` otherwise.
"""
_has_default_fd(h::Highlighter) = h.fd === _default_highlighter_fd

############################################################################################
#                            Conversion to the Native Highlighters                         #
############################################################################################

"""
    _native_highlighters(convert::Function, highlighters::Vector{AbstractHighlighter}) -> Vector{AbstractHighlighter}

Convert every general [`Highlighter`](@ref) in `highlighters` to the native highlighter of
a back end using `convert`, returning a new vector. If `highlighters` has no general
highlighter, it is returned unchanged.

This conversion is performed once per printed table. Hence, the face of a highlighter with
the default decoration function is converted to the native decoration only once, and the
printing loop only sees native highlighters.
"""
function _native_highlighters(convert::F, highlighters::Vector{AbstractHighlighter}) where F
    any(h -> h isa Highlighter, highlighters) || return highlighters
    return AbstractHighlighter[h isa Highlighter ? convert(h) : h for h in highlighters]
end

"""
    _text__native_highlighter(h::Highlighter) -> TextHighlighter
    _html__native_highlighter(h::Highlighter) -> HtmlHighlighter
    _latex__native_highlighter(h::Highlighter) -> LatexHighlighter
    _markdown__native_highlighter(h::Highlighter) -> MarkdownHighlighter
    _typst__native_highlighter(h::Highlighter) -> TypstHighlighter
    _excel__native_highlighter(h::Highlighter) -> ExcelHighlighter

Convert the general highlighter `h` to the native highlighter of a back end. If `h` uses the
default decoration function, its face is converted to the native decoration. Otherwise, the
native highlighter calls the decoration function of `h` and converts the returned face,
keeping a returned native decoration unchanged.
"""
function _text__native_highlighter(h::Highlighter)
    _has_default_fd(h) && return TextHighlighter(h.f, h._decoration)
    return TextHighlighter(h.f, (_, data, i, j) -> h.fd(h, data, i, j))
end

function _html__native_highlighter(h::Highlighter)
    _has_default_fd(h) && return HtmlHighlighter(h.f, html_decoration(h._decoration))
    return HtmlHighlighter(h.f, (_, data, i, j) -> _html__decoration(h.fd(h, data, i, j)))
end

function _latex__native_highlighter(h::Highlighter)
    _has_default_fd(h) && return LatexHighlighter(h.f, latex_decoration(h._decoration))
    return LatexHighlighter(h.f, (_, data, i, j) -> _latex__decoration(h.fd(h, data, i, j)))
end

function _markdown__native_highlighter(h::Highlighter)
    _has_default_fd(h) && return MarkdownHighlighter(h.f, markdown_decoration(h._decoration))
    return MarkdownHighlighter(
        h.f, (_, data, i, j) -> _markdown__decoration(h.fd(h, data, i, j))
    )
end

function _typst__native_highlighter(h::Highlighter)
    _has_default_fd(h) && return TypstHighlighter(h.f, typst_decoration(h._decoration))
    return TypstHighlighter(h.f, (_, data, i, j) -> _typst__decoration(h.fd(h, data, i, j)))
end

function _excel__native_highlighter(h::Highlighter)
    _has_default_fd(h) && return ExcelHighlighter(h.f, excel_decoration(h._decoration))
    return ExcelHighlighter(h.f, (_, data, i, j) -> _excel__decoration(h.fd(h, data, i, j)))
end

"""
    _text__native_highlighters(highlighters::Vector{AbstractHighlighter}) -> Vector{AbstractHighlighter}
    _html__native_highlighters(highlighters::Vector{AbstractHighlighter}) -> Vector{AbstractHighlighter}
    _latex__native_highlighters(highlighters::Vector{AbstractHighlighter}) -> Vector{AbstractHighlighter}
    _markdown__native_highlighters(highlighters::Vector{AbstractHighlighter}) -> Vector{AbstractHighlighter}
    _typst__native_highlighters(highlighters::Vector{AbstractHighlighter}) -> Vector{AbstractHighlighter}
    _excel__native_highlighters(highlighters::Vector{AbstractHighlighter}) -> Vector{AbstractHighlighter}

Convert every general highlighter in `highlighters` to the native highlighter of the back
end (see `_native_highlighters`).
"""
_text__native_highlighters(hs::Vector{AbstractHighlighter}) =
    _native_highlighters(_text__native_highlighter, hs)
_html__native_highlighters(hs::Vector{AbstractHighlighter}) =
    _native_highlighters(_html__native_highlighter, hs)
_latex__native_highlighters(hs::Vector{AbstractHighlighter}) =
    _native_highlighters(_latex__native_highlighter, hs)
_markdown__native_highlighters(hs::Vector{AbstractHighlighter}) =
    _native_highlighters(_markdown__native_highlighter, hs)
_typst__native_highlighters(hs::Vector{AbstractHighlighter}) =
    _native_highlighters(_typst__native_highlighter, hs)
_excel__native_highlighters(hs::Vector{AbstractHighlighter}) =
    _native_highlighters(_excel__native_highlighter, hs)
