## Description ############################################################################
#
# Word Back End: Render the table to a WriteDocx.Table object.
#
############################################################################################

"""
    _docx__render_table(pspec::PrintingSpec, opts::DocxPrintOptions) -> W.Table

Render the complete table described by `pspec` using the PrettyTables.jl printing iterator.
The cells are accumulated in [`DocxRow`](@ref)s during the single pass over the iterator and
converted to the Word objects afterward, when every border of every cell is known.

# Options

The fields of `opts` are:

- `highlighters::Vector{AbstractHighlighter}`: Highlighters to apply to the data cells.
    (**Default**: `AbstractHighlighter[]`)
- `style::DocxTableStyle`: Text and cell style for each table section.
    (**Default**: `DocxTableStyle()`)
- `table_format::DocxTableFormat`: Border configuration.
    (**Default**: `DocxTableFormat()`)
"""
# This method must be the only caller of the rendering body and it must not be inlined into
# `_docx__print`. Otherwise, each keyword set would pay for a new entry point into the body
# (see `DocxPrintOptions`).
@noinline function _docx__render_table(pspec::PrintingSpec, opts::DocxPrintOptions)
    return _docx__render_table_core(pspec, opts)
end

function _docx__render_table_core(pspec::PrintingSpec, opts::DocxPrintOptions)
    # == Unpack the Options ================================================================

    highlighters = _docx__native_highlighters(opts.highlighters)
    style        = opts.style
    table_format = opts.table_format
    borders      = table_format.borders

    table_data = pspec.table_data

    num_printed_cols      = _number_of_printed_columns(table_data)
    num_printed_data_cols = _number_of_printed_data_columns(table_data)

    context  = pspec.context
    renderer = pspec.renderer === :show ? Val(:show) : Val(:print)

    # Reusable render buffer: one allocation per table instead of three per cell.
    rctx = RenderContext(context)

    # == Iterator Setup ====================================================================

    # Preprocess the `Union{Symbol, Vector{Int}}` fields into concrete index iterables.
    horizontal_lines_at_data_rows = if table_format.horizontal_lines_at_data_rows isa Symbol
        table_format.horizontal_lines_at_data_rows == :all ? (1:typemax(Int)) : (1:0)
    else
        table_format.horizontal_lines_at_data_rows::Vector{Int}
    end

    vertical_lines_at_data_columns =
        if table_format.vertical_lines_at_data_columns isa Symbol
            table_format.vertical_lines_at_data_columns == :all ? (1:typemax(Int)) : (1:0)
        else
            table_format.vertical_lines_at_data_columns::Vector{Int}
        end

    ps     = PrintingTableState()
    action = :initialize

    has_cont_column = _is_horizontally_cropped(table_data)

    rows = DocxRow[]

    # The highlighters must receive the object the user passed to `pretty_table`, not the
    # internal table wrapper. Notice that this is loop invariant.
    orig_data = _get_data(table_data.data)

    # == Main Loop =========================================================================

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        if action == :new_row
            row = DocxRow(rs ∉ (:table_header, :table_footer))

            # Word repeats the header rows after every page break. Notice that they must
            # form an uninterrupted run from the first row of the table. Hence, the
            # title and the subtitle are also marked as header rows.
            row.header =
                table_format.repeat_header_rows_at_page_breaks &&
                rs ∈ (:table_header, :column_labels)

            push!(rows, row)
            continue
        end

        row = last(rows)

        if action == :end_row
            # Obtain the next row section since some decisions below depend on it. Notice
            # that this must be done here, and not once per action, because the lookahead is
            # a full run of the printing state iterator and only this branch consumes it.
            _, next_rs, _ = _next(ps, table_data)

            if rs == :column_labels
                (next_rs != :column_labels) &&
                    table_format.horizontal_line_after_column_labels &&
                    _docx__set_bottom!(row, borders.header_line)

            elseif rs ∈ (:data, :continuation_row)
                if next_rs ∉ (:data, :continuation_row)
                    (
                        table_format.horizontal_line_after_data_rows || (
                            (next_rs == :summary_row) &&
                            table_format.horizontal_line_before_summary_rows
                        )
                    ) && _docx__set_bottom!(row, borders.middle_line)

                elseif ps.i ∈ horizontal_lines_at_data_rows
                    _docx__set_bottom!(row, borders.middle_line)
                end

            elseif rs == :summary_row
                (next_rs != :summary_row) &&
                    table_format.horizontal_line_after_summary_rows &&
                    _docx__set_bottom!(row, borders.bottom_line)

            elseif rs == :row_group_label
                table_format.horizontal_line_before_row_group_label &&
                    _docx__set_top!(row, borders.middle_line)

                table_format.horizontal_line_after_row_group_label &&
                    _docx__set_bottom!(row, borders.middle_line)
            end

            continue
        end

        # == Cell Actions ==================================================================

        if action ∈ (
            :horizontal_continuation_cell,
            :diagonal_continuation_cell,
            :vertical_continuation_cell,
            :row_number_vertical_continuation_cell,
            :row_label_vertical_continuation_cell,
        )
            text = if action == :horizontal_continuation_cell
                "⋯"
            elseif action == :diagonal_continuation_cell
                "⋱"
            else
                "⋮"
            end

            cell = DocxCell([DocxRun(text)], :c, :center, style.data_cell)
            push!(row.cells, cell)

        else
            table_cell = _current_cell(action, ps, table_data)
            table_cell === _IGNORE_CELL && continue

            runs      = _docx__render_cell(table_cell, rctx, renderer)
            alignment = _current_cell_alignment(action, ps, table_data)

            # Footnote markers are appended as superscript runs.
            fn_indices = _current_cell_footnotes(table_data, action, ps.i, ps.j)

            if !isnothing(fn_indices) && !isempty(fn_indices)
                marker = join(fn_indices, ",")
                push!(runs, DocxRun(marker, _DOCX__NO_DECORATION, true))
            end

            if action ∈ (:title, :subtitle, :row_group_label, :footnote, :source_notes)
                # -- Full-Span Cells -------------------------------------------------------

                if action == :footnote
                    pushfirst!(runs, DocxRun(string(ps.i), _DOCX__NO_DECORATION, true))
                end

                style_key  = action == :source_notes ? :source_note : action
                cell_style = getproperty(style, style_key)

                valign = action ∈ (:title, :subtitle) ? :bottom : :center

                cell = DocxCell(
                    runs,
                    alignment,
                    valign,
                    cell_style;
                    gridspan = max(1, num_printed_cols)
                )

                push!(row.cells, cell)
                continue

            elseif (action == :column_label) && (table_cell isa MergeCells)
                # -- Column Labels (Merged Cell) -------------------------------------------

                span = min(table_cell.column_span, num_printed_data_cols - ps.j + 1)

                cell_style =
                    ps.i == 1 ? style.first_line_merged_column_label :
                    style.merged_column_label

                cell = DocxCell(
                    runs,
                    table_cell.alignment,
                    :bottom,
                    cell_style;
                    gridspan = span
                )

                table_format.horizontal_line_at_merged_column_labels &&
                    (cell.bottom = borders.merged_header_cell_line)

                push!(row.cells, cell)

                # We draw the vertical line here because we have access to the actual span
                # of the merged cell.
                last_merged_col = ps.j + span - 1

                if last_merged_col == num_printed_data_cols
                    # If we do not have a continuation column, we are in the last column.
                    # The right border in this case is drawn at the end.
                    (
                        table_format.vertical_line_after_data_columns && has_cont_column
                    ) && (cell.right = borders.middle_line)

                elseif last_merged_col ∈ vertical_lines_at_data_columns
                    cell.right = borders.middle_line
                end

                continue

            else
                # -- Other Cells -----------------------------------------------------------

                valign     = :top
                cell_style = _DOCX__NO_DECORATION

                if action == :column_label
                    style_var =
                        ps.i == 1 ? style.first_line_column_label : style.column_label

                    cell_style = if style_var isa Vector{Vector{DocxPair}}
                        style_var[ps.j]
                    else
                        style_var
                    end

                    valign = :bottom

                elseif action == :row_number_label
                    cell_style = ps.i == 1 ? style.row_number_label : _DOCX__NO_DECORATION
                    valign     = :bottom

                elseif action == :stubhead_label
                    cell_style = ps.i == 1 ? style.stubhead_label : _DOCX__NO_DECORATION
                    valign     = :bottom

                elseif action ∈ (:row_number, :summary_row_number)
                    cell_style = style.row_number

                elseif action == :row_label
                    cell_style = style.row_label

                elseif action == :summary_row_label
                    cell_style = style.summary_row_label

                elseif action == :summary_row_cell
                    cell_style = style.summary_row_cell

                elseif action == :data
                    cell_style = style.data_cell
                end

                cell = DocxCell(runs, alignment, valign, cell_style)
                push!(row.cells, cell)

                # Apply the highlighters in order, breaking after the first match. Notice
                # that the decoration must come after the one of the section so that it
                # overrides it.
                if action == :data
                    for highlighter in highlighters
                        highlighter.f(orig_data, ps.i, ps.j) || continue

                        decoration = _docx__highlighter_decoration(
                            highlighter, orig_data, ps.i, ps.j
                        )

                        cell.decoration = vcat(cell.decoration, decoration)

                        break
                    end
                end

                if (action == :column_label) || (action == :row_number_label) ||
                    (action == :stubhead_label)
                    (
                        (ps.i < length(table_data.column_labels)) &&
                        table_format.horizontal_line_between_column_labels
                    ) && (cell.bottom = borders.middle_line)
                end
            end
        end

        # == Vertical Lines ================================================================

        cell = last(row.cells)

        if action ∈ (
            :row_number_label,
            :row_number,
            :row_number_vertical_continuation_cell,
            :summary_row_number,
        )
            table_format.vertical_line_after_row_number_column &&
                (cell.right = borders.center_line)

        elseif action ∈ (
            :stubhead_label,
            :row_label,
            :row_label_vertical_continuation_cell,
            :summary_row_label,
        )
            table_format.vertical_line_after_row_label_column &&
                (cell.right = borders.center_line)

        elseif action ∈
            (:column_label, :data, :summary_row_cell, :vertical_continuation_cell)
            if ps.j == num_printed_data_cols
                # If we do not have a continuation column, we are in the last column. The
                # right border in this case is drawn at the end.
                (table_format.vertical_line_after_data_columns && has_cont_column) &&
                    (cell.right = borders.middle_line)

            elseif ps.j ∈ vertical_lines_at_data_columns
                cell.right = borders.middle_line
            end
        end
    end

    # == Post-Loop Operations ==============================================================

    # The outer borders span only the content area, excluding the title, the subtitle, the
    # footnotes, and the source notes.
    content = findall(r -> r.content && !isempty(r.cells), rows)

    if !isempty(content)
        first_row = rows[first(content)]
        last_row  = rows[last(content)]

        table_format.horizontal_line_at_beginning &&
            _docx__set_top!(first_row, borders.top_line)

        # NOTE: The bottom rule must be an independent decision from the line at the
        # beginning. It follows the flag of the last section that is actually printed.
        draw_bottom_line = if _has_summary_rows(table_data)
            table_format.horizontal_line_after_summary_rows
        else
            table_format.horizontal_line_after_data_rows
        end

        draw_bottom_line && _docx__set_bottom!(last_row, borders.bottom_line)

        draw_right_line = if has_cont_column
            table_format.vertical_line_after_continuation_column
        else
            table_format.vertical_line_after_data_columns
        end

        for i in content
            cells = rows[i].cells

            table_format.vertical_line_at_beginning &&
                (first(cells).left = borders.left_line)

            draw_right_line && (last(cells).right = borders.right_line)
        end
    end

    return _docx__table(rows, table_format.cell_margins)
end

"""
    _docx__set_bottom!(row::DocxRow, border::Vector{DocxPair}) -> Nothing
    _docx__set_top!(row::DocxRow, border::Vector{DocxPair}) -> Nothing

Apply `border` to the bottom or to the top of every cell in `row`.
"""
function _docx__set_bottom!(row::DocxRow, border::Vector{DocxPair})
    for cell in row.cells
        cell.bottom = border
    end

    return nothing
end

function _docx__set_top!(row::DocxRow, border::Vector{DocxPair})
    for cell in row.cells
        cell.top = border
    end

    return nothing
end
