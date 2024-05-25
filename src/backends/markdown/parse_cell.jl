## Description #############################################################################
#
# Functions to parse the table cells in markdown back end.
#
############################################################################################

# Parse the table `cell` of type `T` and return a `String` with the parsed cell text, one
# component per line.
function _markdown_parse_cell(
    @nospecialize(io::IOContext),
    cell::Any;
    allow_markdown_in_cells::Bool = false,
    cell_data_type::DataType = Nothing,
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    linebreaks::Bool = false,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
    kwargs...
)
    isstring = cell_data_type <: AbstractString

    # Convert to string using the desired renderer.
    #
    # Due to the non-specialization of `data`, `cell` here is inferred as `Any`. However,
    # we know that the output of `_render_text` must be a vector of String.
    cell_str::String = _markdown_render_cell(
        renderer,
        io,
        cell;
        compact_printing = compact_printing,
        isstring = isstring,
        limit_printing = limit_printing,
    )

    return _escape_markdown_str(cell_str, !allow_markdown_in_cells, linebreaks)
end

_markdown_parse_cell(@nospecialize(io::IOContext), cell::Missing; kwargs...) = "missing"
_markdown_parse_cell(@nospecialize(io::IOContext), cell::Nothing; kwargs...) = "nothing"
_markdown_parse_cell(@nospecialize(io::IOContext), cell::UndefinedCell; kwargs...) = "#undef"
