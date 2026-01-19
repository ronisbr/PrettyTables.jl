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

- `filename::Union{Nothing, String} = "table.xlsx"`: Output filename. If `nothing`, returns an in-memory XLSX object.
- `sheet_name::String = "Sheet1"`: Name of the worksheet.
- `overwrite::Bool = true`: Whether to overwrite existing files.
- `table_style::Union{Nothing, XlsxTableStyle} = nothing`: Style to apply to the table.
- `table_format::Union{Nothing, XlsxTableFormat} = nothing`: Format configuration for the table.

# Returns

- If `filename` is a `String`: Returns the filename after writing.
- If `filename` is `nothing`: Returns an `XLSX.XLSXFile` object (requires XLSX.jl).

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
