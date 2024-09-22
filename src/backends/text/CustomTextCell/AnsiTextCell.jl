## Description #############################################################################
#
# Text cell with ANSI escape sequences.
#
############################################################################################

export AnsiTextCell

mutable struct AnsiTextCell <: AbstractCustomTextCell
    content::String

    left_padding::Int
    right_padding::Int

    function AnsiTextCell(content::String)
        return new(content, 0, 0)
    end
end

############################################################################################
#                                           API                                            #
############################################################################################

function CustomTextCell.crop!(cell::AnsiTextCell, field_width::Int)
    cell.content = first(right_crop(cell.content, field_width))
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

function CustomTextCell.rendered_cell(
    cell::AnsiTextCell,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    left_padding_str  = " "^max(cell.left_padding, 0)
    right_padding_str = " "^max(cell.right_padding, 0)
    return left_padding_str * cell.content * _TEXT__STRING_RESET * right_padding_str
end

function CustomTextCell.printable_cell_text(
    cell::AnsiTextCell,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    return remove_decorations(CustomTextCell.rendered_cell(cell, context, renderer))
end

function CustomTextCell.reset!(cell::AnsiTextCell)
    cell.left_padding = 0
    cell.right_padding = 0
    return nothing
end
