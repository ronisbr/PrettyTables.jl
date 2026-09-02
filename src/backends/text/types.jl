## Description #############################################################################
#
# Types and structures for the text back end.
#
############################################################################################

export CustomTextCell, TextTableLine, TextTableBorders, TextTableFormat, TextTableStyle
export TextHighlighter

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

"""
    struct TextTableLine

Define the characters of a single horizontal line in the tables printed with the text back
end. Every field defaults to `nothing`, meaning that the corresponding character in the
field `borders` of [`TextTableFormat`](@ref) is used. Hence, this object sparsely overrides
the characters of a single line.

# Fields

- `up_right_corner::Union{Nothing, Char}`: Character in the up right corner.
- `up_left_corner::Union{Nothing, Char}`: Character in the up left corner.
- `bottom_left_corner::Union{Nothing, Char}`: Character in the bottom left corner.
- `bottom_right_corner::Union{Nothing, Char}`: Character in the bottom right corner.
- `up_intersection::Union{Nothing, Char}`: Character in the intersection of lines in the up
    part.
- `left_intersection::Union{Nothing, Char}`: Character in the intersection of lines in the
    left part.
- `right_intersection::Union{Nothing, Char}`: Character in the intersection of lines in the
    right part.
- `middle_intersection::Union{Nothing, Char}`: Character in the intersection of lines in
    the middle of the table.
- `bottom_intersection::Union{Nothing, Char}`: Character in the intersection of the lines
    in the bottom part.
- `row::Union{Nothing, Char}`: Character in the horizontal line.
"""
@kwdef struct TextTableLine
    up_right_corner::Union{Nothing, Char}     = nothing
    up_left_corner::Union{Nothing, Char}      = nothing
    bottom_left_corner::Union{Nothing, Char}  = nothing
    bottom_right_corner::Union{Nothing, Char} = nothing
    up_intersection::Union{Nothing, Char}     = nothing
    left_intersection::Union{Nothing, Char}   = nothing
    right_intersection::Union{Nothing, Char}  = nothing
    middle_intersection::Union{Nothing, Char} = nothing
    bottom_intersection::Union{Nothing, Char} = nothing
    row::Union{Nothing, Char}                 = nothing
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
- `top_line::Union{Nothing, TextTableLine}`: Characters of the top line.
- `header_line::Union{Nothing, TextTableLine}`: Characters of the lines at the column
    labels.
- `merged_header_cell_line::Union{Nothing, TextTableLine}`: Characters of the lines under
    the merged column labels.
- `middle_line::Union{Nothing, TextTableLine}`: Characters of the lines inside the table.
- `bottom_line::Union{Nothing, TextTableLine}`: Characters of the bottom line.
- `left_line::Union{Nothing, Char}`: Character of the vertical line at the left of the
    table.
- `center_line::Union{Nothing, Char}`: Character of the vertical lines inside the table.
- `right_line::Union{Nothing, Char}`: Character of the vertical line at the right of the
    table.

# Line Characters

The line character fields allow the user to customize the characters of each table line
independently. The horizontal line fields accept a [`TextTableLine`](@ref), whereas the
vertical line fields accept a `Char`. Every field, and every character inside a
[`TextTableLine`](@ref), defaults to `nothing`, meaning that the corresponding character
in `borders` is used. Hence, those fields sparsely override the characters in `borders` for
a single line.

The color of each line can be configured with the line faces of [`TextTableStyle`](@ref).
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

    # == Line Characters ===================================================================

    # NOTE: These fields must be the last ones so that the positional constructor with the
    # fields of v3.4.8 (see below) keeps working.
    top_line::Union{Nothing, TextTableLine}                = nothing
    header_line::Union{Nothing, TextTableLine}             = nothing
    merged_header_cell_line::Union{Nothing, TextTableLine} = nothing
    middle_line::Union{Nothing, TextTableLine}             = nothing
    bottom_line::Union{Nothing, TextTableLine}             = nothing
    left_line::Union{Nothing, Char}                        = nothing
    center_line::Union{Nothing, Char}                      = nothing
    right_line::Union{Nothing, Char}                       = nothing
end

# Positional constructor with the fields of v3.4.8, before the line character fields were
# added, so that the code written for the previous versions keeps working.
function TextTableFormat(
    borders,
    horizontal_line_at_beginning,
    horizontal_lines_at_column_labels,
    horizontal_line_at_merged_column_labels,
    horizontal_line_after_column_labels,
    horizontal_lines_at_data_rows,
    horizontal_line_before_row_group_label,
    horizontal_line_after_row_group_label,
    horizontal_line_after_data_rows,
    horizontal_line_before_summary_rows,
    horizontal_line_after_summary_rows,
    vertical_line_at_beginning,
    vertical_line_after_row_number_column,
    vertical_line_after_row_label_column,
    vertical_lines_at_data_columns,
    vertical_line_after_data_columns,
    vertical_line_after_continuation_column,
    suppress_vertical_lines_at_column_labels,
    ellipsis_line_skip,
)
    return TextTableFormat(
        borders,
        horizontal_line_at_beginning,
        horizontal_lines_at_column_labels,
        horizontal_line_at_merged_column_labels,
        horizontal_line_after_column_labels,
        horizontal_lines_at_data_rows,
        horizontal_line_before_row_group_label,
        horizontal_line_after_row_group_label,
        horizontal_line_after_data_rows,
        horizontal_line_before_summary_rows,
        horizontal_line_after_summary_rows,
        vertical_line_at_beginning,
        vertical_line_after_row_number_column,
        vertical_line_after_row_label_column,
        vertical_lines_at_data_columns,
        vertical_line_after_data_columns,
        vertical_line_after_continuation_column,
        suppress_vertical_lines_at_column_labels,
        ellipsis_line_skip,
        nothing,
        nothing,
        nothing,
        nothing,
        nothing,
        nothing,
        nothing,
        nothing,
    )
end

"""
    struct TextHorizontalLine

Characters and escape sequence used to draw a horizontal table line, resolved once per
printed table (see [`TextResolvedTableLines`](@ref)).

# Fields

- `chars::TextTableBorders`: Characters of the line. The field `column` is not used.
- `sgr::String`: Escape sequence of the line, or an empty string for no style.
"""
struct TextHorizontalLine
    chars::TextTableBorders
    sgr::String
end

"""
    struct TextVerticalLine

Character and escape sequence used to draw a vertical table line, resolved once per printed
table (see [`TextResolvedTableLines`](@ref)).

# Fields

- `char::Char`: Character of the line.
- `sgr::String`: Escape sequence of the line, or an empty string for no style.
"""
struct TextVerticalLine
    char::Char
    sgr::String
end

"""
    struct TextResolvedTableLines

Store the lines used to draw the table, resolved once per printed table from the line
characters in [`TextTableFormat`](@ref) and the line faces in [`TextTableStyle`](@ref).
Hence, the printing loop only reads characters and strings.

# Fields

- `top::TextHorizontalLine`: Top line.
- `header::TextHorizontalLine`: Lines at the column labels.
- `merged_header::TextHorizontalLine`: Lines under the merged column labels.
- `middle::TextHorizontalLine`: Lines inside the table.
- `bottom::TextHorizontalLine`: Bottom line.
- `left::TextVerticalLine`: Vertical line at the left of the table.
- `center::TextVerticalLine`: Vertical lines inside the table.
- `right::TextVerticalLine`: Vertical line at the right of the table.
"""
struct TextResolvedTableLines
    top::TextHorizontalLine
    header::TextHorizontalLine
    merged_header::TextHorizontalLine
    middle::TextHorizontalLine
    bottom::TextHorizontalLine
    left::TextVerticalLine
    center::TextVerticalLine
    right::TextVerticalLine
end

"""
    struct TextRenderedStyle

Escape sequences of every field of a [`TextTableStyle`](@ref), rendered once when the style
is created so that the printing loop only writes strings.

This structure is not parametric on purpose. The printing function receives the style
through a field with the abstract type `TextTableStyle`, and the concrete type of this object
allows the compiler to statically type every escape sequence used in the printing loop.
"""
struct TextRenderedStyle
    title::String
    subtitle::String
    row_number_label::String
    row_number::String
    stubhead_label::String
    row_label::String
    row_group_label::String
    first_line_column_label::Union{String, Vector{String}}
    column_label::Union{String, Vector{String}}
    first_line_merged_column_label::String
    merged_column_label::String
    summary_row_cell::String
    summary_row_label::String
    footnote::String
    source_note::String
    omitted_cell_summary::String
    table_border::String
    top_line::String
    header_line::String
    merged_header_cell_line::String
    middle_line::String
    bottom_line::String
    left_line::String
    center_line::String
    right_line::String
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
    _text__face_sgr(faces::Vector{Face}) -> Vector{String}

Return the escape sequence of every face in `faces`.
"""
_text__face_sgr(faces::Vector{Face}) = String[_text__face_sgr(f) for f in faces]

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
- `top_line::Union{Nothing, Face}`: Face with the style for the top line.
- `header_line::Union{Nothing, Face}`: Face with the style for the lines at the column
    labels.
- `merged_header_cell_line::Union{Nothing, Face}`: Face with the style for the lines under
    the merged column labels.
- `middle_line::Union{Nothing, Face}`: Face with the style for the lines inside the table.
- `bottom_line::Union{Nothing, Face}`: Face with the style for the bottom line.
- `left_line::Union{Nothing, Face}`: Face with the style for the vertical line at the left
    of the table.
- `center_line::Union{Nothing, Face}`: Face with the style for the vertical lines inside
    the table.
- `right_line::Union{Nothing, Face}`: Face with the style for the vertical line at the
    right of the table.
- `_rendered::TextRenderedStyle`: Private field with the escape sequences of every field,
    rendered when the style is created.

The line faces default to `nothing`, meaning that the corresponding line is rendered with
the face in `table_border`. When printing with the backend-agnostic [`TableFormat`](@ref),
the color of each line design is converted to the corresponding line face, unless the line
face is explicitly set, which has the highest precedence.

# Constructor

    TextTableStyle(; kwargs...)

Create a style in which each field can be passed as a keyword. Every keyword accepts a
`Face` or a `Crayon`, which is converted to the equivalent face. The keywords
`first_line_column_label` and `column_label` also accept a vector of faces or crayons.
"""
struct TextTableStyle{
    TFCL <: Union{Face, Vector{Face}},
    TCL <: Union{Face, Vector{Face}},
}
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
    top_line::Union{Nothing, Face}
    header_line::Union{Nothing, Face}
    merged_header_cell_line::Union{Nothing, Face}
    middle_line::Union{Nothing, Face}
    bottom_line::Union{Nothing, Face}
    left_line::Union{Nothing, Face}
    center_line::Union{Nothing, Face}
    right_line::Union{Nothing, Face}

    # == Private Fields ====================================================================

    _rendered::TextRenderedStyle
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
    top_line                       = nothing,
    header_line                    = nothing,
    merged_header_cell_line        = nothing,
    middle_line                    = nothing,
    bottom_line                    = nothing,
    left_line                      = nothing,
    center_line                    = nothing,
    right_line                     = nothing,
)
    return _text__build_table_style(
        title,
        subtitle,
        row_number_label,
        row_number,
        stubhead_label,
        row_label,
        row_group_label,
        first_line_column_label,
        column_label,
        first_line_merged_column_label,
        merged_column_label,
        summary_row_cell,
        summary_row_label,
        footnote,
        source_note,
        omitted_cell_summary,
        table_border,
        top_line,
        header_line,
        merged_header_cell_line,
        middle_line,
        bottom_line,
        left_line,
        center_line,
        right_line,
    )
end

"""
    TextTableStyle(style::TextTableStyle; kwargs...) -> TextTableStyle

Create a copy of `style` in which the fields passed as keywords in `kwargs` are replaced,
converting the crayons into faces and rendering the escape sequences again.
"""
function TextTableStyle(style::TextTableStyle; kwargs...)
    return _text__build_table_style(
        (get(kwargs, f, getfield(style, f)) for f in _TEXT__STYLE_FIELDS)...
    )
end

# Public fields of `TextTableStyle`, in the order of its keyword constructor.
const _TEXT__STYLE_FIELDS = fieldnames(TextTableStyle)[1:(end - 1)]

"""
    _text__build_table_style(args...) -> TextTableStyle

Build a `TextTableStyle` from the values passed to its keyword constructor, converting the
crayons into faces and rendering the escape sequences.

This function only forwards the arguments to `_text__build_table_style_core`, which
performs the work. The arguments of both are not specialized (also during inference) and
the functions are not inlined so that they are compiled once. Otherwise, each distinct set
of keywords passed to `TextTableStyle` would infer the conversions and the rendering again,
which is expensive.
"""
Base.@nospecializeinfer Base.@constprop :none @noinline function _text__build_table_style(
    @nospecialize(title),
    @nospecialize(subtitle),
    @nospecialize(row_number_label),
    @nospecialize(row_number),
    @nospecialize(stubhead_label),
    @nospecialize(row_label),
    @nospecialize(row_group_label),
    @nospecialize(first_line_column_label),
    @nospecialize(column_label),
    @nospecialize(first_line_merged_column_label),
    @nospecialize(merged_column_label),
    @nospecialize(summary_row_cell),
    @nospecialize(summary_row_label),
    @nospecialize(footnote),
    @nospecialize(source_note),
    @nospecialize(omitted_cell_summary),
    @nospecialize(table_border),
    @nospecialize(top_line),
    @nospecialize(header_line),
    @nospecialize(merged_header_cell_line),
    @nospecialize(middle_line),
    @nospecialize(bottom_line),
    @nospecialize(left_line),
    @nospecialize(center_line),
    @nospecialize(right_line),
)
    return _text__build_table_style_core(
        title,
        subtitle,
        row_number_label,
        row_number,
        stubhead_label,
        row_label,
        row_group_label,
        first_line_column_label,
        column_label,
        first_line_merged_column_label,
        merged_column_label,
        summary_row_cell,
        summary_row_label,
        footnote,
        source_note,
        omitted_cell_summary,
        table_border,
        top_line,
        header_line,
        merged_header_cell_line,
        middle_line,
        bottom_line,
        left_line,
        center_line,
        right_line,
    )
end

"""
    _text__build_table_style_core(args...) -> TextTableStyle

Convert the values passed to the keyword constructor of `TextTableStyle` and render the
escape sequences (see `_text__build_table_style`).
"""
Base.@nospecializeinfer Base.@constprop :none @noinline function _text__build_table_style_core(
    @nospecialize(title),
    @nospecialize(subtitle),
    @nospecialize(row_number_label),
    @nospecialize(row_number),
    @nospecialize(stubhead_label),
    @nospecialize(row_label),
    @nospecialize(row_group_label),
    @nospecialize(first_line_column_label),
    @nospecialize(column_label),
    @nospecialize(first_line_merged_column_label),
    @nospecialize(merged_column_label),
    @nospecialize(summary_row_cell),
    @nospecialize(summary_row_label),
    @nospecialize(footnote),
    @nospecialize(source_note),
    @nospecialize(omitted_cell_summary),
    @nospecialize(table_border),
    @nospecialize(top_line),
    @nospecialize(header_line),
    @nospecialize(merged_header_cell_line),
    @nospecialize(middle_line),
    @nospecialize(bottom_line),
    @nospecialize(left_line),
    @nospecialize(center_line),
    @nospecialize(right_line),
)
    title                          = _text__to_face(title)
    subtitle                       = _text__to_face(subtitle)
    row_number_label               = _text__to_face(row_number_label)
    row_number                     = _text__to_face(row_number)
    stubhead_label                 = _text__to_face(stubhead_label)
    row_label                      = _text__to_face(row_label)
    row_group_label                = _text__to_face(row_group_label)
    first_line_column_label        = _text__to_faces(first_line_column_label)
    column_label                   = _text__to_faces(column_label)
    first_line_merged_column_label = _text__to_face(first_line_merged_column_label)
    merged_column_label            = _text__to_face(merged_column_label)
    summary_row_cell               = _text__to_face(summary_row_cell)
    summary_row_label              = _text__to_face(summary_row_label)
    footnote                       = _text__to_face(footnote)
    source_note                    = _text__to_face(source_note)
    omitted_cell_summary           = _text__to_face(omitted_cell_summary)
    table_border                   = _text__to_face(table_border)
    top_line                       = _text__to_optional_face(top_line)
    header_line                    = _text__to_optional_face(header_line)
    merged_header_cell_line        = _text__to_optional_face(merged_header_cell_line)
    middle_line                    = _text__to_optional_face(middle_line)
    bottom_line                    = _text__to_optional_face(bottom_line)
    left_line                      = _text__to_optional_face(left_line)
    center_line                    = _text__to_optional_face(center_line)
    right_line                     = _text__to_optional_face(right_line)

    rendered = TextRenderedStyle(
        _text__face_sgr(title),
        _text__face_sgr(subtitle),
        _text__face_sgr(row_number_label),
        _text__face_sgr(row_number),
        _text__face_sgr(stubhead_label),
        _text__face_sgr(row_label),
        _text__face_sgr(row_group_label),
        _text__face_sgr(first_line_column_label),
        _text__face_sgr(column_label),
        _text__face_sgr(first_line_merged_column_label),
        _text__face_sgr(merged_column_label),
        _text__face_sgr(summary_row_cell),
        _text__face_sgr(summary_row_label),
        _text__face_sgr(footnote),
        _text__face_sgr(source_note),
        _text__face_sgr(omitted_cell_summary),
        _text__face_sgr(table_border),
        _text__optional_face_sgr(top_line),
        _text__optional_face_sgr(header_line),
        _text__optional_face_sgr(merged_header_cell_line),
        _text__optional_face_sgr(middle_line),
        _text__optional_face_sgr(bottom_line),
        _text__optional_face_sgr(left_line),
        _text__optional_face_sgr(center_line),
        _text__optional_face_sgr(right_line),
    )

    return TextTableStyle(
        title,
        subtitle,
        row_number_label,
        row_number,
        stubhead_label,
        row_label,
        row_group_label,
        first_line_column_label,
        column_label,
        first_line_merged_column_label,
        merged_column_label,
        summary_row_cell,
        summary_row_label,
        footnote,
        source_note,
        omitted_cell_summary,
        table_border,
        top_line,
        header_line,
        merged_header_cell_line,
        middle_line,
        bottom_line,
        left_line,
        center_line,
        right_line,
        rendered,
    )
end

"""
    _text__to_face(decoration::Union{Face, Crayon}) -> Face

Convert the `decoration` passed to `TextTableStyle`, a face or a crayon, into a face.
"""
_text__to_face(face::Face)     = face
_text__to_face(crayon::Crayon) = _face_from_crayon(crayon)

"""
    _text__to_optional_face(decoration::Union{Nothing, Face, Crayon}) -> Union{Nothing, Face}

Convert an optional `decoration` passed to `TextTableStyle` into a face, keeping `nothing`
unchanged.
"""
_text__to_optional_face(::Nothing) = nothing
_text__to_optional_face(decoration) = _text__to_face(decoration)

"""
    _text__optional_face_sgr(face::Union{Nothing, Face}) -> String

Return the escape sequence of an optional `face`, or an empty string if `face` is `nothing`.
"""
_text__optional_face_sgr(::Nothing) = ""
_text__optional_face_sgr(face::Face) = _text__face_sgr(face)

"""
    _text__to_faces(decorations::Union{Face, Crayon, AbstractVector}) -> Union{Face, Vector{Face}}

Convert the `decorations` passed to `TextTableStyle`, a face, a crayon, or a vector of them,
into a face or a vector of faces.
"""
_text__to_faces(decoration::Union{Face, Crayon}) = _text__to_face(decoration)
_text__to_faces(faces::Vector{Face})             = faces
_text__to_faces(decorations::AbstractVector)     = Face[_text__to_face(d) for d in decorations]

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
