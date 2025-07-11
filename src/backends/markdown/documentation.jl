## Description #############################################################################
#
# Documentation for the Markdown backend.
#
############################################################################################

"""
# PrettyTables.jl Markdown Backend

The markdown backend can be selected by passing the keyword `backend = :markdown` to the
function [`pretty_table`](@ref). In this case, we have the following additional keywords to
configure the output.

# Keywords

- `allow_markdown_in_cells::Bool`: If `true`, the content of the cells can contain markdown
    code.
    (**Default**: `false`)
- `highlighters::Vector{MarkdownHighlighter}`: Highlighters to apply to the table. For more
    information, see the section **Markdown Highlighters** in the **Extended Help**.
- `line_breaks::Bool`: If `true`, line breaks in the content of the cells (`\\n`) are
    replaced by `<br>`.
    (**Default**: `false`)
- `style::MarkdownTableStyle`: Style of the table. For more information, see the section
    **Markdown Table Style** in the **Extended Help**.
- `table_format::MarkdownTableFormat`: Markdown table format used to render the table. For
    more information, see the section **Markdown Table Format** in the **Extended Help**.

# Extended Help

## Markdown Highlighters

A set of highlighters can be passed as a `Vector{MarkdownHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`MarkdownHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `fd(h, data, i, j)` in which `h` is the
    highlighter. This function must return the [`MarkdownStyle`](@ref) to be applied to the
cell that must be highlighted.

The function `f` has the following signature:

```julia
f(data, i, j)
```

in which `data` is a reference to the data that is being printed, and `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the highlight
style will be applied to the `(i, j)` element. Otherwise, the default style will be used.

If the function `f` returns true, the function `fd(h, data, i, j)` will be called and must
return an element of type [`MarkdownStyle`](@ref) that contains the decoration to be
applied to the cell.

A markdown highlighter can be constructed using two helpers:

```julia
MarkdownHighlighter(f::Function, decoration::MarkdownStyle)

MarkdownHighlighter(f::Function, fd::Function)
```

whereas the second lets the user select the desired decoration by specifying the function
`fd`.
`fd`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

## Markdown Table Format

The markdown table format is defined using an object of type [`MarkdownTableFormat`](@ref)
that contains the following fields:

- `title_heading_level::Int`: Title heading level.
- `subtitle_heading_level::Int`: Subtitle heading level.
- `horizontal_line_char::Char`: Character used to draw the horizontal line.
- `line_before_summary_rows::Bool`: Whether to draw a line before the summary rows.

## Markdown Table Style

The markdown table style is defined using an object of type [`MarkdownTableStyle`](@ref)
that contains the following fields:

- `row_number_label::MarkdownStyle`: Style for the row number label.
- `row_number::MarkdownStyle`: Style for the row number.
- `first_column_label::MarkdownStyle`: Style for the first line of the column labels.
- `row_label::MarkdownStyle`: Style for the row label.
- `row_group_label::MarkdownStyle`: Style for the row group label.
- `first_column_label::MarkdownStyle`: Style for the first line of the  column
    labels.
- `column_label::MarkdownStyle`: Style for the column label.
- `summary_row_label::MarkdownStyle`: Style for the summary row label.
- `summary_row_cell::MarkdownStyle`: Style for the summary row cell.
- `footnote::MarkdownStyle`: Style for the footnote.
- `source_note::MarkdownStyle`: Style for the source note.
- `omitted_cell_summary::MarkdownStyle`: Style for the omitted cell summary.

Each field is an instance of the structure [`MarkdownStyle`](@ref) describing the style to
be applied to the corresponding element.

For example, if we want that the stubhead label is bold and italic, we must define:

```julia
style = MarkdownTableStyle(
    stubhead_label = MarkdownStyle(bold = true, italic = true)
)
```
"""
pretty_table_markdown_backend
