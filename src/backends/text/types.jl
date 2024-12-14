## Description #############################################################################
#
# Types and structures for the text back end.
#
############################################################################################

export CustomTextCell, TextTableBorders, TextTableFormat, TextTableStyle, TextHighlighter

############################################################################################
#                                     Custom Text Cell                                     #
############################################################################################

include("./CustomTextCell/CustomTextCell.jl")
using .CustomTextCell
export AbstractCustomTextCell

include("./CustomTextCell/AnsiTextCell.jl")
include("./CustomTextCell/UrlTextCell.jl")

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
    size::NTuple{2, Int} = (-1, -1)
    row::Int             = 1
    column::Int          = 0
    has_color::Bool      = false

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
const _TEXT__RESET               = crayon"reset"
const _TEXT__DEFAULT             = crayon"default"
const _TEXT__BOLD                = crayon"bold"
const _TEXT__DARK_GRAY           = crayon"fg:dark_gray"
const _TEXT__CYAN                = crayon"fg:cyan"
const _TEXT__BOLD_UNDERLINE      = crayon"bold underline"
const _TEXT__DARK_GRAY_UNDERLINE = crayon"fg:dark_gray underline"

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
    after the column labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data column. If the symbol `:none` is passed,
    no horizontal lines will be drawn after the data rows.
- `horizontal_line_before_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn before the row group label.
- `horizontal_line_after_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn after the row group label.
- `horizontal_line_after_data_rows::Bool`: If `true`, a horizontal line will be drawn
    after the data rows.
- `horizontal_line_after_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    after the summary rows.
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
    horizontal_line_before_row_group_label::Bool = true
    horizontal_line_after_row_group_label::Bool = true
    horizontal_line_after_data_rows::Bool = true
    horizontal_line_after_summary_rows::Bool = true

    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_line_after_data_columns::Bool = true
    vertical_line_after_continuation_column::Bool = true

    right_vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
    suppress_vertical_lines_at_column_labels::Bool = false

    # == Other Configurations ==============================================================

    ellipsis_line_skip::Int = 0
    new_line_at_end::Bool = true
end

"""
    struct TextTableStyle

Define the style of the tables printed with the text back end.

# Fields

- `title::Crayon`: Crayon with the style for the title.
- `subtitle::Crayon`: Crayon with the style for the subtitle.
- `row_number_label::Crayon`: Crayon with the style for the row number label.
- `row_number::Crayon`: Crayon with the style for the row numbers.
- `stubhead_label::Crayon`:  Crayon with the style for the stubhead label.
- `row_label::Crayon`: Crayon with the style for the row labels.
- `row_group_label::Crayon`: Crayon with the style for the row group label.
- `first_line_column_label::Crayon`: Crayon with the style for the first column label lines.
- `column_label::Crayon`: Crayon with the style for the rest of the column labels.
- `first_line_merged_column_label::Crayon`: Crayon with the style for the merged cells at
    the first column label line.
- `merged_column_label::Crayon`: Crayon with the style for the merged cells at the rest of
    the column labels.
- `summary_row_cell::Crayon`: Crayon with the style for the summary row cell.
- `summary_row_label::Crayon`: Crayon with the style for the summary row label.
- `footnote::Crayon`: Crayon with the style for the footnotes.
- `source_note::Crayon`: Crayon with the style for the source notes.
- `omitted_cell_summary::Crayon`: Crayon with the style for the omitted cell summary.
- `table_border::Crayon`: Crayon with the style for the table border.
"""
@kwdef struct TextTableStyle
    title::Crayon                          = _TEXT__BOLD
    subtitle::Crayon                       = _TEXT__DEFAULT
    row_number_label::Crayon               = _TEXT__BOLD
    row_number::Crayon                     = _TEXT__DEFAULT
    stubhead_label::Crayon                 = _TEXT__BOLD
    row_label::Crayon                      = _TEXT__BOLD
    row_group_label::Crayon                = _TEXT__BOLD
    first_line_column_label::Crayon        = _TEXT__BOLD
    column_label::Crayon                   = _TEXT__DARK_GRAY
    first_line_merged_column_label::Crayon = _TEXT__BOLD_UNDERLINE
    merged_column_label::Crayon            = _TEXT__DARK_GRAY_UNDERLINE
    summary_row_cell::Crayon               = _TEXT__DEFAULT
    summary_row_label::Crayon              = _TEXT__BOLD
    footnote::Crayon                       = _TEXT__DEFAULT
    source_note::Crayon                    = _TEXT__DARK_GRAY
    omitted_cell_summary::Crayon           = _TEXT__CYAN
    table_border::Crayon                   = _TEXT__DEFAULT
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

```julia
TextHighlighter(f::Function; kwargs...)
```

where it will construct a `Crayon` using the keywords in `kwargs` and apply it to the
highlighted cell,

```julia
TextHighlighter(f::Function, crayon::Crayon)
```

where it will apply the `crayon` to the highlighted cell, and

```julia
TextHighlighter(f::Function, fd::Function)
```

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
