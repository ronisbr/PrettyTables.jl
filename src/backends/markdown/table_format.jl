## Description #############################################################################
#
# Markdown Back End: Conversion of the backend-agnostic table format and style.
#
############################################################################################

# Fields of `TableStyle` without a counterpart in `MarkdownTableStyle`: the title and the
# subtitle are rendered as Markdown headings, and the merged column label cells have no
# dedicated decoration.
const _MARKDOWN__UNSUPPORTED_STYLE_FIELDS = (
    :title,
    :subtitle,
    :first_line_merged_column_label,
    :merged_column_label,
)

"""
    _markdown__table_style(style::Union{TableStyle, MarkdownTableStyle}) -> MarkdownTableStyle

Convert `style` to a `MarkdownTableStyle`. A native `MarkdownTableStyle` is returned
unchanged, whereas the fields of a backend-agnostic [`TableStyle`](@ref) override the ones
of the default Markdown table style. The fields `title`, `subtitle`,
`first_line_merged_column_label`, and `merged_column_label` are ignored because the
Markdown table style does not have them.
"""
_markdown__table_style(style::MarkdownTableStyle) = style

function _markdown__table_style(style::TableStyle)
    return MarkdownTableStyle(;
        _table_style_kwargs(style; drop = _MARKDOWN__UNSUPPORTED_STYLE_FIELDS)...
    )
end

"""
    _markdown__table_format(table_format::Union{TableFormat, MarkdownTableFormat}) -> MarkdownTableFormat

Convert `table_format` to a `MarkdownTableFormat`. A native `MarkdownTableFormat` is
returned unchanged. For a backend-agnostic [`TableFormat`](@ref), only
`horizontal_line_before_summary_rows` is honored (it maps to the field
`line_before_summary_rows`) because Markdown tables cannot express the other lines.
"""
_markdown__table_format(table_format::MarkdownTableFormat) = table_format

function _markdown__table_format(table_format::TableFormat)
    def = MarkdownTableFormat()

    return MarkdownTableFormat(;
        line_before_summary_rows = _table_format_field(
            table_format.horizontal_line_before_summary_rows, def.line_before_summary_rows
        )
    )
end
