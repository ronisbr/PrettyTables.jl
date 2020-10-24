# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to screen printing and manipulation.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function _compute_omitted_rows_and_cols(screen::Screen,
                                        num_cols::Int,
                                        num_rows::Int,
                                        cols_width::Vector{Int},
                                        num_lines_in_row::Vector{Int},
                                        num_printed_cols::Int,
                                        num_printed_rows::Int,
                                        header_num_rows::Int,
                                        noheader::Bool,
                                        vlines::Vector{Int},
                                        hlines::Vector{Int},
                                        Δc::Int,
                                        Δscreen_lines::Int)
    num_omitted_cols = 0
    num_omitted_rows = 0

    # Compute the number of omitted columns.
    if screen.size[2] > 0
        num_fully_printed_cols = 0
        accum_size = 0 ∈ vlines ? 2 : 1

        @inbounds for i = 1:num_printed_cols
            accum_size += cols_width[i]
            accum_size ≥ (screen.size[2] - 1) && break
            num_fully_printed_cols += 1
            accum_size += 2
            i ∈ vlines && (accum_size += 1)
        end

        num_omitted_cols = clamp(num_cols - num_fully_printed_cols + Δc,
                                 0, num_cols)
    end

    if screen.size[1] > 0
        # Compute the number of omitted rows.
        num_fully_printed_rows = 0
        accum_size = 0 ∈ hlines ? 1 : 0

        if !noheader
            accum_size += header_num_rows
            accum_size += 1 ∈ hlines ? 1 : 0
        end

        # Compute the limit of `accum_size` that leads to data cropping. Notice
        # that we must subtract `2` to account for the continuation line and the
        # summary line.
        accum_size_limit = screen.size[1] - Δscreen_lines - 2

        @inbounds for j = 1:num_printed_rows
            accum_size += num_lines_in_row[j]

            if accum_size > accum_size_limit
                # If no omitted cells are printed, then we can have 2 additional
                # spaces. Hence, if there are only 2 lines left to be printed
                # and not column is omitted, then nothing will be cropped.
                if (num_omitted_cols == 0)
                    remaining_lines = j < num_printed_rows ?
                        sum(num_lines_in_row[j+1:num_printed_rows]) : 0

                    accum_size + remaining_lines ≤ accum_size_limit + 2 &&
                        (num_fully_printed_rows = num_printed_rows)
                end

                break
            end

            num_fully_printed_rows += 1
            (j+!noheader) ∈ hlines && (accum_size += 1)
        end

        num_omitted_rows = num_rows - num_fully_printed_rows
    end

    return num_omitted_cols, num_omitted_rows
end

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

    # In case of a continuation row, we want the last character to indicate that
    # the table continues both vertically and horizontally in case the text is
    # cropped.
    old_cont_char = screen.cont_char
    screen.cont_char = '⋱'

    num_cols = length(cols_width)

    0 ∈ vlines && _p!(screen, border_crayon, tf.column)

    @inbounds for j = 1:num_cols
        data_ij_str, data_ij_len = _str_aligned("⋮", alignment, cols_width[j])
        data_ij_str  = " " * data_ij_str * " "
        data_ij_len += 2

        flp = j == num_cols

        _p!(screen, text_crayon, data_ij_str, false, data_ij_len)
        _pc!(j ∈ vlines, screen, border_crayon, tf.column, "", flp, 1, 0)
        _eol(screen) && break
    end

    _nl!(screen, io)

    screen.cont_char = old_cont_char

    return nothing
end

"""
    _draw_line!(screen::Screen, io::IO, left::Char, intersection::Char, right::Char, row::Char, border_crayon::Crayon, cols_width::Vector{Int}, vlines::Vector{Int})

Draw a vertical line in internal line buffer of `screen` and then flush to the
io `io`.

"""
function _draw_line!(screen::Screen, io::IO, left::Char, intersection::Char,
                     right::Char, row::Char, border_crayon::Crayon,
                     cols_width::Vector{Int}, vlines::Vector{Int})

    # We does not want to add ellipsis when drawing lines.
    old_cont_char          = screen.cont_char
    old_cont_space_char    = screen.cont_space_char
    screen.cont_char       = row
    screen.cont_space_char = row

    num_cols = length(cols_width)

    0 ∈ vlines && _p!(screen, border_crayon, left)

    @inbounds for i = 1:num_cols
        # Check the alignment and print.
        _p!(screen, border_crayon, row^(cols_width[i]+2)) && break

        i != num_cols &&
            _pc!(i ∈ vlines, screen, border_crayon, intersection, "")
    end

    _pc!(num_cols ∈ vlines, screen, border_crayon, right, "", true)
    _nl!(screen, io)

    screen.cont_char       = old_cont_char
    screen.cont_space_char = old_cont_space_char

    return nothing
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

Flush the internal line buffer of `screen` into `io`.

"""
function _nl!(screen::Screen, io::IO)
    # Update the information about the current columns and row of the screen.
    screen.row += 1
    screen.col  = 0

    # Flush the current line to the buffer removing any trailing space.
    str = rstrip(String(take!(screen.buf_line)))
    println(io, str)
end

"""
    _p!(screen::Screen, crayon::Crayon, str::Char, final_line_print::Bool = false, lstr::Int = -1)
    _p!(screen::Screen, crayon::Crayon, str::String, final_line_print::Bool = false, lstr::Int = -1)

Print `str` into the internal line buffer of `screen` using the Crayon `crayon`
with the screen information in `screen`. The parameter `final_line_print` must
be set to `true` if this is the last string that will be printed in the line.
This is necessary for the algorithm to select whether or not to include the
continuation character.

The size of the string can be passed to `lstr` to save computational burden. If
`lstr = -1`, then the string length will be computed inside the function.

The line buffer can be flushed to an `io` using the function `_nl!`.

"""
_p!(screen::Screen, crayon::Crayon, str::Char, final_line_print::Bool = false,
    lstr::Int = -1) = _p!(screen, crayon, string(str), final_line_print, lstr)

function _p!(screen::Screen, crayon::Crayon, str::String,
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
                sapp = screen.cont_space_char * screen.cont_char
                lapp = 2
            elseif screen.size[2] - screen.col == 2
                # If there are only 2 characters left, then we must only print
                # " ⋯".
                str  = ""
                lstr = 0
                sapp = screen.cont_space_char * screen.cont_char
                lapp = 2
            elseif screen.size[2] - screen.col == 1
                # If there are only 1 character left, then we must only print
                # "⋯".
                str  = ""
                lstr = 0
                sapp = string(screen.cont_char)
                lapp = 1
            else
                # This should never be reached.
                @error("Internal error!")
                return true
            end

            # In this case, we reached the end of screen. Thus, remove any
            # trailing spaces.
            sapp = rstrip(sapp)
            length(sapp) == 0 && (str = rstrip(str))

        elseif !final_line_print
            # Here we must verify if this is the final printing on this line. If
            # it is, then we should just check if the entire string fits on the
            # available size. Otherwise, we must see if, after printing the
            # current string, we will have more than 1 space left. If not, then
            # we just add the continuation character sequence.

            if Δ == 1
                str   = lstr > 1 ? _crop_str(str, lstr - 1) : ""
                lstr -= 1
                sapp  = screen.cont_space_char * screen.cont_char
                lapp  = 2

                # In this case, we reached the end of screen. Thus, remove any
                # trailing spaces.
                sapp = rstrip(sapp)
                length(sapp) == 0 && (str = rstrip(str))
            end
        end
    end

    # Print the with correct formating.
    #
    # Notice that all text printed with crayon is reset right after the string.
    # Hence, if the crayon is empty (`_default_crayon`) or if it is a reset,
    # then we can just print as if the terminal does not support color.
    if (crayon != _default_crayon) && (crayon != _reset_crayon) && screen.has_color
        print(screen.buf_line, crayon, str, _reset_crayon, sapp)
    else
        print(screen.buf_line, str, sapp)
    end

    # Update the current columns.
    screen.col += lstr + lapp

    # Return if we reached the end of line.
    return _eol(screen)
end

"""
    _pc!(cond::Bool, screen::Screen, io::IO, crayon::Crayon, str_true::Union{Char,String}, str_false::Union{Char,String}, final_line_print::Bool = false, lstr_true::Int = -1, lstr_false::Int = -1)

If `cond == true` then print `str_true`. Otherwise, print `str_false`. Those
strings will be printed into the internal line buffer of `screen` using the
Crayon `crayon` with the screen information in `screen`. The parameter
`final_line_print` must be set to `true` if this is the last string that will be
printed in the line. This is necessary for the algorithm to select whether or
not to include the continuation character.

The size of the strings can be passed to `lstr_true` and `lstr_false` to save
computational burden. If they are `-1`, then the string lengths will be computed
inside the function.

"""
function _pc!(cond::Bool, screen::Screen, crayon::Crayon,
              str_true::Union{Char,String}, str_false::Union{Char,String},
              final_line_print::Bool = false, lstr_true::Int = -1,
              lstr_false::Int = -1)
    if cond
        return _p!(screen, crayon, str_true, final_line_print, lstr_true)
    else
        return _p!(screen, crayon, str_false, final_line_print, lstr_false)
    end
end
