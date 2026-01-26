## Description #############################################################################
#
# Types and structures for the Excel back end.
#
############################################################################################

export ExcelHighlighter, ExcelTableFormat, ExcelTableStyle

############################################################################################
#                                       Constants                                          #
############################################################################################

# Pair that defines Excel properties.
const ExcelPair = Pair{String, String}

# Create some default decorations to reduce allocations.
const _EXCEL__NO_DECORATION = ExcelPair[]
const _EXCEL__BOLD = ["bold" => "true"]
const _EXCEL__NAME = ["name" => "Calibri"]
const _EXCEL__ITALIC = ["italic" => "true"]
const _EXCEL__XLARGE_BOLD = ["size" => "18", "bold" => "true"]
const _EXCEL__LARGE_ITALIC = ["size" => "14", "italic" => "true"]
const _EXCEL__SMALL = ["size" => "10"]
const _EXCEL__SMALL_ITALIC = ["size" => "10", "italic" => "true"]
const _EXCEL__SMALL_ITALIC_GRAY = ["color" => "gray", "size" => "10", "italic" => "true"]
const _EXCEL__MERGED_CELL = ["bottom" => "thin", "color" => "black"]

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


"""
    ExcelTableFormat

Format that will be used to print the Excel table. All parameters are strings compatible with
the corresponding Excel property.


"""
@kwdef struct ExcelTableFormat
end


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
@kwdef struct ExcelTableStyle
    table::Vector{ExcelPair}                          = _EXCEL__NO_DECORATION
    title::Vector{ExcelPair}                          = _EXCEL__XLARGE_BOLD
    subtitle::Vector{ExcelPair}                       = _EXCEL__LARGE_ITALIC
    row_number_label::Vector{ExcelPair}               = _EXCEL__BOLD
    row_number::Vector{ExcelPair}                     = _EXCEL__BOLD
    stubhead_label::Vector{ExcelPair}                 = _EXCEL__BOLD
    row_label::Vector{ExcelPair}                      = _EXCEL__BOLD
    row_group_label::Vector{ExcelPair}                = _EXCEL__BOLD
    first_line_column_label::Vector{ExcelPair}                     = _EXCEL__BOLD
    column_label::Vector{ExcelPair}                                 = _EXCEL__BOLD
    first_line_merged_column_label::Vector{ExcelPair} = _EXCEL__MERGED_CELL
    merged_column_label::Vector{ExcelPair}            = _EXCEL__MERGED_CELL
    summary_row_cell::Vector{ExcelPair}               = _EXCEL__NO_DECORATION
    summary_row_label::Vector{ExcelPair}              = _EXCEL__BOLD
    footnote::Vector{ExcelPair}                       = _EXCEL__SMALL
    source_note::Vector{ExcelPair}                    = _EXCEL__SMALL_ITALIC_GRAY
end
