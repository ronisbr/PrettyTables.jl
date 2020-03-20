# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Types and structures for the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export TextFormat, Highlighter

"""
    TextFormat

# Fields

* `up_right_corner`: Character in the up right corner.
* `up_left_corner`: Character in the up left corner.
* `bottom_left_corner`: Character in the bottom left corner.
* `bottom_right_corner`: Character in the bottom right corner.
* `up_intersection`: Character in the intersection of lines in the up part.
* `left_intersection`: Character in the intersection of lines in the left part.
* `right_intersection`: Character in the intersection of lines in the right
                        part.
* `middle_intersection`: Character in the intersection of lines in the middle of
                         the table.
* `bottom_intersection`: Character in the intersection of the lines in the
                         bottom part.
* `column`: Character in a vertical line inside the table.
* `left_border`: Character used as the left border.
* `right_border`: Character used as the right border.
* `row`: Character in a horizontal line inside the table.
* `hlines`: Horizontal lines that must be drawn by default.

# Pre-defined formats

The following pre-defined formats are available: `unicode` (**default**),
`mysql`, `compact`, `markdown`, `simple`, `ascii_rounded`, and `ascii_dots`.

"""
@with_kw struct TextFormat
    up_right_corner::Char     = '┐'
    up_left_corner::Char      = '┌'
    bottom_left_corner::Char  = '└'
    bottom_right_corner::Char = '┘'
    up_intersection::Char     = '┬'
    left_intersection::Char   = '├'
    right_intersection::Char  = '┤'
    middle_intersection::Char = '┼'
    bottom_intersection::Char = '┴'
    column::Char              = '│'
    left_border::Char         = '│'
    right_border::Char        = '│'
    row::Char                 = '─'
    hlines::Vector{Symbol}    = [:begin,:header,:end]
end

"""
    Highlighter

Defines the highlighter of a table when using the text backend.

# Fileds

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighter, or `false`
       otherwise.
* `crayon`: Crayon with the style of a highlighted element.

"""
@with_kw struct Highlighter
    f::Function
    crayon::Crayon
end

"""
    Highlighter(f; kwargs...)

Construct a `Highlighter` with activation function `f` and pass all the keyword
arguments `kwargs` to `Crayon`.

"""
Highlighter(f; kwargs...) = Highlighter(f = f, crayon = Crayon(;kwargs...))

"""
    Screen

Store the information of the screen and the current cursor position. Notice that
this is not the real cursor position with respect to the screen, but with
respect to the point in which the table is printed.

# Fields

* `size`: Screen size.
* `row`: Current row.
* `col`: Current column.
* `has_color`: Indicates if the screen has color support.

"""
@with_kw mutable struct Screen
    size::Tuple{Int,Int} = (-1,-1)
    row::Int             = 1
    col::Int             = 0
    has_color::Bool      = false
end
