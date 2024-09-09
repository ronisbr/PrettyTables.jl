## Description #############################################################################
#
# Types and structures for the text back end
#
############################################################################################

############################################################################################
#                                         Display                                          #
############################################################################################

"""
    struct Display

Store the information of the display and the current cursor position.

!!! note

    This is not the real cursor position with respect to the display, but with respect to
    the point in which the table is printed.

# Fields

- `size::Tuple{Int, Int}`: Display size.
- `row::Int`: Current row.
- `column::Int`: Current column.
- `has_color::Bool`: Indicates if the display has color support.
- `continuation_char::Char`: The character that indicates the line is cropped.
- `buf_line::IOBuffer`:  Buffer that stores the current line.
- `buf::IOBuffer`: Buffer that stores the entire output.
"""
@kwdef mutable struct Display
    size::Tuple{Int,Int}    = (-1, -1)
    row::Int                = 1
    column::Int             = 0
    has_color::Bool         = false
    continuation_char::Char = '⋯'

    # Buffer that stores the entire output.
    buf::IOBuffer = IOBuffer()
    # Buffer that stores the current line.
    buf_line::IOBuffer = IOBuffer()
end

############################################################################################
#                                       Table Format                                       #
############################################################################################

@kwdef struct TextTableFormat
    # == Border and Lines ==================================================================

    up_right_corner::Char      = '┐'
    up_left_corner::Char       = '┌'
    bottom_left_corner::Char   = '└'
    bottom_right_corner::Char  = '┘'
    up_intersection::Char      = '┬'
    left_intersection::Char    = '├'
    right_intersection::Char   = '┤'
    middle_intersection::Char  = '┼'
    bottom_intersection::Char  = '┴'
    column::Char               = '│'
    row::Char                  = '─'

    # == Other Configurations ==============================================================

    continuation_char::Char = '⋯'
end
