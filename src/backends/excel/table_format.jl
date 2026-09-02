## Description #############################################################################
#
# Excel Back End: Conversion of the backend-agnostic table format and style.
#
############################################################################################

"""
    _excel__table_style(style::Union{TableStyle, ExcelTableStyle}) -> ExcelTableStyle

Convert `style` to an `ExcelTableStyle`. A native `ExcelTableStyle` is returned unchanged,
whereas the fields of a backend-agnostic [`TableStyle`](@ref) override the ones of the
default Excel table style.
"""
_excel__table_style(style::ExcelTableStyle) = style
_excel__table_style(style::TableStyle) = ExcelTableStyle(; _table_style_kwargs(style)...)

export excel_line_style

"""
    excel_line_style(line_style::LineStyle) -> Vector{ExcelPair}

Convert `line_style` into the border attributes used by the Excel back end.

The Excel border style is selected from the combination of the `style` and `width` fields
(unset fields default to `:solid` and `:thin`):

| `style` \\ `width` | `:thin`    | `:medium`        | `:thick`         |
|:-------------------|:-----------|:-----------------|:-----------------|
| `:solid`           | `thin`     | `medium`         | `thick`          |
| `:dashed`          | `dashed`   | `mediumDashed`   | `mediumDashed`   |
| `:dotted`          | `dotted`   | `dotted`         | `dotted`         |
| `:double`          | `double`   | `double`         | `double`         |

The `color` is converted to the 8-digit value `"FFRRGGBB"`; a color that is `nothing` or
cannot be resolved to a 24-bit value becomes `"Black"`, matching the default borders of
`ExcelTableBorders`.
"""
function excel_line_style(line_style::LineStyle)
    style = isnothing(line_style.style) ? :solid : line_style.style
    width = isnothing(line_style.width) ? :thin  : line_style.width

    border_style = if style == :dashed
        width == :thin ? "dashed" : "mediumDashed"
    elseif style == :dotted
        "dotted"
    elseif style == :double
        "double"
    else
        width == :thin ? "thin" : (width == :medium ? "medium" : "thick")
    end

    color_hex = _face_color_hex(line_style.color; uppercase = true)
    color     = isnothing(color_hex) ? "Black" : "FF" * color_hex

    return ExcelPair["style" => border_style, "color" => color]
end

"""
    _excel__table_format(table_format::Union{TableFormat, ExcelTableFormat}) -> ExcelTableFormat

Convert `table_format` to an `ExcelTableFormat`. A native `ExcelTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default Excel table format. The Excel-only field
`horizontal_line_between_column_labels` keeps its default.
"""
_excel__table_format(table_format::ExcelTableFormat) = table_format

function _excel__table_format(table_format::TableFormat)
    def = _DEFAULT_EXCEL_TABLE_FORMAT

    return ExcelTableFormat(;
        borders = _table_format_borders(table_format, def.borders, excel_line_style),
        _table_format_presence_fields(table_format, def)...
    )
end
