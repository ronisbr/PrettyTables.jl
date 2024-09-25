## Description #############################################################################
#
# Sub-module that defines a custom text cell for the text back end.
#
############################################################################################

module CustomTextCell

export AbstractCustomTextCell

############################################################################################
#                                          Types                                           #
############################################################################################

abstract type AbstractCustomTextCell end

############################################################################################
#                                        Functions                                         #
############################################################################################

function crop!(cell::AbstractCustomTextCell, field_width::Int)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `crop!`.")
end

function init!(
    cell::AbstractCustomTextCell,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `init!`.")
end

function left_padding!(cell::AbstractCustomTextCell, pad::Int)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `left_padding!`.")
end

function right_padding!(cell::AbstractCustomTextCell, pad::Int)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `right_padding!`.")
end

function rendered_cell(cell::AbstractCustomTextCell)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `rendered_cell`.")
end

function rendered_cell_line(cell::AbstractCustomTextCell, line::Int)
    line > 1 && return ""
    return rendered_cell(cell)
end

function printable_cell_text(cell::AbstractCustomTextCell)
    error("The custom text cell type `$(typeof(cell))` does not implement the API function `printable_cell_text`.")
end

end
