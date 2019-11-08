# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Private functions and macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

################################################################################
#                             Auxiliary functions
################################################################################

"""
    function _str_aligned(data::AbstractString, alignment::Symbol, field_size::Integer)

This function returns the string `data` with alignment `alignment` in a field
with size `field_size`. `alignment` can be `:l` or `:L` for left alignment, `:c`
or `:C` for center alignment, or `:r` or `:R` for right alignment. It defaults
to `:r` if `alignment` is any other symbol.

"""
function _str_aligned(data::AbstractString, alignment::Symbol,
                      field_size::Integer)

    Δ  = field_size - length(data)
    Δ < 0 && error("The field size must be bigger than the data size.")

    if alignment == :l || alignment == :L
        return data * " "^Δ
    elseif alignment == :c || alignment == :C
        left  = div(Δ,2)
        right = Δ-left
        return " "^left * data * " "^right
    else
        return " "^Δ * data
    end
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
        row_number_i_str = _str_aligned("⋮", :c, row_number_width + 2)
        _p!(screen, io, text_crayon,   row_number_i_str)
        _p!(screen, io, border_crayon, tf.column)
    end

    @inbounds for j = 1:num_printed_cols
        data_ij_str = _str_aligned("⋮", :c, cols_width[j] + 2)
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
