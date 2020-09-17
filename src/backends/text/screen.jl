# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to screen printing and manipulation.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _draw_continuation_row(screen::Screen, io::IO, tf::TextFormat, text_crayon::Crayon, border_crayon::Crayon, cols_width::Vector{Int}, vlines::Vector{Int}, alignment::Symbol)

Draw the continuation row when the table has filled the vertical space
available. This function prints in each column the character `⋮` with the
alignment in `alignment`.

"""
function _draw_continuation_row(screen::Screen, io::IO, tf::TextFormat,
                                text_crayon::Crayon, border_crayon::Crayon,
                                cols_width::Vector{Int}, vlines::Vector{Int},
                                alignment::Symbol)

    num_cols = length(cols_width)

    0 ∈ vlines && _p!(screen, io, border_crayon, tf.column)

    @inbounds for j = 1:num_cols
        data_ij_str, data_ij_len = _str_aligned("⋮", alignment, cols_width[j])
        _p!(screen, io, text_crayon, " " * data_ij_str * " ", false, data_ij_len+2)

        flp = j == num_cols

        _pc!(j ∈ vlines, screen, io, border_crayon, tf.column, "", flp, 1, 0)
        _eol(screen) && break
    end

    _nl!(screen, io)

    return nothing
end

"""
    _draw_line!(screen::Screen, io::IO, left::Char, intersection::Char, right::Char, row::Char, border_crayon::Crayon, cols_width::Vector{Int}, vlines::Vector{Int})

Draw a vertical line in `io` using the information in `screen`.

"""
function _draw_line!(screen::Screen, io::IO, left::Char, intersection::Char,
                     right::Char, row::Char, border_crayon::Crayon,
                     cols_width::Vector{Int}, vlines::Vector{Int})

    num_cols = length(cols_width)

    0 ∈ vlines && _p!(screen, io, border_crayon, left)

    @inbounds for i = 1:num_cols
        # Check the alignment and print.
        _p!(screen, io, border_crayon, row^(cols_width[i]+2)) && break

        i != num_cols &&
            _pc!(i ∈ vlines, screen, io, border_crayon, intersection, "")
    end

    _pc!(num_cols ∈ vlines, screen, io, border_crayon, right, "", true)
    _nl!(screen, io)
end

"""
    _eol(screen::Screen)

Return `true` if the cursor is at the end of line or `false` otherwise.

"""
_eol(screen::Screen) = (screen.size[2] > 0) && (screen.col >= screen.size[2])

"""
    _eos(screen::Screen, Δ::Int)

Return `true` if the cursor is `Δ` lines before the end of screen or `false`
otherwise.

"""
_eos(screen::Screen, Δ::Int) = (screen.size[1] > 0) && (screen.row+Δ >= screen.size[1])

"""
    _nl!(screen::Screen, io::IO)

Add a new line into `io` using the screen information in `screen`.

"""
function _nl!(screen::Screen, io::IO)
    # Store the largest column that was printed.
    screen.max_col < screen.col && (screen.max_col = screen.col)
    screen.row += 1
    screen.col  = 0
    println(io)
end

"""
    _p!(screen::Screen, io::IO, crayon::Crayon, str::Char, final_line_print::Bool = false, lstr::Int = -1)
    _p!(screen::Screen, io::IO, crayon::Crayon, str::String, final_line_print::Bool = false, lstr::Int = -1)

Print `str` into `io` using the Crayon `crayon` with the screen information in
`screen`. The parameter `final_line_print` must be set to `true` if this is the
last string that will be printed in the line. This is necessary for the
algorithm to select whether or not to include the continuation character.

The size of the string can be passed to `lstr` to save computational burden. If
`lstr = -1`, then the string length will be computed inside the function.

"""
_p!(screen::Screen, io::IO, crayon::Crayon, str::Char,
    final_line_print::Bool = false, lstr::Int = -1) =
        _p!(screen, io, crayon, string(str), final_line_print, lstr)

function _p!(screen::Screen, io::IO, crayon::Crayon, str::String,
             final_line_print::Bool = false, lstr::Int = -1)

    # Get the size of the string if required.
    lstr < 0 && (lstr = textwidth(str))

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
                # Here we crop the string considering the available space
                # reserving 2 characters for the line continuation indicator.
                str  = _crop_str(str, lstr + Δ - 2)
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
                str   = lstr > 1 ? _crop_str(str, lstr - 1) : ""
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

"""
    _pc!(cond::Bool, screen::Screen, io::IO, crayon::Crayon, str_true::Union{Char,String}, str_false::Union{Char,String}, final_line_print::Bool = false, lstr_true::Int = -1, lstr_false::Int = -1)

If `cond == true` then print `str_true`. Otherwise, print `str_false`. Those
strings will be printed into `io` using the Crayon `crayon` with the screen
information in `screen`. The parameter `final_line_print` must be set to `true`
if this is the last string that will be printed in the line. This is necessary
for the algorithm to select whether or not to include the continuation
character.

The size of the strings can be passed to `lstr_true` and `lstr_false` to save
computational burden. If they are `-1`, then the string lengths will be computed
inside the function.

"""
function _pc!(cond::Bool, screen::Screen, io::IO, crayon::Crayon,
              str_true::Union{Char,String}, str_false::Union{Char,String},
              final_line_print::Bool = false, lstr_true::Int = -1,
              lstr_false::Int = -1)
    if cond
        return _p!(screen, io, crayon, str_true, final_line_print, lstr_true)
    else
        return _p!(screen, io, crayon, str_false, final_line_print, lstr_false)
    end
end
