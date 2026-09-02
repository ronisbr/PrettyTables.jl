## Description #############################################################################
#
# LaTeX Back End: Conversion of the backend-agnostic table format and style.
#
############################################################################################

"""
    _latex__table_style(style::Union{TableStyle, LatexTableStyle}) -> LatexTableStyle

Convert `style` to a `LatexTableStyle`. A native `LatexTableStyle` is returned unchanged,
whereas the fields of a backend-agnostic [`TableStyle`](@ref) override the ones of the
default LaTeX table style.
"""
_latex__table_style(style::LatexTableStyle) = style
_latex__table_style(style::TableStyle) = LatexTableStyle(; _table_style_kwargs(style)...)

export latex_line_style

"""
    latex_line_style(line_style::LineStyle) -> String

Convert `line_style` into a LaTeX horizontal rule command.

The `style` is converted as follows: `:solid` becomes `"\\\\hline"`, `:double` becomes
`"\\\\hline\\\\hline"`, `:dashed` becomes `"\\\\hdashline"`, and `:dotted` becomes
`"\\\\hdashline[1pt/1pt]"`. The dashed and dotted rules require the package **arydshln** to
be loaded in the document. The `width` and `color` fields are ignored because LaTeX
controls them with the global commands `\\\\arrayrulewidth` and `\\\\arrayrulecolor`.
"""
function latex_line_style(line_style::LineStyle)
    line_style.style == :double && return "\\hline\\hline"
    line_style.style == :dashed && return "\\hdashline"
    line_style.style == :dotted && return "\\hdashline[1pt/1pt]"
    return "\\hline"
end

"""
    _latex__table_format(table_format::Union{TableFormat, LatexTableFormat}) -> LatexTableFormat

Convert `table_format` to a `LatexTableFormat`. A native `LatexTableFormat` is returned
unchanged, whereas the fields of a backend-agnostic [`TableFormat`](@ref) override the ones
of the default LaTeX table format.

The design of `merged_header_cell_line` always keeps the default `"\\\\cline"` because the
back end appends the column range to this command. The designs of the vertical lines
(`left_line`, `center_line`, and `right_line`) are ignored because the back end draws them
with the column specification of the table environment.
"""
_latex__table_format(table_format::LatexTableFormat) = table_format

function _latex__table_format(table_format::TableFormat)
    def = _DEFAULT_LATEX_TABLE_FORMAT

    return LatexTableFormat(;
        borders = _table_format_borders(table_format, def.borders, latex_line_style; skip = (:merged_header_cell_line,)),
        _table_format_presence_fields(table_format, def)...
    )
end
