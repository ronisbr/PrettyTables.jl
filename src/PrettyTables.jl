module PrettyTables

using Formatting
using Parameters
using Reexport
using Tables

@reexport using Crayons

export Highlighter, PrettyTableFormat

################################################################################
#                                    Types
################################################################################

"""
    struct PrettyTableFormat

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
* `column`: Character in a vertical line.
* `row`: Character in a horizontal line.
* `top_line`: If `true`, then the top table line will be drawn.
* `header_line`: If `true`, then the line between the header and the data will
                 be drawn.
* `bottom_line`: If `true`, then the bottom table line will be drawn.

# Pre-defined formats

The following pre-defined formats are available: `unicode` (**default**),
`mysql`, `compact`, `markdown`, `simple`, `ascii_rounded`, and `ascii_dots`.

"""
@with_kw struct PrettyTableFormat
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
    row::Char                 = '─'
    top_line::Bool            = true
    header_line::Bool         = true
    bottom_line::Bool         = true
end

"""
    struct Highlighter

Defines the highlighter of a table.

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
    function Highlighter(f; kwargs...)

Construct a `Highlighter` with activation function `f` and pass all the keyword
arguments `kwargs` to `Crayon`.

"""
Highlighter(f; kwargs...) = Highlighter(f = f, crayon = Crayon(;kwargs...))

################################################################################
#                                  Constants
################################################################################

# Crayon used to reset all the styling.
const _reset_crayon = Crayon(reset = true)

################################################################################
#                                  Includes
################################################################################

include("predefined_formats.jl")
include("predefined_highlighters.jl")
include("predefined_formatters.jl")
include("helpers.jl")
include("print.jl")

end # module
