module PrettyTablesExcelExt

using PrettyTables
using XLSX

# Import the functions we're overriding.
import PrettyTables: _excel__print, fmt__excel_stringify, pretty_table

# Import types we need.
using PrettyTables: PrintingSpec, TableData, ColumnTable, RowTable, PrintingTableState
using PrettyTables: MergeCells

# Import internal iterator and helpers.
import PrettyTables: _next, _current_cell, _current_cell_alignment, _current_cell_footnotes
import PrettyTables: _number_of_printed_columns, _number_of_printed_data_columns
import PrettyTables: _IGNORE_CELL

# Also import Tables.jl for handling table data
using Tables

############################################################################################
#                                         Includes                                         #
############################################################################################

include("helpers.jl")
include("table_sections.jl")
include("write_table.jl")

############################################################################################
#                                        Functions                                         #
############################################################################################

""" _excel__print(pspec::PrintingSpec; kwargs...)

Implementation of Excel backend printing when XLSX.jl is loaded.

# Keywords

- `filename::Union{Nothing,String}`: The name of the Excel file to be used to contain the
    table. If `nothing` (default), no file will be created but an `XLSXFile` object will be
    returned instead. If a valid filename is given, behaviour depends on the value specified
    for `mode`.
    (**Default**: `nothing`)
- `sheet::Union{String, XLSX.Worksheet}`: If `sheet` is a `String`, it specifies the name of
    the tab to use for the created pretty table. Default = `"prettytable"`. If a sheet with
    the given name doesn't exist, it will be created. The resultant `XLSXFile` object will
    be returned. If `sheet` is an `XLSX.Worksheet`, this worksheet will be updated in place
    by the addition of the pretty table and `nothing` will be returned.
    (**Default**: `"prettytable"`)
- `mode::String`: Determines whether to create a new Excel file (`mode = "w"`) or to open
    and use an existing Excel file (`mode = "rw"`).
    (**Default**: `"w"`)
- `overwrite::Bool`: Determines whether or not to overwrite an existing file if `mode =
    "w"`.
    (**Default**: `false`)
- `anchor_cell::String`: Defines the top-left cell of the table, allowing placement anywhere
    on a sheet. A table will overwrite any existing data in the cells it is written to, but
    using `anchor_cell` makes it possible to place a pretty table alongside existing data in
    the specified sheet.
    (**Default**: `"A1"`)

All other keyword arguments are passed to the internal `_excel__write_table!` function.

# Returns

- If `filename === nothing`
    - If `sheet === XLSX.worksheet`: Returns `nothing`. The worksheet specified is updated
    in place.
    - If `sheet !== XLSX.worksheet`: Returns an in-memory `XLSX.XLSXFile` object.
    - If `filename::String` and `mode=\"w\"`: Writes to a new file and returns the filename.
- If `filename::String` and `mode = "rw"`: Reads an existing file, updates and returns the
    in-memory `XLSX.XLSXFile` object

!!! note

    Save a returned `XLSX.XLSXFile` using `XLSX.writexlsx` or `XLSX.savexlsx`.
"""
function PrettyTables._excel__print(
    pspec::PrintingSpec;
    filename::Union{Nothing, String} = nothing,
    sheet::Union{String, XLSX.Worksheet} = "prettytable",
    mode::String = "w",
    overwrite::Bool = false,
    anchor_cell::String = "A1",
    kwargs...
)
    if isnothing(filename)
        if sheet isa String
            # Return in-memory XLSX object.
            xf = XLSX.newxlsx()
            sh = xf[1]
            sheet == sh.name || XLSX.renamesheet!(sh, sheet)

            _excel__write_table!(sh, pspec; anchor_cell, kwargs...)

            return xf
        end

        _excel__write_table!(sheet, pspec; anchor_cell, kwargs...)
        return nothing
    end

    # Check arguments.
    mode ∉ ["w", "rw", "wr"] && throw(ArgumentError(
        "Invalid mode \"$mode\". Must be either \"w\" to create a new file or \"rw\" to add a PrettyTable to an existing spreadsheet."
    ))

    sheet isa XLSX.Worksheet && throw(ArgumentError(
        "Can't specify both `filename` and an `XLSX.worksheet`. Either the `sheet` argument must be a `String` name of the worksheet to write to, not an `XLSX.Worksheet` object or the filename must be `nothing`."
    ))

    if mode == "w"
        # Write the PrettyTable to a new `xlsx` file.
        (!overwrite && isfile(filename)) &&
            error("File \"$filename\" already exists and `overwrite = false`.")

        XLSX.openxlsx(filename, mode = "w") do xf
            sh = xf[1]
            sheet == sh.name || XLSX.renamesheet!(sh, sheet)

            _excel__write_table!(sh, pspec; anchor_cell, kwargs...)
        end

        return filename
    end

    # If we reach this point, we know that `mode` is "rw" and `filename` is not `nothing`,
    # so we can open the file and write to it.
    xf = XLSX.opentemplate(filename)
    XLSX.hassheet(xf, sheet) || XLSX.addsheet!(xf, sheet)
    sh = xf[sheet]

    _excel__write_table!(sh, pspec; anchor_cell, kwargs...)

    # Returning xf forces the user to save using XLSX.writexlsx, reducing the risk of
    # accidentally overwriting data.
    return xf
end

"""
    pretty_table(::Type{XLSX.XLSXFile}, data; kwargs...)

Convenience method to get an in-memory XLSX workbook object.

# Examples

```julia
julia> using PrettyTables, XLSX

julia> data = [1 2 3; 4 5 6]

julia> xf = pretty_table(XLSX.XLSXFile, data; backend = :excel)

julia> # Now you can manipulate the workbook further or save it to file yourself.

julia> XLSX.writexlsx("myfile.xlsx", xf)
```
"""
function pretty_table(::Type{XLSX.XLSXFile}, @nospecialize(data::Any); kwargs...)
    # Force backend to :excel and filename to nothing.
    !haskey(kwargs, :backend) &&
        return pretty_table(data; backend = :excel, filename = nothing, kwargs...)

    return pretty_table(data; filename = nothing, kwargs...)
end

end # module
