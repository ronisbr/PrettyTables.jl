## Description #############################################################################
#
# Functions to write each section of the table
#
############################################################################################

"""
    _excel_write_title!(sheet, table_data, style, footnote_refs, current_row, num_cols, col_offset)

Write the table title to the worksheet.
"""
function _excel_write_title!(sheet, table_data, style, footnote_refs, current_row, num_cols, col_offset)
    title_text = table_data.title
    # Check for footnote reference in title
    if haskey(footnote_refs, (:title, 1, 1))
        title_text = title_text * _excel_to_superscript(footnote_refs[(:title, 1, 1)])
    end
    _excel_unempty_row(sheet, current_row, 1:num_cols+col_offset) # ensure these cells aren't empty before merging
    sheet[current_row, 1] = title_text
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, 1), XLSX.CellRef(current_row, num_cols + col_offset)))
    atts = _excel_newpairs(style.title)
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row, 1; atts...)
    else
        setFont(sheet, current_row, 1; size=fontsize)
    end
    setAlignment(sheet, current_row, 1; vertical = "center", horizontal=_excel_alignment_string(table_data.title_alignment), wrapText = true)
    title_lines = _excel_text_lines(title_text)
    setRowHeight(sheet, current_row; height = _excel_row_height_for_text(title_lines, fontsize))
    return nothing
end

"""
    _excel_write_subtitle!(sheet, table_data, style, footnote_refs, current_row, num_cols, col_offset)

Write the table subtitle to the worksheet.
"""
function _excel_write_subtitle!(sheet, table_data, style, footnote_refs, current_row, num_cols, col_offset)
    subtitle_text = table_data.subtitle

    # Check for footnote reference in subtitle
    if haskey(footnote_refs, (:subtitle, 1, 1))
        subtitle_text = subtitle_text * _excel_to_superscript(footnote_refs[(:subtitle, 1, 1)])
    end

    sheet[current_row, 1] = subtitle_text
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, 1), XLSX.CellRef(current_row, num_cols + col_offset)))
    atts = _excel_newpairs(style.subtitle)
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row, 1; atts...)
    else
        setFont(sheet, current_row, 1; size=fontsize)
   end
    setAlignment(sheet, current_row, 1; vertical = "center", horizontal=_excel_alignment_string(table_data.subtitle_alignment), wrapText = true)
    subtitle_lines = _excel_text_lines(subtitle_text)
    setRowHeight(sheet, current_row; height = _excel_row_height_for_text(subtitle_lines, fontsize))
    return nothing
end

"""
    _excel_write_row_number_column!(sheet, table_data, table_format, style, max_row_lines, max_row_height, max_col_length, max_col_height, current_row)

Write the row number column header to the worksheet.
"""
function _excel_write_row_number_column!(sheet, table_data, table_format, style, max_row_lines, max_row_height, max_col_length, max_col_height, current_row)
    if !isnothing(table_data.row_number_column_label)
        number_label = table_data.row_number_column_label
        sheet[current_row, 1] = number_label
        
        lines=_excel_text_lines(number_label)
        max_col_length[1] = max(_excel_multilength(number_label), max_col_length[1])
        max_row_lines = max(max_row_lines, lines)
        atts = _excel_newpairs(style.row_number_label)
        fontsize=DEFAULT_FONT_SIZE
        if !isnothing(atts)
            g = _excel_getsize(atts)
            isnothing(g) && push!(atts, :size => fontsize)
            fontsize = isnothing(g) ? fontsize : g
            setFont(sheet, current_row, 1; atts...)
        else
            setFont(sheet, current_row, 1; size=fontsize)
        end
        if table_data.show_row_number_column && table_format.vline_after_row_numbers
            sheet[current_row+1:current_row+length(table_data.column_labels), 1]=""
            setBorder(sheet, current_row:current_row+length(table_data.column_labels), 1; right=table_format.vline_after_row_numbers_type)
        end
        max_col_height[1] = max(max_col_height[1], fontsize)
        max_row_height = max(max_row_height, fontsize)
    end
    return max_row_lines, max_row_height
end

"""
    _excel_write_footnotes!(sheet, table_data, style, current_row, num_cols, col_offset)

Write the footnotes section to the worksheet.
"""
function _excel_write_footnotes!(sheet, table_data, style, current_row, num_cols, col_offset)
    start_row = current_row
    atts = _excel_newpairs(style.footnote)
    fontsize=DEFAULT_FONT_SIZE
    for (idx, (_, footnote_text)) in enumerate(table_data.footnotes)
        # Format as: ¹ Footnote text
        sheet[current_row, 1] = _excel_to_superscript(idx) * " " * string(footnote_text)
        mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, 1), XLSX.CellRef(current_row, num_cols + col_offset)))
        footnote_lines = _excel_text_lines(footnote_text)
        if !isnothing(atts)
            fontsize = _excel_update_fontsize!(atts, fontsize)
            setFont(sheet, current_row, 1; atts...)
        else
            setFont(sheet, current_row, 1; size=fontsize)
        end
        setRowHeight(sheet, current_row; height = _excel_row_height_for_text(footnote_lines, fontsize))
        current_row = current_row + 1
   end
    setUniformAlignment(sheet, start_row:current_row-1, 1; vertical = "center", horizontal=_excel_alignment_string(table_data.footnote_alignment), wrapText = true)
    setUniformFont(sheet, start_row:current_row-1, 1; atts...)
    return current_row
end

"""
    _write_excel_sourcenotes!(sheet, table_data, style, current_row, num_cols, col_offset)

Write the source notes section to the worksheet.
"""
function _write_excel_sourcenotes!(sheet, table_data, style, current_row, num_cols, col_offset)
    _excel_unempty_row(sheet, current_row, 1:num_cols+col_offset) # ensure these cells aren't empty before merging
    sheet[current_row, 1] = table_data.source_notes
    atts = _excel_newpairs(style.source_note)
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row, 1; atts...)
    else
        setFont(sheet, current_row, 1; size=fontsize)
    end
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, 1), XLSX.CellRef(current_row, num_cols + col_offset)))
    setAlignment(sheet, current_row, 1; horizontal = _excel_alignment_string(table_data.source_note_alignment), wrapText=true)
    source_lines = _excel_text_lines(table_data.source_notes)
    setRowHeight(sheet, current_row; height = _excel_row_height_for_text(source_lines, fontsize))
    return nothing
end
