module PrettyTablesExcelExt

using PrettyTables
using XLSX

# Import the functions we're overriding
import PrettyTables: _excel__print, fmt__excel_stringify

# Import types we need
using PrettyTables: PrintingSpec, TableData, ColumnTable, RowTable

# Also import Tables.jl for handling table data
using Tables

include("../src/backends/excel/helpers.jl")
include("../src/backends/excel/table_sections.jl")
#include("../src/backends/excel/types.jl")

"""
    _excel__print(pspec::PrintingSpec; kwargs...)

Implementation of Excel backend printing when XLSX.jl is loaded.

# Returns

- If `filename === nothing`: Returns an in-memory `XLSX.XLSXFile` object.
- If `filename::String` and `mode=\"w\"`: Writes to a new file and returns the filename.
- If `filename::String` and `mode=\"rw\"`: Reads an existing file, updates and returns the in-memory `XLSX.XLSXFile` object

# Keywords

- `filename` : the name of the file or `nothing`. (Default: `nothing`)
- `sheet-name` : the name of the worksheet to write to, which will be created or renamed if necessary. (Default: `prettytable`).
- `mode` : Determines whether a new file is created (`mode = \"w\"`) or an existing file is updated (`mode = \"rw\"`). (Default: \"w\")
- `overwrite` : Forces a newly created file to overwrite any existing file of the same name if `true`. (Default: `false`)
- `anchor_cell` : Defines the location of the top left corner of the table in the worksheet. (Default = \"A1\")

Save a returned XLSX.XLSXFile using `XLSX.writexlsx`.

"""
function PrettyTables._excel__print(
    pspec::PrintingSpec;
    filename::Union{Nothing, String} = nothing,
    sheet_name::String = "prettytable", # this minimises risk of accidentally overwriting data if `mode=\"rw\"`.
    mode::String = "w",
    overwrite::Bool = false,
    anchor_cell::String = "A1",
    kwargs...
)
    # Extract table data from PrintingSpec
    table_data = pspec.table_data

    if filename === nothing
        # Return in-memory XLSX object
        xf = newxlsx()
        sheet = xf[1]
        sheet_name == sheet.name || XLSX.renamesheet!(sheet, sheet_name)
        _write_excel_table!(sheet, table_data; anchor_cell, kwargs...)
        return xf
        
    else
        if mode ∉ ["w", "rw"]
            throw(ArgumentError("Invalid mode \"$mode\". \nMust be either \"w\" to create a new file or \"rw\" to add a PrettyTable to an existing spreadsheet."))
        end

        if mode == "w" # Write the PrettyTable to a new `xlsx` file.

            if !overwrite && isfile(filename)
                error("File '$filename' already exists and overwrite=false")
            end
            
            XLSX.openxlsx(filename, mode="w") do xf
                sheet = xf[1]
                sheet_name == sheet.name || XLSX.renamesheet!(sheet, sheet_name)
                _write_excel_table!(sheet, table_data; anchor_cell, kwargs...)
                return filename
            end

        elseif mode == "rw" # Open an existing `xlsx` file and write a PrettyTable to it. Return in-memory XLSX object.
            xf = XLSX.opentemplate(filename)
            XLSX.hassheet(xf, sheet_name) || XLSX.addsheet!(xf, sheet_name)
            sheet = xf[sheet_name]
            _write_excel_table!(sheet, table_data; anchor_cell, kwargs...)
            return xf # returning xf forces the user to save using XLSX.writexlsx, reducing the risk of accidentally overwriting data.

        else
            println("Unreachable reached!")
            error()
        end
        
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
    highlighters::Vector{ExcelHighlighter}=ExcelHighlighter[],
    excel_formatters::Vector{ExcelFormatter}=ExcelFormatter[],
    table_format::ExcelTableFormat=ExcelTableFormat(),
    style::ExcelTableStyle=ExcelTableStyle(),
    anchor_cell::String
)
    c=XLSX.CellRef(anchor_cell)
    anchor_row_offset = Int(c.row_number - 1)
    anchor_col_offset = Int(c.column_number - 1)
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
        _excel_write_title!(sheet, table_data, style, footnote_refs, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
        current_row += 1
    end
    
    # Write subtitle if present
    if !isempty(table_data.subtitle)
        _excel_write_subtitle!(sheet, table_data, style, footnote_refs, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
        current_row += 1
    end

    # only if any title/subtitle has been written    
    if current_row > 1
        _excel_unempty_row(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset) # ensure these cells aren't empty before merging

        # underline beneath title/subtitle block
        if _excel_check_table_format("underline_title", table_format.underline_title)
            setBorder(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; bottom=_excel_tableformat_atts("underline_title_type", table_format.underline_title_type))
        end

        # Add blank line after title/subtitle
        current_row += 1
    end

    max_row_height = 0.0 # for row height - reset each row
    max_col_length = zeros(Float64, num_cols+col_offset) # for column width, accumulated over rows

    # Write row number label if specified
    if table_data.show_row_number_column
        max_row_height = _excel_write_row_number_column!(sheet, table_data, table_format, style, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
    end

    # Write column labels if they should be shown
    if table_data.show_column_labels && !isempty(table_data.column_labels)
        # Build a map of merged cells if present
        merge_map = _excel_create_mergemap(table_data)
        
        for (label_row_idx, label_row) in enumerate(table_data.column_labels)
            _excel_unempty_row(sheet, current_row + anchor_row_offset, (table_data.show_row_number_column ? 2 : 1) + anchor_col_offset:num_cols+col_offset + anchor_col_offset) # ensure these cells aren't empty before merging

            # Write stubhead label if needed (only on first label row)
            if table_data.row_labels !== nothing
                if label_row_idx == 1 && !isempty(table_data.stubhead_label)
                    max_row_height = _excel_write_stubhead_label!(sheet, table_data, style, col_offset, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
                end
            end
            
            # Write column labels, handling merged cells
            j = 1
            while j <= length(label_row)
                j, max_row_height = _excel_write_column_labels!(sheet, table_data, table_format, style, footnote_refs, merge_map, label_row, label_row_idx, j, num_cols, col_offset, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
            end
            setRowHeight(sheet, current_row + anchor_row_offset; height = max_row_height)
            
            max_row_height = 0 # for row height - reset each row
 
            current_row += 1
        end
        # line under header block
        if _excel_check_table_format("underline_headers",table_format.underline_headers)
            setBorder(sheet, current_row + anchor_row_offset-1, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; bottom=_excel_tableformat_atts("underline_headers_type", table_format.underline_headers_type))
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
            _excel_write_group_row!(sheet, table_data, table_format, style, footnote_refs, row_group_map, i, num_cols, col_offset, anchor_row_offset, anchor_col_offset, current_row)

            max_row_height = 0 # for row height - reset each row

            # Annoyingly, now need to reapply highlighters in bottom row of each group, in case any of the highlighters sets cell borders that have been overwritten
            if i > 1
                for j in 1:num_cols
                    for highlighter in highlighters
                        atts = _excel_highlighter_atts(table_data, highlighter, i-1, j)
                        if !isnothing(atts)
                            _, _, border_atts = atts
                            if !isempty(border_atts)
                                setBorder(sheet, current_row + anchor_row_offset - 1, j + col_offset + anchor_col_offset; allsides = [border_atts...])
                            end
                            break
                        end
                    end
                end
            end

            current_row += 1
        end
        
        # Now write the actual data row
        # Write row number if needed
        if table_data.show_row_number_column
            max_row_height = _excel_write_row_number!(sheet, table_data, table_format, style, i, max_row_height, anchor_row_offset, anchor_col_offset, current_row)
        end
        
        # Write row label if present
        row_label_col =  table_data.show_row_number_column ? 2 : 1
        if table_data.row_labels !== nothing && i <= length(table_data.row_labels)
            max_row_height = _excel_write_row_label(sheet, table_data, style, footnote_refs, i, row_label_col, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
        end

       # Do before writing cell content and highlighting
        if _excel_check_table_format("underline_data_rows",table_format.underline_data_rows)
            setBorder(sheet, current_row + anchor_row_offset, col_offset + anchor_col_offset:num_cols + col_offset + anchor_col_offset; bottom=_excel_tableformat_atts("underline_data_rows_type", table_format.underline_data_rows_type))
        end

        # Write data cells
        for j in 1:num_cols
            max_row_height = _excel_write_cell!(sheet, table_data, table_format, style, highlighters, excel_formatters, i, j, num_cols, col_offset, footnote_refs, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
        end
        setRowHeight(sheet, current_row + anchor_row_offset; height = max_row_height)
        max_row_height = 0 # for row height - reset each row
        
        current_row += 1
    end

    if _excel_check_table_format("underline_table",table_format.underline_table)
        setBorder(sheet, current_row + anchor_row_offset-1, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; bottom=_excel_tableformat_atts("underline_table_type", table_format.underline_table_type))
    end

    # Annoyingly, now need to reapply highlighters in bottom row of table, in case any of the highlighters sets cell borders
    for j in 1:num_cols
        for highlighter in highlighters
            atts = _excel_highlighter_atts(table_data, highlighter, num_rows, j)
            if !isnothing(atts)
                _, _, border_atts = atts
                if !isempty(border_atts)
                    setBorder(sheet, current_row + anchor_row_offset - 1, j + col_offset + anchor_col_offset; allsides = [border_atts...])
                end
                break
            end
        end
    end

    # Write summary rows if present
    if table_data.summary_rows !== nothing
#        current_row += 1  # Blank line before summary
        for (idx, summary_row_func) in enumerate(table_data.summary_rows)
            _excel_unempty_row(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset) # ensure these cells aren't empty before merging
            _excel_write_summary_row(sheet, table_data, table_format, style, idx, summary_row_func, excel_formatters, num_cols, col_offset, footnote_refs, max_row_height, max_col_length, anchor_row_offset, anchor_col_offset, current_row)
            max_row_height = 0 # for row height - reset each row
            current_row += 1
        end
        if _excel_check_table_format("underline_summary",table_format.underline_summary)
            setBorder(sheet, current_row + anchor_row_offset-1, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; bottom=_excel_tableformat_atts("underline_summary_type", table_format.underline_summary_type))
        end
    end

    # Vertical line to right of row labels if required
    if table_data.row_labels !== nothing && _excel_check_table_format("vline_after_row_labels",table_format.vline_after_row_labels)
        start = (!isempty(table_data.title) ? 1 : 0) + (!isempty(table_data.subtitle) ? 1 : 0) + anchor_row_offset + 2 # allow for extra line after title/subtitle
        setBorder(sheet, start:current_row + anchor_row_offset-1, col_offset + anchor_col_offset + (isnothing(table_data.row_labels) ? 1 : 0); right=_excel_tableformat_atts("vline_after_row_labels_type", table_format.vline_after_row_labels_type))
    end

    # Write footnotes if present
    if table_data.footnotes !== nothing && !isempty(table_data.footnotes)
        _excel_unempty_row(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset) # ensure these cells aren't empty before merging
        current_row = _excel_write_footnotes!(sheet, table_data, table_format, style, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
     end
    
    # Write source notes if present
    if !isempty(table_data.source_notes)
        _excel_unempty_row(sheet, current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset) # ensure these cells aren't empty before merging
        _write_excel_sourcenotes!(sheet, table_data, style, current_row, num_cols, anchor_row_offset, anchor_col_offset, col_offset)
    end
    
    for i in 1:num_cols+col_offset
        col_width = _excel_get_col_width(table_format, i, max_col_length, col_offset)
        if col_width > 0.0
            setColumnWidth(sheet, i + anchor_col_offset; width = col_width)
        end
    end

    if _excel_check_table_format("outside_border",table_format.outside_border)
        setBorder(sheet, 1 + anchor_row_offset:current_row + anchor_row_offset, 1 + anchor_col_offset:num_cols+col_offset + anchor_col_offset; outside=_excel_tableformat_atts("outside_border_type",table_format.outside_border_type))
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