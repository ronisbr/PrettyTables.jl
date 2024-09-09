## Description #############################################################################
#
# Functions related to display manipulation.
#
############################################################################################

function _text__check_eol(display::Display)
    w = display.size[2]
    return (w > 0) && (display.column > display.size[2])
end

_text__print(display::Display, char::Char) = _text__print(display, string(char))

function _text__print(display::Display, str::AbstractString)
    _text__check_eol(display) && return nothing
    print(display.buf_line, str)
    display.column += textwidth(str)
    return nothing
end

function _text__flush_line(display::Display)
    dw   = display.size[2]
    line = String(take!(display.buf_line))

    if (dw > 0) && (display.column > dw)
        line =
            first(right_crop(line, display.column - dw + 2)) *
            " $(display.continuation_char)"
    end

    println(display.buf, line)
    display.column = 0
    display.row += 1
    return nothing
end

function _text__aligned_print(
    display::Display,
    str::AbstractString,
    cell_width::Int,
    alignment::Symbol
)
    if alignment == :r
        _text__print(display, lpad(str, cell_width))

    elseif alignment == :c
        tw = textwidth(str)
        Δ = max(div(cell_width - tw, 2), 0)
        _text__print(display, " "^Δ * str * " "^(cell_width - tw - Δ))

    else
        _text__print(display, rpad(str, cell_width))
    end

    return nothing
end
