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
# The native objects of this back end select it when `backend = :auto`.
_backend_of(::Union{ExcelTableFormat, ExcelTableStyle}) = :excel

_excel__table_style(style::ExcelTableStyle) = style
_excel__table_style(style::TableStyle) = ExcelTableStyle(; _table_style_kwargs(style)...)

function _excel__table_style(style::Any)
    throw(
        ArgumentError(
            "The Excel back end does not support a style of type `$(typeof(style))`. Use `ExcelTableStyle` or the backend-agnostic `TableStyle`."
        )
    )
end

export excel_line_style

"""
    excel_line_style(line_style::LineStyle; default::Vector{ExcelPair} = ExcelPair["style" => "thin", "color" => "Black"]) -> Vector{ExcelPair}

Convert `line_style` into the border attributes used by the Excel back end.

The Excel border style is selected from the combination of the `style` and `width` fields
(unset fields default to `:solid` and `:thin`):

| `style` \\ `width` | `:thin`    | `:medium`        | `:thick`         |
|:-------------------|:-----------|:-----------------|:-----------------|
| `:solid`           | `thin`     | `medium`         | `thick`          |
| `:dashed`          | `dashed`   | `mediumDashed`   | `mediumDashed`   |
| `:dotted`          | `dotted`   | `dotted`         | `dotted`         |
| `:double`          | `double`   | `double`         | `double`         |

The `color` is converted to the 8-digit value `"FFRRGGBB"`. An unset `style` or `width`
keeps the one of the border attributes in `default`, and a color that is `nothing` or
cannot be resolved to a 24-bit value keeps the color in `default`.
"""
function excel_line_style(
    line_style::LineStyle;
    default::Vector{ExcelPair} = ExcelPair["style" => "thin", "color" => "Black"]
)
    default_style = something(_excel__pair_value(default, "style"), "thin")
    default_color = something(_excel__pair_value(default, "color"), "Black")

    # The default border style carries a width and a style. We only need them when the
    # corresponding field of the line style is unset.
    default_width_symbol =
        (default_style == "thick") ? :thick :
        startswith(default_style, "medium") ? :medium : :thin

    default_style_symbol =
        occursin("ashed", default_style) ? :dashed :
        (default_style == "dotted") ? :dotted :
        (default_style == "double") ? :double : :solid

    style = isnothing(line_style.style) ? default_style_symbol : line_style.style
    width = isnothing(line_style.width) ? default_width_symbol : line_style.width

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
    color     = isnothing(color_hex) ? default_color : "FF" * color_hex

    return ExcelPair["style" => border_style, "color" => color]
end

"""
    _excel__pair_value(pairs::Vector{ExcelPair}, key::String) -> Union{Nothing, String}

Return the value of the first pair in `pairs` with `key`, or `nothing` if there is none.
"""
function _excel__pair_value(pairs::Vector{ExcelPair}, key::String)
    for (k, v) in pairs
        (k == key) && return v
    end

    return nothing
end

"""
    _excel__table_format(table_format::Union{TableFormat, ExcelTableFormat}) -> ExcelTableFormat

Convert `table_format` to an `ExcelTableFormat`. A native `ExcelTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default Excel table format. The Excel-only field
`horizontal_line_between_column_labels` keeps its default.
"""
_excel__table_format(table_format::ExcelTableFormat) = table_format

function _excel__table_format(table_format::Any)
    throw(
        ArgumentError(
            "The Excel back end does not support a table format of type `$(typeof(table_format))`. Use `ExcelTableFormat` or the backend-agnostic `TableFormat`."
        )
    )
end

function _excel__table_format(table_format::TableFormat)
    def = _DEFAULT_EXCEL_TABLE_FORMAT

    return ExcelTableFormat(;
        borders = _table_format_borders(table_format, def.borders, excel_line_style),
        _table_format_presence_fields(table_format, def)...
    )
end
