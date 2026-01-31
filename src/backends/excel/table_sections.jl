## Description #############################################################################
#
# Functions to write each section of the table
#
############################################################################################

"""
    _excel_write_title!(sheet, table_data, style, footnote_refs, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)

Write the table title to the worksheet.
"""
function _excel_write_title!(sheet, table_data, style, footnote_refs, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
    title_text = table_data.title
    # Check for footnote reference in title
    if haskey(footnote_refs, (:title, 1, 1))
        title_text = title_text * _excel_to_superscript(footnote_refs[(:title, 1, 1)])
    end
    _excel_unempty_row(sheet, current_row + anchor_row_offset, 1+anchor_col_offset:num_cols+col_offset+anchor_col_offset) # ensure these cells aren't empty before merging
    sheet[current_row + anchor_row_offset, 1 + anchor_col_offset] = title_text
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row + anchor_row_offset, 1 + anchor_col_offset), XLSX.CellRef(current_row + anchor_row_offset, num_cols + col_offset + anchor_col_offset)))
    atts = _excel_newpairs(_excel_tablestyle_atts("title",style.title))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; size=fontsize)
    end
    setAlignment(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; vertical = "center", horizontal=_excel_alignment_string(table_data.title_alignment), wrapText = true)
    title_lines = _excel_text_lines(title_text)
    setRowHeight(sheet, current_row + anchor_row_offset; height = _excel_row_height_for_text(title_lines, fontsize))
    return nothing
end

"""
    _excel_write_subtitle!(sheet, table_data, style, footnote_refs, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)

Write the table subtitle to the worksheet.
"""
function _excel_write_subtitle!(sheet, table_data, style, footnote_refs, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
    subtitle_text = table_data.subtitle

    # Check for footnote reference in subtitle
    if haskey(footnote_refs, (:subtitle, 1, 1))
        subtitle_text = subtitle_text * _excel_to_superscript(footnote_refs[(:subtitle, 1, 1)])
    end

    sheet[current_row + anchor_row_offset, 1 + anchor_col_offset] = subtitle_text
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row + anchor_row_offset, 1 + anchor_col_offset), XLSX.CellRef(current_row + anchor_row_offset, num_cols + col_offset + anchor_col_offset)))
    atts = _excel_newpairs(_excel_tablestyle_atts("subtitle",style.subtitle))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; size=fontsize)
   end
    setAlignment(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; vertical = "center", horizontal=_excel_alignment_string(table_data.subtitle_alignment), wrapText = true)
    subtitle_lines = _excel_text_lines(subtitle_text)
    setRowHeight(sheet, current_row + anchor_row_offset; height = _excel_row_height_for_text(subtitle_lines, fontsize))
    return nothing
end

"""
    _excel_write_row_number_column!(sheet, table_data, table_format, style, max_row_lines, max_row_height, max_col_length, max_col_height, anchor_row_offset, anchor_col_offset, current_row)

Write the row number column header to the worksheet.
"""
function _excel_write_row_number_column!(sheet, table_data, table_format, style, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
    if !isnothing(table_data.row_number_column_label)
        number_label = table_data.row_number_column_label
        sheet[current_row + anchor_row_offset, 1 + anchor_col_offset] = number_label
        
        lines=_excel_text_lines(number_label)
        max_col_length[1] = max(_excel_multilength(number_label), max_col_length[1])
        atts = _excel_newpairs(_excel_tablestyle_atts("row_number_label",style.row_number_label))
        fontsize=DEFAULT_FONT_SIZE
        if !isnothing(atts)
            g = _excel_getsize(atts)
            isnothing(g) && push!(atts, :size => fontsize)
            fontsize = isnothing(g) ? fontsize : g
            setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; atts...)
        else
            setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; size=fontsize)
        end
        if table_data.show_row_number_column && _excel_check_table_format("vline_after_row_numbers",table_format.vline_after_row_numbers)
            sheet[current_row + anchor_row_offset + 1:current_row + anchor_row_offset + length(table_data.column_labels), 1 + anchor_col_offset]=""
            setBorder(sheet, current_row + anchor_row_offset:current_row + anchor_row_offset + length(table_data.column_labels), 1 + anchor_col_offset; right=table_format.vline_after_row_numbers_type)
        end
#        lines=_excel_text_lines(number_label)
        row_height, col_length = _excel_cell_length_and_height(number_label, fontsize)
        max_row_height = max(max_row_height, row_height)
        max_col_length[1] = max(max_col_length[1], col_length)
    end
    return max_row_height
end

"""
    _excel_write_stubhead_label!(sheet, table_data, style, max_row_lines, max_row_height, max_col_length, max_col_height, current_row)

Write the stubhead lebel to the worksheet.
"""
function _excel_write_stubhead_label!(sheet, table_data, style, col_offset, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
    stubhead_label = table_data.stubhead_label
    sheet[current_row + anchor_row_offset, col_offset + anchor_col_offset] = stubhead_label
    atts = _excel_newpairs(_excel_tablestyle_atts("stubhead_label",style.stubhead_label))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, col_offset + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, col_offset + anchor_col_offset; size=fontsize)
    end
    setAlignment(sheet, current_row + anchor_row_offset, col_offset + anchor_col_offset; vertical = "top", horizontal=_excel_alignment_string(table_data.row_label_column_alignment), wrapText = true)
    row_height, col_length = _excel_cell_length_and_height(stubhead_label, fontsize)
    max_row_height = max(max_row_height, row_height)
    max_col_length[col_offset] = max(max_col_length[col_offset], col_length)
    return max_row_height
end

function _excel_write_column_labels!(sheet, table_data, table_format, style, footnote_refs, merge_map, label_row, label_row_idx, j, num_cols, col_offset, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
    cla = _excel_column_alignment(j, table_data.column_label_alignment, table_data.data_alignment) # get the column label alignment
    # Check if this cell is the start of a merge
    if haskey(merge_map, (label_row_idx, j))
        span, merge_data, merge_alignment = merge_map[(label_row_idx, j)]
        label_text = string(merge_data)
        # Check for footnote reference
        if haskey(footnote_refs, (:column_label, label_row_idx, j))
            label_text = label_text * _excel_to_superscript(footnote_refs[(:column_label, label_row_idx, j)])
        end
        sheet[current_row + anchor_row_offset, j + col_offset + anchor_col_offset] = label_text
        mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row + anchor_row_offset, j + col_offset + anchor_col_offset), XLSX.CellRef(current_row + anchor_row_offset, j + col_offset + anchor_col_offset + span-1)))
        if label_row_idx == 1
            atts = _excel_newpairs(_excel_tablestyle_atts("first_line_merged_column_label", style.first_line_merged_column_label))
        else
            atts = _excel_newpairs(_excel_tablestyle_atts("column_label",style.column_label))
        end
        fontsize=DEFAULT_FONT_SIZE
        if !isnothing(atts)
            fontsize = _excel_update_fontsize!(atts, fontsize)
            setFont(sheet, current_row + anchor_row_offset, j+ col_offset + anchor_col_offset; atts...)
        else
            setFont(sheet, current_row + anchor_row_offset, j+ col_offset + anchor_col_offset; size=fontsize)
        end
        # don't include merged columns in column width calculation
        row_height, _ = _excel_cell_length_and_height(label_text, fontsize)
        max_row_height = max(max_row_height, row_height)
        setAlignment(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; vertical = "top", horizontal=_excel_alignment_string(merge_alignment), wrapText = true)
        if  _excel_check_table_format("underline_merged_headers",table_format.underline_merged_headers)
            setBorder(sheet, current_row + anchor_row_offset, j+col_offset + anchor_col_offset:j+col_offset + anchor_col_offset+span-1; bottom=table_format.underline_merged_headers_type)
        end
        if  _excel_check_table_format("vline_between_data_columns",table_format.vline_between_data_columns) && j+span < num_cols
            setBorder(sheet, current_row + anchor_row_offset, j+col_offset + anchor_col_offset; right=table_format.vline_between_data_columns_type)
        end
        # Skip the spanned columns
        j += span
    else
        # Regular label
        label_text = string(label_row[j])
        # Check for footnote reference
        if haskey(footnote_refs, (:column_label, label_row_idx, j))
            label_text = label_text * _excel_to_superscript(footnote_refs[(:column_label, label_row_idx, j)])
        end
        sheet[current_row + anchor_row_offset, j + col_offset + anchor_col_offset] = label_text
        atts = _excel_newpairs(_excel_tablestyle_atts("column_label",style.column_label))
        fontsize=DEFAULT_FONT_SIZE
        if !isnothing(atts)
            fontsize = _excel_update_fontsize!(atts, fontsize)
            setFont(sheet, current_row + anchor_row_offset, j+ col_offset + anchor_col_offset; atts...)
        else
            setFont(sheet, current_row + anchor_row_offset, j+ col_offset + anchor_col_offset; size=fontsize)
        end
        row_height, col_length = _excel_cell_length_and_height(label_text, fontsize)
        max_row_height = max(max_row_height, row_height)
        max_col_length[j+col_offset] = max(max_col_length[j+col_offset], col_length)
        setAlignment(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; vertical = "top", horizontal=cla, wrapText = true)
        if  _excel_check_table_format("vline_between_data_columns",table_format.vline_between_data_columns) && j < num_cols
            setBorder(sheet, current_row + anchor_row_offset, j+col_offset + anchor_col_offset; right=table_format.vline_between_data_columns_type)
        end
        j += 1
    end
    return j, max_row_height
end

"""
    _excel_write_group_row!(sheet, table_data, style, current_row, num_cols, col_offset)

Write a group row to the worksheet.
"""
function _excel_write_group_row!(sheet, table_data, table_format, style, footnote_refs, row_group_map, i, num_cols, col_offset, anchor_row_offset, anchor_col_offset, current_row)
    # Write row group label in its own row in the row number column (column 1)
    group_label = row_group_map[i]
    # Check for footnote reference in row group label
    if haskey(footnote_refs, (:row_group_label, i, 1))
        group_label = string(group_label) * _excel_to_superscript(footnote_refs[(:row_group_label, i, 1)])
    end
    sheet[current_row + anchor_row_offset, 1 + anchor_col_offset] = group_label
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row + anchor_row_offset, 1 + anchor_col_offset), XLSX.CellRef(current_row + anchor_row_offset, num_cols + col_offset + anchor_col_offset)))
    setAlignment(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; vertical = "top", horizontal = _excel_alignment_string(table_data.row_group_label_alignment), wrapText = true)
    atts = _excel_newpairs(_excel_tablestyle_atts("row_group_label",style.row_group_label))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; size=fontsize)
    end
    if  _excel_check_table_format("overline_group",table_format.overline_group)
        setBorder(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; top=table_format.underline_group_type)
    end
    if  _excel_check_table_format("underline_group",table_format.underline_group)
        setBorder(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; bottom=table_format.underline_group_type)
    end
    # don't include group labels in column width calculation
    row_height, _ = _excel_cell_length_and_height(group_label, fontsize)

    setRowHeight(sheet, current_row + anchor_row_offset; height = row_height)
    
end

"""
    _excel_write_row_number!(sheet, table_data, table_format, style, highlighters, excel_formatters, i, j, num_cols, col_offset, footnote_refs, max_row_lines, max_row_height, max_col_length, max_col_height, anchor_row_offset, anchor_col_offset, current_row)

Write a row number to the worksheet.
"""
function _excel_write_row_number!(sheet, table_data, table_format, style, i, max_row_height, anchor_row_offset, anchor_col_offset, current_row)
    sheet[current_row + anchor_row_offset, 1 + anchor_col_offset] = i
    atts = _excel_newpairs(_excel_tablestyle_atts("row_number",style.row_number))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize=_excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; size=fontsize)
    end
    if  _excel_check_table_format("vline_after_row_numbers",table_format.vline_after_row_numbers)
        setBorder(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; right=table_format.vline_after_row_numbers_type)
    end
    row_height, col_length = _excel_cell_length_and_height(i, fontsize)
    max_row_height = max(max_row_height, row_height)
#    max_col_length[1] = max(max_col_length[1], col_length)
    setAlignment(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; vertical = "top", horizontal = _excel_alignment_string(table_data.row_number_column_alignment))
    return max_row_height
end

"""
    _excel_write_row_label!(sheet, table_data, table_format, style, highlighters, excel_formatters, i, j, num_cols, col_offset, footnote_refs, max_row_lines, max_row_height, max_col_length, max_col_height, anchor_row_offset, anchor_col_offset, current_row)

Write a row label to the worksheet.
"""
function _excel_write_row_label(sheet, table_data, style, footnote_refs, i, row_label_col, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
    row_label_text = string(table_data.row_labels[i])
    # Check for footnote reference in row label
    if haskey(footnote_refs, (:row_label, i, 1))
        row_label_text = row_label_text * _excel_to_superscript(footnote_refs[(:row_label, i, 1)])
    end
    sheet[current_row + anchor_row_offset, row_label_col + anchor_col_offset] = row_label_text
    atts = _excel_newpairs(_excel_tablestyle_atts("row_label",style.row_label))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, row_label_col + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, row_label_col + anchor_col_offset; size=fontsize)
    end
    row_height, col_length = _excel_cell_length_and_height(row_label_text, fontsize)
    max_row_height = max(max_row_height, row_height)
    max_col_length[row_label_col] = max(max_col_length[row_label_col], col_length)
    setAlignment(sheet, current_row + anchor_row_offset, row_label_col + anchor_col_offset; vertical = "top", horizontal = _excel_alignment_string(table_data.row_label_column_alignment), wrapText = true)
end

"""
    _excel_write_cell!(sheet, table_data, table_format, style, highlighters, excel_formatters, i, j, num_cols, col_offset, footnote_refs, max_row_lines, max_row_height, max_col_length, max_col_height, anchor_row_offset, anchor_col_offset, current_row)

Write a single cell to the worksheet.
"""
function _excel_write_cell!(sheet, table_data, table_format, style, highlighters, excel_formatters, i, j, num_cols, col_offset, footnote_refs, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
    data = table_data.data
    cell_value = _get_cell_value(data, i, j, table_data)
    # Check for footnote reference in data cell
    if haskey(footnote_refs, (:data, i, j))
        cell_value = string(cell_value) * _excel_to_superscript(footnote_refs[(:data, i, j)])
    end

    #apply standard PrettyTables formatters
    formatted_value = cell_value
    if !isnothing(table_data.formatters)
        for formatter in table_data.formatters
            formatted_value = _excel_apply_formatter(formatted_value, formatter, current_row, j)
        end
    end
    sheet[current_row + anchor_row_offset, j + col_offset + anchor_col_offset] = formatted_value
    atts = _excel_newpairs(_excel_tablestyle_atts("table_cell_style",style.table_cell_style))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; size=fontsize)
    end
    row_height, col_length = _excel_cell_length_and_height(formatted_value, fontsize)
    max_row_height = max(max_row_height, row_height)
    max_col_length[j + col_offset] = max(max_col_length[j + col_offset], col_length)

    setAlignment(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; vertical = "top", horizontal = _excel_alignment_string(_excel_cell_alignment(table_data, i, j)))

    # Apply Excel specific (numFmt) formatters
    for formatter in excel_formatters
        atts = _excel_format_attributes(table_data, formatter, i, j)
        if !isnothing(atts)
            setFormat(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; atts...)
        end
    end

    # Apply Excel specific highlighters
    for highlighter in highlighters
        atts = _excel_font_attributes(table_data, highlighter, i, j)
        if !isnothing(atts)
            setFont(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; atts...)
            break
        end
    end
    if  _excel_check_table_format("vline_between_data_columns",table_format.vline_between_data_columns) && j < num_cols
        setBorder(sheet, current_row + anchor_row_offset, j+col_offset + anchor_col_offset; right=table_format.vline_between_data_columns_type)
    end
    return max_row_height
end

"""
    _excel_write_summary_row!(sheet, table_data, style, current_row, num_cols, col_offset)

Write a summary row to the worksheet.
"""
function _excel_write_summary_row(sheet, table_data, table_format, style, idx, summary_row_func, excel_formatters, num_cols, col_offset, footnote_refs, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
    # Write summary row label in the row label column
    row_label_col = table_data.show_row_number_column ? 2 : 1
    if table_data.summary_row_labels !== nothing && idx <= length(table_data.summary_row_labels)
        summary_label_text = string(table_data.summary_row_labels[idx])
        # Check for footnote reference in summary row label
        if haskey(footnote_refs, (:summary_row_label, idx, 1))
            summary_label_text = summary_label_text * _excel_to_superscript(footnote_refs[(:summary_row_label, idx, 1)])
        end
        sheet[current_row + anchor_row_offset, row_label_col + anchor_col_offset] = summary_label_text
        atts = _excel_newpairs(_excel_tablestyle_atts("summary_row_label",style.summary_row_label))
        fontsize=DEFAULT_FONT_SIZE
        if !isnothing(atts)
            fontsize = _excel_update_fontsize!(atts, fontsize)
            setFont(sheet, current_row + anchor_row_offset, row_label_col + anchor_col_offset; atts...)
        else
            setFont(sheet, current_row + anchor_row_offset, row_label_col + anchor_col_offset; size=fontsize)
        end
    end
    setAlignment(sheet, current_row + anchor_row_offset, col_offset + anchor_col_offset; vertical = "top", horizontal=_excel_alignment_string(table_data.row_label_column_alignment), wrapText = true)
    row_height, col_length = _excel_cell_length_and_height(summary_label_text, fontsize)
    max_row_height = max(max_row_height, row_height)
    max_col_length[col_offset] = max(max_col_length[col_offset], col_length)
   
    # Write summary row data - call the function for each column
    # Check if function takes 1 or 2 arguments
    num_args = length(first(methods(summary_row_func)).sig.parameters) - 1
    
    for j in 1:table_data.num_columns
        summary_value = if num_args == 2
            # Function signature: f(data, j)
            summary_row_func(table_data.data, j)
        else
            # Function signature: f(col)
            # Extract column data
            col_data = [_get_cell_value(table_data.data, i, j, table_data) for i in 1:table_data.num_rows]
            summary_row_func(col_data)
        end
        # Check for footnote reference in summary row cell
        if haskey(footnote_refs, (:summary_row, idx, j))
            summary_value = string(summary_value) * _excel_to_superscript(footnote_refs[(:summary_row, idx, j)])
        end
        sheet[current_row + anchor_row_offset, j + col_offset + anchor_col_offset] = summary_value
        atts = _excel_newpairs(_excel_tablestyle_atts("summary_row_cell",style.summary_row_cell))
        fontsize=DEFAULT_FONT_SIZE
        if !isnothing(atts)
            fontsize = _excel_update_fontsize!(atts, fontsize)
            setFont(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; atts...)
        else
            setFont(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; size=fontsize)
        end
        row_height, col_length = _excel_cell_length_and_height(summary_value, fontsize)
        max_row_height = max(max_row_height, row_height)
        max_col_length[j + col_offset] = max(max_col_length[j + col_offset], col_length)

        # apply formatters here too, but row is the Excel row number (current row), which is outside the rows in the data table.
        for formatter in excel_formatters
            atts = _excel_format_attributes(table_data, formatter, current_row, j)
            if !isnothing(atts)
                setFormat(sheet, current_row + anchor_row_offset, j + col_offset + anchor_col_offset; atts...)
            end
        end

        if  _excel_check_table_format("vline_between_data_columns",table_format.vline_between_data_columns) && j < num_cols
            setBorder(sheet, current_row + anchor_row_offset, j+col_offset + anchor_col_offset; right=table_format.vline_between_data_columns_type)
        end

    end
    setRowHeight(sheet, current_row + anchor_row_offset; height = max_row_height)

end

"""
    _excel_write_footnotes!(sheet, table_data, style, current_row, num_cols, col_offset)

Write the footnotes section to the worksheet.
"""
function _excel_write_footnotes!(sheet, table_data, style, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
    start_row = current_row
    atts = _excel_newpairs(_excel_tablestyle_atts("footnote",style.footnote))
    fontsize=DEFAULT_FONT_SIZE
    for (idx, (_, footnote_text)) in enumerate(table_data.footnotes)
        # Format as: ¹ Footnote text
        sheet[current_row + anchor_row_offset, 1 + anchor_col_offset] = _excel_to_superscript(idx) * " " * string(footnote_text)
        mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row + anchor_row_offset, 1 + anchor_col_offset), XLSX.CellRef(current_row + anchor_row_offset, num_cols + col_offset + anchor_col_offset)))
        footnote_lines = _excel_text_lines(footnote_text)
        if !isnothing(atts)
            fontsize = _excel_update_fontsize!(atts, fontsize)
            setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; atts...)
        else
            setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; size=fontsize)
        end
        setRowHeight(sheet, current_row + anchor_row_offset; height = _excel_row_height_for_text(footnote_lines, fontsize))
        current_row = current_row + 1
   end
    setUniformAlignment(sheet, start_row:current_row + anchor_row_offset-1, 1 + anchor_col_offset; vertical = "center", horizontal=_excel_alignment_string(table_data.footnote_alignment), wrapText = true)
    setUniformFont(sheet, start_row:current_row + anchor_row_offset-1, 1 + anchor_col_offset; atts...)
    return current_row
end

"""
    _write_excel_sourcenotes!(sheet, table_data, style, current_row, num_cols, col_offset)

Write the source notes section to the worksheet.
"""
function _write_excel_sourcenotes!(sheet, table_data, style, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
#    _excel_unempty_row(sheet, current_row + anchor_row_offset, 1:num_cols+col_offset) # ensure these cells aren't empty before merging
    sheet[current_row + anchor_row_offset, 1 + anchor_col_offset] = table_data.source_notes
    atts = _excel_newpairs(_excel_tablestyle_atts("source_note",style.source_note))
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_fontsize!(atts, fontsize)
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; atts...)
    else
        setFont(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; size=fontsize)
    end
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row + anchor_row_offset, 1 + anchor_col_offset), XLSX.CellRef(current_row + anchor_row_offset, num_cols + col_offset + anchor_col_offset)))
    setAlignment(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset; horizontal = _excel_alignment_string(table_data.source_note_alignment), wrapText=true)
    source_lines = _excel_text_lines(table_data.source_notes)
    setRowHeight(sheet, current_row + anchor_row_offset; height = _excel_row_height_for_text(source_lines, fontsize))
    return nothing
end
