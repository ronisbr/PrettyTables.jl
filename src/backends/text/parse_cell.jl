## Description #############################################################################
#
# Functions to parse the table cells in text back end.
#
############################################################################################

# Parse the table `cell` of type `T` and return a vector of `String` with the parsed cell
# text, one component per line.
function _text_parse_cell(
    @nospecialize(io::IOContext),
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
    # Due to the non-specialization of `data`, `cell` here is inferred as `Any`. However,
    # we know that the output of `_text_render_cell` must be a vector of String.
    cell_vstr::Vector{String} = _text_render_cell(
        renderer,
        io,
        cell,
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

function _text_parse_cell(
    @nospecialize(io::IOContext),
    cell::Markdown.MD;
    column_width::Integer = -1,
    linebreaks::Bool = false,
    has_color::Bool = true,
    kwargs...
)
    # The maximum size for Markdowns cells is 80.
    column_width ≤ 0 && (column_width = 80)

    # == Render Markdown ===================================================================

    # First, we need to render the Markdown with all the colors.
    str = sprint(Markdown.term, cell, column_width; context = :color => true)

    if !linebreaks
        if !has_color
            str_nc = replace(remove_decorations(str), "\n" => "\\n")
            return [str_nc]
        else
            str = replace(str, "\n" => "\\n")
            return [str]
        end
    else
        # Obtain the number of lines and the maximum number of used columns.
        tokens = String.(split(str, '\n'))

        if !has_color
            return remove_decorations.(tokens)
        else
            # Here, we need to take the composed decoration at the end of line and apply it
            # to the next one because we need to reset the entire decoration after printing
            # the cell.
            processed_tokens = similar(tokens)
            decoration = Decoration()

            for l = 1:length(tokens)
                # If a property of the last decoration was inactive, we should drop it to
                # avoid unnecessary escape sequences.
                decoration = drop_inactive_properties(decoration)

                processed_tokens[l] = convert(String, decoration) * tokens[l] * "\e[0m"

                # Get the composed decoration of the current line.
                decoration = update_decoration(decoration, tokens[l])
            end

            return processed_tokens
        end
    end
end

function _text_parse_cell(@nospecialize(io::IOContext), cell::CustomTextCell; kwargs...)
    # Call the API function to reset all the fields in the custom text cell.
    reset!(cell)
    cell_vstr = parse_cell_text(cell; kwargs...)
    return cell_vstr
end

_text_parse_cell(@nospecialize(io::IOContext), cell::Missing; kwargs...) = ["missing"]
_text_parse_cell(@nospecialize(io::IOContext), cell::Nothing; kwargs...) = ["nothing"]
_text_parse_cell(@nospecialize(io::IOContext), cell::UndefinedCell; kwargs...) = ["#undef"]
