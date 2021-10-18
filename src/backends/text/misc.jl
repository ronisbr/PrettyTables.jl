# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Miscellaneous functions related to the Text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    _update_column_width(column_width::Int, largest_cell_width::Int, column_width_specification::Int, maximum_column_width::Int, minimum_column_width::Int)

Compute the column width `column_width` considering the largest cell width in
the column `largest_cell_width`, the user specification in
`column_width_specification`, and the maximum and minimum allowed column width
in `maximum_column_width` and `minimum_column_width`, respectively.
"""
function _update_column_width(
    column_width::Int,
    largest_cell_width::Int,
    column_width_specification::Int,
    maximum_column_width::Int,
    minimum_column_width::Int
)
    if column_width_specification ≤ 0
        # The columns width must never be lower than 1.
        column_width = max(column_width, largest_cell_width)

        # Make sure that the maximum column width is respected.
        if (maximum_column_width > 0) && (maximum_column_width < column_width)
            column_width = maximum_column_width
        end

        # Make sure that the minimum column width is respected.
        if (minimum_column_width > 0) && (minimum_column_width > column_width)
            column_width = minimum_column_width
        end
    else
        column_width = column_width_specification
    end

    return column_width
end
