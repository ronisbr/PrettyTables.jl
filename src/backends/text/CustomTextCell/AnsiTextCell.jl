## Description #############################################################################
#
# Text cell with ANSI escape sequences.
#
############################################################################################

export AnsiTextCell

mutable struct AnsiTextCell <: AbstractCustomTextCell
    content::String

    # == API Configurations ================================================================

    crop::Int
    left_padding::Int
    right_padding::Int
    suffix::String

    # == Line Breaks =======================================================================

    line_breaks::Bool
    lines::Union{Nothing, Vector{String}}
    decorations::Union{Nothing, Vector{Decoration}}

    # == Constructor =======================================================================

    function AnsiTextCell(content::String)
        return new(content, 0, 0, 0, "", false, nothing, nothing)
    end

    function AnsiTextCell(renderfn::Function; context::Tuple = ())
        # Render the text and create the text cell.
        io = IOBuffer()
        renderfn(IOContext(io, context...))
        rendered = String(take!(io))
        return AnsiTextCell(rendered)
    end
end

############################################################################################
#                                           API                                            #
############################################################################################

function CustomTextCell.add_suffix!(cell::AnsiTextCell, suffix::String)
    cell.suffix = suffix
    return nothing
end

function CustomTextCell.crop!(cell::AnsiTextCell, field_width::Int)
    cell.crop = field_width
    return nothing
end

function CustomTextCell.init!(
    cell::AnsiTextCell,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    line_breaks::Bool = false
)
    cell.crop          = 0
    cell.left_padding  = 0
    cell.right_padding = 0
    cell.line_breaks   = line_breaks
    cell.suffix        = ""
    cell.lines         = nothing
    cell.decorations   = nothing

    if line_breaks
        lines     = String.(split(cell.content, '\n'))
        num_lines = length(lines)

        current_decoration = Decoration()
        decorations        = Decoration[]
        sizehint!(decorations, num_lines)

        for line in lines
            push!(decorations, current_decoration)
            current_decoration = drop_inactive_properties(
                update_decoration(current_decoration, line)
            )
        end

        cell.decorations = decorations
        cell.lines       = lines
    end

    return nothing
end

function CustomTextCell.left_padding!(cell::AnsiTextCell, pad::Int)
    cell.left_padding = pad
    return nothing
end

function CustomTextCell.right_padding!(cell::AnsiTextCell, pad::Int)
    cell.right_padding = pad
    return nothing
end

function CustomTextCell.rendered_cell(cell::AnsiTextCell)
    left_padding_str  = " "^max(cell.left_padding, 0)
    right_padding_str = " "^max(cell.right_padding, 0)
    line_str          = if !cell.line_breaks
        replace(cell.content, '\n' => "\\n")
    else
        cell.content
    end

    cropped_str = first(right_crop(line_str, cell.crop))

    return left_padding_str * cropped_str * right_padding_str * cell.suffix *
        _TEXT__STRING_RESET
end

function CustomTextCell.rendered_cell_line(cell::AnsiTextCell, line::Int)
    if isnothing(cell.lines)
        line == 1 && return CustomTextCell.rendered_cell(cell)
        return ""
    end

    (line > length(cell.lines)) && return ""

    left_padding_str  = " "^max(cell.left_padding, 0)
    right_padding_str = " "^max(cell.right_padding, 0)
    line_str          = cell.lines[line]
    decoration_str    = convert(String, cell.decorations[line])
    cropped_str       = first(right_crop(line_str, cell.crop))

    return decoration_str * left_padding_str * cropped_str * right_padding_str *
        cell.suffix * _TEXT__STRING_RESET
end

function CustomTextCell.printable_cell_text(cell::AnsiTextCell)
    line = cell.line_breaks ? cell.content : replace(cell.content, '\n' => "\\n")
    return remove_decorations(line)
end
