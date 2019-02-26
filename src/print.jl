#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Functions to print the tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export pretty_table

################################################################################
#                                    Macros
################################################################################

"""
    macro _draw_line(io, left, intersection, right, row, border_crayon, num_cols, cols_width, show_row_number, row_number_width)

This macro draws a vertical table line. The `left`, `intersection`, `right`, and
`row` are the characters that will be used to draw the table line.

"""
macro _draw_line(io, left, intersection, right, row, border_crayon, num_cols,
                 cols_width, show_row_number, row_number_width)

    return quote
        local io               = $(esc(io))
        local left             = $(esc(left))
        local intersection     = $(esc(intersection))
        local right            = $(esc(right))
        local row              = $(esc(row))
        local border_crayon    = $(esc(border_crayon))
        local num_cols         = $(esc(num_cols))
        local cols_width       = $(esc(cols_width))
        local show_row_number  = $(esc(show_row_number))
        local row_number_width = $(esc(row_number_width))

        @_ps(io, border_crayon, left)

        if show_row_number
            print(io, border_crayon, row^(row_number_width+2))
            print(io, border_crayon, intersection)
        end

        @inbounds for i = 1:num_cols
            # Check the alignment and print.
            @_ps(io, border_crayon, row^(cols_width[i]+2))

            i != num_cols && @_ps(io, border_crayon, intersection)
        end

        @_ps(io, border_crayon, right)
        println(io)
    end
end

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

"""
    macro _ps(io, crayon, str)

Print `str` to `io` using `crayon` and reset the style at the end. Notice that
if `io` does not support colors, then no escape sequence will be printed.

"""
macro _ps(io, crayon, str)
    return quote
        io_has_color = get($(esc(io)), :color, false)

        if io_has_color
            print($(esc(io)), $(esc(crayon)), $(esc(str)), $(esc(_reset_crayon)))
        else
            print($(esc(io)), $(esc(str)))
        end
    end
end

################################################################################
#                               Public Functions
################################################################################

"""
    function pretty_table(data::AbstractMatrix{T1}, header::AbstractVecOrMat{T2}; kwargs...) where {T1,T2}

Print to `io` the matrix `data` with header `header` using the format `tf` (see
`PrettyTableFormat`). If `io` is omitted, then it defaults to `stdout`. If
`header` is empty, then it will be automatically filled with "Col. i" for the
*i*-th column.

The `header` can be a `Vector` or a `Matrix`. If it is a `Matrix`, then each row
will be a header line. The first line is called *header* and the others are
called *sub-headers* .

    function pretty_table([io::IO,] data::AbstractMatrix{T}, tf::PrettyTableFormat = unicode; ...) where T

Print to `io` the matrix `data` using the format `tf` (see `PrettyTableFormat`).
If `io` is omitted, then it defaults to `stdout`. The header will be
automatically filled with "Col. i" for the *i*-th column.

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
* `formatter`: See the section `Formatter`.
* `highlighters`: A tuple with a list of highlighters (see the section
                  `Highlighters`).
* `hlines`: A vector of `Int` indicating row numbers in which an additional
            horizontal line should be drawn after the row. Notice that numbers
            lower than 1 and equal or higher than the number of rows will be
            neglected.
* `linebreaks`: If `true`, then `\n` will break the line inside the cells.
                (**Default** = `false`)
* `noheader`: If `true`, then the header will not be printed. Notice that all
              keywords and parameters related to the header and sub-headers will
              be ignored. (**Default** = `false`)
* `same_column_size`: If `true`, then all the columns will have the same size.
                      (**Default** = `false`)
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

pretty_table(table, tf::PrettyTableFormat = unicode; kwargs...) =
    pretty_table(stdout, table, tf; kwargs...)

function pretty_table(io::IO, table, tf::PrettyTableFormat = unicode; kwargs...)
    !Tables.istable(table) && error("table must be compliant with the Table.jl.")

    # Get the data.
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
                       formatter::Dict = Dict(),
                       highlighters::Tuple = (),
                       hlines::AbstractVector{Int} = Int[],
                       linebreaks::Bool = false,
                       noheader::Bool = false,
                       same_column_size::Bool = false,
                       show_row_number::Bool = false)

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
    # subheaders.

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

    # Transform some keywords that are single elements to vectors.
    if !noheader
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

    # Get the string which is printed when `print` is called in each element of
    # the matrix.
    header_str       = Matrix{String}(undef, header_num_rows, num_cols)
    data_str         = Matrix{Vector{AbstractString}}(undef, num_rows, num_cols)
    num_lines_in_row = ones(Int, num_rows)
    cols_width       = zeros(Int, num_cols)

    @inbounds @views for i = 1:num_cols
        fi = haskey(formatter, i) ? formatter[i] :
                (haskey(formatter, 0) ? formatter[0] : nothing)

        if !noheader
            for j = 1:header_num_rows
                header_str[j,i] = escape_string(sprint(print, header[(i-1)*header_num_rows + j]))

                # Compute the minimum column size to print this string.
                cell_width = length(header_str[j,i])

                # Check if we need to increase the columns size.
                cols_width[i] < cell_width && (cols_width[i] = cell_width)
            end
        end

        for j = 1:num_rows
            data_ij = fi != nothing ? fi(data[j,i], j) : data[j,i]
            data_str_ij = sprint(print, data_ij)

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
    end

    # The row number width depends on how many digits the total number of rows
    # has and the length of the header "Row".
    row_number_width = max(3,floor(Int, log10(num_rows)) + 1)

    # If the user wants all the columns with the same size, then select the
    # larger.
    same_column_size && (cols_width = [maximum(cols_width) for i = 1:num_cols])

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    io_has_color = get(io, :color, false)
    buf_io       = IOBuffer()
    buf          = IOContext(buf_io, :color => io_has_color)


    # Top table line
    # ==========================================================================

    tf.top_line && @_draw_line(buf, tf.up_left_corner, tf.up_intersection,
                               tf.up_right_corner, tf.row, border_crayon,
                               num_cols, cols_width, show_row_number,
                               row_number_width)

    # Header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        @inbounds @views for i = 1:header_num_rows
            @_ps(buf, border_crayon, tf.column)

            if show_row_number
                # The text "Row" must appear only on the first line.

                if i == 1
                    header_row_i_str = " " * @_str_aligned("Row", :r, row_number_width) * " "
                    @_ps(buf, rownum_header_crayon, header_row_i_str)
                else
                    @_ps(buf, rownum_header_crayon, " "^(row_number_width+1))
                end

                @_ps(buf, border_crayon, tf.column)
            end

            for j = 1:num_cols
                header_i_str = " " * @_str_aligned(header_str[i,j], alignment[j], cols_width[j]) * " "

                # Check if we are printing the header or the sub-headers and select
                # the styling accordingly.
                crayon = (i == 1) ? header_crayon[j] : subheader_crayon[j]

                @_ps(buf, crayon,        header_i_str)
                @_ps(buf, border_crayon, tf.column)
            end

            i != header_num_rows && println(buf)
        end

        println(buf)

        # Bottom header line
        #-----------------------------------------------------------------------

        @_draw_line(buf, tf.left_intersection, tf.middle_intersection,
                    tf.right_intersection, tf.row, border_crayon, num_cols,
                    cols_width, show_row_number, row_number_width)
    end

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_rows
        for l = 1:num_lines_in_row[i]
            @_ps(buf, border_crayon, tf.column)

            if show_row_number
                if l == 1
                    row_number_i_str = " " * @_str_aligned(string(i), :r, row_number_width) * " "
                else
                    row_number_i_str = " " * @_str_aligned("", :r, row_number_width) * " "
                end

                @_ps(buf, text_crayon,   row_number_i_str)
                @_ps(buf, border_crayon, tf.column)
            end

            for j = 1:num_cols
                if length(data_str[i,j]) >= l
                    data_ij_str = " " * @_str_aligned(data_str[i,j][l], alignment[j], cols_width[j]) * " "
                else
                    data_ij_str = " " * @_str_aligned("", alignment[j], cols_width[j]) * " "
                end

                # If we have highlighters defined, then we need to verify if this
                # data should be highlight.
                printed = false
                crayon  = text_crayon

                for h in highlighters
                    if h.f(data, i, j)
                        crayon = h.crayon
                        @_ps(buf, crayon, data_ij_str)
                        printed = true
                        break
                    end
                end

                !printed && @_ps(buf, text_crayon, data_ij_str)

                @_ps(buf, border_crayon, tf.column)
            end

            println(buf)
        end

        # Check if we must draw a horizontal line here.
        i != num_rows && i in hlines &&
        @_draw_line(buf, tf.left_intersection, tf.middle_intersection,
                    tf.right_intersection, tf.row, border_crayon, num_cols,
                    cols_width, show_row_number, row_number_width)

    end

    # Bottom table line
    # ==========================================================================

    tf.bottom_line && @_draw_line(buf, tf.bottom_left_corner,
                                  tf.bottom_intersection,
                                  tf.bottom_right_corner, tf.row, border_crayon,
                                  num_cols, cols_width, show_row_number,
                                  row_number_width)

    # Print the buffer
    # ==========================================================================
    print(io, String(take!(buf_io)))

    nothing
end

