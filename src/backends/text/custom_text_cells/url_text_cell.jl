# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Text cell to render an URL.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export URLTextCell

"""
    URLTextCell

A text cell that contains a URL and is rendered using the ANSI escape sequence
`\\e8]`.

!!! warning
    Some terminals **do not** support this feature, leading to a layout problem
    in the printed table.

# Fields

**Public**

- `text::String`: The label of the URL.
- `url::String`: The URL.

**Private**

- `_crop::Int`: Number of characters in the text that must be cropped when
    rendering the URL.
- `_left_pad::Int`: Number of spaces to be added to the left of the text when
    rendering the URL.
- `_right_pad::Int`: Number of spaces to be added to the right of the text when
    rendering the URL.
- `_suffix::String`: Suffix to be appended to the text when rendering the URL.
"""
mutable struct URLTextCell <: CustomTextCell
    # Public
    text::String
    url::String

    # Private
    _crop::Int
    _left_pad::Int
    _right_pad::Int
    _suffix::String
end

function URLTextCell(text::String, url::String)
    return URLTextCell(text, url, 0, 0, 0, "")
end

################################################################################
#                                     API
################################################################################

function get_printable_cell_line(c::URLTextCell, l::Int)
    if l == 1
        return " "^c._left_pad * c.text * " "^c._right_pad
    else
        return ""
    end
end

function get_rendered_line(c::URLTextCell, l::Int)
    if l == 1
        url_text_width = textwidth(c.text)
        printable_size = c._left_pad + url_text_width + c._right_pad
        rem_chars = printable_size - c._crop

        # Left padding
        # ======================================================================

        Δ = clamp(rem_chars, 0, c._left_pad)
        str = " " ^ Δ
        rem_chars ≤ c._left_pad && return str * c._suffix
        rem_chars -= c._left_pad

        # URL text
        # ======================================================================

        Δ = clamp(rem_chars, 0, url_text_width)
        proc_text = _crop_str(c.text, Δ)
        str *= "\e]8;;" * c.url * "\e\\" * proc_text * "\e]8;;\e\\"
        rem_chars ≤ url_text_width && return str * c._suffix
        rem_chars -= url_text_width

        # Right padding
        # ======================================================================

        Δ = clamp(rem_chars, 0, c._right_pad)
        str *= " " ^ Δ
        return str * c._suffix
    else
        return ""
    end
end

function append_suffix_to_line!(c::URLTextCell, l::Int, suffix::String)
    l == 1 && (c._suffix = suffix)
    return nothing
end

function apply_line_padding!(c::URLTextCell, l::Int, left_pad::Int, right_pad::Int)
    if l == 1
        c._left_pad = left_pad
        c._right_pad = right_pad
    end

    return nothing
end

function crop_line!(c::URLTextCell, l::Int, num::Int)
    l == 1 && (c._crop = num)
    return nothing
end

parse_cell_text(c::URLTextCell; kwargs...) = [c.text]

function reset!(c::URLTextCell)
    c._crop = 0
    c._left_pad = 0
    c._right_pad = 0
    c._suffix = ""

    return nothing
end

