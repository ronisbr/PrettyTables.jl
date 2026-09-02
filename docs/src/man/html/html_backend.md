# HTML Backend

The HTML backend can be selected by passing the keyword `backend = :html` to the function
[`pretty_table`](@ref). In this case, we have the following additional keywords to configure
the output.

## Keywords

- `allow_html_in_cells::Bool`: If `true`, the content of the cells can contain HTML code.
  This can be useful to render tables with more complex content, but it can also be a
  security risk if the content is not sanitized.
  (**Default**: `false`)
- `column_label_titles::Union{Nothing, AbstractVector}`: Titles for the column labels. If
  `nothing`, no titles are added. If a vector is passed, it must have the same length as the
  number of column label rows. Each element in the vector can be `nothing` (no title for
  that row) or an element with the title for that row. Notice that this element will be
  converted to string using the function `string`.
  (**Default**: `nothing`)
- `highlighters::Vector{<:AbstractHighlighter}`: Highlighters to apply to the table. For more
  information, see the section [HTML Highlighters](@ref).
- `line_breaks::Bool`: If `true`, line breaks in the content of the cells (`\\n`) are
  replaced by the HTML tag `<br>`.
  (**Default**: `false`)
- `maximum_column_width::String`: CSS width string for the maximum column width.
  (**Default**: "")
- `minify::Bool`: If `true`, the output HTML code is minified.
  (**Default**: `false`)
- `stand_alone::Bool`: If `true`, the output HTML code is a complete HTML document.
  (**Default**: `false`)
- `style::Union{TableStyle, HtmlTableStyle}`: Style of the table. For more information, see the section
  [HTML Table Style](@ref).
- `table_class::String`: Class for the table.
  (**Default**: "")
- `table_div_class::String`: Class for the div containing the table. It is only used if
  `wrap_table_in_div` is `true`.
  (**Default**: "")
- `table_format::Union{TableFormat, HtmlTableFormat}`: HTML table format used to render the table. For more
  information, see the section [HTML Table Format](@ref).
- `top_left_string::String`: String to put in the top left corner div.
  (**Default**: "")
- `top_right_string::String`: String to put in the top right corner div. Notice that this
  information is replaced if we are printing the omitted cell summary.
  (**Default**: "")
- `wrap_table_in_div::Bool`: If `true`, the table is wrapped in a div.
  (**Default**: `false`)

## HTML Highlighters

A set of highlighters can be passed as a vector of `AbstractHighlighter` to the
`highlighters` keyword. A highlighter can be an instance of the structure
[`HtmlHighlighter`](@ref), specific to this back end, or of the general
[`Highlighter`](@ref), which is defined by a `Face` and works with every back end (see
[Faces](@ref)). The face is converted with [`html_decoration`](@ref). The structure [`HtmlHighlighter`](@ref)
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
  if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
  highlighter. This function must return a `Vector{Pair{String, String}}` with properties
  compatible with the `style` field that will be applied to the highlighted cell.

A HTML highlighter can be constructed using three helpers:

```julia
HtmlHighlighter(f::Function, decoration::Vector{Pair{String, String}})

HtmlHighlighter(f::Function, decorations::NTuple{N, Pair{String, String})

HtmlHighlighter(f::Function, fd::Function)
```

The first will apply a fixed decoration to the highlighted cell specified in `decoration`,
whereas the second lets the user select the desired decoration by specifying the function
`fd`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the vector `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

For example, if we want to highlight the cells with values greater than 5 in red, and all
the cells with values less than 5 in blue, we can define:

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

- `css::String`: CSS to be injected at the end of the `<style>` section. Notice that this
  field is only applied if `stand_alone = true`.
- `table_width::String`: Table width. Notice that this field is only applied if
  `stand_alone = true`.
- `borders::HtmlTableBorders`: Format of the borders. Each line role is a string with a CSS
  `border` shorthand value (for example, `"1px dashed blue"`).
- A set of boolean fields selecting which horizontal and vertical lines are drawn. For the
  complete list, see the documentation of [`HtmlTableFormat`](@ref).

The table lines are emitted as inline styles in the table cells (the lines at the beginning
and end of the table are emitted in the `<table>` element together with
`border-collapse: collapse`). Hence, they are applied in any rendering mode, including when
the table is embedded in another document (Jupyter, Pluto, Documenter, etc.).

Compared to the other back ends, `HtmlTableFormat` has three additional line presence
fields (`horizontal_line_before_column_labels`, `horizontal_line_after_footnotes`, and
`horizontal_line_at_end`) because the HTML back end places the title and the footer inside
the ruled area.

The following macros are available to help configuring the table lines:

- `@html__all_horizontal_lines`: Return the keyword arguments to show all horizontal lines.
- `@html__all_vertical_lines`: Return the keyword arguments to show all vertical lines.
- `@html__no_horizontal_lines`: Return the keyword arguments to suppress all horizontal
  lines.
- `@html__no_vertical_lines`: Return the keyword arguments to suppress all vertical lines.

For example, we can draw only the vertical lines as follows:

```julia
table_format = HtmlTableFormat(; @html__no_horizontal_lines, @html__all_vertical_lines)
```

### Line Design

We can change the design of the table lines by passing a custom [`HtmlTableBorders`](@ref)
object to the field `borders`. For example, the following format renders the line after the
column labels as a dotted green line and every line inside the table body as a dashed blue
line:

```julia
table_format = HtmlTableFormat(;
    borders = HtmlTableBorders(;
        header_line = "2px dotted green",
        middle_line = "1px dashed blue",
    ),
    horizontal_lines_at_data_rows = :all,
)
```

The backend-agnostic [`TableFormat`](@ref) is also supported: its line designs are
converted to CSS border values with [`html_line_style`](@ref), and its line presence fields
override the corresponding fields of the default HTML table format.

Since the lines are emitted as inline styles, any decoration applied later (alignment,
styles, or highlighters) can override them by pushing another value for the same CSS
property. Additionally, when two lines meet at the same edge (for example, the line after
the data rows and the line before the summary rows), the CSS border-collapsing rules select
the wider border, and then the border with the higher style precedence.

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
- `first_line_column_label::Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}}`: Style for
  the first line of the column labels. If a vector of `Vector{HtmlPair}}` is provided, each
  column label in the first line will use the corresponding style.
- `column_label::Union{Vector{HtmlPair}, Vector{Vector{HtmlPair}}}`: Style for the rest of
  the column labels. If a vector of `Vector{HtmlPair}}` is provided, each column label will
  use the corresponding style.
- `first_line_merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the
  first column label line.
- `merged_column_label::Vector{HtmlPair}`: Style for the merged cells at the rest of the
  column labels.
- `summary_row_cell::Vector{HtmlPair}`: Style for the summary row cell.
- `summary_row_label::Vector{HtmlPair}`: Style for the summary row label.
- `footnote::Vector{HtmlPair}`: Style for the footnote.
- `source_notes::Vector{HtmlPair}`: Style for the source notes.
- `first_line_of_column_labels::Vector{HtmlPair}`: Style for the first line of the column
  labels.

Each field is a vector of [`HtmlPair`](@ref), *i.e.* `Pair{String, String}`, describing
properties and values compatible with the HTML style attribute.

For example, if we want the stubhead label to be bold and red, we must define:
```julia
style = HtmlTableStyle(
    stubhead_label = ["font-weight" => "bold", "color" => "red"]
)
```

Every keyword of the constructor of [`HtmlTableStyle`](@ref) also accepts a `Face`, which is
converted to CSS properties with [`html_decoration`](@ref) (see [Faces](@ref)).
