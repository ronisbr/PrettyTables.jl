## Description #############################################################################
#
# Text Back End: Conversion of the backend-agnostic table format and style.
#
############################################################################################

"""
    _text__table_style(style::Union{TableStyle, TextTableStyle}) -> TextTableStyle

Convert `style` to a `TextTableStyle`. A native `TextTableStyle` is returned unchanged,
whereas the fields of a backend-agnostic [`TableStyle`](@ref) override the ones of the
default text table style.
"""
_text__table_style(style::TextTableStyle) = style
_text__table_style(style::TableStyle) = TextTableStyle(; _table_style_kwargs(style)...)

"""
    _text__table_format(table_format::Union{TableFormat, TextTableFormat}) -> TextTableFormat

Convert `table_format` to a `TextTableFormat`. A native `TextTableFormat` is returned
unchanged, whereas the line presence and line design fields of a backend-agnostic
[`TableFormat`](@ref) override the ones of the default text table format.

Each [`LineStyle`](@ref) is mapped to Unicode box-drawing characters as follows. The styles
`:solid`, `:dashed`, and `:dotted` are drawn with the light characters (`─`, `╌`, and `┈`)
if the width is `:thin`, or with the heavy characters (`━`, `╍`, and `┉`) if the width is
`:medium` or `:thick`. The style `:double` is always drawn with the double characters
(`═`), regardless of the width. The intersections between two designed lines, or between a
designed line and a default one, are selected automatically from the crossing designs. If
Unicode does not provide the required intersection character (for example, a heavy line
crossing a double one), the character in the field `borders` of the text table format is
used instead.

The color of each line design is converted to the corresponding line face of
`TextTableStyle` (see `_text__merge_line_style_colors`), unless the line face is explicitly
set, which has the highest precedence.
"""
_text__table_format(table_format::TextTableFormat) = table_format

function _text__table_format(table_format::TableFormat)
    def = TextTableFormat()

    top_design    = _text__line_design(table_format.top_line)
    header_design = _text__line_design(table_format.header_line)
    merged_design = _text__line_design(table_format.merged_header_cell_line)
    middle_design = _text__line_design(table_format.middle_line)
    bottom_design = _text__line_design(table_format.bottom_line)
    left_design   = _text__line_design(table_format.left_line)
    center_design = _text__line_design(table_format.center_line)
    right_design  = _text__line_design(table_format.right_line)

    return TextTableFormat(;
        top_line                = _text__horizontal_line_borders(
            top_design, left_design, center_design, right_design
        ),
        header_line             = _text__horizontal_line_borders(
            header_design, left_design, center_design, right_design
        ),
        merged_header_cell_line = _text__horizontal_line_borders(
            merged_design, left_design, center_design, right_design
        ),
        middle_line             = _text__horizontal_line_borders(
            middle_design, left_design, center_design, right_design
        ),
        bottom_line             = _text__horizontal_line_borders(
            bottom_design, left_design, center_design, right_design
        ),
        left_line               = isnothing(left_design) ?
            nothing : _text__vertical_line_char(left_design),
        center_line             = isnothing(center_design) ?
            nothing : _text__vertical_line_char(center_design),
        right_line              = isnothing(right_design) ?
            nothing : _text__vertical_line_char(right_design),
        _table_format_presence_fields(table_format, def)...
    )
end

"""
    _text__merge_line_style_colors(nt::NamedTuple, table_format::TableFormat) -> NamedTuple

Merge the colors of the line designs in the backend-agnostic `table_format` into the line
faces of the text table style in `nt`, which contains the keyword arguments passed to the
text back end after the conversion of the generic configurations. The line faces explicitly
set in the style have precedence over the line design colors. If no line design sets a
color, `nt` is returned unchanged.
"""
function _text__merge_line_style_colors(nt::NamedTuple, table_format::TableFormat)
    top    = _text__line_style_face(table_format.top_line)
    header = _text__line_style_face(table_format.header_line)
    merged = _text__line_style_face(table_format.merged_header_cell_line)
    middle = _text__line_style_face(table_format.middle_line)
    bottom = _text__line_style_face(table_format.bottom_line)
    left   = _text__line_style_face(table_format.left_line)
    center = _text__line_style_face(table_format.center_line)
    right  = _text__line_style_face(table_format.right_line)

    if (
        isnothing(top) && isnothing(header) && isnothing(merged) && isnothing(middle) &&
        isnothing(bottom) && isnothing(left) && isnothing(center) && isnothing(right)
    )
        return nt
    end

    style = haskey(nt, :style) ? nt.style : _DEFAULT_TEXT_TABLE_STYLE

    new_style = TextTableStyle(;
        title                          = style.title,
        subtitle                       = style.subtitle,
        row_number_label               = style.row_number_label,
        row_number                     = style.row_number,
        stubhead_label                 = style.stubhead_label,
        row_label                      = style.row_label,
        row_group_label                = style.row_group_label,
        first_line_column_label        = style.first_line_column_label,
        column_label                   = style.column_label,
        first_line_merged_column_label = style.first_line_merged_column_label,
        merged_column_label            = style.merged_column_label,
        summary_row_cell               = style.summary_row_cell,
        summary_row_label              = style.summary_row_label,
        footnote                       = style.footnote,
        source_note                    = style.source_note,
        omitted_cell_summary           = style.omitted_cell_summary,
        table_border                   = style.table_border,
        top_line                       = isnothing(style.top_line) ? top : style.top_line,
        header_line                    = isnothing(style.header_line) ?
            header : style.header_line,
        merged_header_cell_line        = isnothing(style.merged_header_cell_line) ?
            merged : style.merged_header_cell_line,
        middle_line                    = isnothing(style.middle_line) ?
            middle : style.middle_line,
        bottom_line                    = isnothing(style.bottom_line) ?
            bottom : style.bottom_line,
        left_line                      = isnothing(style.left_line) ?
            left : style.left_line,
        center_line                    = isnothing(style.center_line) ?
            center : style.center_line,
        right_line                     = isnothing(style.right_line) ?
            right : style.right_line,
    )

    return merge(nt, (style = new_style,))
end
