## Description #############################################################################
#
# Functions to print the tables.
#
############################################################################################

export pretty_table

############################################################################################
#                                     Public Functions                                     #
############################################################################################

"""
    pretty_table([io::IO | String | HTML,] table;  kwargs...)

Print to `io` the `table`.

If `io` is omitted, it defaults to `stdout`. If `String` is passed in the place of `io`, a
`String` with the printed table will be returned by the function. If `HTML` is passed in the
place of `io`, an `HTML` object is returned with the printed table.

When printing, it will be verified if `table` complies with **Tables.jl** API. If it is
compliant, this interface will be used to print the table. If it is not compliant, only the
following types are supported:

1. `AbstractVector`: any vector can be printed.
2. `AbstractMatrix`: any matrix can be printed.
3. `Dict`: any `Dict` can be printed. In this case, the special keyword `sortkeys` can be
    used to select whether or not the user wants to print the dictionary with the keys
    sorted. If it is `false`, the elements will be printed on the same order returned by the
    functions `keys` and `values`. Notice that this assumes that the keys are sortable, if
    they are not, an error will be thrown.

# Keywords

- `alignment::Union{Symbol, Vector{Symbol}}`: Select the alignment of the columns (see the
    section `Alignment`).
- `backend::Union{Symbol, T_BACKENDS}`: Select which back end will be used to print the
    table (see the section `Back End`). Notice that the additional configuration in
    `kwargs...` depends on the selected back end.
- `cell_alignment::Union{Nothing, Dict{Tuple{Int, Int}, Symbol}, Function, Tuple}`: A tuple
    of functions with the signature `f(data, i, j)` that overrides the alignment of the cell
    `(i, j)` to the value returned by `f`. It can also be a single function, when it is
    assumed that only one alignment function is required, or `nothing`, when no cell
    alignment modification will be performed. If the function `f` does not return a valid
    alignment symbol as shown in section `Alignment`, it will be discarded. For convenience,
    it can also be a dictionary of type `(i, j) => a` that overrides the alignment of the
    cell `(i, j)` to `a`. `a` must be a symbol like specified in the section `Alignment`.
    (**Default** = `nothing`)

!!! note

    If more than one alignment function is passed to `cell_alignment`, the functions will be
    evaluated in the same order of the tuple. The first one that returns a valid alignment
    symbol for each cell is applied, and the rest is discarded.

- `cell_first_line_only::Bool`: If `true`, only the first line of each cell will be printed.
    (**Default** = `false`)
- `compact_printing::Bool`: Select if the option `:compact` will be used when printing the
    data.
    (**Default** = `true`)
- `formatters::Union{Nothing, Function, Tuple}`: See the section `Formatters`.
- `header::Union{Symbol, Vector{Symbol}}`: The header must be a tuple of vectors. Each one
    must have the number of elements equal to the number of columns in the table. The first
    vector is considered the header and the others are the subheaders. If it is `nothing`, a
    default value based on the type will be used. If a single vector is passed, it will be
    considered the header.
    (**Default** = `nothing`)
- `header_alignment::Union{Symbol, Vector{Symbol}}`: Select the alignment of the header
    columns (see the section `Alignment`). If the symbol that specifies the alignment is
    `:s` for a specific column, the same alignment in the keyword `alignment` for that
    column will be used.
    (**Default** = `:s`)
- `header_cell_alignment::Union{Nothing, Dict{Tuple{Int, Int}, Symbol}, Function, Tuple}`:
    This keyword has the same structure of `cell_alignment` but in this case it operates in
    the header. Thus, `(i, j)` will be a cell in the header matrix that contains the header
    and sub-headers. This means that the `data` field in the functions will be the same
    value passed in the keyword `header`.
    (**Default** = `nothing`)

!!! note

      If more than one alignment function is passed to `header_cell_alignment`, the
      functions will be evaluated in the same order of the tuple. The first one that returns
      a valid alignment symbol for each cell is applied, and the rest is discarded.

- `limit_printing::Bool`: If `true`, the cells will be converted using the property `:limit
    => true` of `IOContext`.
    (**Default** = `true`)
- `max_num_of_columns`::Int: The maximum number of table columns that will be rendered. If
    it is lower than 0, all columns will be rendered.
    (**Default** = -1)
- `max_num_of_rows`::Int: The maximum number of table rows that will be rendered. If it is
    lower than 0, all rows will be rendered.
    (**Default** = -1)
- `renderer::Symbol`: A symbol that indicates which function should be used to convert an
    object to a string. It can be `:print` to use the function `print` or `:show` to use the
    function `show`. Notice that this selection is applicable only to the table data.
    Headers, sub-headers, and row name column are always rendered with print.
    (**Default** = `:print`)
- `row_labels::Union{Nothing, AbstractVector}`: A vector containing the row labels that will
    be appended to the left of the table. If it is `nothing`, the column with the row labels
    will not be shown. Notice that the size of this vector must match the number of rows in
    the table.
    (**Default** = `nothing`)
- `row_label_alignment::Symbol`: Alignment of the column with the row labels (see the
    section `Alignment`).
- `row_label_column_title::AbstractString`: Title of the column with the row labels.
    (**Default** = "")
- `row_number_column_title::AbstractString`: Title of the column with the row numbers.
    (**Default** = "Row")
- `show_header::Bool`: If `true`, the header will be printed. Notice that all keywords and
    parameters related to the header and sub-headers will be ignored.
    (**Default** = `false`)
- `show_row_number::Bool`: If `true`, a new column will be printed showing the row number.
    (**Default** = `false`)
- `show_subheader::Bool`: If `true`, the sub-header will be printed, *i.e.* the header will
    contain both the header and subheader. Notice that this option has no effect if
    `show_header = false`.
    (**Default** = `true`)
- `title::AbstractString`: The title of the table. If it is empty, no title will be printed.
    (**Default** = "")
- `title_alignment::Symbol`: Alignment of the title, which must be a symbol as
    explained in the section `Alignment`. This argument is ignored in the
    LaTeX back end.
    (**Default** = :l)

!!! note
    Notice that all back ends have the keyword `tf` to specify the table printing format.
    Thus, if the keyword `backend` is not present or if it is `nothing`, the back end will
    be automatically inferred from the type of the keyword `tf`. In this case, if `tf` is
    also not present, it just fall-back to the text back end unless `HTML` is passed as the
    first argument. In this case, the default back end is set to HTML.

If `String` is used, the keyword `color` selects whether or not the table will be converted
to string with or without colors. The default value is `false`. Notice that this option only
has effect in text back end.

# Alignment

The keyword `alignment` can be a `Symbol` or a vector of `Symbol`.

If it is a symbol, we have the following behavior:

- `:l` or `:L`: the text of all columns will be left-aligned;
- `:c` or `:C`: the text of all columns will be center-aligned;
- `:r` or `:R`: the text of all columns will be right-aligned;
- Otherwise it defaults to `:r`.

If it is a vector, it must have the same number of symbols as the number of
columns in `data`. The *i*-th symbol in the vector specify the alignment of the
-i*-th column using the same symbols as described previously.

!!! note
    In HTML back end, the user can select `:n` ou `:N` to print the cell without any
    alignment annotation.

---

# Text Back End

This back end produces text tables. This back end can be used by selecting
`backend = :text`.

## Keywords

- `alignment_anchor_fallback::Symbol`: This keyword controls the line alignment when using
    the regex alignment anchors if a match is not found. If it is `:l`, the left of the line
    will be aligned with the anchor. If it is `:c`, the line center will be aligned with the
    anchor. Otherwise, the end of the line will be aligned with the anchor.
    (**Default** = `:l`)
- `alignment_anchor_fallback_override::Dict{Int, Symbol}`: A `Dict{Int, Symbol}` to override
    the behavior of `fallback_alignment_anchor` for a specific column. Example:
    `Dict(3 => :c)` changes the fallback alignment anchor behavior for `:c` only for the
    column 3.
- `alignment_anchor_regex::Dict{Int, AbstractVector{Regex}}`: A dictionary
    `Dict{Int, AbstractVector{Regex}}` with a set of regexes that is used to align the
    values in the columns (keys). The characters at the first regex match (or anchor) of
    each line in every cell of the column will be aligned.  The regex match is searched in
    the same order as the regexes appear on the vector. The regex matching is applied after
    the cell conversion to string, which includes the formatters. If no match is found for a
    specific line, the alignment of this line depends on the options
    `alignment_anchor_fallback` and `alignment_anchor_fallback_override`. If the key `0` is
    present, the related regexes will be used to align all the columns. In this case, all
    the other keys will be neglected. Example: `Dict(2 => [r"\\."])` aligns the decimal
    point of the cells in the second column.
    (**Default** = `Dict{Int, Vector{Regex}}()`)
- `autowrap::Bool`: If `true`, the text will be wrapped on spaces to fit the column. Notice
    that this function requires `linebreaks = true` and the column must have a fixed size
    (see `columns_width`).
- `body_hlines::Vector{Int}`: A vector of `Int` indicating row numbers in which an
    additional horizontal line should be drawn after the row. Notice that numbers lower than
    0 and equal or higher than the number of printed rows will be neglected. This vector
    will be appended to the one in `hlines`, but the indices here are related to the printed
    rows of the body. Thus, if `1` is added to `body_hlines`, a horizontal line will be
    drawn after the first data row.
    (**Default** = `Int[]`)
- `body_hlines_format::Union{Nothing, NTuple{4, Char}}`: A tuple of 4 characters specifying
    the format of the horizontal lines that will be drawn by `body_hlines`. The characters
    must be the left intersection, the middle intersection, the right intersection, and the
    row. If it is `nothing`, it will use the same format specified in `tf`.
    (**Default** = `nothing`)
- `columns_width::Union{Int, AbstractVector{Int}}`: A set of integers specifying the width
    of each column. If the width is equal or lower than 0, it will be automatically computed
    to fit the large cell in the column. If it is a single integer, this number will be used
    as the size of all columns.
    (**Default** = 0)
- `crop::Symbol`: Select the printing behavior when the data is bigger than the available
    display size (see `display_size`). It can be `:both` to crop on vertical and horizontal
    direction, `:horizontal` to crop only on horizontal direction, `:vertical` to crop only
    on vertical direction, or `:none` to do not crop the data at all. If the `io` has
    `:limit => true`, `crop` is set to `:both` by default. Otherwise, it is set to `:none`
    by default.
- `crop_subheader::Bool`: If `true`, the sub-header size will not be taken into account when
    computing the column size. Hence, the print algorithm can crop it to save space. This
    has no effect if the user selects a fixed column width.
    (**Default** = `false`)
- `continuation_row_alignment::Symbol`: A symbol that defines the alignment of the cells in
    the continuation row. This row is printed if the table is vertically cropped.
    (**Default** = `:c`)
- `display_size::Tuple{Int, Int}`: A tuple of two integers that defines the display size
    (num. of rows, num. of columns) that is available to print the table. It is used to crop
    the data depending on the value of the keyword `crop`. Notice that if a dimension is not
    positive, it will be treated as unlimited.
    (**Default** = `displaysize(io)`)
- `ellipsis_line_skip::Integer`: An integer defining how many lines will be skipped from
    showing the ellipsis that indicates the text was cropped.
    (**Default** = 0)
- `equal_columns_width::Bool`: If `true`, all the columns will have the same width.
    (**Default** = `false`)
- `highlighters::Union{Highlighter, Tuple}`: An instance of `Highlighter` or a tuple with a
    list of text highlighters (see the section `Text highlighters`).
- `hlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where the
    horizontal lines will be drawn. It can be `nothing`, `:all`, `:none` or a vector of
    integers.
    (**Default** = `nothing`)
    - If it is `nothing`, which is the default, the configuration will be obtained from the
        table format in the variable `tf` (see [`TextFormat`](@ref)).
    - If it is `:all`, all horizontal lines will be drawn.
    - If it is `:none`, no horizontal line will be drawn.
    - If it is a vector of integers, the horizontal lines will be drawn only after the rows
        in the vector. Notice that the top line will be drawn if `0` is in `hlines`, and the
        header and subheaders are considered as only 1 row. Furthermore, it is important to
        mention that the row number in this variable is related to the **printed rows**.
        Thus, it is affected by the option to suppress the header `show_header`.  Finally,
        for convenience, the top and bottom lines can be drawn by adding the symbols
        `:begin` and `:end` to this vector, respectively, and the line after the header can
        be drawn by adding the symbol `:header`.

!!! info

    The values of `body_hlines` will be appended to this vector. Thus, horizontal lines can
    be drawn even if `hlines` is `:none`.

- `linebreaks::Bool`: If `true`, `\\n` will break the line inside the cells.
    (**Default** = `false`)
- `maximum_columns_width::Union{Int, AbstractVector{Int}}`: A set of integers specifying the
    maximum width of each column. If the width is equal or lower than 0, it will be ignored.
    If it is a single integer, this number will be used as the maximum width of all columns.
    Notice that the parameter `columns_width` has precedence over this one.
    (**Default** = 0)
- `minimum_columns_width::Union{Int, AbstractVector{Int}}`: A set of integers specifying the
    minimum width of each column. If the width is equal or lower than 0, it will be ignored.
    If it is a single integer, this number will be used as the minimum width of all columns.
    Notice that the parameter `columns_width` has precedence over this one.
    (**Default** = 0)
- `newline_at_end::Bool`: If `false`, the table will not end with a newline character.
    (**Default** = `true`)
- `overwrite::Bool`: If `true`, the same number of lines in the printed table will be
    deleted from the output `io`. This can be used to update the table in the display
    continuously.
    (**Default** = `false`)
- `reserved_display_lines::Int`: Number of lines to be left at the beginning of the printing
    when vertically cropping the output. Notice that the lines required to show the title
    are automatically computed.
    (**Default** = 0)
- `row_number_alignment::Symbol`: Select the alignment of the row number column (see the
    section `Alignment`).
    (**Default** = `:r`)
- `show_omitted_cell_summary::Bool`: If `true`, a summary will be printed after the table
    with the number of columns and rows that were omitted.
    (**Default** = `true`)
- `tf::TextFormat`: Table format used to print the table (see [`TextFormat`](@ref)).
    (**Default** = `tf_unicode`)
- `title_autowrap::Bool`: If `true`, the title text will be wrapped considering the title
    size. Otherwise, lines larger than the title size will be cropped.
    (**Default** = `false`)
- `title_same_width_as_table::Bool`: If `true`, the title width will match that of the
    table. Otherwise, the title size will be equal to the display width.
    (**Default** = `false`)
- `vcrop_mode::Symbol`: This variable defines the vertical crop behavior. If it is
    `:bottom`, the data, if required, will be cropped in the bottom. On the other hand, if
    it is `:middle`, the data will be cropped in the middle if necessary.
    (**Default** = `:bottom`)
- `vlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where the
    vertical lines will be drawn. It can be `nothing`, `:all`, `:none` or a vector of
    integers.
    (**Default** = `nothing`)
    - If it is `nothing`, which is the default, the configuration will be obtained from the
        table format in the variable `tf` (see [`TextFormat`](@ref)).
    - If it is `:all`, all vertical lines will be drawn.
    - If it is `:none`, no vertical line will be drawn.
    - If it is a vector of integers, the vertical lines will be drawn only after the columns
        in the vector. Notice that the left line will be drawn if `0` is in `vlines`.
        Furthermore, it is important to mention that the column number in this variable is
        related to the **printed column**. Thus, it is affected by the options `row_labels`
        and `show_row_number`.  Finally, for convenience, the left and right vertical lines
        can be drawn by adding the symbols `:begin` and `:end` to this vector, respectively.

The following keywords related to crayons are available to customize the output decoration:

- `border_crayon::Crayon`: Crayon to print the border.
- `header_crayon::Union{Crayon, Vector{Crayon}}`: Crayon to print the header.
- `omitted_cell_summary_crayon::Crayon`: Crayon used to print the omitted cell summary.
- `row_label_crayon::Crayon`: Crayon to print the row labels.
- `row_label_header_crayon::Crayon`: Crayon to print the header of the column with the row
    labels.
- `row_number_header_crayon::Crayon`: Crayon for the header of the column with the row
    numbers.
- `subheader_crayon::Union{Crayon, Vector{Crayon}}`: Crayon to print sub-headers.
- `text_crayon::Crayon`: Crayon to print default text.
- `title_crayon::Crayon`: Crayon to print the title.

The keywords `header_crayon` and `subheader_crayon` can be a `Crayon` or a `Vector{Crayon}`.
In the first case, the `Crayon` will be applied to all the elements. In the second, each
element can have its own crayon, but the length of the vector must be equal to the number of
columns in the data.

## Crayons

A `Crayon` is an object that handles a style for text printed on terminals. It is defined in
the package [Crayons.jl](https://github.com/KristofferC/Crayons.jl). There are many options
available to customize the style, such as foreground color, background color, bold text,
etc.

A `Crayon` can be created in two different ways:

```julia-repl
julia> Crayon(foreground = :blue, background = :black, bold = :true)

julia> crayon"blue bg:black bold"
```

For more information, see the package documentation.

## Text highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.  Each
highlighter is an instance of the structure `Highlighter` that contains three fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighter, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h,data,i,j)` in which `h` is the
    highlighter. This function must return the `Crayon` to be applied to the cell that must
    be highlighted.
- `crayon::Crayon`: The `Crayon` to be applied to the highlighted cell if the default `fd`
    is used.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, and `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the cell
`(i, j)` will be highlighted.

If the function `f` returns true, the function `fd(h, data, i, j)` will be called and must
return a `Crayon` that will be applied to the cell.

A highlighter can be constructed using three helpers:

    Highlighter(f::Function; kwargs...)

where it will construct a `Crayon` using the keywords in `kwargs` and apply it to the
highlighted cell,

    Highlighter(f::Function, crayon::Crayon)

where it will apply the `crayon` to the highlighted cell, and

    Highlighter(f::Function, fd::Function)

where it will apply the `Crayon` returned by the function `fd` to the highlighted cell.

!!! info

    If only a single highlighter is wanted, it can be passed directly to the keyword
    `highlighter` without being inside a `Tuple`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

---

# HTML Back End

This back end produces HTML tables. This back end can be used by selecting
`backend = Val(:html)`.

## Keywords

- `allow_html_in_cells::Bool`: By default, special characters like `<`, `>`, `"`, etc. are
    replaced in HTML back end to generate valid code. However, this algorithm blocks the
    usage of HTML code inside of the cells. If this keyword is `true`, the escape algorithm
    **will not** be applied, allowing HTML code inside all the cells. In this case, the user
    must ensure that the output code is valid. If only few cells have HTML code, wrap in a
    [`HtmlCell`](@ref) object instead.
    (**Default** = `false`)
- `continuation_row_alignment::Symbol`: A symbol that defines the alignment of the cells in
    the continuation row. This row is printed if the table is vertically cropped.
    (**Default** = `:r`)
- `highlighters::Union{HtmlHighlighter, Tuple}`: An instance of [`HtmlHighlighter`](@ref) or
    a tuple with a list of HTML highlighters (see the section `HTML highlighters`).
- `linebreaks::Bool`: If `true`, `\\n` will be replaced by `<br>`. (**Default** = `false`)
- `maximum_columns_width::String`: A string with the maximum width of each columns. This
    string must contain a size that is valid in HTML. If it is not empty, each cell will
    have the following style:
    - `"max-width": <value of maximum_column_width>`
    - `"overflow": "hidden"`
    - `"text-overflow": "ellipsis"`
    - `"white-space": "nowrap"`
    If it is empty, no additional style is applied.
    (**Default** = "")
- `minify::Bool`: If `true`, output will be displayed minified, *i.e.* without unnecessary
    indentation or newlines.
    (**Default** = `false`)
- `standalone::Bool`: If `true`, a complete HTML page will be generated. Otherwise, only
    the content between the tags `<table>` and `</table>` will be printed (with the tags
    included).
    (**Default** = `false`)
- `vcrop_mode::Symbol`: This variable defines the vertical crop behavior. If it is
    `:bottom`, the data, if required, will be cropped in the bottom. On the other hand, if
    it is `:middle`, the data will be cropped in the middle if necessary.
    (**Default** = `:bottom`)
- `table_div_class::String`: The class name for the table `div`. It is only used if
    `wrap_table_in_div` is `true`.
    (**Default** = "")
- `table_class::String`: The class name for the table.
    (**Default** = "")
- `table_style::Dict{String, String}`: A dictionary containing the CSS properties and their
    values to be added to the table `style`.
    (**Default** = `Dict{String, String}()`)
- `tf::HtmlTableFormat`: An instance of the structure [`HtmlTableFormat`](@ref) that defines
    the general format of the HTML table.
- `top_left_str::String`: String to be printed at the left position of the top bar.
    (**Default** = "")
- `top_left_str_decoration::HtmlDecoration`: Decoration used to print the top-left string
    (see `top_left_str`).
    (**Default** = `HtmlDecoration()`)
- `top_right_str::String`: String to be printed at the right position of the top bar. Notice
    that this string will be replaced with the omitted cell summary if it must be displayed.
    (**Default** = "")
- `top_right_str_decoration::HtmlDecoration`: Decoration used to print the top-right string
    (see `top_right_str`).
    (**Default** = `HtmlDecoration()`)
- `wrap_table_in_div::Bool`: If `true`, the table will be wrapped in a `div`.
    (**Default**: `false`)

## HTML highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.  Each
highlighter is an instance of the structure [`HtmlHighlighter`](@ref). It contains the
following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i,j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return the `HtmlDecoration` to be applied to the cell
    that must be highlighted.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, and `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the highlight
style will be applied to the `(i, j)` element.  Otherwise, the default style will be used.

If the function `f` returns true, the function `fd(h, data, i, j)` will be called and must
return an element of type [`HtmlDecoration`](@ref) that contains the decoration to be
applied to the cell.

A HTML highlighter can be constructed using two helpers:

    HtmlHighlighter(f::Function, decoration::HtmlDecoration)

    HtmlHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`
whereas the second let the user select the desired decoration by specifying the function
`fd`.

!!! info

    If only a single highlighter is wanted, it can be passed directly to the keyword
    `highlighter` without being inside a `Tuple`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

---

# LaTeX Back End

This back end produces LaTeX tables. This back end can be used by selecting
`backend = Val(:latex)`.

## Keywords

- `body_hlines::Vector{Int}`: A vector of `Int` indicating row numbers in which an
    additional horizontal line should be drawn after the row. Notice that numbers lower than
    1 and equal or higher than the number of printed rows will be neglected. This vector
    will be appended to the one in `hlines`, but the indices here are related to the printed
    rows of the body. Thus, if `1` is added to `body_hlines`, a horizontal line will be
    drawn after the first data row.
    (**Default** = `Int[]`)
- `highlighters::Union{LatexHighlighter, Tuple}`: An instance of `LatexHighlighter` or a
    tuple with a list of LaTeX highlighters (see the section `LaTeX highlighters`).
- `hlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where the
    horizontal lines will be drawn. It can be `nothing`, `:all`, `:none` or a vector of
    integers.
    (**Default** = `nothing`)
    - If it is `nothing`, which is the default, the configuration will be obtained from the
        table format in the variable `tf` (see [`LatexTableFormat`](@ref)).
    - If it is `:all`, all horizontal lines will be drawn.
    - If it is `:none`, no horizontal line will be drawn.
    - If it is a vector of integers, the horizontal lines will be drawn only after the rows
        in the vector. Notice that the top line will be drawn if `0` is in `hlines`, and the
        header and subheaders are considered as only 1 row. Furthermore, it is important to
        mention that the row number in this variable is related to the **printed rows**.
        Thus, it is affected by the option to suppress the header `show_header`.  Finally,
        for convenience, the top and bottom lines can be drawn by adding the symbols
        `:begin` and `:end` to this vector, respectively, and the line after the header can
        be drawn by adding the symbol `:header`.

!!! info

    The values of `body_hlines` will be appended to this vector. Thus, horizontal lines can
    be drawn even if `hlines` is `:none`.

- `label::AbstractString`: The label of the table. If empty, no label will be added.
    (**Default** = "")
- `longtable_footer::Union{Nothing, AbstractString}`: The string that will be drawn in the
    footer of the tables before a page break. This only works if `table_type` is
    `:longtable`. If it is `nothing`, no footer will be used.
    (**Default** = `nothing`)
- `row_number_alignment::Symbol`: Select the alignment of the row number column (see the
    section `Alignment`).
    (**Default** = `:r`)
- `table_type::Union{Nothing, Symbol}`: Select which LaTeX environment will be used to print
    the table. Currently supported options are `:tabular` for `tabular` or `:longtable` for
    `longtable`. If it is `nothing` the default option of the table format will be used.
    (**Default** = `nothing`)
- `tf::LatexTableFormat`: An instance of the structure [`LatexTableFormat`](@ref) that
    defines the general format of the LaTeX table.
- `vlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where the
    vertical lines will be drawn. It can be `:all`, `:none` or a vector of integers. In the
    first case (the default behavior), all vertical lines will be drawn. In the second case,
    no vertical line will be drawn. In the third case, the vertical lines will be drawn only
    after the columns in the vector.  Notice that the left border will be drawn if `0` is in
    `vlines`.  Furthermore, it is important to mention that the column number in this
    variable is related to the **printed columns**. Thus, it is affected by the columns
    added using the variable `show_row_number`. Finally, for convenience, the left and right
    border can be drawn by adding the symbols `:begin` and `:end` to this vector,
    respectively.
    (**Default** = `:none`)
- `wrap_table::Union{Nothing, String}`: This variable controls whether to wrap the table in
    a environment defined by the variable `wrap_table_environment`.  Defaults to `true`.
    When `false`, the printed table begins with `\\begin{tabular}`. This option does not
    work with `:longtable`. If it is `nothing` the default option of the table format will
    be used.
    (**Default** = `nothing`)
- `wrap_table_environment::Union{Nothing, String}`: Environment that will be used to wrap
    the table if the option `wrap_table` is `true`. If it is `nothing` the default option of
    the table format will be used.
    (**Default** = `nothing`)

## LaTeX highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.  Each
highlighter is an instance of the structure [`LatexHighlighter`](@ref). It contains the
following two fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Functions`: A function with the signature `f(data, i, j, str)::String` in which
    `data` is the matrix, `(i, j)` is the element position in the table, and `str` is the
    data converted to string. This function must return a string that will be placed in the
    cell.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the highlight
style will be applied to the `(i, j)` element.  Otherwise, the default style will be used.

If the function `f` returns true, the function `fd(data, i, j, str)` will be called and must
return the LaTeX string that will be placed in the cell.

There are two helpers that can be used to create LaTeX highlighters:

    LatexHighlighter(f::Function, envs::Union{String,Vector{String}})

    LatexHighlighter(f::Function, fd::Function)

The first will apply recursively all the LaTeX environments in `envs` to the highlighted
text whereas the second let the user select the desired decoration by specifying the
function `fd`.

Thus, for example:

    LatexHighlighter((data, i, j) -> true, ["textbf", "small"])

will wrap all the cells in the table in the following environment:

    \\textbf{\\small{<Cell text>}}

!!! info

    If only a single highlighter is wanted, it can be passed directly to the keyword
    `highlighter` without being inside a `Tuple`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

---

# Markdown Back End

This back end produces Markdown tables. This back end can be used by selecting
`backend = Val(:markdown)`.

## Keywords

- `allow_markdown_in_cells::Bool`: By default, special markdown characters like `*`, `_`,
    `~`, etc. are escaped in markdown back end to generate valid output. However, this
    algorithm blocks the usage of markdown code inside of the cells. If this keyword is
    `true`, the escape algorithm **will not** be applied, allowing markdown code inside all
    the cells. In this case, the user must ensure that the output code is valid.
    (**Default** = `false`)
- `highlighters::Union{MarkdownHighlighter, Tuple}`: An instance of `MarkdownHighlighter` or
    a tuple with a list of Markdown highlighters (see the section
    [Markdown Highlighters](@ref)).
- `linebreaks::Bool`: If `true`, `\\n` will be replaced by `<br>`.
    (**Default** = `false`)
- `show_omitted_cell_summary::Bool`: If `true`, a summary will be printed after the table
    with the number of columns and rows that were omitted.
    (**Default** = `false`)

The following keywords are available to customize the output decoration:

- `header_decoration::MarkdownDecoration`: Decoration applied to the header.
    (**Default** = `MarkdownDecoration(bold = true)`)
- `row_label_decoration::MarkdownDecoration`: Decoration applied to the row label column.
    (**Default** = `MarkdownDecoration()`)
- `row_number_decoration::MarkdownDecoration`: Decoration applied to the row number column.
    (**Default** = `MarkdownDecoration(bold = true)`)
- `subheader_decoration::MarkdownDecoration`: Decoration applied to the sub-header.
    (**Default** = `MarkdownDecoration(code = true)`)

## Markdown Highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.  Each
highlighter is an instance of the structure [`MarkdownHighlighter`](@ref). It contains the
following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i,j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `fd(h, data, i, j)` in which `h` is the
    highlighter. This function must return the [`MarkdownDecoration`](@ref) to be applied to
    the cell that must be highlighted.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, and `i` and `j` are the
element coordinates that are being tested. If this function returns `true`, the highlight
style will be applied to the `(i, j)` element. Otherwise, the default style will be used.

If the function `f` returns true, the function `fd(h, data, i, j)` will be called and must
return an element of type [`MarkdownDecoration`](@ref) that contains the decoration to be
applied to the cell.

A markdown highlighter can be constructed using two helpers:

    MarkdownHighlighter(f::Function, decoration::MarkdownDecoration)

    MarkdownHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in `decoration`
whereas the second let the user select the desired decoration by specifying the function
`fd`.

!!! info

    If only a single highlighter is wanted, it can be passed directly to the keyword
    `highlighter` without being inside a `Tuple`.

!!! note

    If multiple highlighters are valid for the element `(i, j)`, the applied style will be
    equal to the first match considering the order in the tuple `highlighters`.

!!! note

    If the highlighters are used together with [Formatters](@ref), the change in the format
    **will not** affect the parameter `data` passed to the highlighter function `f`. It will
    always receive the original, unformatted value.

---

# Formatters

The keyword `formatters` can be used to pass functions to format the values in the columns.
It must be a tuple of functions in which each function has the following signature:

    f(v, i, j)

where `v` is the value in the cell, `i` is the row number, and `j` is the column number.
Thus, it must return the formatted value of the cell `(i, j)` that has the value `v`. Notice
that the returned value will be converted to string after using the function `sprint`.

This keyword can also be a single function, meaning that only one formatter is available, or
`nothing`, meaning that no formatter will be used.

For example, if we want to multiply all values in odd rows of the column 2 by π, the
formatter should look like:

    formatters = (v, i, j) -> (j == 2 && isodd(i)) ? v * π : v

If multiple formatters are available, they will be applied in the same order as they are
located in the tuple. Thus, for the following `formatters`:

    formatters = (f1, f2, f3)

each element `v` in the table (i-th row and j-th column) will be formatted by:

    v = f1(v,i,j)
    v = f2(v,i,j)
    v = f3(v,i,j)

Thus, the user must be ensure that the type of `v` between the calls are compatible.
"""
function pretty_table(@nospecialize(data::Any); kwargs...)
    io = stdout isa Base.TTY ? IOContext(stdout, :limit => true) : stdout
    pretty_table(io, data; kwargs...)
end

function pretty_table(::Type{String}, @nospecialize(data::Any); color::Bool = false, kwargs...)
    io = IOContext(IOBuffer(), :color => color)
    pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(::Type{HTML}, @nospecialize(data::Any); kwargs...)
    # If the keywords does not set the back end or the table format, use the HTML back end
    # by default.
    if !haskey(kwargs, :backend) && !haskey(kwargs, :tf)
        str = pretty_table(String, data; backend = Val(:html), kwargs...)
    else
        str = pretty_table(String, data; kwargs...)
    end

    return HTML(str)
end

function pretty_table(
    @nospecialize(io::IO),
    @nospecialize(data::Any);
    header::Union{Nothing, AbstractVector, Tuple} = nothing,
    kwargs...
)
    istable = Tables.istable(data)

    if istable
        if Tables.columnaccess(data)
            pdata, pheader = _preprocess_column_tables_jl(data, header)

        else
            # If we do not have column access, let's just assume row access as indicated
            # here:
            #
            #   https://github.com/ronisbr/PrettyTables.jl/issues/220
            pdata, pheader = _preprocess_row_tables_jl(data, header)
        end

    elseif data isa AbstractVecOrMat
        pdata, pheader = _preprocess_vec_or_mat(data, header)

    elseif data isa AbstractDict
        sortkeys = get(kwargs, :sortkeys, false)
        pdata, pheader = _preprocess_dict(data, header; sortkeys = sortkeys)

    else
        error("The type $(typeof(data)) is not supported.")
    end

    return _print_table(io, pdata; header = pheader, kwargs...)
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

# This function creates the structure that holds the global print information.
function _print_info(
    @nospecialize(data::Any),
    @nospecialize(io::IOContext);
    alignment::Union{Symbol, Vector{Symbol}} = :r,
    cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    formatters::Union{Nothing, Function, Tuple} = nothing,
    header::Union{Nothing, AbstractVector, Tuple} = nothing,
    header_alignment::Union{Symbol, Vector{Symbol}} = :s,
    header_cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    limit_printing::Bool = true,
    max_num_of_columns::Int = -1,
    max_num_of_rows::Int = -1,
    renderer::Symbol = :print,
    row_labels::Union{Nothing, AbstractVector} = nothing,
    row_label_alignment::Symbol = :r,
    row_label_column_title::AbstractString = "",
    row_number_alignment::Symbol = :r,
    row_number_column_title::AbstractString = "Row",
    show_header::Bool = true,
    show_row_number::Bool = false,
    show_subheader::Bool = true,
    title::AbstractString = "",
    title_alignment::Symbol = :l
)

    _header = header isa Tuple ? header : (header,)

    # Create the processed table, which holds additional information about how we must print
    # the table.
    ptable = ProcessedTable(
        data,
        _header;
        alignment             = alignment,
        cell_alignment        = cell_alignment,
        header_alignment      = header_alignment,
        header_cell_alignment = header_cell_alignment,
        max_num_of_columns    = max_num_of_columns,
        max_num_of_rows       = max_num_of_rows,
        show_header           = show_header,
        show_subheader        = show_subheader,
    )

    # Add the additional columns if requested.
    if show_row_number
        _add_column!(
            ptable,
            axes(data)[1] |> collect,
            [row_number_column_title];
            alignment = row_number_alignment,
            id = :row_number
        )
    end

    if row_labels !== nothing
        _add_column!(
            ptable,
            row_labels,
            [row_label_column_title];
            alignment = row_label_alignment,
            id = :row_label
        )
    end

    # Make sure that `formatters` is a tuple.
    formatters === nothing  && (formatters = ())
    typeof(formatters) <: Function && (formatters = (formatters,))

    # Render.
    renderer_val = renderer == :show ? Val(:show) : Val(:print)

    # Create the structure that stores the print information.
    pinfo = PrintInfo(
        ptable,
        io,
        formatters,
        compact_printing,
        title,
        title_alignment,
        cell_first_line_only,
        renderer_val,
        limit_printing,
    )

    return pinfo
end

# This is the low level function that prints the table. In this case, `data` must be
# accessed by `[i, j]` and the size of the `header` must be equal to the number of columns
# in `data`.
function _print_table(
    @nospecialize(io::IO),
    @nospecialize(data::Any);
    alignment::Union{Symbol, Vector{Symbol}} = :r,
    backend::T_BACKENDS = Val(:auto),
    cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    formatters::Union{Nothing, Function, Tuple} = nothing,
    header::Union{Nothing, AbstractVector, Tuple} = nothing,
    header_alignment::Union{Symbol, Vector{Symbol}} = :s,
    header_cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    limit_printing::Bool = true,
    max_num_of_columns::Int = -1,
    max_num_of_rows::Int = -1,
    renderer::Symbol = :print,
    row_labels::Union{Nothing, AbstractVector} = nothing,
    row_label_alignment::Symbol = :r,
    row_label_column_title::AbstractString = "",
    row_number_alignment::Symbol = :r,
    row_number_column_title::AbstractString = "Row",
    show_header::Bool = true,
    show_row_number::Bool = false,
    show_subheader::Bool = true,
    title::AbstractString = "",
    title_alignment::Symbol = :l,
    kwargs...
)

    if backend === Val(:auto)
        # In this case, if we do not have the `tf` keyword, then we just fallback to the
        # text back end. Otherwise, check if the type of `tf`.
        if haskey(kwargs, :tf)
            tf = kwargs[:tf]

            if tf isa TextFormat
                backend = Val(:text)
            elseif tf isa HtmlTableFormat
                backend = Val(:html)
            elseif tf isa LatexTableFormat
                backend = Val(:latex)
            else
                throw(
                    TypeError(
                        :_pt,
                        Union{TextFormat, HtmlTableFormat, LatexTableFormat},
                        typeof(tf)
                    )
                )
            end
        else
            backend = Val(:text)
        end
    end

    # Verify if we have a circular reference.
    ptd = get(io, :__PRETTY_TABLES_DATA__, nothing)

    if ptd !== nothing
        context = IOContext(io)

        # In this case, `ptd` is a vector with the data printed by PrettyTables.jl. Hence,
        # we need to search if the current one is inside this vector. If true, we have a
        # circular dependency.
        for d in ptd
            if d === _getdata(data)

                if backend === Val(:text)
                    _pt_text_circular_reference(context)
                elseif backend === Val(:html)
                    _pt_html_circular_reference(context)
                elseif backend === Val(:latex)
                    _pt_latex_circular_reference(context)
                end

                return nothing
            end
        end

        # Otherwise, we must push the current data to the vector.
        push!(ptd, _getdata(data))
    else
        context = IOContext(io, :__PRETTY_TABLES_DATA__ => Any[_getdata(data)])
    end

    # Create the structure that stores the print information.
    pinfo = _print_info(
        data,
        context;
        alignment               = alignment,
        cell_alignment          = cell_alignment,
        cell_first_line_only    = cell_first_line_only,
        compact_printing        = compact_printing,
        formatters              = formatters,
        header                  = header,
        header_alignment        = header_alignment,
        header_cell_alignment   = header_cell_alignment,
        max_num_of_columns      = max_num_of_columns,
        max_num_of_rows         = max_num_of_rows,
        limit_printing          = limit_printing,
        renderer                = renderer,
        row_labels              = row_labels,
        row_label_alignment     = row_label_alignment,
        row_label_column_title  = row_label_column_title,
        row_number_alignment    = row_number_alignment,
        row_number_column_title = row_number_column_title,
        show_header             = show_header,
        show_row_number         = show_row_number,
        show_subheader          = show_subheader,
        title                   = title,
        title_alignment         = title_alignment
    )

    # Select the appropriate back end.
    if backend === Val(:text)
        _print_table_with_text_back_end(pinfo; kwargs...)

    elseif backend === Val(:html)
        # When wrapping `stdout` in `IOContext` in Jupyter, `io.io` is not equal to `stdout`
        # anymore. Hence, we need to check if `io` is `stdout` before calling `_pt_html`.
        is_stdout = (io === stdout) || ((io isa IOContext) && (io.io === stdout))
        _print_table_with_html_back_end(pinfo; is_stdout = is_stdout, kwargs...)

    elseif backend === Val(:latex)
        _print_table_with_latex_back_end(pinfo; kwargs...)

    elseif backend === Val(:markdown)
        return _print_table_with_markdown_back_end(pinfo; kwargs...)
    end

    return nothing
end
