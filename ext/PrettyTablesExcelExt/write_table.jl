## Description #############################################################################
#
# Excel Back End: Write the table to an XLSX.Worksheet object.
#
############################################################################################

"""
    _write_excel_table!(sheet, pspec::PrintingSpec; kwargs)

Write the complete table to an Excel sheet using the PrettyTables.jl printing iterator.
"""
function _write_excel_table!(
    sheet::XLSX.Worksheet,
    pspec::PrintingSpec;
    highlighters::Vector{ExcelHighlighter}  = ExcelHighlighter[],
    excel_formatters::Vector{ExcelFormatter} = ExcelFormatter[],
    table_format::ExcelTableFormat           = ExcelTableFormat(),
    style::ExcelTableStyle                   = ExcelTableStyle(),
    anchor_cell::String,
)
    table_data = pspec.table_data

    c                = XLSX.CellRef(anchor_cell)
    anchor_row_offset = Int(c.row_number  - 1)
    anchor_col_offset = Int(c.column_number - 1)

    num_rows   = table_data.num_rows
    num_cols   = table_data.num_columns
    col_offset = _excel_compute_col_offset(table_data)

    max_row_height = Dict{Int, Float64}()
    max_col_length = zeros(Float64, num_cols + col_offset)

    # == Iterator Setup ====================================================================

    ps     = PrintingTableState()
    action = :initialize

    current_row = 1  # internal row counter (relative to the table, not the sheet)

    # Tracking variables used for post-loop operations and section transitions.
    data_i_to_sheet_row = Dict{Int, Int}()   # data row index i → absolute sheet row
    first_content_row   = 0                  # absolute sheet row of first non-header row
    last_written_row    = 0                  # absolute sheet row of last data/summary row
    footnote_start_row  = 0                  # absolute sheet row of first footnote
    footnote_end_row    = 0                  # absolute sheet row of last footnote
    in_footnotes        = false

    # Shared column range expression (reused in many setBorder/unempty calls).
    all_cols(offset = 0) = 1 + anchor_col_offset : num_cols + col_offset + anchor_col_offset + offset

    # == Main Loop =========================================================================

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        action == :end_printing && break

        next_action, next_rs, _ = _next(ps, table_data)

        # == New Row ===================================================================

        if action == :new_row
            max_row_height[current_row] = 0.0

            # Ensure all cells in the row are non-empty before any merges.
            _excel_unempty_row(sheet, current_row + anchor_row_offset, all_cols())

            # Track first non-header row for vline_after_row_labels calculation.
            if first_content_row == 0 && rs != :table_header
                first_content_row = current_row + anchor_row_offset
            end

            if rs == :data
                data_i_to_sheet_row[ps.i] = current_row + anchor_row_offset
                _excel_try_border!(
                    sheet, current_row + anchor_row_offset, all_cols(),
                    table_format, "underline_data_rows", :bottom,
                )

            elseif rs == :table_footer && next_action == :footnote
                if footnote_start_row == 0
                    footnote_start_row = current_row + anchor_row_offset
                end
                in_footnotes = true
            end

        # == End Row ===================================================================

        elseif action == :end_row
            XLSX.setRowHeight(
                sheet,
                current_row + anchor_row_offset;
                height = max_row_height[current_row],
            )

            if rs == :table_header && next_rs != :table_header
                # Insert blank spacer row after the title/subtitle block.
                current_row += 1
                max_row_height[current_row] = 0.0

                # Ensure cells exist before setting a border on the blank row.
                _excel_unempty_row(sheet, current_row + anchor_row_offset, all_cols())

                _excel_try_border!(
                    sheet, current_row + anchor_row_offset, all_cols(),
                    table_format, "underline_title", :bottom,
                )

            elseif rs == :column_labels && next_rs != :column_labels
                _excel_try_border!(
                    sheet, current_row + anchor_row_offset, all_cols(),
                    table_format, "underline_headers", :bottom,
                )

            elseif rs ∈ (:data, :continuation_row)
                last_written_row = current_row + anchor_row_offset

            elseif rs == :summary_row
                last_written_row = current_row + anchor_row_offset

                if next_rs == :summary_row
                    _excel_try_border!(
                        sheet, current_row + anchor_row_offset, all_cols(),
                        table_format, "underline_summary_rows", :bottom,
                    )
                else
                    _excel_try_border!(
                        sheet, current_row + anchor_row_offset, all_cols(),
                        table_format, "underline_summary", :bottom,
                    )
                end

            elseif rs == :row_group_label
                _excel_try_border!(
                    sheet, current_row + anchor_row_offset, all_cols(),
                    table_format, "overline_group", :top,
                )
                _excel_try_border!(
                    sheet, current_row + anchor_row_offset, all_cols(),
                    table_format, "underline_group", :bottom,
                )
            end

            # Transition from data/summary to the table footer (or to summary rows).
            if (rs ∈ (:data, :continuation_row) &&
                next_rs ∈ (:table_footer, :end_printing, :summary_row)) ||
               (rs == :summary_row && next_rs ∈ (:table_footer, :end_printing))
                _excel_try_border!(
                    sheet, current_row + anchor_row_offset, all_cols(),
                    table_format, "underline_table", :bottom,
                )
            end

            # Finalize footnotes when the last footnote row ends.
            if in_footnotes &&
               !isnothing(table_data.footnotes) &&
               ps.i >= length(table_data.footnotes)
                footnote_end_row = current_row + anchor_row_offset
                _excel_finalize_footnotes!(
                    sheet,
                    table_data,
                    table_format,
                    style,
                    footnote_start_row,
                    footnote_end_row,
                    anchor_col_offset,
                    col_offset,
                    num_cols,
                )
                in_footnotes = false
            end

            current_row += 1

        # == Cell Actions ==============================================================

        else
            cell = _current_cell(action, ps, table_data)
            cell === _IGNORE_CELL && continue

            alignment = _current_cell_alignment(action, ps, table_data)
            sheet_row = current_row + anchor_row_offset

            # Footnote superscripts to append to this cell.
            fn_indices = _current_cell_footnotes(table_data, action, ps.i, ps.j)
            fn_str     = (!isnothing(fn_indices) && !isempty(fn_indices)) ?
                         join(_excel_to_superscript.(fn_indices)) : ""

            # -- Full-span cells -------------------------------------------------------
            if action ∈ (:title, :subtitle, :row_group_label, :footnote, :source_notes)

                if action == :footnote
                    # Footnote cells are prefixed with their index superscript.
                    text = _excel_to_superscript(ps.i) * " " * string(cell)
                else
                    text = string(something(cell, "")) * fn_str
                end

                style_key   = action == :source_notes ? "source_note" : string(action)
                style_field = getproperty(style, Symbol(style_key))

                style_atts = _excel_newpairs(_excel_tablestyle_atts(style_key, style_field))
                fill_atts  = _excel_newpairs(_excel_cell_fill_atts(style_field))

                valign = action ∈ (:title, :subtitle, :row_number_label) ? "bottom" :
                         action == :row_group_label ? "center" : "center"

                row_height = _excel_write_full_span_cell!(
                    sheet, text, current_row, num_cols, col_offset,
                    anchor_row_offset, anchor_col_offset,
                    style_atts, fill_atts, alignment, valign,
                )
                max_row_height[current_row] = max(max_row_height[current_row], row_height)

            # -- Column labels ---------------------------------------------------------
            elseif action == :column_label

                excel_col = ps.j + col_offset + anchor_col_offset

                if cell isa MergeCells
                    num_data_cols  = _number_of_printed_data_columns(table_data)
                    span           = min(cell.column_span, num_data_cols - ps.j + 1)
                    label_text     = string(cell.data) * fn_str

                    sheet[sheet_row, excel_col] = label_text
                    XLSX.mergeCells(
                        sheet,
                        XLSX.CellRange(
                            XLSX.CellRef(sheet_row, excel_col),
                            XLSX.CellRef(sheet_row, excel_col + span - 1),
                        ),
                    )

                    style_key   = ps.i == 1 ?
                        "first_line_merged_column_label" : "merged_column_label"
                    style_field = ps.i == 1 ?
                        style.first_line_merged_column_label : style.merged_column_label

                    fontsize = _excel_apply_cell_style!(
                        sheet, sheet_row, excel_col, style_key, style_field,
                        cell.alignment, "bottom", true,
                    )
                    row_height, _ = _excel_cell_length_and_height(label_text, fontsize)
                    max_row_height[current_row] = max(max_row_height[current_row], row_height)

                    _excel_try_border!(
                        sheet, sheet_row, excel_col : excel_col + span - 1,
                        table_format, "underline_merged_headers", :bottom,
                    )
                    if ps.j + span - 1 < num_cols
                        _excel_try_border!(
                            sheet, sheet_row, excel_col + span - 1,
                            table_format, "vline_between_data_columns", :right,
                        )
                    end

                else
                    label_text = string(cell) * fn_str
                    sheet[sheet_row, excel_col] = label_text

                    style_key   = ps.i == 1 ? "first_line_column_label" : "column_label"
                    style_field = ps.i == 1 ? style.first_line_column_label : style.column_label

                    fontsize = _excel_apply_cell_style!(
                        sheet, sheet_row, excel_col, style_key, style_field,
                        alignment, "bottom", true; col_idx = ps.j,
                    )
                    row_height, col_length = _excel_cell_length_and_height(label_text, fontsize)
                    max_row_height[current_row] = max(max_row_height[current_row], row_height)
                    max_col_length[ps.j + col_offset] = max(
                        max_col_length[ps.j + col_offset], col_length,
                    )

                    if ps.j < num_cols
                        _excel_try_border!(
                            sheet, sheet_row, excel_col,
                            table_format, "vline_between_data_columns", :right,
                        )
                    end
                    if ps.i < length(table_data.column_labels)
                        _excel_try_border!(
                            sheet, sheet_row, excel_col,
                            table_format, "underline_between_headers", :bottom,
                        )
                    end
                end

            # -- Row number label ------------------------------------------------------
            elseif action == :row_number_label
                excel_col  = 1 + anchor_col_offset
                label_text = string(something(cell, "")) * fn_str

                sheet[sheet_row, excel_col] = label_text

                fontsize = _excel_apply_cell_style!(
                    sheet, sheet_row, excel_col,
                    "row_number_label", style.row_number_label, alignment, "bottom", false,
                )
                _excel_try_border!(
                    sheet, sheet_row, excel_col,
                    table_format, "vline_after_row_numbers", :right,
                )
                row_height, col_length = _excel_cell_length_and_height(label_text, fontsize)
                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[1] = max(max_col_length[1], col_length)

            # -- Row number / summary row number ---------------------------------------
            elseif action ∈ (:row_number, :summary_row_number)
                excel_col = 1 + anchor_col_offset
                val       = cell  # Int for :row_number, "" for :summary_row_number

                sheet[sheet_row, excel_col] = val

                fontsize = _excel_apply_cell_style!(
                    sheet, sheet_row, excel_col,
                    "row_number", style.row_number, alignment, "top", false,
                )
                _excel_try_border!(
                    sheet, sheet_row, excel_col,
                    table_format, "vline_after_row_numbers", :right,
                )
                row_height, _ = _excel_cell_length_and_height(val, fontsize)
                max_row_height[current_row] = max(max_row_height[current_row], row_height)

            # -- Stubhead label --------------------------------------------------------
            elseif action == :stubhead_label
                excel_col  = col_offset + anchor_col_offset
                label_text = string(something(cell, "")) * fn_str

                sheet[sheet_row, excel_col] = label_text

                fontsize = _excel_apply_cell_style!(
                    sheet, sheet_row, excel_col,
                    "stubhead_label", style.stubhead_label, alignment, "bottom", true,
                )
                row_height, col_length = _excel_cell_length_and_height(label_text, fontsize)
                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[col_offset] = max(max_col_length[col_offset], col_length)

            # -- Row label / summary row label -----------------------------------------
            elseif action ∈ (:row_label, :summary_row_label)
                excel_col   = col_offset + anchor_col_offset
                label_text  = string(cell) * fn_str
                style_key   = string(action)
                style_field = getproperty(style, Symbol(style_key))

                sheet[sheet_row, excel_col] = label_text

                fontsize = _excel_apply_cell_style!(
                    sheet, sheet_row, excel_col, style_key, style_field, alignment, "top", true,
                )
                row_height, col_length = _excel_cell_length_and_height(label_text, fontsize)
                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[col_offset]  = max(max_col_length[col_offset], col_length)

            # -- Data cell -------------------------------------------------------------
            elseif action == :data
                excel_col = ps.j + col_offset + anchor_col_offset

                # _current_cell already applied table_data.formatters.
                formatted_value = !isempty(fn_str) ? string(cell) * fn_str : cell

                lines = formatted_value isa AbstractString ?
                        _excel_text_lines(formatted_value) : 1

                sheet[sheet_row, excel_col] = formatted_value

                fontsize = _excel_apply_cell_style!(
                    sheet, sheet_row, excel_col,
                    "table_cell", style.table_cell, alignment, "top", lines > 1;
                    col_idx = ps.j,
                )
                for formatter in excel_formatters
                    fmt_atts = _excel_format_attributes(table_data, formatter, current_row, ps.j)
                    if !isnothing(fmt_atts)
                        XLSX.setFormat(sheet, sheet_row, excel_col; fmt_atts...)
                        break
                    end
                end
                if ps.j < num_cols
                    _excel_try_border!(
                        sheet, sheet_row, excel_col,
                        table_format, "vline_between_data_columns", :right,
                    )
                end
                row_height, col_length = _excel_cell_length_and_height(formatted_value, fontsize)
                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[ps.j + col_offset] = max(
                    max_col_length[ps.j + col_offset], col_length,
                )

            # -- Summary row cell ------------------------------------------------------
            elseif action == :summary_row_cell
                excel_col = ps.j + col_offset + anchor_col_offset

                # _current_cell already called the summary function.
                formatted_value = !isempty(fn_str) ? string(cell) * fn_str : cell

                sheet[sheet_row, excel_col] = formatted_value

                fontsize = _excel_apply_cell_style!(
                    sheet, sheet_row, excel_col,
                    "summary_row_cell", style.summary_row_cell, alignment, "top", false;
                    col_idx = ps.j,
                )
                for formatter in excel_formatters
                    fmt_atts = _excel_format_attributes(table_data, formatter, current_row, ps.j)
                    if !isnothing(fmt_atts)
                        XLSX.setFormat(sheet, sheet_row, excel_col; fmt_atts...)
                        break
                    end
                end
                if ps.j < num_cols
                    _excel_try_border!(
                        sheet, sheet_row, excel_col,
                        table_format, "vline_between_data_columns", :right,
                    )
                end
                row_height, col_length = _excel_cell_length_and_height(formatted_value, fontsize)
                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[ps.j + col_offset] = max(
                    max_col_length[ps.j + col_offset], col_length,
                )

            # -- Continuation cells ----------------------------------------------------
            elseif action ∈ (
                :horizontal_continuation_cell,
                :diagonal_continuation_cell,
                :vertical_continuation_cell,
                :row_number_vertical_continuation_cell,
                :row_label_vertical_continuation_cell,
            )
                cont_text = action == :horizontal_continuation_cell ? "⋯" :
                            action == :diagonal_continuation_cell   ? "⋱" : "⋮"

                excel_col = if action == :row_number_vertical_continuation_cell
                    1 + anchor_col_offset
                elseif action == :row_label_vertical_continuation_cell
                    col_offset + anchor_col_offset
                else
                    ps.j + col_offset + anchor_col_offset
                end

                sheet[sheet_row, excel_col] = cont_text
            end
        end
    end

    # == Post-Loop Operations ==============================================================

    # Vertical line to the right of the row labels column.
    if table_data.row_labels !== nothing
        vline_start = first_content_row > 0 ? first_content_row : 1 + anchor_row_offset
        vline_end   = last_written_row   > 0 ? last_written_row  : current_row + anchor_row_offset - 1
        if vline_start <= vline_end
            _excel_try_border!(
                sheet, vline_start : vline_end, col_offset + anchor_col_offset,
                table_format, "vline_after_row_labels", :right,
            )
        end
    end

    # Outside border around the full table.
    _excel_try_border!(
        sheet,
        1 + anchor_row_offset : current_row + anchor_row_offset - 1,
        all_cols(),
        table_format, "outside_border", :outside,
    )

    # Apply highlighters after all borders so they render on top.
    if num_rows > 0
        for i in 1:num_rows
            hl_row = get(data_i_to_sheet_row, i, 0)
            hl_row == 0 && continue

            for j in 1:num_cols
                for highlighter in highlighters
                    highlighter.f(table_data.data, i, j) || continue

                    decoration = highlighter.fd(highlighter, table_data.data, i, j)
                    fill_atts  = _excel_newpairs(_excel_cell_fill_atts(decoration))
                    font_atts  = _excel_newpairs(
                        filter(p -> !startswith(p.first, "cell_fill_"), decoration)
                    )

                    if !isempty(font_atts)
                        font_size = _excel_getsize(font_atts)
                        if !isnothing(font_size)
                            row_height, col_length = _excel_cell_length_and_height(
                                _get_cell_value(table_data, i, j), font_size,
                            )
                            internal_row = hl_row - anchor_row_offset
                            max_row_height[internal_row] = max(
                                get(max_row_height, internal_row, 0.0), row_height,
                            )
                            max_col_length[j + col_offset] = max(
                                max_col_length[j + col_offset], col_length,
                            )
                        end
                        XLSX.setFont(
                            sheet, hl_row, j + col_offset + anchor_col_offset;
                            font_atts...,
                        )
                    end
                    if !isempty(fill_atts)
                        XLSX.setFill(
                            sheet, hl_row, j + col_offset + anchor_col_offset;
                            fill_atts...,
                        )
                    end
                    break
                end
            end
        end
    end

    # Set column widths based on accumulated content lengths.
    for i in 1:num_cols + col_offset
        col_width = _excel_get_col_width(table_format, i, max_col_length, col_offset)
        if col_width > 0.0
            XLSX.setColumnWidth(sheet, i + anchor_col_offset; width = col_width)
        end
    end

    # Re-apply row heights (may have been updated by highlighter font-size changes).
    for (row, height) in max_row_height
        XLSX.setRowHeight(sheet, row + anchor_row_offset; height = height)
    end

    return nothing
end
