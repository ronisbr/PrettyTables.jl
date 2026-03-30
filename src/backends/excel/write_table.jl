## Description #############################################################################
#
# Excel Back End: Write the table to an XLSX.Worksheet object.
#
############################################################################################

"""
    _write_excel_table!(sheet, table_data::TableData; kwargs)

Write the complete table to an Excel sheet, including all sections.
"""
function _write_excel_table!(sheet::XLSX.Worksheet, table_data::TableData;
    highlighters::Vector{ExcelHighlighter} = ExcelHighlighter[],
    excel_formatters::Vector{ExcelFormatter} = ExcelFormatter[],
    table_format::ExcelTableFormat = ExcelTableFormat(),
    style::ExcelTableStyle = ExcelTableStyle(),
    fill::ExcelTableFill = ExcelTableFill(),
    anchor_cell::String
)
    c = XLSX.CellRef(anchor_cell)
    anchor_row_offset = Int(c.row_number - 1)
    anchor_col_offset = Int(c.column_number - 1)
    num_rows = table_data.num_rows
    num_cols = table_data.num_columns

    # Calculate column offset (for row number column, row labels, and row groups)
    col_offset = 0
    if table_data.show_row_number_column
        col_offset += 1
    end
    if table_data.row_labels !== nothing || table_data.summary_row_labels !== nothing
        col_offset += 1
    end
    if table_data.row_group_labels !== nothing && col_offset == 0
        col_offset += 1
    end

    # Row height and column width applied at the end after all content is written to ensure 
    # correct auto-sizing based on content and highlighters.
    max_row_height = Dict{Int,Float64}() # to collect row heights. Unlike cols, number of rows isn't known.
    max_col_length = zeros(Float64, num_cols+col_offset) # to collect column widths, accumulated over rows
    
    current_row = 1
    
    # Build footnote reference map: (section, row, col) => footnote_number
    footnote_refs = Dict{Tuple{Symbol, Int, Int}, Int}()
    if table_data.footnotes !== nothing
        for (idx, (ref_tuple, _)) in enumerate(table_data.footnotes)
            footnote_refs[ref_tuple] = idx
        end
    end
    
    # Write title if present
    if !isempty(table_data.title)
        max_row_height[current_row] = _excel_write_title!(
            sheet, 
            table_data, 
            style, 
            fill, 
            footnote_refs, 
            current_row, 
            num_cols, 
            anchor_row_offset, 
            anchor_col_offset, 
            col_offset
        )
        current_row += 1
     end
    
    # Write subtitle if present
    if !isempty(table_data.subtitle)
        max_row_height[current_row] = _excel_write_subtitle!(
            sheet, 
            table_data, 
            style, 
            fill,
            footnote_refs, 
            current_row, 
            num_cols, 
            anchor_row_offset, 
            anchor_col_offset, 
            col_offset
        )
        current_row += 1
     end

    # only if any title/subtitle has been written    
    if current_row > 1
        _excel_unempty_row( # ensure these cells aren't empty before merging
            sheet, 
            current_row + anchor_row_offset, 
            1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset
        )

        # underline beneath title/subtitle block
        if _excel_check_table_format("underline_title", table_format.underline_title)
            XLSX.setBorder(
                sheet, 
                current_row + anchor_row_offset, 
                1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; 
                bottom = _excel_tableformat_atts(
                    "underline_title_type", 
                    table_format.underline_title_type
                )
            )
        end

        # Add blank line after title/subtitle
        current_row += 1
    end

    max_row_height[current_row] = 0.0

    # Write row number label if specified
    if table_data.show_row_number_column
        max_row_height[current_row] = _excel_write_row_number_column!(
            sheet, 
            table_data, 
            table_format, 
            style, 
            fill, 
            max_row_height[current_row], 
            max_col_length, 
            anchor_row_offset, 
            anchor_col_offset, 
            current_row
        )
    end

    # Write column labels if they should be shown
    if table_data.show_column_labels && !isempty(table_data.column_labels)
        # Build a map of merged cells if present
        merge_map = _excel_create_mergemap(table_data)
        
        for (label_row_idx, label_row) in enumerate(table_data.column_labels)
            _excel_unempty_row( # ensure these cells aren't EmptyCells before merging
                sheet, 
                current_row + anchor_row_offset, 
                (table_data.show_row_number_column ? 2 : 1) + 
                    anchor_col_offset:num_cols+col_offset + anchor_col_offset
            )

            # Write stubhead label if needed (only on first label row)
            if table_data.row_labels !== nothing
                if label_row_idx == 1 && !isempty(table_data.stubhead_label)
                    max_row_height[current_row] = _excel_write_stubhead_label!(
                        sheet, 
                        table_data, 
                        style, 
                        fill, 
                        col_offset, 
                        max_row_height[current_row], 
                        max_col_length, 
                        anchor_row_offset, 
                        anchor_col_offset, 
                        current_row
                    )
                end
            end
            
            # Write column labels, handling merged cells
            j = 1
            while j <= length(label_row)
                j, max_row_height[current_row] = _excel_write_column_labels!(
                    sheet, 
                    table_data, 
                    table_format, 
                    style, 
                    fill, 
                    footnote_refs, 
                    merge_map, 
                    label_row, 
                    label_row_idx, 
                    j, 
                    num_cols, 
                    col_offset, 
                    max_row_height[current_row], 
                    max_col_length, 
                    anchor_row_offset, 
                    anchor_col_offset, 
                    current_row
                )
            end

            XLSX.setRowHeight(
                sheet, 
                current_row + anchor_row_offset; 
                height = max_row_height[current_row]
            )
            
            current_row += 1
            max_row_height[current_row] = 0.0

        end

        # line under header block
        if _excel_check_table_format("underline_headers",table_format.underline_headers)
            XLSX.setBorder(
                sheet, 
                current_row + anchor_row_offset-1, 
                1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; 
                bottom = _excel_tableformat_atts(
                    "underline_headers_type", 
                    table_format.underline_headers_type
                )
            )
        end
    end
   
    # Write data rows (with row groups)

    # Create a mapping of row index to row group label
    row_group_map = Dict{Int, String}()
    if table_data.row_group_labels !== nothing
        for (row_idx, label) in table_data.row_group_labels
            row_group_map[row_idx] = label
        end
    end

    for i in 1:num_rows

        max_row_height[current_row] = 0.0

            # Check if this row starts a new group
        if haskey(row_group_map, i)
            max_row_height[current_row] = _excel_write_group_row!(
                sheet, 
                table_data, 
                table_format, 
                style, 
                fill,
                footnote_refs, 
                row_group_map, 
                i, 
                num_cols, 
                col_offset, 
                max_row_height[current_row], 
                anchor_row_offset, 
                anchor_col_offset, 
                current_row
            )
            current_row += 1
            max_row_height[current_row] = 0.0
        end
        
        # Now write the actual data row
        _excel_unempty_row( # ensure these cells aren't empty before merging
            sheet, 
            current_row + anchor_row_offset, 
            1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset
        )

        # Write row number if needed
        if table_data.show_row_number_column
            max_row_height[current_row] = _excel_write_row_number!(
                sheet, 
                table_data, 
                table_format, 
                style, 
                fill, 
                i, 
                max_row_height[current_row], 
                anchor_row_offset, 
                anchor_col_offset, 
                current_row
            )
        end
        
        # Write row label if present
        row_label_col =  table_data.show_row_number_column ? 2 : 1
        if table_data.row_labels !== nothing && i <= length(table_data.row_labels)
            max_row_height[current_row] = _excel_write_row_label(
                sheet, 
                table_data, 
                style, 
                fill, 
                footnote_refs, 
                i, 
                row_label_col, 
                max_row_height[current_row], 
                max_col_length, 
                anchor_row_offset, 
                anchor_col_offset, 
                current_row
            )
        end

       # Do before writing cell content and highlighting
        if _excel_check_table_format("underline_data_rows",table_format.underline_data_rows)
            XLSX.setBorder(
                sheet, 
                current_row + anchor_row_offset, 
                1 + anchor_col_offset:num_cols + col_offset + anchor_col_offset; 
                bottom = _excel_tableformat_atts(
                    "underline_data_rows_type", 
                    table_format.underline_data_rows_type
                )
            )
        end

        # Write data cells
        for j in 1:num_cols
            max_row_height[current_row] = _excel_write_cell!(
                sheet, 
                table_data, 
                table_format, 
                style, 
                fill, 
                excel_formatters, 
                i, 
                j, 
                num_cols, 
                col_offset, 
                footnote_refs, 
                max_row_height[current_row], 
                max_col_length, 
                anchor_row_offset, 
                anchor_col_offset, 
                current_row
            )
        end

        current_row += 1

    end

    if _excel_check_table_format("underline_table",table_format.underline_table)
        XLSX.setBorder(
            sheet, 
            current_row + anchor_row_offset - 1, 
            1 + anchor_col_offset:num_cols + col_offset + anchor_col_offset; 
            bottom = _excel_tableformat_atts(
                "underline_table_type", 
                table_format.underline_table_type
            )
        )
    end

    # Write summary rows if present
    if table_data.summary_rows !== nothing
        for (idx, summary_row_func) in enumerate(table_data.summary_rows)
            max_row_height[current_row] = 0.0 # for row height - reset each row
            _excel_unempty_row( # ensure these cells aren't empty before merging
                sheet, 
                current_row + anchor_row_offset, 
                1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset
            )
            max_row_height[current_row] = _excel_write_summary_row(
                sheet, 
                table_data, 
                table_format, 
                style, 
                fill, 
                idx, 
                summary_row_func, 
                excel_formatters, 
                num_cols, 
                col_offset, 
                footnote_refs, 
                max_row_height[current_row], 
                max_col_length, 
                anchor_row_offset, 
                anchor_col_offset, 
                current_row
            )
            if _excel_check_table_format(
                    "underline_summary_rows",
                    table_format.underline_summary_rows
                ) && idx < length(table_data.summary_rows)
                XLSX.setBorder(
                    sheet, 
                    current_row + anchor_row_offset, 
                    1 + anchor_col_offset:num_cols + col_offset + anchor_col_offset; 
                    bottom = _excel_tableformat_atts(
                        "underline_summary_rows_type", 
                        table_format.underline_summary_rows_type
                    )
                )
            end

            current_row += 1

        end

        if _excel_check_table_format("underline_summary",table_format.underline_summary)
            XLSX.setBorder(
                sheet, 
                current_row + anchor_row_offset-1, 
                1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; 
                bottom = _excel_tableformat_atts(
                    "underline_summary_type", 
                    table_format.underline_summary_type
                )
            )
        end
    end

    # Vertical line to right of row labels if required
    if table_data.row_labels !== nothing && _excel_check_table_format(
            "vline_after_row_labels", 
            table_format.vline_after_row_labels
        )
        start = (isempty(table_data.title) ? 0 : 1) + (isempty(table_data.subtitle) ? 0 : 1)
        start = (start == 0 ? 0 : start + 1) + anchor_row_offset + 1 # allow for extra line after title/subtitle
        XLSX.setBorder(
            sheet, 
            start:current_row + anchor_row_offset-1, 
            col_offset + anchor_col_offset + (isnothing(table_data.row_labels) ? 1 : 0); 
            right = _excel_tableformat_atts(
                "vline_after_row_labels_type", 
                table_format.vline_after_row_labels_type
            )
        )
    end

    # Write footnotes if present
    if table_data.footnotes !== nothing && !isempty(table_data.footnotes)
        _excel_unempty_row( # ensure these cells aren't empty before merging
            sheet, 
            current_row + anchor_row_offset, 
            1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset
            )
        current_row = _excel_write_footnotes!(
            sheet, 
            table_data, 
            table_format, 
            style, 
            fill, 
            current_row, 
            num_cols, 
            max_row_height, 
            anchor_row_offset, 
            anchor_col_offset, 
            col_offset
        )
     end
    
    # Write source notes if present
    if !isempty(table_data.source_notes)
        max_row_height[current_row] = 0.0 # reset for next row
        _excel_unempty_row( # ensure these cells aren't empty before merging
            sheet, 
            current_row + anchor_row_offset, 
            1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset
        )
        max_row_height[current_row] = _write_excel_sourcenotes!(
            sheet, 
            table_data, 
            style, 
            fill,
            current_row, 
            num_cols, 
            max_row_height[current_row], 
            anchor_row_offset, 
            anchor_col_offset, 
            col_offset
        )
        current_row += 1
    end
    
    if _excel_check_table_format("outside_border", table_format.outside_border)
        XLSX.setBorder(
            sheet, 
            1 + anchor_row_offset:current_row + anchor_row_offset - 1, 
            1 + anchor_col_offset:num_cols + col_offset + anchor_col_offset; 
            outside = _excel_tableformat_atts(
                "outside_border_type",
                table_format.outside_border_type
            )
        )
    end

    # Apply all the highlighters only after the table borders have been written to avoid overwriting highlighter borders.
    # This means that highlighter borders will be drawn on top of table format borders.
############################################################################################
    if num_rows > 0
        start_table_row = anchor_row_offset + 
            (isempty(table_data.title) ? 0 : 1) + 
                (isempty(table_data.subtitle) ? 0 : 1)
        start_table_row = (start_table_row == 0 ? 0 : start_table_row + 1) # allow for extra line after title/subtitle
        start_table_row = start_table_row + 
            (table_data.show_column_labels ? length(table_data.column_labels) : 0)
        for i in 1:num_rows
            if i in keys(row_group_map)
                start_table_row += 1 # allow for group row
            end
            for j in 1:num_cols
                for highlighter in highlighters
                    atts = _excel_highlighter_atts(table_data, highlighter, i, j)
                    if !isnothing(atts)
                        font_atts, fill_atts, border_atts = atts
                        if !isempty(font_atts)
                            # adjust row height and column width for font size changes from highlighters
                            font_size = _excel_getsize(font_atts) 
                            if !isnothing(font_size)
                                row_height, col_length = _excel_cell_length_and_height(
                                    _get_cell_value(table_data, i, j), font_size
                                )
                                max_row_height[start_table_row + i] = max(
                                    max_row_height[start_table_row + i], 
                                    row_height
                                )
                                max_col_length[j + col_offset] = max(
                                    max_col_length[j + col_offset], 
                                    col_length
                                )
                            end
                            XLSX.setFont(
                                sheet, 
                                start_table_row + i, 
                                j + col_offset + anchor_col_offset; 
                                font_atts...,
                            )
                        end
                        if !isempty(fill_atts)
                            XLSX.setFill(
                                sheet, 
                                start_table_row + i, 
                                j + col_offset + anchor_col_offset; 
                                fill_atts...,
                            )
                        end
                        if !isempty(border_atts)
                            XLSX.setBorder(
                                sheet, 
                                start_table_row + i, 
                                j + col_offset + anchor_col_offset; 
                                allsides = [border_atts...]
                            )
                        end
                        break
                    end
                end
            end
        end
    end

    # Set column widths after all content is written to ensure correct auto-width calculation.
    for i in 1:num_cols+col_offset
        col_width = _excel_get_col_width(table_format, i, max_col_length, col_offset)
        if col_width > 0.0
            XLSX.setColumnWidth(sheet, i + anchor_col_offset; width = col_width)
        end
    end

    # Set row heights after all content is written to ensure correct auto-height calculation.
    for (row, height) in max_row_height
        XLSX.setRowHeight(sheet, row + anchor_row_offset; height = height)
    end

    return nothing
end
