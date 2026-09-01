## Description #############################################################################
#
# HTML Back End: Conversion of the backend-agnostic table format and style.
#
############################################################################################

"""
    _html__table_style(style::Union{TableStyle, HtmlTableStyle}) -> HtmlTableStyle

Convert `style` to a `HtmlTableStyle`. A native `HtmlTableStyle` is returned unchanged,
whereas the fields of a backend-agnostic [`TableStyle`](@ref) override the ones of the
default HTML table style.
"""
_html__table_style(style::HtmlTableStyle) = style
_html__table_style(style::TableStyle) = HtmlTableStyle(; _table_style_kwargs(style)...)

export html_line_style

"""
    html_line_style(line_style::LineStyle) -> String

Convert `line_style` into a CSS `border` shorthand value.

The `width` is converted to `"1px"` (`:thin`), `"2px"` (`:medium`), or `"3px"` (`:thick`),
defaulting to `"1px"` if unset. The `style` is converted to the border style `"solid"`,
`"dashed"`, `"dotted"`, or `"double"`, defaulting to `"solid"` if unset. The `color` is
converted to the hexadecimal form `"#rrggbb"`; a color that cannot be resolved to a 24-bit
value falls back to `"black"`.
"""
function html_line_style(line_style::LineStyle)
    width = if line_style.width == :thin
        "1px"
    elseif line_style.width == :medium
        "2px"
    elseif line_style.width == :thick
        "3px"
    else
        "1px"
    end

    style = isnothing(line_style.style) ? "solid" : string(line_style.style)

    hex   = _face_color_hex(line_style.color)
    color = isnothing(hex) ? "black" : "#" * hex

    return width * " " * style * " " * color
end

"""
    _html__table_format(table_format::Union{TableFormat, HtmlTableFormat}) -> HtmlTableFormat

Convert `table_format` to a `HtmlTableFormat`. A native `HtmlTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default HTML table format.
"""
_html__table_format(table_format::HtmlTableFormat) = table_format

function _html__table_format(table_format::TableFormat)
    def = HtmlTableFormat()
    db  = def.borders

    borders = HtmlTableBorders(;
        top_line                = _table_format_border(
            table_format.top_line, html_line_style, db.top_line
        ),
        header_line             = _table_format_border(
            table_format.header_line, html_line_style, db.header_line
        ),
        merged_header_cell_line = _table_format_border(
            table_format.merged_header_cell_line,
            html_line_style,
            db.merged_header_cell_line
        ),
        middle_line             = _table_format_border(
            table_format.middle_line, html_line_style, db.middle_line
        ),
        bottom_line             = _table_format_border(
            table_format.bottom_line, html_line_style, db.bottom_line
        ),
        left_line               = _table_format_border(
            table_format.left_line, html_line_style, db.left_line
        ),
        center_line             = _table_format_border(
            table_format.center_line, html_line_style, db.center_line
        ),
        right_line              = _table_format_border(
            table_format.right_line, html_line_style, db.right_line
        ),
    )

    return HtmlTableFormat(;
        borders,

        # The following presence fields only exist in the HTML back end. Hence, they are
        # not returned by `_table_format_presence_fields` and must be merged here.
        horizontal_line_before_column_labels = _table_format_field(
            table_format.horizontal_line_before_column_labels,
            def.horizontal_line_before_column_labels
        ),
        horizontal_line_after_footnotes      = _table_format_field(
            table_format.horizontal_line_after_footnotes,
            def.horizontal_line_after_footnotes
        ),
        horizontal_line_at_end               = _table_format_field(
            table_format.horizontal_line_at_end,
            def.horizontal_line_at_end
        ),
        _table_format_presence_fields(table_format, def)...
    )
end
