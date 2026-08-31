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
unchanged, whereas the line presence fields of a backend-agnostic [`TableFormat`](@ref)
override the ones of the default text table format.

The line design fields are ignored because the text back end draws the table with a single
character set (see `TextTableBorders`), which cannot express a design for each line. The
color of all the table lines can be set with the field `table_border` of `TextTableStyle`.
"""
_text__table_format(table_format::TextTableFormat) = table_format

function _text__table_format(table_format::TableFormat)
    def = TextTableFormat()
    return TextTableFormat(; _table_format_presence_fields(table_format, def)...)
end
