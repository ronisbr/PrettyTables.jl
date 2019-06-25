#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Functions to print the tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export pretty_table

################################################################################
#                                Private types
################################################################################

"""
    mutable struct Screen

Store the information of the screen and the current cursor position. Notice that
this is not the real cursor position with respect to the screen, but with
respect to the point in which the table is printed.

# Fields

* `size`: Screen size.
* `row`: Current row.
* `col`: Current column.
* `has_color`: Indicates if the screen has color support.

"""
@with_kw mutable struct Screen
    size::Tuple{Int,Int} = (-1,-1)
    row::Int             = 1
    col::Int             = 0
    has_color::Bool      = false
end

################################################################################
#                                    Macros
################################################################################

"""
    macro _str_aligned(data, alignment, field_size)

This macro returns a string of `data` with alignment `alignment` in a field with
size `field_size`. `alignment` can be `:l` or `:L` for left alignment, `:c` or
`:C` for center alignment, or `:r` or `:R` for right alignment. It defaults to
`:r` if `alignment` is any other symbol.

"""
macro _str_aligned(data, alignment, field_size)
    quote
        ldata = $(esc(data))
        la = $(esc(alignment))
        lfs = $(esc(field_size))
        ds  = length(ldata)
        Δ = lfs - ds

        Δ < 0 && error("The field size must be bigger than the data size.")

        if la == :l || la == :L
            ldata * " "^Δ
        elseif la == :c || la == :C
            left  = div(Δ,2)
            right = Δ-left
            " "^left * ldata * " "^right
        else
            " "^Δ * ldata
        end
    end
end

################################################################################
#                               Public Functions
################################################################################

"""
    function pretty_table([io::IO,] data::AbstractVecOrMat{T1}, header::AbstractVecOrMat{T2}, tf::PrettyTableFormat = unicode; kwargs...) where {T1,T2}

Print to `io` the vector or matrix `data` with header `header` using the format
`tf` (see `PrettyTableFormat`). If `io` is omitted, then it defaults to
`stdout`. If `header` is empty, then it will be automatically filled with "Col.
i" for the *i*-th column.

The `header` can be a `Vector` or a `Matrix`. If it is a `Matrix`, then each row
will be a header line. The first line is called *header* and the others are
called *sub-headers* .

    function pretty_table([io::IO,] data::AbstractVecOrMat{T}, tf::PrettyTableFormat = unicode; ...) where T

Print to `io` the vector or matrix `data` using the format `tf` (see
`PrettyTableFormat`). If `io` is omitted, then it defaults to `stdout`. The
header will be automatically filled with "Col. i" for the *i*-th column.

    function pretty_table([io::IO,] dict::Dict{K,V}, tf::PrettyTableFormat = unicode; sortkeys = true, ...) where {K,V}

Print to `io` the dictionary `dict` in a matrix form (one column for the keys
and other for the values), using the format `tf` (see `PrettyTableFormat`). If
`io` is omitted, then it defaults to `stdout`.

In this case, the keyword `sortkeys` can be used to select whether or not the
user wants to print the dictionary with the keys sorted. If it is `false`, then
the elements will be printed on the same order returned by the functions `keys`
and `values`. Notice that this assumes that the keys are sortable, if they are
not, then an error will be thrown.

    function pretty_table([io::IO,] table, tf::PrettyTableFormat = unicode; ...)

Print to `io` the table `table` using the format `tf` (see `PrettyTableFormat`).
In this case, `table` must comply with the API of **Tables.jl**. If `io` is
omitted, then it defaults to `stdout`.

# Keywords

* `border_crayon`: Crayon to print the border.
* `header_crayon`: Crayon to print the header.
* `subheaders_crayon`: Crayon to print sub-headers.
* `rownum_header_crayon`: Crayon for the header of the column with the row
                          numbers.
* `text_crayon`: Crayon to print default text.
* `alignment`: Select the alignment of the columns (see the section `Alignment`).
* `crop`: Select the printing behavior when the data is bigger than the
          available screen size (see `screen_size`). It can be `:both` to crop
          on vertical and horizontal direction, `:horizontal` to crop only on
          horizontal direction, `:vertical` to crop only on vertical direction,
          or `:none` to do not crop the data at all.
* `filters_row`: Filters for the rows (see the section `Filters`).
* `filters_col`: Filters for the columns (see the section `Filters`).
* `formatter`: See the section `Formatter`.
* `highlighters`: A tuple with a list of highlighters (see the section
                  `Highlighters`).
* `hlines`: A vector of `Int` indicating row numbers in which an additional
            horizontal line should be drawn after the row. Notice that numbers
            lower than 1 and equal or higher than the number of rows will be
            neglected.
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

The keywords `header_crayon` and `subheaders_crayon` can be a `Crayon` or a
`Vector{Crayon}`. In the first case, the `Crayon` will be applied to all the
elements. In the second, each element can have its own crayon, but the length of
the vector must be equal to the number of columns in the data.

# Crayons

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
    modifiers such as formatters and highlighters. Thus, for example, if only
    the 4-th row is printed, then it will also be referenced inside the
    formatters and highlighters as 4 instead of 1.

# Formatter

The keyword `formatter` can be used to pass functions to format the values in
the columns. It must be a `Dict{Number,Function}()`. The key indicates the
column number in which its elements will be converted by the function in the
value of the dictionary. The function must have the following signature:

    f(value, i)

in which `value` is the data and `i` is the row number. It must return the
formatted value.

For example, if we want to multiply all values in odd rows of the column 2 by π,
then the formatter should look like:

    Dict(2 => (v,i)->isodd(i) ? v*π : v)

If the key `0` is present, then the corresponding function will be applied to
all columns that does not have a specific key.

# Highlighters

A set of highlighters can be passed as a `Tuple` to the `highlighter` keyword.
Each highlighter is an instance of the structure `Highlighter` that contains
three fields:

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighted, or `false`
       otherwise.
* `crayon`: Crayon with the style of a highlighted element.

The function `f` has the following signature:

    f(data, i, j)

in which `data` is a reference to the data that is being printed, `i` and `j`
are the element coordinates that are being tested. If this function returns
`true`, then the highlight style will be applied to the `(i,j)` element.
Otherwise, the default style will be used.

Notice that if multiple highlighters are valid for the element `(i,j)`, then the
applied style will be equal to the first match considering the order in the
Tuple `highlighters`.

"""
pretty_table(data::AbstractVecOrMat{T1}, header::AbstractVecOrMat{T2},
             tf::PrettyTableFormat = unicode; kwargs...) where {T1,T2} =
    pretty_table(stdout, data, header, tf; kwargs...)

function pretty_table(io::IO, data::AbstractVecOrMat{T1},
                      header::AbstractVecOrMat{T2},
                      tf::PrettyTableFormat = unicode; kwargs...) where {T1,T2}

    isempty(header) && ( header = ["Col. " * string(i) for i = 1:size(data,2)] )
    _pretty_table(io, data, header, tf; kwargs...)
end

pretty_table(data::AbstractVecOrMat{T}, tf::PrettyTableFormat = unicode; kwargs...) where T =
    pretty_table(stdout, data, tf; kwargs...)

pretty_table(io::IO, data::AbstractVecOrMat{T}, tf::PrettyTableFormat = unicode; kwargs...) where T =
    pretty_table(io, data, [], tf; kwargs...)

pretty_table(dict::Dict{K,V}, tf::PrettyTableFormat = unicode; kwargs...) where {K,V} =
    pretty_table(stdout, dict, tf; kwargs...)

function pretty_table(io::IO, dict::Dict{K,V}, tf::PrettyTableFormat = unicode; sortkeys = false, kwargs...) where {K,V}
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

    pretty_table(io, [vk vv], header, tf; kwargs...)
end

pretty_table(table, tf::PrettyTableFormat = unicode; kwargs...) =
    pretty_table(stdout, table, tf; kwargs...)

function pretty_table(io::IO, table, tf::PrettyTableFormat = unicode; kwargs...)

    # Get the data.
    #
    # If `table` is not compatible with Tables.jl, then an error will be thrown.
    data = Tables.columns(table)

    # Get the table schema to obtain the columns names.
    sch = Tables.schema(table)

    if sch == nothing
        num_cols, num_rows = size(data)
        header = ["Col. " * string(i) for i = 1:num_cols]
    else
        names = reshape( [sch.names...], (1,:) )
        types = reshape( [sch.types...], (1,:) )

        # Check if we have only one column. In this case, the header must be a
        # `Vector`.
        if length(names) == 1
            header = [names[1]; types[1]]
        else
            header = [names; types]
        end
    end

    _pretty_table(io, data, header, tf; kwargs...)
end

################################################################################
#                              Private Functions
################################################################################

# This is the low level function that prints the table. In this case, `data`
# must be accessed by `[i,j]` and the size of the `header` must be equal to the
# number of columns in `data`.
function _pretty_table(io, data, header, tf::PrettyTableFormat = unicode;
                       border_crayon::Crayon = Crayon(),
                       header_crayon::Union{Crayon,Vector{Crayon}} = Crayon(bold = true),
                       subheader_crayon::Union{Crayon,Vector{Crayon}} = Crayon(foreground = :dark_gray),
                       rownum_header_crayon::Crayon = Crayon(bold = true),
                       text_crayon::Crayon = Crayon(),
                       alignment::Union{Symbol,Vector{Symbol}} = :r,
                       crop::Symbol = :both,
                       filters_row::Union{Nothing,Tuple} = nothing,
                       filters_col::Union{Nothing,Tuple} = nothing,
                       formatter::Dict = Dict(),
                       highlighters::Tuple = (),
                       hlines::AbstractVector{Int} = Int[],
                       linebreaks::Bool = false,
                       noheader::Bool = false,
                       nosubheader::Bool = false,
                       same_column_size::Bool = false,
                       screen_size::Union{Nothing,Tuple{Int,Int}} = nothing,
                       show_row_number::Bool = false)

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    io_has_color = get(io, :color, false)
    buf_io       = IOBuffer()
    buf          = IOContext(buf_io, :color => io_has_color)
    screen       = Screen(has_color = io_has_color)

    # If the user did not specified the screen size, then get the current
    # display size. However, if cropping is not desired, then just do nothing
    # since the size is initialized with -1.
    if crop != :none
        if screen_size == nothing
            # For files, the function `displaysize` returns the value of the
            # environments variables "LINES" and "COLUMNS". Hence, here we set
            # those to `-1`, so that we can use this information to avoid
            # limiting the output.
            withenv("LINES" => -1, "COLUMNS" => -1) do
                screen.size = displaysize(io)
            end
        else
            screen.size = screen_size
        end

        # If the user does not want to crop, then change the size to -1.
        if crop == :vertical
            screen.size = (screen.size[1],-1)
        elseif crop == :horizontal
            screen.size = (-1,screen.size[2])
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

    !noheader && num_cols != header_num_cols &&
    error("The header length must be equal to the number of columns.")

    # Additional processing necessary if the user wants to print the header.
    if !noheader
        # If the user do not want to print the sub-header but wants to print the
        # header, then just force the number of rows in header to be 1.
        if nosubheader
            # Now, `header` will be a view of the first line of the matrix that
            # has the header.
            header = @view header[1:header_num_rows:end]
            header_num_rows = 1
        end

        # Transform some keywords that are single elements to vectors.
        if typeof(header_crayon) == Crayon
            header_crayon = [header_crayon for i = 1:num_cols]
        else
            length(header_crayon) != num_cols &&
            error("The length of `header_crayon` must be the same as the number of columns.")
        end

        if typeof(subheader_crayon) == Crayon
            subheader_crayon = [subheader_crayon for i = 1:num_cols]
        else
            length(subheader_crayon) != num_cols &&
            error("The length of `subheader_crayon` must be the same as the number of columns.")
        end
    end

    if typeof(alignment) == Symbol
        alignment = [alignment for i = 1:num_cols]
    else
        length(alignment) != num_cols && error("The length of `alignment` must be the same as the number of rows.")
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

    # If the user wants to horizontally crop the printing, then it is not
    # necessary to process all the lines. We will to process, at most, the
    # number of lines in the screen.
    if screen.size[1] > 0
        num_printed_rows = min(num_printed_rows, screen.size[1])
    end

    # If the user wants to vertically crop the printing, then it is not
    # necessary to process all the columns. However, we cannot know at this
    # stage the size of each column. Thus, this initial algorithm uses the fact
    # that each column printed will have at least 4 spaces.
    if screen.size[2] > 0
        num_printed_cols = min(num_printed_cols, ceil(Int, screen.size[2]/4))
    end

    # Get the string which is printed when `print` is called in each element of
    # the matrix. Notice that we must create only the matrix with the printed
    # rows and columns.
    header_str       = Matrix{String}(undef, header_num_rows, num_printed_cols)
    data_str         = Matrix{Vector{AbstractString}}(undef,
                                                      num_printed_rows,
                                                      num_printed_cols)
    num_lines_in_row = ones(Int, num_printed_rows)
    cols_width       = zeros(Int, num_printed_cols)

    # This variable stores the predicted table width. If the user wants
    # horizontal cropping, then it can be use to avoid unnecessary processing of
    # columns that will not be displayed.
    pred_tab_width   = 0

    @inbounds @views for i = 1:num_printed_cols
        # Index of the i-th printed column in `data`.
        ic = id_cols[i]

        fi = haskey(formatter, i) ? formatter[i] :
                (haskey(formatter, 0) ? formatter[0] : nothing)

        if !noheader
            for j = 1:header_num_rows
                header_str[j,i] = escape_string(sprint(print, header[(ic-1)*header_num_rows + j]))

                # Compute the minimum column size to print this string.
                cell_width = length(header_str[j,i])

                # Check if we need to increase the columns size.
                cols_width[i] < cell_width && (cols_width[i] = cell_width)
            end
        end

        for j = 1:num_printed_rows
            # Index of the j-th printed row in `data`.
            jr = id_rows[j]

            data_ij = fi != nothing ? fi(data[jr,ic], jr) : data[jr,ic]

            # Handle `nothing` and `missing`.
            if ismissing(data_ij)
                data_str_ij = "missing"
            elseif data_ij == nothing
                data_str_ij = "nothing"
            else
                data_str_ij = sprint(print, data_ij)
            end

            if linebreaks
                # Get the tokens for each line.
                tokens        = escape_string.(split(data_str_ij, '\n'))
                data_str[j,i] = tokens
                num_lines_ij  = length(tokens)

                # Check if we must update the number of lines in this row.
                num_lines_in_row[j] < num_lines_ij && (num_lines_in_row[j] = num_lines_ij)

                # Compute the maximum length to compute the column size.
                cell_width = maximum(length.(tokens))
            else
                data_str_ij_esc = escape_string(data_str_ij)
                data_str[j,i]   = [data_str_ij_esc]
                cell_width      = length(data_str_ij_esc)
            end

            # Check if we need to increase the columns size.
            cols_width[i] < cell_width && (cols_width[i] = cell_width)
        end

        # If the user horizontal cropping, then check if we need to process
        # another column.
        #
        # TODO: Should we take into account the dividers?
        if screen.size[2] > 0
            pred_tab_width += cols_width[i]

            if pred_tab_width > screen.size[2]
                num_printed_cols = i
                break
            end
        end
    end

    # The row number width depends on how many digits the total number of rows
    # has and the length of the header "Row". Notice that if `noheader` is set
    # to `true`, then we should not take the word "Row" into account.
    row_number_width = max(noheader ? 0 : 3, floor(Int, log10(num_rows)) + 1)

    # If the user wants all the columns with the same size, then select the
    # larger.
    same_column_size && (cols_width = [maximum(cols_width) for i = 1:num_printed_cols])

    # Top table line
    # ==========================================================================

    tf.top_line && _draw_line!(screen, buf, tf.up_left_corner,
                               tf.up_intersection, tf.up_right_corner, tf.row,
                               border_crayon, num_printed_cols, cols_width,
                               show_row_number, row_number_width)

    # Header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        @inbounds @views for i = 1:header_num_rows
            _p!(screen, buf, border_crayon, tf.column)

            if show_row_number
                # The text "Row" must appear only on the first line.
                if i == 1
                    header_row_i_str = " " * @_str_aligned("Row", :r, row_number_width) * " "
                    _p!(screen, buf, rownum_header_crayon, header_row_i_str)
                else
                    _p!(screen, buf, rownum_header_crayon, " "^(row_number_width+2))
                end

                _p!(screen, buf, border_crayon, tf.column)
            end

            for j = 1:num_printed_cols
                # Index of the j-th printed column in `data`.
                jc = id_cols[j]

                header_i_str = " " * @_str_aligned(header_str[i,j], alignment[jc], cols_width[j]) * " "

                # Check if we are printing the header or the sub-headers and select
                # the styling accordingly.
                crayon = (i == 1) ? header_crayon[jc] : subheader_crayon[jc]

                flp = j == num_printed_cols

                _p!(screen, buf, crayon,        header_i_str)
                _p!(screen, buf, border_crayon, tf.column, flp)

                _eol(screen) && break
            end

            i != header_num_rows && _nl!(screen,buf)
        end

        _nl!(screen,buf)

        # Bottom header line
        #-----------------------------------------------------------------------

        _draw_line!(screen, buf, tf.left_intersection, tf.middle_intersection,
                    tf.right_intersection, tf.row, border_crayon,
                    num_printed_cols, cols_width, show_row_number,
                    row_number_width)
    end

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_printed_rows
        ir = id_rows[i]

        for l = 1:num_lines_in_row[i]
            _p!(screen, buf, border_crayon, tf.column)

            if show_row_number
                if l == 1
                    row_number_i_str = " " * @_str_aligned(string(ir), :r, row_number_width) * " "
                else
                    row_number_i_str = " " * @_str_aligned("", :r, row_number_width) * " "
                end

                _p!(screen, buf, text_crayon,   row_number_i_str)
                _p!(screen, buf, border_crayon, tf.column)
            end

            for j = 1:num_printed_cols
                jc = id_cols[j]

                if length(data_str[i,j]) >= l
                    data_ij_str = " " * @_str_aligned(data_str[i,j][l], alignment[jc], cols_width[j]) * " "
                else
                    data_ij_str = " " * @_str_aligned("", alignment[jc], cols_width[j]) * " "
                end

                # If we have highlighters defined, then we need to verify if this
                # data should be highlight.
                printed = false
                crayon  = text_crayon

                for h in highlighters
                    if h.f(data, ir, jc)
                        crayon = h.crayon
                        _p!(screen, buf, crayon, data_ij_str)
                        printed = true
                        break
                    end
                end

                !printed && _p!(screen, buf, text_crayon, data_ij_str)

                flp = j == num_printed_cols

                _p!(screen, buf, border_crayon, tf.column, flp)

                _eol(screen) && break
            end

            _nl!(screen, buf)

        end

        # Check if we must draw a horizontal line here.
        i != num_rows && i in hlines &&
        _draw_line!(screen, buf, tf.left_intersection, tf.middle_intersection,
                    tf.right_intersection, tf.row, border_crayon,
                    num_printed_cols, cols_width, show_row_number,
                    row_number_width)

        # Here we must check if the vertical size of the screen has been
        # reached. Notice that we must add 4 to account for the command line,
        # the continuation line, the bottom table line, and the last blank line.
        if (screen.size[1] > 0) && (screen.row + 4 >= screen.size[1])
            _draw_continuation_row(screen, buf, tf, text_crayon, border_crayon,
                                   num_printed_cols, cols_width,
                                   show_row_number, row_number_width)
            break
        end
    end

    # Bottom table line
    # ==========================================================================

    tf.bottom_line && _draw_line!(screen, buf, tf.bottom_left_corner,
                                  tf.bottom_intersection,
                                  tf.bottom_right_corner, tf.row, border_crayon,
                                  num_printed_cols, cols_width, show_row_number,
                                  row_number_width)

    # Print the buffer
    # ==========================================================================
    print(io, String(take!(buf_io)))

    nothing
end

################################################################################
#                              Printing Functions
################################################################################

"""
    function _draw_continuation_row(screen, io, tf, text_crayon, border_crayon, num_printed_cols, cols_width, show_row_number, row_number_width)

Draw the continuation row when the table has filled the vertical space
available. This function prints in each column the character `⋮` centered.

"""
function _draw_continuation_row(screen, io, tf, text_crayon, border_crayon,
                                num_printed_cols, cols_width, show_row_number,
                                row_number_width)

    _p!(screen, io, border_crayon, tf.column)

    if show_row_number
        row_number_i_str = @_str_aligned("⋮", :c, row_number_width + 2)
        _p!(screen, io, text_crayon,   row_number_i_str)
        _p!(screen, io, border_crayon, tf.column)
    end

    @inbounds for j = 1:num_printed_cols
        data_ij_str = @_str_aligned("⋮", :c, cols_width[j] + 2)
        _p!(screen, io, text_crayon, data_ij_str)

        flp = j == num_printed_cols

        _p!(screen, io, border_crayon, tf.column, flp)
        _eol(screen) && break
    end

    _nl!(screen, io)

    return nothing
end

"""
    function _draw_line!(screen, io, left, intersection, right, row, border_crayon, num_cols, cols_width, show_row_number, row_number_width)

Draw a vertical line in `io` using the information in `screen`.

"""
function _draw_line!(screen, io, left, intersection, right, row, border_crayon,
                     num_cols, cols_width, show_row_number, row_number_width)

    _p!(screen, io, border_crayon, left)

    if show_row_number
        _p!(screen, io, border_crayon, row^(row_number_width+2))
        _p!(screen, io, border_crayon, intersection)
    end

    @inbounds for i = 1:num_cols
        # Check the alignment and print.
        _p!(screen, io, border_crayon, row^(cols_width[i]+2)) && break

        i != num_cols && _p!(screen, io, border_crayon, intersection)
    end

    _p!(screen, io, border_crayon, right, true)
    _nl!(screen, io)
end

"""
    function _eol(screen)

Return `true` if the cursor is at the end of line or `false` otherwise.

"""
_eol(screen) = (screen.size[2] > 0) && (screen.col >= screen.size[2])

"""
    function _nl!(screen, io)

Add a new line into `io` using the screen information in `screen`.

"""
function _nl!(screen, io)
    screen.row += 1
    screen.col  = 0
    println(io)
end

"""
    function _p!(screen, io, crayon, str, final_line_print = false)

Print `str` into `io` using the Crayon `crayon` with the screen information in
`screen`. The parameter `final_line_print` must be set to `true` if this is the
last string that will be printed in the line. This is necessary for the
algorithm to select whether or not to include the continuation character.

"""
function _p!(screen, io, crayon, str, final_line_print = false)
    # Get the size of the string.
    #
    # TODO: We might reduce the number of allocations by avoiding calling
    # `length`, since we have the size of all fields.
    lstr = length(str)

    # `sapp` is a string to be appended to `str`. This is used to add `⋯` if the
    # text must be wrapped. Notice that `lapp` is the length of `sapp`.
    sapp = ""
    lapp = 0

    # When printing a line, we must verify if the screen has bounds. This is
    # done by looking if the horizontal size is positive.
    @inbounds if screen.size[2] > 0

        # If we are at the end of the line, then just return.
        _eol(screen) && return true

        Δ = screen.size[2] - (lstr + screen.col)

        # Check if we can print the entire string.
        if Δ <= 0
            # If we cannot, then create a wrapped string considering how many
            # columns are left.
            if lstr + Δ - 2 > 0
                # This code is necessary to handle UTF-8 characters. What we
                # want is
                #
                #   str = str[1:lstr + Δ - 2]
                #
                # However, this will fail if `str` has UTF-8 characters as
                # explained in:
                #
                #   https://docs.julialang.org/en/v1/manual/strings/index.html

                str  = string(collect(str)[1:lstr + Δ - 2]...)
                lstr = lstr + Δ - 2
                sapp = " ⋯"
                lapp = 2
            elseif screen.size[2] - screen.col == 2
                # If there are only 2 characters left, then we must only print
                # " ⋯".
                str  = ""
                lstr = 0
                sapp = " ⋯"
                lapp = 2
            elseif screen.size[2] - screen.col == 1
                # If there are only 1 character left, then we must only print
                # "⋯".
                str  = ""
                lstr = 0
                sapp = "⋯"
                lapp = 1
            else
                # This should never be reached.
                @error("Internal error!")
                return true
            end
        elseif !final_line_print
            # Here we must verify if this is the final printing on this line. If
            # it is, then we should just check if the entire string fits on the
            # available size. Otherwise, we must see if, after printing the
            # current string, we will have more than 1 space left. If not, then
            # we just add the continuation character sequence.

            if Δ == 1
                str   = lstr > 1 ? str[1:end-1] : ""
                lstr -= 1
                sapp  = " ⋯"
                lapp  = 2
            end
        end
    end

    # Print the with correct formating.
    if screen.has_color
        print(io, crayon, str, _reset_crayon, sapp)
    else
        print(io, str, sapp)
    end

    # Update the current columns.
    screen.col += lstr + lapp

    # Return if we reached the end of line.
    return _eol(screen)
end
