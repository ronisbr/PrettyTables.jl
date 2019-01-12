module PrettyTables

using Parameters

export PrettyTableFormat

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
    bottom_line::Bool         = true
end

################################################################################
#                                  Includes
################################################################################

include("predefined_formats.jl")
include("print.jl")

end # module
