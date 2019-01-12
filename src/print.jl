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
    function pretty_table(data::Matrix{Any}, tf::PrettyTableFormat = unicode; ...)

Print the matrix `data` using the format `tf` (see `PrettyTableFormat`). The
header is considered to be the first row in `data`.

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

"""
pretty_table(data::Matrix{Any}, tf::PrettyTableFormat = unicode;
             alignment::Union{Symbol,Vector{Symbol}} = :r,
             border_bold::Bool = false,
             border_color::Symbol = :normal,
             formatter::Dict = Dict(),
             header_bold::Bool = true,
             header_color::Symbol = :normal,
             same_column_size::Bool = false,
             show_row_number::Bool = false) =
    pretty_table(stdout, data, tf; 
                 alignment        = alignment,
                 border_bold      = border_bold,
                 border_color     = border_color,
                 formatter        = formatter,
                 header_bold      = header_bold,
                 header_color     = header_color,
                 same_column_size = same_column_size,
                 show_row_number  = show_row_number)

function pretty_table(io, data::Matrix{Any}, tf::PrettyTableFormat = unicode;
                      alignment::Union{Symbol,Vector{Symbol}} = :r,
                      border_bold::Bool = false,
                      border_color::Symbol = :normal,
                      formatter::Dict = Dict(),
                      header_bold::Bool = true,
                      header_color::Symbol = :normal,
                      same_column_size::Bool = false,
                      show_row_number::Bool = false)

    # Get information about the table we have to print.
    num_rows, num_cols = size(data)

    num_rows < 2 && error("The table must contain at least 2 rows.")

    if typeof(alignment) == Symbol
        alignment = [alignment for i = 1:num_cols]
    else
        length(alignment) != num_cols && error("The lenght of `aligment` must be the same as the number of rows.")
    end

    # We must concatenate a row on the left if the user wants to print the row
    # number.
    if show_row_number
        data = hcat([ "Row"; [i for i = 1:num_rows-1] ], data)
        alignment = vcat(:r, alignment)
        num_cols += 1
    end

    # Get the string which is printed when `print` is called in each element of
    # the matrix.
    data_str = Matrix{String}(undef, num_rows, num_cols)

    @inbounds @views for i = 1:num_cols
        if show_row_number && i == 1
            fi = nothing
        elseif show_row_number
            ir = show_row_number ? i - 1 : i
            fi = haskey(formatter, ir) ? formatter[ir] : 
                       (haskey(formatter, 0) ? formatter[0] : nothing)
        else
            fi = haskey(formatter, i) ? formatter[i] : 
                       (haskey(formatter, 0) ? formatter[0] : nothing)
        end
        
        for j = 1:num_rows
            data_ij = (j != 1 && fi != nothing) ? fi(data[j,i], j) : data[j,i]
            data_str[j,i] = sprint(print, data_ij)
        end
    end

    # Now, we need to obtain the maximum number of characters in each column.
    cols_width = [maximum(length.(@view(data_str[:,i]))) for i = 1:num_cols]

    # If the user wants all the columns with the same size, then select the
    # larger.
    same_column_size && (cols_width = [maximum(cols_width) for i = 1:num_cols])

    # Header
    # ==========================================================================

    # Up header line.

    if tf.top_line
        printstyled(io, tf.up_left_corner;
                    bold = border_bold, color = border_color)

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

    @inbounds @views for i = 1:num_cols
        header_i_str = @_str_aligned(data_str[1,i], alignment[i], cols_width[i]) * " "

        printstyled(io, header_i_str; bold = header_bold, color = header_color)
        printstyled(io, tf.column; bold = border_bold, color = border_color)

        i != num_cols && print(io, " ")
    end

    println(io)

    # Bottom header line.
    printstyled(io, tf.left_intersection;
                bold = border_bold, color = border_color)

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
    
    @inbounds @views for i = 2:num_rows
        printstyled(io, tf.column * " ";
                    bold = border_bold, color = border_color)

        for j = 1:num_cols
            print(io, @_str_aligned(data_str[i,j], alignment[j], cols_width[j]) * " ")
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
