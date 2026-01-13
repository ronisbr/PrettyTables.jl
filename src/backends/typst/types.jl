## Description #############################################################################
#
# Types and structures for the Typst back end.
#
############################################################################################

export TypstHighlighter, TypstTableStyle

import Base: show, tryparse, parse

############################################################################################
#                                        Constants                                         #
############################################################################################

# Public.
const TypstPair  = Pair{String, String}
const TypstAttrs = String

# Private.
const _TYPST__NO_DECORATION     = TypstPair[]
const _TYPST__BOLD              = ["weight" => "bold"]
const _TYPST__ITALIC            = ["style" => "italic"]
const _TYPST__XLARGE_BOLD       = ["size" => "1.1em", "weight" => "bold"]
const _TYPST__LARGE_ITALIC      = ["size" => "1.1em", "style" => "italic"]
const _TYPST__SMALL             = ["size" => "0.9em"]
const _TYPST__SMALL_ITALIC      = ["size" => "0.9em", "style" => "italic"]
const _TYPST__SMALL_ITALIC_GRAY = ["color" => "gray", "size" => "0.9em", "style" => "italic"]
const _TYPST__MERGED_CELL       = ["stroke" => "(paint: rgb(200,200,200), thickness: 0.01pt)"]

const _TYPST__CELL_ATTRIBUTES = [
    "align", "breakable", "colspan", "fill", "inset", "rowspan", "stroke"
]

const _TYPST__STRING_ATTRIBUTES = [
    "bottom-edge",
    "font",
    "lang",
    "number-type",
    "number-width",
    "region",
    "script",
    "style",
    "top-edge",
    "weight",
]

const _TYPST__TEXT_ATTRIBUTES = [
    "alternates",
    "baseline",
    "bottom-edge",
    "cjk-latin-spacing",
    "costs",
    "dir",
    "discretionary-ligatures",
    "fallback",
    "features",
    "font",
    "fractions",
    "historical-ligatures",
    "hyphenate",
    "kerning",
    "lang",
    "ligatures",
    "number-type",
    "number-width",
    "overhang",
    "region",
    "script",
    "size",
    "slashed-zero",
    "spacing",
    "stretch",
    "style",
    "stylistic-set",
    "top-edge",
    "tracking",
    "weight",
]

const _typst__filter_text_atributes = filter(
    x -> x[1] ∈ _TYPST__TEXT_ATTRIBUTES || occursin(r"text-", x[1])
)

############################################################################################
#                                          Types                                           #
############################################################################################

"""
    struct TypstHighlighter

Define the default highlighter of a table when using the Typst back end.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{Pair{String, String}}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.
- `_decoration::Dict{String, String}`: The decoration to be applied to the highlighted cell
    if the default `fd` is used.

# Remarks

This structure can be constructed using three helpers:

    TypstHighlighter(f::Function, decoration::Vector{Pair{String, String}})

    TypstHighlighter(f::Function, decorations::NTuple{N, Pair{String, String})

    TypstHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
whereas the second let the user select the desired decoration by specifying the function
`fd`.
"""
struct TypstHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Vector{TypstPair}

    # == Constructors ======================================================================

    function TypstHighlighter(f::Function, fd::Function)
        return new(f, fd, TypstPair[])
    end

    function TypstHighlighter(f::Function, decoration::TypstPair)
        return new(f, _typst__default_highlighter_fd, [decoration])
    end

    function TypstHighlighter(f::Function, decoration::Vector{TypstPair})
        return new(f, _typst__default_highlighter_fd, decoration)
    end

    function TypstHighlighter(f::Function, decoration::Vector{TypstPair}, args...)
        return new(f, _typst__default_highlighter_fd, [decoration..., args...])
    end
end

_typst__default_highlighter_fd(h::TypstHighlighter, ::Any, ::Int, ::Int) = h._decoration

"""
    struct TypstTableStyle

Define the style of the tables printed with the Typst back end.

# Fields

- `top_left_string::Vector{TypstPair}`: Style for the top left string.
- `top_right_string::Vector{TypstPair}`: Style for the top right string.
- `table::Vector{TypstPair}`: Style for the table.
- `title::Vector{TypstPair}`: Style for the title.
- `subtitle::Vector{TypstPair}`: Style for the subtitle.
- `row_number_label::Vector{TypstPair}`: Style for the row number label.
- `row_number::Vector{TypstPair}`: Style for the row number.
- `stubhead_label::Vector{TypstPair}`: Style for the stubhead label.
- `row_label::Vector{TypstPair}`: Style for the row label.
- `row_group_label::Vector{TypstPair}`: Style for the row group label.
- `first_line_column_label::Union{Vector{TypstPair}, Vector{Vector{TypstPair}}}`: Style for
    the first line of the column labels. If a vector of `Vector{TypstPair}}` is provided,
    each column label in the first line will use the corresponding style.
- `column_label::Union{Vector{TypstPair}, Vector{Vector{TypstPair}}}`: Style for the rest of
    the column labels. If a vector of `Vector{TypstPair}}` is provided, each column label
    will use the corresponding style.
- `first_line_merged_column_label::Vector{TypstPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{TypstPair}`: Style for the merged cells at the rest of the
    column labels.
- `summary_row_cell::Vector{TypstPair}`: Style for the summary row cell.
- `summary_row_label::Vector{TypstPair}`: Style for the summary row label.
- `footnote::Vector{TypstPair}`: Style for the footnote.
- `source_notes::Vector{TypstPair}`: Style for the source notes.
"""
@kwdef struct TypstTableStyle{
    TFCL <: Union{Vector{TypstPair}, Vector{Vector{TypstPair}}},
    TCL <: Union{Vector{TypstPair}, Vector{Vector{TypstPair}}},
}
    top_left_string::Vector{TypstPair}                = _TYPST__NO_DECORATION
    top_right_string::Vector{TypstPair}               = _TYPST__ITALIC
    table::Vector{TypstPair}                          = _TYPST__NO_DECORATION
    title::Vector{TypstPair}                          = _TYPST__XLARGE_BOLD
    subtitle::Vector{TypstPair}                       = _TYPST__LARGE_ITALIC
    row_number_label::Vector{TypstPair}               = _TYPST__BOLD
    row_number::Vector{TypstPair}                     = _TYPST__BOLD
    stubhead_label::Vector{TypstPair}                 = _TYPST__BOLD
    row_label::Vector{TypstPair}                      = _TYPST__BOLD
    row_group_label::Vector{TypstPair}                = _TYPST__BOLD
    first_line_column_label::TFCL                     = _TYPST__BOLD
    column_label::TCL                                 = _TYPST__BOLD
    first_line_merged_column_label::Vector{TypstPair} = _TYPST__MERGED_CELL
    merged_column_label::Vector{TypstPair}            = _TYPST__MERGED_CELL
    summary_row_cell::Vector{TypstPair}               = _TYPST__NO_DECORATION
    summary_row_label::Vector{TypstPair}              = _TYPST__BOLD
    footnote::Vector{TypstPair}                       = _TYPST__SMALL
    source_note::Vector{TypstPair}                    = _TYPST__SMALL_ITALIC_GRAY
end

abstract type AbstractTypstLength end
abstract type TypstLengthKind end
abstract type TypstFixedLengthKind <: TypstLengthKind end
abstract type TypstRelativeLengthKind <: TypstLengthKind end
abstract type TypstFractionalLengthKind <: TypstLengthKind end

struct Pt <: TypstFixedLengthKind end
struct Mm <: TypstFixedLengthKind end
struct Cm <: TypstFixedLengthKind end
struct In <: TypstFixedLengthKind end
struct Em <: TypstRelativeLengthKind end
struct Ex <: TypstRelativeLengthKind end
struct Fr <: TypstFractionalLengthKind end
struct Percent <: TypstRelativeLengthKind end
struct Auto end

# ---- policy helpers ----

const _TYPST_SUFFIX_UNIT_MAP = Dict(
    "pt" => Pt,
    "mm" => Mm,
    "cm" => Cm,
    "in" => In,
    "em" => Em,
    "ex" => Ex,
    "fr" => Fr,
    "percent"  => Percent,
    "%"  => Percent,
    "auto" => Auto,
)

const _TYPST_UNIT_SUFFIX_MAP = Dict(
    Pt      => "pt",
    Mm      => "mm",
    Cm      => "cm",
    In      => "in",
    Em      => "em",
    Ex      => "ex",
    Fr      => "fr",
    Percent => "%",
    Auto    => "auto",
)

"""
    TypstLength{T}

Represents a **Typst Length value**, encoding both the *numeric magnitude*
and the *unit or sizing mode* used by the Typst layout engine.

`TypstLength` is intended to model all valid Length expressions accepted by
Typst, including absolute units, font-relative units, layout fractions,
percentages, and the special `auto` keyword.

The type parameter `T` specifies the *kind of Length* and determines
how the value should be interpreted when serialized to Typst.

---

## Supported Length categories

### 1. Absolute Lengths (physical units)

Used for print-accurate layout such as margins and page geometry.

| Unit | Meaning |
|------|--------|
| `pt` | Typographic point (1/72 inch) |
| `mm` | Millimeters |
| `cm` | Centimeters |
| `in` | Inches |

Example (Typst):
```typst
25mm
12pt
```

### 2. Font-relative Lengths

Scale relative to the current text Length.

| Unit | Meaning |
|------|--------|
| `em` | Current font Length |
| `ex` | x-height of the font |

Example (Typst):
```typst
25mm
12pt
```

### 3. Fractional Lengths (fr)

Represents a fraction of remaining available space in layout
constructs such as grids, tables, and columns.

fr units are only valid in layout contexts.

Example (Typst):
```typst
1fr
2fr
```

### 4. Percentage Lengths (%)

Relative to the Length of the containing element.

Example:

```typst
50%
```

## Design notes

TypstLength deliberately does not include pixel-based units (px)
or viewport units (vw, vh), as Typst targets print-quality layout.

There is no rem unit; em already captures scoped font-relative sizing.

The type parameter T is expected to encode the semantic category
of the Length (e.g. :pt, :em, :fr, :percent, :auto).

## Examples 

Default constructor
```
TypstLength{Pt}(12)
TypstLength{Em}(0.5)
TypstLength{Fr}(1)
TypstLength{Percent}(50)
TypstLength{Auto}()
```

Alternative constructor
```
TypstLength(Pt,12)
TypstLength(Auto,)
```
Using Symbol
```
TypstLength(:percent,50)
TypstLength(:pt,50)
```

Auto-parse (from string)
```
TypstLength("50em")
TypstLength("2fr")
TypstLength("4%")
```

## See also

Typst layout reference: https://typst.app/docs/reference/layout/

Typst syntax reference: https://typst.app/docs/reference/syntax/

"""
struct TypstLength{T <: Union{Auto,TypstLengthKind}} <: AbstractTypstLength
    value::Union{Nothing, Float64}
end

# Convenience constructors
TypstLength() = TypstLength{Auto}(nothing)
TypstLength(::Type{Auto},x=nothing) = TypstLength{Auto}(nothing)
TypstLength(::Type{T}, x::Real) where {T <: TypstLengthKind} = TypstLength{T}(Float64(x))
TypstLength(s::AbstractString) = parse(TypstLength, s)
function TypstLength(t::Symbol, x::Real) 
    T = get(_TYPST_SUFFIX_UNIT_MAP, (lowercase ∘ string)(t), Auto)
    TypstLength{T}(Float64(x))
end

function Base.tryparse(::Type{TypstLength}, s::AbstractString) :: Union{Nothing, TypstLength}
    t = lowercase(strip(s))

    if t == "auto"
        return TypstLength(Auto)
    end

    # number-only string
    if occursin(r"^[+-]?\d+(\.\d+)?$", t)
        return tryparse(TypstLength, parse(Float64, t))
    end

    m = match(r"^([+-]?\d+(?:\.\d+)?)(?:\s*)(pt|mm|cm|in|em|ex|fr|%)$", t)
    if m === nothing
        return nothing
    end

    value = parse(Float64, m.captures[1])
    unit  = m.captures[2]

    T = get(_TYPST_SUFFIX_UNIT_MAP, unit, nothing)
    T === nothing && return nothing

    return T === Auto ? TypstLength(Auto) : TypstLength(T, value)
end

function Base.tryparse(::Type{TypstLength}, x::Real) :: Union{Nothing, TypstLength}
    if x >= 1
        return TypstLength(Em, x)
    elseif x > 0
        return TypstLength(Fr, x)  # PrettyTables-friendly default
    else
        return nothing
    end
end

"""
    parse(TypstLength, x) -> TypstLength

Parse `x` into a `TypstLength`.

Numeric values are interpreted contextually:
- `x ≥ 1` → `x em`
- `0 < x < 1` → `x fr` (layout weight, suitable for table columns)

Strings may specify explicit units (`pt`, `em`, `fr`, `%`, etc.) or `"auto"`.
"""
function Base.parse(::Type{TypstLength}, x) :: TypstLength
    v = tryparse(TypstLength, x)
    v === nothing && throw(
        ArgumentError(
            "Cannot parse TypstLength from $(repr(x)). " *
            "Expected a number, 'auto', or '<number><unit>' " *
            "(pt, mm, cm, in, em, ex, fr, %).",
        ),
    )
    return v
end

function Base.show(io::IO, s::TypstLength{T}) where {T}
    if T === Auto || isnothing(s.value)
        print(io, "auto")
        return
    end
    value = s.value
    suffix = _TYPST_UNIT_SUFFIX_MAP[T]

    # Avoid trailing .0 when possible
    if isinteger(value)
        print(io, Int(value), suffix)
    else
        print(io, round(value,digits=2), suffix)
    end
    return nothing
end