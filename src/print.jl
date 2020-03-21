#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Functions to print the tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export pretty_table

################################################################################
#                               Public Functions
################################################################################

"""
    pretty_table([io::IO | String,] table[, header::AbstractVecOrMat];  kwargs...)

Print to `io` the table `table` with header `header`. If `io` is omitted, then
it defaults to `stdout`. If `String` is passed in the place of `io`, then a
`String` with the printed table will be returned by the function.

The `header` can be a `Vector` or a `Matrix`. If it is a `Matrix`, then each row
will be a header line. The first line is called *header* and the others are
called *sub-headers* . If `header` is empty or missing, then it will be
automatically filled with "Col.  i" for the *i*-th column.

When printing, it will be verified if `table` complies with **Tables.jl** API.
If it is is compliant, then this interface will be used to print the table. If
it is not compliant, then only the following types are supported:

1. `AbstractVector`: any vector can be printed. In this case, the `header`
   **must** be a vector, where the first element is considered the header and
   the others are the sub-headers.
2. `AbstractMatrix`: any matrix can be printed.
3. `Dict`: any `Dict` can be printed. In this case, the special keyword
   `sortkeys` can be used to select whether or not the user wants to print the
   dictionary with the keys sorted. If it is `false`, then the elements will be
   printed on the same order returned by the functions `keys` and `values`.
   Notice that this assumes that the keys are sortable, if they are not, then an
   error will be thrown.

# Keywords

* `alignment`: Select the alignment of the columns (see the section `Alignment`).
* `backend`: Select which back-end will be used to print the table (see the
             section `Backend`). Notice that the additional configuration in
             `kwargs...` depends on the selected backend. (see the section
             `Backend`).
* `filters_row`: Filters for the rows (see the section `Filters`).
* `filters_col`: Filters for the columns (see the section `Filters`).
* `row_names`: A vector containing the row names that will be appended to the
               left of the table. If it is `nothing`, then the column with the
               row names will not be shown. Notice that the size of this vector
               must match the number of rows in the table.
               (**Default** = `nothing`)
* `row_name_alignment`: Alignment of the column with the rows name (see the
                        section `Alignment`).
* `row_name_column_title`: Title of the column with the row names.
                           (**Default** = "")

!!! note

    Notice that all back-ends have the keyword `tf` to specify the table
    printing format. Thus, if the keyword `backend` is not present or if it is
    `nothing`, then the back-end will be automatically inferred from the type of
    the keyword `tf`. In this case, if `tf` is also not present, then it just
    fall-back to the text back-end.

# Alignment

The keyword `alignment` can be a `Symbol` or a vector of `Symbol`.

If it is a symbol, we have the following behavior:

* `:l` or `:L`: the text of all columns will be left-aligned;
* `:c` or `:C`: the text of all columns will be center-aligned;
* `:r` or `:R`: the text of all columns will be right-aligned;
* Otherwise it defaults to `:r`.

If it is a vector, then it must have the same number of symbols as the number of
columns in `data`. The *i*-th symbol in the vector specify the alignment of the
*i*-th column using the same symbols as described previously.

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

* `border_crayon`: Crayon to print the border.
* `header_crayon`: Crayon to print the header.
* `subheaders_crayon`: Crayon to print sub-headers.
* `rownum_header_crayon`: Crayon for the header of the column with the row
                          numbers.
* `text_crayon`: Crayon to print default text.
* `autowrap`: If `true`, then the text will be wrapped on spaces to fit the
              column. Notice that this function requires `linebreaks = true` and
              the column must have a fixed size (see `columns_width`).
* `body_hlines`: A vector of `Int` indicating row numbers in which an additional
                 horizontal line should be drawn after the row. Notice that
                 numbers lower than 1 and equal or higher than the number of
                 printed rows will be neglected. This vector will be appended to
                 the one in `hlines`, but the indices here are related to the
                 printed rows of the body. Thus, if `1` is added to
                 `body_hlines`, then a horizontal line will be drawn after the
                 first data row. (**Default** = `Int[]`)
* `body_hlines_format`: A tuple of 4 characters specifying the format of the
                        horizontal lines that will be drawn by `body_hlines`.
                        The characters must be the left intersection, the middle
                        intersection, the right intersection, and the row. If it
                        is `nothing`, then it will use the same format specified
                        in `tf`. (**Default** = `nothing`)
* `cell_alignment`: A dictionary of type `(i,j) => a` that overrides that
                    alignment of the cell `(i,j)` to `a` regardless of the
                    columns alignment selected. `a` must be a symbol like
                    specified in the section `Alignment`.
* `columns_width`: A set of integers specifying the width of each column. If the
                   width is equal or lower than 0, then it will be automatically
                   computed to fit the large cell in the column. If it is
                   a single integer, then this number will be used as the size
                   of all columns. (**Default** = 0)
* `crop`: Select the printing behavior when the data is bigger than the
          available screen size (see `screen_size`). It can be `:both` to crop
          on vertical and horizontal direction, `:horizontal` to crop only on
          horizontal direction, `:vertical` to crop only on vertical direction,
          or `:none` to do not crop the data at all.
* `formatters`: See the section `Formatters`.
* `highlighters`: An instance of `Highlighter` or a tuple with a list of
                  text highlighters (see the section `Text highlighters`).
* `hlines`: This variable controls where the horizontal lines will be drawn. It
            can be `nothing`, `:all`, `:none` or a vector of integers.
    - If it is `nothing`, which is the default, then the configuration will be
      obtained from the table format in the variable `tf` (see `TextFormat`).
    - If it is `:all`, then all horizontal lines will be drawn.
    - If it is `:none`, then no horizontal line will be drawn.
    - If it is a vector of integers, then the horizontal lines will be drawn
      only after the rows in the vector. Notice that the top line will be drawn
      if `0` is in `hlines`, and the header and subheaders are considered as
      only 1 row. Furthermore, it is important to mention that the row number in
      this variable is related to the **printed rows**. Thus, it is affected by
      filters, and by the option to suppress the header `noheader`. Finally, for
      convenience, the top and bottom lines can be drawn by adding the symbols
      `:begin` and `:end` to this vector, respectively, and the line after the
      header can be drawn by adding the symbol `:header`.
  !!! info

      The values of `body_hlines` will be appended to this vector. Thus,
      horizontal lines can be drawn even if `hlines` is `:none`.

  (**Default** = `nothing`)
* `linebreaks`: If `true`, then `\\n` will break the line inside the cells.
                (**Default** = `false`)
* `noheader`: If `true`, then the header will not be printed. Notice that all
              keywords and parameters related to the header and sub-headers will
              be ignored. (**Default** = `false`)
* `nosubheader`: If `true`, then the sub-header will not be printed, *i.e.* the
                 header will contain only one line. Notice that this option has
                 no effect if `noheader = true`. (**Default** = `false`)
* `same_column_size`: If `true`, then all the columns will have the same size.
                      (**Default** = `false`)
* `screen_size`: A tuple of two integers that defines the screen size (num. of
                 rows, num. of columns) that is available to print the table. It
                 is used to crop the data depending on the value of the keyword
                 `crop`. If it is `nothing`, then the size will be obtained
                 automatically. Notice that if a dimension is not positive, then
                 it will be treated as unlimited. (**Default** = `nothing`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`)
* `tf`: Table format used to print the table (see `TextFormat`).
        (**Default** = `unicode`)
* `vlines`: This variable controls where the vertical lines will be drawn. It
            can be `:all`, `:none` or a vector of integers. In the first case
            (the default behavior), all vertical lines will be drawn. In the
            second case, no vertical line will be drawn. In the third case,
            the vertical lines will be drawn only after the columns in the
            vector. Notice that the left border will be drawn if `0` is in
            `vlines`. Furthermore, it is important to mention that the column
            number in this variable is related to the **printed columns**. Thus,
            it is affected by filters, and by the columns added using the
            variables `show_row_number` and `row_names`. Finally, for
            convenience, the left and right border can be drawn by adding the
            symbols `:begin` and `:end` to this vector, respectively.
            (**Default** = `:all`)

The keywords `header_crayon` and `subheaders_crayon` can be a `Crayon` or a
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

A set of highlighters can be passed as a `Tuple` to the `highlighter` keyword.
Each highlighter is an instance of the structure `Highlighter` that contains two
fields:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighted, or `false`
       otherwise.
* `crayon`: Crayon with the style of a highlighted element.

The function `f` has the following signature:

    f(data, i, j)

where `data` is a reference to the data that is being printed, `i` and `j` are
the element coordinates that are being tested. If this function returns `true`,
then the highlight style will be applied to the `(i,j)` element. Otherwise, the
default style will be used.

Notice that if multiple highlighters are valid for the element `(i,j)`, then the
applied style will be equal to the first match considering the order in the
Tuple `highlighters`.

If only a single highlighter is wanted, then it can be passed directly to the
keyword `highlighter` without being inside a `Tuple`.

---

# Pretty table HTML backend

This backend produces HTML tables. This backend can be used by selecting
`backend = :html`.

# Keywords

* `cell_alignment`: A dictionary of type `(i,j) => a` that overrides that
                    alignment of the cell `(i,j)` to `a` regardless of the
                    columns alignment selected. `a` must be a symbol like
                    specified in the section `Alignment`.
* `formatter`: See the section `Formatters`.
* `highlighters`: An instance of `HTMLHighlighter` or a tuple with a list of
                  HTML highlighters (see the section `HTML highlighters`).
* `linebreaks`: If `true`, then `\\n` will be replaced by `<br>`.
                (**Default** = `false`)
* `noheader`: If `true`, then the header will not be printed. Notice that all
              keywords and parameters related to the header and sub-headers will
              be ignored. (**Default** = `false`)
* `nosubheader`: If `true`, then the sub-header will not be printed, *i.e.* the
                 header will contain only one line. Notice that this option has
                 no effect if `noheader = true`. (**Default** = `false`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`)
* `standalone`: If `true`, then a complete HTML page will be generated.
                Otherwise, only the content between the tags `<table>` and
                `</table>` will be printed (with the tags included).
                (**Default** = `true`)
* `tf`: An instance of the structure `HTMLTableFormat` that defines the general
        format of the HTML table.

## HTML highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighter` keyword.
Each highlighter is an instance of a structure that is a subtype of
`AbstractHTMLHighlighter`. It also must also contain at least the following two
fields to comply with the API:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighted, or `false`
       otherwise.
* `fd`: Function with the signature `f(h,data,i,j)` in which `h` is the
        highlighter. This function must return the `HTMLDecoration` to be
        applied to the cell that must be highlighted.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j`
are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i,j)` element.
Otherwise, the default style will be used.

Notice that if multiple highlighters are valid for the element `(i,j)`, then the
applied style will be equal to the first match considering the order in the
Tuple `highlighters`.

If the function `f` returns true, then the function `fd(h,data,i,j)` will be
called and must return an element of type `HTMLDecoration` that contains the
decoration to be applied to the cell.

If only a single highlighter is wanted, then it can be passed directly to the
keyword `highlighter` without being inside a `Tuple`.

---

# Pretty table LaTeX backend

This backend produces LaTeX tables. This backend can be used by selecting
`backend = :latex`.

# Keywords

* `cell_alignment`: A dictionary of type `(i,j) => a` that overrides that
                    alignment of the cell `(i,j)` to `a` regardless of the
                    columns alignment selected. `a` must be a symbol like
                    specified in the section `Alignment`.
* `formatter`: See the section `Formatters`.
* `highlighters`: An instance of `LatexHighlighter` or a tuple with a list of
                  LaTeX highlighters (see the section `LaTeX highlighters`).
* `hlines`: A vector of `Int` indicating row numbers in which an additional
            horizontal line should be drawn after the row. Notice that numbers
            lower than 1 and equal or higher than the number of rows will be
            neglected.
* `longtable_footer`: The string that will be drawn in the footer of the tables
                      before a page break. This only works if `table_type` is
                      `:longtable`. If it is `nothing`, then no footer will be
                      used. (**Default** = `nothing`)
* `noheader`: If `true`, then the header will not be printed. Notice that all
              keywords and parameters related to the header and sub-headers will
              be ignored. (**Default** = `false`)
* `nosubheader`: If `true`, then the sub-header will not be printed, *i.e.* the
                 header will contain only one line. Notice that this option has
                 no effect if `noheader = true`. (**Default** = `false`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`)
* `table_type`: Select which LaTeX environment will be used to print the table.
                Currently supported options are `:tabular` for `tabular` or
                `:longtable` for `longtable`. (**Default** = `:tabular`)
* `tf`: An instance of the structure `LatexTableFormat` that defines the general
        format of the LaTeX table.
* `vlines`: This variable controls where the vertical lines will be drawn. It
            can be `:all`, `:none` or a vector of integers. In the first case
            (the default behavior), all vertical lines will be drawn. In the
            second case, no vertical line will be drawn. In the third case,
            the vertical lines will be drawn only after the columns in the
            vector. Notice that the left border will be drawn if `0` is in
            `vlines`. Furthermore, it is important to mention that the column
            number in this variable is related to the **printed columns**. Thus,
            it is affected by filters, and by the columns added using the
            variable `show_row_number`. Finally, for convenience, the left and
            right border can be drawn by adding the symbols `:begin` and `:end`
            to this vector, respectively. (**Default** = `:none`)

## LaTeX highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighter` keyword.
Each highlighter is an instance of the structure `LatexHighlighter`. It contains
the following two fields:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighted, or `false`
       otherwise.
* `fd`: A function with the signature `f(data,i,j,str)::String` in which
        `data` is the matrix, `(i,j)` is the element position in the table, and
        `str` is the data converted to string. This function must return a
        string that will be placed in the cell.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j`
are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i,j)` element.
Otherwise, the default style will be used.

Notice that if multiple highlighters are valid for the element `(i,j)`, then the
applied style will be equal to the first match considering the order in the
Tuple `highlighters`.

If the function `f` returns true, then the function `fd(data,i,j,str)` will be
called and must return the LaTeX string that will be placed in the cell.

If only a single highlighter is wanted, then it can be passed directly to the
keyword `highlighter` without being inside a `Tuple`.

There are two helpers that can be used to create LaTeX highlighters:

    LatexHighlighter(f::Function, envs::Union{String,Vector{String}})

    LatexHighlighter(f::Function, fd::Function)

The first will apply recursively all the LaTeX environments in `envs` to the
highlighted text whereas the second let the user select the desired decoration
by specifying the function `fd`.

Thus, for example:

    LatexHighlighter((data,i,j)->true, ["textbf", "small"])

will wrap all the cells in the table in the following environment:

    \\textbf{\\small{<Cell text>}}

---

# Formatters

The keyword `formatters` can be used to pass functions to format the values in
the columns. It must be a tuple of functions in which each function has the
following signature:

    f(v, i, j)

where `v` is the value in the cell, `i` is the row number, and `j` is the column
number. Thus, it must return the formatted value of the cell `(i,j)` that has
the value `v`. Notice that the returned value will be converted to string after
using the function `sprint`.

This keyword can also be a single function, meaning that only one formatter is
available, or `nothing`, meaning that no formatter will be used.

For example, if we want to multiply all values in odd rows of the column 2 by π,
then the formatter should look like:

    formatters = (v,i,j) -> (j == 2 && isodd(i)) ? v*π : v

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
pretty_table(data; kwargs...) = pretty_table(stdout, data, []; kwargs...)

pretty_table(data, header::AbstractVecOrMat; kwargs...) =
    pretty_table(stdout, data, header; kwargs...)

# This definition is required to avoid ambiguities.
pretty_table(data::AbstractVecOrMat, header::AbstractVecOrMat; kwargs...) =
    pretty_table(stdout, data, header; kwargs...)

# This definition is required to avoid ambiguities.
pretty_table(io::IO, data::AbstractVecOrMat; kwargs...) =
    pretty_table(io, data, []; kwargs...)

pretty_table(io::IO, data; kwargs...) = pretty_table(io, data, []; kwargs...)

function pretty_table(io::IO, data, header::AbstractVecOrMat; kwargs...)
    if Tables.istable(data)
        _pretty_table_Tables(io, data, header; kwargs...)
    elseif typeof(data) <: AbstractVecOrMat
        _pretty_table_VecOrMat(io, data, header; kwargs...)
    elseif typeof(data) <: Dict
        _pretty_table_Dict(io, data; kwargs...)
    else
        error("The type $(typeof(data)) is not supported.")
    end
end

# This definition is required to avoid ambiguities.
pretty_table(::Type{String}, data::AbstractVecOrMat; kwargs...) =
    pretty_table(String, data, []; kwargs...)

pretty_table(::Type{String}, data; kwargs...) =
    pretty_table(String, data, []; kwargs...)

function pretty_table(::Type{String}, data, header::AbstractVecOrMat; kwargs...)
    io = IOBuffer()
    pretty_table(io, data, header; kwargs...)
    return String(take!(io))
end

################################################################################
#                              Private Functions
################################################################################

# Function to print data that complies with Tables.jl API.
function _pretty_table_Tables(io::IO, table, header; kwargs...)
    # First we need to check which type of table we have.
    if Tables.columnaccess(table)
        # Access the table using the columns.
        cols = Tables.columns(table)

        # Get the column names.
        names = collect(Symbol, Tables.columnnames(cols))

        # Compute the table size and get the column types.
        size_j = length(names)
        size_i = Tables.rowcount(cols)

        data = ColumnTable(cols, names, (size_i, size_j))

    elseif Tables.rowaccess(table)
        # Access the table using the rows.
        rows = Tables.rows(table)

        # We need to fetch the first row to get information about the columns.
        row₁,~ = iterate(rows, 1)

        # Get the column names.
        names = collect(Symbol, Tables.columnnames(row₁))

        # Compute the table size.
        size_i = length(rows)
        size_j = length(names)

        data = RowTable(rows, names, (size_i, size_j))
    else
        error("The object does not have a valid Tables.jl implementation.")
    end

    # For the header, we have the following priority:
    #
    #     1. If the user passed a vector `header`, then use it.
    #     2. Otherwise, check if the table defines a schema to create the
    #        header.
    #     3. If the table does not have a schema, then build a default header
    #        based on the column name and type.
    if isempty(header)
        sch = Tables.schema(table)

        if sch != nothing
            names = reshape( [sch.names...], (1,:) )
            types = reshape( [sch.types...], (1,:) )

            # Check if we have only one column. In this case, the header must be
            # a `Vector`.
            if length(names) == 1
                header = [names[1]; types[1]]
            else
                header = [names; types]
            end
        else
            header = data.column_names
        end

    end

    _pretty_table(io, data, header; kwargs...)
end

# Function to print vectors or matrices.
function _pretty_table_VecOrMat(io, matrix, header; kwargs...)
    if isempty(header)
        header = ["Col. " * string(i) for i = 1:size(matrix,2)]
    end

    _pretty_table(io, matrix, header; kwargs...)
end

# Function to print dictionaries.
function _pretty_table_Dict(io, dict::Dict{K,V}; sortkeys = false, kwargs...) where {K,V}
    header = ["Keys"     "Values";
              string(K)  string(V)]

    k = collect(keys(dict))
    v = collect(values(dict))

    if sortkeys
        ind = sortperm(collect(keys(dict)))
        vk  = @view k[ind]
        vv  = @view v[ind]
    else
        vk = k
        vv = v
    end

    pretty_table(io, [vk vv], header; kwargs...)
end

# Dictionary to hold the information between the table format type and the
# backend.
_type_backend_dict = Dict{DataType, Symbol}(TextFormat       => :text,
                                            HTMLTableFormat  => :html,
                                            LatexTableFormat => :latex)

# This is the low level function that prints the table. In this case, `data`
# must be accessed by `[i,j]` and the size of the `header` must be equal to the
# number of columns in `data`.
function _pretty_table(io, data, header;
                       alignment::Union{Symbol,Vector{Symbol}} = :r,
                       backend::Union{Nothing,Symbol} = nothing,
                       filters_row::Union{Nothing,Tuple} = nothing,
                       filters_col::Union{Nothing,Tuple} = nothing,
                       formatters::Union{Nothing,Function,Tuple} = nothing,
                       row_names::Union{Nothing,AbstractVector} = nothing,
                       row_name_alignment::Symbol = :r,
                       row_name_column_title::AbstractString = "",
                       kwargs...)

    # Try to automatically infer the backend based on the table format type.
    if backend == nothing
        # In this case, if we do not have the `tf` keyword, then we just
        # fallback to the text backend. Otherwise, check if the type is
        # listed in the directionary `_type_backend_dict`.
        if haskey(kwargs,:tf) && haskey(_type_backend_dict, typeof(kwargs[:tf]))
            backend = _type_backend_dict[typeof(kwargs[:tf])]
        else
            backend = :text
        end
    end

    # Get information about the table we have to print based on the format of
    # `data`, which must be an `AbstractMatrix` or an `AbstractVector`.
    dims     = size(data)
    num_dims = length(dims)

    if num_dims == 1
        num_rows = dims[1]
        num_cols = 1
    elseif num_dims == 2
        num_rows = dims[1]
        num_cols = dims[2]
    else
        throw(ArgumentError("`data` must not have more than 2 dimensions."))
    end

    num_rows < 1 && error("The table must contain at least 1 row.")

    # The way we get the number of columns of the header depends on its
    # dimension, because the header can be a vector or a matrix. It also depends
    # on the dimension of the `data`. If `data` is a vector, then `header` must
    # be a vector, in which the first elements if the header and the others are
    # sub-headers.

    header_size     = size(header)
    header_num_dims = length(header_size)

    # Check if it is vector or a matrix with only one column.
    if (num_dims == 1) || (num_dims == 2 && num_cols == 1)
        header_num_dims != 1 &&
        error("If the input data has only one column, then the header must be a vector.")

        header_num_cols = 1
        header_num_rows = header_size[1]
    elseif length(header_size) == 2
        header_num_rows = header_size[1]
        header_num_cols = header_size[2]
    else
        header_num_rows = 1
        header_num_cols = header_size[1]
    end

    if typeof(alignment) == Symbol
        alignment = [alignment for i = 1:num_cols]
    else
        length(alignment) != num_cols && error("The length of `alignment` must be the same as the number of rows.")
    end

    # If there is a vector of row names, then it must have the same size of the
    # number of rows.
    if row_names != nothing
        length(row_names) != num_rows &&
        error("The number of lines in `row_names` must match the number of lines in the matrix.")
        show_row_names = true
    else
        show_row_names = false
    end

    # If the user wants to filter the data, then check which columns and rows
    # must be printed. Notice that if a data is filtered, then it means that it
    # passed the filter and must be printed.
    filtered_rows = ones(Bool, num_rows)
    filtered_cols = ones(Bool, num_cols)

    if filters_row != nothing
        @inbounds for i = 1:num_rows
            filtered_i = true

            for filter in filters_row
                !filter(data,i) && (filtered_i = false) && break
            end

            filtered_rows[i] = filtered_i
        end
    end

    if filters_col != nothing
        @inbounds for i = 1:num_cols
            filtered_i = true

            for filter in filters_col
                !filter(data,i) && (filtered_i = false) && break
            end

            filtered_cols[i] = filtered_i
        end
    end

    # `id_cols` and `id_rows` contains the indices of the data array that will
    # be printed.
    id_cols          = findall(filtered_cols)
    id_rows          = findall(filtered_rows)
    num_printed_cols = length(id_cols)
    num_printed_rows = length(id_rows)

    # If there is no data to print, then print a blank line and exit.
    if (num_printed_cols == 0) || (num_printed_rows == 0)
        println(io, "")
        return nothing
    end

    # Make sure that `formatters` is a tuple.
    formatters == nothing  && (formatters = ())
    typeof(formatters) <: Function && (formatters = (formatters,))

    # Create the structure that stores the print information.
    pinfo = PrintInfo(data, header, id_cols, id_rows, num_rows, num_cols,
                      num_printed_cols, num_printed_rows, header_num_rows,
                      header_num_cols, show_row_names, row_names,
                      row_name_alignment, row_name_column_title, alignment,
                      formatters)

    if backend == :text
        _pt_text(io, pinfo; kwargs...)
    elseif backend == :html
        _pt_html(io, pinfo; kwargs...)
    elseif backend == :latex
        _pt_latex(io, pinfo; kwargs...)
    else
        error("Unknown backend `$backend`.")
    end

    return nothing
end
