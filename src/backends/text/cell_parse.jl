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

Parse the table `cell` of type `T` and return a vector of `String` with the
parsed cell text, one component per line.
"""
function _parse_cell_text(
    cell::Any;
    autowrap::Bool = true,
    cell_data_type::DataType = Nothing,
    cell_first_line_only::Bool = false,
    column_width::Integer = -1,
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    linebreaks::Bool = false,
    renderer::Union{Val{:print}, Val{:show}} = Val(:print),
    kwargs...
)
    isstring = cell_data_type <: AbstractString

    # Convert to string using the desired renderer.
    #
    # Due to the non-specialization of `data`, `cell` here is inferred as `Any`.
    # However, we know that the output of `_render_text` must be a vector of
    # String.
    cell_vstr::Vector{String} = _render_text(
        renderer, cell,
        compact_printing = compact_printing,
        isstring = isstring,
        limit_printing = limit_printing,
        linebreaks = linebreaks || cell_first_line_only
    )

    # Check if we must autowrap the text.
    autowrap && (cell_vstr = _str_autowrap(cell_vstr, column_width))

    # Check if the user only wants the first line.
    cell_first_line_only && (cell_vstr  = [first(cell_vstr)])

    return cell_vstr
end

function _parse_cell_text(
    cell::Markdown.MD;
    column_width::Integer = -1,
    linebreaks::Bool = false,
    has_color::Bool = true,
    kwargs...
)
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
        if !has_color
            str_nc = replace(str_nc, "\n" => "\\n")
            return [str_nc]
        else
            str = replace(str, "\n" => "\\n")
            return [str]
        end
    else
        # Obtain the number of lines and the maximum number of used columns.
        tokens_nc = String.(split(str_nc, '\n'))

        if !has_color
            return tokens_nc
        else
            tokens = String.(split(str, '\n'))
            _reapply_ansi_format!(tokens)
            return tokens
        end
    end
end

function _parse_cell_text(cell::CustomTextCell; kwargs...)
    # Call the API function to reset all the fields in the custom text cell.
    reset!(cell)
    cell_vstr = parse_cell_text(cell; kwargs...)
    return cell_vstr
end

@inline _parse_cell_text(cell::Missing; kwargs...) = ["missing"]
@inline _parse_cell_text(cell::Nothing; kwargs...) = ["nothing"]
@inline _parse_cell_text(cell::UndefInitializer; kwargs...) = ["#undef"]

"""
    _process_cell_text(data::Any, i::Int, j::Int, l::Int, data_cell::Bool, data_str::String, data_len::Int, col_width::Int, crayon::Crayon, alignment::Symbol, highlighters::Ref{Any})

Process the cell by applying the right alignment and also verifying the
highlighters.
"""
function _process_cell_text(
    (@nospecialize data::Any),
    i::Int,
    j::Int,
    l::Int,
    data_cell::Bool,
    custom_cell::Bool,
    data_str::String,
    col_width::Int,
    crayon::Crayon,
    alignment::Symbol,
    (@nospecialize highlighters::Ref{Any})
)
    lstr = -1

    if data_cell
        # Check for highlighters.
        for h in highlighters.x
            if h.f(_getdata(data), i, j)
                crayon = h.fd(h, _getdata(data), i, j)::Crayon
                break
            end
        end

        # For Markdown cells, we will overwrite alignment and highlighters.
        if isassigned(data, i, j) && (data[i, j] isa Markdown.MD)
            alignment = :l
            crayon = Crayon()
            lstr = _printable_textwidth(data_str)
        end
    end

    if custom_cell
        # To align a custom text cell, we need to compute the alignment and
        # cropping data and apply it using the API functions.
        crop_chars, left_pad, right_pad = _str_compute_alignment_and_crop(
            data_str,
            alignment,
            col_width,
            -1
        )

        if crop_chars > 0
            apply_line_padding!(data[i, j], l, 0, 0)
            crop_line!(data[i, j], l, crop_chars + 1)
            append_suffix_to_line!(data[i, j], l, "…")
        else
            apply_line_padding!(data[i, j], l, left_pad, right_pad)
        end

        data_str = get_printable_cell_line(data[i, j], l)::String
    else
        # Align the string to be printed.
        data_str = _str_aligned(data_str, alignment, col_width, lstr)
    end

    return data_str, crayon
end
