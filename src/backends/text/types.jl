## Description #############################################################################
#
# Types and structures for the text backend.
#
############################################################################################

export TextFormat, Highlighter, CustomTextCell

"""
    struct TextFormat

# Fields

- `up_right_corner::Char`: Character in the up right corner.
- `up_left_corner::Char`: Character in the up left corner.
- `bottom_left_corner::Char`: Character in the bottom left corner.
- `bottom_right_corner::Char`: Character in the bottom right corner.
- `up_intersection::Char`: Character in the intersection of lines in the up part.
- `left_intersection::Char`: Character in the intersection of lines in the left part.
- `right_intersection::Char`: Character in the intersection of lines in the right part.
- `middle_intersection::Char`: Character in the intersection of lines in the middle of the
    table.
- `bottom_intersection::Char`: Character in the intersection of the lines in the bottom
    part.
- `column::Char`: Character in a vertical line inside the table.
- `row::Char`: Character in a horizontal line inside the table.
- `hlines::Vector{Symbol}`: Horizontal lines that must be drawn by default.
- `vlines::Union{Symbol, Vector{Symbol}}`: Vertical lines that must be drawn by default.

# Pre-defined formats

The following pre-defined formats are available: `unicode` (**default**), `mysql`,
`compact`, `markdown`, `simple`, `ascii_rounded`, and `ascii_dots`.
"""
@kwdef struct TextFormat
    up_right_corner::Char                  = '┐'
    up_left_corner::Char                   = '┌'
    bottom_left_corner::Char               = '└'
    bottom_right_corner::Char              = '┘'
    up_intersection::Char                  = '┬'
    left_intersection::Char                = '├'
    right_intersection::Char               = '┤'
    middle_intersection::Char              = '┼'
    bottom_intersection::Char              = '┴'
    column::Char                           = '│'
    row::Char                              = '─'
    hlines::Vector{Symbol}                 = [:begin, :header, :end]
    vlines::Union{Symbol, Vector{Symbol}}  = :all
end

"""
    struct Highlighter

Defines the default highlighter of a table when using the text backend.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i,j)` in `data` must be highlighter, or `false` otherwise.
- `fd::Function`: Function with the signature `f(h, data, i, j)` in which `h` is the
    highlighter. This function must return the `Crayon` to be applied to the cell that must
    be highlighted.
- `crayon::Crayon`: The `Crayon` to be applied to the highlighted cell if the default `fd`
    is used.

# Remarks

This structure can be constructed using three helpers:

    Highlighter(f::Function; kwargs...)

where it will construct a `Crayon` using the keywords in `kwargs` and apply it to the
highlighted cell,

    Highlighter(f::Function, crayon::Crayon)

where it will apply the `crayon` to the highlighted cell, and

    Highlighter(f::Function, fd::Function)

where it will apply the `Crayon` returned by the function `fd` to the highlighted cell.
"""
@kwdef struct Highlighter
    f::Function
    fd::Function = (h, data, i, j) -> h.crayon

    # Private
    crayon::Crayon = Crayon()
end

Highlighter(f; kwargs...) = Highlighter(f = f, crayon = Crayon(;kwargs...))
Highlighter(f, crayon::Crayon) = Highlighter(f = f, crayon = crayon)
Highlighter(f::Function, fd::Function) = Highlighter(f = f, fd = fd)

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
- `cont_char::Char`: The character that indicates the line is cropped.
- `cont_reset::Bool`: If `true`, the decoration will be reseted before printing the
    continuation character. Otherwise, the decoration will be reseted after printing the
    continuation character.
- `cont_space_char::Char`: Space character to be printed before `cont_char`.
"""
@kwdef mutable struct Display
    size::Tuple{Int,Int}  = (-1, -1)
    row::Int              = 1
    column::Int           = 0
    has_color::Bool       = false
    cont_char::Char       = '⋯'
    cont_reset::Bool      = true
    cont_space_char::Char = ' '

    # Buffer that stores the current line.
    buf_line::IOBuffer = IOBuffer()
    # Buffer that stores the entire output.
    buf::IOBuffer = IOBuffer()
end

"""
    abstract type CustomTextCell

Abstract type of custom cells in the text backend.

Each type must implement the following API:

- `get_printable_cell_text`: A function that must return a vector of strings with the
    printable text, *i.e.* without any non-printable character.
- `get_rendered_line`: A function that must return the rendered line that will be printed to
    the display.
- `apply_line_padding!`: Apply a certain number of spaces to the left and right of a
    specific line.
- `crop_line!`: A function that must crop a certain number of printable characters from the
    end of the line.
- `append_suffix_to_line!`: Append a string suffix to a line of the custom cell.
- `apply_line_padding!`: Apply left and right padding to a line of the custom cell.
- `crop_line!`: Crop a certain number of characters from a line of the custom cell.
- `get_printable_cell_line`: Get a printable line of the custom cell.
- `get_rendered_line`: Get a rendered line of the custom cell.
- `parse_cell_text`: Parse the cell text and return a `Vector{String}` with the printable
    lines.
- `reset!`: Reset all the temporary fields. This function is not required.
"""
abstract type CustomTextCell end

"""
    struct RowPrintingState

Structure that hold the state of the row printing state machine.
"""
@kwdef mutable struct RowPrintingState
    state::Symbol = :top_horizontal_line
    i::Int = 0
    l::Int = 0
    continuation_line_drawn::Bool = false
    printed_lines::Int = 1
    i_pt::Int = 0
end

"""
    struct TextCrayons

Structure that holds all the crayons in the text backend.
"""
struct TextCrayons{
    Thc<:Union{Crayon, Vector{Crayon}},
    Tsc<:Union{Crayon, Vector{Crayon}}
}
    border_crayon::Crayon
    header_crayon::Thc
    omitted_cell_summary_crayon::Crayon
    row_label_crayon::Crayon
    row_label_header_crayon::Crayon
    row_number_header_crayon::Crayon
    subheader_crayon::Tsc
    text_crayon::Crayon
    title_crayon::Crayon
end

############################################################################################
#                                        Constants                                         #
############################################################################################

# Crayon used to reset all the styling.
const _default_crayon   = Crayon()
const _reset_crayon     = Crayon(reset = true)
const _reset_crayon_str = string(_reset_crayon)
