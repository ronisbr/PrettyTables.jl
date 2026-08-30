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
end

# Create some default decorations to reduce allocations.
const _TEXT__BOLD                = Face(; weight = :bold)
const _TEXT__BOLD_UNDERLINE      = Face(; weight = :bold, underline = true)
const _TEXT__CYAN                = Face(; foreground = :cyan)
const _TEXT__DARK_GRAY           = Face(; foreground = :bright_black)
const _TEXT__DARK_GRAY_UNDERLINE = Face(; foreground = :bright_black, underline = true)
const _TEXT__DEFAULT             = Face()

# The reset escape sequence.
const _TEXT__STRING_RESET = "\e[0m"

"""
    struct TextTableFormat

Define the format of the tables printed with the text back end.

# Fields

- `borders::TextTableBorders`: Format of the borders.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_lines_at_column_labels::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each column label row index listed in this vector. If the symbol `:all` is
    passed, a horizontal line will be drawn after every column label. If the symbol `:none`
    is passed, no horizontal lines will be drawn.
- `horizontal_line_at_merged_column_labels::Bool`: If `true`, a horizontal line will be
    drawn at the merged column labels. Notice that the horizontal line drawn using the
    option `horizontal_lines_at_column_labels` has precedence over this one.
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the column labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data row. If the symbol `:none` is passed,
    no horizontal lines will be drawn.
- `horizontal_line_before_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn before the row group label.
- `horizontal_line_after_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn after the row group label.
- `horizontal_line_after_data_rows::Bool`: If `true`, a horizontal line will be drawn
    after the data rows.
- `horizontal_line_before_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    before the summary rows. Notice that this line is the same as the one drawn if
    `horizontal_line_after_data_rows` is `true`. However, in this case, the line is omitted
    if there are no summary rows.
- `horizontal_line_after_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    after the summary rows.
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will be
    drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data column. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.
- `suppress_vertical_lines_at_column_labels::Bool`: If `true`, the vertical lines inside
    the column label rows will be suppressed.
- `ellipsis_line_skip::Int`: Number of lines to skip when printing an ellipsis.
"""
@kwdef struct TextTableFormat
    # == Border and Lines ==================================================================

    borders::TextTableBorders = TextTableBorders()

    # == Configuration for the Horizontal and Vertical Lines ===============================

    horizontal_line_at_beginning::Bool = true
    horizontal_lines_at_column_labels::Union{Symbol, Vector{Int}} = :none
    horizontal_line_at_merged_column_labels::Bool = false
    horizontal_line_after_column_labels::Bool = true
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_before_row_group_label::Bool = true
    horizontal_line_after_row_group_label::Bool = true
    horizontal_line_after_data_rows::Bool = true
    horizontal_line_before_summary_rows::Bool = true
    horizontal_line_after_summary_rows::Bool = true

    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
    vertical_line_after_data_columns::Bool = true
    vertical_line_after_continuation_column::Bool = true

    suppress_vertical_lines_at_column_labels::Bool = false

    # == Other Configurations ==============================================================

    ellipsis_line_skip::Int = 0
end

"""
    struct TextTableStyle

Define the style of the tables printed with the text back end.

# Fields

- `title::Face`: Face with the style for the title.
- `subtitle::Face`: Face with the style for the subtitle.
- `row_number_label::Face`: Face with the style for the row number label.
- `row_number::Face`: Face with the style for the row numbers.
- `stubhead_label::Face`:  Face with the style for the stubhead label.
- `row_label::Face`: Face with the style for the row labels.
- `row_group_label::Face`: Face with the style for the row group label.
- `first_line_column_label::Union{Face, Vector{Face}}`: Face or faces with the style for
    the first column label lines. If a vector of faces is passed, it must have the same
    length as the number of columns in the table.
- `column_label::Union{Face, Vector{Face}}`: Face or faces with the style for the rest of
    the column labels. If a vector of faces is passed, it must have the same length as the
    number of columns in the table.
- `first_line_merged_column_label::Face`: Face with the style for the merged cells at the
    first column label line.
- `merged_column_label::Face`: Face with the style for the merged cells at the rest of the
    column labels.
- `summary_row_cell::Face`: Face with the style for the summary row cell.
- `summary_row_label::Face`: Face with the style for the summary row label.
- `footnote::Face`: Face with the style for the footnotes.
- `source_note::Face`: Face with the style for the source notes.
- `omitted_cell_summary::Face`: Face with the style for the omitted cell summary.
- `table_border::Face`: Face with the style for the table border.

# Constructor

    TextTableStyle(; kwargs...)

Create a style in which each field can be passed as a keyword. Every keyword accepts a
`Face` or a `Crayon`, which is converted to the equivalent face. The keywords
`first_line_column_label` and `column_label` also accept a vector of faces or crayons.
"""
struct TextTableStyle{TFCL <: Union{Face, Vector{Face}}, TCL <: Union{Face, Vector{Face}}}
    title::Face
    subtitle::Face
    row_number_label::Face
    row_number::Face
    stubhead_label::Face
    row_label::Face
    row_group_label::Face
    first_line_column_label::TFCL
    column_label::TCL
    first_line_merged_column_label::Face
    merged_column_label::Face
    summary_row_cell::Face
    summary_row_label::Face
    footnote::Face
    source_note::Face
    omitted_cell_summary::Face
    table_border::Face
end

function TextTableStyle(;
    title                          = _TEXT__BOLD,
    subtitle                       = _TEXT__DEFAULT,
    row_number_label               = _TEXT__BOLD,
    row_number                     = _TEXT__DEFAULT,
    stubhead_label                 = _TEXT__BOLD,
    row_label                      = _TEXT__BOLD,
    row_group_label                = _TEXT__BOLD,
    first_line_column_label        = _TEXT__BOLD,
    column_label                   = _TEXT__DARK_GRAY,
    first_line_merged_column_label = _TEXT__BOLD_UNDERLINE,
    merged_column_label            = _TEXT__DARK_GRAY_UNDERLINE,
    summary_row_cell               = _TEXT__DEFAULT,
    summary_row_label              = _TEXT__BOLD,
    footnote                       = _TEXT__DEFAULT,
    source_note                    = _TEXT__DARK_GRAY,
    omitted_cell_summary           = _TEXT__CYAN,
    table_border                   = _TEXT__DEFAULT,
)
    return TextTableStyle(
        _text__to_face(title),
        _text__to_face(subtitle),
        _text__to_face(row_number_label),
        _text__to_face(row_number),
        _text__to_face(stubhead_label),
        _text__to_face(row_label),
        _text__to_face(row_group_label),
        _text__to_faces(first_line_column_label),
        _text__to_faces(column_label),
        _text__to_face(first_line_merged_column_label),
        _text__to_face(merged_column_label),
        _text__to_face(summary_row_cell),
        _text__to_face(summary_row_label),
        _text__to_face(footnote),
        _text__to_face(source_note),
        _text__to_face(omitted_cell_summary),
        _text__to_face(table_border),
    )
end

# Convert a decoration passed to `TextTableStyle` into a face.
_text__to_face(face::Face)     = face
_text__to_face(crayon::Crayon) = _face_from_crayon(crayon)

# Convert a decoration, or a vector of decorations, passed to `TextTableStyle` into faces.
_text__to_faces(decoration::Union{Face, Crayon}) = _text__to_face(decoration)
_text__to_faces(faces::Vector{Face})             = faces
_text__to_faces(decorations::AbstractVector)     = Face[_text__to_face(d) for d in decorations]

"""
    struct _TextRenderedStyle

Escape sequences of every field of a [`TextTableStyle`](@ref), rendered once per table so
that the per-cell loop only writes strings. All the fields are empty if the display has no
color support.
"""
struct _TextRenderedStyle{
    TFCL <: Union{String, Vector{String}}, TCL <: Union{String, Vector{String}}
}
    title::String
    subtitle::String
    row_number_label::String
    row_number::String
    stubhead_label::String
    row_label::String
    row_group_label::String
    first_line_column_label::TFCL
    column_label::TCL
    first_line_merged_column_label::String
    merged_column_label::String
    summary_row_cell::String
    summary_row_label::String
    footnote::String
    source_note::String
    omitted_cell_summary::String
    table_border::String
end

function _TextRenderedStyle(style::TextTableStyle, has_color::Bool)
    sgr(face::Face)          = has_color ? _text__face_sgr(face) : ""
    sgr(faces::Vector{Face}) = String[sgr(f) for f in faces]

    return _TextRenderedStyle(
        sgr(style.title),
        sgr(style.subtitle),
        sgr(style.row_number_label),
        sgr(style.row_number),
        sgr(style.stubhead_label),
        sgr(style.row_label),
        sgr(style.row_group_label),
        sgr(style.first_line_column_label),
        sgr(style.column_label),
        sgr(style.first_line_merged_column_label),
        sgr(style.merged_column_label),
        sgr(style.summary_row_cell),
        sgr(style.summary_row_label),
        sgr(style.footnote),
        sgr(style.source_note),
        sgr(style.omitted_cell_summary),
        sgr(style.table_border),
    )
end

"""
    _text__face_sgr(face::Face) -> String

Return the escape sequence that shows text with the attributes of `face`, or an empty string
if `face` sets no attribute. The attributes that `face` turns off and the default colors of
the terminal are omitted because every styled segment of the table starts after a reset.
"""
function _text__face_sgr(face::Face)
    # The decoration is built with a reset so that the attributes turned off are omitted.
    # Afterward, the reset is removed. Otherwise, `Face(; weight = :bold)` would be rendered
    # as `\\e[22;1m` instead of `\\e[1m`.
    return String(Decoration(Decoration(face); reset = false))
end

"""
    _text__decoration_sgr(decoration::Union{Face, Crayon}) -> String

Return the escape sequence of a `decoration` returned by a highlighter, which can be a `Face`
or a `Crayon`.
"""
_text__decoration_sgr(face::Face)     = _text__face_sgr(face)
_text__decoration_sgr(crayon::Crayon) = _text__face_sgr(_face_from_crayon(crayon))

function _text__decoration_sgr(decoration)
    throw(
        ArgumentError(
            "The decoration of a text highlighter must be a `Face` or a `Crayon`, not a `$(typeof(decoration))`."
        )
    )
end

############################################################################################
#                                     TextHighlighter                                      #
############################################################################################

"""
    struct TextHighlighter <: AbstractHighlighter

Defines the default highlighter of a table when using the text backend.

# Fields

- `f::Function`: Function with the signature `f(data, i, j)` which should return `true`
    if the element `(i, j)` in `data` must be highlighted, or `false` otherwise.
- `fd::Function`: Function with the signature `fd(h, data, i, j)` in which `h` is the
    highlighter. This function must return the `Face` (or `Crayon`) to be applied to the
    cell that must be highlighted.
- `_decoration::Face`: The `Face` to be applied to the highlighted cell if the default `fd`
    is used.
- `_sgr::String`: The escape sequence of `_decoration`, rendered at construction.

# Remarks

This structure can be constructed using the following helpers:

```julia
TextHighlighter(f::Function; kwargs...)
```

where it will construct a `Face` using the keywords in `kwargs` and apply it to the
highlighted cell. The keywords can be the ones of `Face` (`weight`, `slant`, `foreground`,
`background`, `underline`, `strikethrough`, `inverse`, ...) or the ones of `Crayon` (`bold`,
`faint`, `italics`, `negative`, `foreground`, `background`, `underline`, `strikethrough`),
which are translated to the equivalent face attributes,

```julia
TextHighlighter(f::Function, face::Face)
TextHighlighter(f::Function, crayon::Crayon)
```

where it will apply the `face` (or the `crayon`, converted to a face) to the highlighted
cell, and

```julia
TextHighlighter(f::Function, fd::Function)
```

where it will apply the `Face` (or `Crayon`) returned by the function `fd` to the
highlighted cell.
"""
struct TextHighlighter <: AbstractHighlighter
    f::Function
    fd::Function

    # == Private Fields ====================================================================

    _decoration::Face
    _sgr::String

    # == Constructors ======================================================================

    function TextHighlighter(f::Function, fd::Function)
        return new(f, fd, _TEXT__DEFAULT, "")
    end

    function TextHighlighter(f::Function, face::Face)
        return new(f, _text__default_highlighter_fd, face, _text__face_sgr(face))
    end

    function TextHighlighter(f::Function, crayon::Crayon)
        return TextHighlighter(f, _face_from_crayon(crayon))
    end

    function TextHighlighter(f::Function; kwargs...)
        return TextHighlighter(f, _face_from_kwargs(; kwargs...))
    end
end

_text__default_highlighter_fd(h::TextHighlighter, ::Any, ::Int, ::Int) = h._decoration

"""
    _text__highlighter_sgr(h::AbstractHighlighter, data, i::Int, j::Int) -> String

Return the escape sequence of the highlighter `h` for the cell `(i, j)` of `data`.
"""
function _text__highlighter_sgr(h::TextHighlighter, data, i::Int, j::Int)
    # The default `fd` returns the stored face, whose escape sequence is already rendered.
    (h.fd === _text__default_highlighter_fd) && return h._sgr
    return _text__decoration_sgr(h.fd(h, data, i, j))
end

function _text__highlighter_sgr(h::AbstractHighlighter, ::Any, ::Int, ::Int)
    throw(
        ArgumentError(
            "The text back end does not support highlighters of type `$(typeof(h))`."
        )
    )
end
