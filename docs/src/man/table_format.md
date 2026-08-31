# Table Format and Style

```@meta
CurrentModule = PrettyTables
```

```@setup table_format
using PrettyTables
```

Each back end configures its output with two objects: a table format, which states how the
table is printed (for example, which lines are drawn), and a table style, which states how
the table is decorated (for example, the face of the column labels). Both objects have
backend-specific types (`TextTableFormat`, `LatexTableStyle`, and so on), which also carry
backend-specific options. Hence, switching back ends would require rewriting those
configurations.

To avoid this, the keywords `table_format` and `style` of [`pretty_table`](@ref) also
accept the backend-agnostic objects [`TableFormat`](@ref) and [`TableStyle`](@ref), which
describe the table lines and decorations once for every back end:

```julia
table_format = TableFormat(;
    horizontal_lines_at_data_rows = :all,
    vertical_lines_at_data_columns = :none,
    header_line = LineStyle(; style = :dashed),
)

style = TableStyle(;
    title = Face(; weight = :bold, foreground = :magenta),
    first_line_column_label = Face(; slant = :italic, foreground = :blue),
)

pretty_table(matrix; table_format = table_format, style = style)
pretty_table(matrix; backend = :latex, table_format = table_format, style = style)
pretty_table(matrix; backend = :typst, table_format = table_format, style = style)
pretty_table(matrix; backend = :excel, table_format = table_format, style = style)
```

!!! note

    A [`TableFormat`](@ref) does not select a back end. If the keyword `backend` is
    `:auto`, the table is printed with the text back end, exactly as when `table_format` is
    not passed.

## Sparse Override

Every field of [`TableFormat`](@ref) and [`TableStyle`](@ref) defaults to `nothing`,
meaning "keep the default behavior of the selected back end". Hence, the objects never
replace the back end configuration entirely: each set field overrides only the
corresponding field of the back end default format or style. For example, the following
object only adds horizontal lines between the data rows, keeping everything else untouched
in every back end:

```@repl table_format
pretty_table([1 2; 3 4]; table_format = TableFormat(horizontal_lines_at_data_rows = :all))
```

Notice that `nothing` differs from `:none` in the fields that accept a `Symbol`: `nothing`
keeps the back end default, whereas `:none` explicitly disables the lines.

## Table Format

### Line Presence

The line presence fields of [`TableFormat`](@ref) select which lines are drawn. They have
the same names as the corresponding fields of the table formats of the text, LaTeX, Typst,
and Excel back ends:

- `horizontal_line_at_beginning`
- `horizontal_line_after_column_labels`
- `horizontal_line_at_merged_column_labels`
- `horizontal_lines_at_data_rows` (`:all`, `:none`, or a vector of row indices)
- `horizontal_line_before_row_group_label`
- `horizontal_line_after_row_group_label`
- `horizontal_line_after_data_rows`
- `horizontal_line_before_summary_rows`
- `horizontal_line_after_summary_rows`
- `vertical_line_at_beginning`
- `vertical_line_after_row_number_column`
- `vertical_line_after_row_label_column`
- `vertical_lines_at_data_columns` (`:all`, `:none`, or a vector of column indices)
- `vertical_line_after_data_columns`
- `vertical_line_after_continuation_column`

The backend-specific fields (for example, `horizontal_lines_at_column_labels` of the text
back end and `horizontal_line_between_column_labels` of the Excel back end) are not part of
[`TableFormat`](@ref) and remain available in the native table formats.

### Line Design

The design of each line is described by a [`LineStyle`](@ref), a backend-agnostic
description converted to the native line design of each back end. A `LineStyle` has three
fields, all defaulting to `nothing` (keep the back end default):

- `style`: `:solid`, `:dashed`, `:dotted`, or `:double`.
- `width`: `:thin`, `:medium`, or `:thick`.
- `color`: a named color (`Symbol`), a 24-bit color (`UInt32` or `"#rrggbb"`), a tuple
  `(r, g, b)`, or a `SimpleColor`.

The line roles follow the border fields of the Typst and Excel table formats:

- `top_line`, `header_line`, `merged_header_cell_line`, `middle_line`, and `bottom_line`
  for the horizontal lines.
- `left_line`, `center_line`, and `right_line` for the vertical lines.

The conversion functions can also be called directly:

```@repl table_format
typst_line_style(LineStyle(; style = :dashed, width = :thick, color = :red))

excel_line_style(LineStyle(; style = :dashed, color = 0xff0000))

latex_line_style(LineStyle(; style = :double))
```

## Table Style

A [`TableStyle`](@ref) describes the decoration of each table section with a
[`Face`](@ref), exactly like the keyword constructors of the native table styles (see
[Faces](@ref)). The available fields are the ones shared by the back end style types:
`title`, `subtitle`, `row_number_label`, `row_number`, `stubhead_label`, `row_label`,
`row_group_label`, `first_line_column_label`, `column_label`,
`first_line_merged_column_label`, `merged_column_label`, `summary_row_label`,
`summary_row_cell`, `footnote`, and `source_note`. The fields `first_line_column_label` and
`column_label` also accept a vector with one face per column.

```@repl table_format
style = TableStyle(; first_line_column_label = Face(; slant = :italic, foreground = :blue));

pretty_table([1 2; 3 4]; style = style)
```

The backend-specific style fields (for example, `table_border` of `TextTableStyle` and
`data_cell` of `ExcelTableStyle`) are not part of [`TableStyle`](@ref) and remain available
in the native table styles.

## Back End Support

The conversion is a best effort: aspects a back end cannot express are silently ignored.
The following table summarizes the support:

| Aspect                      | Text | HTML | LaTeX | Markdown | Typst | Excel |
|:----------------------------|:-----|:-----|:------|:---------|:------|:------|
| Horizontal line presence    | ✓    | –    | ✓     | partial¹ | ✓     | ✓     |
| Vertical line presence      | ✓    | –    | ✓     | –        | ✓     | ✓     |
| Line design: `style`        | –    | –    | ✓²    | –        | ✓³    | ✓     |
| Line design: `width`        | –    | –    | –     | –        | ✓     | ✓     |
| Line design: `color`        | –    | –    | –     | –        | ✓     | ✓     |
| Table style                 | ✓    | ✓    | ✓     | partial⁴ | ✓     | ✓     |

1. Markdown only supports `horizontal_line_before_summary_rows`.
2. The LaTeX dashed and dotted rules use `\hdashline`, which requires the package
   **arydshln** in the document. The designs of the merged header cell line and of the
   vertical lines cannot be changed.
3. Typst strokes have no double variant, so `:double` falls back to `:solid`.
4. Markdown ignores `title`, `subtitle`, `first_line_merged_column_label`, and
   `merged_column_label` because its style type does not have those fields.

Additional notes:

- The HTML back end currently ignores [`TableFormat`](@ref) entirely. The table lines can
  be customized with the field `css` of `HtmlTableFormat`.
- The text back end ignores the line design because it draws the table with a single
  character set (see `TextTableBorders`). The color of all the table lines can be set with
  the field `table_border` of `TextTableStyle`.
