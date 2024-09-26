## Description #############################################################################
#
# Text cell with ANSI escape sequences.
#
############################################################################################

export AnsiTextCell

mutable struct AnsiTextCell <: AbstractCustomTextCell
    content::String

    # == Padding ===========================================================================

    left_padding::Int
    right_padding::Int

    # == Line Breaks =======================================================================

    line_breaks::Bool
    lines::Union{Nothing, Vector{String}}
    decorations::Union{Nothing, Vector{Decoration}}

    # == Constructor =======================================================================

    function AnsiTextCell(content::String)
        return new(content, 0, 0, false, nothing, nothing)
    end
end

############################################################################################
#                                           API                                            #
############################################################################################

function CustomTextCell.crop!(cell::AnsiTextCell, field_width::Int)
    cell.content = first(right_crop(cell.content, field_width))
    return nothing
end

function CustomTextCell.init!(
    cell::AnsiTextCell,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    line_breaks::Bool = false
)
    cell.left_padding  = 0
    cell.right_padding = 0
    cell.line_breaks   = line_breaks

    if line_breaks
        lines     = String.(split(cell.content, '\n'))
        num_lines = length(lines)

        current_decoration = Decoration()
        decorations        = Decoration[]
        sizehint!(decorations, num_lines)

        for line in lines
            push!(decorations, current_decoration)
            current_decoration = update_decoration(current_decoration, line)
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

    return left_padding_str * line_str * _TEXT__STRING_RESET * right_padding_str
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

    return decoration_str * left_padding_str * line_str * right_padding_str *
        _TEXT__STRING_RESET
end

CustomTextCell.printable_cell_text(cell::AnsiTextCell) = remove_decorations(cell.content)
