## Description #############################################################################
#
# Excel Back End: Functions to write table sections.
#
############################################################################################

"""
    _excel__write_full_span_cell!(
        sheet::XLSX.Worksheet,
        text::Any,
        row::Int,
        num_cols::Int,
        col_offset::Int,
        anchor_row_offset::Int,
        anchor_col_offset::Int,
        style_attributes::Union{Nothing, Vector{Pair{Symbol, Any}}},
        fill_attributes::Union{Nothing, Vector{Pair{Symbol, Any}}},
        alignment::Union{Nothing, Symbol},
        valign::String
    ) -> Float64

Write a cell that spans the full width of the table (title, subtitle, row group labels,
footnotes, source notes). Returns the computed row height. The caller is responsible for
calling `_excel__unempty_row!` before invoking this function.
"""
function _excel__write_full_span_cell!(
    sheet::XLSX.Worksheet,
    text::Any,
    row::Int,
    num_cols::Int,
    col_offset::Int,
    anchor_row_offset::Int,
    anchor_col_offset::Int,
    style_attributes::Union{Nothing, Vector{Pair{Symbol, Any}}},
    fill_attributes::Union{Nothing, Vector{Pair{Symbol, Any}}},
    alignment::Union{Nothing, Symbol},
    valign::String,
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

    fontsize = _excel__set_fontsize_and_alignment!(
        sheet, sheet_row, col_start, style_attributes, alignment, valign, true
    )

    if !isnothing(fill_attributes)
        XLSX.setFill(sheet, sheet_row, col_start; fill_attributes...)
    end

    text_lines = text isa AbstractString ? _excel__text_lines(text) : 1
    return _excel__row_height_for_text(text_lines, fontsize)
end

"""
    _excel__finalize_footnotes!(
        sheet::XLSX.Worksheet,
        table_data::TableData,
        table_format::ExcelTableFormat,
        style::ExcelTableStyle,
        footnote_start_row::Int,
        footnote_end_row::Int,
        anchor_col_offset::Int,
        col_offset::Int,
        num_cols::Int
    ) -> Nothing

Apply batch font/alignment styling across all footnote rows and draw the optional underline
border after footnotes. Called once after the last footnote row is written.
`footnote_start_row` and `footnote_end_row` are absolute Excel row numbers (including the
anchor offset).
"""
function _excel__finalize_footnotes!(
    sheet::XLSX.Worksheet,
    table_data::TableData,
    table_format::ExcelTableFormat,
    style::ExcelTableStyle,
    footnote_start_row::Int,
    footnote_end_row::Int,
    anchor_col_offset::Int,
    col_offset::Int,
    num_cols::Int,
)
    attributes = _excel__newpairs(_excel__tablestyle_attributes("footnote", style.footnote))

    XLSX.setUniformAlignment(
        sheet,
        footnote_start_row:footnote_end_row,
        1 + anchor_col_offset;
        vertical   = "center",
        horizontal = _excel__alignment_string(table_data.footnote_alignment),
        wrapText   = true,
    )

    if !isnothing(attributes)
        XLSX.setUniformFont(
            sheet,
            footnote_start_row:footnote_end_row,
            1 + anchor_col_offset;
            attributes...,
        )
    end

    if _excel__check_table_format("underline_footnotes", table_format.underline_footnotes)
        XLSX.setBorder(
            sheet,
            footnote_end_row,
            1 + anchor_col_offset : num_cols + col_offset + anchor_col_offset;
            bottom = _excel__tableformat_attributes(
                "underline_footnotes_type",
                table_format.underline_footnotes_type,
            ),
        )
    end
end
