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
function _parse_cell_text(cell;
                          autowrap::Bool = true,
                          cell_data_type::DataType = Nothing,
                          cell_first_line_only::Bool = false,
                          column_width::Integer = -1,
                          compact_printing::Bool = true,
                          linebreaks::Bool = false,
                          renderer::Union{Val{:print}, Val{:show}} = Val(:print),
                          kwargs...)

    isstring = cell_data_type <: AbstractString

    # Convert to string using the desired renderer.
    cell_vstr = _render_text(renderer, cell,
                             compact_printing = compact_printing,
                             isstring = isstring,
                             linebreaks = linebreaks || cell_first_line_only)

    # Check if we must autowrap the text.
    autowrap && (cell_vstr = _str_autowrap(cell_vstr, column_width))

    if cell_first_line_only
        cell_vstr  = [first(cell_vstr)]
        cell_lstr  = [textwidth(first(cell_vstr))]
        cell_width = first(cell_lstr)
    else
        cell_lstr  = textwidth.(cell_vstr)
        cell_width = maximum(cell_lstr)
    end

    return cell_vstr, cell_lstr, cell_width
end

function _parse_cell_text(cell::Markdown.MD;
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

@inline _parse_cell_text(cell::Missing; kwargs...) = ["missing"], [7], 7
@inline _parse_cell_text(cell::Nothing; kwargs...) = ["nothing"], [7], 7
@inline _parse_cell_text(cell::UndefInitializer; kwargs...) = ["#undef"], [6], 6

"""
    _process_cell_text(data::Any, i::Int, j::Int, data_cell::Bool, data_str::String, data_len::Int, col_width::Int, crayon::Crayon, alignment::Symbol, cell_alignment::Tuple, highlighters::Tuple)

Process the cell by applying the right alignment and also verifying the
highlighters.

"""
function _process_cell_text(data::Any,
                            i::Int,
                            j::Int,
                            data_cell::Bool,
                            data_str::String,
                            data_len::Int,
                            col_width::Int,
                            crayon::Crayon,
                            alignment::Symbol,
                            cell_alignment::Tuple,
                            highlighters::Tuple)

    if data_cell
        # Check for highlighters.
        for h in highlighters
            if h.f(_getdata(data), i, j)
                crayon = h.fd(h, _getdata(data), i, j)
                break
            end
        end

        # Check for cell alignment override.
        for f in cell_alignment
            aux = f(_getdata(data), i, j)

            if aux ∈ [:l, :c, :r, :L, :C, :R]
                alignment = aux
                break
            end
        end

        # For Markdown cells, we will overwrite alignment and
        # highlighters.
        if isassigned(data,i,j) && (data[i,j] isa Markdown.MD)
            alignment = :l
            crayon = Crayon()
        end
    end

    # Align the string to be printed.
    data_str, data_len = _str_aligned(data_str, alignment, col_width, data_len)

    # Add spacing.
    data_str  = " " * data_str * " "
    data_len += 2

    return data_str, data_len, crayon
end
