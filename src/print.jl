# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to print the tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export pretty_table

################################################################################
#                               Public Functions
################################################################################

"""
    pretty_table([io::IO | String | HTML,] table;  kwargs...)

Print to `io` the `table`.

If `io` is omitted, then it defaults to `stdout`. If `String` is passed in the
place of `io`, then a `String` with the printed table will be returned by the
function. If `HTML` is passed in the place of `io`, then an `HTML` object is
returned with the printed table.

When printing, it will be verified if `table` complies with **Tables.jl** API.
If it is compliant, then this interface will be used to print the table. If it
is not compliant, then only the following types are supported:

1. `AbstractVector`: any vector can be printed.
2. `AbstractMatrix`: any matrix can be printed.
3. `Dict`: any `Dict` can be printed. In this case, the special keyword
    `sortkeys` can be used to select whether or not the user wants to print the
    dictionary with the keys sorted. If it is `false`, then the elements will be
    printed on the same order returned by the functions `keys` and `values`.
    Notice that this assumes that the keys are sortable, if they are not, then
    an error will be thrown.

# Keywords

- `alignment::Union{Symbol, Vector{Symbol}}`: Select the alignment of the
    columns (see the section `Alignment`).
- `backend::Union{Symbol, T_BACKENDS}`: Select which back-end will be used to
    print the table (see the section `Backend`). Notice that the
    additional configuration in `kwargs...` depends on the selected backend.
- `cell_alignment::Union{Nothing, Dict{Tuple{Int, Int}, Symbol}, Function, Tuple}`:
    A tuple of functions with the signature `f(data, i, j)` that overrides the
    alignment of the cell `(i, j)` to the value returned by `f`. It can also be a
    single function, when it is assumed that only one alignment function is
    required, or `nothing`, when no cell alignment modification will be
    performed. If the function `f` does not return a valid alignment symbol as
    shown in section `Alignment`, then it will be discarded. For
    convenience, it can also be a dictionary of type `(i, j) => a` that
    overrides the alignment of the cell `(i, j)` to `a`. `a` must be a symbol
    like specified in the section `Alignment`. (**Default** = `nothing`)

!!! note
    If more than one alignment function is passed to `cell_alignment`, then
    the functions will be evaluated in the same order of the tuple. The
    first one that returns a valid alignment symbol for each cell is applied,
    and the rest is discarded.

- `cell_first_line_only::Bool`: If `true`, then only the first line of each cell
    will be printed. (**Default** = `false`)
- `compact_printing::Bool`: Select if the option `:compact` will be used when
    printing the data. (**Default** = `true`)
- `filters_row::Union{Nothing, Tuple}`: Filters for the rows (see the section
    `Filters`).
- `filters_col::Union{Nothing, Tuple}`: Filters for the columns (see the section
    `Filters`).
- `formatters::Union{Nothing, Function, Tuple}`: See the section
    `Formatters`.
- `header::Union{Symbol, Vector{Symbol}}`: The header must be a tuple of
    vectors. Each one must have the number of elements equal to the number of
    columns in the table. The first vector is considered the header and the
    others are the subheaders. If it is `nothing`, then a default value based on
    the type will be used. If a single vector is passed, then it will be
    considered the header. (**Default** = `nothing`)
- `header_alignment::Union{Symbol, Vector{Symbol}}`: Select the alignment of the
    header columns (see the section `Alignment`). If the symbol that
    specifies the alignment is `:s` for a specific column, then the same
    alignment in the keyword `alignment` for that column will be used.
    (**Default** = `:s`)
- `header_cell_alignment::Union{Nothing, Dict{Tuple{Int, Int}, Symbol}, Function, Tuple}`:
    This keyword has the same structure of `cell_alignment` but in this case it
    operates in the header. Thus, `(i, j)` will be a cell in the header matrix
    that contains the header and sub-headers. This means that the `data` field
    in the functions will be the same value passed in the keyword `header`.
    (**Default** = `nothing`)

!!! note
      If more than one alignment function is passed to `header_cell_alignment`,
      then the functions will be evaluated in the same order of the tuple. The
      first one that returns a valid alignment symbol for each cell is applied,
      and the rest is discarded.

- `limit_printing::Bool`: If `true`, then the cells will be converted using the
    property `:limit => true` of `IOContext`. (**Default** = `true`)
- `renderer::Symbol`: A symbol that indicates which function should be used to
    convert an object to a string. It can be `:print` to use the function
    `print` or `:show` to use the function `show`. Notice that this selection is
    applicable only to the table data. Headers, sub-headers, and row name column
    are always rendered with print. (**Default** = `:print`)
- `row_names::Union{Nothing, AbstractVector}`: A vector containing the row names
    that will be appended to the left of the table. If it is `nothing`, then the
    column with the row names will not be shown. Notice that the size of this
    vector must match the number of rows in the table. (**Default** = `nothing`)
- `row_name_alignment::Symbol`: Alignment of the column with the rows name (see
    the section `Alignment`).
- `row_name_column_title::AbstractString`: Title of the column with the row
    names. (**Default** = "")
- `row_number_column_title::AbstractString`: Title of the column with the row
    numbers. (**Default** = "Row")
- `show_row_number::Bool`: If `true`, then a new column will be printed showing
    the row number. (**Default** = `false`)
- `title::AbstractString`: The title of the table. If it is empty, then no title
    will be printed. (**Default** = "")
- `title_alignment::Symbol`: Alignment of the title, which must be a symbol as
    explained in the section `Alignment`. This argument is ignored in the
    LaTeX backend. (**Default** = :l)

!!! note
    Notice that all back-ends have the keyword `tf` to specify the table
    printing format. Thus, if the keyword `backend` is not present or if it is
    `nothing`, then the back-end will be automatically inferred from the type of
    the keyword `tf`. In this case, if `tf` is also not present, then it just
    fall-back to the text back-end unless `HTML` is passed as the first
    argument. In this case, the default back-end is set to HTML.

If `String` is used, then the keyword `color` selects whether or not the table
will be converted to string with or without colors. The default value is
`false`. Notice that this option only has effect in text backend.

# Alignment

The keyword `alignment` can be a `Symbol` or a vector of `Symbol`.

If it is a symbol, we have the following behavior:

- `:l` or `:L`: the text of all columns will be left-aligned;
- `:c` or `:C`: the text of all columns will be center-aligned;
- `:r` or `:R`: the text of all columns will be right-aligned;
- Otherwise it defaults to `:r`.

If it is a vector, then it must have the same number of symbols as the number of
columns in `data`. The *i*-th symbol in the vector specify the alignment of the
-i*-th column using the same symbols as described previously.

!!! note
    In HTML backend, the user can select `:n` ou `:N` to print the cell without
    any alignment annotation.

# Filters

It is possible to specify filters to filter the data that will be printed. There
are two types of filters: the row filters, which are specified by the keyword
`filters_row`, and the column filters, which are specified by the keyword
`filters_col`.

The filters are a tuple of functions that must have the following signature:

```julia
f(data,i)::Bool
```

in which `data` is a pointer to the matrix that is being printed and `i` is the
i-th row in the case of the row filters or the i-th column in the case of column
filters. If this function returns `true` for `i`, then the i-th row (in case of
`filters_row`) or the i-th column (in case of `filters_col`) will be printed.
Otherwise, it will be omitted.

A set of filters can be passed inside of a tuple. Notice that, in this case,
**all filters** for a specific row or column must be return `true` so that it
can be printed, *i.e* the set of filters has an `AND` logic.

If the keyword is set to `nothing`, which is the default, then no filtering will
be applied to the data.

!!! note
    The filters do not change the row and column numbering for the others
    modifiers such as column width specification, formatters, and highlighters.
    Thus, for example, if only the 4-th row is printed, then it will also be
    referenced inside the formatters and highlighters as 4 instead of 1.

---

# Pretty table text back-end

This back-end produces text tables. This back-end can be used by selecting
`back-end = :text`.

# Keywords

- `border_crayon::Crayon`: Crayon to print the border.
- `header_crayon::Union{Crayon, Vector{Crayon}}`: Crayon to print the header.
- `subheader_crayon::Union{Crayon, Vector{Crayon}}`: Crayon to print
    sub-headers.
- `rownum_header_crayon::Crayon`: Crayon for the header of the column with the
    row numbers.
- `text_crayon::Crayon`: Crayon to print default text.
- `omitted_cell_summary_crayon::Crayon`: Crayon used to print the omitted cell
    summary.
- `alignment_anchor_fallback::Symbol`: This keyword controls the line alignment
    when using the regex alignment anchors if a match is not found. If it is
    `:l`, then the left of the line will be aligned with the anchor. If it is
    `:c`, then the line center will be aligned with the anchor. Otherwise, the
    end of the line will be aligned with the anchor. (**Default** = `:l`)
- `alignment_anchor_fallback_override::Dict{Int, Symbol}`: A `Dict{Int, Symbol}`
    to override the behavior of `fallback_alignment_anchor` for a specific
    column. Example: `Dict(3 => :c)` changes the fallback alignment anchor
    behavior for `:c` only for the column 3.
- `alignment_anchor_regex::Dict{Int, AbstractVector{Regex}}`: A dictionary
    `Dict{Int, AbstractVector{Regex}}` with a set of regexes that is used to
    align the values in the columns (keys). The characters at the first regex
    match (or anchor) of each line in every cell of the column will be aligned.
    The regex match is searched in the same order as the regexes appear on the
    vector. The regex matching is applied after the cell conversion to string,
    which includes the formatters. If no match is found for a specific line,
    then the alignment of this line depends on the options
    `alignment_anchor_fallback` and `alignment_anchor_fallback_override`. If the
    key `0` is present, then the related regexes will be used to align all the
    columns. In this case, all the other keys will be neglected. Example:
    `Dict(2 => [r"\\."])` aligns the decimal point of the cells in the second
    column. (**Default** = `Dict{Int, Vector{Regex}}()`)
- `autowrap::Bool`: If `true`, then the text will be wrapped on spaces to fit
    the column. Notice that this function requires `linebreaks = true` and the
    column must have a fixed size (see `columns_width`).
- `body_hlines::Vector{Int}`: A vector of `Int` indicating row numbers in which
    an additional horizontal line should be drawn after the row. Notice that
    numbers lower than 1 and equal or higher than the number of printed rows
    will be neglected. This vector will be appended to the one in `hlines`, but
    the indices here are related to the printed rows of the body. Thus, if `1`
    is added to `body_hlines`, then a horizontal line will be drawn after the
    first data row. (**Default** = `Int[]`)
- `body_hlines_format::Union{Nothing, NTuple{4, Char}}`: A tuple of 4 characters
    specifying the format of the horizontal lines that will be drawn by
    `body_hlines`. The characters must be the left intersection, the middle
    intersection, the right intersection, and the row. If it is `nothing`, then
    it will use the same format specified in `tf`. (**Default** = `nothing`)
- `columns_width::Union{Int, AbstractVector{Int}}`: A set of integers specifying
    the width of each column. If the width is equal or lower than 0, then it
    will be automatically computed to fit the large cell in the column. If it is
    a single integer, then this number will be used as the size of all columns.
    (**Default** = 0)
- `crop::Symbol`: Select the printing behavior when the data is bigger than the
    available display size (see `display_size`). It can be `:both` to crop on
    vertical and horizontal direction, `:horizontal` to crop only on horizontal
    direction, `:vertical` to crop only on vertical direction, or `:none` to do
    not crop the data at all. If the `io` has `:limit => true`, then `crop` is
    set to `:both` by default. Otherwise, it is set to `:none` by default.
- `crop_num_lines_at_beginning::Int`: Number of lines to be left at the
    beginning of the printing when vertically cropping the output. Notice that
    the lines required to show the title are automatically computed.
    (**Default** = 0)
- `crop_subheader::Bool`: If `true`, then the sub-header size will not be taken
    into account when computing the column size. Hence, the print algorithm can
    crop it to save space. This has no effect if the user selects a fixed column
    width. (**Default** = `false`)
- `continuation_row_alignment::Symbol`: A symbol that defines the alignment of
    the cells in the continuation row. This row is printed if the table is
    vertically cropped. (**Default** = `:c`)
- `display_size::Tuple{Int, Int}`: A tuple of two integers that defines the
    display size (num. of rows, num. of columns) that is available to print the
    table. It is used to crop the data depending on the value of the keyword
    `crop`. Notice that if a dimension is not positive, then it will be treated
    as unlimited. (**Default** = `displaysize(io)`)
- `ellipsis_line_skip::Integer`: An integer defining how many lines will be
    skipped from showing the ellipsis that indicates the text was cropped.
    (**Default** = 0)
- `equal_columns_width::Bool`: If `true`, then all the columns will have the
    same width. (**Default** = `false`)
- `highlighters::Union{Highlighter, Tuple}`: An instance of `Highlighter` or a
    tuple with a list of text highlighters (see the section `Text
    highlighters`).
- `hlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where
    the horizontal lines will be drawn. It can be `nothing`, `:all`, `:none` or
    a vector of integers. (**Default** = `nothing`)
    - If it is `nothing`, which is the default, then the configuration will be
        obtained from the table format in the variable `tf` (see
        [`TextFormat`](@ref)).
    - If it is `:all`, then all horizontal lines will be drawn.
    - If it is `:none`, then no horizontal line will be drawn.
    - If it is a vector of integers, then the horizontal lines will be drawn
        only after the rows in the vector. Notice that the top line will be
        drawn if `0` is in `hlines`, and the header and subheaders are
        considered as only 1 row. Furthermore, it is important to mention that
        the row number in this variable is related to the **printed rows**.
        Thus, it is affected by filters, and by the option to suppress the
        header `noheader`. Finally, for convenience, the top and bottom lines
        can be drawn by adding the symbols `:begin` and `:end` to this vector,
        respectively, and the line after the header can be drawn by adding the
        symbol `:header`.

!!! info
    The values of `body_hlines` will be appended to this vector. Thus,
    horizontal lines can be drawn even if `hlines` is `:none`.

- `linebreaks::Bool`: If `true`, then `\\n` will break the line inside the
    cells. (**Default** = `false`)
- `maximum_columns_width::Union{Int, AbstractVector{Int}}`: A set of integers
    specifying the maximum width of each column. If the width is equal or lower
    than 0, then it will be ignored. If it is a single integer, then this number
    will be used as the maximum width of all columns. Notice that the parameter
    `columns_width` has precedence over this one. (**Default** = 0)
- `minimum_columns_width::Union{Int, AbstractVector{Int}}`: A set of integers
    specifying the minimum width of each column. If the width is equal or lower
    than 0, then it will be ignored. If it is a single integer, then this number
    will be used as the minimum width of all columns. Notice that the parameter
    `columns_width` has precedence over this one. (**Default** = 0)
- `newline_at_end::Bool`: If `false`, then the table will not end with a newline
    character. (**Default** = `true`)
- `noheader::Bool`: If `true`, then the header will not be printed. Notice that
    all keywords and parameters related to the header and sub-headers will be
    ignored. (**Default** = `false`)
- `nosubheader::Bool`: If `true`, then the sub-header will not be printed,
    *i.e.* the header will contain only one line. Notice that this option has no
    effect if `noheader = true`. (**Default** = `false`)
- `overwrite::Bool`: If `true`, then the same number of lines in the printed
    table will be deleted from the output `io`. This can be used to update the
    table in the display continuously. (**Default** = `false`)
- `row_number_alignment::Symbol`: Select the alignment of the row number column
    (see the section `Alignment`). (**Default** = `:r`)
- `show_omitted_cell_summary::Bool`: If `true`, then a summary will be printed
    after the table with the number of columns and rows that were omitted.
    (**Default** = `true`)
- `tf::TextFormat`: Table format used to print the table (see
    [`TextFormat`](@ref)). (**Default** = `tf_unicode`)
- `title_autowrap::Bool`: If `true`, then the title text will be wrapped
    considering the title size. Otherwise, lines larger than the title size will
    be cropped. (**Default** = `false`)
- `title_crayon::Crayon`: Crayon to print the title.
- `title_same_width_as_table::Bool`: If `true`, then the title width will match
    that of the table. Otherwise, the title size will be equal to the display
    width. (**Default** = `false`)
- `vcrop_mode::Symbol`: This variable defines the vertical crop behavior. If it
    is `:bottom`, then the data, if required, will be cropped in the bottom. On
    the other hand, if it is `:middle`, then the data will be cropped in the
    middle if necessary. (**Default** = `:bottom`)
- `vlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where
    the vertical lines will be drawn. It can be `nothing`, `:all`, `:none` or a
    vector of integers. (**Default** = `nothing`)
    - If it is `nothing`, which is the default, then the configuration will be
        obtained from the table format in the variable `tf` (see
        [`TextFormat`](@ref)).
    - If it is `:all`, then all vertical lines will be drawn.
    - If it is `:none`, then no vertical line will be drawn.
    - If it is a vector of integers, then the vertical lines will be drawn only
        after the columns in the vector. Notice that the top line will be drawn
        if `0` is in `vlines`. Furthermore, it is important to mention that the
        column number in this variable is related to the **printed column**.
        Thus, it is affected by filters, and by the options `row_names` and
        `show_row_number`. Finally, for convenience, the left and right vertical
        lines can be drawn by adding the symbols `:begin` and `:end` to this
        vector, respectively, and the line after the header can be drawn by
        adding the symbol `:header`.

The keywords `header_crayon` and `subheader_crayon` can be a `Crayon` or a
`Vector{Crayon}`. In the first case, the `Crayon` will be applied to all the
elements. In the second, each element can have its own crayon, but the length of
the vector must be equal to the number of columns in the data.

## Crayons

A `Crayon` is an object that handles a style for text printed on terminals. It
is defined in the package
[Crayons.jl](https://github.com/KristofferC/Crayons.jl). There are many options
available to customize the style, such as foreground color, background color,
bold text, etc.

A `Crayon` can be created in two different ways:

```julia-repl
julia> Crayon(foreground = :blue, background = :black, bold = :true)

julia> crayon"blue bg:black bold"
```

For more information, see the package documentation.

## Text highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.
Each highlighter is an instance of the structure `Highlighter` that contains
three fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should
    return `true` if the element `(i, j)` in `data` must be highlighter, or
    `false` otherwise.
- `fd::Function`: Function with the signature `f(h,data,i,j)` in which `h` is
    the highlighter. This function must return the `Crayon` to be applied to the
    cell that must be highlighted.
- `crayon::Crayon`: The `Crayon` to be applied to the highlighted cell if the
    default `fd` is used.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, and `i` and
`j` are the element coordinates that are being tested. If this function returns
`true`, then the cell `(i, j)` will be highlighted.

If the function `f` returns true, then the function `fd(h, data, i, j)` will be
called and must return a `Crayon` that will be applied to the cell.

A highlighter can be constructed using three helpers:

    Highlighter(f::Function; kwargs...)

where it will construct a `Crayon` using the keywords in `kwargs` and apply it
to the highlighted cell,

    Highlighter(f::Function, crayon::Crayon)

where it will apply the `crayon` to the highlighted cell, and

    Highlighter(f::Function, fd::Function)

where it will apply the `Crayon` returned by the function `fd` to the
highlighted cell.

!!! info
    If only a single highlighter is wanted, then it can be passed directly to
    the keyword `highlighter` without being inside a `Tuple`.

!!! note
    If multiple highlighters are valid for the element `(i, j)`, then the
    applied style will be equal to the first match considering the order in the
    tuple `highlighters`.

!!! note
    If the highlighters are used together with [Formatters](@ref), then the
    change in the format **will not** affect the parameter `data` passed to the
    highlighter function `f`. It will always receive the original, unformatted
    value.

---

# Pretty table HTML backend

This backend produces HTML tables. This backend can be used by selecting
`backend = Val(:html)`.

# Keywords

- `allow_html_in_cells::Bool`: By default, special characters like `<`, `>`,
    `"`, etc. are replaced in HTML backend to generate valid code. However, this
    algorithm blocks the usage of HTML code inside of the cells. If this keyword
    is `true`, then the escape algorithm **will not** be applied, allowing HTML
    code inside all the cells. In this case, the user must ensure that the
    output code is valid. (**Default** = `false`)
- `highlighters::Union{HTMLHighlighter, Tuple}`: An instance of
    [`HTMLHighlighter`](@ref) or a tuple with a list of HTML highlighters (see
    the section `HTML highlighters`).
- `linebreaks::Bool`: If `true`, then `\\n` will be replaced by `<br>`.
    (**Default** = `false`)
- `minify::Bool`: If `true`, then output will be displayed minified, *i.e.*
    without unnecessary indentation or newlines. (**Default** = `false`)
- `noheader::Bool`: If `true`, then the header will not be printed. Notice that
    all keywords and parameters related to the header and sub-headers will be
    ignored. (**Default** = `false`)
- `nosubheader::Bool`: If `true`, then the sub-header will not be printed,
    *i.e.* the header will contain only one line. Notice that this option has no
    effect if `noheader = true`. (**Default** = `false`)
- `standalone::Bool`: If `true`, then a complete HTML page will be generated.
    Otherwise, only the content between the tags `<table>` and `</table>` will
    be printed (with the tags included). (**Default** = `true`)
- `tf::HTMLTableFormat`: An instance of the structure [`HTMLTableFormat`](@ref)
    that defines the general format of the HTML table.

## HTML highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.
Each highlighter is an instance of the structure [`HTMLHighlighter`](@ref). It
contains the following two public fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should
    return `true` if the element `(i,j)` in `data` must be highlighted, or
    `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is
    the highlighter. This function must return the `HTMLDecoration` to be
    applied to the cell that must be highlighted.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, and `i` and
`j` are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i, j)` element.
Otherwise, the default style will be used.

If the function `f` returns true, then the function `fd(h, data, i, j)` will be
called and must return an element of type [`HTMLDecoration`](@ref) that contains
the decoration to be applied to the cell.

A HTML highlighter can be constructed using two helpers:

    HTMLHighlighter(f::Function, decoration::HTMLDecoration)

    HTMLHighlighter(f::Function, fd::Function)

The first will apply a fixed decoration to the highlighted cell specified in
`decoration` whereas the second let the user select the desired decoration by
specifying the function `fd`.

!!! info
    If only a single highlighter is wanted, then it can be passed directly to
    the keyword `highlighter` without being inside a `Tuple`.

!!! note
    If multiple highlighters are valid for the element `(i, j)`, then the
    applied style will be equal to the first match considering the order in the
    tuple `highlighters`.

!!! note
    If the highlighters are used together with [Formatters](@ref), then the
    change in the format **will not** affect the parameter `data` passed to the
    highlighter function `f`. It will always receive the original, unformatted
    value.

---

# Pretty table LaTeX backend

This backend produces LaTeX tables. This backend can be used by selecting
`backend = Val(:latex)`.

# Keywords

- `body_hlines::Vector{Int}`: A vector of `Int` indicating row numbers in which
    an additional horizontal line should be drawn after the row. Notice that
    numbers lower than 1 and equal or higher than the number of printed rows
    will be neglected. This vector will be appended to the one in `hlines`, but
    the indices here are related to the printed rows of the body. Thus, if `1`
    is added to `body_hlines`, then a horizontal line will be drawn after the
    first data row. (**Default** = `Int[]`)
- `highlighters::Union{LatexHighlighter, Tuple}`: An instance of
    `LatexHighlighter` or a tuple with a list of LaTeX highlighters (see the
    section `LaTeX highlighters`).
- `hlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where
    the horizontal lines will be drawn. It can be `nothing`, `:all`, `:none` or
    a vector of integers. (**Default** = `nothing`)
    - If it is `nothing`, which is the default, then the configuration will be
        obtained from the table format in the variable `tf` (see
        [`LatexTableFormat`](@ref)).
    - If it is `:all`, then all horizontal lines will be drawn.
    - If it is `:none`, then no horizontal line will be drawn.
    - If it is a vector of integers, then the horizontal lines will be drawn
        only after the rows in the vector. Notice that the top line will be
        drawn if `0` is in `hlines`, and the header and subheaders are
        considered as only 1 row. Furthermore, it is important to mention that
        the row number in this variable is related to the **printed rows**.
        Thus, it is affected by filters, and by the option to suppress the
        header `noheader`. Finally, for convenience, the top and bottom lines
        can be drawn by adding the symbols `:begin` and `:end` to this vector,
        respectively, and the line after the header can be drawn by adding the
        symbol `:header`.

!!! info
    The values of `body_hlines` will be appended to this vector. Thus,
    horizontal lines can be drawn even if `hlines` is `:none`.

- `label::AbstractString`: The label of the table. If empty, then no label will
    be added. (**Default** = "")
- `longtable_footer::Union{Nothing, AbstractString}`: The string that will be
    drawn in the footer of the tables before a page break. This only works if
    `table_type` is `:longtable`. If it is `nothing`, then no footer will be
    used. (**Default** = `nothing`)
- `noheader::Bool`: If `true`, then the header will not be printed. Notice that
    all keywords and parameters related to the header and sub-headers will be
    ignored. (**Default** = `false`)
- `nosubheader::Bool`: If `true`, then the sub-header will not be printed,
    *i.e.* the header will contain only one line. Notice that this option has no
    effect if `noheader = true`. (**Default** = `false`)
- `row_number_alignment::Symbol`: Select the alignment of the row number column
    (see the section `Alignment`). (**Default** = `:r`)
- `table_type::Union{Nothing, Symbol}`: Select which LaTeX environment will be
    used to print the table. Currently supported options are `:tabular` for
    `tabular` or `:longtable` for `longtable`. If it is `nothing` then the
    default option of the table format will be used. (**Default** = `nothing`)
- `tf::LatexTableFormat`: An instance of the structure
    [`LatexTableFormat`](@ref) that defines the general format of the LaTeX table.
- `vlines::Union{Nothing, Symbol, AbstractVector}`: This variable controls where
    the vertical lines will be drawn. It can be `:all`, `:none` or a vector of
    integers. In the first case (the default behavior), all vertical lines will
    be drawn. In the second case, no vertical line will be drawn. In the third
    case, the vertical lines will be drawn only after the columns in the vector.
    Notice that the left border will be drawn if `0` is in `vlines`.
    Furthermore, it is important to mention that the column number in this
    variable is related to the **printed columns**. Thus, it is affected by
    filters, and by the columns added using the variable `show_row_number`.
    Finally, for convenience, the left and right border can be drawn by adding
    the symbols `:begin` and `:end` to this vector, respectively.
    (**Default** = `:none`)
- `wrap_table::Union{Nothing, String}`: This variable controls whether to wrap
    the table in a environment defined by the variable `wrap_table_environment`.
    Defaults to `true`. When `false`, the printed table begins with
    `\\begin{tabular}`. This option does not work with `:longtable`. If it is
    `nothing` then the default option of the table format will be used.
    (**Default** = `nothing`)
- `wrap_table_environment::Union{Nothing, String}`: Environment that will be
    used to wrap the table if the option `wrap_table` is `true`. If it is
    `nothing` then the default option of the table format will be used.
    (**Default** = `nothing`)

## LaTeX highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighters` keyword.
Each highlighter is an instance of the structure [`LatexHighlighter`](@ref). It
contains the following two fields:

- `f::Function`: Function with the signature `f(data, i, j)` in which should
    return `true` if the element `(i, j)` in `data` must be highlighted, or
    `false` otherwise.
- `fd::Functions`: A function with the signature `f(data, i, j, str)::String` in
    which `data` is the matrix, `(i, j)` is the element position in the table,
    and `str` is the data converted to string. This function must return a
    string that will be placed in the cell.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j`
are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i, j)` element.
Otherwise, the default style will be used.

If the function `f` returns true, then the function `fd(data, i, j, str)` will
be called and must return the LaTeX string that will be placed in the cell.

There are two helpers that can be used to create LaTeX highlighters:

    LatexHighlighter(f::Function, envs::Union{String,Vector{String}})

    LatexHighlighter(f::Function, fd::Function)

The first will apply recursively all the LaTeX environments in `envs` to the
highlighted text whereas the second let the user select the desired decoration
by specifying the function `fd`.

Thus, for example:

    LatexHighlighter((data, i, j) -> true, ["textbf", "small"])

will wrap all the cells in the table in the following environment:

    \\textbf{\\small{<Cell text>}}

!!! info
    If only a single highlighter is wanted, then it can be passed directly to
    the keyword `highlighter` without being inside a `Tuple`.

!!! note
    If multiple highlighters are valid for the element `(i, j)`, then the
    applied style will be equal to the first match considering the order in the
    tuple `highlighters`.

!!! note
    If the highlighters are used together with [Formatters](@ref), then the
    change in the format **will not** affect the parameter `data` passed to the
    highlighter function `f`. It will always receive the original, unformatted
    value.

---

# Formatters

The keyword `formatters` can be used to pass functions to format the values in
the columns. It must be a tuple of functions in which each function has the
following signature:

    f(v, i, j)

where `v` is the value in the cell, `i` is the row number, and `j` is the column
number. Thus, it must return the formatted value of the cell `(i, j)` that has
the value `v`. Notice that the returned value will be converted to string after
using the function `sprint`.

This keyword can also be a single function, meaning that only one formatter is
available, or `nothing`, meaning that no formatter will be used.

For example, if we want to multiply all values in odd rows of the column 2 by π,
then the formatter should look like:

    formatters = (v, i, j) -> (j == 2 && isodd(i)) ? v * π : v

If multiple formatters are available, then they will be applied in the same
order as they are located in the tuple. Thus, for the following `formatters`:

    formatters = (f1, f2, f3)

each element `v` in the table (i-th row and j-th column) will be formatted by:

    v = f1(v,i,j)
    v = f2(v,i,j)
    v = f3(v,i,j)

Thus, the user must be ensure that the type of `v` between the calls are
compatible.

"""
@inline function pretty_table(data; kwargs...)
    io = stdout isa Base.TTY ? IOContext(stdout, :limit => true) : stdout
    _pretty_table(io, data; kwargs...)
end

pretty_table(io::IO, data; kwargs...) = _pretty_table(io, data; kwargs...)

function pretty_table(::Type{String}, data; color::Bool = false, kwargs...)
    io = IOContext(IOBuffer(), :color => color)
    _pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(::Type{HTML}, data; kwargs...)
    # If the keywords does not set the backend or the table format, use the HTML
    # backend by default.
    if !haskey(kwargs, :backend) && !haskey(kwargs, :tf)
        str = pretty_table(String, data; backend = Val(:html), kwargs...)
    else
        str = pretty_table(String, data; kwargs...)
    end

    return HTML(str)
end
