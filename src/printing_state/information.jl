## Description #############################################################################
#
# Functions to retrieve table information.
#
############################################################################################

"""
    _column_label_limits(table_data::TableData, i::Int, j::Int) -> Tuple{Int, Int}

Return the limits of the column label cell at `(i, j)` in `table_data`. If the cell is not
merged, the limits are just `(j, j)`. If the cell is merged, the limits are the start and
end of the merged cell, which is defined by the `merge_column_label_cells` field of
`table_data`.
"""
function _column_label_limits(table_data::TableData, i::Int, j::Int)
    isnothing(table_data.merge_column_label_cells) && return j, j

    # Check if we are in a merged column.
    for mc in table_data.merge_column_label_cells
        if mc.i == i && (mc.j <= j <= mc.j + mc.column_span - 1)
            return mc.j, mc.j + mc.column_span - 1
        end
    end

    # If we are not in a merged column, the limits are just the cell itself.
    return j, j
end

"""
    _current_table_row_section_info(rs::Symbol, action::Symbol, i::Number) -> String

Generate a descriptive string for the current table row section specified by the `rs` and
`action` parameters, along with the row index `i`.
"""
function _current_table_row_section_info(rs::Symbol, action::Symbol, i::Number)
    section = get(_TABLE_ROW_SECTION_NAMES, rs, "Unknown Section")
    section_desc = "Row $i"

    if rs == :table_header
        # NOTE: The `else` branches are required. Without them the chain evaluates to
        # `nothing` for any other action, and the `isempty` below would throw a `MethodError`
        # instead of returning the `String` this function promises.
        section_desc = if action == :title
            "Title"
        elseif action == :subtitle
            "Subtitle"
        else
            ""
        end

    elseif rs == :table_footer
        section_desc = if action == :footnote
            "Footnote $i"
        elseif action == :source_notes
            "Source Notes"
        else
            ""
        end

    elseif rs == :continuation_row
        section_desc = ""
    end

    return isempty(section_desc) ? section : "$section: $section_desc"
end

"""
    _has_footnotes(table_data::TableData) -> Bool

Return whether `table_data` has footnotes.
"""
function _has_footnotes(table_data::TableData)
    return !isnothing(table_data.footnotes)
end

"""
    _has_merged_cells(table_data::TableData, i::Int) -> Bool

Return whether `table_data` has merged cells in line `i`.
"""
function _has_merged_cells(table_data::TableData, i::Int)
    isnothing(table_data.merge_column_label_cells) && return false

    for mc in table_data.merge_column_label_cells
        mc.i == i && return true
    end

    return false
end

"""
    _has_row_group_labels(table_data::TableData)

Return whether `table_data` has row group labels.
"""
function _has_row_group_labels(table_data::TableData)
    return !isnothing(table_data.row_group_labels)
end

"""
    _has_row_labels(table_data::TableData) -> Bool

Return whether `table_data` has row labels.
"""
function _has_row_labels(table_data::TableData)
    return !isnothing(table_data.row_labels) || _has_summary_rows(table_data)
end

"""
    _has_summary_rows(table_data::TableData) -> Bool

Return whether `table_data` has summary rows.
"""
_has_summary_rows(table_data::TableData) = !isnothing(table_data.summary_rows)

"""
    _is_horizontally_cropped(table_data::TableData) -> Bool

Return whether `table_data` is horizontally cropped, meaning that a continuation column must
be printed.
"""
function _is_horizontally_cropped(table_data::TableData)
    # NOTE: Like for the rows, `maximum_number_of_columns == 0` means "crop to zero
    # columns", whereas a negative value means "no limit".
    return table_data.maximum_number_of_columns >= 0 ?
           table_data.num_columns > table_data.maximum_number_of_columns : false
end

"""
    _is_column_label_cell_merged(table_data::TableData, i::Int, j::Int) -> Bool

Return whether the cell at `(i, j)` is a merged column label cell.
"""
function _is_column_label_cell_merged(table_data::TableData, i::Int, j::Int)
    j₀, j₁ = _column_label_limits(table_data, i, j)
    return j₀ != j₁
end

"""
    _is_vertically_cropped(table_data::TableData) -> Bool

Return whether `table_data` is vertically cropped, meaning that a continuation row must be
printed.
"""
function _is_vertically_cropped(table_data::TableData)
    # NOTE: For rows, `maximum_number_of_rows == 0` means "crop to zero rows", whereas a
    # negative value means "no limit". This is the convention `_next` and
    # `_number_of_printed_data_rows` use. Testing for `> 0` here made a table cropped to zero
    # rows be reported as not cropped, so the data columns were sized without accounting for
    # the continuation row.
    return table_data.maximum_number_of_rows >= 0 ?
           table_data.num_rows > table_data.maximum_number_of_rows : false
end

"""
    _number_of_printed_columns(table_data::TableData) -> Int

Return the number of printed columns in `table_data`, which includes the continuation column.
"""
function _number_of_printed_columns(table_data::TableData)
    # NOTE: `maximum_number_of_columns < 0` means "no limit" and `0` means "crop to zero
    # columns", exactly like in `_next` and in `_number_of_printed_data_columns`. All of
    # them must agree. Otherwise, the back ends would lay out a number of columns different
    # from the one the iterator feeds them.
    data_columns =
        table_data.maximum_number_of_columns >= 0 ?
        # If we are cropping the table, we have one additional column for the continuation
        # characters.
        min(table_data.maximum_number_of_columns + 1, table_data.num_columns) :
        table_data.num_columns

    total_columns =
        data_columns + table_data.show_row_number_column + _has_row_labels(table_data)

    return total_columns
end

"""
    _number_of_printed_data_columns(table_data::TableData) -> Int

Return the number of printed data columns.
"""
function _number_of_printed_data_columns(table_data::TableData)
    data_columns =
        table_data.maximum_number_of_columns >= 0 ?
        min(table_data.maximum_number_of_columns, table_data.num_columns) :
        table_data.num_columns

    return data_columns
end

"""
    _number_of_printed_data_rows(table_data::TableData) -> Int

Return the number of printed data rows.
"""
function _number_of_printed_data_rows(table_data::TableData)
    data_rows =
        table_data.maximum_number_of_rows >= 0 ?
        min(table_data.maximum_number_of_rows, table_data.num_rows) : table_data.num_rows

    return data_rows
end

"""
    _print_row_group_label(table_data::TableData, i::Int) -> Bool

Return whether we must print a row group label of `table_data` in line `i`.
"""
function _print_row_group_label(table_data::TableData, i::Int)
    !_has_row_group_labels(table_data) && return false

    for rg in table_data.row_group_labels
        first(rg) == i && return true
    end

    return false
end

"""
    _line_spec_indices(spec::Union{Symbol, Vector{Int}}, n::Int) -> Union{UnitRange{Int}, Vector{Int}}

Convert the specification `spec` of the lines at the data rows or data columns in a table
format, which can be `:all`, `:none`, or a vector with the indices, to the indices of the
rows or columns after which a line must be drawn, considering that there are `n` of them.
"""
function _line_spec_indices(spec::Union{Symbol, Vector{Int}}, n::Int)
    spec isa Vector{Int} && return spec
    return spec == :all ? (1:n) : (1:0)
end

"""
    _horizontal_line_after_row(tf, rs::Symbol, next_rs::Symbol, i::Int, horizontal_lines_at_data_rows::AbstractVector{Int}) -> Symbol

Return the field of the borders in the table format `tf` with the horizontal line that must
be drawn after the current row, or `:none` if no line must be drawn. `rs` and `next_rs` are
the row sections of the current and next rows, `i` is the row index of the printing state
after the current row ends, and `horizontal_lines_at_data_rows` contains the data rows after
which a line must be drawn.

The lines under the merged column labels, which are drawn after every column label row but
the last one, are not handled here because each back end draws them differently.

Notice that the printing state resets `i` when the data section ends. Hence, only
`horizontal_line_after_data_rows` controls the line after the last data row.
"""
function _horizontal_line_after_row(
    tf,
    rs::Symbol,
    next_rs::Symbol,
    i::Int,
    horizontal_lines_at_data_rows::AbstractVector{Int}
)
    role = if (rs == :table_header) &&
        (next_rs != :table_header) &&
        tf.horizontal_line_at_beginning
        :top_line

    elseif rs == :column_labels
        ((next_rs != :column_labels) && tf.horizontal_line_after_column_labels) ?
            :header_line : :none

    elseif (next_rs == :row_group_label) && tf.horizontal_line_before_row_group_label
        :middle_line

    elseif (rs == :data) && (i ∈ horizontal_lines_at_data_rows)
        :middle_line

    elseif (
        (rs ∈ (:data, :continuation_row)) &&
        (next_rs ∈ (:summary_row, :table_footer, :end_printing)) &&
        tf.horizontal_line_after_data_rows
    )
        :middle_line

    elseif (
        (rs ∈ (:data, :continuation_row)) &&
        (next_rs == :summary_row) &&
        tf.horizontal_line_before_summary_rows
    )
        :middle_line

    elseif (rs == :row_group_label) && tf.horizontal_line_after_row_group_label
        :middle_line

    elseif (rs == :summary_row) &&
        (next_rs != :summary_row) &&
        tf.horizontal_line_after_summary_rows
        :middle_line

    else
        :none
    end

    # A line before the end of the table is the bottom line.
    ((role != :none) && (next_rs ∈ (:table_footer, :end_printing))) && return :bottom_line

    return role
end

"""
    _merged_cell_span(table_data::TableData, cell::MergeCells, j::Int) -> Int

Return the number of printed data columns spanned by the merged column label `cell`, which
starts at the data column `j` of `table_data`. The span is limited to the printed data
columns because the table can be horizontally cropped.
"""
function _merged_cell_span(table_data::TableData, cell::MergeCells, j::Int)
    return min(cell.column_span, _number_of_printed_data_columns(table_data) - j + 1)
end
