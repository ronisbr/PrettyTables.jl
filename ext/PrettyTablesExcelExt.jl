module PrettyTablesExcelExt

using PrettyTables
using XLSX

# Import the functions we're overriding
import PrettyTables: _excel__print, fmt__excel_stringify, pretty_table

# Import types we need
using PrettyTables: PrintingSpec, TableData, ColumnTable, RowTable

# Also import Tables.jl for handling table data
using Tables

include("../src/backends/excel/table_sections.jl")
include("../src/backends/excel/write_table.jl")
include("../src/backends/excel/helpers.jl")

"""
    _excel__print(pspec::PrintingSpec; kwargs...)

Implementation of Excel backend printing when XLSX.jl is loaded.

# Returns

- If `filename === nothing`
    - If `sheet === XLSX.worksheet`: Returns `nothing`. The worksheet specified is updated in place.
    - If `sheet !== XLSX.worksheet`: Returns an in-memory `XLSX.XLSXFile` object.
- If `filename::String` and `mode=\"w\"`: Writes to a new file and returns the filename.
- If `filename::String` and `mode=\"rw\"`: Reads an existing file, updates and returns the in-memory `XLSX.XLSXFile` object

# Additional Keywords

- `filename::Union{Nothing,String}`: The name of the Excel file to be used to contain the 
  table. If `nothing` (default), no file will be created but an `XLSXFile` object will be 
  returned instead. If a valid filename is given, behaviour depends on the value specified 
  for `mode`.
- `sheet::Union{String, XLSX.Worksheet}`: If `sheet` is a `String`, it specifies the name of 
  the tab to use for the created pretty table. Default = `"prettytable"`. If a sheet with the 
  given name doesn't exist, it will be created. The resultant `XLSXFile` object will be 
  returned. If `sheet` is an `XLSX.Worksheet`, this worksheet will be updated in place by the 
  addition of the pretty table and `nothing` will be returned.
- `mode::String`: Determines whether to create a new Excel file (`mode = "w"` - Default) or 
  to open and use an existing Excel file (`mode = "rw"`).
- `overwrite::Bool`: Determines whether or not to overwrite an existing file if `mode = "w"`. 
  Default = `false`.
- `anchor_cell::String`: Defines the top-left cell of the table, allowing placement 
  anywhere on a sheet. A table will overwrite any existing data in the cells it is written to, 
  but using `anchor_cell` makes it possible to place a pretty table alongside existing data 
  in the specified sheet. Default = `"A1"`. 
- `excel_formatters::Vector{ExcelFormatter}`: Excel-specific format (numFmt) definitions 
  to appy to the table. For more information, see the section [`ExcelFormatter`](@ref).
- `highlighters::Vector{ExcelHighlighter}`: Excel-specific highlighters to apply to the 
  table. For more information, see the section [`ExcelHighlighter`](@ref).
- `table_format::ExcelTableFormat`: Defines the table borders to be used in each section 
  of the table. For more information, see the section [`ExcelTableFormat`](@ref)
- `style::ExcelTableStyle`: Defines the Excel font attributes to be used by each element of 
  the table. For more information, see the section [`ExcelTableStyle`](@ref).
- `fill::ExcelTableFill`: Defines the Excel cell fill to be used by each element of 
  the table. For more information, see the section [`ExcelTableFill`](@ref).

Save a returned XLSX.XLSXFile using `XLSX.writexlsx` or `XLSX.savexlsx`.

"""
function PrettyTables._excel__print(
    # Default values chosen to minimise risk of accidentally overwriting data if `mode=\"rw\"`
    pspec::PrintingSpec;
    filename::Union{Nothing, String} = nothing,
    sheet::Union{String, XLSX.Worksheet} = "prettytable",
    mode::String = "w",
    overwrite::Bool = false,
    anchor_cell::String = "A1",
    kwargs...
)
    # Extract table data from PrintingSpec
    table_data = pspec.table_data

    if filename === nothing
        if sheet isa String
            # Return in-memory XLSX object
            xf = XLSX.newxlsx()
            sh = xf[1]
            sheet == sh.name || XLSX.renamesheet!(sh, sheet)
            _write_excel_table!(sh, table_data; anchor_cell, kwargs...)
            return xf
        else # sheet isa XLSX.worksheet; update sheet in place.
            _write_excel_table!(sheet, table_data; anchor_cell, kwargs...)
            return nothing
        end
        
    else
        if mode ∉ ["w", "rw", "wr"]
            throw(ArgumentError("Invalid mode \"$mode\". \nMust be either \"w\" to create a new file or \"rw\" to add a PrettyTable to an existing spreadsheet."))
        end
        if sheet isa XLSX.Worksheet
            throw(ArgumentError("Can't specify both `filename` and an `XLSX.worksheet`. Either the `sheet` argument must be a `String` name of the worksheet to write to, not an `XLSX.Worksheet` object or the filename must be `nothing`."))
        end

        if mode == "w" # Write the PrettyTable to a new `xlsx` file.

            if !overwrite && isfile(filename)
                error("File '$filename' already exists and overwrite=false")
            end
            
            XLSX.openxlsx(filename, mode="w") do xf
                sh = xf[1]
                sheet == sh.name || XLSX.renamesheet!(sh, sheet)
                _write_excel_table!(sh, table_data; anchor_cell, kwargs...)
                return filename
            end

        elseif mode ∈ ["rw", "wr"] # Open an existing `xlsx` file and write a PrettyTable to it. Return in-memory XLSX object.
            xf = XLSX.opentemplate(filename)
            XLSX.hassheet(xf, sheet) || XLSX.addsheet!(xf, sheet)
            sh = xf[sheet]
            _write_excel_table!(sh, table_data; anchor_cell, kwargs...)
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
function pretty_table(::Type{XLSX.XLSXFile}, @nospecialize(data::Any); kwargs...)
    # Force backend to :excel and filename to nothing
    if !haskey(kwargs, :backend)
        return pretty_table(data; backend = :excel, filename = nothing, kwargs...)
    else
        return pretty_table(data; filename = nothing, kwargs...)
    end
end

end # module