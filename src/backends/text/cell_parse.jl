# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to parse the table cells in text back-end.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _parse_cell_text(cell::T; kwargs...)

Parse the table cell `cell` of type `T`. This function must return:

* A vector of `String` with the parsed cell text, one component per line.
* A vector with the length of each parsed line.
* The necessary width for the cell.

"""
@inline function _parse_cell_text(cell;
                                  compact_printing::Bool = true,
                                  renderer::Union{Val{:print}, Val{:show}} = Val(:print),
                                  kwargs...)

    # Convert to string using the desired renderer.
    cell_str = _render_text(renderer, cell, compact_printing = compact_printing)

    # In this case, since the input value is not a `String`, then we do not need
    # to take into account things like line breaks.
    cell_vstr    = [cell_str]
    cell_lstr    = [textwidth(cell_str)]
    cell_width   = first(cell_lstr)

    return cell_vstr, cell_lstr, cell_width
end

@inline function _parse_cell_text(cell::Markdown.MD;
                                  column_width::Integer = -1,
                                  linebreaks::Bool = false,
                                  has_color::Bool = true,
                                  kwargs...)

    # The maximum size for Markdowns cells is 80.
    column_width ≤ 0 && (column_width = 80)

    # Render Markdown
    # ==========================================================================

    # First, we need to render the Markdown with all the colors.
    str = sprint(Markdown.term, cell, column_width; context = :color => true)

    # Now, we need to remove all ANSI escape sequences to count the printable
    # characters.
    #
    # This regex was obtained at:
    #
    #     https://stackoverflow.com/questions/14693701/how-can-i-remove-the-ansi-escape-sequences-from-a-string-in-python
    #
    str_nc = replace(str, r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])" => "")

    if !linebreaks
        str_nc     = replace(str_nc, "\n" => "\\n")
        cell_width = textwidth(str_nc)

        if !has_color
            return [str_nc], [cell_width], cell_width
        else
            str = replace(str, "\n" => "\\n")
            return [str], [cell_width], cell_width
        end
    else
        # Obtain the number of lines and the maximum number of used columns.
        tokens_nc = split(str_nc, '\n')
        lines     = length(tokens_nc)
        max_cols  = maximum(textwidth.(tokens_nc))
        num_chars = textwidth.(tokens_nc)

        if !has_color
            return tokens_nc, num_chars, max_cols
        else
            tokens = split(str, '\n')
            _reapply_ansi_format!(tokens)
            return tokens, num_chars, max_cols
        end
    end
end

@inline function _parse_cell_text(cell::AbstractString;
                                  autowrap::Bool = true,
                                  cell_data_type::DataType = Nothing,
                                  cell_first_line_only::Bool = false,
                                  column_width::Integer = -1,
                                  compact_printing::Bool = true,
                                  linebreaks::Bool = false,
                                  renderer::Union{Val{:print}, Val{:show}} = Val(:print),
                                  kwargs...)

    isstring = cell_data_type <: AbstractString

    if cell_first_line_only
        cell_vstr  = [first(_str_line_breaks(cell,
                                             autowrap,
                                             column_width,
                                             compact_printing,
                                             isstring,
                                             renderer))]
        cell_lstr  = [textwidth(first(cell_vstr))]
        cell_width = first(cell_lstr)
    elseif linebreaks
        cell_vstr  = _str_line_breaks(cell,
                                      autowrap,
                                      column_width,
                                      compact_printing,
                                      isstring,
                                      renderer)
        cell_lstr  = textwidth.(cell_vstr)
        cell_width = maximum(cell_lstr)
    else
        cell_str   = _render_text(renderer, cell,
                                  compact_printing = compact_printing,
                                  isstring = isstring)
        cell_vstr  = [cell_str]
        cell_lstr  = [textwidth(cell_str)]
        cell_width = first(cell_lstr)
    end

    return cell_vstr, cell_lstr, cell_width
end

@inline _parse_cell_text(cell::Missing; kwargs...) = ["missing"], [7], 7
@inline _parse_cell_text(cell::Nothing; kwargs...) = ["nothing"], [7], 7
@inline _parse_cell_text(cell::UndefInitializer; kwargs...) = ["#undef"], [6], 6
