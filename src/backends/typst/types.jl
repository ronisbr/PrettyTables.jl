## Description #############################################################################
#
# Types and structures for the Typst back end.
#
############################################################################################

export TypstHighlighter, TypstTableBorders, TypstTableFormat, TypstTableStyle, TypstCaption

import Base: show, tryparse, parse

############################################################################################
#                                        Constants                                         #
############################################################################################

# == Public ================================================================================

const TypstPair  = Pair{String, String}
const TypstAttrs = String

# == Private ===============================================================================

const _TYPST__ALIGNMENT_MAP = Dict(
    :l => "left",
    :L => "left",
    :c => "center",
    :C => "center",
    :r => "right",
    :R => "right"
)

const _TYPST__CELL_ATTRIBUTES = [
    "align",
    "breakable",
    "colspan",
    "fill",
    "inset",
    "rowspan",
    "stroke",
]

const _TYPST__TABLE_ATTRIBUTES = [
    "rows",
    "gutter",
    "column-gutter",
    "row-gutter",
    "inset",
    "fill",
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
    "fill",
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

# -- Decorations ---------------------------------------------------------------------------

const _TYPST__NO_DECORATION     = TypstPair[]
const _TYPST__BOLD              = ["text-weight" => "bold"]
const _TYPST__ITALIC            = ["text-style" => "italic"]
const _TYPST__XLARGE_BOLD       = ["text-size" => "1.1em", "text-weight" => "bold"]
const _TYPST__LARGE_ITALIC      = ["text-size" => "1.1em", "text-style" => "italic"]
const _TYPST__SMALL             = ["text-size" => "0.9em"]
const _TYPST__SMALL_ITALIC      = ["text-size" => "0.9em", "text-style" => "italic"]
const _TYPST__SMALL_ITALIC_GRAY = ["text-fill" => "gray", "text-size" => "0.9em", "text-style" => "italic"]
const _TYPST__MERGED_CELL       = TypstPair[]

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
    struct TypstTableBorders

Define the stroke widths for the borders of a table printed with the Typst back end. All
fields are strings with the properties that can be passed to a `stroke` object (e.g.,
`"(paint: blue, thickness: 4pt, cap: \"round\")"`). For more information, refer to:
https://typst.app/docs/reference/visualize/stroke/

# Fields

## Horizontal Lines

- `top_line::String`: Stroke for the top border of the table.
    (**Default**: `"1.5pt"`)
- `header_line::String`: Stroke for the line below the table header.
    (**Default**: `"1.0pt"`)
- `merged_header_cell_line::String`: Stroke for the line below merged header cells.
    (**Default**: `"0.8pt"`)
- `middle_line::String`: Stroke for horizontal lines inside the table body.
    (**Default**: `"0.8pt"`)
- `bottom_line::String`: Stroke for the bottom border of the table.
    (**Default**: `"1.5pt"`)

## Vertical Lines

- `left_line::String`: Stroke for the left border of the table.
    (**Default**: `"1.5pt"`)
- `center_line::String`: Stroke for vertical lines inside the table body.
    (**Default**: `"0.8pt"`)
- `right_line::String`: Stroke for the right border of the table.
    (**Default**: `"1.5pt"`)
"""
@kwdef struct TypstTableBorders
    # == Horizontal Lines ==================================================================

    top_line::String                = "1.5pt"
    header_line::String             = "0.8pt"
    merged_header_cell_line::String = "0.8pt"
    middle_line::String             = "0.5pt"
    bottom_line::String             = "1.5pt"

    # == Vertical Lines ====================================================================

    left_line::String               = "1.5pt"
    center_line::String             = "0.8pt"
    right_line::String              = "1.5pt"
end

"""
    struct TypstTableFormat

Define the format of the tables printed with the Typst back end.

# Fields

- `borders::TypstTableBorders`: Format of the borders.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_line_at_merged_column_labels::Bool`: If `true`, a horizontal line will be
    drawn on bottom of the merged column labels using `\\cline`.
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the column labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data column. If the symbol `:none` is passed,
    no horizontal lines will be drawn after the data rows.
- `horizontal_line_before_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn before the row group label.
- `horizontal_line_after_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn after the row group label.
- `horizontal_line_after_data_rows::Bool`: If `true`, a horizontal line will be drawn
    after the data rows.
- `horizontal_line_before_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    before the summary rows. Notice that this line is the same as the one drawn if
    `horizontal_line_after_data_rows` is `true`. However, in this case, the line is omitted
    if there is no summary rows.
- `horizontal_line_after_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    after the summary rows.
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will be
    drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data column. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.
"""
@kwdef struct TypstTableFormat
    borders::TypstTableBorders = TypstTableBorders()

    # == Configuration for the Horizontal and Vertical Lines ===============================

    horizontal_line_at_beginning::Bool = true
    horizontal_line_after_column_labels::Bool = true
    horizontal_line_at_merged_column_labels::Bool = true
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_before_row_group_label::Bool = true
    horizontal_line_after_row_group_label::Bool = true
    horizontal_line_after_data_rows::Bool = true
    horizontal_line_before_summary_rows::Bool = true
    horizontal_line_after_summary_rows::Bool = true

    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
    vertical_line_after_data_columns::Bool = true
    vertical_line_after_continuation_column::Bool = true
end

"""
    struct TypstTableStyle

Define the style of the tables printed with the Typst back end.

# Fields

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
- `omitted_cell_summary::Vector{TypstPair}`: Style for the omitted cell summary.
- `summary_row_cell::Vector{TypstPair}`: Style for the summary row cell.
- `summary_row_label::Vector{TypstPair}`: Style for the summary row label.
- `footnote::Vector{TypstPair}`: Style for the footnote.
- `source_notes::Vector{TypstPair}`: Style for the source notes.
"""
@kwdef struct TypstTableStyle{
    TFCL <: Union{Vector{TypstPair}, Vector{Vector{TypstPair}}},
    TCL <: Union{Vector{TypstPair}, Vector{Vector{TypstPair}}},
}
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
    omitted_cell_summary::Vector{TypstPair}           = _TYPST__SMALL_ITALIC_GRAY
    summary_row_cell::Vector{TypstPair}               = _TYPST__NO_DECORATION
    summary_row_label::Vector{TypstPair}              = _TYPST__BOLD
    footnote::Vector{TypstPair}                       = _TYPST__SMALL
    source_note::Vector{TypstPair}                    = _TYPST__SMALL_ITALIC_GRAY
end

"""
    struct TypstCaption

Define a Typst caption configuration to be used by the Typst backend.

# Fields

- `caption::String`: Caption text.
- `kind::Union{Auto, String}`: Caption kind forwarded to Typst (for example, `auto` or a
    custom kind).
- `supplement::Union{Nothing, String}`: Optional caption supplement.
- `gap::Union{Auto, AbstractTypstLength}`: Gap between figure content and caption.
- `position::Union{Nothing, String}`: Optional caption position.
"""
@kwdef struct TypstCaption
    caption::String
    kind::String = "auto"
    supplement::Union{Nothing, String} = nothing
    gap::String = "auto"
    position::Union{Nothing, String} = nothing
end

TypstCaption(caption::String; kwargs...) = TypstCaption(; caption, kwargs...)