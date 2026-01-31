## Description #############################################################################
#
# Excel backend for PrettyTables.jl
#
############################################################################################

"""
    _excel__print(pspec::PrintingSpec; kwargs...)

Print the table to Excel format using the specifications in `pspec`.

This function requires XLSX.jl to be loaded. The actual implementation
is provided by the PrettyTablesExcelExt extension when XLSX.jl is available.

# Keywords

- `filename::Union{Nothing, String}` : the name of the file or `nothing`. (Default: `nothing`)
- `sheet-name::String` : the name of the worksheet to write to, which will be created or renamed if necessary. (Default: `prettytable`).
- `mode::String` : Determines whether a new file is created (`mode = \"w\"`) or an existing file is updated (`mode = \"rw\"`). (Default: \"w\")
- `overwrite::Bool` : Forces a newly created file to overwrite any existing file of the same name if `true`. (Default: `false`)
- `anchor_cell::String` : Defines the location of the top left corner of the table in the worksheet. (Default = \"A1\")

# Returns

- If `filename === nothing`: Returns an in-memory `XLSX.XLSXFile` object.
- If `filename::String` and `mode=\"w\"`: Writes to a new file and returns the filename.
- If `filename::String` and `mode=\"rw\"`: Reads an existing file, updates and returns the in-memory `XLSX.XLSXFile` object

Save a returned XLSX.XLSXFile using `XLSX.writexlsx`.

# Extended Help

The Excel backend converts the table data and all its sections (title, subtitle, headers,
footers, etc.) into an Excel workbook. When XLSX.jl is not loaded, calling this function
will produce an error message with instructions on how to install and load the package.

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
