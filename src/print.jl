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
    function pretty_table(data::AbstractMatrix{T1}, header::AbstractVector{T2}; kwargs...) where {T1,T2}

Print to `io` the matrix `data` with header `header` using the format `tf` (see
`PrettyTableFormat`). If `io` is omitted, then it defaults to `stdout`. If
`header` is empty, then it will be automatically filled with `"Col. i"` for the
*i*-th column.

    function pretty_table([io,] data::AbstractMatrix{T}, tf::PrettyTableFormat = unicode; ...) where T

Print to `io` the matrix `data` using the format `tf` (see `PrettyTableFormat`).
The header is considered to be the first row of `data`. If `io` is omitted, then
it defaults to `stdout`.

    function pretty_table([io,] table, tf::PrettyTableFormat = unicode; ...)

Print to `io` the table `table` using the format `tf` (see `PrettyTableFormat`).
The header is considered to be the first row of `data`. In this case, `table`
must comply with the API of **Tables.jl**. If `io` is omitted, then it defaults
to `stdout`.

# Keywords

* `alignment`: Select the alignment of the columns (see the section `Alignment`).
* `border_bold`: If `true`, then the border will be printed in **bold**
                 (**Default** = `false`).
* `border_color`: The color in which the border will be printed using the same
                  convention as in the function `printstyled`. (**Default** =
                  `:normal`)
* `formatter`: See the section `Formatter`.
* `header_bold`: If `true`, then the header will be printed in **bold**
                 (**Default** = `false`).
* `header_color`: The color in which the header will be printed using the same
                  convention as in the function `printstyled`. (**Default** =
                  `:normal`)
* `highlighters`: A tuple with a list of highlighters (see the section
                  `Highlighters`).
* `same_column_size`: If `true`, then all the columns will have the same size.
                      (**Default** = `false`)
* `show_row_number`: If `true`, then a new column will be printed showing the
                     row number. (**Default** = `false`.)

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
* `bold`: If `true`, then the highlight style should be **bold**.
* `color`: A symbol with the color of the highlight style using the same
           convention as in the function `printstyled`.

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
pretty_table(data::AbstractMatrix{T1}, header::AbstractVector{T2}; kwargs...) where {T1,T2} =
    pretty_table(stdout, data, header; kwargs...)

function pretty_table(io, data::AbstractMatrix{T1}, header::AbstractVector{T2}; kwargs...) where {T1,T2}
    isempty(header) && ( header = ["Col. " * string(i) for i = 1:size(data,2)] )
    _pretty_table(io, data, header; kwargs...)
end

pretty_table(data::AbstractMatrix{T}, tf::PrettyTableFormat = unicode; kwargs...) where T =
    pretty_table(stdout, data, tf; kwargs...)

pretty_table(io, data::AbstractMatrix{T}, tf::PrettyTableFormat = unicode; kwargs...) where T =
    _pretty_table(io, @view(data[2:end,:]), @view(data[1,:]), tf; kwargs...)

pretty_table(table, tf::PrettyTableFormat = unicode; kwargs...) =
    pretty_table(stdout, table, tf; kwargs...)

function pretty_table(io, table, tf::PrettyTableFormat = unicode; kwargs...)
    !Tables.istable(table) && error("table must be compliant with the Table.jl.")

    # Get the data.
    data = Tables.columns(table)

    # Get the table schema to obtain the columns names.
    sch = Tables.schema(table)

    if sch == nothing
        num_cols, num_rows = size(data)
        header = ["Col. " * string(i) for i = 1:num_cols]
    else
        header = sch.names
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
                      alignment::Union{Symbol,Vector{Symbol}} = :r,
                      border_bold::Bool = false,
                      border_color::Symbol = :normal,
                      formatter::Dict = Dict(),
                      header_bold::Bool = true,
                      header_color::Symbol = :normal,
                      highlighters::Tuple = (),
                      same_column_size::Bool = false,
                      show_row_number::Bool = false)

    # Get information about the table we have to print.
    num_rows, num_cols = size(data)

    num_rows < 1 && error("The table must contain at least 1 row.")

    num_cols != length(header) &&
    error("The header length must be equal to the number of columns.")

    if typeof(alignment) == Symbol
        alignment = [alignment for i = 1:num_cols]
    else
        length(alignment) != num_cols && error("The length of `alignment` must be the same as the number of rows.")
    end

    # Get the string which is printed when `print` is called in each element of
    # the matrix.
    header_str = Vector{String}(undef, num_cols)
    data_str   = Matrix{String}(undef, num_rows, num_cols)

    @inbounds @views for i = 1:num_cols
        fi = haskey(formatter, i) ? formatter[i] :
                (haskey(formatter, 0) ? formatter[0] : nothing)

        header_str[i] = sprint(print, header[i])

        for j = 1:num_rows
            data_ij = fi != nothing ? fi(data[j,i], j) : data[j,i]
            data_str[j,i] = sprint(print, data_ij)
        end
    end

    # Now, we need to obtain the maximum number of characters in each column.
    cols_width = [maximum(vcat(length.(header_str[i]), length.(@view(data_str[:,i])))) for i = 1:num_cols]

    # The row number width depends on how many digits the total number of rows
    # has and the length of the header "Row".
    row_number_width = max(3,floor(Int, log10(num_rows)) + 1)

    # If the user wants all the columns with the same size, then select the
    # larger.
    same_column_size && (cols_width = [maximum(cols_width) for i = 1:num_cols])

    # Header
    # ==========================================================================

    # Up header line.

    if tf.top_line
        printstyled(io, tf.up_left_corner;
                    bold = border_bold, color = border_color)

        if show_row_number
            printstyled(io, tf.row^(row_number_width+2);
                        bold = border_bold, color = border_color)
            printstyled(io, tf.up_intersection;
                        bold  = border_bold, color = border_color)
        end

        @inbounds for i = 1:num_cols
            # Check the alignment and print.
            printstyled(io, tf.row^(cols_width[i]+2);
                        bold = border_bold, color = border_color)

            i != num_cols && printstyled(io, tf.up_intersection;
                                         bold  = border_bold,
                                         color = border_color)
        end

        printstyled(io, tf.up_right_corner;
                    bold = border_bold, color = border_color)
        println(io)
    end

    # Header text.
    printstyled(io, tf.column * " ";
                bold = border_bold, color = border_color)

    if show_row_number
        header_row_i_str = @_str_aligned("Row", :r, row_number_width) * " "
        printstyled(io, header_row_i_str; bold = header_bold, color = header_color)
        printstyled(io, tf.column;        bold = border_bold, color = border_color)
        print(io, " ")
    end

    @inbounds @views for i = 1:num_cols
        header_i_str = @_str_aligned(header_str[i], alignment[i], cols_width[i]) * " "

        printstyled(io, header_i_str; bold = header_bold, color = header_color)
        printstyled(io, tf.column;    bold = border_bold, color = border_color)

        i != num_cols && print(io, " ")
    end

    println(io)

    # Bottom header line.
    printstyled(io, tf.left_intersection;
                bold = border_bold, color = border_color)

    if show_row_number
        printstyled(io, tf.row^(row_number_width+2);
                    bold = border_bold, color = border_color)

        printstyled(io, tf.middle_intersection;
                    bold = border_bold, color = border_color)
    end

    @inbounds @views for i = 1:num_cols
        printstyled(io, tf.row^(cols_width[i]+2);
                    bold = border_bold, color = border_color)

        i != num_cols && printstyled(io, tf.middle_intersection;
                                     bold = border_bold, color = border_color)
    end

    printstyled(io, tf.right_intersection;
                bold = border_bold, color = border_color)
    println(io)

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_rows
        printstyled(io, tf.column * " ";
                    bold = border_bold, color = border_color)

        if show_row_number
            row_number_i_str = @_str_aligned(string(i), :r, row_number_width)
            print(io, row_number_i_str * " ")
            printstyled(io, tf.column; bold = border_bold, color = border_color)
            print(io, " ")
        end

        for j = 1:num_cols
            data_ij_str = @_str_aligned(data_str[i,j], alignment[j], cols_width[j]) * " "

            # If we have highlighters defined, then we need to verify if this
            # data should be highlight.
            printed = false

            for h in highlighters
                if h.f(data, i, j)
                    printstyled(io, data_ij_str; bold = h.bold, color = h.color)
                    printed = true
                    break
                end
            end

            !printed && print(io, data_ij_str)

            printstyled(io, tf.column; bold = border_bold, color = border_color)

            j != num_cols && print(io, " ")
        end

        println(io)
    end

    # Bottom table line
    # ==========================================================================

    if tf.bottom_line
        printstyled(io, tf.bottom_left_corner;
                    bold = border_bold, color = border_color)

        if show_row_number
            printstyled(io, tf.row^(row_number_width+2);
                        bold = border_bold, color = border_color)
            printstyled(io, tf.bottom_intersection;
                        bold  = border_bold, color = border_color)
        end

        @inbounds @views for i = 1:num_cols
            printstyled(io, tf.row^(cols_width[i]+2);
                        bold = border_bold, color = border_color)

            i != num_cols && printstyled(io, tf.bottom_intersection;
                                         bold = border_bold,
                                         color = border_color)
        end

        printstyled(io, tf.bottom_right_corner;
                    bold = border_bold, color = border_color)
        println(io)
    end

    nothing
end

