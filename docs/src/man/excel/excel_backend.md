# Excel Backend

The Excel backend can be selected by passing the keyword `backend = :excel` to the function
[`pretty_table`](@ref). This will allow you to create a pretty table in a newly created 
Excel file or to add a pretty table to a new or existing sheet in an existing Excel file.

This backend uses the functions of [XLSX.jl](https://github.com/felipenoris/XLSX.jl), 
particularly the functions `setFont`, `setFill`, `setBorder` and `setFormat`. For more 
information, refer to the documentation of this package.

## Keywords

The following additional keywords configure the output of the `:excel` backend.

- `filename::Union{Nothing,String}`: The name of the Excel file to be used to contain the 
  table. If `nothing` (default), no file will be created but an `XLSXFile` object will be 
  returned instead. If a valid filename is given, behaviour depends on the value specified 
  for `mode` as follows:
    - If `filename === nothing`
      - If `sheet === XLSX.worksheet`: Returns `nothing`. The worksheet specified is updated in place.
      - If `sheet !== XLSX.worksheet`: Returns an in-memory `XLSX.XLSXFile` object.
    - If `filename::String` and `mode=\"w\"`: Writes to a new file and returns the filename.
    - If `filename::String` and `mode=\"rw\"`: Reads an existing file, updates and returns the in-memory `XLSX.XLSXFile` object.

- `sheet::Union{String, XLSX.Worksheet}`: If `sheet` is a `String`, it specifies the name of 
  the tab to use for the created pretty table. Default = `"prettytable"`. If a sheet with the 
  given name doesn't exist, it will be created. If `sheet` is an `XLSX.Worksheet`, this 
  worksheet will be updated in place by the addition of the pretty table and `nothing` will 
  be returned.
- `mode::String`: Determines whether to create a new Excel file (`mode = "w"` - Default) or 
  to open and use an existing Excel file (`mode = "rw"`).
- `overwrite::Bool`: Determines whether or not to overwrite an existing file if `mode = "w"`. 
  Default = `false`.
- `anchor_cell::String`: Defines the top-left cell of the table, allowing placement 
  anywhere on a sheet. A table will overwrite any existing data in the cells it is written to, 
  but using `anchor_cell` makes it possible to place a pretty table alongside existing data 
  in the specified sheet. Default = `"A1"`. 
- `excel_formatters::Vector{ExcelFormatter}`: Excel-specific format (numFmt) definitions 
  to appy to the table. For more information, see the section [`ExcelFormatter`](@ref).
- `highlighters::Vector{ExcelHighlighter}`: Excel-specific highlighters to apply to the 
  table. For more information, see the section [`ExcelHighlighter`](@ref).
- `table_format::ExcelTableFormat`: Defines the table borders to be used in each section 
  of the table. For more information, see the section [`ExcelTableFormat`](@ref)
- `style::ExcelTableStyle`: Defines the Excel font attributes to be used by each element of 
  the table. For more information, see the section [`ExcelTableStyle`](@ref). 


## Excel Highlighters

A set of highlighters can be passed as a `Vector{ExcelHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`ExcelHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)`, which should return `true`
  if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
  highlighter. This function must return a `Vector{Pair{Symbol,Vector{Pair{String, String}}}}` with properties compatible with the `XLSX.setFont` function that will be applied to 
  the highlighted cell.

An Excel highlighter can be constructed using the following helpers:

```julia
ExcelHighlighters(f::Function, decoration::ExcelPair)
ExcelHighlighters(f::Function, decoration::Vector{Pair{String, String}})
ExcelHighlighters(f::Function, decoration::Pair{Symbol,Vector{Pair{String, String}}})
ExcelHighlighters(f::Function, decoration::Vector{Pair{Symbol,Vector{Pair{String, String}}}})

ExcelHighlighters(f::Function, fd::Function)
```

The first set will apply a fixed decoration to the highlighted cell, whereas the 
second lets the user select the desired decoration by specifying the function `fd`.

The decoration is specified as `[:format => ["attribute" => "value"], ...]`
where `:format` can be specified as `:font`, `:fill` or `:border`. The attributes and 
values are the same as those supported by the functions `XLSX.setFont`, `XLSX.setFill` 
and `XLSX.setBorder`.

If a single decoration is supplied, the leading symbol may omitted and will be assumed 
to be `:font`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells in the third data column with a value greater 
than 10, those in the fourth column with a value greater than 10 and those (in any column) 
with zero value, each with separate highlighter formats, we can specify:

```julia
highlighters = [
    ExcelHighlighter((data, i, j) -> (j == 3) && (data[i, j] > 10), [
        :font => [ "color"=>"red", "bold"=>"true"],
        :fill => [ "pattern" => "solid", "fgColor" => "grey90"],
        :border => ["style" => "thick", "color" => "red"],
    ]),
    ExcelHighlighter((data, i, j) -> (data[i, j] ≈ 0.0), [
        :font => [ "color"=>"green", "bold"=>"true"],
        :border => ["style" => "thick", "color" => "green"],
    ]),
    ExcelHighlighter((data, i, j) -> (j == 4) && (data[i, j] > 10),
        ["color"=>"blue", "bold"=>"true"], # assumes `:font`
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

Excel formatters apply native Excel formatting to native Excel values. 
However, `PrettyTables,jl`can handle Julia types that can't be represented 
natively in Excel. If these are passed natively, then XLSX.jl will fail. 
To circumvent this, a predefined formatter has been provided which converts 
any unhandled types to strings (using `string()`). For more information, see 
[`fmt__excel_stringify`](@ref).

## Excel Table Format

The borders to be used in each section of the generated table are defined using an 
object of type [`ExcelTableFormat`](@ref) that contains the following fields:

- `outside_border::Bool`: A Bool indicating whether or not to draw an outside border.
- `outside_border_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border to be 
  applied to the outside border of the table.
- `underline_title::Bool`: Determines whether to draw a cell border under the 
  table title/subtitle section.
- `underline_title_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border to be 
  drawn under the table title/subtitle section.
- `underline_headers::Bool`: Determines whether to draw a cell border under the 
  (unmerged) column header section.
- `underline_headers_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border 
  to be drawn under the column header section.
- `underline_between_headers::Bool`: Determines whether to draw a cell border under the 
  (unmerged) column headers.
- `underline_between_headers_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border 
  to be drawn between (unmerged) column headers.
- `underline_merged_headers::Bool`: Determines whether to draw a cell border under 
  any merged column headers. 
- `underline_merged_headers_type::Union{Nothing,Vector{ExcelPair}}`: Describes the 
  border to be drawn under any merged column headers.
- `underline_data_rows::Bool`: Determines whether to draw a cell border under each 
  data row in the data table. 
- `underline_data_rows_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border 
  to be drawn under each data row in the data table.
- `underline_table::Bool`: Determines whether to draw a cell border under the 
  data table section.
- `underline_table_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border to 
  be drawn under the data table section.
- `overline_group::Bool`: Determines whether to draw a cell border over each 
  row group divider.
- `overline_group_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border to 
  be drawn over each row group divider.
- `underline_group::Bool`: Determines whether to draw a cell border under each 
  row group divider.
- `underline_group_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border to 
  be drawn under each row group divider.
- `underline_summary_rows::Bool`: Determines whether to draw a cell border under 
  the summary rows section. 
- `underline_summary_rows_type::Union{Nothing,Vector{ExcelPair}}`: Describes the 
  border to be drawn under the summary rows.
- `underline_summary::Bool`: Determines whether to draw a cell border under the 
  table summary section.
- `underline_summary_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border 
  to be drawn under the table summary.
- `underline_footnotes::Bool`: Determines whether to draw a cell border under the 
  table footnotes section.
- `underline_footnotes_type::Union{Nothing,Vector{ExcelPair}}`: Describes the border 
  to be drawn under the footnote section.
- `vline_after_row_numbers::Bool`: Determines whether to draw a cell border to the 
  right of the row number column.
- `vline_after_row_numbers_type::Union{Nothing,Vector{ExcelPair}}`: Describes the 
  border to be drawn under the row number column.
- `vline_after_row_labels::Bool`: Determines whether to draw a cell border to the 
  right of the row label column.
- `vline_after_row_labels_type::Union{Nothing,Vector{ExcelPair}}`: Describes the 
  border to be drawn after the row label column.
- `vline_between_data_columns::Bool`: Determines whether to draw a vertical 
  border to be drawn between the data columns.
- `vline_between_data_columns_type::Union{Nothing,Vector{ExcelPair}}`: Describes the 
  border to be drawn between the data columns.
- `data_column_width::Union{Float64,Vector{Float64},Nothing}`: Specifies the column 
  width to be used for the data table columns, over-riding any automatically 
  calculated column width. If a vector of values is provided, the width of each 
  column is set by the corresponding vector entry.
- `min_data_column_width::Union{Float64,Vector{Float64},Nothing}`: Specifies the 
  minimum column width to be used for the data table columns, clipping any 
  narrower column width automatically calculated. If a vector of values is 
  provided, the minimum width of each column is set by the corresponding vector 
  entry.
- `max_data_column_width::Union{Float64,Vector{Float64},Nothing}`: Specifies the 
  maximum column width to be used for the data table columns, clipping any 
  wider column width automatically calculated. If a vector of values is 
  provided, the maximum width of each column is set by the corresponding vector 
  entry.

Each cell border is controlled by two fields. The first is a Bool which dictates 
whether or not the cell border should be drawn (default = `true` in every case). 
The second is a vector of `Pair{String, String}` which specifies the border 
attributes to use if the border is to be drawn using the attributes supported 
by `XLSX.setBorder`. The default color is `black` and the style is one of `dotted` 
(for internal cell borders within a section), `thin` (for borders between sections), 
or `thick` (only for the outside table border).

The `underline` and `overline` values specify the bottom and top cell borders 
respectively while `vline` values specify the border on the right hand side.

The `title` border is drawn under the subtitle row (if provided) or under the title 
row if there is no subtitle.

To simplify the specification of table borders, four standard definitions are provided:
- `DEFAULT_EXCEL_TABLE_FORMAT`: The default table format used by `pretty_table` when 
  the `table_format` keyword is not specified. This format draws all borders with a 
  thin line, except for the outside border which is drawn with a thick line and the 
  data row underline and summary row underline which are drawn with a dotted line.
- `EXCEL_FORMAT_NO_VLINES`: A table format with no vertical lines.
- `EXCEL_FORMAT_CELL_LINES`: A table format with no borders around the individual data 
  cells.
  - `EXCEL_FORMAT_SECTION_LINES`: Produces a table with horizontal lines separating the 
  different table sections (title, column labels, data rows, summary rows, footnotes)
  and one vertical line between the row labels and the table data.

The `data_column_width`, `min_data_column_width` and `max_data_column_width` fields
are specified in Excel's internal units. If `data_column_width` is specified, 
`min_data_column_width` and `max_data_column_width` are ignored.

It is only necessary to define those fields for which the default border formats 
need to be overwritten. For example, to choose to draw an outside border around 
the whole table with a double line:

```julia
table_format = ExcelTableFormat(
    outside_border_type=["style" => "double"],
)
```

The predefined table formats may be used as a starting point, alone or in combination 
and, if required, can be further modidied by overwriting specific fields. For example, 
to start with the `EXCEL_FORMAT_SECTION_LINES` and format and modify the section lines 
to be thick and red:

```julia
table_format = ExcelTableFormat(
    EXCEL_FORMAT_SECTION_LINES;
    underline_data_rows_type = ["style" => "thick", "color" => "red"],
    overline_group_type = ["style" => "thick", "color" => "red"],
    underline_group_type = ["style" => "thick", "color" => "red"],
    underline_summary_rows_type = ["style" => "thick", "color" => "red"],
)
```
When merging formats like this, the predefined table formats are applied in order, 
with later formats taking precedence over earlier ones. Finally, any keyword arguments 
provided will take precedence over all predefined formats.

## Excel Table Style

The Excel table style is defined using an object of type [`ExcelTableStyle`](@ref) that
contains the following fields:

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

Each field corresponds to a table element and should be a vector of `ExcelPair`, 
*i.e.* `Pair{String, String}`, describing properties and values compatible with the 
`XLSX.setFont` function.

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
    title                          = ["bold" => "true", "color" => "orange", "size" => "18", "under" => "single"],
)

```

## Excel Table Fill

The Excel table fill (background cell color) is defined using an object of type 
[`ExcelTableFill`](@ref) that contains the following fields: 

- `title::Union{Nothing,Vector{ExcelPair}}`: Fill for the title.
- `subtitle::Union{Nothing,Vector{ExcelPair}}`: Fill for the subtitle.
- `row_number_label::Union{Nothing,Vector{ExcelPair}}`: Fill for the row number label.
- `row_number::Union{Nothing,Vector{ExcelPair}}`: Fill for the row number.
- `stubhead_label::Union{Nothing,Vector{ExcelPair}}`: Fill for the stubhead label.
- `row_label::Union{Nothing,Vector{ExcelPair}}`: Fill for the row label.
- `row_group_label::Union{Nothing,Vector{ExcelPair}}`: Fill for the row group label.
- `first_line_column_label::Union{Nothing,Vector{ExcelPair},Vector{Vector{ExcelPair}}}`: 
  Fill for the first line of the column labels. If a vector of `Vector{ExcelPair}}` is 
  provided, each column label in the first line will use the corresponding fill.
- `column_label::Union{Nothing,Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Fill for 
  the rest of the column labels. If a vector of `Vector{ExcelPair}}` is provided, each 
  column label will use the corresponding fill.
- `first_line_merged_column_label::Union{Nothing,Vector{ExcelPair}}`: Fill for the 
  merged cells at the first column label line.
- `merged_column_label::Union{Nothing,Vector{ExcelPair}}`: Fill for the merged cells 
  at the rest of the column labels.
- `table_cell::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Fill 
  for the table cells. If a vector of `Vector{ExcelPair}}` is provided, each 
  column in the data table will use the corresponding fill.
- `summary_row_label::Union{Nothing,Vector{ExcelPair}}`: Fill for the summary row label.
- `summary_row_cell::Union{Nothing, Vector{ExcelPair}, Vector{Vector{ExcelPair}}}`: Fill 
  for the summary row cell. If a vector of `Vector{ExcelPair}}` is provided, each column 
  in the summary row will use the corresponding fill.
- `footnote::Union{Nothing,Vector{ExcelPair}}`: Fill for the footnotes.
- `source_note::Union{Nothing,Vector{ExcelPair}}`: Fill for the source notes.

Each field corresponds to a table element and should be a vector of `ExcelPair`, 
*i.e.* `Pair{String, String}`, describing properties and values compatible with the 
`XLSX.setFill` function.

It is only necessary to define those fields for which the default style needs to be 
overwritten. For example:

```julia
style = ExcelTableFill(
    column_label                   = [["pattern" => "solid", "fgColor" => "gray20"], ["pattern" => "solid", "fgColor" => "grey80"]], # assuming two columns
    summary_row_label              = ["pattern" => "lightHorizontal"],
)
```