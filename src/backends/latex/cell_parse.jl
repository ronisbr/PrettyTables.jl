# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to parse the table cells in LaTeX back-end.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Parse the table `cell` of type `T` considering the context `io`.
@inline function _parse_cell_latex(
    io::IOContext,
    cell::Any;
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
    kwargs...,
)

    # Create the context that will be used when rendering the cell.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

    # Convert to string using the desired renderer.
    if renderer === Val(:show)
        if !(cell isa LaTeXString) && cell isa AbstractString
            cell_str = cell
        elseif showable(MIME("text/latex"), cell)
            cell_str = sprint(show, MIME("text/latex"), cell; context = context)
        else
            cell_str = sprint(show, cell; context = context)
        end
    else
        cell_str = sprint(print, cell; context = context)
    end

    if cell_first_line_only
        cell_str = split(cell_str, '\n')[1]
    end

    return _str_latex_escaped(cell_str)
end

@inline function _parse_cell_latex(
    io::IOContext,
    cell::Union{LaTeXString, LatexCell};
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
    kwargs...,
)

    # Create the context that will be used when rendering the cell.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

    # Convert to string using the desired renderer.
    data = _get_latex_cell_data(cell)
    if renderer === Val(:show)
        if showable(MIME("text/latex"), data)
            cell_str = sprint(show, MIME("text/latex"), data; context = context)
        elseif data isa AbstractString
            cell_str = data
        else
            cell_str = sprint(show, data; context = context)
        end
    else
        cell_str = sprint(print, data; context = context)
    end

    if cell_first_line_only
        cell_str = split(cell_str, '\n')[1]
    end

    return _str_latex_cell_escaped(cell_str)
end

@inline function _parse_cell_latex(io::IOContext, cell::Markdown.MD; kwargs...)
    return replace(sprint(show, MIME("text/latex"), cell), "\n" => "")
end

@inline _parse_cell_latex(io::IOContext, cell::Missing; kwargs...) = "missing"
@inline _parse_cell_latex(io::IOContext, cell::Nothing; kwargs...) = "nothing"
@inline _parse_cell_latex(io::IOContext, cell::UndefinedCell; kwargs...) = "\\#undef"
@inline _get_latex_cell_data(cell::LatexCell) = cell.data
@inline _get_latex_cell_data(cell::LaTeXString) = cell
