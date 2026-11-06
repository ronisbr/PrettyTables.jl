## Description ############################################################################
#
# Excel Back End: Write the table to an XLSX.Worksheet object.
#
############################################################################################

"""
    _excel__write_table!(
        sheet::XLSX.Worksheet,
        pspec::PrintingSpec,
        opts::ExcelPrintOptions
    ) -> Nothing

Write the complete table described by `pspec` to `sheet` using the PrettyTables.jl
printing iterator. Cell styling, borders, column widths, and row heights are all applied
during the single pass over the iterator.

# Options

The fields of `opts` are:

- `anchor_cell::String`: Top-left cell of the table in A1 notation (e.g. `"B3"`).
    (**Default**: `"A1"`)
- `data_column_widths::Union{Real, AbstractVector{<:Real}}`: Explicit width for each data
    column in Excel units, overriding auto-calculated widths. A scalar applies to all
    columns; a vector sets per-column widths. When set (> 0), `minimum_data_column_widths`
    and `maximum_data_column_widths` are ignored for that column.
    (**Default**: `0.0`)
- `excel_formatters::Vector{ExcelFormatter}`: Number-format rules applied to data and
    summary cells.
    (**Default**: `ExcelFormatter[]`)
- `highlighters::Vector{AbstractHighlighter}`: Highlighters to apply to the table.
    (**Default**: `AbstractHighlighter[]`)
- `minimum_data_column_widths::Union{Real, AbstractVector{<:Real}}`: Minimum width for each
    data column in Excel units. A scalar applies to all columns; a vector sets per-column
    minimums.
    (**Default**: `0.0`)
- `maximum_data_column_widths::Union{Real, AbstractVector{<:Real}}`: Maximum width for each
    data column in Excel units. A scalar applies to all columns; a vector sets per-column
    maximums.
    (**Default**: `0.0`)
- `style::ExcelTableStyle`: Font and fill style for each table section.
    (**Default**: `ExcelTableStyle()`)
- `table_format::ExcelTableFormat`: Border and column-width configuration.
    (**Default**: `ExcelTableFormat()`)
"""
# This method must be the only caller of the rendering body and it must not be inlined into
# `_excel__print`. Otherwise, each keyword set would pay for a new entry point into the body
# (see `ExcelPrintOptions`).
@noinline function _excel__write_table!(
    sheet::XLSX.Worksheet, pspec::PrintingSpec, opts::ExcelPrintOptions
)
    return _excel__write_table_core!(sheet, pspec, opts)
end

function _excel__write_table_core!(
    sheet::XLSX.Worksheet, pspec::PrintingSpec, opts::ExcelPrintOptions
)
    # == Unpack the Options ================================================================

    anchor_cell                = opts.anchor_cell
    data_column_widths         = opts.data_column_widths
    excel_formatters           = opts.excel_formatters
    highlighters               = _excel__native_highlighters(opts.highlighters)
    maximum_data_column_widths = opts.maximum_data_column_widths
    minimum_data_column_widths = opts.minimum_data_column_widths
    style                      = opts.style
    table_format               = opts.table_format

    table_data = pspec.table_data

    c = XLSX.CellRef(anchor_cell)
    anchor_row_offset = Int(c.row_number - 1)
    anchor_col_offset = Int(c.column_number - 1)

    num_cols = table_data.num_columns
    num_rows = table_data.num_rows
    num_printed_cols = _number_of_printed_columns(table_data)
    num_printed_data_cols = _number_of_printed_data_columns(table_data)

    _check_column_label_styles(
        style.first_line_column_label,
        style.column_label,
        Vector{Vector{ExcelPair}},
        num_cols,
    )

    num_leading_columns =
        num_printed_cols - num_printed_data_cols - _is_horizontally_cropped(table_data)

    context  = pspec.context
    renderer = pspec.renderer === :show ? Val(:show) : Val(:print)

    # Reusable render buffer: one allocation per table instead of three per cell.
    rctx = RenderContext(context)

    # The width keywords are indexed per data column. Hence, we must check their length here
    # to raise a meaningful error instead of a `BoundsError` deep in the back end.
    for (name, v) in (
        ("data_column_widths", data_column_widths),
        ("minimum_data_column_widths", minimum_data_column_widths),
        ("maximum_data_column_widths", maximum_data_column_widths),
    )
        (v isa AbstractVector) &&
            (length(v) != num_cols) &&
            throw(
                ArgumentError(
                    "The length of `$name` ($(length(v))) must be equal to the number of columns ($num_cols).",
                ),
            )
    end

    data_column_widths = _excel__data_column_widths(data_column_widths, num_cols)

    minimum_data_column_widths = _excel__data_column_widths(
        minimum_data_column_widths, num_cols
    )

    maximum_data_column_widths = _excel__data_column_widths(
        maximum_data_column_widths, num_cols
    )

    max_row_height = Dict{Int, Float64}()
    max_col_length = zeros(Float64, num_printed_cols)

    # == Iterator Setup ====================================================================

    # Resolve the lines of the table.
    lines   = TableLines(table_format, table_data)
    borders = table_format.borders

    ps     = PrintingTableState()
    action = :initialize

    # Row section of the previous row, required to select the line above the first row of
    # the ruled area and above a row group label. The table header is the section before the
    # first row even if the table has no title and no subtitle.
    prev_rs = :table_header

    # Line drawn after the unmerged cells of the current column label row, if any.
    column_label_row_line = :none

    all_cols = (1 + anchor_col_offset):(num_printed_cols + anchor_col_offset)

    ir = jr = 0

    # The highlighters and the formatters must receive the object the user passed to
    # `pretty_table`, not the internal table wrapper. Notice that this is loop invariant.
    orig_data = _get_data(table_data.data)

    # == Main Loop =========================================================================

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        jr += 1

        sheet_row = ir + anchor_row_offset
        sheet_col = jr + anchor_col_offset

        if action == :new_row
            ir += 1
            jr = 0

            max_row_height[ir] = 0.0

            # Ensure all cells in the row are non-empty before any merges.
            _excel__unempty_row!(sheet, ir + anchor_row_offset, all_cols)

            # The line between two column label rows is drawn as the bottom border of each
            # unmerged cell, since the merged cells have their own line.
            column_label_row_line = _line_between_column_label_rows(
                lines, table_data, rs, ps.i
            )

        elseif action ∈ (
            :horizontal_continuation_cell,
            :diagonal_continuation_cell,
            :vertical_continuation_cell,
            :row_number_vertical_continuation_cell,
            :row_label_vertical_continuation_cell,
        )
            alignment = :c

            rendered_cell = if action == :horizontal_continuation_cell
                "⋯"
            elseif action == :diagonal_continuation_cell
                "⋱"
            else
                "⋮"
            end

            sheet[sheet_row, sheet_col] = rendered_cell

            fontsize = _excel__apply_cell_style!(
                sheet, sheet_row, sheet_col, style.data_cell, alignment, "bottom", false
            )

            row_height, col_length = _excel__cell_length_and_height(rendered_cell, fontsize)

            max_row_height[ir] = max(max_row_height[ir], row_height)
            max_col_length[jr] = max(max_col_length[jr], col_length)

        elseif action == :end_row
            # Obtain the next row section since some decisions below depend on it. Notice
            # that this must be done here, and not once per action, because the lookahead is
            # a full run of the printing state iterator and only this branch consumes it.
            _, next_rs, _ = _next(ps, table_data)

            # NOTE: The row height is set once for every row in the post-loop block, which
            # already has the final value. Setting it here as well doubled the work.

            # == Table Lines ===============================================================

            # The lines are only drawn in the ruled area, which excludes the title, the
            # subtitle, the footnotes, and the source notes.
            if rs ∉ (:table_header, :table_footer)
                row_abs = ir + anchor_row_offset

                # The line above the row is its top border if it is the first row of the
                # ruled area or a row group label, since the label does not end the data
                # section. Otherwise, the line above the row is the bottom border of the row
                # above it. Notice that the row index is only used if the row above is a data
                # row, in which case it is the row before this one.
                if (prev_rs == :table_header) || (rs == :row_group_label)
                    role = _horizontal_line_after_row(
                        lines, table_data, prev_rs, rs, ps.i - 1
                    )

                    (role != :none) && XLSX.setBorder(
                        sheet, row_abs, all_cols; top = getfield(borders, role)
                    )
                end

                # The line after the row is its bottom border, unless the next row is a row
                # group label.
                if next_rs != :row_group_label
                    role = _horizontal_line_after_row(lines, table_data, rs, next_rs, ps.i)

                    (role != :none) && XLSX.setBorder(
                        sheet, row_abs, all_cols; bottom = getfield(borders, role)
                    )
                end

                # The vertical line at the left edge of the table. Notice that the one at the
                # right edge is the right border of the last cell of the row, which was set
                # when the cell was created.
                lines.vertical_line_at_beginning && XLSX.setBorder(
                    sheet, row_abs, first(all_cols); left = borders.left_line
                )
            end

            prev_rs = rs

        else
            # == Cell Actions ==============================================================

            cell = _current_cell(action, ps, table_data)
            cell === _IGNORE_CELL && continue

            rendered_cell = _excel__render_cell(cell, rctx, renderer)

            alignment = _current_cell_alignment(action, ps, table_data)

            # Footnote superscripts to append to this cell.
            fn_str = _current_cell_footnote_marks(
                _excel__to_superscript, table_data, action, ps.i, ps.j, ""
            )
            !isempty(fn_str) &&
                (rendered_cell = _excel__append_superscript(rendered_cell, fn_str))

            # -- Full-span Cells -----------------------------------------------------------

            if action ∈ (:title, :subtitle, :row_group_label, :footnote, :source_notes)
                if action == :footnote
                    # Footnote cells are prefixed with their index superscript.
                    rendered_cell = _excel__to_superscript(ps.i) * rendered_cell
                end

                style_key  = action == :source_notes ? "source_note" : string(action)
                cell_style = getproperty(style, Symbol(style_key))

                valign = if action ∈ (:title, :subtitle)
                    "bottom"
                else
                    "center"
                end

                col_start = 1 + anchor_col_offset
                col_end   = num_printed_cols + anchor_col_offset

                sheet[sheet_row, col_start] = rendered_cell

                XLSX.mergeCells(
                    sheet,
                    XLSX.CellRange(
                        XLSX.CellRef(sheet_row, col_start), XLSX.CellRef(sheet_row, col_end)
                    ),
                )

                fontsize = _excel__apply_cell_style!(
                    sheet, sheet_row, col_start, cell_style, alignment, valign, true
                )

                text_lines = _excel__text_lines(rendered_cell)
                row_height = _excel__row_height_for_text(text_lines, fontsize)

                max_row_height[ir] = max(max_row_height[ir], row_height)

            elseif (action == :column_label) && (cell isa MergeCells)
                # -- Column labels (Merged Cell) -------------------------------------------

                span = _merged_cell_span(table_data, cell, ps.j)

                sheet[sheet_row, sheet_col] = rendered_cell

                XLSX.mergeCells(
                    sheet,
                    XLSX.CellRange(
                        XLSX.CellRef(sheet_row, sheet_col),
                        XLSX.CellRef(sheet_row, sheet_col + span - 1),
                    ),
                )

                cell_style =
                    ps.i == 1 ? style.first_line_merged_column_label :
                    style.merged_column_label

                fontsize = _excel__apply_cell_style!(
                    sheet, sheet_row, sheet_col, cell_style, cell.alignment, "bottom", true
                )

                row_height, _ = _excel__cell_length_and_height(rendered_cell, fontsize)

                max_row_height[ir] = max(max_row_height[ir], row_height)

                lines.horizontal_line_at_merged_column_labels && XLSX.setBorder(
                    sheet,
                    sheet_row,
                    sheet_col:(sheet_col + span - 1);
                    bottom = borders.merged_header_cell_line,
                )

                # We draw the vertical line here because we have access to the actual span
                # of the merged cell.
                role = _vertical_line_after_column(
                    lines, table_data, :data, ps.j + span - 1
                )

                (role != :none) && XLSX.setBorder(
                    sheet,
                    sheet_row,
                    sheet_col + span - 1;
                    right = getfield(borders, role),
                )

            else
                # -- Other Cells -----------------------------------------------------------

                vertical_alignment = "bottom"
                cell_style         = _EXCEL__NO_DECORATION
                wrap               = false

                sheet[sheet_row, sheet_col] = rendered_cell

                # .. Unmerged Column labels ................................................

                if (action == :column_label)
                    style_var =
                        ps.i == 1 ? style.first_line_column_label : style.column_label

                    cell_style = if style_var isa Vector{Vector{ExcelPair}}
                        style_var[ps.j]
                    else
                        style_var
                    end

                    vertical_alignment = "bottom"
                    wrap = true

                    (column_label_row_line != :none) && XLSX.setBorder(
                        sheet,
                        sheet_row,
                        sheet_col;
                        bottom = getfield(borders, column_label_row_line),
                    )

                elseif action == :row_number_label
                    cell_style = ps.i == 1 ? style.row_number_label : _EXCEL__NO_DECORATION
                    vertical_alignment = "bottom"
                    wrap = true

                    (column_label_row_line != :none) && XLSX.setBorder(
                        sheet,
                        sheet_row,
                        sheet_col;
                        bottom = getfield(borders, column_label_row_line),
                    )

                elseif action ∈ (:row_number, :summary_row_number)
                    cell_style = style.row_number
                    vertical_alignment = "top"
                    wrap = true

                elseif action == :stubhead_label
                    cell_style = ps.i == 1 ? style.stubhead_label : _EXCEL__NO_DECORATION
                    vertical_alignment = "bottom"
                    wrap = true

                    (column_label_row_line != :none) && XLSX.setBorder(
                        sheet,
                        sheet_row,
                        sheet_col;
                        bottom = getfield(borders, column_label_row_line),
                    )

                elseif action == :row_label
                    cell_style = style.row_label
                    vertical_alignment = "top"
                    wrap = true

                elseif action == :summary_row_label
                    cell_style = style.summary_row_label
                    vertical_alignment = "top"
                    wrap = true

                elseif action == :data
                    cell_style = style.data_cell
                    text_lines = _excel__text_lines(rendered_cell)
                    vertical_alignment = "top"
                    wrap = text_lines > 1

                    for formatter in excel_formatters
                        # `:data` formatters match the data row index.
                        formatter.region === :data || continue

                        fmt_attributes = _excel__format_attributes(
                            orig_data, formatter, _data_indices(table_data, ps.i, ps.j)...
                        )
                        if !isnothing(fmt_attributes)
                            XLSX.setFormat(sheet, sheet_row, sheet_col; fmt_attributes...)
                            break
                        end
                    end

                elseif action == :summary_row_cell
                    cell_style = style.summary_row_cell
                    vertical_alignment = "top"
                    wrap = false

                    for formatter in excel_formatters
                        # `:summary_row` formatters match the summary row index and the
                        # column index in the data.
                        formatter.region === :summary_row || continue

                        _, dj = _data_indices(table_data, 1, ps.j)

                        fmt_attributes = _excel__format_attributes(
                            orig_data, formatter, ps.i, dj
                        )

                        if !isnothing(fmt_attributes)
                            XLSX.setFormat(sheet, sheet_row, sheet_col; fmt_attributes...)
                            break
                        end
                    end
                end

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    sheet_col,
                    cell_style,
                    alignment,
                    vertical_alignment,
                    wrap,
                )

                row_height, col_length = _excel__cell_length_and_height(
                    rendered_cell, fontsize
                )

                max_row_height[ir] = max(max_row_height[ir], row_height)
                max_col_length[jr] = max(max_col_length[jr], col_length)

                # Apply highlighters in order, breaking after the first match. Notice that
                # this must be performed after applying the section style. Otherwise, the
                # highlighter decoration would be overwritten.
                if action == :data
                    di, dj = _data_indices(table_data, ps.i, ps.j)

                    for highlighter in highlighters
                        highlighter.f(orig_data, di, dj) || continue

                        decoration = _excel__highlighter_decoration(
                            highlighter, orig_data, di, dj
                        )

                        hl_font_size = _excel__apply_cell_style!(
                            sheet, sheet_row, sheet_col, decoration, nothing, "", false
                        )

                        hl_row_height, hl_col_length = _excel__cell_length_and_height(
                            rendered_cell, hl_font_size
                        )

                        max_row_height[ir] = max(max_row_height[ir], hl_row_height)
                        max_col_length[jr] = max(max_col_length[jr], hl_col_length)

                        break
                    end
                end
            end
        end

        # == Vertical Lines ================================================================

        # The vertical line after a cell is its right border. Notice that the merged column
        # labels were handled above because their span is required, and that the cells of the
        # table header and footer have no borders.
        vline_role = if (action == :column_label) && (cell isa MergeCells)
            :none
        else
            _vertical_line_after_cell(lines, table_data, action, ps.j)
        end

        if vline_role != :none
            # The row group label spans the entire table. Hence, its right border is the line
            # at the right edge of the table, drawn at the last column.
            vline_col = action == :row_group_label ? last(all_cols) : sheet_col
            XLSX.setBorder(
                sheet, sheet_row, vline_col; right = getfield(borders, vline_role)
            )
        end
    end

    # == Post-Loop Operations ==============================================================

    # Set column widths based on accumulated content lengths.
    for i in 1:num_printed_cols
        col_width = _excel__get_col_width(
            i,
            max_col_length,
            num_leading_columns,
            num_printed_data_cols,
            data_column_widths,
            minimum_data_column_widths,
            maximum_data_column_widths,
        )

        col_width > 0 &&
            XLSX.setColumnWidth(sheet, i + anchor_col_offset; width = col_width)
    end

    # Set final row heights.
    for (row, height) in max_row_height
        XLSX.setRowHeight(sheet, row + anchor_row_offset; height = height)
    end

    return nothing
end
