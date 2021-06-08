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

A text cell that contains an URL and is rendered using the conceal ANSI escape
sequence.

!!! warn
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
@kwdef mutable struct URLTextCell <: CustomTextCell
    # Public
    text::String
    url::String

    # Private
    _crop::Int = 0
    _left_pad::Int = 0
    _right_pad::Int = 0
    _suffix::String = ""

    function URLTextCell(text::String, url::String)
        new(text, url, 0, 0, 0, "")
    end
end

################################################################################
#                                     API
################################################################################

function get_printable_cell_line(c::URLTextCell, l::Int)
    if l == 1
        return c.text
    else
        return ""
    end
end

function get_rendered_line(c::URLTextCell, l::Int)
    if l == 1
        proc_text = _crop_str(c.text, textwidth(c.text) - c._crop)
        str = "\e]8;;" * c.url * "\e\\" * proc_text * "\e]8;;\e\\" * c._suffix
        str = " "^c._left_pad * str * " "^c._right_pad
        return str
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

