## Description #############################################################################
#
# Documentation for the HTML backend.
#
############################################################################################

"""
# PrettyTables.jl HTML Backend

The HTML backend can be selected by passing the keyword `backend = :html` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output.

# Keywords

- `allow_html_in_cells::Bool`: If `true`, the content of the cells can contain HTML code.
    This can be useful to render tables with more complex content, but it can also be a
    security risk if the content is not sanitized.
    (**Default**: `false`)
- `column_label_titles::Union{Nothing, AbstractVector}`: Titles for the column labels. If
    `nothing`, no titles are added. If a vector is passed, it must have the same length as
    the number of column label rows. Each element in the vector can be `nothing` (no title
    for that row) or an element with the title for that row. Notice that this element will
    be converted to string using the function `string`.
    (**Default**: `nothing`)
- `highlighters::Vector{HtmlHighlighter}`: Highlighters to apply to the table. For more
    information, see the section **HTML Highlighters** in the **Extended Help**.
- `line_breaks::Bool`: If `true`, line breaks in the content of the cells (`\\n`) are
    replaced by the HTML tag `<br>`.
    (**Default**: `false`)
- `maximum_column_width::String`: CSS width string for the maximum column width.
    (**Default**: "")
- `minify::Bool`: If `true`, the output HTML code is minified.
    (**Default**: `false`)
- `stand_alone::Bool`: If `true`, the output HTML code is a complete HTML document.
    (**Default**: `false`)
- `style::HtmlTableStyle`: Style of the table. For more information, see the section
    **HTML Table Style** in the **Extended Help**.
- `table_class::String`: Class for the table.
    (**Default**: "")
- `table_div_class::String`: Class for the div containing the table. It is only used if
    `wrap_table_in_div` is `true`.
    (**Default**: "")
- `table_format::HtmlTableFormat`: HTML table format used to render the table. For more
    information, see the section **HTML Table Format** in the **Extended Help**.
- `top_left_string::String`: String to put in the top left corner div.
    (**Default**: "")
- `top_right_string::String`: String to put in the top right corner div. Notice that this
    information is replaced if we are printing the omitted cell summary.
    (**Default**: "")
- `wrap_table_in_div::Bool`: If `true`, the table is wrapped in a div.
    (**Default**: `false`)

# Extended Help

## HTML Highlighters

A set of highlighters can be passed as a `Vector{HtmlHighlighter}` to the `highlighters`
keyword. Each highlighter is an instance of the structure [`HtmlHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return a `Vector{Pair{String, String}}` with properties
    compatible with the `style` field that will be applied to the highlighted cell.

A HTML highlighter can be constructed using three helpers:

```julia
HtmlHighlighter(f::Function, decoration::Vector{Pair{String, String}})

HtmlHighlighter(f::Function, decorations::NTuple{N, Pair{String, String}})

HtmlHighlighter(f::Function, fd::Function)
```

 The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
 the second allows specifying decorations as a `Tuple`, and the third lets the user select
 the desired decoration by specifying the function `fd`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells with value greater than 5 in red, and all
cells with values less than 5 in blue, we can define:

```julia
hl_gt5 = HtmlHighlighter(
    (data, i, j) -> data[i, j] > 5,
    ["color" => "red"]
)

hl_lt5 = HtmlHighlighter(
    (data, i, j) -> data[i, j] < 5,
    ["color" => "blue"]
)

highlighters = [hl_gt5, hl_lt5]
```

## HTML Table Format

The HTML table format is defined using an object of type [`HtmlTableFormat`](@ref) that
contains the following fields:

- `css::String`: CSS to be injected at the end of the `<style>` section.
- `table_width::String`: Table width.

Notice that this format is only applied if `stand_alone = true`.

## HTML Table Style

The HTML table style is defined using an object of type [`HtmlTableStyle`](@ref) that
contains the following fields:

- `top_left_string::Vector{HtmlPair}`: Style for the top left string.
- `top_right_string::Vector{HtmlPair}`: Style for the top right string.
- `table::Vector{HtmlPair}`: Style for the table.
- `title::Vector{HtmlPair}`: Style for the title.
- `subtitle::Vector{HtmlPair}`: Style for the subtitle.
- `row_number_label::Vector{HtmlPair}`: Style for the row number label.
- `row_number::Vector{HtmlPair}`: Style for the row number.
- `stubhead_label::Vector{HtmlPair}`: Style for the stubhead label.
- `row_label::Vector{HtmlPair}`: Style for the row label.
- `row_group_label::Vector{HtmlPair}`: Style for the row group label.
- `first_line_column_label::Vector{HtmlPair}`: Style for the first line of the column
    labels.
- `column_label::Vector{HtmlPair}`: Style for the column label.
- `first_line_merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the
    first column label line.
- `merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the rest of the
    column labels.
- `summary_row_cell::Vector{HtmlPair}`: Style for the summary row cell.
- `summary_row_label::Vector{HtmlPair}`: Style for the summary row label.
- `footnote::Vector{HtmlPair}`: Style for the footnote.
- `source_notes::Vector{HtmlPair}`: Style for the source notes.

Each field is a vector of [`HtmlPair`](@ref), *i.e.* `Pair{String, String}`, describing
properties and values compatible with the HTML style attribute.

For example, if we want the stubhead label to be bold and red, we must define:

```julia
style = HtmlTableStyle(
    stubhead_label = ["font-weight" => "bold", "color" => "red"]
)
```
"""
pretty_table_html_backend
