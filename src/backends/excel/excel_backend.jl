## Description #############################################################################
#
# Excel backend for PrettyTables.jl
#
############################################################################################

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

Save a returned XLSX.XLSXFile using `XLSX.writexlsx` or `XLSX.savexlsx`.

"""
function _excel__print(args...; kwargs...)

    error("""
    Excel backend requires the XLSX.jl package.
    
    Please install and load it with:
        using Pkg
        Pkg.add("XLSX")
        using XLSX
    
    Then retry your pretty_table call with backend = :excel.
    """)
end
