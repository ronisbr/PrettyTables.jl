module PrettyTablesWriteDocxExt

using PrettyTables
import WriteDocx as W

# Import the functions we're overriding.
import PrettyTables: _docx__print, _is_horizontally_cropped, pretty_table

# Import types we need.
using PrettyTables: PrintingSpec, RenderContext, PrintingTableState, MergeCells
using PrettyTables: DocxPrintOptions

# Import internal iterator and helpers.
import PrettyTables: _next, _current_cell, _current_cell_alignment
import PrettyTables: _current_cell_footnote_marks
import PrettyTables: _number_of_printed_columns, _number_of_printed_data_columns
import PrettyTables: _check_backend_keywords, _data_indices, _get_data, _has_summary_rows
import PrettyTables: _check_column_label_styles, _line_spec_indices, _merged_cell_span
import PrettyTables: _IGNORE_CELL, _DOCX__NO_DECORATION, _sprint_with_context
import PrettyTables: _docx__highlighter_decoration, _docx__native_highlighters
import PrettyTables: _face_color_hex, _face_from_kwargs
import PrettyTables: docx_decoration, remove_decorations

@static if VERSION >= v"1.11"
    import PrettyTables: _StyledString, _face_regions
end

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
    _docx__print(pspec::PrintingSpec; kwargs...) -> Union{String, W.Table}

Render the table described by `pspec` as a Word table. All other keyword arguments are
gathered in a `DocxPrintOptions` and passed to `_docx__render_table`.

# Keywords

- `default_font::Union{Nothing, String}`: Default font of the document written to
    `filename`. If it is `nothing`, `_DOCX__DEFAULT_FONT` is used. Since the font is a
    property of the document, an `ArgumentError` is thrown if it is passed when no file is
    written.
    (**Default**: `nothing`)
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
function PrettyTables._docx__print(
    pspec::PrintingSpec;
    default_font::Union{Nothing, String} = nothing,
    filename::Union{Nothing, String} = nothing,
    overwrite::Bool = false,
    kwargs...,
)
    # Check the file and the document options before rendering the table to fail as soon as
    # possible.
    if isnothing(filename)
        !isnothing(default_font) && throw(
            ArgumentError(
                "The keyword `default_font` is only applied to the documents created by the Word back end, i.e., when `filename` is set or when calling `pretty_table(WriteDocx.Document, data; kwargs...)`. The default font of a returned `WriteDocx.Table` is defined by the styles of the document that contains it.",
            ),
        )
    else
        (!overwrite && isfile(filename)) &&
            error("File \"$filename\" already exists and `overwrite = false`.")
    end

    font = _docx__default_font(default_font)

    _check_backend_keywords(DocxPrintOptions, kwargs, "Word")
    opts  = DocxPrintOptions(; kwargs...)
    table = _docx__render_table(pspec, opts)

    isnothing(filename) && return table

    W.save(filename, _docx__document(table, font))

    return filename
end

"""
    pretty_table(::Type{W.Table}, data::Any; kwargs...) -> W.Table
    pretty_table(::Type{W.Document}, data::Any; kwargs...) -> W.Document

Render `data` as a pretty table and return the `WriteDocx.Table` object, or a
`WriteDocx.Document` with a single section containing it. All keyword arguments are
forwarded to `pretty_table`, except `default_font`, which selects the default font of the
returned `WriteDocx.Document` (Calibri if it is `nothing`). The default font of a returned
`WriteDocx.Table` is defined by the styles of the document that contains it. Hence, passing
`default_font` when the `WriteDocx.Table` is returned throws an `ArgumentError`.

# Examples

```julia
julia> using PrettyTables

julia> import WriteDocx as W

julia> doc = pretty_table(W.Document, [1 2 3; 4 5 6])

julia> W.save("myfile.docx", doc)
```
"""
function pretty_table(::Type{W.Table}, @nospecialize(data::Any); kwargs...)
    # Force `backend` to `:docx` and `filename` to `nothing`. Notice that the overrides must
    # be stripped from the user keywords first and then placed **last**, since the rightmost
    # binding wins when the keywords are splatted.
    kw = Base.structdiff(NamedTuple(kwargs), NamedTuple{(:filename, :backend)})

    return pretty_table(data; kw..., backend = :docx, filename = nothing)
end

function pretty_table(
    ::Type{W.Document},
    @nospecialize(data::Any);
    default_font::Union{Nothing, String} = nothing,
    kwargs...,
)
    font = _docx__default_font(default_font)
    return _docx__document(pretty_table(W.Table, data; kwargs...), font)
end

############################################################################################
#                                     Precompilation                                       #
############################################################################################

include("precompile.jl")

end # module
