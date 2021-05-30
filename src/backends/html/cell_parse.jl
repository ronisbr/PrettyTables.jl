# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to parse the table cells in HTML back-end.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _parse_cell_html(cell::T; kwargs...)

Parse the table `cell` of type `T`.

This function must return a string that will be printed to the IO.
"""
@inline function _parse_cell_html(
    cell;
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    linebreaks::Bool = false,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
    kwargs...
)
    # Create the context that will be used when rendering the cell. Notice that
    # the `IOBuffer` will be neglected.
    context = IOContext(stdout, :compact => compact_printing, :limit => limit_printing)

    # Convert to string using the desired renderer.
    if renderer === Val(:show)
        if cell isa AbstractString
            cell_str = cell
        elseif showable(MIME("text/html"), cell)
            cell_str = sprint(show, MIME("text/html"), cell; context = context)
        else
            cell_str = sprint(show, cell; context = context)
        end
    else
        cell_str = sprint(print, cell; context = context)
    end

    if cell_first_line_only
        cell_str = split(cell_str, '\n')[1]
    elseif linebreaks
        cell_str = replace(cell_str, "\n" => "<BR>")
    end

    return _str_escaped(cell_str)
end

@inline function _parse_cell_html(cell::Markdown.MD; kwargs...)
    return replace(sprint(show, MIME("text/html"), cell),"\n"=>"")
end

@inline _parse_cell_html(cell::Missing; kwargs...) = "missing"
@inline _parse_cell_html(cell::Nothing; kwargs...) = "nothing"
@inline _parse_cell_html(cell::UndefInitializer; kwargs...) = "#undef"
