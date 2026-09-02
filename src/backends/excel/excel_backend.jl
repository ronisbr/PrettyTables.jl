## Description #############################################################################
#
# Excel backend for PrettyTables.jl
#
############################################################################################

# Default style and format, created once because constructing them allocates.
const _DEFAULT_EXCEL_TABLE_STYLE  = ExcelTableStyle()
const _DEFAULT_EXCEL_TABLE_FORMAT = ExcelTableFormat()

# Empty formatter vector used as the default. It must never be mutated.
const _NO_EXCEL_FORMATTERS = ExcelFormatter[]

############################################################################################
#                                      Print Options                                       #
############################################################################################

"""
    struct ExcelPrintOptions

Options of the Excel back end, with one field per keyword of `pretty_table` that is
specific to the table written to the worksheet. The meaning and the default of each field
are documented in the Excel back end section of `pretty_table`. The keywords related to the
file (`filename`, `mode`, `overwrite`, and `sheet`) are handled by `_excel__print`.

The keywords are gathered in this structure so that the rendering body has a single
positional signature. Otherwise, each distinct set of keywords passed by the user would
create a new entry point into the body, and compiling an entry point into such a large
function is expensive (hundreds of milliseconds in Julia 1.12) even when the body itself is
already compiled.
"""
@kwdef struct ExcelPrintOptions
    anchor_cell::String                                         = "A1"
    data_column_widths::Union{Float64, Vector{Float64}}         = 0.0
    excel_formatters::Vector{ExcelFormatter}                    = _NO_EXCEL_FORMATTERS
    highlighters::Vector{AbstractHighlighter}                   = _NO_HIGHLIGHTERS
    maximum_data_column_widths::Union{Float64, Vector{Float64}} = 0.0
    minimum_data_column_widths::Union{Float64, Vector{Float64}} = 0.0
    style::ExcelTableStyle                                      = _DEFAULT_EXCEL_TABLE_STYLE
    table_format::ExcelTableFormat                              = _DEFAULT_EXCEL_TABLE_FORMAT
end

############################################################################################
#                                       Entry Point                                       #
############################################################################################

"""
    _excel__print(pspec::PrintingSpec; kwargs...) -> Union{Nothing, String, XLSX.XLSXFile}

Write the table described by `pspec` to an Excel workbook. All other keyword arguments are
gathered in an [`ExcelPrintOptions`](@ref) and passed to `_excel__write_table!`.

# Keywords

- `filename::Union{Nothing, String}`: Path of the Excel file to write. When `nothing`, no
    file is created and an in-memory `XLSX.XLSXFile` is returned instead. When a string,
    behavior depends on `mode`.
    (**Default**: `nothing`)
- `sheet::Union{String, XLSX.Worksheet}`: When a `String`, the name of the worksheet tab.
    If no sheet with that name exists it will be created. When an `XLSX.Worksheet`, that
    worksheet is updated in place and `nothing` is returned.
    (**Default**: `"prettytable"`)
- `mode::String`: `"w"` to create a new file or `"rw"` (or its alias `"wr"`) to open and
    update an existing one.
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
    error("""
          Excel backend requires the XLSX.jl package.

          Please install and load it with:

              using Pkg
              Pkg.add("XLSX")
              using XLSX

          Then retry your pretty_table call with backend = :excel.
          """)

    return nothing
end
