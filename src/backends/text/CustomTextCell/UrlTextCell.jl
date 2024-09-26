## Description #############################################################################
#
# Text cell to render a URL.
#
############################################################################################

export UrlTextCell

mutable struct UrlTextCell <: AbstractCustomTextCell
    text::String
    url::String

    # == API Configurations ================================================================

    crop::Int
    left_padding::Int
    right_padding::Int
    suffix::String

    # == Constructor =======================================================================

    function UrlTextCell(text::String, url::String)
        return new(text, url, 0, 0, 0, "")
    end
end

############################################################################################
#                                           API                                            #
############################################################################################

function CustomTextCell.add_sufix!(cell::UrlTextCell, sufix::String)
    cell.suffix = sufix
    return nothing
end

function CustomTextCell.crop!(cell::UrlTextCell, field_width::Int)
    cell.crop = field_width
    return nothing
end

function CustomTextCell.init!(
    cell::UrlTextCell,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    line_breaks::Bool = false
)
    cell.crop          = 0
    cell.left_padding  = 0
    cell.right_padding = 0

    return nothing
end

function CustomTextCell.left_padding!(cell::UrlTextCell, pad::Int)
    cell.left_padding = pad
    return nothing
end

function CustomTextCell.right_padding!(cell::UrlTextCell, pad::Int)
    cell.right_padding = pad
    return nothing
end

function CustomTextCell.rendered_cell(cell::UrlTextCell)
    text = CustomTextCell.printable_cell_text(cell)
    rendered_cell = "\e]8;;$(cell.url)\e\\$(text)\e]8;;\e\\"
    return rendered_cell
end

function CustomTextCell.printable_cell_text(cell::UrlTextCell)
    left_padding_str  = " "^max(cell.left_padding, 0)
    right_padding_str = " "^max(cell.right_padding, 0)
    full_str          = left_padding_str * cell.text * right_padding_str
    cropped_str       = first(right_crop(full_str, cell.crop)) * cell.suffix

    return cropped_str
end
