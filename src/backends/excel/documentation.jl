## Description #############################################################################
#
# Excel Back End: Documentation for the Excel backend.
#
############################################################################################

"""
# Excel Backend

The Excel backend can be selected by passing the keyword `backend = :excel` to the function
[`pretty_table`](@ref). This will allow you to create a pretty table in a newly created
Excel file or to add a pretty table to a new or existing sheet in an existing Excel file.

The Excel backend return depends on the following combination of keywords:

- `nothing` when `sheet` is an `XLSX.Worksheet` (the worksheet is updated in place).
- `XLSX.XLSXFile` when `filename` is `nothing` and `sheet` is a `String`.
- `String` (the filename) when `filename` is a `String` and `mode = "w"`.
- `XLSX.XLSXFile` when `filename` is a `String` and `mode = "rw"`.

!!! note

    This backend uses the functions of [XLSX.jl](https://github.com/felipenoris/XLSX.jl),
    particularly the functions `setFont`, `setFill`, `setBorder` and `setFormat`. For more
    information, refer to the documentation of this package.

## Keywords

- `anchor_cell::String`: Top-left cell of the table in A1 notation (e.g. `"B3"`).
    (**Default**: `"A1"`)
- `data_column_widths::Union{Float64, Vector{Float64}}`: Explicit width for each data column
    in Excel units, overriding auto-calculated widths. A scalar applies to all columns; a
    vector sets per-column widths. When set (> 0), `minimum_data_column_widths` and
    `maximum_data_column_widths` are ignored for that column.
    (**Default**: `0.0`)
- `excel_formatters::Vector{ExcelFormatter}`: Number-format rules applied to data and
    summary cells.
    (**Default**: `ExcelFormatter[]`)
- `filename::Union{Nothing, String}`: Path of the Excel file to write. When `nothing`, no
    file is created and an in-memory `XLSX.XLSXFile` is returned instead. When a string,
    behaviour depends on `mode`.
    (**Default**: `nothing`)
- `highlighters::Vector{ExcelHighlighter}`: Highlighters to apply to the table. For more
    information, see the section **Excel Highlighters** in the **Extended Help**.
- `maximum_data_column_widths::Union{Float64, Vector{Float64}}`: Maximum width for each
    data column in Excel units. A scalar applies to all columns; a vector sets per-column
    maximums.
    (**Default**: `0.0`)
- `minimum_data_column_widths::Union{Float64, Vector{Float64}}`: Minimum width for each
    data column in Excel units. A scalar applies to all columns; a vector sets per-column
    minimums.
    (**Default**: `0.0`)
- `mode::String`: `"w"` to create a new file or `"rw"` to open and update an existing one.
    (**Default**: `"w"`)
- `overwrite::Bool`: Allow overwriting an existing file when `mode = "w"`.
    (**Default**: `false`)
- `sheet::Union{String, XLSX.Worksheet}`: When a `String`, the name of the worksheet tab.
    If no sheet with that name exists it will be created. When an `XLSX.Worksheet`, that
    worksheet is updated in place and `nothing` is returned.
    (**Default**: `"prettytable"`)
- `style::TextTableStyle`: Style of the table. For more information, see the section
    **Excel Table Style** in the **Extended Help**.
- `table_format::ExcelTableFormat`: Excel table format used to render the table. For more
    information, see the section **Excel Table Format** in the **Extended Help**.

# Extended Help

## Excel Highlighters

A set of highlighters can be passed as a `Vector{ExcelHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`ExcelHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)`, which should return `true`
  if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
  highlighter. This function must return a `Vector{ExcelPair}` with the styling attributes
  to apply to the highlighted cell.

An Excel highlighter can be constructed using the following helpers:

```julia
ExcelHighlighter(f::Function, decoration::ExcelPair)
ExcelHighlighter(f::Function, decoration::Vector{ExcelPair})
ExcelHighlighter(f::Function, fd::Function)
```

The decoration uses the same `Vector{ExcelPair}` format as `ExcelTableStyle` fields.
Font attributes are specified directly; fill attributes use the `"cell_fill_"` key prefix
(stripped before calling `XLSX.setFill`). Border attributes are not supported.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells in the third data column with a value greater
than 10 in red with a grey fill, and those in the fourth column in blue:

```julia
highlighters = [
    ExcelHighlighter((data, i, j) -> (j == 3) && (data[i, j] > 10), [
        "color" => "red", "bold" => "true",
        "cell_fill_pattern" => "solid", "cell_fill_fgColor" => "grey90",
    ]),
    ExcelHighlighter((data, i, j) -> (j == 4) && (data[i, j] > 10),
        ["color" => "blue", "bold" => "true"],
    ),
]
```

## Excel Formatters

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

Excel formatters apply native Excel formatting to native Excel values. However,
`PrettyTables,jl`can handle Julia types that can't be represented natively in Excel. If
these are passed natively, then XLSX.jl will fail. To circumvent this, a predefined
formatter has been provided which converts any unhandled types to strings (using
`string()`). For more information, see [`fmt__excel_stringify`](@ref).

## Excel Table Format

The Excel table format is defined using an object of type [`ExcelTableFormat`](@ref) that
contains the following fields:

- `borders::ExcelTableBorders`: Border style configuration (see below).
- `horizontal_line_at_beginning::Bool`: Draw a horizontal line at the first table row after
    the title/subtitle section (i.e., the top of the column labels or the first data row).
    Title and subtitle rows are never bordered.
- `horizontal_line_after_column_labels::Bool`: Draw a line under the column header section.
- `horizontal_line_between_column_labels::Bool`: Draw a line between column header rows.
- `horizontal_line_at_merged_column_labels::Bool`: Draw a line under merged column headers.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: Draw underlines after data
    rows. `:all` draws after every row, `:none` draws none, a `Vector{Int}` draws only after
    the specified row indices (e.g., `[1, 3]` draws after rows 1 and 3).
- `horizontal_line_after_data_rows::Bool`: Draw a line under the data table section.
- `horizontal_line_before_row_group_label::Bool`: Draw a line above each row group divider.
- `horizontal_line_after_row_group_label::Bool`: Draw a line below each row group divider.
- `horizontal_line_before_summary_rows::Bool`: Draw a line between consecutive summary rows.
- `horizontal_line_after_summary_rows::Bool`: Draw a line under the last summary row.
- `vertical_line_at_beginning::Bool`: Draw a vertical line on the left side of the content
    area (excludes title/subtitle and footnotes).
- `vertical_line_after_row_number_column::Bool`: Draw a vertical line after the row number
    column.
- `vertical_line_after_row_label_column::Bool`: Draw a vertical line after the row label
    column.
- `vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: Draw dividers between data
    columns. `:all` draws after every column, `:none` draws none, a `Vector{Int}` draws only
    after the specified column indices (e.g., `[1, 3]` draws after columns 1 and 3).
- `vertical_line_after_data_columns::Bool`: Draw a vertical line on the right side of the
    content area (excludes title/subtitle and footnotes).

We provide a few helpers to configure the table format. For more information, see the
documentation of the following macros:

- [`@excel__all_horizontal_lines`](@ref).
- [`@excel__all_vertical_lines`](@ref).
- [`@excel__no_horizontal_lines`](@ref).
- [`@excel__no_vertical_lines`](@ref).

Border styles are specified using an [`ExcelTableBorders`](@ref) object with these fields:

**Horizontal lines:**

- `top_line`: Top of the outside border.
    (**Default**: thick black).
- `header_line`: Line drawn under the column label section.
    (**Default**: medium black).
- `merged_header_cell_line`: Line below merged header cells
    (**Default**: thin black).
- `middle_line`: All other internal horizontal lines — data row underlines, lines around
    row groups, lines around summary rows, between-header lines — and vertical lines
    between data columns.
    (**Default**: thin black).
- `bottom_line`: Bottom of the outside border
    (**Default**: thick black).

**Vertical lines:**

- `left_line`: Left of the outside border.
    (**Default**: thick black).
- `center_line`: Structural vertical lines — after row numbers and after row labels.
    (**Default**: thin black).
- `right_line`: Right of the outside border.
    (**Default**: thick black).

### Examples

Apply a preset:

```julia
table_format = ExcelTableFormat(; EXCEL_FORMAT_NO_VLINES...)
```

Combine presets and override a field:

```julia
table_format = ExcelTableFormat(;
    merge(EXCEL_FORMAT_SECTION_LINES, (horizontal_line_before_row_group_label = true,))...,
)
```

Draw section-separator lines in red:

```julia
table_format = ExcelTableFormat(
    borders = ExcelTableBorders(header_line = ["style" => "thin", "color" => "red"]),
)
```

To start from a preset and customize border styles:

```julia
table_format = ExcelTableFormat(
    EXCEL_FORMAT_SECTION_LINES;
    borders = ExcelTableBorders(
        header_line = ["style" => "thick", "color" => "red"],
        middle_line = ["style" => "thick", "color" => "red"],
    ),
)
```

When merging presets, the predefined table formats are applied in order with later formats
taking precedence. Any keyword arguments provided take precedence over all predefined
formats.

## Excel Table Style

The Excel table style is defined using an object of type [`ExcelTableStyle`](@ref) that
contains the following fields:

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

Each field corresponds to a table element and should be a vector of `ExcelPair`,
*i.e.* `Pair{String, String}`, describing properties and values compatible with the
`XLSX.setFont` function.

Fill (background color) attributes for a cell can also be included in the same field by
prefixing their keys with `"cell_fill_"`. Any pair whose key starts with `"cell_fill_"` is
routed to `XLSX.setFill` (with the prefix stripped) instead of `XLSX.setFont`. Font and
fill pairs may be mixed freely within a single field.

It is only necessary to define those fields for which the default style needs to be
overwritten. For example:

```julia
style = ExcelTableStyle(
    column_label                   = [["bold" => "true"], ["color" => "red"]], # assuming two columns
    summary_row_label              = ["size" => "8"],
    first_line_merged_column_label = ["bold" => "true", "color" => "orange"],
    footnote                       = ["italic" => "true", "color" => "cyan"],
    row_group_label                = ["bold" => "true", "color" => "magenta"],
    subtitle                       = ["italic" => "true"],
    title                          = ["bold" => "true", "cell_fill_pattern" => "solid", "cell_fill_fgColor" => "black"],
)
```

"""
pretty_table_excel_backend
