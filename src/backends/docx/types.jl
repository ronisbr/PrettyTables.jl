## Description #############################################################################
#
# Word Back End: Types, structures and constructors.
#
############################################################################################

export DocxPair, DocxHighlighter, DocxTableBorders, DocxTableFormat, DocxTableStyle

############################################################################################
#                                        Constants                                         #
############################################################################################

"""
    DocxPair

Pair `Pair{String, String}` that defines a Word property, used by the fields of
[`DocxTableStyle`](@ref) and [`DocxTableBorders`](@ref) and by the decoration of a
[`DocxHighlighter`](@ref).
"""
const DocxPair = Pair{String, String}

# Create some default table style definitions to reduce allocations.
const _DOCX__NO_DECORATION     = DocxPair[]
const _DOCX__BOLD              = ["bold" => "true"]
const _DOCX__XLARGE_BOLD       = ["size" => "18", "bold" => "true"]
const _DOCX__LARGE_ITALIC      = ["size" => "14", "italic" => "true"]
const _DOCX__SMALL             = ["size" => "10"]
const _DOCX__SMALL_ITALIC_GRAY = ["color" => "808080", "size" => "10", "italic" => "true"]

const _DOCX__MEDIUM_BORDER = ["style" => "single", "size" => "8", "color" => "000000"]
const _DOCX__THICK_BORDER  = ["style" => "single", "size" => "16", "color" => "000000"]
const _DOCX__THIN_BORDER   = ["style" => "single", "size" => "4", "color" => "000000"]

############################################################################################
#                                       Highlighters                                       #
############################################################################################

"""
    struct DocxHighlighter

Define the default highlighter of a table when using the Word back end.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{DocxPair}` with the styling attributes
    to apply to the highlighted cell.

# Remarks

A Word highlighter can be constructed using the following helpers:

```julia
DocxHighlighter(f::Function, decoration::DocxPair)
DocxHighlighter(f::Function, decoration::Vector{DocxPair})
DocxHighlighter(f::Function, fd::Function)
```

The decoration is a flat `Vector{DocxPair}` (same format as the [`DocxTableStyle`](@ref)
fields). Border attributes are not supported in highlighters.

For example, to highlight cells in column 3 with a value greater than 10 in red bold, and
cells with value 0 in green on a light gray background:

```julia
highlighters = [
    DocxHighlighter((data, i, j) -> (j == 3) && (data[i, j] > 10),
        ["color" => "FF0000", "bold" => "true"],
    ),
    DocxHighlighter((data, i, j) -> (data[i, j] ≈ 0.0),
        ["color" => "008000", "background" => "E6E6E6"],
    ),
]
```

The following helpers create the decoration from a `Face` of StyledStrings.jl, converted
with [`docx_decoration`](@ref), from a `Crayon`, converted to the equivalent face, or from
the keywords of `Face` and `Crayon` (see [`Highlighter`](@ref)):

    DocxHighlighter(f::Function, face::Face)

    DocxHighlighter(f::Function, crayon::Crayon)

    DocxHighlighter(f::Function; kwargs...)
"""
struct DocxHighlighter <: AbstractHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Vector{DocxPair}

    # == Constructors ======================================================================

    function DocxHighlighter(f::Function, fd::Function)
        return new(f, fd, DocxPair[])
    end

    function DocxHighlighter(f::Function, decoration::DocxPair)
        return new(f, _docx__default_highlighter_fd, [decoration])
    end

    function DocxHighlighter(f::Function, decoration::Vector{DocxPair})
        return new(f, _docx__default_highlighter_fd, decoration)
    end

    function DocxHighlighter(f::Function, face::Face)
        return DocxHighlighter(f, docx_decoration(face))
    end

    function DocxHighlighter(f::Function, crayon::Crayon)
        return DocxHighlighter(f, _face_from_crayon(crayon))
    end

    function DocxHighlighter(f::Function; kwargs...)
        return DocxHighlighter(f, _face_from_kwargs(; kwargs...))
    end
end

_docx__default_highlighter_fd(h::DocxHighlighter, ::Any, ::Int, ::Int) = h._decoration

############################################################################################
#                                      Table Borders                                       #
############################################################################################

"""
    struct DocxTableBorders

Define the border styles for each line type used when printing a table with the Word back
end. All fields are `Vector{DocxPair}` with the keys `"style"`, `"size"`, and `"color"`
(see [`docx_line_style`](@ref)).

# Fields

## Horizontal Lines

- `top_line::Vector{DocxPair}`: Style for the top border of the table.
    (**Default**: `["style" => "single", "size" => "16", "color" => "000000"]`)
- `header_line::Vector{DocxPair}`: Style for the line drawn under the column label section.
    (**Default**: `["style" => "single", "size" => "8", "color" => "000000"]`)
- `merged_header_cell_line::Vector{DocxPair}`: Style for the line below merged header
    cells.
    (**Default**: `["style" => "single", "size" => "4", "color" => "000000"]`)
- `middle_line::Vector{DocxPair}`: Style for all other internal horizontal lines (data row
    underlines, lines around row groups, lines around summary rows) and for vertical lines
    between data columns.
    (**Default**: `["style" => "single", "size" => "4", "color" => "000000"]`)
- `bottom_line::Vector{DocxPair}`: Style for the bottom border of the table.
    (**Default**: `["style" => "single", "size" => "16", "color" => "000000"]`)

## Vertical Lines

- `left_line::Vector{DocxPair}`: Style for the left border of the table.
    (**Default**: `["style" => "single", "size" => "16", "color" => "000000"]`)
- `center_line::Vector{DocxPair}`: Style for structural vertical lines (after the row
    number column and after the row label column).
    (**Default**: `["style" => "single", "size" => "4", "color" => "000000"]`)
- `right_line::Vector{DocxPair}`: Style for the right border of the table.
    (**Default**: `["style" => "single", "size" => "16", "color" => "000000"]`)
"""
@kwdef struct DocxTableBorders
    # == Horizontal Lines ==================================================================

    top_line::Vector{DocxPair}                = _DOCX__THICK_BORDER
    header_line::Vector{DocxPair}             = _DOCX__MEDIUM_BORDER
    merged_header_cell_line::Vector{DocxPair} = _DOCX__THIN_BORDER
    middle_line::Vector{DocxPair}             = _DOCX__THIN_BORDER
    bottom_line::Vector{DocxPair}             = _DOCX__THICK_BORDER

    # == Vertical Lines ====================================================================

    left_line::Vector{DocxPair}   = _DOCX__THICK_BORDER
    center_line::Vector{DocxPair} = _DOCX__THIN_BORDER
    right_line::Vector{DocxPair}  = _DOCX__THICK_BORDER
end

############################################################################################
#                                       Table Format                                       #
############################################################################################

"""
    struct DocxTableFormat

Define the table borders that will be used to form the Word table.

# Fields

- `borders::DocxTableBorders`: Border style configuration for all line types.
- `horizontal_line_at_beginning::Bool`: Whether to draw a horizontal line at the first
    table row after the title/subtitle section (i.e., the top of the column labels or the
    first data row if there are no column labels). Title and subtitle rows are never
    bordered.
- `horizontal_line_after_column_labels::Bool`: Whether to draw a line under the column
    header section.
- `horizontal_line_between_column_labels::Bool`: Whether to draw a line between (unmerged)
    column header rows.
- `horizontal_line_at_merged_column_labels::Bool`: Whether to draw a line under merged
    column headers.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: Controls which data rows get
    an underline. `:all` draws a line after every data row; `:none` draws none; a
    `Vector{Int}` draws a line only after the listed row indices.
- `horizontal_line_after_data_rows::Bool`: Whether to draw a line under the data table
    section.
- `horizontal_line_before_row_group_label::Bool`: Whether to draw a line above each row
    group divider.
- `horizontal_line_after_row_group_label::Bool`: Whether to draw a line below each row
    group divider.
- `horizontal_line_before_summary_rows::Bool`: Whether to draw a line between the data rows
    and the summary rows.
- `horizontal_line_after_summary_rows::Bool`: Whether to draw a line under the last summary
    row.
- `vertical_line_at_beginning::Bool`: Whether to draw a vertical line at the left side of
    the table (spanning only the content rows, not title/subtitle or footnotes).
- `vertical_line_after_row_number_column::Bool`: Whether to draw a vertical line to the
    right of the row number column.
- `vertical_line_after_row_label_column::Bool`: Whether to draw a vertical line to the
    right of the row label column.
- `vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: Controls which data columns
    get a right-side divider. `:all` draws after every data column; `:none` draws none; a
    `Vector{Int}` draws only after the listed column indices.
- `vertical_line_after_data_columns::Bool`: Whether to draw a vertical line after the last
    data column (spanning only the content rows, not title/subtitle or footnotes).
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be drawn
    after the continuation column.
- `cell_margins::NTuple{4, Float64}`: Margins of every cell in points, in the order top,
    left, bottom, and right. Notice that Word renders a cell without margins with the text
    touching the borders.
- `repeat_header_rows_at_page_breaks::Bool`: If `true`, the rows above the data (title,
    subtitle, and column labels) are marked as table header rows, meaning that Word repeats
    them at every page break.
"""
@kwdef struct DocxTableFormat
    borders::DocxTableBorders = DocxTableBorders()

    # == Configuration for the Horizontal and Vertical Lines ===============================

    horizontal_line_at_beginning::Bool = true
    horizontal_line_after_column_labels::Bool = true
    horizontal_line_between_column_labels::Bool = false
    horizontal_line_at_merged_column_labels::Bool = true
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_after_data_rows::Bool = true
    horizontal_line_before_row_group_label::Bool = true
    horizontal_line_after_row_group_label::Bool = true
    horizontal_line_before_summary_rows::Bool = true
    horizontal_line_after_summary_rows::Bool = true

    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
    vertical_line_after_data_columns::Bool = true
    vertical_line_after_continuation_column::Bool = true

    # == Word Specific Configuration =======================================================

    cell_margins::NTuple{4, Float64} = (2.0, 5.0, 2.0, 5.0)
    repeat_header_rows_at_page_breaks::Bool = true
end

############################################################################################
#                                       Table Style                                        #
############################################################################################

"""
    struct DocxTableStyle

Define the style (text and cell attributes) of each of the table elements used with the Word
back end.

# Fields

- `title::Vector{DocxPair}`: Style for the title.
- `subtitle::Vector{DocxPair}`: Style for the subtitle.
- `row_number_label::Vector{DocxPair}`: Style for the row number label.
- `row_number::Vector{DocxPair}`: Style for the row number.
- `stubhead_label::Vector{DocxPair}`: Style for the stubhead label.
- `row_label::Vector{DocxPair}`: Style for the row label.
- `row_group_label::Vector{DocxPair}`: Style for the row group label.
- `first_line_column_label::Union{Vector{DocxPair}, Vector{Vector{DocxPair}}}`: Style for
    the first line of the column labels. If a vector of `Vector{DocxPair}` is provided,
    each column label in the first line will use the corresponding style.
- `column_label::Union{Vector{DocxPair}, Vector{Vector{DocxPair}}}`: Style for the rest of
    the column labels. If a vector of `Vector{DocxPair}` is provided, each column label
    will use the corresponding style.
- `first_line_merged_column_label::Vector{DocxPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{DocxPair}`: Style for the merged cells at the rest of the
    column labels.
- `data_cell::Vector{DocxPair}`: Style for the table cells.
- `summary_row_label::Vector{DocxPair}`: Style for the summary row label.
- `summary_row_cell::Vector{DocxPair}`: Style for the summary row cell.
- `footnote::Vector{DocxPair}`: Style for the footnotes.
- `source_note::Vector{DocxPair}`: Style for the source notes.

# Remarks

Each field corresponds to a table element and should be a vector of `DocxPair`, *i.e.*
`Pair{String, String}`, with the following keys:

| Key            | Value                                                                     |
|:---------------|:--------------------------------------------------------------------------|
| `"bold"`       | `"true"` or `"false"`.                                                    |
| `"italic"`     | `"true"` or `"false"`.                                                    |
| `"strike"`     | `"true"` or `"false"`.                                                    |
| `"underline"`  | A `WriteDocx.UnderlinePattern`, *e.g.* `"single"`, `"double"`, or `"wave"`. |
| `"color"`      | Text color as a 6-digit hexadecimal string, *e.g.* `"FF0000"`.            |
| `"background"` | Cell background as a 6-digit hexadecimal string.                          |
| `"font"`       | Font name, *e.g.* `"Palatino"`.                                           |
| `"size"`       | Font size in points, *e.g.* `"14"`.                                       |

It is only necessary to define those fields for which the default style needs to be
overwritten. For example:

# Examples

```julia
style = DocxTableStyle(
    column_label      = [["bold" => "true"], ["color" => "FF0000"]], # assuming two columns
    summary_row_label = ["size" => "8"],
    footnote          = ["italic" => "true", "color" => "00FFFF"],
    row_group_label   = ["bold" => "true", "background" => "EEEEEE"],
    title             = ["bold" => "true", "color" => "FFA500", "size" => "18"],
)
```

# Constructor

    DocxTableStyle(; kwargs...)

Create a style in which each field can be passed as a keyword. Every keyword also accepts a
`Face` (or a `Crayon`, converted to the equivalent face), which is converted with
[`docx_decoration`](@ref). The keywords `first_line_column_label` and `column_label` also
accept a vector with one decoration (Word attributes or `Face`) per column.
"""
struct DocxTableStyle{
    TFCL <: Union{Vector{DocxPair}, Vector{Vector{DocxPair}}},
    TCL <: Union{Vector{DocxPair}, Vector{Vector{DocxPair}}},
}
    title::Vector{DocxPair}
    subtitle::Vector{DocxPair}
    row_number_label::Vector{DocxPair}
    row_number::Vector{DocxPair}
    stubhead_label::Vector{DocxPair}
    row_label::Vector{DocxPair}
    row_group_label::Vector{DocxPair}
    first_line_column_label::TFCL
    column_label::TCL
    first_line_merged_column_label::Vector{DocxPair}
    merged_column_label::Vector{DocxPair}
    data_cell::Vector{DocxPair}
    summary_row_label::Vector{DocxPair}
    summary_row_cell::Vector{DocxPair}
    footnote::Vector{DocxPair}
    source_note::Vector{DocxPair}
end

function DocxTableStyle(;
    title                          = _DOCX__XLARGE_BOLD,
    subtitle                       = _DOCX__LARGE_ITALIC,
    row_number_label               = _DOCX__BOLD,
    row_number                     = _DOCX__BOLD,
    stubhead_label                 = _DOCX__BOLD,
    row_label                      = _DOCX__BOLD,
    row_group_label                = _DOCX__BOLD,
    first_line_column_label        = _DOCX__BOLD,
    column_label                   = _DOCX__NO_DECORATION,
    first_line_merged_column_label = _DOCX__BOLD,
    merged_column_label            = _DOCX__NO_DECORATION,
    data_cell                      = _DOCX__NO_DECORATION,
    summary_row_label              = _DOCX__BOLD,
    summary_row_cell               = _DOCX__NO_DECORATION,
    footnote                       = _DOCX__SMALL,
    source_note                    = _DOCX__SMALL_ITALIC_GRAY,
)
    return DocxTableStyle(
        _docx__decoration(title),
        _docx__decoration(subtitle),
        _docx__decoration(row_number_label),
        _docx__decoration(row_number),
        _docx__decoration(stubhead_label),
        _docx__decoration(row_label),
        _docx__decoration(row_group_label),
        _docx__column_label_decoration(first_line_column_label),
        _docx__column_label_decoration(column_label),
        _docx__decoration(first_line_merged_column_label),
        _docx__decoration(merged_column_label),
        _docx__decoration(data_cell),
        _docx__decoration(summary_row_label),
        _docx__decoration(summary_row_cell),
        _docx__decoration(footnote),
        _docx__decoration(source_note),
    )
end
