## Description #############################################################################
#
# Documentation the text backend.
#
############################################################################################

"""
# PrettyTables.jl Text Backend

The text backend can be selected by passing the keyword `backend = :text` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output.

# Keywords

- `alignment_anchor_fallback::Symbol`: This keyword controls the line alignment when using
    the regex alignment anchors if a match is not found. If it is `:l`, the left of the line
    will be aligned with the anchor. If it is `:c`, the line center will be aligned with the
    anchor. Otherwise, the end of the line will be aligned with the anchor.
    (**Default** = `:l`)
- `alignment_anchor_regex::Union{Vector{Regex}, Vector{Pair{Int, Vector{Regex}}}}`: This
    keyword can be used to provide regexes to aligh the data values in the table columns. It
    it is `Vector{Regex}`, the regexes will be used to align all the columns. If it is
    `Vector{Pair{Int, Vector{Regex}}}`, the `Int` element specify the column to which the
    regexes in `Vector{Regex}` will be applied. The regex match is searched in the same
    order as the regexes appear on the vector. The regex matching is applied after the cell
    conversion to string, which includes the formatters. If no match is found for a specific
    line, the alignment of this line depends on the options `alignment_anchor_fallback`.
    Example: `[2 => [r"\\."]]` aligns the decimal point of the cells in the second column.
    (**Default** = `Regex[]`)
- `auto_wrap::Bool`: If `true`, the text will be wrapped on spaces to fit the column. Notice
    that this function requires `linebreaks = true` and the column must have a fixed size
    (see `fixed_data_column_widths`).
    (**Default** = `false`)
- `column_label_width_based_on_first_line_only::Bool`: If `true`, the column label width is
    based on the first line of the column. Hence, if the other column labels have a text
    width larger than the computed column width, they will be cropped to fit.
    (**Default** = `false`)
- `display_size::Tuple{Int, Int}`: A tuple of two integers that defines the display size
    (num. of rows, num. of columns) that is available to print the table. It is used to crop
    the data depending on the value of the keyword `crop`. Notice that if a dimension is not
    positive, it will be treated as unlimited.
    (**Default** = `displaysize(io)`)
- `equal_data_column_widths::Bool`: If `true`, the data columns will have the same width.
    (**Default** = `false`)
- `fit_table_in_display_horizontally::Bool`: If `true`, the table will be cropped to fit
    the display horizontally.
    (**Default** = `true`)
- `fit_table_in_display_vertically::Bool`: If `true`, the table will be cropped to fit the
    display vertically.
    (**Default** = `true`)
- `fixed_data_column_widths::Union{Int, Vector{Int}}`: If it is a `Vector{Int}`, this vector
    specifies the width of each column. If it is a `Int`, this number will be used as the
    width of all columns. If the width is equal or lower than 0, it will be automatically
    computed to fit the large cell in the column.
    (**Default** = 0)
- `highlighters::Vector{TextHighlighter}`: Highlighters to apply to the table. For more
    information, see the section **Text Highlighters** in the **Extended Help**.
- `line_breaks::Bool`: If `true`, a new line character will break the line inside the cells.
    (**Default** = `false`)
- `maximum_data_column_widths::Union{Int, Vector{Int}}`: If it is a `Vector{Int}`, this
    vector specifies the maximum width of each column. If it is a `Int`, this number will be
    used as the maximum width of all columns. If the maximum width is equal or lower than 0,
    it will be ignored. Notice that the parameter `fixed_data_column_widths` has precedence
    over this one.
    (**Default** = 0)
- `overwrite_display::Bool`: If `true`, the same number of lines in the printed table will
    be deleted from the output `io`. This can be used to update the table in the display
    continuously.
    (**Default** = `false`)
- `reserved_display_lines::Int`: Number of lines to be left at the beginning of the printing
    when vertically cropping the output.
    (**Default** = 0)
- `style::TextTableStyle`: Style of the table. For more information, see the section
    **Text Table Style** in the **Extended Help**.
- `table_format::TextTableFormat`: Text table format used to render the table. For more
    information, see the section **Text Table Format** in the **Extended Help**.

# Extended Help

## Text highlighters

A set of highlighters can be passed as a `Vector{TextHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`TextHighlighter`](@ref). It
contains three fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighter, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return the `Crayon` to be applied to the cell that must
    be highlighted.
- `crayon::Crayon`: The `Crayon` to be applied to the highlighted cell if the default `fd`
    is used.

The function `f` has the following signature:

```julia
f(data, i, j)
```

in which `data` is a reference to the data that is being printed, and `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the cell
`(i, j)` will be highlighted.

If the function `f` returns true, the function `fd(h, data, i, j)` will be called and must
return a `Crayon` that will be applied to the cell.

A highlighter can be constructed using three helpers:

```julia
Highlighter(f::Function; kwargs...)
```

where it will construct a `Crayon` using the keywords in `kwargs` and apply it to the
highlighted cell,

```julia
Highlighter(f::Function, crayon::Crayon)
```

where it will apply the `crayon` to the highlighted cell, and

```julia
Highlighter(f::Function, fd::Function)
```

where it will apply the `Crayon` returned by the function `fd` to the highlighted cell.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, we if want to highlight the cells with value greater than 5 in red, and
all the cells with value less than 5 in blue, we can define:

```julia
hl_gt5 = TextHighlighter(
    (data, i, j) -> data[i, j] > 5,
    crayon"red"
)

hl_lt5 = HtmlHighlighter(
    (data, i, j) -> data[i, j] < 5,
    crayon"blue"
)

highlighters = [hl_gt5, hl_lt5]
```

## Text Table Format

The text table format is defined using an object of type [`TextTableFormat`](@ref) that
contains the following fields:

- `borders::TextTableBorders`: Format of the borders.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the column labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data column. If the symbol `:none` is passed,
    no horizontal lines will be drawn after the data rows.
- `horizontal_line_before_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn before the row group label.
- `horizontal_line_after_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn after the row group label.
- `horizontal_line_after_data_rows::Bool`: If `true`, a horizontal line will be drawn
    after the data rows.
- `horizontal_line_after_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    after the summary rows.
- `right_vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will
    be drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data column. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.
- `ellipsis_line_skip::Integer`: Number of lines to skip when printing an ellipsis.
- `new_line_at_end::Bool`: If `true`, a new line will be added at the end of the table.

We provide a few helpers to configure the table format. For more information, see the
documentation of the following macros:

- [`@text__all_horizontal_lines`](@ref).
- [`@text__all_vertical_lines`](@ref).
- [`@text__no_horizontal_lines`](@ref).
- [`@text__no_vertical_lines`](@ref).

## Text Table Style

The text table style is defined using an object of type [`TextTableStyle`](@ref) that
contains the following fields:

- `title::Crayon`: Crayon with the style for the title.
- `subtitle::Crayon`: Crayon with the style for the subtitle.
- `row_number_label::Crayon`: Crayon with the style for the row number label.
- `row_number::Crayon`: Crayon with the style for the row numbers.
- `stubhead_label::Crayon`:  Crayon with the style for the stubhead label.
- `row_label::Crayon`: Crayon with the style for the row labels.
- `row_group_label::Crayon`: Crayon with the style for the row group label.
- `first_line_column_label::Crayon`: Crayon with the style for the first column label lines.
- `column_label::Crayon`: Crayon with the style for the rest of the column labels.
- `first_line_merged_column_label::Crayon`: Crayon with the style for the merged cells at
    the first column label line.
- `merged_column_label::Crayon`: Crayon with the style for the merged cells at the rest of
    the column labels.
- `summary_row_cell::Crayon`: Crayon with the style for the summary row cell.
- `summary_row_label::Crayon`: Crayon with the style for the summary row label.
- `footnote::Crayon`: Crayon with the style for the footnotes.
- `source_note::Crayon`: Crayon with the style for the source notes.
- `omitted_cell_summary::Crayon`: Crayon with the style for the omitted cell summary.
- `table_border::Crayon`: Crayon with the style for the table border.

Each field is a `Crayon` describing the style for the corresponding element in the table.

For example, we if want that the stubhead label is bold and red, we must define:

```julia
style = TextTableStyle(
    stubhead_label = crayon"bold red"
)
```
"""
pretty_table_text_backend
