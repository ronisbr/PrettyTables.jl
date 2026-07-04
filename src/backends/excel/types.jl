## Description #############################################################################
#
# Excel Back End: Types, structures and constructors.
#
############################################################################################

export ExcelPair, ExcelHighlighter, ExcelTableBorders, ExcelTableFormat, ExcelTableStyle
export ExcelFormatter

############################################################################################
#                                       Constants                                          #
############################################################################################

# Pair that defines Excel properties.
const ExcelPair = Pair{String, String}

# Create some default table style definitions to reduce allocations.
const _EXCEL__NO_DECORATION     = ExcelPair[]
const _EXCEL__BOLD              = ["bold"   => "true"]
const _EXCEL__ITALIC            = ["italic" => "true"]
const _EXCEL__XLARGE_BOLD       = ["size"   => "18", "bold"   => "true"]
const _EXCEL__LARGE_ITALIC      = ["size"   => "14", "italic" => "true"]
const _EXCEL__SMALL             = ["size"   => "10"]
const _EXCEL__SMALL_ITALIC      = ["size"   => "10", "italic" => "true"]
const _EXCEL__SMALL_ITALIC_GRAY = ["color"  => "gray", "size" => "10", "italic" => "true"]

const _EXCEL__MEDIUM_BORDER     = ["style" => "medium", "color" => "Black"]
const _EXCEL__THICK_BORDER      = ["style" => "thick",  "color" => "Black"]
const _EXCEL__THIN_BORDER       = ["style" => "thin",   "color" => "Black"]

############################################################################################
#                                       Highlighters                                       #
############################################################################################

"""
    struct ExcelHighlighter

Define the default highlighter of a table when using the Excel back end.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{ExcelPair}` with the styling attributes
    to apply to the highlighted cell.
- `_decoration::Vector{ExcelPair}`: The decoration applied when the default `fd` is used.

# Remarks

An Excel highlighter can be constructed using the following helpers:

```julia
ExcelHighlighter(f::Function, decoration::ExcelPair)
ExcelHighlighter(f::Function, decoration::Vector{ExcelPair})
ExcelHighlighter(f::Function, fd::Function)
```

The decoration is a flat `Vector{ExcelPair}` (same format as `ExcelTableStyle` fields).
Font attributes are passed directly; fill attributes use the `"cell_fill_"` key prefix
(the prefix is stripped before calling `XLSX.setFill`). Border attributes are not
supported in highlighters.

For example, to highlight cells in column 3 with a value greater than 10 in red bold, cells
with value 0 in green with a solid fill, and cells in column 4 greated than 10 in blue:

```julia
highlighters = [
    ExcelHighlighter((data, i, j) -> (j == 3) && (data[i, j] > 10), [
        "color" => "red", "bold" => "true",
        "cell_fill_pattern" => "solid", "cell_fill_fgColor" => "grey90",
    ]),
    ExcelHighlighter((data, i, j) -> (data[i, j] ≈ 0.0),
        ["color" => "green", "bold" => "true"],
    ),
    ExcelHighlighter((data, i, j) -> (j == 4) && (data[i, j] > 10),
        ["color" => "blue", "bold" => "true"],
    ),
]
```
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
        return new(f, _excel__default_highlighter_fd, [decoration])
    end

    function ExcelHighlighter(f::Function, decoration::Vector{ExcelPair})
        return new(f, _excel__default_highlighter_fd, decoration)
    end
end

_excel__default_highlighter_fd(h::ExcelHighlighter, ::Any, ::Int, ::Int) = h._decoration

############################################################################################
#                                       Formatters                                         #
############################################################################################

"""
    struct ExcelFormatter

Define the Excel format to apply to a cell.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true`
  if the element `(i, j)` in `data` must be formatted, or `false` otherwise. The first
  argument is the entire data matrix passed to `pretty_table`, allowing `data[i, j]` to be
  inspected inside the predicate.
- `numFmt::ExcelPair`: Specifies the format to apply to the cell. The format should be
  specified with an `ExcelPair` (*i.e.* `Pair{String, String}`) using the `XLSX.jl`
  formatting definitions used by the `XLSX.setFormat` function.
- `region::Symbol`: Region of the table in which the formatter is applied. It can be
  `:data` or `:summary_row`. If it is `:data`, the formatter is applied to the data cells
  and the value of `i` passed to `f` is the **data row** index. If it is `:summary_row`,
  the formatter is applied to the summary row cells and the value of `i` passed to `f` is
  the **summary row** index (*i.e.* `1` for the first summary row, `2` for the second, and
  so on).

# Constructors

```julia
ExcelFormatter(f::Function, numFmt::Vector{ExcelPair}; region::Symbol = :data)
```

The keyword `region` defaults to `:data`, so the formatter matches data cells based on the
data row index unless `:summary_row` is explicitly requested.

# Remarks

It is possible to apply a set of native Excel formats by passing a `Vector{ExcelFormatter}`
to the `excel_formatters` keyword. Each Excel formatter is an instance of the structure
[`ExcelFormatter`](@ref).

The first formatter (in the order they are specified) that satisfies the specified condition
in the given table cell is applied, and the remainder of the formatters in the list are
skipped. If none matches, no `ExcelFormatter` is applied.

An `ExcelFormatter` can be applied in the summary row, too. In this case, set `region` to
`:summary_row`. The value of `i` passed to `f` then relates to the summary row index (`1`
for the first summary row, `2` for the second, and so on), rather than the data table row.
The value of `j` has the same meaning/values (column specifier) as in the data table
itself.

Excel formatters may be applied in addition to the standard formatters. The standard
formatters control the literal values written to Excel while the Excel formatters control
how Excel displays the literal cell values.

For example, to apply Excel-native formatting to different columns of a table:

```julia
excel_formatters = [
    ExcelFormatter((data, i, j) -> (j==1), ["format" => "#,##0_0_0"])
    ExcelFormatter((data, i, j) -> (j==2), ["format" => "#,##0.??_0_0"])
    ExcelFormatter((data, i, j) -> (j==3), ["format" => "#,##0.???"])
    ExcelFormatter((data, i, j) -> (j==4), ["format" => "0_0_0_0"])
]
```

Excel formatters apply native Excel formatting to native Excel values. However,
`PrettyTables,jl`can handle Julia types that can't be represented natively in Excel. If
these are passed natively, then XLSX.jl will fail. To circumvent this, a predefined
formatter has been provided which converts any unhandled types to strings (using
`string()`). For more information, see [`fmt__excel_stringify`](@ref).
"""
struct ExcelFormatter
    f::Function
    numFmt::Vector{ExcelPair}
    region::Symbol

    # == Constructors ======================================================================

    function ExcelFormatter(
        f::Function,
        numFmt::Vector{ExcelPair};
        region::Symbol = :data
    )
        region ∈ (:data, :summary_row) || throw(ArgumentError(
            "The `region` of an `ExcelFormatter` must be `:data` or `:summary_row`."
        ))

        return new(f, numFmt, region)
    end
end

############################################################################################
#                                      Table Borders                                       #
############################################################################################

"""
    struct ExcelTableBorders

Define the border styles for each line type used when printing a table with the Excel back
end. All fields are `Vector{ExcelPair}` compatible with the `XLSX.setBorder` function.

# Fields

## Horizontal Lines

- `top_line::Vector{ExcelPair}`: Style for the top border of the table.
    (**Default**: `["style" => "thick", "color" => "Black"]`)
- `header_line::Vector{ExcelPair}`: Style for the line drawn under the column label
    section.
    (**Default**: `["style" => "medium", "color" => "Black"]`)
- `merged_header_cell_line::Vector{ExcelPair}`: Style for the line below merged header
    cells.
    (**Default**: `["style" => "thin", "color" => "Black"]`)
- `middle_line::Vector{ExcelPair}`: Style for all other internal horizontal lines (data
    row underlines, lines around row groups, lines around summary rows) and for vertical
    lines between data columns.
    (**Default**: `["style" => "thin", "color" => "Black"]`)
- `bottom_line::Vector{ExcelPair}`: Style for the bottom border of the table.
    (**Default**: `["style" => "thick", "color" => "Black"]`)

## Vertical Lines

- `left_line::Vector{ExcelPair}`: Style for the left border of the table.
    (**Default**: `["style" => "thick", "color" => "Black"]`)
- `center_line::Vector{ExcelPair}`: Style for structural vertical lines (after the row
    number column and after the row label column).
    (**Default**: `["style" => "thin", "color" => "Black"]`)
- `right_line::Vector{ExcelPair}`: Style for the right border of the table.
    (**Default**: `["style" => "thick", "color" => "Black"]`)
"""
@kwdef struct ExcelTableBorders
    # == Horizontal Lines ==================================================================

    top_line::Vector{ExcelPair}                = _EXCEL__THICK_BORDER
    header_line::Vector{ExcelPair}             = _EXCEL__MEDIUM_BORDER
    merged_header_cell_line::Vector{ExcelPair} = _EXCEL__THIN_BORDER
    middle_line::Vector{ExcelPair}             = _EXCEL__THIN_BORDER
    bottom_line::Vector{ExcelPair}             = _EXCEL__THICK_BORDER

    # == Vertical Lines ====================================================================

    left_line::Vector{ExcelPair}               = _EXCEL__THICK_BORDER
    center_line::Vector{ExcelPair}             = _EXCEL__THIN_BORDER
    right_line::Vector{ExcelPair}              = _EXCEL__THICK_BORDER
end

############################################################################################
#                                       Table Format                                       #
############################################################################################

"""
    struct ExcelTableFormat

Define the table borders that will be used to form the Excel table.

# Fields

- `borders::ExcelTableBorders`: Border style configuration for all line types.
- `horizontal_line_at_beginning::Bool`: Whether to draw a horizontal line at the first
    table row after the title/subtitle section (i.e., the top of the column labels or
    the first data row if there are no column labels). Title and subtitle rows are never
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
- `horizontal_line_before_summary_rows::Bool`: Whether to draw a line under each summary
    row (between multiple summary rows).
- `horizontal_line_after_summary_rows::Bool`: Whether to draw a line under the last
    summary row.
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
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.
"""
@kwdef struct ExcelTableFormat
    borders::ExcelTableBorders = ExcelTableBorders()

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
end

############################################################################################
#                                       Table Style                                        #
############################################################################################

"""
    struct ExcelTableStyle

Define the style (font and cell attributes) of each of the table elements used with the
Excel back end.

# Fields

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
- `data_cell::Vector{ExcelPair}`: Style for the table cells. If a vector of
    `Vector{ExcelPair}}` is provided, each column in the data table will use the
    corresponding style.
- `summary_row_label::Vector{ExcelPair}`: Style for the summary row label.
- `summary_row_cell::Vector{ExcelPair}`: Style for the summary row cell. If a vector of
    `Vector{ExcelPair}}` is provided, each column in the summary row will use the
    corresponding style.
- `footnote::Vector{ExcelPair}`: Style for the footnotes.
- `source_note::Vector{ExcelPair}`: Style for the source notes.

# Remarks

Each field corresponds to a table element and should be a vector of `ExcelPair`, *i.e.*
`Pair{String, String}`, describing properties and values compatible with the `XLSX.setFont`
function. We can also defined properties to be applied to the cell itself with the function
`XLSX.setFill`. In this case, prefix the parameter name with `"cell_fill_"` (e.g.,
`"cell_fill_pattern" => "solid"`).

It is only necessary to define those fields for which the default style needs to be
overwritten. For example:

# Examples

```julia
style = ExcelTableStyle(
    column_label                   = [["bold" => "true"], ["color" => "red"]], # assuming two columns
    summary_row_label              = ["size" => "8"],
    first_line_merged_column_label = ["bold" => "true", "color" => "orange"],
    footnote                       = ["italic" => "true", "color" => "cyan"],
    row_group_label                = ["bold" => "true", "color" => "magenta"],
    subtitle                       = ["italic" => "true"],
    title                          = ["bold" => "true", "color" => "orange", "size" => "18", "under" => "single"],
)
```
"""
@kwdef struct ExcelTableStyle{
    TFCL <: Union{Vector{ExcelPair}, Vector{Vector{ExcelPair}}},
    TCL <: Union{Vector{ExcelPair}, Vector{Vector{ExcelPair}}},
}
    title::Vector{ExcelPair}                          = _EXCEL__XLARGE_BOLD
    subtitle::Vector{ExcelPair}                       = _EXCEL__LARGE_ITALIC
    row_number_label::Vector{ExcelPair}               = _EXCEL__BOLD
    row_number::Vector{ExcelPair}                     = _EXCEL__BOLD
    stubhead_label::Vector{ExcelPair}                 = _EXCEL__BOLD
    row_label::Vector{ExcelPair}                      = _EXCEL__BOLD
    row_group_label::Vector{ExcelPair}                = _EXCEL__BOLD
    first_line_column_label::TFCL                     = _EXCEL__BOLD
    column_label::TCL                                 = _EXCEL__NO_DECORATION
    first_line_merged_column_label::Vector{ExcelPair} = _EXCEL__BOLD
    merged_column_label::Vector{ExcelPair}            = _EXCEL__NO_DECORATION
    data_cell::Vector{ExcelPair}                      = _EXCEL__NO_DECORATION
    summary_row_label::Vector{ExcelPair}              = _EXCEL__BOLD
    summary_row_cell::Vector{ExcelPair}               = _EXCEL__NO_DECORATION
    footnote::Vector{ExcelPair}                       = _EXCEL__SMALL
    source_note::Vector{ExcelPair}                    = _EXCEL__SMALL_ITALIC_GRAY
end
