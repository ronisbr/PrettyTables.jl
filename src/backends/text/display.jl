# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to display printing and manipulation.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _draw_continuation_row(display::Display, io::IO, tf::TextFormat, text_crayon::Crayon, border_crayon::Crayon, cols_width::Vector{Int}, vlines::Vector{Int}, alignment::Symbol)

Draw the continuation row when the table has filled the vertical space
available. This function prints in each column the character `⋮` with the
alignment in `alignment`.
"""
function _draw_continuation_row(
    display::Display,
    io::IO,
    tf::TextFormat,
    text_crayon::Crayon,
    border_crayon::Crayon,
    cols_width::Vector{Int},
    vlines::Vector{Int},
    alignment::Symbol
)
    # In case of a continuation row, we want the last character to indicate that
    # the table continues both vertically and horizontally in case the text is
    # cropped.
    old_cont_char = display.cont_char
    display.cont_char = '⋱'

    num_cols = length(cols_width)

    0 ∈ vlines && _p!(display, border_crayon, tf.column)

    @inbounds for j in 1:num_cols
        data_ij_str  = _str_aligned("⋮", alignment, cols_width[j])
        data_ij_str  = " " * data_ij_str * " "

        flp = j == num_cols

        _p!(display, text_crayon, data_ij_str, false)
        _pc!(j ∈ vlines, display, border_crayon, tf.column, "", flp, 1, 0)
        _eol(display) && break
    end

    _nl!(display, io)

    display.cont_char = old_cont_char

    return nothing
end

"""
    _draw_line!(display::Display, io::IO, left::Char, intersection::Char, right::Char, row::Char, border_crayon::Crayon, cols_width::Vector{Int}, vlines::Vector{Int})

Draw a vertical line in internal line buffer of `display` and then flush to the
io `io`.
"""
function _draw_line!(
    display::Display,
    io::IO,
    left::Char,
    intersection::Char,
    right::Char,
    row::Char,
    border_crayon::Crayon,
    cols_width::Vector{Int},
    vlines::Vector{Int}
)
    # We does not want to add ellipsis when drawing lines.
    old_cont_char           = display.cont_char
    old_cont_space_char     = display.cont_space_char
    display.cont_char       = row
    display.cont_space_char = row

    num_cols = length(cols_width)

    0 ∈ vlines && _p!(display, border_crayon, left)

    @inbounds for i in 1:num_cols
        # Check the alignment and print.
        _p!(display, border_crayon, row^(cols_width[i] + 2)) && break

        i != num_cols &&
            _pc!(i ∈ vlines, display, border_crayon, intersection, "")
    end

    _pc!(num_cols ∈ vlines, display, border_crayon, right, "", true)
    _nl!(display, io)

    display.cont_char       = old_cont_char
    display.cont_space_char = old_cont_space_char

    return nothing
end

"""
    _eol(display::Display)

Return `true` if the cursor is at the end of line or `false` otherwise.
"""
_eol(display::Display) = (display.size[2] > 0) && (display.col >= display.size[2])

"""
    _fit_str_to_display!(display::Display, str::Char, final_line_print::Bool = false, lstr::Int = -1)

Return the string and the suffix to be printed in the display. It ensures that
the return data will fit the `display`.

The parameter `final_line_print` must be set to `true` if this is the last
string that will be printed in the line. This is necessary for the algorithm to
select whether or not to include the continuation character.

The size of the string can be passed to `lstr` to save computational burden. If
`lstr = -1`, then the string length will be computed inside the function.

The line buffer can be flushed to an `io` using the function `_nl!`.

# Return

- The new string, which is `str` cropped to fit the display.
- The suffix to be appended to the cropped string.
- The number of columns that will be used to print the string and the suffix.
"""
function _fit_str_to_display(
    display::Display,
    str::String,
    final_line_print::Bool = false,
    lstr::Int = -1
)
    # Get the size of the string if required.
    lstr < 0 && (lstr = textwidth(str))

    # `sapp` is a string to be appended to `str`. This is used to add `⋯` if the
    # text must be wrapped. Notice that `lapp` is the length of `sapp`.
    sapp = ""
    lapp = 0

    # When printing a line, we must verify if the display has bounds. This is
    # done by looking if the horizontal size is positive.
    @inbounds if display.size[2] > 0

        # If we are at the end of the line, then just return.
        _eol(display) && return "", "", 0

        Δ = display.size[2] - (lstr + display.col)

        # Check if we can print the entire string.
        if Δ <= 0
            # If we cannot, then create a wrapped string considering how many
            # columns are left.
            cropped_str_len = lstr + Δ - 2

            if cropped_str_len > 0
                # Here we crop the string considering the available space
                # reserving 2 characters for the line continuation indicator.
                str  = _crop_str(str, cropped_str_len)
                lstr = cropped_str_len
                sapp = display.cont_space_char * display.cont_char
                lapp = 2
            else
                # In this case, we do not have space to show any part of the
                # string.
                display_rem_chars = display.size[2] - display.col

                if display_rem_chars == 2
                    # If there are only 2 characters left, then we must only
                    # print " ⋯".
                    str  = ""
                    lstr = 0
                    sapp = display.cont_space_char * display.cont_char
                    lapp = 2
                elseif display_rem_chars == 1
                    # If there are only 1 character left, then we must only
                    # print "⋯".
                    str  = ""
                    lstr = 0
                    sapp = string(display.cont_char)
                    lapp = 1
                else
                    # This should never be reached.
                    error("Internal error!")
                end
            end

            # In this case, we reached the end of display. Thus, remove any
            # trailing spaces.
            sapp_strip = rstrip(sapp)
            sapp = String(sapp_strip)

            if length(sapp) == 0
                str_strip = rstrip(str)
                str = String(str_strip)
            end

        elseif !final_line_print
            # Here we must verify if this is the final printing on this line. If
            # it is, then we should just check if the entire string fits on the
            # available size. Otherwise, we must see if, after printing the
            # current string, we will have more than 1 space left. If not, then
            # we just add the continuation character sequence.

            if Δ == 1
                str   = (lstr > 1) ? _crop_str(str, lstr - 1) : ""
                lstr -= 1
                sapp  = display.cont_space_char * display.cont_char
                lapp  = 2

                # In this case, we reached the end of display. Thus, remove any
                # trailing spaces.
                sapp_strip = rstrip(sapp)
                sapp = String(sapp_strip)

                if length(sapp) == 0
                    str_strip = rstrip(str)
                    str = String(str_strip)
                end
            end
        end
    end

    return str, sapp, lstr + lapp
end

"""
    _nl!(display::Display, io::IO)

Flush the internal line buffer of `display` into `io`.
"""
function _nl!(display::Display, io::IO)
    # Update the information about the current columns and row of the display.
    display.row += 1
    display.col  = 0

    # Flush the current line to the buffer removing any trailing space.
    str = String(rstrip(String(take!(display.buf_line))))
    println(io, str)

    return nothing
end

"""
    _p!(display::Display, crayon::Crayon, str::Char, final_line_print::Bool = false, lstr::Int = -1)
    _p!(display::Display, crayon::Crayon, str::String, final_line_print::Bool = false, lstr::Int = -1)

Print `str` into the internal line buffer of `display` using the Crayon `crayon`
with the display information in `display`. The parameter `final_line_print` must
be set to `true` if this is the last string that will be printed in the line.
This is necessary for the algorithm to select whether or not to include the
continuation character.

The size of the string can be passed to `lstr` to save computational burden. If
`lstr = -1`, then the string length will be computed inside the function.

The line buffer can be flushed to an `io` using the function `_nl!`.
"""
function _p!(
    display::Display,
    crayon::Crayon,
    str::Char,
    final_line_print::Bool = false,
    lstr::Int = -1
)
    return _p!(display, crayon, string(str), final_line_print, lstr)
end

function _p!(
    display::Display,
    crayon::Crayon,
    str::String,
    final_line_print::Bool = false,
    lstr::Int = -1
)
    _eol(display) && return true

    # Compute the new string given the display size.
    str, suffix, num_printed_cols = _fit_str_to_display(
        display,
        str,
        final_line_print,
        lstr
    )

    return _write_to_display!(display, crayon, str, suffix, num_printed_cols)
end

"""
    _pc!(cond::Bool, display::Display, io::IO, crayon::Crayon, str_true::Union{Char,String}, str_false::Union{Char,String}, final_line_print::Bool = false, lstr_true::Int = -1, lstr_false::Int = -1)

If `cond == true` then print `str_true`. Otherwise, print `str_false`. Those
strings will be printed into the internal line buffer of `display` using the
Crayon `crayon` with the display information in `display`. The parameter
`final_line_print` must be set to `true` if this is the last string that will be
printed in the line. This is necessary for the algorithm to select whether or
not to include the continuation character.

The size of the strings can be passed to `lstr_true` and `lstr_false` to save
computational burden. If they are `-1`, then the string lengths will be computed
inside the function.
"""
function _pc!(
    cond::Bool,
    display::Display,
    crayon::Crayon,
    str_true::Union{Char,String},
    str_false::Union{Char,String},
    final_line_print::Bool = false,
    lstr_true::Int = -1,
    lstr_false::Int = -1
)
    if cond
        return _p!(display, crayon, str_true, final_line_print, lstr_true)
    else
        return _p!(display, crayon, str_false, final_line_print, lstr_false)
    end
end

function _write_to_display!(
    display::Display,
    crayon::Crayon,
    str::String,
    suffix::String,
    num_printed_cols::Int
)
    if num_printed_cols < 0
        num_printed_cols = textwidth(str) + textwidth(suffix)
    end

    # Print the with correct formating.
    #
    # Notice that all text printed with crayon is reset right after the string.
    # Hence, if the crayon is empty (`_default_crayon`) or if it is a reset,
    # then we can just print as if the terminal does not support color.
    if (crayon != _default_crayon) && (crayon != _reset_crayon) && display.has_color
        print(display.buf_line, crayon, str, _reset_crayon, suffix)
    else
        print(display.buf_line, str, suffix)
    end

    # Update the current columns.
    display.col += num_printed_cols

    # Return if we reached the end of line.
    return _eol(display)
end
