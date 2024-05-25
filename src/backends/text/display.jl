## Description #############################################################################
#
# Functions related to display printing and manipulation.
#
############################################################################################

# Return the available rows in `display`. If there is no row limit, this function returns
# -1.
function _available_rows(display::Display)
    if display.size[1] > 0
        return display.size[1] - display.row
    else
        return -1
    end
end

# Draw the continuation row when the table has filled the vertical space available. This
# function prints in each column the character `⋮` with the alignment in `alignment`.
function _draw_continuation_line(
    display::Display,
    ptable::ProcessedTable,
    tf::TextFormat,
    text_crayon::Crayon,
    border_crayon::Crayon,
    columns_width::Vector{Int},
    vlines::Union{Symbol, Vector{Int}},
    alignment::Symbol
)
    # In case of a continuation row, we want the last character to indicate that the table
    # continues both vertically and horizontally in case the text is cropped.
    old_cont_char = display.cont_char
    display.cont_char = '⋱'

    num_cols = length(columns_width)

    _check_vline(ptable, vlines, 0) && _p!(display, border_crayon, tf.column)

    @inbounds for j in 1:num_cols
        str = " " * align_string("⋮", columns_width[j], alignment; fill = true) * " "
        final_line_print = j == num_cols

        _p!(display, text_crayon, str, false) && break

        if _check_vline(ptable, vlines, j)
            _p!(display, border_crayon, tf.column, final_line_print, 1) && break
        end
    end

    _nl!(display)

    display.cont_char = old_cont_char

    return nothing
end

# Draw a vertical line in internal line buffer of `display` and then flush to the `io`.
function _draw_line!(
    display::Display,
    ptable::ProcessedTable,
    left::Char,
    intersection::Char,
    right::Char,
    row::Char,
    border_crayon::Crayon,
    columns_width::Vector{Int},
    vlines::Union{Symbol, AbstractVector},
)
    # We does not want to add ellipsis when drawing lines.
    old_cont_char           = display.cont_char
    old_cont_space_char     = display.cont_space_char
    display.cont_char       = row
    display.cont_space_char = row
    display.cont_reset      = false

    num_cols = length(columns_width)

    _check_vline(ptable, vlines, 0) && _p!(display, border_crayon, left)

    @inbounds for i in 1:num_cols
        # Check the alignment and print.
        _p!(display, border_crayon, row^(columns_width[i] + 2)) && break

        if i != num_cols
            if _check_vline(ptable, vlines, i)
                _p!(display, border_crayon, intersection, false, 1) && break
            end
        end
    end

    if _check_vline(ptable, vlines, num_cols)
        _p!(display, border_crayon, right, true, 1)
    end

    _nl!(display)

    display.cont_char       = old_cont_char
    display.cont_space_char = old_cont_space_char
    display.cont_reset      = true

    return nothing
end

# Return `true` if the cursor is at the end of line or `false` otherwise.
function _eol(display::Display)
    return (display.size[2] > 0) && (display.column >= display.size[2])
end

# Return the string and the suffix to be printed in the display. It ensures that the return
# data will fit the `display`.
#
# The parameter `final_line_print` must be set to `true` if this is the last string that
# will be printed in the line. This is necessary for the algorithm to select whether or not
# to include the continuation character.
#
# The size of the string can be passed to `lstr` to save computational burden.  If
# `lstr = -1`, then the string length will be computed inside the function.
#
# The line buffer can be flushed to an `io` using the function `_nl!`.
#
# # Return
#
# - The new string, which is `str` cropped to fit the display.
# - The suffix to be appended to the cropped string.
# - The number of columns that will be used to print the string and the suffix.
function _fit_string_in_display(
    display::Display,
    str::String,
    final_line_print::Bool = false,
    lstr::Int = -1
)
    # Get the size of the string if required.
    lstr < 0 && (lstr = textwidth(str))

    @inbounds if display.size[2] > 0
        # We need to check the continuation string that the user wants to display. The width
        # of this string must be used as a margin to the cropping algorithm.
        cont_str     = string(display.cont_space_char) * string(display.cont_char)
        field_margin = textwidth(cont_str)

        # Get the number of characters we need to crop to fit the display.
        crop = get_crop_to_fit_string_in_field(
            str,
            display.size[2] - display.column - field_margin;
            add_continuation_char = false,
            continuation_char = display.cont_char,
            printable_string_width = lstr
        )

        # There are two situations in which we do not need to crop the string:
        #
        #   1. If the number of characters that must be cropped is 0, it means that we have
        #      enough size to display the string plus the continuation characters. Thus, we
        #      just print the current string now. If the continuation characters are needed,
        #      they will be printed in the next cell.
        #   2. If the number of characters that must be cropped equals the size of the
        #      continuation string and we are at the final line print, we just need to print
        #      the string.

        if (final_line_print && (crop ≤ field_margin)) || (crop == 0)
            suffix = ""
            num_columns = lstr

        else
            suffix = cont_str

            str, ~ = right_crop(
                str,
                crop;
                keep_escape_seq = false,
                printable_string_width = lstr
            )

            num_columns = lstr - crop + field_margin
        end

    else
        suffix = ""
        num_columns = lstr

    end

    return str, suffix, num_columns
end

# Flush the content of the display buffer into `io`.
function _flush_display!(
    io::IO,
    display::Display,
    overwrite::Bool,
    newline_at_end::Bool,
    num_displayed_rows::Int
)
    # If `overwrite` is `true`, then delete the exact number of lines of the table. This can
    # be used to replace the table in the display continuously.
    str_overwrite = overwrite ? "\e[1F\e[2K"^(num_displayed_rows - 1) : ""

    output_str = String(take!(display.buf))

    # Check if the user does not want a newline at end.
    !newline_at_end && (output_str = String(chomp(output_str)))

    print(io, str_overwrite * output_str)

    return nothing
end

# Flush the internal line buffer of `display`. It correspond to a new line in the buffer.
function _nl!(display::Display)
    # Update the information about the current columns and row of the display.
    display.row += 1
    display.column = 0

    # Flush the current line to the buffer removing any trailing space.
    str = String(rstrip(String(take!(display.buf_line))))
    println(display.buf, str)

    return nothing
end

# Print `str` into the internal line buffer of `display` using the Crayon `crayon` with the
# display information in `display`. The parameter `final_line_print` must be set to `true`
# if this is the last string that will be printed in the line. This is necessary for the
# algorithm to select whether or not to include the continuation character.
#
# The size of the string can be passed to `lstr` to save computational burden.  If `lstr =
# -1`, then the string length will be computed inside the function.
#
# The line buffer can be flushed to an `io` using the function `_nl!`.
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
    lstr < 0 && (lstr = textwidth(str))

    str, suffix, num_columns = _fit_string_in_display(
        display,
        str,
        final_line_print,
        lstr
    )

    return _write_to_display!(display, crayon, str, suffix, num_columns)
end

# Write the string `str` to the display considering the decoration in `crayon`. It also
# appends a `suffix`, resetting the decoration if required.
function _write_to_display!(
    display::Display,
    crayon::Crayon,
    str::String,
    suffix::String,
    num_printed_text_columns::Int = -1
)
    # If we reached end-of-line, just return.
    _eol(display) && return true

    if num_printed_text_columns < 0
        num_printed_text_columns = textwidth(str) + textwidth(suffix)
    end

    # Print the with correct formating.
    #
    # Notice that all text printed with crayon is reset right after the string. Hence, if
    # the crayon is empty (`_default_crayon`) or if it is a reset, then we can just print as
    # if the terminal does not support color.
    buf_line = display.buf_line

    if (crayon != _default_crayon) && (crayon != _reset_crayon) && display.has_color
        # If we convert the crayon to string using `string`, it calls `print` which checks
        # if the Base has colors, leading to inference problems. For more information, see:
        #
        #   https://github.com/KristofferC/Crayons.jl/issues/62
        write(buf_line, Crayons.CSI)
        Crayons._print(buf_line, crayon)
        write(buf_line, Crayons.END_ANSI)

        write(buf_line, str)
        display.cont_reset && write(buf_line, _reset_crayon_str)
        write(buf_line, suffix)
        display.cont_reset || write(buf_line, _reset_crayon_str)
    else
        write(buf_line, str, suffix)
    end

    # Update the current column in the display.
    display.column += num_printed_text_columns

    # Return if we reached the end of line.
    return _eol(display)
end
