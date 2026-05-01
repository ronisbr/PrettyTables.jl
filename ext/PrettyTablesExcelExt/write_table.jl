## Description ############################################################################
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
- `highlighters::Vector{ExcelHighlighter}`: Highlighters to apply to the table.
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

    num_cols = table_data.num_columns
    num_printed_cols = _number_of_printed_columns(table_data)
    num_printed_data_cols = _number_of_printed_data_columns(table_data)

    initial_data_column =
        num_printed_cols - num_printed_data_cols - _is_horizontally_cropped(table_data)

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
    max_col_length = zeros(Float64, num_printed_cols)

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

    # Tracking variables used for post-loop operations and section transitions.
    first_content_row = 0 # ..................... Absolute sheet row of first non-header row
    last_written_row  = 0 # .................... Absolute sheet row of last data/summary row

    all_cols = (1 + anchor_col_offset):(num_printed_cols + anchor_col_offset)

    ir = jr = 0

    # == Main Loop =========================================================================

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        _, next_rs, _  = _next(ps, table_data)

        action == :end_printing && break

        jr += 1

        sheet_row = ir + anchor_row_offset
        sheet_col = jr + anchor_col_offset

        # == New Row =======================================================================

        if action == :new_row
            ir += 1
            jr  = 0

            max_row_height[ir] = 0.0

            # Ensure all cells in the row are non-empty before any merges.
            _excel__unempty_row!(sheet, ir + anchor_row_offset, all_cols)

            # Track first non-header row for vertical_line_after_row_label_column
            # calculation.
            if first_content_row == 0 && rs != :table_header
                first_content_row = ir + anchor_row_offset
            end

            if rs == :data && ps.i ∈ horizontal_lines_at_data_rows
                XLSX.setBorder(
                    sheet,
                    ir + anchor_row_offset,
                    all_cols;
                    bottom = table_format.borders.middle_line,
                )
            end

        # == Continuation Cells ============================================================

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
                sheet,
                sheet_row,
                sheet_col,
                style.row_number_label,
                alignment,
                "bottom",
                false,
            )

            row_height, col_length = _excel__cell_length_and_height(rendered_cell, fontsize)

            max_row_height[ir] = max(max_row_height[ir], row_height)
            max_col_length[jr] = max(
                max_col_length[jr], col_length
            )

        # == End Row =======================================================================

        elseif action == :end_row
            XLSX.setRowHeight(
                sheet,
                ir + anchor_row_offset;
                height = max_row_height[ir],
            )

            if rs == :column_labels && next_rs != :column_labels
                if table_format.horizontal_line_after_column_labels
                    XLSX.setBorder(
                        sheet, ir + anchor_row_offset, all_cols;
                        bottom = table_format.borders.header_line,
                    )
                end

            elseif rs ∈ (:data, :continuation_row)
                last_written_row = ir + anchor_row_offset

            elseif rs == :summary_row
                last_written_row = ir + anchor_row_offset

                if next_rs == :summary_row
                    if table_format.horizontal_line_before_summary_rows
                        XLSX.setBorder(
                            sheet, ir + anchor_row_offset, all_cols;
                            bottom = table_format.borders.middle_line,
                        )
                    end
                else
                    if table_format.horizontal_line_after_summary_rows
                        XLSX.setBorder(
                            sheet, ir + anchor_row_offset, all_cols;
                            bottom = table_format.borders.middle_line,
                        )
                    end
                end

            elseif rs == :row_group_label
                if table_format.horizontal_line_before_row_group_label
                    XLSX.setBorder(
                        sheet, ir + anchor_row_offset, all_cols;
                        top = table_format.borders.middle_line,
                    )
                end

                if table_format.horizontal_line_after_row_group_label
                    XLSX.setBorder(
                        sheet, ir + anchor_row_offset, all_cols;
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
                        sheet, ir + anchor_row_offset, all_cols;
                        bottom = table_format.borders.middle_line,
                    )
                end

            end

        # == Cell Actions ==================================================================

        else
            cell = _current_cell(action, ps, table_data)
            cell === _IGNORE_CELL && continue

            rendered_cell = _excel__render_cell(cell, renderer)

            alignment = _current_cell_alignment(action, ps, table_data)

            # Footnote superscripts to append to this cell.
            fn_indices = _current_cell_footnotes(table_data, action, ps.i, ps.j)

            if !isnothing(fn_indices) && !isempty(fn_indices)
                fn_str = join(_excel__to_superscript.(fn_indices))
                rendered_cell = string(rendered_cell) * fn_str
            end

            # -- Full-span Cells -----------------------------------------------------------

            if action ∈ (:title, :subtitle, :row_group_label, :footnote, :source_notes)
                if action == :footnote
                    # Footnote cells are prefixed with their index superscript.
                    rendered_cell = _excel__to_superscript(ps.i) * rendered_cell
                end

                style_key  = action == :source_notes ? "source_note" : string(action)
                cell_style = getproperty(style, Symbol(style_key))

                valign = if action ∈ (:title, :subtitle, :row_number_label)
                    "bottom"
                elseif action == :row_group_label
                    "center"
                else
                    "center"
                end

                col_start = 1 + anchor_col_offset
                col_end   = num_printed_cols + anchor_col_offset

                sheet[sheet_row, col_start] = rendered_cell

                XLSX.mergeCells(
                    sheet,
                    XLSX.CellRange(
                        XLSX.CellRef(sheet_row, col_start),
                        XLSX.CellRef(sheet_row, col_end),
                    ),
                )

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    col_start,
                    cell_style,
                    alignment,
                    valign,
                    true
                )

                text_lines = _excel__text_lines(rendered_cell)
                row_height = _excel__row_height_for_text(text_lines, fontsize)

                max_row_height[ir] = max(max_row_height[ir], row_height)

            # -- Column labels (Merged Cell) -----------------------------------------------

            elseif (action == :column_label) && (cell isa MergeCells)
                num_data_cols = _number_of_printed_data_columns(table_data)
                span          = min(cell.column_span, num_data_cols - ps.j + 1)

                sheet[sheet_row, sheet_col] = rendered_cell

                XLSX.mergeCells(
                    sheet,
                    XLSX.CellRange(
                        XLSX.CellRef(sheet_row, sheet_col),
                        XLSX.CellRef(sheet_row, sheet_col + span - 1),
                    ),
                )

                cell_style = ps.i == 1 ?
                    style.first_line_merged_column_label :
                    style.merged_column_label

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    sheet_col,
                    cell_style,
                    cell.alignment,
                    "bottom",
                    true,
                )

                row_height, _ = _excel__cell_length_and_height(rendered_cell, fontsize)

                max_row_height[ir] = max(
                    max_row_height[ir], row_height
                )

                if table_format.horizontal_line_at_merged_column_labels
                    XLSX.setBorder(
                        sheet, sheet_row, sheet_col:(sheet_col + span - 1);
                        bottom = table_format.borders.merged_header_cell_line,
                    )
                end

                # We draw the vertical line here because we have access to the actual
                # span of the merged cell.
                if (
                    ((ps.j + span - 1) ∈ vertical_lines_at_data_columns) || (
                        (ps.j + span - 1) == num_printed_data_cols &&
                        table_format.vertical_line_after_data_columns
                    )
                )
                    XLSX.setBorder(
                        sheet,
                        sheet_row,
                        sheet_col + span - 1;
                        right = table_format.borders.middle_line,
                    )
                end

            # -- Other Cells ---------------------------------------------------------------
            else
                vertical_alignment = "bottom"
                cell_style         = _EXCEL__NO_DECORATION
                wrap               = false

                # -- Unmerged Column labels ------------------------------------------------

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

                    if ps.i < length(table_data.column_labels) &&
                       table_format.horizontal_line_between_column_labels
                        XLSX.setBorder(
                            sheet, sheet_row, sheet_col;
                            bottom = table_format.borders.middle_line,
                        )
                    end

                # -- Row number Label ------------------------------------------------------

                elseif action == :row_number_label
                    cell_style = style.row_number_label
                    vertical_alignment = "bottom"
                    wrap = true

                # -- Row Number / Summary Row Number ---------------------------------------

                elseif action ∈ (:row_number, :summary_row_number)
                    cell_style = style.row_number
                    vertical_alignment = "top"
                    wrap = true

                # -- Stubhead Label --------------------------------------------------------

                elseif action == :stubhead_label
                    cell_style = style.stubhead_label
                    vertical_alignment = "bottom"
                    wrap = true

                # -- Row Label / Summary Row Label -----------------------------------------

                elseif action == :row_label
                    cell_style = style.row_label
                    vertical_alignment = "top"
                    wrap = true

                elseif action == :summary_row_label
                    cell_style = style.summary_row_label
                    vertical_alignment = "top"
                    wrap = true

                # -- Data Cell -------------------------------------------------------------

                elseif action == :data
                    lines = _excel__text_lines(rendered_cell)
                    vertical_alignment = "top"
                    wrap = lines > 1

                    for formatter in excel_formatters
                        fmt_attributes = _excel__format_attributes(
                            table_data, formatter, ir, ps.j
                        )
                        if !isnothing(fmt_attributes)
                            XLSX.setFormat(sheet, sheet_row, sheet_col; fmt_attributes...)
                            break
                        end
                    end

                    # Apply highlighters in order, breaking after the first match.
                    for highlighter in highlighters
                        highlighter.f(table_data.data, ps.i, ps.j) || continue

                        decoration = highlighter.fd(highlighter, table_data.data, ps.i, ps.j)

                        hl_font_size = _excel__apply_cell_style!(
                            sheet,
                            sheet_row,
                            sheet_col,
                            decoration,
                            nothing,
                            "",
                            false
                        )

                        hl_row_height, hl_col_length = _excel__cell_length_and_height(
                            rendered_cell, hl_font_size
                        )

                        max_row_height[ir] = max(
                            max_row_height[ir], hl_row_height
                        )

                        max_col_length[jr] = max(
                            max_col_length[jr], hl_col_length
                        )

                        break
                    end

                # -- Summary Row Cell ------------------------------------------------------

                elseif action == :summary_row_cell
                    vertical_alignment = "top"
                    wrap = false

                    for formatter in excel_formatters
                        fmt_attributes = _excel__format_attributes(
                            table_data, formatter, ir, ps.j
                        )

                        if !isnothing(fmt_attributes)
                            XLSX.setFormat(sheet, sheet_row, sheet_col; fmt_attributes...)
                            break
                        end
                    end
                end

                sheet[sheet_row, sheet_col] = rendered_cell

                fontsize = _excel__apply_cell_style!(
                    sheet,
                    sheet_row,
                    sheet_col,
                    cell_style,
                    alignment,
                    vertical_alignment,
                    wrap
                )

                row_height, col_length = _excel__cell_length_and_height(
                    rendered_cell, fontsize
                )

                max_row_height[ir] = max(max_row_height[ir], row_height)
                max_col_length[jr] = max(max_col_length[jr], col_length)
            end
        end

        # == Vertical Lines ================================================================

        if action ∈ (
            :row_number_label,
            :row_number,
            :row_number_vertical_continuation_cell,
            :summary_row_number
        )
            table_format.vertical_line_after_row_number_column &&
                XLSX.setBorder(
                    sheet,
                    sheet_row,
                    sheet_col;
                    right = table_format.borders.center_line
                )

        elseif action ∈ (
            :stubhead_label,
            :row_label,
            :row_label_vertical_continuation_cell,
            :summary_row_label
        )
            table_format.vertical_line_after_row_label_column &&
                XLSX.setBorder(
                    sheet,
                    sheet_row,
                    sheet_col;
                    right = table_format.borders.center_line,
                )

        elseif action ∈ (
            :column_label,
            :data,
            :summary_row_cell,
            :vertical_continuation_cell,
        )
            if !(action == :column_label && cell isa MergeCells)
                if (
                    (ps.j ∈ vertical_lines_at_data_columns) || (
                        ps.j == num_printed_data_cols &&
                        table_format.vertical_line_after_data_columns
                    )
                )
                    XLSX.setBorder(
                        sheet,
                        sheet_row,
                        sheet_col;
                        right = table_format.borders.middle_line,
                    )
                end
            end
        end
    end

    # == Post-Loop Operations ==============================================================

    # Vertical line to the right of the row labels column.
    if table_data.row_labels !== nothing
        vline_start = first_content_row > 0 ? first_content_row : 1 + anchor_row_offset
        vline_end =
            last_written_row > 0 ? last_written_row : ir + anchor_row_offset - 1

        if vline_start <= vline_end && table_format.vertical_line_after_row_label_column
            XLSX.setBorder(
                sheet, vline_start:vline_end, initial_data_column + anchor_col_offset;
                right = table_format.borders.center_line,
            )
        end
    end

    # Outer borders span only the content area (excludes title/subtitle and footnotes).
    content_start = first_content_row > 0 ? first_content_row : 1 + anchor_row_offset
    content_end =
        last_written_row > 0 ? last_written_row : ir + anchor_row_offset - 1
    all_rows = content_start:content_end

    b = table_format.borders

    if table_format.horizontal_line_at_beginning
        XLSX.setBorder(sheet, content_start, all_cols; top    = b.top_line)
        XLSX.setBorder(sheet, content_end,   all_cols; bottom = b.bottom_line)
    end

    if table_format.vertical_line_at_beginning
        XLSX.setBorder(sheet, all_rows, first(all_cols); left = b.left_line)
    end

    if _is_horizontally_cropped(table_data)
        table_format.vertical_line_after_continuation_column && XLSX.setBorder(
            sheet,
            all_rows,
            last(all_cols);
            right = b.right_line,
        )
    else
        table_format.vertical_line_after_data_columns &&
            XLSX.setBorder(sheet, all_rows, last(all_cols); right = b.right_line)
    end

    # Set column widths based on accumulated content lengths.
    for i in 1:num_printed_cols
        col_width = _excel__get_col_width(
            i,
            max_col_length,
            initial_data_column,
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
