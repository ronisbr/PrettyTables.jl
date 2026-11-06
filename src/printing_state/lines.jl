## Description #############################################################################
#
# Table lines shared by every back end: the line presence resolved from the back end table
# format and the functions that select which line must be drawn between two rows or after
# a column.
#
############################################################################################

"""
    _line_spec_indices(spec::Union{Symbol, Vector{Int}}, n::Int) -> _LineIndices

Convert the specification `spec` of the lines at the column label rows, data rows, or data
columns in a table format, which can be `:all`, `:none`, or a vector with the indices, to
the indices of the rows or columns after which a line must be drawn, considering that there
are `n` of them.
"""
function _line_spec_indices(spec::Union{Symbol, Vector{Int}}, n::Int)
    spec isa Vector{Int} && return _LineIndices(false, n, spec)
    return _LineIndices(spec == :all, n, Int[])
end

"""
    TableLines(tf, table_data::TableData) -> TableLines

Resolve the line presence of the back end table format `tf` for `table_data`. `tf` must
have the line presence fields shared by all the back end table formats (see
`_TABLE_FORMAT_PRESENCE_FIELDS`). The fields that exist only in some back ends are read if
`tf` has them and set to their neutral value otherwise (see [`TableLines`](@ref)).

The line specifications `:all`, `:none`, or a vector of indices are converted to
`_LineIndices` here. Hence, the back ends must call this function once per table and pass
the result to the functions that need the lines.
"""
function TableLines(tf, table_data::TableData)
    T = typeof(tf)

    # The line between the table header and the ruled area is the line at the beginning of
    # the table in the back ends that render the title and the subtitle outside the ruled
    # area. The HTML back end renders them inside it and has a dedicated field.
    horizontal_line_before_column_labels =
        if hasfield(T, :horizontal_line_before_column_labels)
            tf.horizontal_line_before_column_labels::Bool
        else
            tf.horizontal_line_at_beginning::Bool
        end

    # The line after the last column label row is controlled by
    # `horizontal_line_after_column_labels`. Hence, the specification at the column labels
    # only covers the rows before it. Otherwise, the text back end would reserve a display
    # line for a horizontal line that is never drawn.
    horizontal_lines_at_column_labels_spec =
        if hasfield(T, :horizontal_lines_at_column_labels)
            tf.horizontal_lines_at_column_labels::Union{Symbol, Vector{Int}}
        elseif hasfield(T, :horizontal_line_between_column_labels)
            tf.horizontal_line_between_column_labels::Bool ? :all : :none
        else
            :none
        end

    horizontal_lines_at_column_labels = _line_spec_indices(
        horizontal_lines_at_column_labels_spec, length(table_data.column_labels) - 1
    )

    horizontal_lines_at_data_rows = _line_spec_indices(
        tf.horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}, table_data.num_rows
    )

    vertical_lines_at_data_columns = _line_spec_indices(
        tf.vertical_lines_at_data_columns::Union{Symbol, Vector{Int}},
        table_data.num_columns,
    )

    horizontal_line_after_footnotes =
        hasfield(T, :horizontal_line_after_footnotes) ?
        tf.horizontal_line_after_footnotes::Bool : false

    horizontal_line_at_end =
        hasfield(T, :horizontal_line_at_end) ? tf.horizontal_line_at_end::Bool : false

    suppress_vertical_lines_at_column_labels =
        hasfield(T, :suppress_vertical_lines_at_column_labels) ?
        tf.suppress_vertical_lines_at_column_labels::Bool : false

    return TableLines(
        tf.horizontal_line_at_beginning::Bool,
        horizontal_line_before_column_labels,
        horizontal_lines_at_column_labels,
        tf.horizontal_line_at_merged_column_labels::Bool,
        tf.horizontal_line_after_column_labels::Bool,
        horizontal_lines_at_data_rows,
        tf.horizontal_line_before_row_group_label::Bool,
        tf.horizontal_line_after_row_group_label::Bool,
        tf.horizontal_line_after_data_rows::Bool,
        tf.horizontal_line_before_summary_rows::Bool,
        tf.horizontal_line_after_summary_rows::Bool,
        horizontal_line_after_footnotes,
        horizontal_line_at_end,
        tf.vertical_line_at_beginning::Bool,
        tf.vertical_line_after_row_number_column::Bool,
        tf.vertical_line_after_row_label_column::Bool,
        vertical_lines_at_data_columns,
        tf.vertical_line_after_data_columns::Bool,
        tf.vertical_line_after_continuation_column::Bool,
        suppress_vertical_lines_at_column_labels,
    )
end

"""
    _has_any_table_line(lines::TableLines) -> Bool

Return whether at least one table line is drawn according to `lines`.
"""
function _has_any_table_line(lines::TableLines)
    for f in fieldnames(TableLines)
        # Suppressing the vertical lines at the column labels does not draw a line.
        (f == :suppress_vertical_lines_at_column_labels) && continue
        _has_lines(getfield(lines, f)) && return true
    end

    return false
end

"""
    _has_lines(lines::Union{Bool, _LineIndices}) -> Bool

Return whether the line presence field `lines` of [`TableLines`](@ref) draws at least one
line. A specification of rows or columns draws a line if it selects at least one of them,
which is the case for `:all` even if the table has no rows or columns.
"""
_has_lines(lines::Bool) = lines
_has_lines(lines::_LineIndices) = lines.all || !isempty(lines.indices)

"""
    _next_row_section(table_data::TableData, rs::Symbol, i::Int) -> Symbol

Return the row section of the row printed after the row `i` of the section `rs` in
`table_data`, which is `:table_footer` if the ruled area of the table ends there, even if the
table has no footnotes or source notes. `rs` must be `:column_labels`, `:data`,
`:continuation_row`, `:row_group_label`, or `:summary_row`.

The result is obtained from the printing state iterator itself. Hence, it always agrees with
the sequence of rows the iterator emits, and the back ends that must know the next row
section before iterating the current row (for example, to emit the borders of a row before
its cells) do not need to repeat the rules of the iterator.
"""
function _next_row_section(table_data::TableData, rs::Symbol, i::Int)
    # A row group label is always followed by a data row (see `_next`).
    (rs == :row_group_label) && return :data

    # The state before the end of the row `i` of the section `rs`: the iterator returns the
    # `:end_row` action and the state that leads to the next row.
    _, _, state = _next(PrintingTableState(_CONTINUATION_COLUMN, i, 0, rs), table_data)

    # The next action is `:new_row` with the next row section, or `:end_printing` with the
    # section `:table_footer` if the table ends without a footer.
    _, next_rs, _ = _next(state, table_data)

    return next_rs
end

"""
    _horizontal_line_after_row(lines::TableLines, table_data::TableData, rs::Symbol, next_rs::Symbol, i::Int) -> Symbol

Return the field of the back end borders (`:top_line`, `:header_line`, `:middle_line`, or
`:bottom_line`) with the horizontal line that must be drawn between the row of the section
`rs` and the next row, whose section is `next_rs`, or `:none` if no line must be drawn
there. The back ends decide where this line is emitted (after the row above or before the
row below), but each line must be emitted only once.

`i` identifies the row above the line in its section when the rule depends on it:

- the column label row index if `rs` is `:column_labels` and `next_rs` is `:column_labels`;
- the data row index if `rs` is `:data` and the next row is inside the data section
    (`next_rs` is `:data`, `:row_group_label`, or `:continuation_row`);
- the index of the data row before the first row printed after the continuation row if `rs`
    is `:continuation_row` and `next_rs` is `:data`, which happens in the middle cropping,
    since the line above the first row printed after the continuation row is the line after
    that data row;
- the footnote index if `rs` is `:table_footer` and the row is a footnote, or 0 if it is
    the source notes.

It is ignored otherwise. Notice that the index in the printing state after the `:end_row`
action of a row has these values.

`rs` can also be `:table_header`, in which case the line is the one before the first row of
the ruled area: the line between the table header (title and subtitle) and the ruled area if
the table has a header, or the line at the beginning of the table otherwise. Hence, the back
ends pass `:table_header` for the first row of the ruled area without checking whether the
table has a header. `rs` can also be `:none`, which is equivalent to `:table_header` for a
table without a header. The lines under the merged column labels, which are drawn after
every column label row but the last one, are not handled here because each back end draws
them differently.

The line after the last row of the ruled area, which precedes the table footer, uses the
bottom line design.
"""
function _horizontal_line_after_row(
    lines::TableLines, table_data::TableData, rs::Symbol, next_rs::Symbol, i::Int
)
    # == Lines Outside the Ruled Area ======================================================

    # No line is drawn between the title and the subtitle or between the table footer rows,
    # except the line after the footnotes.
    (next_rs == :table_header) && return :none

    if rs == :table_footer
        return (
            lines.horizontal_line_after_footnotes &&
            _has_footnotes(table_data) &&
            (i == length(table_data.footnotes))
        ) ? :middle_line : :none
    end

    # The ruled area is empty if the table has no rows at all.
    (next_rs ∈ (:table_footer, :end_printing)) &&
        (rs ∈ (:none, :table_header)) &&
        return :none

    # == Lines at the Beginning of the Ruled Area ==========================================

    if rs ∈ (:none, :table_header)
        # The line before the first row of the ruled area is the line between the table
        # header and the ruled area if the table has a header, which the HTML back end
        # renders inside the ruled area, or the line at the beginning of the table otherwise.
        hline = if (rs == :table_header) && _has_table_header(table_data)
            lines.horizontal_line_before_column_labels
        else
            lines.horizontal_line_at_beginning
        end

        return hline ? :top_line : :none
    end

    # == Lines Inside the Ruled Area =======================================================

    role = if rs == :column_labels
        if next_rs == :column_labels
            (i ∈ lines.horizontal_lines_at_column_labels) ? :header_line : :none

        elseif lines.horizontal_line_after_column_labels
            :header_line

        elseif (next_rs == :row_group_label) && lines.horizontal_line_before_row_group_label
            :middle_line

        else
            :none
        end

    elseif rs == :row_group_label
        lines.horizontal_line_after_row_group_label ? :middle_line : :none

    elseif rs == :summary_row
        # No line is drawn between the summary rows.
        ((next_rs != :summary_row) && lines.horizontal_line_after_summary_rows) ?
        :middle_line : :none

    elseif next_rs == :row_group_label
        # The line before a row group label is drawn if the user wants it or if the data row
        # above the label has a horizontal line, which is drawn as the line before the label.
        (
            lines.horizontal_line_before_row_group_label ||
            (i ∈ lines.horizontal_lines_at_data_rows)
        ) ? :middle_line : :none

    elseif next_rs ∈ (:data, :continuation_row)
        # Here, both rows are inside the data section. Notice that the row above the first
        # row printed after the continuation row owns the line between them. However, the
        # line after a data row is owned by the row group label of the next data row, if
        # any. Hence, it is not drawn if the continuation row is printed instead of the
        # label.
        (
            (i ∈ lines.horizontal_lines_at_data_rows) && !(
                (rs == :data) &&
                (next_rs == :continuation_row) &&
                _print_row_group_label(table_data, i + 1)
            )
        ) ? :middle_line : :none

    else
        # Here, the data section ends. Notice that a line selected by
        # `horizontal_lines_at_data_rows` is internal to the data section. Hence, only
        # `horizontal_line_after_data_rows` controls the line after the last data row.
        (
            lines.horizontal_line_after_data_rows ||
            ((next_rs == :summary_row) && lines.horizontal_line_before_summary_rows)
        ) ? :middle_line : :none
    end

    # == Line at the End of the Ruled Area =================================================

    if next_rs ∈ (:table_footer, :end_printing)
        ((role != :none) || lines.horizontal_line_at_end) && return :bottom_line
    end

    return role
end

"""
    _line_between_column_label_rows(lines::TableLines, table_data::TableData, rs::Symbol, i::Int) -> Symbol

Return the field of the back end borders with the horizontal line that must be drawn after
the row `i` of the section `rs` if it is a column label row followed by another one, or
`:none` otherwise (see [`_horizontal_line_after_row`](@ref)). The back ends that draw this
line as the bottom border of each unmerged cell of the row, since the merged column labels
have their own line, call this function when the row begins.
"""
function _line_between_column_label_rows(
    lines::TableLines, table_data::TableData, rs::Symbol, i::Int
)
    ((rs == :column_labels) && (i < length(table_data.column_labels))) || return :none
    return _horizontal_line_after_row(lines, table_data, rs, rs, i)
end

"""
    _vertical_line_after_column(lines::TableLines, table_data::TableData, column::Symbol, j::Int = 0) -> Symbol

Return the field of the back end borders (`:center_line` or `:right_line`) with the vertical
line that must be drawn after the printed `column` of `table_data`, or `:none` if no line
must be drawn there. `column` can be:

- `:row_number`: The row number column.
- `:row_label`: The row label column.
- `:data`: The data column `j`, which is the index of the printed data column.
- `:continuation`: The continuation column, printed if the table is horizontally cropped.
- `:last`: The last printed column of the table, whichever it is. Hence, the result is the
    line at the right edge of the table, which is drawn after a row group label.

The line at the beginning of the table is `vertical_line_at_beginning` and it is always the
left line of the borders.

The line after the last printed data column is `vertical_line_after_data_columns`, even if
this column is in `vertical_lines_at_data_columns`. It is the right line if the table is not
horizontally cropped, or a center line if the continuation column follows it.
"""
function _vertical_line_after_column(
    lines::TableLines, table_data::TableData, column::Symbol, j::Int = 0
)
    if column == :row_number
        return lines.vertical_line_after_row_number_column ? :center_line : :none

    elseif column == :row_label
        return lines.vertical_line_after_row_label_column ? :center_line : :none

    elseif column == :continuation
        return lines.vertical_line_after_continuation_column ? :right_line : :none

    elseif column == :last
        vline = if _is_horizontally_cropped(table_data)
            lines.vertical_line_after_continuation_column
        else
            lines.vertical_line_after_data_columns
        end

        return vline ? :right_line : :none
    end

    # == Data Columns ======================================================================

    if j < _number_of_printed_data_columns(table_data)
        return (j ∈ lines.vertical_lines_at_data_columns) ? :center_line : :none
    end

    lines.vertical_line_after_data_columns || return :none

    # If the table has a continuation column, the line after the data columns is not at the
    # right edge of the table.
    return _is_horizontally_cropped(table_data) ? :center_line : :right_line
end

# Actions of the printing state iterator that emit a cell in each printed column (see
# `_vertical_line_after_cell`).
const _ROW_NUMBER_COLUMN_CELL_ACTIONS = (
    :row_number_label,
    :row_number,
    :row_number_vertical_continuation_cell,
    :summary_row_number,
)

const _ROW_LABEL_COLUMN_CELL_ACTIONS = (
    :stubhead_label, :row_label, :row_label_vertical_continuation_cell, :summary_row_label
)

const _DATA_COLUMN_CELL_ACTIONS = (
    :column_label, :data, :vertical_continuation_cell, :summary_row_cell
)

const _CONTINUATION_COLUMN_CELL_ACTIONS = (
    :horizontal_continuation_cell, :diagonal_continuation_cell
)

"""
    _vertical_line_after_cell(lines::TableLines, table_data::TableData, action::Symbol, j::Int) -> Symbol

Return the field of the back end borders with the vertical line that must be drawn after the
cell emitted by the `action` of the printing state iterator, or `:none` if no line must be
drawn there or if `action` does not emit a cell (see [`_vertical_line_after_column`](@ref)).
`j` must be the index of the printed data column of the cell if it is in a data column,
which is the last spanned column for a merged column label. It is ignored otherwise.

The row group labels span the entire table. Hence, the line after them is the line at the
right edge of the table.
"""
function _vertical_line_after_cell(
    lines::TableLines, table_data::TableData, action::Symbol, j::Int
)
    column = if action ∈ _ROW_NUMBER_COLUMN_CELL_ACTIONS
        :row_number
    elseif action ∈ _ROW_LABEL_COLUMN_CELL_ACTIONS
        :row_label
    elseif action ∈ _DATA_COLUMN_CELL_ACTIONS
        :data
    elseif action ∈ _CONTINUATION_COLUMN_CELL_ACTIONS
        :continuation
    elseif action == :row_group_label
        :last
    else
        return :none
    end

    return _vertical_line_after_column(lines, table_data, column, j)
end
