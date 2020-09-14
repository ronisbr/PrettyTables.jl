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
* `vlines`: Vertical lines that must be drawn by default.

# Pre-defined formats

The following pre-defined formats are available: `unicode` (**default**),
`mysql`, `compact`, `markdown`, `simple`, `ascii_rounded`, and `ascii_dots`.

"""
@with_kw struct TextFormat
    up_right_corner::Char                 = '┐'
    up_left_corner::Char                  = '┌'
    bottom_left_corner::Char              = '└'
    bottom_right_corner::Char             = '┘'
    up_intersection::Char                 = '┬'
    left_intersection::Char               = '├'
    right_intersection::Char              = '┤'
    middle_intersection::Char             = '┼'
    bottom_intersection::Char             = '┴'
    column::Char                          = '│'
    row::Char                             = '─'
    hlines::Vector{Symbol}                = [:begin,:header,:end]
    vlines::Union{Symbol,Vector{Symbol}}  = :all
end

"""
    Highlighter

Defines the default highlighter of a table when using the text backend.

# Fields

* `f`: Function with the signature `f(data,i,j)` in which should return `true`
       if the element `(i,j)` in `data` must be highlighter, or `false`
       otherwise.
* `fd`: Function with the signature `f(h,data,i,j)` in which `h` is the
        highlighter. This function must return the `Crayon` to be applied to the
        cell that must be highlighted.
* `crayon`: The `Crayon` to be applied to the highlighted cell if the default
            `fd` is used.

# Remarks

This structure can be constructed using three helpers:

    Highlighter(f::Function; kwargs...)

where it will construct a `Crayon` using the keywords in `kwargs` and apply it
to the highlighted cell,

    Highlighter(f::Function, crayon::Crayon)

where it will apply the `crayon` to the highlighted cell, and

    Highlighter(f::Function, fd::Function)

where it will apply the `Crayon` returned by the function `fd` to the
highlighted cell.

"""
@with_kw struct Highlighter
    f::Function
    fd::Function = (h,data,i,j)->h.crayon

    # Private
    crayon::Crayon = Crayon()
end

Highlighter(f; kwargs...) = Highlighter(f = f, crayon = Crayon(;kwargs...))
Highlighter(f, crayon::Crayon) = Highlighter(f = f, crayon = crayon)
Highlighter(f::Function, fd::Function) = Highlighter(f = f, fd = fd)

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
* `max_col`: Store the largest column that was printed.

"""
@with_kw mutable struct Screen
    size::Tuple{Int,Int} = (-1,-1)
    row::Int             = 1
    col::Int             = 0
    has_color::Bool      = false
    max_col::Int         = 0
end

################################################################################
#                                  Constants
################################################################################

# Crayon used to reset all the styling.
const _reset_crayon = Crayon(reset = true)
