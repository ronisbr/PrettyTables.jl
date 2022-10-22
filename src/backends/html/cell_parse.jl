# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to parse the table cells in HTML back-end.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Parse the table `cell` of type `T` considering the context `io`.
@inline function _parse_cell_html(
    io::IOContext,
    cell::Any;
    allow_html_in_cells::Bool = false,
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    linebreaks::Bool = false,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
    kwargs...
)
    cell_str = _render_cell_html(
        io,
        cell;
        compact_printing = compact_printing,
        limit_printing = limit_printing,
        renderer = renderer
    )

    # Check if we need to replace `\n` with `<br>`.
    replace_newline = !cell_first_line_only && linebreaks

    if cell_first_line_only
        cell_str = split(cell_str, '\n')[1]
    end

    # If the user wants HTML code inside cell, then we must not escape the HTML
    # characters.
    return _str_html_escaped(cell_str, replace_newline, !allow_html_in_cells)
end

@inline function _parse_cell_html(
    io::IOContext,
    cell::HtmlCell;
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    linebreaks::Bool = false,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
    kwargs...
)
    cell_str = _render_cell_html(
        io,
        cell.data;
        compact_printing = compact_printing,
        limit_printing = limit_printing,
        renderer = renderer
    )

    # Check if we need to replace `\n` with `<br>`.
    replace_newline = !cell_first_line_only && linebreaks

    if cell_first_line_only
        cell_str = split(cell_str, '\n')[1]
    end

    return _str_html_escaped(cell_str, replace_newline, false)
end

@inline function _parse_cell_html(io::IOContext, cell::Markdown.MD; kwargs...)
    return replace(sprint(show, MIME("text/html"), cell),"\n"=>"")
end

@inline _parse_cell_html(io::IOContext, cell::Missing; kwargs...) = "missing"
@inline _parse_cell_html(io::IOContext, cell::Nothing; kwargs...) = "nothing"
@inline _parse_cell_html(io::IOContext, cell::UndefinedCell; kwargs...) = "#undef"

function _render_cell_html(
    io::IOContext,
    cell::Any;
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
)
    # Create the context that will be used when rendering the cell.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

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

    return cell_str
end
