# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to parse the table cells in text back-end.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _parse_cell(cell::T; kwargs...)

Parse the table cell `cell` of type `T`. This function must return:

* A vector of `String` with the parsed cell text, one component per line.
* A vector with the length of each parsed line.
* The necessary width for the cell.

"""
@inline function _parse_cell(cell; compact_printing::Bool = true, kwargs...)
    # Convert to string using `print`.
    cell_str = sprint(print, cell; context = :compact => compact_printing)
    return _parse_cell(cell_str; kwargs...)
end

@inline function _parse_cell(cell::Markdown.MD; kwargs...)
    r = repr(cell)

    # `repr` adds a new line at the end, which is not necessary.
    len = length(r)-1
    cell_str = first(r, len)

    return _parse_cell(cell_str; kwargs...)
end

@inline function _parse_cell(cell::AbstractString;
                             autowrap::Bool = true,
                             cell_first_line_only::Bool = false,
                             column_width::Integer = -1,
                             linebreaks::Bool = false,
                             kwargs...)

    if cell_first_line_only
        cell_vstr  = [first(_str_line_breaks(cell, autowrap, column_width))]
        cell_lstr  = [textwidth(first(cell_vstr))]
        cell_width = first(cell_lstr)
    elseif linebreaks
        cell_vstr  = _str_line_breaks(cell, autowrap, column_width)
        cell_lstr  = textwidth.(cell_vstr)
        cell_width = maximum(cell_lstr)
    else
        cell_str_esc = _str_escaped(cell)
        cell_vstr    = [cell_str_esc]
        cell_lstr    = [textwidth(cell_str_esc)]
        cell_width   = first(cell_lstr)
    end

    return cell_vstr, cell_lstr, cell_width
end

@inline _parse_cell(cell::Missing; kwargs...) = ["missing"], [7], 7
@inline _parse_cell(cell::Nothing; kwargs...) = ["nothing"], [7], 7
@inline _parse_cell(cell::UndefInitializer; kwargs...) = ["#undef"], [6], 6
