## Description #############################################################################
#
# Excel Back End: Types, structures and constructors.
#
############################################################################################

export ExcelPair, ExcelHighlighter, ExcelTableBorders, ExcelTableFormat, ExcelTableStyle, ExcelFormatter
export DEFAULT_EXCEL_TABLE_FORMAT, DEFAULT_EXCEL_TABLE_STYLE
export EXCEL_FORMAT_NO_VLINES, EXCEL_FORMAT_CELL_LINES, EXCEL_FORMAT_SECTION_LINES

############################################################################################
#                                       Constants                                          #
############################################################################################

# Pair that defines Excel properties.
const ExcelPair = Pair{String, String}

# Create some default table style definitions to reduce allocations.
const _EXCEL__NO_DECORATION = ExcelPair[]
const _EXCEL__BOLD = ["bold" => "true"]
const _EXCEL__NAME = ["name" => "Calibri"]
const _EXCEL__ITALIC = ["italic" => "true"]
const _EXCEL__XLARGE_BOLD = ["size" => "18", "bold" => "true"]
const _EXCEL__LARGE_ITALIC = ["size" => "14", "italic" => "true"]
const _EXCEL__SMALL = ["size" => "10"]
const _EXCEL__SMALL_ITALIC = ["size" => "10", "italic" => "true"]
const _EXCEL__SMALL_ITALIC_GRAY = ["color" => "gray", "size" => "10", "italic" => "true"]
#const _EXCEL__MERGED_CELL = ["color" => "black"]

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

For example, to highlight cells in column 3 with a value greater than 10 in red bold,
cells with value 0 in green with a solid fill, and cells in column 4 > 10 in blue:

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

- `f::Function`: Function with the signature `f(value, i, j)` which should return `true` 
  if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `numFmt::ExcelPair`: Specifies the format to apply to the cell. The format should be 
  specified with an `ExcelPair` (*i.e.* `Pair{String, String}`) using the `XLSX.jl` 
  formatting definitions used by the `XLSX.setFormat` function.

# Remarks

It is possible to apply a set of native Excel formats by passing a `Vector{ExcelFormatter}` 
to the `excel_formatters` keyword. Each Excel formatter is an instance of the structure 
[`ExcelFormatter`](@ref).

The first formatter (in the order they are specified) that satisfies the specified condition 
in the given table cell is applied, and the remainder of the formatters in the list are 
skipped. If none matches, no `ExcelFormatter` is applied.

An `ExcelFormatter` can be applied in the summary row, too. In this case, the value of `i` 
should relate to the Excel row in which the summary row appears, rather than the data table 
row. This will always be outside the range of (greater than) any `i` in the data table. The
value of `j` has the same meaning/values (column specifier) as in the data table itself.

Excel formatters may be applied in addition to the standard formatters. The standard 
formatters control the literal values written to Excel while the Excel formatters control 
how Excel displays the literal cell values.

For example, to apply Excel-native formatting to different columns of a table:

```julia
excel_formatters = [
    ExcelFormatter((v, i, j) -> (j==1), ["format" => "#,##0_0_0"])
    ExcelFormatter((v, i, j) -> (j==2), ["format" => "#,##0.??_0_0"])
    ExcelFormatter((v, i, j) -> (j==3), ["format" => "#,##0.???"])
    ExcelFormatter((v, i, j) -> (j==4), ["format" => "0_0_0_0"])
]
```

Excel formatters apply native Excel formatting to native Excel values. 
However, `PrettyTables,jl`can handle Julia types that can't be represented 
natively in Excel. If these are passed natively, then XLSX.jl will fail. 
To circumvent this, a predefined formatter has been provided which converts 
any unhandled types to strings (using `string()`). For more information, see 
[`fmt__excel_stringify`](@ref).

"""
struct ExcelFormatter
    f::Function
    numFmt::Vector{ExcelPair}
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
- `header_line::Vector{ExcelPair}`: Style for section-separating horizontal lines (title
    underline, header underline, group over/underlines, summary underline, footnote
    underline, table underline).
    (**Default**: `["style" => "thin", "color" => "Black"]`)
- `merged_header_cell_line::Vector{ExcelPair}`: Style for the line below merged header
    cells.
    (**Default**: `["style" => "thin", "color" => "Black"]`)
- `middle_line::Vector{ExcelPair}`: Style for within-section horizontal lines (data row
    underlines, summary row underlines, between-header lines) and for vertical lines between
    data columns.
    (**Default**: `["style" => "dotted", "color" => "Black"]`)
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

    top_line::Vector{ExcelPair}                = ExcelPair["style" => "thick",  "color" => "Black"]
    header_line::Vector{ExcelPair}             = ExcelPair["style" => "thin",   "color" => "Black"]
    merged_header_cell_line::Vector{ExcelPair} = ExcelPair["style" => "thin",   "color" => "Black"]
    middle_line::Vector{ExcelPair}             = ExcelPair["style" => "dotted", "color" => "Black"]
    bottom_line::Vector{ExcelPair}             = ExcelPair["style" => "thick",  "color" => "Black"]

    # == Vertical Lines ====================================================================

    left_line::Vector{ExcelPair}               = ExcelPair["style" => "thick",  "color" => "Black"]
    center_line::Vector{ExcelPair}             = ExcelPair["style" => "thin",   "color" => "Black"]
    right_line::Vector{ExcelPair}              = ExcelPair["style" => "thick",  "color" => "Black"]
end

############################################################################################
#                                       Table Format                                       #
############################################################################################
#        1         2         3         4         5         6         7         8         9
#2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

"""
    struct ExcelTableFormat

Define the table borders that will be used to form the Excel table.

# Fields

- `borders::ExcelTableBorders`: Border style configuration for all line types.
- `outside_border::Bool`: Whether to draw a border around the entire table.
- `underline_title::Union{Nothing,Bool}`: Whether to draw a line under the title/subtitle
    section.
- `underline_headers::Union{Nothing,Bool}`: Whether to draw a line under the column header
    section.
- `underline_between_headers::Union{Nothing,Bool}`: Whether to draw a line between
    (unmerged) column header rows.
- `underline_merged_headers::Union{Nothing,Bool}`: Whether to draw a line under merged
    column headers.
- `underline_data_rows::Union{Nothing,Bool}`: Whether to draw a line under each data row.
- `underline_table::Union{Nothing,Bool}`: Whether to draw a line under the data table
    section.
- `overline_group::Union{Nothing,Bool}`: Whether to draw a line above each row group
    divider.
- `underline_group::Union{Nothing,Bool}`: Whether to draw a line below each row group
    divider.
- `underline_summary_rows::Union{Nothing,Bool}`: Whether to draw a line under each summary
    row (between multiple summary rows).
- `underline_summary::Union{Nothing,Bool}`: Whether to draw a line under the last summary
    row.
- `underline_footnotes::Union{Nothing,Bool}`: Whether to draw a line under the footnotes
    section.
- `vline_after_row_numbers::Union{Nothing,Bool}`: Whether to draw a vertical line to the
    right of the row number column.
- `vline_after_row_labels::Union{Nothing,Bool}`: Whether to draw a vertical line to the
    right of the row label column.
- `vline_between_data_columns::Union{Nothing,Bool}`: Whether to draw vertical lines
    between data columns.

# Remarks

Border placement is controlled by the boolean fields above. Border styles (line thickness,
color) are configured via the `borders::ExcelTableBorders` field. The `underline` and
`overline` fields specify the bottom and top cell borders respectively; `vline` fields
specify right-hand-side borders.

The `underline_title` border is drawn under the subtitle row (if provided) or under the
title row when there is no subtitle.

Four predefined formats are provided:
- `DEFAULT_EXCEL_TABLE_FORMAT`: All borders enabled; outside border is thick, section
    separators are thin, and within-section lines are dotted.
- `EXCEL_FORMAT_NO_VLINES`: No vertical lines.
- `EXCEL_FORMAT_NO_CELL_LINES`: No borders between individual data cells (no data row
    underlines, no column dividers).
- `EXCEL_FORMAT_SECTION_LINES`: Only section-level horizontal borders and one vertical
    line after the row label column.

To customize border styles, pass an `ExcelTableBorders` object. For example, to draw all
section-separator lines in red:

```julia
table_format = ExcelTableFormat(
    borders = ExcelTableBorders(header_line = ["style" => "thin", "color" => "red"]),
)
```

Predefined formats can be combined and extended:

```julia
table_format = ExcelTableFormat(
    EXCEL_FORMAT_SECTION_LINES;
    borders = ExcelTableBorders(
        header_line = ["style" => "thick", "color" => "red"],
        middle_line = ["style" => "thick", "color" => "red"],
    ),
)
```

"""
@kwdef struct ExcelTableFormat
    borders::ExcelTableBorders          = ExcelTableBorders()
    outside_border::Bool                = true
    underline_title::Union{Nothing, Bool} = nothing
    underline_headers::Union{Nothing, Bool} = nothing
    underline_between_headers::Union{Nothing, Bool} = nothing
    underline_merged_headers::Union{Nothing, Bool} = nothing
    underline_data_rows::Union{Nothing, Bool} = nothing
    underline_table::Union{Nothing, Bool} = nothing
    overline_group::Union{Nothing, Bool} = nothing
    underline_group::Union{Nothing, Bool} = nothing
    underline_summary_rows::Union{Nothing, Bool} = nothing
    underline_summary::Union{Nothing, Bool} = nothing
    underline_footnotes::Union{Nothing, Bool} = nothing
    vline_after_row_numbers::Union{Nothing, Bool} = nothing
    vline_after_row_labels::Union{Nothing, Bool} = nothing
    vline_between_data_columns::Union{Nothing, Bool} = nothing
end

const DEFAULT_EXCEL_TABLE_FORMAT = ExcelTableFormat(
    ExcelTableBorders(), # borders
    true,                # outside_border
    true,                # underline_title
    true,                # underline_headers
    true,                # underline_between_headers
    true,                # underline_merged_headers
    true,                # underline_data_rows
    true,                # underline_table
    true,                # overline_group
    true,                # underline_group
    true,                # underline_summary_rows
    true,                # underline_summary
    true,                # underline_footnotes
    true,                # vline_after_row_numbers
    true,                # vline_after_row_labels
    true,                # vline_between_data_columns
)

const EXCEL_FORMAT_NO_VLINES = ExcelTableFormat(
    vline_after_row_numbers = false,
    vline_after_row_labels = false,
    vline_between_data_columns = false,
)

const EXCEL_FORMAT_NO_CELL_LINES = ExcelTableFormat(
    underline_data_rows = false,
    vline_between_data_columns = false,
)

const EXCEL_FORMAT_SECTION_LINES = ExcelTableFormat(
    underline_data_rows = false,
    overline_group = false,
    underline_group = false,
    underline_summary_rows = false,
    vline_between_data_columns = false,
    vline_after_row_numbers = false,
)

function _excel__format_merge(a::ExcelTableFormat, b::ExcelTableFormat)
    # `borders` is never `nothing`, so we use equality with the zero-kwarg default to detect
    # "not explicitly set" — only override `a.borders` when `b` was given a custom value.
    merged_borders = b.borders == ExcelTableBorders() ? a.borders : b.borders
    return ExcelTableFormat(;
        borders = merged_borders,
        (name => (getfield(b, name) === nothing ?
                  getfield(a, name) :
                  getfield(b, name))
         for name in fieldnames(ExcelTableFormat) if name != :borders
        )...
    )
end

"""
  ExcelTableFormat(presets::ExcelTableFormat...; kwargs...)

Create an `ExcelTableFormat` object by merging one or more predefined table formats 
and then modifying the resulting format with any keyword arguments.

When merging, the predefined table formats are applied in order, with later formats 
taking precedence over earlier ones. Finally, any keyword arguments provided will 
take precedence over all predefined formats.

Example usage:

```julia
table_format = ExcelTableFormat(
    EXCEL_FORMAT_SECTION_LINES,
    EXCEL_FORMAT_NO_VLINES;
    overline_group = true,
    underline_group = true,
)
```

"""
function ExcelTableFormat(presets::ExcelTableFormat...; kwargs...)
    # Start from the default instance
    fmt = ExcelTableFormat()

    # Merge all presets in order
    for p in presets
        fmt = _excel__format_merge(fmt, p)
    end

    # Apply keyword overrides last
    return _excel__format_merge(fmt, ExcelTableFormat(; kwargs...))
end


############################################################################################
#                                       Table Style                                        #
############################################################################################

"""
    struct ExcelTableStyle

Define the style (font attributes) of each of the table elements used with the 
Excel back end.

# Fields

- `title::Union{Nothing,Vector{ExcelPair}}`: Style for the title.
- `subtitle::Union{Nothing,Vector{ExcelPair}}`: Style for the subtitle.
- `row_number_label::Union{Nothing,Vector{ExcelPair}}`: Style for the row number label.
- `row_number::Union{Nothing,Vector{ExcelPair}}`: Style for the row number.
- `stubhead_label::Union{Nothing,Vector{ExcelPair}}`: Style for the stubhead label.
- `row_label::Union{Nothing,Vector{ExcelPair}}`: Style for the row label.
- `row_group_label::Union{Nothing,Vector{ExcelPair}}`: Style for the row group label.
- `first_line_column_label::Union{Nothing,Vector{ExcelPair},Vector{Vector{ExcelPair}}}`: 
  Style for the first line of the column labels. If a vector of `Vector{ExcelPair}}` is 
  provided, each column label in the first line will use the corresponding style.
- `column_label::Union{Nothing,Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Style for 
  the rest of the column labels. If a vector of `Vector{ExcelPair}}` is provided, each 
  column label will use the corresponding style.
- `first_line_merged_column_label::Union{Nothing,Vector{ExcelPair}}`: Style for the 
  merged cells at the first column label line.
- `merged_column_label::Union{Nothing,Vector{ExcelPair}}`: Style for the merged cells 
  at the rest of the column labels.
- `table_cell::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Style 
  for the table cells. If a vector of `Vector{ExcelPair}}` is provided, each 
  column in the data table will use the corresponding style.
- `summary_row_label::Union{Nothing,Vector{ExcelPair}}`: Style for the summary row label.
- `summary_row_cell::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Style 
  for the summary row cell. If a vector of `Vector{ExcelPair}}` is provided, each column 
  in the summary row will use the corresponding style.
- `footnote::Union{Nothing,Vector{ExcelPair}}`: Style for the footnotes.
- `source_note::Union{Nothing,Vector{ExcelPair}}`: Style for the source notes.

# Remarks

Each field corresponds to a table element and should be a vector of `ExcelPair`, 
*i.e.* `Pair{String, String}`, describing properties and values compatible with the 
`XLSX.setFont` function.

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
@kwdef struct ExcelTableStyle
    title::Union{Nothing, Vector{ExcelPair}} = nothing
    subtitle::Union{Nothing, Vector{ExcelPair}} = nothing
    row_number_label::Union{Nothing, Vector{ExcelPair}} = nothing
    row_number::Union{Nothing, Vector{ExcelPair}} = nothing
    stubhead_label::Union{Nothing, Vector{ExcelPair}} = nothing
    row_label::Union{Nothing, Vector{ExcelPair}} = nothing
    row_group_label::Union{Nothing, Vector{ExcelPair}} = nothing
    first_line_column_label::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}} = nothing
    column_label::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}} = nothing
    first_line_merged_column_label::Union{Nothing, Vector{ExcelPair}} = nothing
    merged_column_label::Union{Nothing, Vector{ExcelPair}} = nothing
    table_cell::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}} = nothing
    summary_row_label::Union{Nothing, Vector{ExcelPair}} = nothing
    summary_row_cell::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}} = nothing
    footnote::Union{Nothing, Vector{ExcelPair}} = nothing
    source_note::Union{Nothing, Vector{ExcelPair}} = nothing
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
    _EXCEL__NO_DECORATION,                           # column_label
    _EXCEL__BOLD,                                    # first_line_merged_column_label
    _EXCEL__NO_DECORATION,                           # merged_column_label
    _EXCEL__NO_DECORATION,                           # table_cell
    _EXCEL__BOLD,                                    # summary_row_label
    _EXCEL__NO_DECORATION,                           # summary_row_cell
    _EXCEL__SMALL,                                   # footnote
    _EXCEL__SMALL_ITALIC_GRAY,                       # source_note
)

