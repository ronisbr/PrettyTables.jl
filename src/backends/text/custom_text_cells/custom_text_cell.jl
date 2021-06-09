# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Custom cells for the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    append_suffix_to_line!(c::CustomTextCell, l::Int, suffix::String)

Append the `suffix` to the line `l` of the custom cell text `c`.
"""
function append_suffix_to_line!(c::CustomTextCell, l::Int, suffix::String)
    error("The method `append_suffix_to_line!` is not defined for `$(typeof(c))`.")
end

"""
    apply_line_padding!(c::CustomTextCell, l::Int, left_pad::Int, right_pad::Int)

Apply to the line `l` of the custom text cell `c` the padding with `left_pad`
spaces in the left and `right_pad` spaces in the right.
"""
function apply_line_padding!(c::CustomTextCell, l::Int, left_pad::Int, right_pad::Int)
    error("The method `apply_line_padding` is not defined for `$(typeof(c))`.")
end

"""
    crop_line!(c::CustomTextCell, l::Int, num::Int)

Crop `num` characters from the line `l` of the custom text cell `c`. The number
of cropped characters must consider the left and right alignment paddings.
"""
function crop_line!(c::CustomTextCell, l::Int, num::Int)
    error("The method `crop_line!` is not defined for `$(typeof(c))`.")
end

"""
    get_printable_cell_line(c::CustomTextCell, l::Int)

Return the printable line `l` of the custom text cell `c`. The printable cell
line must consider the left and right alignment paddings.
"""
function get_printable_cell_line(c::CustomTextCell, l::Int)
    error("The method `get_printable_cell_line` is not defined for `$(typeof(c))`.")
end

"""
    get_rendered_line(c::CustomTextCell, l::Int)

Return the rendered line `l` of the custom text cell `l`.
"""
function get_rendered_line(c::CustomTextCell, l::Int)
    error("The method `get_rendered_line` is not defined for `$(typeof(c))`.")
end

"""
    parse_cell_text(c::CustomTextCell; kwargs...)

Parse the cell text and return a vector of `String` with the printable cell
text, where each element in the vector is a new line.

The returned data must contain **only** the printable characters.

The following keyword arguments are passed to this function, which is called
during the cell parsing phase. Those options are related to the input
configuration of `pretty_table`, and the user must choose whether or not support
them.

- `autowrap::Bool`: If `true`, the user wants to wrap the text in the cell. In
    this case, the option `column_width` contains the column width so that the
    text can be wrapped into multiple lines.
- `cell_first_line_only::Bool`: If `true`, the user only wants the first line.
- `column_width::Integer`: The column width.
- `compact_printing::Bool`: If `true`, the user wants compact printing (see
    `:compact` options of `IOContext`).
- `limit_printing::Bool`: If `true`, the user wants the cells to be converted
    using the option `:limit => true` in `IOContext`.
- `linebreaks::Bool`: If `true`, the user wants line breaks inside the cells.
- `renderer::Union{Val{:print}, Val{:show}}`: The render that the user wants to
    convert the cells to strings.
"""
function parse_cell_text(c::CustomTextCell; kwargs...)
    error("The method `parse_cell_text` is not defined for `$(typeof(c))`.")
end

"""
    reset!(c::CustomTextCell)

Reset all fields in the custom text cell `c`.

This function is not required for the API. It is called before parsing the
custom text cell.
"""
reset!(c::CustomTextCell) = nothing
