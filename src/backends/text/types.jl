## Description #############################################################################
#
# Types and structures for the text back end
#
############################################################################################

export TextTableFormat

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
- `buf_line::IOBuffer`:  Buffer that stores the current line.
- `buf::IOBuffer`: Buffer that stores the entire output.
"""
@kwdef mutable struct Display
    size::Tuple{Int,Int}    = (-1, -1)
    row::Int                = 1
    column::Int             = 0
    has_color::Bool         = false

    # Buffer that stores the entire output.
    buf::IOBuffer = IOBuffer()
    # Buffer that stores the current line.
    buf_line::IOBuffer = IOBuffer()
end

############################################################################################
#                                       Table Format                                       #
############################################################################################

# Create some default decorations to reduce allocations.
const _TEXT__RESET = crayon"reset"
const _TEXT__DEFAULT = crayon"default"
const _TEXT__BOLD = crayon"bold"
const _TEXT__DRAK_GRAY = crayon"fg:dark_gray"
const _TEXT__CYAN = crayon"fg:cyan"

# Convert the reset crayon to string to reduce allocations.
const _TEXT__STRING_RESET = string(_TEXT__RESET)

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

    # == Configuration for the Horizontal and Vertical Lines ===============================

    horizontal_line_at_beginning::Bool = true
    horizontal_line_after_column_labels::Bool = true
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_before_summary_rows::Bool = true
    horizontal_line_at_end::Bool = true

    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
    vertical_line_at_end::Bool = true

    # == Decorations =======================================================================

    title_decoration::Crayon                = _TEXT__BOLD
    subtitle_decoration::Crayon             = _TEXT__DEFAULT
    row_number_label_decoration::Crayon     = _TEXT__BOLD
    row_number_decoration::Crayon           = _TEXT__DEFAULT
    stubhead_label_decoration::Crayon       = _TEXT__BOLD
    row_label_decoration::Crayon            = _TEXT__BOLD
    row_group_label_decoration::Crayon      = _TEXT__BOLD
    first_column_label_decoration::Crayon   = _TEXT__BOLD
    column_label_decoration::Crayon         = _TEXT__DRAK_GRAY
    summary_row_cell_decoration::Crayon     = _TEXT__BOLD
    summary_row_label_decoration::Crayon    = _TEXT__BOLD
    footnote_decoration::Crayon             = _TEXT__DEFAULT
    source_note_decoration::Crayon          = _TEXT__DEFAULT
    merged_cell_decoration::Crayon          = _TEXT__BOLD
    omitted_cell_summary_decoration::Crayon = _TEXT__CYAN

    # == Other Configurations ==============================================================

    ellipsis_line_skip::Integer = 0
    new_line_at_end::Bool = true
end
