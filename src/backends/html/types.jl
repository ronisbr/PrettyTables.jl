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

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{Pair{String, String}}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.
- `_decoration::Dict{String, String}`: The decoration to be applied to the highlighted cell
    if the default `fd` is used.

# Remarks

This structure can be constructed using three helpers:

    HtmlHighlighter(f::Function, decoration::Vector{Pair{String, String}})

    HtmlHighlighter(f::Function, decorations::NTuple{N, Pair{String, String})

    HtmlHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
whereas the second let the user select the desired decoration by specifying the function
`fd`.
"""
struct HtmlHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Vector{HtmlPair}

    # == Constructors ======================================================================

    function HtmlHighlighter(f::Function, fd::Function)
        return new(f, fd, HtmlPair[])
    end

    function HtmlHighlighter(f::Function, decoration::HtmlPair)
        return new(
            f,
            _html__default_highlighter_fd,
            [decoration]
        )
    end

    function HtmlHighlighter(f::Function, decoration::Vector{HtmlPair})
        return new(
            f,
            _html__default_highlighter_fd,
            decoration
        )
    end

    function HtmlHighlighter(f::Function, decoration::Vector{HtmlPair}, args...)
        return new(
            f,
            _html__default_highlighter_fd,
            [decoration..., args...]
        )
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
const _HTML__SMALL_ITALIC_GRAY = ["color" => "gray", "font-size" => "small", "font-style" => "italic"]
const _HTML__MERGED_CELL = ["border-bottom" => "1px solid black"]

"""
    HtmlTableFormat

Format that will be used to print the HTML table. All parameters are strings compatible with
the corresponding HTML property.

# Fields

- `css::String`: CSS to be injected at the end of the `<style>` section.
- `table_width::String`: Table width.

# Remarks

Besides the usual HTML tags related to the tables (`table`, `td, `th`, `tr`, etc.), there
are three important classes that can be used to format tables using the variable `css`.

TODO: Add the classes.
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
- `first_line_column_label::Vector{HtmlPair}`: Style for the first line of the column
    labels.
- `column_label::Vector{HtmlPair}`: Style for the column label.
- `first_line_merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the rest of the
    column labels.
- `summary_row_cell::Vector{HtmlPair}`: Style for the summary row cell.
- `summary_row_label::Vector{HtmlPair}`: Style for the summary row label.
- `footnote::Vector{HtmlPair}`: Style for the footnote.
- `source_notes::Vector{HtmlPair}`: Style for the source notes.
"""
@kwdef struct HtmlTableStyle
    top_left_string::Vector{HtmlPair}                = _HTML__BOLD
    top_right_string::Vector{HtmlPair}               = _HTML__ITALIC
    table::Vector{HtmlPair}                          = _HTML__NO_DECORATION
    title::Vector{HtmlPair}                          = _HTML__XLARGE_BOLD
    subtitle::Vector{HtmlPair}                       = _HTML__LARGE_ITALIC
    row_number_label::Vector{HtmlPair}               = _HTML__BOLD
    row_number::Vector{HtmlPair}                     = _HTML__BOLD
    stubhead_label::Vector{HtmlPair}                 = _HTML__BOLD
    row_label::Vector{HtmlPair}                      = _HTML__BOLD
    row_group_label::Vector{HtmlPair}                = _HTML__BOLD
    first_line_column_label::Vector{HtmlPair}        = _HTML__BOLD
    column_label::Vector{HtmlPair}                   = _HTML__NO_DECORATION
    first_line_merged_column_label::Vector{HtmlPair} = _HTML__MERGED_CELL
    merged_column_label::Vector{HtmlPair}            = _HTML__MERGED_CELL
    summary_row_cell::Vector{HtmlPair}               = _HTML__NO_DECORATION
    summary_row_label::Vector{HtmlPair}              = _HTML__BOLD
    footnote::Vector{HtmlPair}                       = _HTML__SMALL
    source_note::Vector{HtmlPair}                    = _HTML__SMALL_ITALIC_GRAY
end
