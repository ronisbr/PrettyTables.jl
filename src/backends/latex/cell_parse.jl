# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to parse the table cells in LaTeX back-end.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _parse_cell_latex(cell::T; kwargs...)

Parse the table cell `cell` of type `T`. This function must return a string that
will be printed to the IO.

"""
@inline function _parse_cell_latex(cell;
                                   cell_first_line_only::Bool = false,
                                   compact_printing::Bool = true,
                                   renderer::Union{Val{:print}, Val{:show}} = Val(:print),
                                   kwargs...)

    # Convert to string using the desired renderer.
    if renderer === Val(:show)
        if cell isa AbstractString
            cell_str = cell
        elseif showable(MIME("text/latex"), cell)
            cell_str = sprint(show, MIME("text/latex"), cell;
                              context = :compact => compact_printing)
        else
            cell_str = sprint(show, cell;
                              context = :compact => compact_printing)
        end
    else
        cell_str = sprint(print, cell; context = :compact => compact_printing)
    end

    if cell_first_line_only
        cell_str = split(cell_str, '\n')[1]
    end

    return _str_latex_escaped(cell_str)
end

@inline _parse_cell_latex(cell::Markdown.MD; kwargs...) =
    replace(sprint(show, MIME("text/latex"), cell),"\n"=>"")

@inline _parse_cell_latex(cell::Missing; kwargs...) = "missing"
@inline _parse_cell_latex(cell::Nothing; kwargs...) = "nothing"
@inline _parse_cell_latex(cell::UndefInitializer; kwargs...) = "\\#undef"
