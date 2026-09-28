# Word Backend

The Word back end can be selected by passing the keyword `backend = :docx` to the function
[`pretty_table`](@ref). It renders the table as a Word (`.docx`) table, either written to a
file or returned as a `WriteDocx.Table` that can be embedded in a larger document.

The back end's return value depends on the keyword `filename`:

- `String` (the filename) when `filename` is a `String`.
- `WriteDocx.Table` when `filename` is `nothing`.

!!! note

    This back end requires [WriteDocx.jl](https://github.com/PumasAI/WriteDocx.jl) to be
    loaded.

```julia
julia> using PrettyTables, WriteDocx

julia> pretty_table([1 2 3; 4 5 6]; backend = :docx, filename = "table.docx")
"table.docx"
```

The `WriteDocx.Table` object is obtained by omitting `filename`, or with the convenience
method `pretty_table(WriteDocx.Table, data; kwargs...)`, so that the table can be placed
inside a document together with other content:

```julia
julia> import WriteDocx as W

julia> table = pretty_table(W.Table, [1 2 3; 4 5 6]; title = "My Table")

julia> doc = W.Document(
           W.Body([
               W.Section([
                   W.Paragraph([W.Run([W.Text("The results are:")])]),
                   table,
               ]),
           ]),
       )

julia> W.save("report.docx", doc)
```

The method `pretty_table(WriteDocx.Document, data; kwargs...)` returns the table already
wrapped in a document with a single section.

## Keywords

- `data_column_widths::Union{Real, AbstractVector{<:Real}}`: Explicit width for each data
    column in points, overriding the estimated widths. A scalar applies to all columns; a
    vector sets per-column widths. When set (> 0), `minimum_data_column_widths` and
    `maximum_data_column_widths` are ignored for that column.
    (**Default**: `0.0`)
- `filename::Union{Nothing, String}`: Path of the Word file to write, which must end in
    `.docx`. When `nothing`, the `WriteDocx.Table` is returned instead of being written to
    a document.
    (**Default**: `nothing`)
- `highlighters::Vector{<:AbstractHighlighter}`: Highlighters to apply to the data cells.
    For more information, see the section [Word Highlighters](@ref docx-highlighters).
- `maximum_data_column_widths::Union{Real, AbstractVector{<:Real}}`: Maximum width for each
    data column in points. A scalar applies to all columns; a vector sets per-column
    maximums.
    (**Default**: `0.0`)
- `minimum_data_column_widths::Union{Real, AbstractVector{<:Real}}`: Minimum width for each
    data column in points. A scalar applies to all columns; a vector sets per-column
    minimums.
    (**Default**: `0.0`)
- `overwrite::Bool`: Allow overwriting an existing file. If it is `false` and the file
    `filename` already exists, an error is thrown.
    (**Default**: `false`)
- `style::Union{TableStyle, DocxTableStyle}`: Style of the table. The fields of the
    backend-agnostic [`TableStyle`](@ref) override the ones of the default Word table style.
    For more information, see the section [Word Table Style](@ref docx-table-style).
- `table_format::Union{TableFormat, DocxTableFormat}`: Word table format used to render the
    table. The backend-agnostic [`TableFormat`](@ref) is fully supported: its line presence
    and design fields override the ones of the default Word table format. For more
    information, see the section [Word Table Format](@ref docx-table-format).

## Table Sections

The Word table has one row per table section. The title, the subtitle, the row group labels,
the footnotes, and the source notes are rendered in rows that span the entire table width,
whereas the other sections are rendered in the corresponding cells.

The back end estimates the width of each column from its content and writes it to the table
grid. By default, Word uses those widths only as a starting point and adjusts the columns to
the content. If any of the keywords `data_column_widths`, `minimum_data_column_widths`, or
`maximum_data_column_widths` is set, the table uses a fixed layout, meaning that Word lays
out the columns exactly at the computed widths and wraps the text that does not fit. The
widths of the row number, row label, and continuation columns are always estimated.

Footnote markers are rendered as superscript text runs, and a line break inside a cell is
rendered as a Word line break, keeping the cell content in a single paragraph. A tab inside
a cell is rendered as a Word tab. The ANSI escape sequences and the characters that cannot
be written in a Word document (for example, the null character) are removed from the text.

Each region of a styled string of StyledStrings.jl (Julia 1.11 or newer) becomes a text run
with the attributes of its face (see [Faces](@ref)). As in the Excel back end, the
attributes of the table style and of the highlighter applied to the cell take precedence
over the ones of the regions.

## [Word Highlighters](@id docx-highlighters)

A set of highlighters can be passed as a vector of `AbstractHighlighter` to the
`highlighters` keyword. A highlighter can be an instance of the general
[`Highlighter`](@ref), which is defined by a `Face` and works with every back end (see
[Highlighters](@ref highlighters)), or of the structure [`DocxHighlighter`](@ref), specific
to this back end. The face of a general highlighter is converted with
[`docx_decoration`](@ref). The structure [`DocxHighlighter`](@ref) contains the following
two public fields:

- `f::Function`: Function with the signature `f(data, i, j)`, which should return `true` if
  the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `fd(h, data, i, j)` in which `h` is the
  highlighter. This function must return a `Vector{DocxPair}` with the styling attributes to
  apply to the highlighted cell.

A Word highlighter can be constructed using the following helpers:

```julia
DocxHighlighter(f::Function, decoration::DocxPair)
DocxHighlighter(f::Function, decoration::Vector{DocxPair})
DocxHighlighter(f::Function, fd::Function)
```

The decoration uses the same `Vector{DocxPair}` format as the [`DocxTableStyle`](@ref)
fields. Border attributes are not supported. The decoration can also be created from a
`Face`, which is converted with [`docx_decoration`](@ref), or from the keywords of `Face`:

```julia
DocxHighlighter(f::Function, face::Face)
DocxHighlighter(f::Function; kwargs...)
```

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells in the third data column with a value greater
than 10 in red on a gray background, and those in the fourth column in blue:

```julia
highlighters = [
    DocxHighlighter((data, i, j) -> (j == 3) && (data[i, j] > 10),
        ["color" => "FF0000", "bold" => "true", "background" => "E6E6E6"],
    ),
    DocxHighlighter((data, i, j) -> (j == 4) && (data[i, j] > 10),
        ["color" => "0000FF", "bold" => "true"],
    ),
]
```

## [Word Table Format](@id docx-table-format)

The Word table format is defined using an object of type [`DocxTableFormat`](@ref) that
contains the following fields:

- `borders::DocxTableBorders`: Border style configuration (see below).
- `horizontal_line_at_beginning::Bool`: Draw a horizontal line at the first table row after
    the title/subtitle section (i.e., the top of the column labels or the first data row).
    Title and subtitle rows are never bordered.
- `horizontal_line_after_column_labels::Bool`: Draw a line under the column header section.
- `horizontal_line_between_column_labels::Bool`: Draw a line between column header rows.
- `horizontal_line_at_merged_column_labels::Bool`: Draw a line under merged column headers.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: Draw underlines after data
    rows. `:all` draws after every row, `:none` draws none, a `Vector{Int}` draws only after
    the specified row indices (e.g., `[1, 3]` draws after rows 1 and 3). The line after the
    last data row is only drawn if `horizontal_line_after_data_rows` is `true`.
- `horizontal_line_after_data_rows::Bool`: Draw a line under the data table section.
- `horizontal_line_before_row_group_label::Bool`: Draw a line above each row group divider.
- `horizontal_line_after_row_group_label::Bool`: Draw a line below each row group divider.
- `horizontal_line_before_summary_rows::Bool`: Draw a line between the data rows and the
    summary rows.
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
- `vertical_line_after_continuation_column::Bool`: Draw a vertical line after the
    continuation column.
- `cell_margins::NTuple{4, Float64}`: Margins of every cell in points, in the order top,
    left, bottom, and right. Notice that Word renders a cell without margins with the text
    touching the borders.
    (**Default**: `(2.0, 5.0, 2.0, 5.0)`)
- `repeat_header_rows_at_page_breaks::Bool`: Mark the rows above the data (title, subtitle,
    and column labels) as table header rows, meaning that Word repeats them at every page
    break.
    (**Default**: `true`)

We provide a few helpers to configure the table format. For more information, see the
documentation of the following macros:

- [`@docx__all_horizontal_lines`](@ref).
- [`@docx__all_vertical_lines`](@ref).
- [`@docx__no_horizontal_lines`](@ref).
- [`@docx__no_vertical_lines`](@ref).

Border styles are specified using a [`DocxTableBorders`](@ref) object whose fields are
vectors of [`DocxPair`](@ref) with the keys `"style"` (a `WriteDocx.BorderStyle`, *e.g.*
`"single"`, `"dashed"`, `"dotted"`, or `"double"`), `"size"` (the line thickness in eighths
of a point), and `"color"`:

**Horizontal lines:**

- `top_line`: Top of the outside border.
    (**Default**: 2 pt black).
- `header_line`: Line drawn under the column label section.
    (**Default**: 1 pt black).
- `merged_header_cell_line`: Line below merged header cells.
    (**Default**: 0.5 pt black).
- `middle_line`: All other internal horizontal lines — data row underlines, lines around
    row groups, lines around summary rows, between-header lines — and vertical lines
    between data columns.
    (**Default**: 0.5 pt black).
- `bottom_line`: Bottom of the outside border.
    (**Default**: 2 pt black).

**Vertical lines:**

- `left_line`: Left of the outside border.
    (**Default**: 2 pt black).
- `center_line`: Structural vertical lines — after row numbers and after row labels.
    (**Default**: 0.5 pt black).
- `right_line`: Right of the outside border.
    (**Default**: 2 pt black).

### Examples

Apply a preset:

```julia
table_format = DocxTableFormat(; @docx__no_vertical_lines)
```

Apply a preset and override one of its fields. Notice that the keyword must come **after**
the macro, since the last binding wins:

```julia
table_format = DocxTableFormat(;
    @docx__no_vertical_lines,
    vertical_line_at_beginning = true,
)
```

Draw the section-separator lines in red:

```julia
table_format = DocxTableFormat(;
    borders = DocxTableBorders(;
        header_line = ["style" => "single", "size" => "8", "color" => "FF0000"]
    ),
)
```

A backend-agnostic [`TableFormat`](@ref) is also accepted, in which case the line designs
are converted with [`docx_line_style`](@ref).

## [Word Table Style](@id docx-table-style)

The Word table style is defined using an object of type [`DocxTableStyle`](@ref) that
contains the following fields:

- `title::Vector{DocxPair}`: Style for the title.
- `subtitle::Vector{DocxPair}`: Style for the subtitle.
- `row_number_label::Vector{DocxPair}`: Style for the row number label.
- `row_number::Vector{DocxPair}`: Style for the row number.
- `stubhead_label::Vector{DocxPair}`: Style for the stubhead label.
- `row_label::Vector{DocxPair}`: Style for the row label.
- `row_group_label::Vector{DocxPair}`: Style for the row group label.
- `first_line_column_label::Union{Vector{DocxPair}, Vector{Vector{DocxPair}}}`: Style for
    the first line of the column labels. If a vector of `Vector{DocxPair}` is provided, each
    column label in the first line will use the corresponding style.
- `column_label::Union{Vector{DocxPair}, Vector{Vector{DocxPair}}}`: Style for the rest of
    the column labels. If a vector of `Vector{DocxPair}` is provided, each column label will
    use the corresponding style.
- `first_line_merged_column_label::Vector{DocxPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{DocxPair}`: Style for the merged cells at the rest of the
    column labels.
- `data_cell::Vector{DocxPair}`: Style for the table cells.
- `summary_row_label::Vector{DocxPair}`: Style for the summary row label.
- `summary_row_cell::Vector{DocxPair}`: Style for the summary row cell.
- `footnote::Vector{DocxPair}`: Style for the footnotes.
- `source_note::Vector{DocxPair}`: Style for the source notes.

Each field corresponds to a table element and should be a vector of `DocxPair`, *i.e.*
`Pair{String, String}`, with the following keys:

| Key            | Value                                                          |
|:---------------|:---------------------------------------------------------------|
| `"bold"`       | `"true"` or `"false"`.                                         |
| `"italic"`     | `"true"` or `"false"`.                                         |
| `"strike"`     | `"true"` or `"false"`.                                         |
| `"underline"`  | A `WriteDocx.UnderlinePattern`, *e.g.* `"single"` or `"wave"`. |
| `"color"`      | Text color as a 6-digit hexadecimal string, *e.g.* `"FF0000"`. |
| `"background"` | Cell background as a 6-digit hexadecimal string.               |
| `"font"`       | Font name, *e.g.* `"Palatino"`.                                |
| `"size"`       | Font size in points, *e.g.* `"14"` or `"10.5"`.                |

The colors accept a 6-digit hexadecimal string (with or without the leading `#`) or one of
the named colors of StyledStrings.jl (for example, `"red"`, `"bright_blue"`, or `"gray"`).
For backward compatibility, the color names of Crayons.jl (for example, `"light_blue"`) are
also accepted.

It is only necessary to define those fields for which the default style needs to be
overwritten. For example:

```julia
style = DocxTableStyle(
    column_label      = [["bold" => "true"], ["color" => "FF0000"]], # assuming two columns
    summary_row_label = ["size" => "8"],
    footnote          = ["italic" => "true", "color" => "00FFFF"],
    row_group_label   = ["bold" => "true", "background" => "EEEEEE"],
    title             = ["bold" => "true", "color" => "FFA500", "size" => "18"],
)
```

Every keyword of the constructor of [`DocxTableStyle`](@ref) also accepts a `Face`, which is
converted to Word attributes with [`docx_decoration`](@ref) (see [Faces](@ref)).

!!! note

    Word shades an entire cell rather than a text run. Hence, `"background"` always shades
    the cell, and the background of the face of a section of a styled string is dropped.
