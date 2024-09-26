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

function add_sufix!(cell::AbstractCustomTextCell, sufix::String)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `add_sufix!`.")
end

"""
    crop!(cell::AbstractCustomTextCell, field_width::Int) -> Nothing

Rigth crop a field with display width `field_width` from `cell`. This cropping must be
applied to either the entire cell or to a specific line.
"""
function crop!(cell::AbstractCustomTextCell, field_width::Int)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `crop!`.")
end

"""
    init!(cell::AbstractCustomTextCell, context::IOContext, renderer::Union{Val{:print}, Val{:show}}) -> Nothing

Initialize the custom text `cell` using the `context` and `renderer`.

# Keywords

- `line_breaks`: If `true`, the cell will be rendered into multiple lines.
"""
function init!(
    cell::AbstractCustomTextCell,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}};
    line_breaks::Bool = false
)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `init!`.")
end

"""
    left_padding!(cell::AbstractCustomTextCell, pad::Int) -> Nothing

Apply a left padding of `pad` display characters to `cell`.
"""
function left_padding!(cell::AbstractCustomTextCell, pad::Int)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `left_padding!`.")
end

"""
    right_padding!(cell::AbstractCustomTextCell, pad::Int) -> Nothing

Apply a right padding of `pad` display characters to `cell`.
"""
function right_padding!(cell::AbstractCustomTextCell, pad::Int)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `right_padding!`.")
end

"""
    rendered_cell(cell::AbstractCustomTextCell) -> String

Render all the lines in the `cell`, applying the specifications for right and left padding
and cropping.
"""
function rendered_cell(cell::AbstractCustomTextCell)
    error("The custom text cell of type `$(typeof(cell))` does not implement the API function `rendered_cell`.")
end

"""
    rendered_cell_line(cell::AbstractCustomTextCell, line::Int) -> String

Render the `line` in the `cell`, applying the specifications for right and left padding
and cropping.
"""
function rendered_cell_line(cell::AbstractCustomTextCell, line::Int)
    line > 1 && return ""
    return rendered_cell(cell)
end

"""
    printable_cell_text(cell::AbstractCustomTextCell) -> String

Render only the printable characters in `cell`. Here, we must not consider the
specifications for right and left padding or cropping.

!!! note

    If line breaks are not supported, `\n` must be escaped.
"""
function printable_cell_text(cell::AbstractCustomTextCell)
    error("The custom text cell type `$(typeof(cell))` does not implement the API function `printable_cell_text`.")
end

end
