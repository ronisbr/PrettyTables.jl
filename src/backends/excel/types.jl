## Description #############################################################################
#
# Types and structures for the Excel back end.
#
############################################################################################

export ExcelHighlighter, ExcelTableFormat, ExcelTableStyle, ExcelFormatter, DEFAULT_EXCEL_TABLE_FORMAT, DEFAULT_EXCEL_TABLE_STYLE 

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
const _EXCEL__MERGED_CELL = ["color" => "black"]

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

    _decoration::Vector{Pair{Symbol,Vector{ExcelPair}}}

    # == Constructors ======================================================================

    function ExcelHighlighter(f::Function, fd::Function)
        return new(f, fd, ExcelPair[])
    end

    function ExcelHighlighter(f::Function, decoration::ExcelPair)
        return new(
            f,
            _excel__default_highlighter_fd,
            [:font => [decoration]]
        )
    end

    function ExcelHighlighter(f::Function, decoration::Pair{Symbol,Vector{ExcelPair}})
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
            [:font => decoration]
        )
    end

    function ExcelHighlighter(f::Function, decoration::Vector{Pair{Symbol,Vector{ExcelPair}}}, args...)
        return new(
            f,
            _excel__default_highlighter_fd,
            [decoration..., args...]
        )
    end
end

_excel__default_highlighter_fd(h::ExcelHighlighter, ::Any, ::Int, ::Int) = h._decoration

############################################################################################
#                                       Formatters                                         #
############################################################################################

"""
    ExcelFormatter

Define the Excel format to apply to a cell.

# Fields

- `f::Function`: Function with the signature `f(value, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `numFmt::ExcelPair`: Specifies the format to apply to the cell. The format should be 
    specified using the `XLSX.jl` formatting definitions used by the `XLSX.setFormat`
    function. 

"""
struct ExcelFormatter
    f::Function
    numFmt::Vector{ExcelPair}
end

############################################################################################
#                                       Table Format                                       #
############################################################################################


"""
    ExcelTableFormat

Format that will be used to print the Excel table. All parameters are strings compatible with
the corresponding Excel property.


"""
@kwdef struct ExcelTableFormat
    outside_border::Bool = true
    outside_border_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_title::Union{Nothing,Bool} = nothing
    underline_title_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_headers::Union{Nothing,Bool} = nothing
    underline_headers_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_merged_headers::Union{Nothing,Bool} = nothing
    underline_merged_headers_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_data_rows::Union{Nothing,Bool} = nothing
    underline_data_rows_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_table::Union{Nothing,Bool} = nothing
    underline_table_type::Union{Nothing,Vector{ExcelPair}}=nothing
    overline_group::Union{Nothing,Bool} = nothing
    overline_group_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_group::Union{Nothing,Bool} = nothing
    underline_group_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_summary_rows::Union{Nothing,Bool} = nothing
    underline_summary_rows_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_summary::Union{Nothing,Bool} = nothing
    underline_summary_type::Union{Nothing,Vector{ExcelPair}}=nothing
    underline_footnotes::Union{Nothing,Bool} = nothing
    underline_footnotes_type::Union{Nothing,Vector{ExcelPair}}=nothing
    vline_after_row_numbers::Union{Nothing,Bool} = nothing
    vline_after_row_numbers_type::Union{Nothing,Vector{ExcelPair}}=nothing
    vline_after_row_labels::Union{Nothing,Bool} = nothing
    vline_after_row_labels_type::Union{Nothing,Vector{ExcelPair}}=nothing
    vline_between_data_columns::Union{Nothing,Bool} = nothing
    vline_between_data_columns_type::Union{Nothing,Vector{ExcelPair}}=nothing
    data_cell_width::Union{Float64,Vector{Float64},Nothing}=nothing
    min_data_cell_width::Union{Float64,Vector{Float64},Nothing}=nothing
    max_data_cell_width::Union{Float64,Vector{Float64},Nothing}=nothing
end


const DEFAULT_EXCEL_TABLE_FORMAT = ExcelTableFormat(
    true,                                                 # outside_border
    ExcelPair["style" => "thick", "color" => "Black"],    # outside_border_type
    true,                                                 # underline_title
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_title_type
    true,                                                 # underline_headers
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_headers_type
    true,                                                 # underline_merged_headers
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_merged_headers_type
    true,                                                 # underline_data_rows
    ExcelPair["style" => "dotted", "color" => "Black"],   # underline_data_rows_type
    true,                                                 # underline_table
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_table_type
    true,                                                 # overline_group
    ExcelPair["style" => "thin", "color" => "Black"],     # overline_group_type
    true,                                                 # underline_group
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_group_type
    true,                                                  # underline_summary_rows
    ExcelPair["style" => "dotted", "color" => "Black"],   # underline_summary_rows_type
    true,                                                 # underline_summary
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_summary_type
    true,                                                 # underline_footnotes
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_footnotes_type
    true,                                                 # vline_after_row_numbers
    ExcelPair["style" => "thin", "color" => "Black"],     # vline_after_row_numbers_type
    true,                                                 # vline_after_row_labels
    ExcelPair["style" => "thin", "color" => "Black"],     # vline_after_row_labels_type
    true,                                                 # vline_between_data_columns
    ExcelPair["style" => "dotted", "color" => "Black"],   # vline_between_data_columns_type
    0.0,                                                  # data_cell_width
    0.0,                                                  # min_data_cell_width
    0.0,                                                  # max_data_cell_width
)

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
    title::Union{Nothing,Vector{ExcelPair}}=nothing
    subtitle::Union{Nothing,Vector{ExcelPair}}=nothing
    row_number_label::Union{Nothing,Vector{ExcelPair}}=nothing
    row_number::Union{Nothing,Vector{ExcelPair}}=nothing
    stubhead_label::Union{Nothing,Vector{ExcelPair}}=nothing
    row_label::Union{Nothing,Vector{ExcelPair}}=nothing
    row_group_label::Union{Nothing,Vector{ExcelPair}}=nothing
    first_line_column_label::Union{Nothing,Vector{ExcelPair}}=nothing
    column_label::Union{Nothing,Vector{ExcelPair}}=nothing
    first_line_merged_column_label::Union{Nothing,Vector{ExcelPair}}=nothing
    merged_column_label::Union{Nothing,Vector{ExcelPair}}=nothing
    table_cell_style::Union{Nothing,Vector{ExcelPair}}=nothing
    summary_row_cell::Union{Nothing,Vector{ExcelPair}}=nothing
    summary_row_label::Union{Nothing,Vector{ExcelPair}}=nothing
    footnote::Union{Nothing,Vector{ExcelPair}}=nothing
    source_note::Union{Nothing,Vector{ExcelPair}}=nothing
end

const DEFAULT_EXCEL_TABLE_STYLE =  ExcelTableStyle(
    push!(_EXCEL__XLARGE_BOLD, "under" => "single"), # title
    _EXCEL__LARGE_ITALIC,                            # subtitle
    _EXCEL__BOLD,                                    # row_number_label
    _EXCEL__BOLD,                                    # row_number
    _EXCEL__BOLD,                                    # stubhead_label
    _EXCEL__BOLD,                                    # row_label
    _EXCEL__BOLD,                                    # row_group_label
    _EXCEL__BOLD,                                    # first_line_column_label
    _EXCEL__BOLD,                                    # column_label
    _EXCEL__MERGED_CELL,                             # first_line_merged_column_label
    _EXCEL__MERGED_CELL,                             # merged_column_label
    _EXCEL__NO_DECORATION,                           # table_cell_style
    _EXCEL__NO_DECORATION,                           # summary_row_cell
    _EXCEL__BOLD,                                    # summary_row_label
    _EXCEL__SMALL,                                   # footnote
    _EXCEL__SMALL_ITALIC_GRAY,                       # source_note
)
