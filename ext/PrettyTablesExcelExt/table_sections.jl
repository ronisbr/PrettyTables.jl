## Description #############################################################################
#
# Excel Back End: Functions to write table sections.
#
############################################################################################

"""
    _excel_write_full_span_cell!(
        sheet, text, row, num_cols, col_offset,
        anchor_row_offset, anchor_col_offset,
        style_atts, fill_atts, alignment, valign
    ) -> Float64

Write a cell that spans the full width of the table (title, subtitle, row group labels,
footnotes, source notes). Returns the computed row height.

The caller is responsible for calling `_excel_unempty_row` before invoking this function.
"""
function _excel_write_full_span_cell!(
    sheet,
    text,
    row,
    num_cols,
    col_offset,
    anchor_row_offset,
    anchor_col_offset,
    style_atts,
    fill_atts,
    alignment,
    valign,
)
    sheet_row = row + anchor_row_offset
    col_start = 1 + anchor_col_offset
    col_end   = num_cols + col_offset + anchor_col_offset

    sheet[sheet_row, col_start] = text

    XLSX.mergeCells(
        sheet,
        XLSX.CellRange(
            XLSX.CellRef(sheet_row, col_start),
            XLSX.CellRef(sheet_row, col_end),
        ),
    )

    fontsize = _excel_set_fontsize_and_alignment!(
        sheet, sheet_row, col_start, style_atts, alignment, valign, true
    )

    if !isnothing(fill_atts)
        XLSX.setFill(sheet, sheet_row, col_start; fill_atts...)
    end

    text_lines = text isa AbstractString ? _excel_text_lines(text) : 1
    return _excel_row_height_for_text(text_lines, fontsize)
end

"""
    _excel_finalize_footnotes!(
        sheet, table_data, table_format, style, fill,
        footnote_start_row, footnote_end_row,
        anchor_col_offset, col_offset, num_cols
    )

Apply batch font/alignment styling across all footnote rows and draw the optional
underline border after footnotes. Called once after the last footnote row is written.

`footnote_start_row` and `footnote_end_row` are absolute Excel row numbers (including
the anchor offset).
"""
function _excel_finalize_footnotes!(
    sheet,
    table_data,
    table_format,
    style,
    fill,
    footnote_start_row,
    footnote_end_row,
    anchor_col_offset,
    col_offset,
    num_cols,
)
    atts = _excel_newpairs(_excel_tablestyle_atts("footnote", style.footnote))

    XLSX.setUniformAlignment(
        sheet,
        footnote_start_row:footnote_end_row,
        1 + anchor_col_offset;
        vertical   = "center",
        horizontal = _excel_alignment_string(table_data.footnote_alignment),
        wrapText   = true,
    )

    if !isnothing(atts)
        XLSX.setUniformFont(
            sheet,
            footnote_start_row:footnote_end_row,
            1 + anchor_col_offset;
            atts...,
        )
    end

    if _excel_check_table_format("underline_footnotes", table_format.underline_footnotes)
        XLSX.setBorder(
            sheet,
            footnote_end_row,
            1 + anchor_col_offset : num_cols + col_offset + anchor_col_offset;
            bottom = _excel_tableformat_atts(
                "underline_footnotes_type",
                table_format.underline_footnotes_type,
            ),
        )
    end
end
