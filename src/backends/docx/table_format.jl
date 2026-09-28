## Description #############################################################################
#
# Word Back End: Conversion of the backend-agnostic table format and style.
#
############################################################################################

# The native objects of this back end select it when `backend = :auto`.
_backend_of(::Union{DocxTableFormat, DocxTableStyle}) = :docx

"""
    _docx__table_style(style::Union{TableStyle, DocxTableStyle}) -> DocxTableStyle

Convert `style` to a `DocxTableStyle`. A native `DocxTableStyle` is returned unchanged,
whereas the fields of a backend-agnostic [`TableStyle`](@ref) override the ones of the
default Word table style.
"""
_docx__table_style(style::DocxTableStyle) = style
_docx__table_style(style::TableStyle) = DocxTableStyle(; _table_style_kwargs(style)...)

function _docx__table_style(style::Any)
    return throw(
        ArgumentError(
            "The Word back end does not support a style of type `$(typeof(style))`. Use `DocxTableStyle` or the backend-agnostic `TableStyle`.",
        ),
    )
end

export docx_line_style

"""
    docx_line_style(line_style::LineStyle; default::Vector{DocxPair} = DocxPair["style" => "single", "size" => "4", "color" => "000000"]) -> Vector{DocxPair}

Convert `line_style` into the border attributes used by the Word back end.

The `style` field selects the Word border style, whereas the `width` field selects the
border size in eighths of a point:

| `style`   | Word Border Style | `width`    | Word Border Size |
|:----------|:------------------|:-----------|:-----------------|
| `:solid`  | `single`          | `:thin`    | `4`              |
| `:dashed` | `dashed`          | `:medium`  | `8`              |
| `:dotted` | `dotted`          | `:thick`   | `16`             |
| `:double` | `double`          |            |                  |

The `color` is converted to the 6-digit value `"RRGGBB"`. An unset field keeps the
corresponding border attribute in `default`, as does a color that is `nothing` or cannot be
resolved to a 24-bit value.
"""
function docx_line_style(
    line_style::LineStyle;
    default::Vector{DocxPair} = DocxPair[
        "style" => "single", "size" => "4", "color" => "000000"
    ],
)
    default_style = something(_docx__pair_value(default, "style"), "single")
    default_size  = something(_docx__pair_value(default, "size"), "4")
    default_color = something(_docx__pair_value(default, "color"), "000000")

    style = if isnothing(line_style.style)
        default_style
    elseif line_style.style == :dashed
        "dashed"
    elseif line_style.style == :dotted
        "dotted"
    elseif line_style.style == :double
        "double"
    else
        "single"
    end

    size = if isnothing(line_style.width)
        default_size
    elseif line_style.width == :medium
        "8"
    elseif line_style.width == :thick
        "16"
    else
        "4"
    end

    color_hex = _face_color_hex(line_style.color; uppercase = true)
    color     = isnothing(color_hex) ? default_color : color_hex

    return DocxPair["style" => style, "size" => size, "color" => color]
end

"""
    _docx__pair_value(pairs::Vector{DocxPair}, key::String) -> Union{Nothing, String}

Return the value of the first pair in `pairs` with `key`, or `nothing` if there is none.
"""
function _docx__pair_value(pairs::Vector{DocxPair}, key::String)
    for (k, v) in pairs
        (k == key) && return v
    end

    return nothing
end

"""
    _docx__table_format(table_format::Union{TableFormat, DocxTableFormat}) -> DocxTableFormat

Convert `table_format` to a `DocxTableFormat`. A native `DocxTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default Word table format. The Word-only fields
`horizontal_line_between_column_labels`, `cell_margins`, and
`repeat_header_rows_at_page_breaks` keep their defaults.
"""
_docx__table_format(table_format::DocxTableFormat) = table_format

function _docx__table_format(table_format::Any)
    return throw(
        ArgumentError(
            "The Word back end does not support a table format of type `$(typeof(table_format))`. Use `DocxTableFormat` or the backend-agnostic `TableFormat`.",
        ),
    )
end

function _docx__table_format(table_format::TableFormat)
    def = _DEFAULT_DOCX_TABLE_FORMAT

    return DocxTableFormat(;
        borders = _table_format_borders(table_format, def.borders, docx_line_style),
        _table_format_presence_fields(table_format, def)...,
    )
end
