module PrettyTablesExcelExt

using PrettyTables
using XLSX

# Import the function we're overriding
import PrettyTables: _excel__print

# Import types we need
using PrettyTables: PrintingSpec, TableData, ColumnTable, RowTable

# Also import Tables.jl for handling table data
using Tables

"""
    _excel__print(pspec::PrintingSpec; kwargs...)

Implementation of Excel backend printing when XLSX.jl is loaded.

# Returns

- If `filename::String`: Writes to file and returns the filename.
- If `filename === nothing`: Returns an in-memory `XLSX.XLSXFile` object.
"""
function PrettyTables._excel__print(
    pspec::PrintingSpec;
    filename::Union{Nothing, String} = "prettytable.xlsx",
    sheet_name::String = "Sheet1",
    overwrite::Bool = true,
    kwargs...
)
    # Extract table data from PrintingSpec
    table_data = pspec.table_data
    
    if filename === nothing
        # Return in-memory XLSX object
        xf = newxlsx()
        sheet = xf[1]
        XLSX.rename!(sheet, sheet_name)
        _write_excel_table!(sheet, table_data)
        return xf
        
    else
        # Write to file
        if !overwrite && isfile(filename)
            error("File '$filename' already exists and overwrite=false")
        end
        
        XLSX.openxlsx(filename, mode="w") do xf
            sheet = xf[1]
            XLSX.rename!(sheet, sheet_name)
            _write_excel_table!(sheet, table_data)
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
wb = pretty_table(XLSX.XLSXFile, data; backend = :excel)

# Now you can manipulate the workbook further or write it yourself
XLSX.writexlsx("myfile.xlsx", wb)
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
    _write_excel_table!(sheet, table_data::TableData)

Write the complete table to an Excel sheet, including all sections.
"""
function _write_excel_table!(sheet, table_data::TableData)
    current_row = 1
    
    # Write title if present
    if !isempty(table_data.title)
        sheet[current_row, 1] = table_data.title
        current_row += 1
    end
    
    # Write subtitle if present
    if !isempty(table_data.subtitle)
        sheet[current_row, 1] = table_data.subtitle
        current_row += 1
    end
    
    # Add blank line after title/subtitle
    if current_row > 1
        current_row += 1
    end
    
    # Calculate column offset (for row number column, row labels, and row groups)
    col_offset = 0
    if table_data.show_row_number_column
        col_offset += 1
    end
    if table_data.row_labels !== nothing || table_data.row_group_labels !== nothing
        col_offset += 1
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
            if col_offset > 0 && label_row_idx == 1 && !isempty(table_data.stubhead_label)
                sheet[current_row, 1] = table_data.stubhead_label
            end
            
            # Write column labels, handling merged cells
            j = 1
            while j <= length(label_row)
                # Check if this cell is the start of a merge
                if haskey(merge_map, (label_row_idx, j))
                    span, merge_data = merge_map[(label_row_idx, j)]
                    # Write the merged label to the first column of the merge range
                    sheet[current_row, j + col_offset] = string(merge_data)
                    # Skip the spanned columns
                    j += span
                else
                    # Regular label
                    sheet[current_row, j + col_offset] = string(label_row[j])
                    j += 1
                end
            end
            current_row += 1
        end
    end
    
    # Write data rows (with row groups)
    data = table_data.data
    num_rows = table_data.num_rows
    num_cols = table_data.num_columns
    
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
            sheet[current_row, 1] = group_label
            current_row += 1
        end
        
        # Now write the actual data row
        # Write row number if needed
        if table_data.show_row_number_column
            sheet[current_row, 1] = i
        end
        
        # Write row label if present
        row_label_col = table_data.show_row_number_column ? 2 : 1
        if table_data.row_labels !== nothing && i <= length(table_data.row_labels)
            sheet[current_row, row_label_col] = string(table_data.row_labels[i])
        end
        
        # Write data cells
        for j in 1:num_cols
            cell_value = _get_cell_value(data, i, j, table_data)
            sheet[current_row, j + col_offset] = cell_value
        end
        
        current_row += 1
    end
    
    # Write summary rows if present
    if table_data.summary_rows !== nothing
        current_row += 1  # Blank line before summary
        for (idx, summary_row_func) in enumerate(table_data.summary_rows)
            # Write summary row label in the row label column
            row_label_col = table_data.show_row_number_column ? 2 : 1
            if table_data.summary_row_labels !== nothing && idx <= length(table_data.summary_row_labels)
                sheet[current_row, row_label_col] = string(table_data.summary_row_labels[idx])
            end
            
            # Write summary row data - call the function for each column
            for j in 1:table_data.num_columns
                # summary_row_func is a function with signature (data, column_index)
                summary_value = summary_row_func(table_data.data, j)
                sheet[current_row, j + col_offset] = summary_value
            end
            current_row += 1
        end
    end
    
    # Write footnotes if present
    if table_data.footnotes !== nothing && !isempty(table_data.footnotes)
        current_row += 1  # Blank line before footnotes
        for footnote in table_data.footnotes
            sheet[current_row, 1] = string(last(footnote))
            current_row += 1
        end
    end
    
    # Write source notes if present
    if !isempty(table_data.source_notes)
        current_row += 1  # Blank line before source notes
        sheet[current_row, 1] = table_data.source_notes
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

end # module