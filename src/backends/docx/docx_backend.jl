## Description #############################################################################
#
# Word backend for PrettyTables.jl
#
############################################################################################

# Default style and format, created once because constructing them allocates.
const _DEFAULT_DOCX_TABLE_STYLE  = DocxTableStyle()
const _DEFAULT_DOCX_TABLE_FORMAT = DocxTableFormat()

############################################################################################
#                                      Print Options                                       #
############################################################################################

"""
    struct DocxPrintOptions

Options of the Word back end, with one field per keyword of `pretty_table` that is specific
to the rendered table. The meaning and the default of each field are documented in the Word
back end section of `pretty_table`. The keywords related to the file (`filename` and
`overwrite`) are handled by `_docx__print`.

The keywords are gathered in this structure so that the rendering body has a single
positional signature. Otherwise, each distinct set of keywords passed by the user would
create a new entry point into the body, and compiling an entry point into such a large
function is expensive (hundreds of milliseconds in Julia 1.12) even when the body itself is
already compiled.
"""
@kwdef struct DocxPrintOptions
    data_column_widths::DataColumnWidths         = 0.0
    highlighters::Vector{AbstractHighlighter}    = _NO_HIGHLIGHTERS
    maximum_data_column_widths::DataColumnWidths = 0.0
    minimum_data_column_widths::DataColumnWidths = 0.0
    style::DocxTableStyle                        = _DEFAULT_DOCX_TABLE_STYLE
    table_format::DocxTableFormat                = _DEFAULT_DOCX_TABLE_FORMAT
end

############################################################################################
#                                       Entry Point                                        #
############################################################################################

"""
    _docx__print(pspec::PrintingSpec; kwargs...) -> Union{String, WriteDocx.Table}

Render the table described by `pspec` as a Word table. All other keyword arguments are
gathered in a [`DocxPrintOptions`](@ref) and passed to `_docx__render_table`.

# Keywords

- `filename::Union{Nothing, String}`: Path of the Word file to write, which must end in
    `.docx`. When `nothing`, no file is created and the `WriteDocx.Table` is returned
    instead, allowing it to be embedded in a larger document.
    (**Default**: `nothing`)
- `overwrite::Bool`: Allow overwriting an existing file.
    (**Default**: `false`)

# Returns

- `WriteDocx.Table` when `filename` is `nothing`.
- `String` (the filename) otherwise.
"""
function _docx__print(args...; kwargs...)
    error("""
          Word backend requires the WriteDocx.jl package.

          Please install and load it with:

              using Pkg
              Pkg.add("WriteDocx")
              using WriteDocx

          Then retry your pretty_table call with backend = :docx.
          """)

    return nothing
end
