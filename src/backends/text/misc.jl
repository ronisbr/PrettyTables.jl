# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Miscellaneous functions related to the Text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Compute the table width.
function _compute_table_width(
    display::Display,
    ptable::ProcessedTable,
    vlines::Union{Symbol, Vector{Int}},
    columns_width::Vector{Int}
)
    # Sum the width of the columns.
    table_width =
        sum(columns_width) +
        2length(columns_width) +
        _count_vlines(ptable, vlines)

    if display.size[2] > 0
        table_width = min(table_width, display.size[2])
    end

    return table_width
end

# Return the default crayon for a cell in a row with identification `row_id` and
# in a column with identification `column_id`.
function _select_default_cell_crayon(
    row_id::Symbol,
    column_id::Symbol,
    header_crayon::Crayon,
    row_name_crayon::Crayon,
    row_name_header_crayon::Crayon,
    rownum_header_crayon::Crayon,
    subheader_crayon::Crayon,
    text_crayon::Crayon
)
    if column_id == :row_number
        if row_id == :__HEADER__
            return rownum_header_crayon
        else
            return text_crayon
        end
    elseif column_id == :row_name
        if row_id == :__HEADER__
            return row_name_header_crayon
        else
            return row_name_crayon
        end
    elseif row_id == :__HEADER__
        return header_crayon
    elseif row_id == :__SUBHEADER__
        return subheader_crayon
    else
        return text_crayon
    end
end

# Compute the column width `column_width` considering the largest cell width in
# the column `largest_cell_width`, the user specification in
# `column_width_specification`, and the maximum and minimum allowed column width
# in `maximum_column_width` and `minimum_column_width`, respectively.
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

# Return the indices in the `table_str` and `ptable` related to the `i`th
# processed row.
function _vcrop_row_number(
    vcrop_mode::Symbol,
    num_rows::Int,
    num_header_rows::Int,
    num_printed_rows::Int,
    i::Int
)
    if (vcrop_mode != :middle)
        return i, i
    else
        if i ≤ num_header_rows
            return i, i
        else
            i = i - num_header_rows

            if i % 2 == 1
                i_ts = div(i, 2, RoundDown) + num_header_rows + 1
                i_pt = i_ts
                return i_ts, i_pt
            else
                Δi = div(i, 2) - 1
                i_ts = num_printed_rows - Δi
                i_pt = num_rows - Δi
                return i_ts, i_pt
            end
        end
    end
end
