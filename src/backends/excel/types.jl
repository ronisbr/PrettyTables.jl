## Description #############################################################################
#
# Types and structures for the Excel back end.
#
############################################################################################

export ExcelHighlighter, ExcelTableFormat, ExcelTableStyle

# Pair that defines Excel properties.
const ExcelPair = Pair{String, String}

############################################################################################
#                                       Highlighters                                       #
############################################################################################

"""
    struct ExcelHighlighter

Define the default highlighter of a table when using the Excel back end.

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

    ExcelHighlighter(f::Function, decoration::Vector{Pair{String, String}})

    ExcelHighlighter(f::Function, decorations::NTuple{N, Pair{String, String})

   ExcelHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
whereas the second let the user select the desired decoration by specifying the function
`fd`.
"""
struct ExcelHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Vector{ExcelPair}

    # == Constructors ======================================================================

    function ExcelHighlighter(f::Function, fd::Function)
        return new(f, fd, ExcelPair[])
    end

    function ExcelHighlighter(f::Function, decoration::ExcelPair)
        return new(
            f,
            _excel__default_highlighter_fd,
            [decoration]
        )
    end

    function ExcelHighlighter(f::Function, decoration::Vector{ExcelPair})
        return new(
            f,
            _excel__default_highlighter_fd,
            decoration
        )
    end

    function ExcelHighlighter(f::Function, decoration::Vector{ExcelPair}, args...)
        return new(
            f,
            _excel__default_highlighter_fd,
            [decoration..., args...]
        )
    end
end

_excel__default_highlighter_fd(h::ExcelHighlighter, ::Any, ::Int, ::Int) = h._decoration

############################################################################################
#                                       Table Format                                       #
############################################################################################

# Create some default decorations to reduce allocations.
const _EXCEL__NO_DECORATION = ExcelPair[]
const _EXCEL__BOLD = ["font-weight" => "bold"]
const _EXCEL__NAME = ["font-name" => "Arial"]
const _EXCEL__ITALIC = ["font-style" => "italic"]
const _EXCEL__XLARGE_BOLD = ["font-size" => "x-large", "font-weight" => "bold"]
const _EXCEL__LARGE_ITALIC = ["font-size" => "large", "font-style" => "italic"]
const _EXCEL__SMALL = ["font-size" => "small"]
const _EXCEL__SMALL_ITALIC = ["font-size" => "small", "font-style" => "italic"]
const _EXCEL__SMALL_ITALIC_GRAY = ["color" => "gray", "font-size" => "small", "font-style" => "italic"]
const _EXCEL__MERGED_CELL = ["border-bottom" => "1px solid black"]

"""
    ExcelTableFormat

Format that will be used to print the Excel table. All parameters are strings compatible with
the corresponding Excel property.


"""
#=
@kwdef struct ExcelTableFormat
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
=#

"""
    struct ExcelTableStyle

Define the style of the tables printed with the Excel back end.

# Fields

- `top_left_string::Vector{ExcelPair}`: Style for the top left string.
- `top_right_string::Vector{ExcelPair}`: Style for the top right string.
- `table::Vector{ExcelPair}`: Style for the table.
- `title::Vector{ExcelPair}`: Style for the title.
- `subtitle::Vector{ExcelPair}`: Style for the subtitle.
- `row_number_label::Vector{ExcelPair}`: Style for the row number label.
- `row_number::Vector{ExcelPair}`: Style for the row number.
- `stubhead_label::Vector{ExcelPair}`: Style for the stubhead label.
- `row_label::Vector{ExcelPair}`: Style for the row label.
- `row_group_label::Vector{ExcelPair}`: Style for the row group label.
- `first_line_column_label::Union{Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Style for
    the first line of the column labels. If a vector of `Vector{ExcelPair}}` is provided,
    each column label in the first line will use the corresponding style.
- `column_label::Union{Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Style for the rest of
    the column labels. If a vector of `Vector{ExcelPair}}` is provided, each column label
    will use the corresponding style.
- `first_line_merged_column_label::Vector{ExcelPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{ExcelPair}`: Style for the merged cells at the rest of the
    column labels.
- `summary_row_cell::Vector{ExcelPair}`: Style for the summary row cell.
- `summary_row_label::Vector{ExcelPair}`: Style for the summary row label.
- `footnote::Vector{ExcelPair}`: Style for the footnote.
- `source_notes::Vector{ExcelPair}`: Style for the source notes.
"""
@kwdef struct ExcelTableStyle{
    TFCL<:Union{Vector{ExcelPair}, Vector{Vector{ExcelPair}}},
    TCL<:Union{Vector{ExcelPair}, Vector{Vector{ExcelPair}}}
}
    top_left_string::Vector{ExcelPair}                = _EXCEL__NO_DECORATION
    top_right_string::Vector{ExcelPair}               = _EXCEL__ITALIC
    table::Vector{ExcelPair}                          = _EXCEL__NO_DECORATION
    title::Vector{ExcelPair}                          = _EXCEL__XLARGE_BOLD
    subtitle::Vector{ExcelPair}                       = _EXCEL__LARGE_ITALIC
    row_number_label::Vector{ExcelPair}               = _EXCEL__BOLD
    row_number::Vector{ExcelPair}                     = _EXCEL__BOLD
    stubhead_label::Vector{ExcelPair}                 = _EXCEL__BOLD
    row_label::Vector{ExcelPair}                      = _EXCEL__BOLD
    row_group_label::Vector{ExcelPair}                = _EXCEL__BOLD
    first_line_column_label::TFCL                    = _EXCEL__BOLD
    column_label::TCL                                = _EXCEL__NO_DECORATION
    first_line_merged_column_label::Vector{ExcelPair} = _EXCEL__MERGED_CELL
    merged_column_label::Vector{ExcelPair}            = _EXCEL__MERGED_CELL
    summary_row_cell::Vector{ExcelPair}               = _EXCEL__NO_DECORATION
    summary_row_label::Vector{ExcelPair}              = _EXCEL__BOLD
    footnote::Vector{ExcelPair}                       = _EXCEL__SMALL
    source_note::Vector{ExcelPair}                    = _EXCEL__SMALL_ITALIC_GRAY
end
