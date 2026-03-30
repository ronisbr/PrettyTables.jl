## Description #############################################################################
#
# Excel Back End: Types, structures and constructors.
#
############################################################################################

export ExcelHighlighter, ExcelTableFormat, ExcelTableStyle, ExcelTableFill, ExcelFormatter
export DEFAULT_EXCEL_TABLE_FORMAT, DEFAULT_EXCEL_TABLE_STYLE, DEFAULT_EXCEL_TABLE_FILL
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

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{Pair{String, String}}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.
- `_decoration::Dict{String, String}`: The decoration to be applied to the highlighted cell
    if the default `fd` is used.

# Remarks

An Excel highlighter can be constructed using the following helpers:

```julia
ExcelHighlighters(f::Function, decoration::ExcelPair)
ExcelHighlighters(f::Function, decoration::Vector{Pair{String, String}})
ExcelHighlighters(f::Function, decoration::Pair{Symbol, Vector{Pair{String, String}}})
ExcelHighlighters(
    f::Function,
    decoration::Vector{Pair{Symbol, Vector{Pair{String, String}}}}
)

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

"""
struct ExcelHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Vector{Pair{Symbol, Vector{ExcelPair}}}

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

    function ExcelHighlighter(f::Function, decoration::Pair{Symbol, Vector{ExcelPair}})
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

    function ExcelHighlighter(
        f::Function,
        decoration::Vector{Pair{Symbol, Vector{ExcelPair}}}
    )
        return new(
            f,
            _excel__default_highlighter_fd,
            decoration
        )
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
#                                       Table Format                                       #
############################################################################################
#        1         2         3         4         5         6         7         8         9      
#2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

"""
    struct ExcelTableFormat

Define the table cell borders that will be used to form the Excel table. All parameters are 
strings compatible with the `setBorder` XLSX.jl function.

# Fields

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


# Remarks

The borders to be used in each section of the generated table are defined using an 
object of type [`ExcelTableFormat`}(@ref)] that contains the following fields:

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
to start with the `EXCEL_FORMAT_SECTION_LINES` format and modify the section lines to 
be thick and red:

```julia
table_format = ExcelTableFormat(
    EXCEL_FORMAT_SECTION_LINES;
    underline_data_rows_type = ["style" => "thick", "color" => "red"],
    overline_group_type = ["style" => "thick", "color" => "red"],
    underline_group_type = ["style" => "thick", "color" => "red"],
    underline_summary_rows_type = ["style" => "thick", "color" => "red"],
)
```

"""
@kwdef struct ExcelTableFormat
    outside_border::Bool = true
    outside_border_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_title::Union{Nothing, Bool} = nothing
    underline_title_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_headers::Union{Nothing, Bool} = nothing
    underline_headers_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_between_headers::Union{Nothing, Bool} = nothing
    underline_between_headers_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_merged_headers::Union{Nothing, Bool} = nothing
    underline_merged_headers_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_data_rows::Union{Nothing, Bool} = nothing
    underline_data_rows_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_table::Union{Nothing, Bool} = nothing
    underline_table_type::Union{Nothing, Vector{ExcelPair}} = nothing
    overline_group::Union{Nothing, Bool} = nothing
    overline_group_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_group::Union{Nothing, Bool} = nothing
    underline_group_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_summary_rows::Union{Nothing, Bool} = nothing
    underline_summary_rows_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_summary::Union{Nothing, Bool} = nothing
    underline_summary_type::Union{Nothing, Vector{ExcelPair}} = nothing
    underline_footnotes::Union{Nothing, Bool} = nothing
    underline_footnotes_type::Union{Nothing, Vector{ExcelPair}} = nothing
    vline_after_row_numbers::Union{Nothing, Bool} = nothing
    vline_after_row_numbers_type::Union{Nothing, Vector{ExcelPair}} = nothing
    vline_after_row_labels::Union{Nothing, Bool} = nothing
    vline_after_row_labels_type::Union{Nothing, Vector{ExcelPair}} = nothing
    vline_between_data_columns::Union{Nothing, Bool} = nothing
    vline_between_data_columns_type::Union{Nothing, Vector{ExcelPair}} = nothing
    data_column_width::Union{Float64, Vector{Float64}, Nothing} = nothing
    min_data_column_width::Union{Float64, Vector{Float64}, Nothing} = nothing
    max_data_column_width::Union{Float64, Vector{Float64}, Nothing} = nothing
end

const DEFAULT_EXCEL_TABLE_FORMAT = ExcelTableFormat(
    true,                                                 # outside_border
    ExcelPair["style" => "thick", "color" => "Black"],    # outside_border_type
    true,                                                 # underline_title
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_title_type
    true,                                                 # underline_headers
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_headers_type
    true,                                                 # underline_between_headers
    ExcelPair["style" => "thin", "color" => "Black"],     # underline_between_headers_type
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
    true,                                                 # underline_summary_rows
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
    -1.0,                                                 # data_column_width
    -1.0,                                                 # min_data_column_width
    -1.0,                                                 # max_data_column_width
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

function _excel_format_merge(a::ExcelTableFormat, b::ExcelTableFormat)
    return ExcelTableFormat(; (name => (getfield(b, name) === nothing ?
                                        getfield(a, name) :
                                        getfield(b, name))
                                for name in fieldnames(ExcelTableFormat)
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
        fmt = _excel_format_merge(fmt, p)
    end

    # Apply keyword overrides last
    return _excel_format_merge(fmt, ExcelTableFormat(; kwargs...))
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

############################################################################################
#                                       Table Fill                                        #
############################################################################################

"""
    struct ExcelTableFill

Define the cell fill to use for each of the table elements in the 
Excel back end.

# Fields

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

# Remarks

Each field corresponds to a table element and should be a vector of `ExcelPair`, 
*i.e.* `Pair{String, String}`, describing properties and values compatible with the 
`XLSX.setFill` function.

It is only necessary to define those fields for which the default style needs to be 
overwritten. For example:

# Examples

```julia
style = ExcelTableFill(
    column_label                   = [["pattern" => "solid", "fgColor" => "gray20"], ["pattern" => "solid", "fgColor" => "grey80"]], # assuming two columns
    summary_row_label              = ["pattern" => "lightHorizontal"],
)
```

"""
@kwdef struct ExcelTableFill
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

const DEFAULT_EXCEL_TABLE_FILL =  ExcelTableFill(
    ExcelPair[],                                    # title
    ExcelPair[],                                    # subtitle
    ExcelPair[],                                    # row_number_label
    ExcelPair[],                                    # row_number
    ExcelPair[],                                    # stubhead_label
    ExcelPair[],                                    # row_label
    ExcelPair[],                                    # row_group_label
    ExcelPair[],                                    # first_line_column_label
    ExcelPair[],                                    # column_label
    ExcelPair[],                                    # first_line_merged_column_label
    ExcelPair[],                                    # merged_column_label
    ExcelPair[],                                    # table_cell
    ExcelPair[],                                    # summary_row_label
    ExcelPair[],                                    # summary_row_cell
    ExcelPair[],                                    # footnote
    ExcelPair[],                                    # source_note
)