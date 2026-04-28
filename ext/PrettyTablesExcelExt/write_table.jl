## Description #############################################################################
#
# Excel Back End: Write the table to an XLSX.Worksheet object.
#
############################################################################################

"""
    _excel__write_table!(
        sheet::XLSX.Worksheet,
        pspec::PrintingSpec;
        kwargs...
    ) -> Nothing

Write the complete table described by `pspec` to `sheet` using the PrettyTables.jl
printing iterator. Cell styling, borders, column widths, and row heights are all applied
during the single pass over the iterator.

# Keywords

- `anchor_cell::String`: Top-left cell of the table in A1 notation (e.g. `"B3"`).
    (**Default**: `"A1"`)
- `data_column_widths::Union{Float64, Vector{Float64}}`: Explicit width for each data column
    in Excel units, overriding auto-calculated widths. A scalar applies to all columns; a
    vector sets per-column widths. When set (> 0), `minimum_data_column_widths` and
    `maximum_data_column_widths` are ignored for that column.
    (**Default**: `0.0`)
- `excel_formatters::Vector{ExcelFormatter}`: Number-format rules applied to data and
    summary cells.
    (**Default**: `ExcelFormatter[]`)
- `minimum_data_column_widths::Union{Float64, Vector{Float64}}`: Minimum width for each
    data column in Excel units. A scalar applies to all columns; a vector sets per-column
    minimums.
    (**Default**: `0.0`)
- `maximum_data_column_widths::Union{Float64, Vector{Float64}}`: Maximum width for each
    data column in Excel units. A scalar applies to all columns; a vector sets per-column
    maximums.
    (**Default**: `0.0`)
- `style::ExcelTableStyle`: Font and fill style for each table section.
    (**Default**: `ExcelTableStyle()`)
- `table_format::ExcelTableFormat`: Border and column-width configuration.
    (**Default**: `ExcelTableFormat()`)
"""
function _excel__write_table!(
    sheet::XLSX.Worksheet,
    pspec::PrintingSpec;
    anchor_cell::String = "A1",
    data_column_widths::Union{Float64, Vector{Float64}} = 0.0,
    excel_formatters::Vector{ExcelFormatter} = ExcelFormatter[],
    highlighters::Vector{ExcelHighlighter} = ExcelHighlighter[],
    maximum_data_column_widths::Union{Float64, Vector{Float64}} = 0.0,
    minimum_data_column_widths::Union{Float64, Vector{Float64}} = 0.0,
    style::ExcelTableStyle = ExcelTableStyle(),
    table_format::ExcelTableFormat = ExcelTableFormat(),
)
    table_data = pspec.table_data

    c = XLSX.CellRef(anchor_cell)
    anchor_row_offset = Int(c.row_number  - 1)
    anchor_col_offset = Int(c.column_number - 1)

    num_cols   = table_data.num_columns
    col_offset = _excel__compute_col_offset(table_data)

    renderer = Val(pspec.renderer)

    if data_column_widths isa Number
        data_column_widths = data_column_widths .+ 0.0 * (1:num_cols)
    end

    if minimum_data_column_widths isa Number
        minimum_data_column_widths = minimum_data_column_widths .+ 0.0 * (1:num_cols)
    end

    if maximum_data_column_widths isa Number
        maximum_data_column_widths = maximum_data_column_widths .+ 0.0 * (1:num_cols)
    end

    max_row_height = Dict{Int, Float64}()
    max_col_length = zeros(Float64, num_cols + col_offset)

    # == Iterator Setup ====================================================================

    # Preprocess Union{Symbol,Vector{Int}} fields into concrete index iterables,
    # mirroring the Typst backend's handling.
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

    current_row = 1  # internal row counter (relative to the table, not the sheet)

    # Tracking variables used for post-loop operations and section transitions.
    first_content_row = 0      # absolute sheet row of first non-header row
    last_written_row  = 0      # absolute sheet row of last data/summary row

    all_cols = (1 + anchor_col_offset):(num_cols + col_offset + anchor_col_offset)

    # == Main Loop =========================================================================

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        action == :end_printing && break

        _, next_rs, _ = _next(ps, table_data)

        # == New Row ===================================================================

        if action == :new_row
            max_row_height[current_row] = 0.0

            # Ensure all cells in the row are non-empty before any merges.
            _excel__unempty_row!(sheet, current_row + anchor_row_offset, all_cols)

            # Track first non-header row for vertical_line_after_row_label_column
            # calculation.
            if first_content_row == 0 && rs != :table_header
                first_content_row = current_row + anchor_row_offset
            end

            if rs == :data && ps.i ∈ horizontal_lines_at_data_rows
                XLSX.setBorder(
                    sheet,
                    current_row + anchor_row_offset,
                    all_cols;
                    bottom = table_format.borders.middle_line,
                )
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

                # Ensure cells exist before any formatting on the blank row.
                _excel__unempty_row!(sheet, current_row + anchor_row_offset, all_cols)

            elseif rs == :column_labels && next_rs != :column_labels
                if table_format.horizontal_line_after_column_labels
                    XLSX.setBorder(
                        sheet, current_row + anchor_row_offset, all_cols;
                        bottom = table_format.borders.header_line,
                    )
                end

            elseif rs ∈ (:data, :continuation_row)
                last_written_row = current_row + anchor_row_offset

            elseif rs == :summary_row
                last_written_row = current_row + anchor_row_offset

                if next_rs == :summary_row
                    if table_format.horizontal_line_before_summary_rows
                        XLSX.setBorder(
                            sheet, current_row + anchor_row_offset, all_cols;
                            bottom = table_format.borders.middle_line,
                        )
                    end
                else
                    if table_format.horizontal_line_after_summary_rows
                        XLSX.setBorder(
                            sheet, current_row + anchor_row_offset, all_cols;
                            bottom = table_format.borders.middle_line,
                        )
                    end
                end

            elseif rs == :row_group_label
                if table_format.horizontal_line_before_row_group_label
                    XLSX.setBorder(
                        sheet, current_row + anchor_row_offset, all_cols;
                        top = table_format.borders.middle_line,
                    )
                end

                if table_format.horizontal_line_after_row_group_label
                    XLSX.setBorder(
                        sheet, current_row + anchor_row_offset, all_cols;
                        bottom = table_format.borders.middle_line,
                    )
                end
            end

            # Transition from data/summary to the table footer (or to summary rows).
            if (
                (
                    rs ∈ (:data, :continuation_row) &&
                    next_rs ∈ (:table_footer, :end_printing, :summary_row)
                ) || (
                    rs == :summary_row && next_rs ∈ (:table_footer, :end_printing)
                )
            )
                if table_format.horizontal_line_after_data_rows
                    XLSX.setBorder(
                        sheet, current_row + anchor_row_offset, all_cols;
                        bottom = table_format.borders.middle_line,
                    )
                end
            end


            current_row += 1

        # == Cell Actions ==================================================================

        else
            cell = _current_cell(action, ps, table_data)
            cell === _IGNORE_CELL && continue

            rendered_cell = _excel__render_cell(cell, renderer)

            alignment = _current_cell_alignment(action, ps, table_data)
            sheet_row = current_row + anchor_row_offset

            # Footnote superscripts to append to this cell.
            fn_indices = _current_cell_footnotes(table_data, action, ps.i, ps.j)

            if !isnothing(fn_indices) && !isempty(fn_indices)
                fn_str = join(_excel__to_superscript.(fn_indices))
                rendered_cell = string(rendered_cell) * fn_str
            end

            # -- Full-span cells -------------------------------------------------------
            if action ∈ (:title, :subtitle, :row_group_label, :footnote, :source_notes)

                if action == :footnote
                    # Footnote cells are prefixed with their index superscript.
                    rendered_cell = _excel__to_superscript(ps.i) * rendered_cell
                end

                style_key   = action == :source_notes ? "source_note" : string(action)
                style_field = getproperty(style, Symbol(style_key))

                style_attributes, fill_attributes = _excel__font_fill_attributes(
                    style_key, style_field
                )

                valign = if action ∈ (:title, :subtitle, :row_number_label)
                    "bottom"
                elseif action == :row_group_label
                    "center"
                else
                    "center"
                end

                row_height = _excel__write_full_span_cell!(
                    sheet,
                    rendered_cell,
                    current_row,
                    num_cols,
                    col_offset,
                    anchor_row_offset,
                    anchor_col_offset,
                    style_attributes,
                    fill_attributes,
                    alignment,
                    valign,
                )
                max_row_height[current_row] = max(max_row_height[current_row], row_height)

            # -- Column labels ---------------------------------------------------------
            elseif action == :column_label

                excel_col = ps.j + col_offset + anchor_col_offset

                if cell isa MergeCells
                    num_data_cols = _number_of_printed_data_columns(table_data)
                    span          = min(cell.column_span, num_data_cols - ps.j + 1)

                    sheet[sheet_row, excel_col] = rendered_cell

                    XLSX.mergeCells(
                        sheet,
                        XLSX.CellRange(
                            XLSX.CellRef(sheet_row, excel_col),
                            XLSX.CellRef(sheet_row, excel_col + span - 1),
                        ),
                    )

                    style_key = ps.i == 1 ?
                        "first_line_merged_column_label" :
                        "merged_column_label"

                    style_field = ps.i == 1 ?
                        style.first_line_merged_column_label :
                        style.merged_column_label

                    fontsize = _excel__apply_cell_style!(
                        sheet,
                        sheet_row,
                        excel_col,
                        style_key,
                        style_field,
                        cell.alignment,
                        "bottom",
                        true,
                    )

                    row_height, _ = _excel__cell_length_and_height(rendered_cell, fontsize)

                    max_row_height[current_row] = max(
                        max_row_height[current_row], row_height
                    )

                    if table_format.horizontal_line_at_merged_column_labels
                        XLSX.setBorder(
                            sheet, sheet_row, excel_col:(excel_col + span - 1);
                            bottom = table_format.borders.merged_header_cell_line,
                        )
                    end

                    if (
                        ps.j + span - 1 < num_cols &&
                        (ps.j + span - 1) ∈ vertical_lines_at_data_columns
                    )
                        XLSX.setBorder(
                            sheet,
                            sheet_row,
                            excel_col + span - 1;
                            right = table_format.borders.middle_line,
                        )
                    end

                else
                    sheet[sheet_row, excel_col] = rendered_cell

                    style_key = ps.i == 1 ? "first_line_column_label" : "column_label"

                    style_field = ps.i == 1 ?
                        style.first_line_column_label :
                        style.column_label

                    fontsize = _excel__apply_cell_style!(
                        sheet,
                        sheet_row,
                        excel_col,
                        style_key,
                        style_field,
                        alignment,
                        "bottom",
                        true;
                        col_idx = ps.j,
                    )

                    row_height, col_length = _excel__cell_length_and_height(
                        rendered_cell, fontsize
                    )

                    max_row_height[current_row] = max(
                        max_row_height[current_row], row_height
                    )

                    max_col_length[ps.j + col_offset] = max(
                        max_col_length[ps.j + col_offset], col_length
                    )

                    if ps.j < num_cols && ps.j ∈ vertical_lines_at_data_columns
                        XLSX.setBorder(
                            sheet,
                            sheet_row,
                            excel_col;
                            right = table_format.borders.middle_line,
                        )
                    end

                    if ps.i < length(table_data.column_labels) &&
                       table_format.horizontal_line_between_column_labels
                        XLSX.setBorder(
                            sheet, sheet_row, excel_col;
                            bottom = table_format.borders.middle_line,
                        )
                    end
                end

            # -- Row number label ----------------------------------------------------------
            elseif action == :row_number_label
                excel_col  = 1 + anchor_col_offset

                sheet[sheet_row, excel_col] = rendered_cell

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    excel_col,
                    "row_number_label",
                    style.row_number_label,
                    alignment,
                    "bottom",
                    false,
                )

                if table_format.vertical_line_after_row_number_column
                    XLSX.setBorder(
                        sheet, sheet_row, excel_col;
                        right = table_format.borders.center_line,
                    )
                end

                row_height, col_length = _excel__cell_length_and_height(
                    rendered_cell, fontsize
                )

                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[1] = max(max_col_length[1], col_length)

            # -- Row Number / Summary Row Number -------------------------------------------
            elseif action ∈ (:row_number, :summary_row_number)
                excel_col = 1 + anchor_col_offset

                sheet[sheet_row, excel_col] = rendered_cell

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    excel_col,
                    "row_number",
                    style.row_number,
                    alignment,
                    "top",
                    false,
                )

                if table_format.vertical_line_after_row_number_column
                    XLSX.setBorder(
                        sheet, sheet_row, excel_col;
                        right = table_format.borders.center_line,
                    )
                end

                row_height, _ = _excel__cell_length_and_height(rendered_cell, fontsize)

                max_row_height[current_row] = max(max_row_height[current_row], row_height)

            # -- Stubhead label --------------------------------------------------------
            elseif action == :stubhead_label
                excel_col  = col_offset + anchor_col_offset

                sheet[sheet_row, excel_col] = rendered_cell

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    excel_col,
                    "stubhead_label",
                    style.stubhead_label,
                    alignment,
                    "bottom",
                    true,
                )

                row_height, col_length = _excel__cell_length_and_height(
                    rendered_cell, fontsize
                )

                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[col_offset] = max(max_col_length[col_offset], col_length)

            # -- Row label / summary row label -----------------------------------------
            elseif action ∈ (:row_label, :summary_row_label)
                excel_col   = col_offset + anchor_col_offset
                style_key   = string(action)
                style_field = getproperty(style, Symbol(style_key))

                sheet[sheet_row, excel_col] = rendered_cell

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    excel_col,
                    style_key,
                    style_field,
                    alignment,
                    "top",
                    true,
                )

                row_height, col_length = _excel__cell_length_and_height(
                    rendered_cell, fontsize
                )

                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[col_offset]  = max(max_col_length[col_offset], col_length)

            # -- Data cell -------------------------------------------------------------
            elseif action == :data
                excel_col = ps.j + col_offset + anchor_col_offset

                lines = rendered_cell isa AbstractString ?
                    _excel__text_lines(rendered_cell) :
                    1

                sheet[sheet_row, excel_col] = rendered_cell

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    excel_col,
                    "table_cell",
                    style.table_cell,
                    alignment,
                    "top",
                    lines > 1;
                    col_idx = ps.j,
                )

                for formatter in excel_formatters
                    fmt_attributes = _excel__format_attributes(
                        table_data, formatter, current_row, ps.j
                    )
                    if !isnothing(fmt_attributes)
                        XLSX.setFormat(sheet, sheet_row, excel_col; fmt_attributes...)
                        break
                    end
                end

                if ps.j < num_cols && ps.j ∈ vertical_lines_at_data_columns
                    XLSX.setBorder(
                        sheet,
                        sheet_row,
                        excel_col;
                        right = table_format.borders.middle_line,
                    )
                end

                row_height, col_length = _excel__cell_length_and_height(
                    rendered_cell, fontsize
                )

                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[ps.j + col_offset] = max(
                    max_col_length[ps.j + col_offset], col_length
                )

                # Apply highlighters in order, breaking after the first match.
                for highlighter in highlighters
                    highlighter.f(table_data.data, ps.i, ps.j) || continue

                    decoration = highlighter.fd(highlighter, table_data.data, ps.i, ps.j)
                    font_attributes, fill_attributes = _excel__font_fill_attributes(
                        decoration
                    )

                    if !isempty(font_attributes)
                        hl_font_size = _excel__getsize(font_attributes)

                        if !isnothing(hl_font_size)
                            hl_row_height, hl_col_length = _excel__cell_length_and_height(
                                rendered_cell, hl_font_size
                            )
                            max_row_height[current_row] = max(
                                max_row_height[current_row], hl_row_height
                            )
                            max_col_length[ps.j + col_offset] = max(
                                max_col_length[ps.j + col_offset], hl_col_length
                            )
                        end

                        XLSX.setFont(sheet, sheet_row, excel_col; font_attributes...)
                    end

                    !isempty(fill_attributes) &&
                        XLSX.setFill(sheet, sheet_row, excel_col; fill_attributes...)

                    break
                end

            # -- Summary Row Cell ----------------------------------------------------------
            elseif action == :summary_row_cell
                excel_col = ps.j + col_offset + anchor_col_offset

                sheet[sheet_row, excel_col] = rendered_cell

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    excel_col,
                    "summary_row_cell",
                    style.summary_row_cell,
                    alignment,
                    "top",
                    false;
                    col_idx = ps.j,
                )

                for formatter in excel_formatters
                    fmt_attributes = _excel__format_attributes(
                        table_data, formatter, current_row, ps.j
                    )

                    if !isnothing(fmt_attributes)
                        XLSX.setFormat(sheet, sheet_row, excel_col; fmt_attributes...)
                        break
                    end
                end

                if ps.j < num_cols && ps.j ∈ vertical_lines_at_data_columns
                    XLSX.setBorder(
                        sheet, sheet_row, excel_col;
                        right = table_format.borders.middle_line,
                    )
                end

                row_height, col_length = _excel__cell_length_and_height(
                    rendered_cell, fontsize
                )

                max_row_height[current_row] = max(max_row_height[current_row], row_height)
                max_col_length[ps.j + col_offset] = max(
                    max_col_length[ps.j + col_offset], col_length
                )

            # -- Continuation cells ----------------------------------------------------
            elseif action ∈ (
                :horizontal_continuation_cell,
                :diagonal_continuation_cell,
                :vertical_continuation_cell,
                :row_number_vertical_continuation_cell,
                :row_label_vertical_continuation_cell,
            )
                cont_text = if action == :horizontal_continuation_cell
                    "⋯"
                elseif action == :diagonal_continuation_cell
                    "⋱"
                else
                    "⋮"
                end

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
        vline_end =
            last_written_row > 0 ? last_written_row : current_row + anchor_row_offset - 1

        if vline_start <= vline_end && table_format.vertical_line_after_row_label_column
            XLSX.setBorder(
                sheet, vline_start:vline_end, col_offset + anchor_col_offset;
                right = table_format.borders.center_line,
            )
        end
    end

    # Outer borders span only the content area (excludes title/subtitle and footnotes).
    content_start = first_content_row > 0 ? first_content_row : 1 + anchor_row_offset
    content_end =
        last_written_row > 0 ? last_written_row : current_row + anchor_row_offset - 1

    _excel__try_outer_borders!(sheet, content_start:content_end, all_cols, table_format)

    # Set column widths based on accumulated content lengths.
    for i in 1:(num_cols + col_offset)
        col_width = _excel__get_col_width(
            i,
            max_col_length,
            col_offset,
            data_column_widths,
            minimum_data_column_widths,
            maximum_data_column_widths,
        )

        col_width > 0 && XLSX.setColumnWidth(sheet, i + anchor_col_offset; width = col_width)
    end

    # Set final row heights.
    for (row, height) in max_row_height
        XLSX.setRowHeight(sheet, row + anchor_row_offset; height = height)
    end

    return nothing
end
