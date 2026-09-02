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
# The native objects of this back end select it when `backend = :auto`.
_backend_of(::Union{HtmlTableFormat, HtmlTableStyle}) = :html

_html__table_style(style::HtmlTableStyle) = style
_html__table_style(style::TableStyle) = HtmlTableStyle(; _table_style_kwargs(style)...)

function _html__table_style(style::Any)
    throw(
        ArgumentError(
            "The HTML back end does not support a style of type `$(typeof(style))`. Use `HtmlTableStyle` or the backend-agnostic `TableStyle`."
        )
    )
end

export html_line_style

"""
    html_line_style(line_style::LineStyle; default::String = "1px solid black") -> String

Convert `line_style` into a CSS `border` shorthand value.

The `width` is converted to `"1px"` (`:thin`), `"2px"` (`:medium`), or `"3px"` (`:thick`).
The `style` is converted to the border style `"solid"`, `"dashed"`, `"dotted"`, or
`"double"`. The `color` is converted to the hexadecimal form `"#rrggbb"`. Every unset field,
or a color that cannot be resolved to a 24-bit value, keeps the corresponding component of
the shorthand `default`, which must have the form `"<width> <style> <color>"`. If `default`
does not have this form, the unset components are `"1px"`, `"solid"`, and `"black"`.
"""
function html_line_style(line_style::LineStyle; default::String = "1px solid black")
    tokens = split(default)
    default_width, default_style, default_color =
        length(tokens) == 3 ? String.(tokens) : ("1px", "solid", "black")

    width = if line_style.width == :thin
        "1px"
    elseif line_style.width == :medium
        "2px"
    elseif line_style.width == :thick
        "3px"
    else
        default_width
    end

    style = isnothing(line_style.style) ? default_style : string(line_style.style)

    hex   = _face_color_hex(line_style.color)
    color = isnothing(hex) ? default_color : "#" * hex

    return width * " " * style * " " * color
end

"""
    _html__table_format(table_format::Union{TableFormat, HtmlTableFormat}) -> HtmlTableFormat

Convert `table_format` to a `HtmlTableFormat`. A native `HtmlTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default HTML table format.
"""
_html__table_format(table_format::HtmlTableFormat) = table_format

function _html__table_format(table_format::Any)
    throw(
        ArgumentError(
            "The HTML back end does not support a table format of type `$(typeof(table_format))`. Use `HtmlTableFormat` or the backend-agnostic `TableFormat`."
        )
    )
end

function _html__table_format(table_format::TableFormat)
    def = _DEFAULT_HTML_TABLE_FORMAT

    return HtmlTableFormat(;
        borders = _table_format_borders(table_format, def.borders, html_line_style),

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
