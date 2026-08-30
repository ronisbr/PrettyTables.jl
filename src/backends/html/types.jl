## Description #############################################################################
#
# Types and structures for the HTML back end.
#
############################################################################################

export HtmlHighlighter, HtmlTableFormat, HtmlTableStyle

# Pair that defines HTML properties.
const HtmlPair = Pair{String, String}

############################################################################################
#                                       Highlighters                                       #
############################################################################################

"""
    struct HtmlHighlighter

Define the default highlighter of a table when using the HTML back end.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{Pair{String, String}}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.
- `_decoration::Vector{HtmlPair}`: The decoration to be applied to the highlighted cell
    if the default `fd` is used.

# Remarks

This structure can be constructed using the following helpers:

    HtmlHighlighter(f::Function, decoration::HtmlPair)

    HtmlHighlighter(f::Function, decoration::Vector{HtmlPair})

    HtmlHighlighter(f::Function, fd::Function)

The first two apply a fixed decoration to the highlighted cell, whereas the third lets the
user select the desired decoration by specifying the function `fd`.
"""
struct HtmlHighlighter <: AbstractHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Vector{HtmlPair}

    # == Constructors ======================================================================

    function HtmlHighlighter(f::Function, fd::Function)
        return new(f, fd, HtmlPair[])
    end

    function HtmlHighlighter(f::Function, decoration::HtmlPair)
        return new(f, _html__default_highlighter_fd, [decoration])
    end

    function HtmlHighlighter(f::Function, decoration::Vector{HtmlPair})
        return new(f, _html__default_highlighter_fd, decoration)
    end

    function HtmlHighlighter(f::Function, decoration::Vector{HtmlPair}, args::HtmlPair...)
        return new(f, _html__default_highlighter_fd, [decoration..., args...])
    end
end

_html__default_highlighter_fd(h::HtmlHighlighter, ::Any, ::Int, ::Int) = h._decoration

############################################################################################
#                                       Table Format                                       #
############################################################################################

# Create some default decorations to reduce allocations.
const _HTML__NO_DECORATION = HtmlPair[]
const _HTML__BOLD = ["font-weight" => "bold"]
const _HTML__ITALIC = ["font-style" => "italic"]
const _HTML__XLARGE_BOLD = ["font-size" => "x-large", "font-weight" => "bold"]
const _HTML__LARGE_ITALIC = ["font-size" => "large", "font-style" => "italic"]
const _HTML__SMALL = ["font-size" => "small"]
const _HTML__SMALL_ITALIC = ["font-size" => "small", "font-style" => "italic"]
const _HTML__SMALL_ITALIC_GRAY = [
    "color" => "gray", "font-size" => "small", "font-style" => "italic"
]
const _HTML__MERGED_CELL = ["border-bottom" => "1px solid black"]

"""
    HtmlTableFormat

Format that will be used to print the HTML table. All parameters are strings compatible with
the corresponding HTML property.

# Fields

- `css::String`: CSS to be injected at the end of the `<style>` section.
- `table_width::String`: Table width.

Notice that this format is only applied if `stand_alone = true`.
"""
@kwdef struct HtmlTableFormat
    css::String = """
    table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
    }

    td, th {
      padding-bottom: 6px !important;
      padding-left: 8px !important;
      padding-right: 8px !important;
      padding-top: 6px !important;
    }

    tr.title td {
      padding-bottom: 2px !important;
    }

    tr.footnote td {
      padding-bottom: 2px !important;
    }

    tr.sourceNotes td {
      padding-bottom: 2px !important;
    }

    table > *:first-child > tr:first-child {
      border-top: 2px solid black;
    }

    table > *:last-child > tr:last-child {
      border-bottom: 2px solid black;
    }

    thead > tr:nth-child(1 of .columnLabelRow) {
      border-top: 1px solid black;
    }

    thead tr:last-child {
      border-bottom: 1px solid black;
    }

    tbody tr:last-child {
      border-bottom: 1px solid black;
    }

    tbody > tr:nth-child(1 of .summaryRow) {
      border-top: 1px solid black;
    }

    tbody > tr:nth-last-child(1 of .summaryRow) {
      border-bottom: 1px solid black;
    }

    tfoot tr:nth-last-child(1 of .footnote) {
      border-bottom: 1px solid black;
    }"""

    table_width::String = ""
end

"""
    struct HtmlTableStyle

Define the style of the tables printed with the HTML back end.

# Fields

- `top_left_string::Vector{HtmlPair}`: Style for the top left string.
- `top_right_string::Vector{HtmlPair}`: Style for the top right string.
- `table::Vector{HtmlPair}`: Style for the table.
- `title::Vector{HtmlPair}`: Style for the title.
- `subtitle::Vector{HtmlPair}`: Style for the subtitle.
- `row_number_label::Vector{HtmlPair}`: Style for the row number label.
- `row_number::Vector{HtmlPair}`: Style for the row number.
- `stubhead_label::Vector{HtmlPair}`: Style for the stubhead label.
- `row_label::Vector{HtmlPair}`: Style for the row label.
- `row_group_label::Vector{HtmlPair}`: Style for the row group label.
- `first_line_column_label::Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}}`: Style for
    the first line of the column labels. If a vector of `Vector{HtmlPair}` is provided,
    each column label in the first line will use the corresponding style.
- `column_label::Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}}`: Style for the rest of
    the column labels. If a vector of `Vector{HtmlPair}` is provided, each column label
    will use the corresponding style.
- `first_line_merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the rest of the
    column labels.
- `summary_row_cell::Vector{HtmlPair}`: Style for the summary row cell.
- `summary_row_label::Vector{HtmlPair}`: Style for the summary row label.
- `footnote::Vector{HtmlPair}`: Style for the footnote.
- `source_note::Vector{HtmlPair}`: Style for the source notes.

# Constructor

    HtmlTableStyle(; kwargs...)

Create a style in which each field can be passed as a keyword. Every keyword also accepts a
`Face`, which is converted with [`html_decoration`](@ref). The keywords
`first_line_column_label` and `column_label` also accept a vector with one decoration (CSS
properties or `Face`) per column.
"""
struct HtmlTableStyle{
    TFCL <: Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}},
    TCL <: Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}},
}
    top_left_string::Vector{HtmlPair}
    top_right_string::Vector{HtmlPair}
    table::Vector{HtmlPair}
    title::Vector{HtmlPair}
    subtitle::Vector{HtmlPair}
    row_number_label::Vector{HtmlPair}
    row_number::Vector{HtmlPair}
    stubhead_label::Vector{HtmlPair}
    row_label::Vector{HtmlPair}
    row_group_label::Vector{HtmlPair}
    first_line_column_label::TFCL
    column_label::TCL
    first_line_merged_column_label::Vector{HtmlPair}
    merged_column_label::Vector{HtmlPair}
    summary_row_cell::Vector{HtmlPair}
    summary_row_label::Vector{HtmlPair}
    footnote::Vector{HtmlPair}
    source_note::Vector{HtmlPair}
end

function HtmlTableStyle(;
    top_left_string                = _HTML__NO_DECORATION,
    top_right_string               = _HTML__ITALIC,
    table                          = _HTML__NO_DECORATION,
    title                          = _HTML__XLARGE_BOLD,
    subtitle                       = _HTML__LARGE_ITALIC,
    row_number_label               = _HTML__BOLD,
    row_number                     = _HTML__BOLD,
    stubhead_label                 = _HTML__BOLD,
    row_label                      = _HTML__BOLD,
    row_group_label                = _HTML__BOLD,
    first_line_column_label        = _HTML__BOLD,
    column_label                   = _HTML__NO_DECORATION,
    first_line_merged_column_label = _HTML__MERGED_CELL,
    merged_column_label            = _HTML__MERGED_CELL,
    summary_row_cell               = _HTML__NO_DECORATION,
    summary_row_label              = _HTML__BOLD,
    footnote                       = _HTML__SMALL,
    source_note                    = _HTML__SMALL_ITALIC_GRAY,
)
    return HtmlTableStyle(
        _html__decoration(top_left_string),
        _html__decoration(top_right_string),
        _html__decoration(table),
        _html__decoration(title),
        _html__decoration(subtitle),
        _html__decoration(row_number_label),
        _html__decoration(row_number),
        _html__decoration(stubhead_label),
        _html__decoration(row_label),
        _html__decoration(row_group_label),
        _html__column_label_decoration(first_line_column_label),
        _html__column_label_decoration(column_label),
        _html__decoration(first_line_merged_column_label),
        _html__decoration(merged_column_label),
        _html__decoration(summary_row_cell),
        _html__decoration(summary_row_label),
        _html__decoration(footnote),
        _html__decoration(source_note),
    )
end
