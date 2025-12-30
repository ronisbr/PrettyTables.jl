## Description #############################################################################
#
# Types and structures for the Typst back end.
#
############################################################################################

export TypstHighlighter, TypstTableStyle

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
    "align",
    "breakable",
    "colspan",
    "fill",
    "inset",
    "rowspan",
    "stroke",
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
        return new(
            f,
            _typst__default_highlighter_fd,
            [decoration]
        )
    end

    function TypstHighlighter(f::Function, decoration::Vector{TypstPair})
        return new(
            f,
            _typst__default_highlighter_fd,
            decoration
        )
    end

    function TypstHighlighter(f::Function, decoration::Vector{TypstPair}, args...)
        return new(
            f,
            _typst__default_highlighter_fd,
            [decoration..., args...]
        )
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
    TFCL<:Union{Vector{TypstPair}, Vector{Vector{TypstPair}}},
    TCL<:Union{Vector{TypstPair}, Vector{Vector{TypstPair}}}
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

