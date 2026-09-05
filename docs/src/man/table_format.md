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
the same names as the corresponding fields of the table formats of the text, HTML, LaTeX,
Typst, and Excel back ends:

- `horizontal_line_at_beginning`
- `horizontal_line_before_column_labels` (HTML back end only)
- `horizontal_line_after_column_labels`
- `horizontal_line_at_merged_column_labels`
- `horizontal_lines_at_data_rows` (`:all`, `:none`, or a vector of row indices)
- `horizontal_line_before_row_group_label`
- `horizontal_line_after_row_group_label`
- `horizontal_line_after_data_rows`
- `horizontal_line_before_summary_rows`
- `horizontal_line_after_summary_rows`
- `horizontal_line_after_footnotes` (HTML back end only)
- `horizontal_line_at_end` (HTML back end only)
- `vertical_line_at_beginning`
- `vertical_line_after_row_number_column`
- `vertical_line_after_row_label_column`
- `vertical_lines_at_data_columns` (`:all`, `:none`, or a vector of column indices)
- `vertical_line_after_data_columns`
- `vertical_line_after_continuation_column`

The fields marked as HTML back end only exist because the HTML back end places the title
inside the ruled area, can draw a line between the footnotes and the source notes, and draws
the line at the end of the table (after the last summary or data row, before the footnotes
and source notes) with a dedicated field, whereas the other back ends draw it with
`horizontal_line_after_data_rows` or `horizontal_line_after_summary_rows`. They are silently
ignored by the other back ends.
The backend-specific fields (for example, `horizontal_lines_at_column_labels` of the text
back end and `horizontal_line_between_column_labels` of the Excel back end) are not part of
[`TableFormat`](@ref) and remain available in the native table formats.

The following macros return the keyword arguments to show or suppress every horizontal or
vertical line, which can be merged with additional keywords to override individual options:

- `@all_horizontal_lines`: Return the keyword arguments to show all horizontal lines.
- `@all_vertical_lines`: Return the keyword arguments to show all vertical lines.
- `@no_horizontal_lines`: Return the keyword arguments to suppress all horizontal lines.
- `@no_vertical_lines`: Return the keyword arguments to suppress all vertical lines.

For example, the following object draws only the vertical lines and the horizontal line
after the column labels in any back end:

```@repl table_format
pretty_table(
    [1 2; 3 4];
    table_format = TableFormat(;
        @no_horizontal_lines,
        @all_vertical_lines,
        horizontal_line_after_column_labels = true,
    )
)
```

The text, HTML, LaTeX, Typst, and Excel back ends also provide the same macro quadruple for
their native table formats (for example, `@text__all_horizontal_lines` for
`TextTableFormat` and `@html__no_vertical_lines` for `HtmlTableFormat`), which additionally
cover the backend-specific presence fields. The Markdown back end has no macros because its
table format has a single presence field.

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
html_line_style(LineStyle(; style = :dashed, width = :thick, color = :red))

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
| Horizontal line presence    | ✓    | ✓    | ✓     | partial¹ | ✓     | ✓     |
| Vertical line presence      | ✓    | ✓    | ✓     | –        | ✓     | ✓     |
| Line design: `style`        | ✓²   | ✓    | ✓³    | –        | ✓⁴    | ✓     |
| Line design: `width`        | ✓²   | ✓⁵   | –     | –        | ✓     | ✓     |
| Line design: `color`        | ✓    | ✓    | –     | –        | ✓     | ✓     |
| Table style                 | ✓    | ✓    | ✓     | partial⁶ | ✓     | ✓     |

1. Markdown only supports `horizontal_line_before_summary_rows`.
2. The text back end maps the designs to Unicode box-drawing characters, which only have
   light and heavy weights (`:medium` maps to heavy) and no heavy double lines. The
   intersections between the lines are selected automatically from the crossing designs,
   falling back to the characters in `TextTableBorders` when Unicode does not provide the
   required character. The line design colors are converted to the line faces of
   `TextTableStyle`.
3. The LaTeX dashed and dotted rules use `\hdashline`, which requires the package
   **arydshln** in the document. The designs of the merged header cell line and of the
   vertical lines cannot be changed.
4. Typst strokes have no double variant, so `:double` falls back to `:solid`.
5. The HTML back end maps the widths `:thin`, `:medium`, and `:thick` to `1px`, `2px`, and
   `3px`, respectively.
6. Markdown ignores `title`, `subtitle`, `first_line_merged_column_label`, and
   `merged_column_label` because its style type does not have those fields.

Additional notes:

- The HTML back end draws no lines by default, so the emitted code has no border
  decoration and the table appearance can be fully customized with CSS. When enabled, the
  table lines are drawn using inline styles in the table cells. Hence, they are applied in
  any rendering mode. The presence fields `horizontal_line_before_column_labels`,
  `horizontal_line_after_footnotes`, and `horizontal_line_at_end` are only honored by the
  HTML back end. As in the text back end, the footnotes and source notes are outside the
  ruled area: the line at the end of the table is drawn before them, and the vertical lines
  at the edges of the table are hidden in their cells.
- In the text back end, the color of each line follows the precedence: the line face in
  `TextTableStyle` (for example, `middle_line`), the `color` of the line design, and the
  face in the field `table_border` of `TextTableStyle`.
