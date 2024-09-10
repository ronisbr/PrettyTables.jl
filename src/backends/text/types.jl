## Description #############################################################################
#
# Types and structures for the text back end
#
############################################################################################

export TextTableBorders, TextTableFormat, TextHighlighter

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

"""
    struct TextTableBorders

Define the format of the borders in the tables printed with the text back end.

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
"""
@kwdef struct TextTableBorders
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
end

# Create some default decorations to reduce allocations.
const _TEXT__RESET = crayon"reset"
const _TEXT__DEFAULT = crayon"default"
const _TEXT__BOLD = crayon"bold"
const _TEXT__DARK_GRAY = crayon"fg:dark_gray"
const _TEXT__CYAN = crayon"fg:cyan"

# Convert the reset crayon to string to reduce allocations.
const _TEXT__STRING_RESET = string(_TEXT__RESET)

"""
    struct TextTableFormat

Define the format of the tables printed with the text back end.

# Fields

- `borders::TextTableBorders`: Format of the borders.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the colum labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data column. If the symbol `:none` is passed,
    no horizontal lines will be drawn after the data rows.
- `horizontal_line_before_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    before the summary rows.
- `horizontal_line_at_end::Bool`: If `true`, a horizontal line will be drawn at the end of
    the table.
- `right_vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will
    be drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data column. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.
- `title_decoration::Crayon`: Crayon with the decoration for the title.
- `subtitle_decoration::Crayon`: Crayon with the decoration for the subtitle.
- `row_number_label_decoration::Crayon`: Crayon with the decoration for the row number
    label.
- `row_number_decoration::Crayon`: Crayon with the decoration for the row numbers.
- `stubhead_label_decoration::Crayon`:  Crayon with the decoration for the stubhead label.
- `row_label_decoration::Crayon`: Crayon with the decoration for the row labels.
- `row_group_label_decoration::Crayon`: Crayon with the decoration for the row group label.
- `first_column_label_decoration::Crayon`: Crayon with the decoration for the first
    column labels.
- `column_label_decoration::Crayon`: Crayon with the decoration for the rest of the column
    labels.
- `summary_row_cell_decoration::Crayon`: Crayon with the decoration for the summary row
    cell.
- `summary_row_label_decoration::Crayon`: Crayon with the decoration for the summary row
    label.
- `footnote_decoration::Crayon`: Crayon with the decoration for the footnotes.
- `source_note_decoration::Crayon`: Crayon with the decoration for the source notes.
- `merged_cell_decoration::Crayon`: Crayon with the decoration for the merged cells.
- `omitted_cell_summary_decoration::Crayon`: Crayon with the decoration for the omitted
    cell summary.
- `ellipsis_line_skip::Integer`: Number of lines to skip when printing an ellipsis.
- `new_line_at_end::Bool`: If `true`, a new line will be added at the end of the table.
"""
@kwdef struct TextTableFormat
    # == Border and Lines ==================================================================

    borders::TextTableBorders = TextTableBorders()

    # == Configuration for the Horizontal and Vertical Lines ===============================

    horizontal_line_at_beginning::Bool = true
    horizontal_line_after_column_labels::Bool = true
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_before_summary_rows::Bool = true
    horizontal_line_at_end::Bool = true

    right_vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_line_after_data_columns::Bool = true
    vertical_line_after_continuation_column::Bool = true

    # == Decorations =======================================================================

    title_decoration::Crayon                = _TEXT__BOLD
    subtitle_decoration::Crayon             = _TEXT__DEFAULT
    row_number_label_decoration::Crayon     = _TEXT__BOLD
    row_number_decoration::Crayon           = _TEXT__DEFAULT
    stubhead_label_decoration::Crayon       = _TEXT__BOLD
    row_label_decoration::Crayon            = _TEXT__BOLD
    row_group_label_decoration::Crayon      = _TEXT__BOLD
    first_column_label_decoration::Crayon   = _TEXT__BOLD
    column_label_decoration::Crayon         = _TEXT__DARK_GRAY
    summary_row_cell_decoration::Crayon     = _TEXT__BOLD
    summary_row_label_decoration::Crayon    = _TEXT__BOLD
    footnote_decoration::Crayon             = _TEXT__DEFAULT
    source_note_decoration::Crayon          = _TEXT__DARK_GRAY
    merged_cell_decoration::Crayon          = _TEXT__BOLD
    omitted_cell_summary_decoration::Crayon = _TEXT__CYAN

    # == Other Configurations ==============================================================

    ellipsis_line_skip::Integer = 0
    new_line_at_end::Bool = true
end

############################################################################################
#                                     TextHighlighter                                      #
############################################################################################

"""
    struct TextHighlighter

Defines the default highlighter of a table when using the text backend.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` in which should return `true`
    if the element `(i, j)` in `data` must be highlighter, or `false` otherwise.
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
struct TextHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Crayon

    # == Constructors ======================================================================

    function TextHighlighter(f::Function, fd::Function)
        return new(f, fd, _TEXT__DEFAULT)
    end

    function TextHighlighter(f::Function, decoration::Crayon)
        return new(
            f,
            _text__default_highlighter_fd,
            decoration
        )
    end
end

_text__default_highlighter_fd(h::TextHighlighter, ::Any, ::Int, ::Int) = h._decoration
