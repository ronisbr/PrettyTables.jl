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

"""
    _html__table_format(table_format::Union{TableFormat, HtmlTableFormat}) -> HtmlTableFormat

Convert `table_format` to a `HtmlTableFormat`. A native `HtmlTableFormat` is returned
unchanged. The HTML back end currently does not support the backend-agnostic
[`TableFormat`](@ref): the object is ignored and the default HTML table format is used. The
table lines can be customized with the field `css` of `HtmlTableFormat`.
"""
_html__table_format(table_format::HtmlTableFormat) = table_format
_html__table_format(::TableFormat) = HtmlTableFormat()
