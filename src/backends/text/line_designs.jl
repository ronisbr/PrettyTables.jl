## Description #############################################################################
#
# Text Back End: Map the backend-agnostic line designs to box-drawing characters and resolve
#   the characters and escape sequences used to draw each table line.
#
############################################################################################

############################################################################################
#                                        Constants                                         #
############################################################################################

# Junction characters between a horizontal and a vertical line, indexed by
# `3 * (h - 1) + v`, where `h` and `v` are the classes of the horizontal and vertical line
# designs (1 = light, 2 = heavy, 3 = double). `'\0'` indicates that Unicode does not provide
# the required character, meaning that we must fall back to the character in
# `TextTableBorders`.

const _TEXT__UP_LEFT_CORNERS      = ('┌', '┎', '╓', '┍', '┏', '\0', '╒', '\0', '╔')
const _TEXT__UP_RIGHT_CORNERS     = ('┐', '┒', '╖', '┑', '┓', '\0', '╕', '\0', '╗')
const _TEXT__BOTTOM_LEFT_CORNERS  = ('└', '┖', '╙', '┕', '┗', '\0', '╘', '\0', '╚')
const _TEXT__BOTTOM_RIGHT_CORNERS = ('┘', '┚', '╜', '┙', '┛', '\0', '╛', '\0', '╝')
const _TEXT__UP_INTERSECTIONS     = ('┬', '┰', '╥', '┯', '┳', '\0', '╤', '\0', '╦')
const _TEXT__LEFT_INTERSECTIONS   = ('├', '┠', '╟', '┝', '┣', '\0', '╞', '\0', '╠')
const _TEXT__RIGHT_INTERSECTIONS  = ('┤', '┨', '╢', '┥', '┫', '\0', '╡', '\0', '╣')
const _TEXT__MIDDLE_INTERSECTIONS = ('┼', '╂', '╫', '┿', '╋', '\0', '╪', '\0', '╬')
const _TEXT__BOTTOM_INTERSECTIONS = ('┴', '┸', '╨', '┷', '┻', '\0', '╧', '\0', '╩')

# Object used when merging the characters of a line without customizations.
const _TEXT__EMPTY_TABLE_LINE = TextTableLine()

############################################################################################
#                Conversion of the Backend-Agnostic Line Designs (LineStyle)               #
############################################################################################

"""
    _text__line_design(design::Union{Nothing, LineStyle}) -> Union{Nothing, LineStyle}

Normalize the line `design`, converting a [`LineStyle`](@ref) with every field set to
`nothing` into `nothing`.
"""
_text__line_design(::Nothing) = nothing
_text__line_design(design::LineStyle) = _line_style_is_empty(design) ? nothing : design

"""
    _text__line_class(design::LineStyle) -> Int

Return the class of the line `design` used to obtain the junction characters: 1 for light
lines, 2 for heavy lines, and 3 for double lines.
"""
function _text__line_class(design::LineStyle)
    (design.style == :double) && return 3
    (design.width ∈ (:medium, :thick)) && return 2
    return 1
end

"""
    _text__horizontal_line_char(design::LineStyle) -> Char

Return the character used to draw a horizontal line with `design`.
"""
function _text__horizontal_line_char(design::LineStyle)
    c = _text__line_class(design)
    (c == 3) && return '═'
    (design.style == :dashed) && return (c == 2) ? '╍' : '╌'
    (design.style == :dotted) && return (c == 2) ? '┉' : '┈'
    return (c == 2) ? '━' : '─'
end

"""
    _text__vertical_line_char(design::LineStyle) -> Char

Return the character used to draw a vertical line with `design`.
"""
function _text__vertical_line_char(design::LineStyle)
    c = _text__line_class(design)
    (c == 3) && return '║'
    (design.style == :dashed) && return (c == 2) ? '┇' : '┆'
    (design.style == :dotted) && return (c == 2) ? '┋' : '┊'
    return (c == 2) ? '┃' : '│'
end

"""
    _text__junction_char(
        horizontal_design::Union{Nothing, LineStyle},
        vertical_design::Union{Nothing, LineStyle},
        table::NTuple{9, Char}
    ) -> Union{Nothing, Char}

Return the junction character between a horizontal line with `horizontal_design` and a
vertical line with `vertical_design`, obtained from the lookup `table`. If both designs are
`nothing`, or if Unicode does not provide the required character, the function returns
`nothing`, meaning that the character in `TextTableBorders` must be used. An unset design
is treated as a light line.
"""
Base.@nospecializeinfer function _text__junction_char(
    @nospecialize(horizontal_design::Union{Nothing, LineStyle}),
    @nospecialize(vertical_design::Union{Nothing, LineStyle}),
    table::NTuple{9, Char}
)
    (isnothing(horizontal_design) && isnothing(vertical_design)) && return nothing
    h = isnothing(horizontal_design) ? 1 : _text__line_class(horizontal_design)
    v = isnothing(vertical_design)   ? 1 : _text__line_class(vertical_design)
    c = table[3 * (h - 1) + v]
    return (c == '\0') ? nothing : c
end

"""
    _text__horizontal_table_line(
        design::Union{Nothing, LineStyle},
        left_design::Union{Nothing, LineStyle},
        center_design::Union{Nothing, LineStyle},
        right_design::Union{Nothing, LineStyle}
    ) -> Union{Nothing, TextTableLine}

Convert the [`LineStyle`](@ref) `design` of a horizontal line into a
[`TextTableLine`](@ref), taking the designs of the left, center, and right vertical lines
into account to obtain the junction characters. The function returns `nothing` if no design
modifies the horizontal line.

The arguments are not specialized. Otherwise, each combination of set and unset designs
would compile this function again.
"""
Base.@nospecializeinfer function _text__horizontal_table_line(
    @nospecialize(design::Union{Nothing, LineStyle}),
    @nospecialize(left_design::Union{Nothing, LineStyle}),
    @nospecialize(center_design::Union{Nothing, LineStyle}),
    @nospecialize(right_design::Union{Nothing, LineStyle})
)
    if (
        isnothing(design) && isnothing(left_design) && isnothing(center_design) &&
        isnothing(right_design)
    )
        return nothing
    end

    return TextTableLine(;
        up_left_corner      = _text__junction_char(
            design, left_design, _TEXT__UP_LEFT_CORNERS
        ),
        up_right_corner     = _text__junction_char(
            design, right_design, _TEXT__UP_RIGHT_CORNERS
        ),
        bottom_left_corner  = _text__junction_char(
            design, left_design, _TEXT__BOTTOM_LEFT_CORNERS
        ),
        bottom_right_corner = _text__junction_char(
            design, right_design, _TEXT__BOTTOM_RIGHT_CORNERS
        ),
        up_intersection     = _text__junction_char(
            design, center_design, _TEXT__UP_INTERSECTIONS
        ),
        left_intersection   = _text__junction_char(
            design, left_design, _TEXT__LEFT_INTERSECTIONS
        ),
        right_intersection  = _text__junction_char(
            design, right_design, _TEXT__RIGHT_INTERSECTIONS
        ),
        middle_intersection = _text__junction_char(
            design, center_design, _TEXT__MIDDLE_INTERSECTIONS
        ),
        bottom_intersection = _text__junction_char(
            design, center_design, _TEXT__BOTTOM_INTERSECTIONS
        ),
        row                 = isnothing(design) ?
            nothing : _text__horizontal_line_char(design),
    )
end

"""
    _text__line_style_face(design::Union{Nothing, LineStyle}) -> Union{Nothing, Face}

Return the face with the color of the line `design`, or `nothing` if the design does not
set a color.
"""
_text__line_style_face(::Nothing) = nothing

function _text__line_style_face(design::LineStyle)
    isnothing(design.color) && return nothing
    return Face(; foreground = design.color)
end

############################################################################################
#                                Resolution of Table Lines                                 #
############################################################################################

"""
    _text__line_char(user::Union{Nothing, Char}, default::Char) -> Char

Return `default` if `user` is `nothing`, and `user` otherwise.
"""
_text__line_char(user::Union{Nothing, Char}, default::Char) =
    isnothing(user) ? default : user

"""
    _text__merge_table_line(
        line::Union{Nothing, TextTableLine},
        borders::TextTableBorders,
        center_char::Char
    ) -> TextTableBorders

Merge the characters of `line` over the ones of `borders`, returning the character set used
to draw a horizontal line. `center_char` is the resolved character of the center vertical
line, stored in the field `column`.
"""
function _text__merge_table_line(
    line::Union{Nothing, TextTableLine},
    borders::TextTableBorders,
    center_char::Char
)
    if isnothing(line)
        (center_char == borders.column) && return borders
        line = _TEXT__EMPTY_TABLE_LINE
    end

    return TextTableBorders(;
        up_right_corner     = _text__line_char(
            line.up_right_corner, borders.up_right_corner
        ),
        up_left_corner      = _text__line_char(line.up_left_corner, borders.up_left_corner),
        bottom_left_corner  = _text__line_char(
            line.bottom_left_corner, borders.bottom_left_corner
        ),
        bottom_right_corner = _text__line_char(
            line.bottom_right_corner, borders.bottom_right_corner
        ),
        up_intersection     = _text__line_char(
            line.up_intersection, borders.up_intersection
        ),
        left_intersection   = _text__line_char(
            line.left_intersection, borders.left_intersection
        ),
        right_intersection  = _text__line_char(
            line.right_intersection, borders.right_intersection
        ),
        middle_intersection = _text__line_char(
            line.middle_intersection, borders.middle_intersection
        ),
        bottom_intersection = _text__line_char(
            line.bottom_intersection, borders.bottom_intersection
        ),
        column              = center_char,
        row                 = _text__line_char(line.row, borders.row),
    )
end

"""
    _text__line_sgr(
        face::Union{Nothing, Face},
        rendered_sgr::String,
        table_border_sgr::String
    ) -> String

Return the escape sequence used to draw a line: the escape sequence `rendered_sgr` of the
line `face` in [`TextTableStyle`](@ref) if it is set, or the escape sequence
`table_border_sgr` of the field `table_border` in [`TextTableStyle`](@ref) otherwise.
"""
function _text__line_sgr(
    face::Union{Nothing, Face},
    rendered_sgr::String,
    table_border_sgr::String
)
    return isnothing(face) ? table_border_sgr : rendered_sgr
end

"""
    _text__resolve_table_lines(tf::TextTableFormat, style::TextTableStyle) -> TextResolvedTableLines

Resolve the characters and escape sequences used to draw each table line from the line
characters in `tf` and the line faces in `style`. This function is called once per printed
table. If no line character or line face is set, every resolved character set is the object
in the field `borders` of `tf` and every escape sequence is the one rendered for the field
`table_border` of `style`, reproducing the default behavior without any transformation.
"""
function _text__resolve_table_lines(tf::TextTableFormat, style::TextTableStyle)
    borders = tf.borders
    rstyle  = style._rendered

    # If no line character or line face is set, we can reuse the characters in `borders`
    # and the escape sequence of `table_border` for every line, skipping all the resolution.
    no_line_chars =
        isnothing(tf.top_line) && isnothing(tf.header_line) &&
        isnothing(tf.merged_header_cell_line) && isnothing(tf.middle_line) &&
        isnothing(tf.bottom_line) && isnothing(tf.left_line) &&
        isnothing(tf.center_line) && isnothing(tf.right_line)

    no_line_faces =
        isnothing(style.top_line) && isnothing(style.header_line) &&
        isnothing(style.merged_header_cell_line) && isnothing(style.middle_line) &&
        isnothing(style.bottom_line) && isnothing(style.left_line) &&
        isnothing(style.center_line) && isnothing(style.right_line)

    if no_line_chars && no_line_faces
        tb_sgr = rstyle.table_border

        return TextResolvedTableLines(
            borders,
            borders,
            borders,
            borders,
            borders,
            tb_sgr,
            tb_sgr,
            tb_sgr,
            tb_sgr,
            tb_sgr,
            borders.column,
            borders.column,
            borders.column,
            tb_sgr,
            tb_sgr,
            tb_sgr,
        )
    end

    center_char = _text__line_char(tf.center_line, borders.column)

    return TextResolvedTableLines(
        _text__merge_table_line(tf.top_line, borders, center_char),
        _text__merge_table_line(tf.header_line, borders, center_char),
        _text__merge_table_line(tf.merged_header_cell_line, borders, center_char),
        _text__merge_table_line(tf.middle_line, borders, center_char),
        _text__merge_table_line(tf.bottom_line, borders, center_char),
        _text__line_sgr(style.top_line, rstyle.top_line, rstyle.table_border),
        _text__line_sgr(style.header_line, rstyle.header_line, rstyle.table_border),
        _text__line_sgr(
            style.merged_header_cell_line,
            rstyle.merged_header_cell_line,
            rstyle.table_border
        ),
        _text__line_sgr(style.middle_line, rstyle.middle_line, rstyle.table_border),
        _text__line_sgr(style.bottom_line, rstyle.bottom_line, rstyle.table_border),
        _text__line_char(tf.left_line, borders.column),
        center_char,
        _text__line_char(tf.right_line, borders.column),
        _text__line_sgr(style.left_line, rstyle.left_line, rstyle.table_border),
        _text__line_sgr(style.center_line, rstyle.center_line, rstyle.table_border),
        _text__line_sgr(style.right_line, rstyle.right_line, rstyle.table_border),
    )
end
