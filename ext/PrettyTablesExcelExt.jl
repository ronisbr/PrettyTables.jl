module PrettyTablesExcelExt

using PrettyTables
using XLSX

# Import the function we're overriding
import PrettyTables: _excel__print

# Import types we need
using PrettyTables: PrintingSpec, TableData, ColumnTable, RowTable

# Also import Tables.jl for handling table data
using Tables

include("../src/backends/excel/helpers.jl")
#include("../src/backends/excel/types.jl")


"""
    _excel__print(pspec::PrintingSpec; kwargs...)

Implementation of Excel backend printing when XLSX.jl is loaded.

# Returns

- If `filename::String`: Writes to file and returns the filename.
- If `filename === nothing`: Returns an in-memory `XLSX.XLSXFile` object.
"""
function PrettyTables._excel__print(
    pspec::PrintingSpec;
    filename::Union{Nothing, String} = nothing,
    sheet_name::String = "Sheet1",
    overwrite::Bool = true,
    kwargs...
)
    # Extract table data from PrintingSpec
    table_data = pspec.table_data
    println(kwargs)

    if filename === nothing
        # Return in-memory XLSX object
        xf = newxlsx()
        sheet = xf[1]
        XLSX.rename!(sheet, sheet_name)
        _write_excel_table!(sheet, table_data; kwargs...)
        return xf
        
    else
        # Write to file
        if !overwrite && isfile(filename)
            error("File '$filename' already exists and overwrite=false")
        end
        
        XLSX.openxlsx(filename, mode="w") do xf
            sheet = xf[1]
            XLSX.rename!(sheet, sheet_name)
            _write_excel_table!(sheet, table_data; kwargs...)
        end
        
        # Print confirmation if appropriate
        if pspec.context.io === stdout || (pspec.context.io isa IOContext && pspec.context.io.io === stdout)
            println("Excel file written to: $filename")
        end
        
        return filename
    end
end

"""
    pretty_table(::Type{XLSX.XLSXFile}, data; kwargs...)

Convenience method to get an in-memory XLSX workbook object.

# Examples

```julia
using PrettyTables, XLSX

data = [1 2 3; 4 5 6]
xf = pretty_table(XLSX.XLSXFile, data; backend = :excel)

# Now you can manipulate the workbook further or save it to file yourself
XLSX.writexlsx("myfile.xlsx", xf)
```
"""
function PrettyTables.pretty_table(::Type{XLSX.XLSXFile}, @nospecialize(data::Any); kwargs...)
    # Force backend to :excel and filename to nothing
    if !haskey(kwargs, :backend)
        return pretty_table(String, data; backend = :excel, filename = nothing, kwargs...)
    else
        return pretty_table(String, data; filename = nothing, kwargs...)
    end
end

"""
    _write_excel_table!(sheet, table_data::TableData; kwargs)

Write the complete table to an Excel sheet, including all sections.
"""
function _write_excel_table!(sheet, table_data::TableData;
    highlighters::Vector{ExcelHighlighter}=[],
    excel_formatters::Vector{ExcelFormatter}=[],
    table_format::ExcelTableFormat,
    style::ExcelTableStyle
)
    data = table_data.data
    num_rows = table_data.num_rows
    num_cols = table_data.num_columns

    # Calculate column offset (for row number column, row labels, and row groups)
    col_offset = 0
    if table_data.show_row_number_column || table_data.row_group_labels !== nothing
        col_offset += 1
    end
    if table_data.row_labels !== nothing
        col_offset += 1
    end
    

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
        _excel_write_title!(sheet, table_data, style, footnote_refs, current_row, num_cols, col_offset)
        current_row += 1
    end
    
    # Write subtitle if present
    if !isempty(table_data.subtitle)
        _excel_write_subtitle!(sheet, table_data, style, footnote_refs, current_row, num_cols, col_offset)
        current_row += 1
    end
    
    # Add blank line after title/subtitle
    if current_row > 1
        current_row += 1
    end
    
    max_row_height = 0 # for row height - reset each row
    max_row_lines = 0 # for row height - reset each row
    max_col_height = zeros(Int, num_cols+col_offset) # for column width, accumulated over rows
    max_col_length = zeros(Int, num_cols+col_offset) # for column width, accumulated over rows

    # Write row number label if specified
    if table_data.show_row_number_column
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
            max_col_height[1] = max(max_col_height[1], fontsize)
            max_row_height = max(max_row_height, fontsize)
        end
    end

    # Write column labels if they should be shown
    if table_data.show_column_labels && !isempty(table_data.column_labels)
        # Build a map of merged cells if present
        merge_map = Dict{Tuple{Int, Int}, Tuple{Int, Any}}()  # (row, col) => (span, data)
        if table_data.merge_column_label_cells !== nothing
            for merge_cell in table_data.merge_column_label_cells
                # merge_cell has fields: i (row), j (column), column_span, data
                merge_map[(merge_cell.i, merge_cell.j)] = (merge_cell.column_span, merge_cell.data)
            end
        end
        
        for (label_row_idx, label_row) in enumerate(table_data.column_labels)
            # Write stubhead label if needed (only on first label row)
            if table_data.row_labels !== nothing
                if label_row_idx == 1 && !isempty(table_data.stubhead_label)
                    stubhead_label = table_data.stubhead_label
                    sheet[current_row, col_offset] = stubhead_label
                    atts = _excel_newpairs(style.stubhead_label)
                    fontsize=DEFAULT_FONT_SIZE
                    if !isnothing(atts)
                        fontsize = _excel_update_atts!(atts, fontsize)
                        setFont(sheet, current_row, col_offset; atts...)
                    else
                        setFont(sheet, current_row, col_offset; size=fontsize)
                    end
                    max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, col_offset, stubhead_label, fontsize)
                end
            end
            
            # Write column labels, handling merged cells
            j = 1
            while j <= length(label_row)
                cla = _excel_column_alignment(j, table_data.column_label_alignment, table_data.data_alignment) # get the column label alignment
                # Check if this cell is the start of a merge
                if haskey(merge_map, (label_row_idx, j))
                    span, merge_data = merge_map[(label_row_idx, j)]
                    label_text = string(merge_data)
                    # Check for footnote reference
                    if haskey(footnote_refs, (:column_label, label_row_idx, j))
                        label_text = label_text * _excel_to_superscript(footnote_refs[(:column_label, label_row_idx, j)])
                    end
                    sheet[current_row, j + col_offset] = label_text
                    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, j + col_offset), XLSX.CellRef(current_row, j + col_offset + span-1)))
                    atts = _excel_newpairs(style.column_label)
                    fontsize=DEFAULT_FONT_SIZE
                    if !isnothing(atts)
                        fontsize = _excel_update_atts!(atts, fontsize)
                        setFont(sheet, current_row, j+ col_offset; atts...)
                    else
                        setFont(sheet, current_row, j+ col_offset; size=fontsize)
                    end
                    # don't include merged columns in column width calculation
                    max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, nothing, nothing, nothing, label_text, fontsize)
                    setAlignment(sheet, current_row, j + col_offset; vertical = "top", horizontal=cla, wrapText = true)
                    # Skip the spanned columns
                    j += span
                else
                    # Regular label
                    label_text = string(label_row[j])
                    # Check for footnote reference
                    if haskey(footnote_refs, (:column_label, label_row_idx, j))
                        label_text = label_text * _excel_to_superscript(footnote_refs[(:column_label, label_row_idx, j)])
                    end
                    sheet[current_row, j + col_offset] = label_text
                    atts = _excel_newpairs(style.column_label)
                    fontsize=DEFAULT_FONT_SIZE
                    if !isnothing(atts)
                        fontsize = _excel_update_atts!(atts, fontsize)
                        setFont(sheet, current_row, j+ col_offset; atts...)
                    else
                        setFont(sheet, current_row, j+ col_offset; size=fontsize)
                    end
                    max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, j + col_offset, label_text, fontsize)
                    setAlignment(sheet, current_row, j + col_offset; vertical = "top", horizontal=cla, wrapText = true)
                   j += 1
                end
            end
            setRowHeight(sheet, current_row; height = _excel_row_height_for_text(max_row_lines, max_row_height))
            
            max_row_height = 0 # for row height - reset each row
            max_row_lines = 0 # for row height - reset each row

            current_row += 1
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
        # Check if this row starts a new group
        if haskey(row_group_map, i)
            # Write row group label in its own row in the row number column (column 1)
            group_label = row_group_map[i]
            # Check for footnote reference in row group label
            if haskey(footnote_refs, (:row_group_label, i, 1))
                group_label = string(group_label) * _excel_to_superscript(footnote_refs[(:row_group_label, i, 1)])
            end
            sheet[current_row, 1] = group_label
            mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, 1), XLSX.CellRef(current_row, num_cols + col_offset)))
            setAlignment(sheet, current_row, 1; vertical = "top", horizontal = _excel_alignment_string(table_data.row_group_label_alignment), wrapText = true)
            atts = _excel_newpairs(style.row_group_label)
            fontsize=DEFAULT_FONT_SIZE
            if !isnothing(atts)
                fontsize = _excel_update_atts!(atts, fontsize)
                setFont(sheet, current_row, 1; atts...)
            else
                setFont(sheet, current_row, 1; size=fontsize)
            end
            # don't include group labels in column width calculation
            max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, nothing, nothing, nothing, group_label, fontsize)

            setRowHeight(sheet, current_row; height = _excel_row_height_for_text(max_row_lines, max_row_height))
            
            max_row_height = 0 # for row height - reset each row
            max_row_lines = 0 # for row height - reset each row

            current_row += 1
        end
        
        # Now write the actual data row
        # Write row number if needed
        if table_data.show_row_number_column
            sheet[current_row, 1] = i
            atts = _excel_newpairs(style.row_number)
            fontsize=DEFAULT_FONT_SIZE
            if !isnothing(atts)
                fontsize=_excel_update_atts!(atts, fontsize)
                setFont(sheet, current_row, 1; atts...)
            else
                setFont(sheet, current_row, 1; size=fontsize)
            end
            max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, 1, string(i), fontsize)
             setAlignment(sheet, current_row, 1; vertical = "top", horizontal = _excel_alignment_string(table_data.row_number_column_alignment))
         end
        
        # Write row label if present
        row_label_col = table_data.show_row_number_column ? 2 : 1
        if table_data.row_labels !== nothing && i <= length(table_data.row_labels)
            row_label_text = string(table_data.row_labels[i])
            # Check for footnote reference in row label
            if haskey(footnote_refs, (:row_label, i, 1))
                row_label_text = row_label_text * _excel_to_superscript(footnote_refs[(:row_label, i, 1)])
            end
            sheet[current_row, row_label_col] = row_label_text
             atts = _excel_newpairs(style.row_label)
            fontsize=DEFAULT_FONT_SIZE
            if !isnothing(atts)
                fontsize = _excel_update_atts!(atts, fontsize)
                setFont(sheet, current_row, row_label_col; atts...)
            else
                setFont(sheet, current_row, row_label_col; size=fontsize)
            end
            max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, row_label_col, row_label_text, fontsize)
            setAlignment(sheet, current_row, row_label_col; vertical = "top", horizontal = _excel_alignment_string(table_data.row_label_column_alignment), wrapText = true)
        end
        
        # Write data cells
        for j in 1:num_cols
            cell_value = _get_cell_value(data, i, j, table_data)
            # Check for footnote reference in data cell
            if haskey(footnote_refs, (:data, i, j))
                cell_value = string(cell_value) * _excel_to_superscript(footnote_refs[(:data, i, j)])
            end
            sheet[current_row, j + col_offset] = cell_value
            atts = _excel_newpairs(style.row_label)
            fontsize=DEFAULT_FONT_SIZE
            if !isnothing(atts)
                fontsize = _excel_update_atts!(atts, fontsize)
                setFont(sheet, current_row, row_label_col; atts...)
            else
                setFont(sheet, current_row, row_label_col; size=fontsize)
            end

            if cell_value isa String # can't get width of numbers because they are affected by formatting.
                max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, row_label_col, row_label_text, fontsize)
            end
            max_col_height[row_label_col] = max(max_col_height[row_label_col], fontsize)
            max_row_height = max(max_row_height, fontsize)

            setAlignment(sheet, current_row, j + col_offset; vertical = "top", horizontal = _excel_alignment_string(_excel_cell_alignment(table_data, i, j)))

            for formatter in excel_formatters
                atts = _excel_format_attributes(table_data, formatter, i, j)
                if !isnothing(atts)
                    setFormat(sheet, current_row, j + col_offset; atts...)
                end
            end
            for highlighter in highlighters
                atts = _excel_font_attributes(table_data, highlighter, i, j)
                if !isnothing(atts)
                    setFont(sheet, current_row, j + col_offset; atts...)
                    break
                end
            end
        end

        setRowHeight(sheet, current_row; height = _excel_row_height_for_text(max_row_lines, max_row_height))
        
        max_row_height = 0 # for row height - reset each row
        max_row_lines = 0 # for row height - reset each row
        
        current_row += 1
    end
    
    # Write summary rows if present
    if table_data.summary_rows !== nothing
        current_row += 1  # Blank line before summary
        for (idx, summary_row_func) in enumerate(table_data.summary_rows)
            # Write summary row label in the row label column
            row_label_col = table_data.show_row_number_column ? 2 : 1
            if table_data.summary_row_labels !== nothing && idx <= length(table_data.summary_row_labels)
                summary_label_text = string(table_data.summary_row_labels[idx])
                # Check for footnote reference in summary row label
                if haskey(footnote_refs, (:summary_row_label, idx, 1))
                    summary_label_text = summary_label_text * _excel_to_superscript(footnote_refs[(:summary_row_label, idx, 1)])
                end
                sheet[current_row, row_label_col] = summary_label_text
                atts = _excel_newpairs(style.summary_row_label)
                fontsize=DEFAULT_FONT_SIZE
                if !isnothing(atts)
                    fontsize = _excel_update_atts!(atts, fontsize)
                    setFont(sheet, current_row, row_label_col; atts...)
                else
                    setFont(sheet, current_row, row_label_col; size=fontsize)
                end
            end
            max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, row_label_col, summary_label_text, fontsize)
            
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
                sheet[current_row, j + col_offset] = summary_value
                atts = _excel_newpairs(style.summary_row_cell)
                fontsize=DEFAULT_FONT_SIZE
                if !isnothing(atts)
                    fontsize = _excel_update_atts!(atts, fontsize)
                    setFont(sheet, current_row, j + col_offset; atts...)
                else
                    setFont(sheet, current_row, j + col_offset; size=fontsize)
                end
                if summary_value isa String # can't get width of numbers because they are affected by formatting.
                    max_row_lines, max_row_height = _excel_update_length_and_height!(max_row_lines, max_row_height, max_col_length, max_col_height, j + col_offset, summary_value, fontsize)
                end
                max_col_height[j + col_offset] = max(max_col_height[j + col_offset], fontsize)
                max_row_height = max(max_row_height, fontsize)

                # apply formatters here too, but row is the Excel row number (current row), which is outside the rows in the data table.
                for formatter in excel_formatters
                    atts = _excel_format_attributes(table_data, formatter, current_row, j)
                    if !isnothing(atts)
                        setFormat(sheet, current_row, j + col_offset; atts...)
                    end
                end

            end
            setRowHeight(sheet, current_row; height = _excel_row_height_for_text(max_row_lines, max_row_height))
            
            max_row_height = 0 # for row height - reset each row
            max_row_lines = 0 # for row height - reset each row
        
            current_row += 1
        end
    end
    
    # Write footnotes if present
    if table_data.footnotes !== nothing && !isempty(table_data.footnotes)
        current_row += 1 # Blank line before footnotes
        _excel_write_footnotes!(sheet, table_data, style, current_row, num_cols, col_offset)
        current_row += 1  # Blank line after footnotes
     end
    
    # Write source notes if present
    if !isempty(table_data.source_notes)
        current_row += 1  # Blank line before source notes
        _write_excel_sourcenotes!(sheet, table_data, style, current_row, num_cols, col_offset)
    end
    
    for i in 1:num_cols+col_offset
        if max_col_length[i] > 0
            setColumnWidth(sheet, i; width = _excel_column_width_for_text(max_col_length[i], max_col_height[i]))
        end
    end

    return nothing
end

"""
    _get_cell_value(data, i, j, table_data::TableData)

Get the value of a cell from the data structure, handling different data types.
"""
function _get_cell_value(data, i, j, table_data::TableData)
    # Adjust indices based on the data structure's first indices
    row_idx = i + table_data.first_row_index - 1
    col_idx = j + table_data.first_column_index - 1
    
    try
        if data isa ColumnTable
            # For ColumnTable, access via column name
            col_name = data.column_names[col_idx]
            col_data = Tables.getcolumn(data.table, col_name)
            return col_data[row_idx]
        elseif data isa RowTable
            # For RowTable, iterate to the right row
            rows = collect(Tables.rows(data.table))
            row = rows[row_idx]
            col_name = data.column_names[col_idx]
            return Tables.getcolumn(row, col_name)
        else
            # For regular arrays and matrices
            return data[row_idx, col_idx]
        end
    catch e
        # If there's an error accessing the data, return empty string
        return ""
    end
end

"""
    _excel_write_title!(sheet, table_data, current_row, num_cols, col_offset)

Write the table title to the worksheet.
"""
function _excel_write_title!(sheet, table_data, style, footnote_refs, current_row, num_cols, col_offset)
    title_text = table_data.title
    # Check for footnote reference in title
    if haskey(footnote_refs, (:title, 1, 1))
        title_text = title_text * _excel_to_superscript(footnote_refs[(:title, 1, 1)])
    end
    sheet[current_row, 1:(num_cols + col_offset)]="" # ensure these cells aren't empty before merging
    sheet[current_row, 1] = title_text
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, 1), XLSX.CellRef(current_row, num_cols + col_offset)))
    atts = _excel_newpairs(style.title)
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_atts!(atts, fontsize)
        setFont(sheet, current_row, 1; atts...)
    else
        setFont(sheet, current_row, 1; size=fontsize)
    end
    setAlignment(sheet, current_row, 1; vertical = "center", horizontal=_excel_alignment_string(table_data.title_alignment), wrapText = true)
    title_lines = _excel_text_lines(title_text)
    setRowHeight(sheet, current_row; height = _excel_row_height_for_text(title_lines, fontsize))
end

"""
    _excel_write_subtitle!(sheet, table_data, current_row, num_cols, col_offset)

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
        fontsize = _excel_update_atts!(atts, fontsize)
        setFont(sheet, current_row, 1; atts...)
    else
        setFont(sheet, current_row, 1; size=fontsize)
   end
    setAlignment(sheet, current_row, 1; vertical = "center", horizontal=_excel_alignment_string(table_data.subtitle_alignment), wrapText = true)
    subtitle_lines = _excel_text_lines(subtitle_text)
    setRowHeight(sheet, current_row; height = _excel_row_height_for_text(subtitle_lines, fontsize))
end


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
            fontsize = _excel_update_atts!(atts, fontsize)
            setFont(sheet, current_row, 1; atts...)
        else
            setFont(sheet, current_row, 1; size=fontsize)
        end
        setRowHeight(sheet, current_row; height = _excel_row_height_for_text(footnote_lines, fontsize))
        current_row = current_row + 1
   end
    setUniformAlignment(sheet, start_row:current_row-1, 1; vertical = "center", horizontal=_excel_alignment_string(table_data.footnote_alignment), wrapText = true)
    setUniformFont(sheet, start_row:current_row-1, 1; atts...)
end

function _write_excel_sourcenotes!(sheet, table_data, style, current_row, num_cols, col_offset)
    sheet[current_row, 1] = table_data.source_notes
    atts = _excel_newpairs(style.source_note)
    fontsize=DEFAULT_FONT_SIZE
    if !isnothing(atts)
        fontsize = _excel_update_atts!(atts, fontsize)
        setFont(sheet, current_row, 1; atts...)
    else
        setFont(sheet, current_row, 1; size=fontsize)
    end
    mergeCells(sheet, XLSX.CellRange(XLSX.CellRef(current_row, 1), XLSX.CellRef(current_row, num_cols + col_offset)))
    setAlignment(sheet, current_row, 1; horizontal = _excel_alignment_string(table_data.source_note_alignment), wrapText=true)
    source_lines = _excel_text_lines(table_data.source_notes)
    setRowHeight(sheet, current_row; height = _excel_row_height_for_text(source_lines, fontsize))
end

end # module