module PrettyTablesExcelExt

using PrettyTables
using XLSX

# Import the functions we're overriding.
import PrettyTables: _excel__print, _is_horizontally_cropped, pretty_table

# Import types we need.
using PrettyTables: PrintingSpec, RenderContext, TableData, PrintingTableState, MergeCells
using PrettyTables: AbstractHighlighter, ExcelPrintOptions

# Import internal iterator and helpers.
import PrettyTables: _next, _current_cell, _current_cell_alignment, _current_cell_footnotes
import PrettyTables: _number_of_printed_columns, _number_of_printed_data_columns
import PrettyTables: _get_data, _has_summary_rows
import PrettyTables: _IGNORE_CELL, _EXCEL__NO_DECORATION, _sprint_with_context
import PrettyTables: _excel__highlighter_decoration
import PrettyTables: excel_decoration

@static if VERSION >= v"1.11"
    import PrettyTables: _face_regions
end

# Also import Tables.jl for handling table data
using Tables

############################################################################################
#                                         Includes                                         #
############################################################################################

include("helpers.jl")
include("render_cell.jl")
include("write_table.jl")

############################################################################################
#                                        Functions                                         #
############################################################################################

"""
    _excel__print(pspec::PrintingSpec; kwargs...) -> Union{Nothing, String, XLSX.XLSXFile}

Write the table described by `pspec` to an Excel workbook. All other keyword arguments are
gathered in an `ExcelPrintOptions` and passed to `_excel__write_table!`.

# Keywords

- `anchor_cell::String`: Top-left cell of the table in A1 notation, allowing placement
    anywhere on the sheet.
    (**Default**: `"A1"`)
- `filename::Union{Nothing, String}`: Path of the Excel file to write. When `nothing`, no
    file is created and an in-memory `XLSX.XLSXFile` is returned instead. When a string,
    behavior depends on `mode`.
    (**Default**: `nothing`)
- `sheet::Union{String, XLSX.Worksheet}`: When a `String`, the name of the worksheet tab.
    If no sheet with that name exists it will be created. When an `XLSX.Worksheet`, that
    worksheet is updated in place and `nothing` is returned.
    (**Default**: `"prettytable"`)
- `mode::String`: `"w"` to create a new file, `"rw"` to open and update an existing one,
    or `"wr"` as an alias for `"rw"`.
    (**Default**: `"w"`)
- `overwrite::Bool`: Allow overwriting an existing file when `mode = "w"`.
    (**Default**: `false`)

# Returns

- `nothing` when `sheet` is an `XLSX.Worksheet` (the worksheet is updated in place).
- `XLSX.XLSXFile` when `filename` is `nothing` and `sheet` is a `String`.
- `String` (the filename) when `filename` is a `String` and `mode = "w"`.
- `XLSX.XLSXFile` when `filename` is a `String` and `mode = "rw"` (or `"wr"`).

!!! note

    Save a returned `XLSX.XLSXFile` using `XLSX.writexlsx` or `XLSX.savexlsx`.
"""
function PrettyTables._excel__print(
    pspec::PrintingSpec;
    filename::Union{Nothing, String} = nothing,
    mode::String = "w",
    overwrite::Bool = false,
    sheet::Union{String, XLSX.Worksheet} = "prettytable",
    kwargs...,
)
    opts = ExcelPrintOptions(; kwargs...)

    if isnothing(filename)
        if sheet isa String
            # Return in-memory XLSX object.
            xf = XLSX.newxlsx()
            sh = xf[1]
            sheet == sh.name || XLSX.renamesheet!(sh, sheet)

            _excel__write_table!(sh, pspec, opts)

            return xf
        end

        _excel__write_table!(sheet, pspec, opts)
        return nothing
    end

    # Check arguments.
    mode ∉ ["w", "rw", "wr"] && throw(
        ArgumentError(
            "Invalid mode \"$mode\". Must be either \"w\" to create a new file, or \"rw\" (or its alias \"wr\") to add a PrettyTable to an existing spreadsheet.",
        ),
    )

    sheet isa XLSX.Worksheet && throw(
        ArgumentError(
            "Can't specify both `filename` and an `XLSX.worksheet`. Either the `sheet` argument must be a `String` name of the worksheet to write to, not an `XLSX.Worksheet` object or the filename must be `nothing`.",
        ),
    )

    if mode == "w"
        # Write the PrettyTable to a new `xlsx` file.
        (!overwrite && isfile(filename)) &&
            error("File \"$filename\" already exists and `overwrite = false`.")

        XLSX.openxlsx(filename; mode = "w") do xf
            sh = xf[1]
            sheet == sh.name || XLSX.renamesheet!(sh, sheet)

            _excel__write_table!(sh, pspec, opts)
        end

        return filename
    end

    # If we reach this point, we know that `mode` is "rw" and `filename` is not `nothing`,
    # so we can open the file and write to it.
    xf = XLSX.opentemplate(filename)
    XLSX.hassheet(xf, sheet) || XLSX.addsheet!(xf, sheet)
    sh = xf[sheet]

    _excel__write_table!(sh, pspec, opts)

    # Returning xf forces the user to save using XLSX.writexlsx, reducing the risk of
    # accidentally overwriting data.
    return xf
end

"""
    pretty_table(::Type{XLSX.XLSXFile}, data::Any; kwargs...) -> XLSX.XLSXFile

Render `data` as a PrettyTable and return an in-memory `XLSX.XLSXFile` object. All keyword
arguments are forwarded to `pretty_table`.

# Examples

```julia
julia> using PrettyTables, XLSX

julia> xf = pretty_table(XLSX.XLSXFile, [1 2 3; 4 5 6]; backend = :excel)

julia> XLSX.writexlsx("myfile.xlsx", xf)
```
"""
function pretty_table(::Type{XLSX.XLSXFile}, @nospecialize(data::Any); kwargs...)
    # Force `backend` to `:excel` and `filename` to `nothing`.
    #
    # NOTE: The overrides must be stripped from the user keywords first and then placed
    # **last**. When keywords are splatted, the rightmost binding wins, so a user-supplied
    # `filename` used to override the `nothing` here and write a file, contradicting both the
    # documentation and this comment.
    kw = Base.structdiff(NamedTuple(kwargs), NamedTuple{(:filename, :backend)})

    return pretty_table(data; kw..., backend = :excel, filename = nothing)
end

############################################################################################
#                                     Precompilation                                       #
############################################################################################

include("precompile.jl")

end # module
