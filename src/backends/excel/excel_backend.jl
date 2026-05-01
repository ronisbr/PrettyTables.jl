## Description #############################################################################
#
# Excel backend for PrettyTables.jl
#
############################################################################################

"""
    _excel__print(pspec::PrintingSpec; kwargs...) -> Union{Nothing, String, XLSX.XLSXFile}

Write the table described by `pspec` to an Excel workbook. All other keyword arguments are
passed through to `_excel__write_table!`.

# Keywords

- `filename::Union{Nothing, String}`: Path of the Excel file to write. When `nothing`, no
    file is created and an in-memory `XLSX.XLSXFile` is returned instead. When a string,
    behaviour depends on `mode`.
    (**Default**: `nothing`)
- `sheet::Union{String, XLSX.Worksheet}`: When a `String`, the name of the worksheet tab.
    If no sheet with that name exists it will be created. When an `XLSX.Worksheet`, that
    worksheet is updated in place and `nothing` is returned.
    (**Default**: `"prettytable"`)
- `mode::String`: `"w"` to create a new file or `"rw"` to open and update an existing one.
    (**Default**: `"w"`)
- `overwrite::Bool`: Allow overwriting an existing file when `mode = "w"`.
    (**Default**: `false`)
- `anchor_cell::String`: Top-left cell of the table in A1 notation, allowing placement
    anywhere on the sheet.
    (**Default**: `"A1"`)

# Returns

- `nothing` when `sheet` is an `XLSX.Worksheet` (the worksheet is updated in place).
- `XLSX.XLSXFile` when `filename` is `nothing` and `sheet` is a `String`.
- `String` (the filename) when `filename` is a `String` and `mode = "w"`.
- `XLSX.XLSXFile` when `filename` is a `String` and `mode = "rw"`.

!!! note

    Save a returned `XLSX.XLSXFile` using `XLSX.writexlsx` or `XLSX.savexlsx`.
"""
function _excel__print(args...; kwargs...)
    error(
        """
        Excel backend requires the XLSX.jl package.

        Please install and load it with:

            using Pkg
            Pkg.add("XLSX")
            using XLSX

        Then retry your pretty_table call with backend = :excel.
        """
    )

    return nothing
end
