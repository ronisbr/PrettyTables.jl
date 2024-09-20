## Description #############################################################################
#
# Text back end for PrettyTables.jl.
#
############################################################################################

function _text__circular_reference(io::IOContext)
    print(io, "#= circular reference =#")
    return nothing
end

function _text__print_table(
    pspec::PrintingSpec;
    tf::TextTableFormat = TextTableFormat(),
    column_label_width_based_on_first_line_only::Bool = false,
    display_size::NTuple{2, Int} = displaysize(pspec.context),
    fit_table_in_display_horizontally::Bool = true,
    fit_table_in_display_vertically::Bool = true,
    line_breaks::Bool = false,
    highlighters::Vector{TextHighlighter} = TextHighlighter[],
    maximum_data_column_widths::Union{Number, Vector{Int}} = 0,
    style::TextTableStyle = TextTableStyle(),
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # If the user does not want to crop the table horizontally, we set the display width to
    # -1, meaning that we do not have a limit.
    if !fit_table_in_display_horizontally
        display_size = (display_size[1], -1)
    end

    # If the user does not want to crop the table vertically, we set the display length to
    # -1, meaning that we do not have a limit.
    if !fit_table_in_display_vertically
        display_size = (-1, display_size[2])
    end

    # Create the structure that holds the display information.
    display = Display(
        display_size,
        1,
        0,
        get(context, :color, false),
        buf_io,
        IOBuffer()
    )

    # Process the vertical lines at data columns.
    if tf.right_vertical_lines_at_data_columns isa Symbol
        right_vertical_lines_at_data_columns =
            if tf.right_vertical_lines_at_data_columns == :all
                1:table_data.num_columns
            else
                1:0
            end
    else
        right_vertical_lines_at_data_columns =
            tf.right_vertical_lines_at_data_columns::Vector{Int}
    end

    # Process the horizontal lines at data rows.
    if tf.horizontal_lines_at_data_rows isa Symbol
        horizontal_lines_at_data_rows = if tf.horizontal_lines_at_data_rows == :all
            1:table_data.num_rows
        else
            1:0
        end
    else
        horizontal_lines_at_data_rows = tf.horizontal_lines_at_data_rows::Vector{Int}
    end

    # Limit the number of rendered columns given the display size if the user wants.
    if fit_table_in_display_horizontally && (display_size[2] > 0)
        mc = div(display.size[2], 5, RoundUp)

        if table_data.maximum_number_of_columns >= 0
            table_data.maximum_number_of_columns = min(
                table_data.maximum_number_of_columns,
                mc
            )
        else
            table_data.maximum_number_of_columns = mc
        end
    end

    # Limit the number of rendered rows given the display size if the user wants.
    vertically_limited_by_display          = false
    suppress_hline_before_continuation_row = false
    suppress_hline_after_continuation_row  = false

    if fit_table_in_display_vertically && (display_size[1] > 0)
        # We do not support middle cropping when using line breaks since it will required a
        # much more complex algorithm, decreasing the maintainability.
        if line_breaks
            table_data.vertical_crop_mode = :bottom
        end

        # NOTE: In case we have line breaks, this design is only preliminary. In this case,
        # we perform the following actions:
        #
        #   1. Design the number of rendered rows assuming one line per row.
        #   2. Render the table.
        #   2. Compute the number of rendered columns.
        #   3. Re-design the number of rendered rows considering the actual number of lines.

        mr, suppress_hline_before_continuation_row, suppress_hline_after_continuation_row =
            _text__design_vertical_cropping(
                table_data,
                tf,
                horizontal_lines_at_data_rows,
                pspec.show_omitted_cell_summary,
                display.size[1]
            )

        if table_data.maximum_number_of_rows >= 0
            vertically_limited_by_display = mr < table_data.maximum_number_of_rows
            table_data.maximum_number_of_rows = min(table_data.maximum_number_of_rows, mr)
        else
            vertically_limited_by_display = mr < table_data.num_rows
            table_data.maximum_number_of_rows = mr
        end
    end

    # == Render the Table ==================================================================

    # For the text back end, we need to render the entire table before printing to take into
    # account the required column width.

    row_labels, column_labels, table_str, summary_rows, footnotes = _text__render_table(
        table_data,
        context,
        renderer,
        line_breaks,
        maximum_data_column_widths,
    )

    num_printed_data_rows, num_printed_data_columns = size(table_str)

    # == Compute the Column Width ==========================================================

    row_number_column_width, row_label_column_width, printed_data_column_widths =
        _text__printed_column_widths(
            table_data,
            row_labels,
            column_labels,
            summary_rows,
            table_str,
            right_vertical_lines_at_data_columns,
            column_label_width_based_on_first_line_only,
            line_breaks
        )

    # Now, we crop the additional column labels if the user wants to do so.
    # TODO: What we should do with the merged column labels?
    if column_label_width_based_on_first_line_only
        for j in eachindex(printed_data_column_widths)
            cw  = printed_data_column_widths[j]
            cls = @views column_labels[:, j]

            for i in eachindex(cls)
                str = cls[i]
                tw  = textwidth(str)

                tw <= cw && continue

                str, _ = right_crop(str, tw - printed_data_column_widths[j] + 1)
                cls[i] = str * "…"
            end
        end
    end

    # == Omitted Columns ===================================================================

    # In text back end, the printed column can be limited either by the user specification
    # or by the display limit. Now, we have access to the width of all candidate columns to
    # be printed. Hence, we can update the number of printed columns accordingly. Notice
    # that we also must analyze if the table continuation column is required since in text
    # back end we also have the continuation caused by the display end-of-line.

    # Compute the required width to display the table using the user specification without
    # the continuation column.
    table_width_wo_cont_col = _text__table_width_wo_cont_column(
        table_data,
        tf,
        right_vertical_lines_at_data_columns,
        row_number_column_width,
        row_label_column_width,
        printed_data_column_widths,
    )

    # We need to check if we are limiting the number of columns by the display or by the
    # user specification.
    horizontally_limited_by_display = false

    if fit_table_in_display_horizontally && (display.size[2] > 0)
        # Here we have three possibilities:
        #
        #   1. We cannot show the table continuation column, meaning that the table is
        #      horizontally limited by the display.
        #   2. We can partially show the continuation column, meaning that the table is
        #      horizontally limited by the display but there is a continuation column.
        #   3. We can show the continuation column, meaning that the table is horizontally
        #      cropped by the user specification.

        num_remaining_columns = display_size[2] - table_width_wo_cont_col

        horizontally_limited_by_display =
            num_remaining_columns < (3 + tf.vertical_line_after_continuation_column)
    end

    # If we are limited by the display, we need to update the number of printed columns and
    # rows.
    if horizontally_limited_by_display
        num_printed_data_columns = _text__number_of_printed_data_columns(
            display.size[2],
            table_data,
            tf,
            right_vertical_lines_at_data_columns,
            row_number_column_width,
            row_label_column_width,
            printed_data_column_widths,
        )

        table_data.maximum_number_of_columns = min(
            num_printed_data_columns + 1,
            length(column_labels)
        )
    end

    # If this is the very first row, we must check if a horizontal line must be printed.
    num_omitted_data_columns = table_data.num_columns - num_printed_data_columns
    num_omitted_data_rows    = table_data.num_rows - num_printed_data_rows

    # We must compute what will be the last printed column index to draw the correct
    # vertical lines. Notice that, at this point, we might be printing a column partially.
    last_printed_column_index = if horizontally_limited_by_display
        table_data.maximum_number_of_columns
    else
        num_printed_data_columns
    end

    # Finally, we can compute the printed table width.
    printed_table_width = table_width_wo_cont_col

    if _is_horizontally_cropped(table_data)
        printed_table_width += 3 + tf.vertical_line_after_continuation_column
    end

    if horizontally_limited_by_display
        printed_table_width = display_size[2]
    end

    # == Vertical Cropping Design with Line Breaks =========================================

    # Up to now, we consider that each table row has only one line. Now that we know how
    # many columns we must print, we can redesign the vertical cropping if the user wants
    # line breaks. In this case, we will analyze each line and check how many data rows we
    # can print considering the multiple lines.

    if fit_table_in_display_vertically && line_breaks
        # Notice that `mr` contains the number of fully printed data rows. Furthermore, if
        # `lrc` is `true`, the last row is cropped, meaning that we need to print `mr + 1`
        # rows from the rendered table.
        mr, lrc, supress_hline_before_continuation_row =
            _text__design_vertical_cropping_with_line_breaks(
                table_data,
                table_str,
                tf,
                horizontal_lines_at_data_rows,
                pspec.show_omitted_cell_summary,
                display.size[1],
                num_printed_data_columns,
            )

        if table_data.maximum_number_of_rows >= 0
            vertically_limited_by_display =
                vertically_limited_by_display || (mr < table_data.maximum_number_of_rows)

            table_data.maximum_number_of_rows = min(
                table_data.maximum_number_of_rows,
                mr + lrc
            )
        else
            vertically_limited_by_display =
                vertically_limited_by_display ||
                (num_fully_printed_data_rows < table_data.num_rows)

            table_data.maximum_number_of_rows = mr + lrc
        end

        # Now that we have the number of fully printed data rows, we must update those
        # variables.
        num_printed_data_rows = table_data.maximum_number_of_rows
        num_omitted_data_rows = table_data.num_rows - mr
    end

    # == Print the Table ===================================================================

    ps     = PrintingTableState()
    action = :initialize

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    # Variable to store how many data lines were printed.
    num_data_lines = 0

    top_line_printed = false

    # Those variables are used to process rows with multiple lines.
    #
    # Number of lines in the current row. It is computed by the maximum number of lines
    # inside a data cell in a specific row.
    num_lines_in_row = 0

    # Number of lines available in the display for the data section. Notice that it only
    # makes sense if the display are limiting the table.
    num_available_data_section_lines = if vertically_limited_by_display
        total_table_lines, num_lines_before_data, num_lines_after_data =
            _text__number_of_required_lines(table_data, tf, horizontal_lines_at_data_rows)

        (
            display.size[1] -
            num_lines_before_data -
            num_lines_after_data -
            pspec.show_omitted_cell_summary -
            1 # ........................................................... Continuation row
        )
    else
        0
    end

    # Number of lines printed in data section, including horizontal lines and row group
    # labels.
    num_printed_data_section_lines = 0

    # Stored state at the beginning of the row with multiple lines. We used those values to
    # reiterate the printing state until we have no more new rows.
    saved_ps = PrintingTableState()
    saved_ir = 0

    # Current row line that is being printed. If it is 0, the current row does not have
    # multiple lines.
    current_row_line = 0

    tokens = if !line_breaks
        nothing
    else
        Vector{Vector{SubString}}(undef, last_printed_column_index)
    end

    while action != :end_printing
        if current_row_line == 0
            saved_ps = ps
            saved_ir = ir
        end

        action, rs, ps = _next(ps, table_data)
        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action == :end_printing && break

        # If we already printed the number of available lines in data section, skip
        # everything until we exit the data section.
        if line_breaks && (rs == :data) && (num_available_data_section_lines > 0) &&
            (num_printed_data_section_lines >= num_available_data_section_lines)
            current_row_line = 0
            continue
        end

        # == Table Header and Footer =======================================================

        if rs == :table_header
            if action ∈ (:title, :subtitle)
                alignment     = _current_cell_alignment(action, ps, table_data)
                cell          = _current_cell(action, ps, table_data)
                decoration    = action == :title ? style.title : style.subtitle
                rendered_cell = _text__render_cell(cell, buf, renderer)

                _text__print_aligned(
                    display,
                    rendered_cell,
                    printed_table_width,
                    alignment,
                    decoration
                )
                _text__flush_line(display)
            end

            continue

        elseif rs == :table_footer
            if action == :footnote
                alignment  = _current_cell_alignment(action, ps, table_data)
                decoration = style.footnote

                _text__print_aligned(
                    display,
                    footnotes[ps.i],
                    printed_table_width,
                    alignment,
                    decoration
                )
                _text__flush_line(display)

            elseif action == :source_notes
                alignment     = _current_cell_alignment(action, ps, table_data)
                cell          = _current_cell(action, ps, table_data)
                decoration    = style.source_note
                rendered_cell = _text__render_cell(cell, buf, renderer)

                _text__print_aligned(
                    display,
                    rendered_cell,
                    printed_table_width,
                    alignment,
                    decoration
                )
                _text__flush_line(display)
            end

            continue
        end

        # == New Row =======================================================================

        if action == :new_row

            # If this is the very first row, we must check if a horizontal line must be
            # printed.
            if tf.horizontal_line_at_beginning && !top_line_printed
                _text__print_column_label_horizontal_line(
                    display,
                    tf,
                    table_data,
                    ir - 1,
                    right_vertical_lines_at_data_columns,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths,
                    true
                )

                _text__flush_line(display, false)

                top_line_printed = true
            end

            if rs == :row_group_label
                # We must draw the horizontal line here if the user requested, if the last
                # row has a horizontal line due to the intersections, or if the last row was
                # a column label and the user wants a line after it.
                if tf.horizontal_line_before_row_group_label ||
                    (ir - 1 ∈ horizontal_lines_at_data_rows) ||
                    (ir == 1 && tf.horizontal_line_after_column_labels)

                    _text__print_horizontal_line(
                        display,
                        tf,
                        table_data,
                        right_vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                        true,
                        false,
                        true
                    )

                    _text__flush_line(display, false)
                    num_printed_data_section_lines += 1
                end
            end

            # Check if we need to start processing multiple row lines.
            if line_breaks && (rs == :data) && (current_row_line == 0)
                num_lines_in_row = maximum(count.(==('\n'), table_str[ir, :])) + 1
                current_row_line = 1

                # Obtain the tokens for each line.
                for jt in eachindex(tokens)
                    tokens[jt] = split(table_str[ir, jt], '\n')
                end
            end

            tf.vertical_line_at_beginning && _text__print(display, tf.borders.column)

            continue
        end

        # == Continuation Row ==============================================================

        if action == :diagonal_continuation_cell
            _text__print(display, " ⋱ ")
            tf.vertical_line_after_continuation_column &&
                _text__print(display, tf.borders.column)
            continue

        elseif action == :horizontal_continuation_cell
            _text__print(display, " ⋯ ")
            tf.vertical_line_after_continuation_column &&
                _text__print(display, tf.borders.column)
            continue

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            alignment = _current_cell_alignment(action, ps, table_data)

            if action == :row_number_vertical_continuation_cell
                cell_width = row_number_column_width
                hline      = tf.vertical_line_after_row_number_column

            elseif action == :row_label_vertical_continuation_cell
                cell_width = row_label_column_width
                hline      = tf.vertical_line_after_row_label_column

            else
                cell_width = printed_data_column_widths[jr]
                hline = false

                if jr == last_printed_column_index
                    tf.vertical_line_after_data_columns && (hline = true)
                elseif ps.j ∈ right_vertical_lines_at_data_columns
                    hline = true
                end
            end

            _text__print(display, " ")
            _text__print_aligned(display, "⋮", cell_width, alignment)
            _text__print(display, " ")
            hline && _text__print(display, tf.borders.column)

            continue
        end

        # == End Row =======================================================================

        if action == :end_row
            _, next_rs, _ = _next(ps, table_data)

            if rs == :data
                num_data_lines += 1
                num_printed_data_section_lines += 1
            elseif rs == :row_group_label
                num_printed_data_section_lines += 1
            end

            # == Flush the Line ============================================================

            if rs == :continuation_row
                _text__flush_line(display, true, '⋱')

            elseif rs == :data
                _text__flush_line(
                    display,
                    true,
                    (num_data_lines - 1) % (tf.ellipsis_line_skip + 1) == 0 ? '⋯' : ' '
                )

            else
                _text__flush_line(display)
            end

            # Check if we must render another line for this row or if we should go to the
            # next row.
            if current_row_line > 0
                current_row_line += 1

                if current_row_line <= num_lines_in_row
                    # We if reached this point, we must render another line of the same row.
                    # Hence, we will restore that saved state at the beginning of the line,
                    # and render it again. Since we increased `current_row_line`, we will
                    # render the
                    # next row.
                    ps = saved_ps
                    ir = saved_ir
                    continue
                end

                # If we reached this point, we finished rendering the row.
                current_row_line = 0
            end

            # == Handle the Horizontal Lines ===============================================

            # Print the horizontal line after the column labels.
            if (rs == :column_labels) && (ps.row_section != :column_labels) &&
                tf.horizontal_line_after_column_labels

                # We should skip this line if we have a row group label at the first column.
                if next_rs != :row_group_label
                    # We must handle that case where there is no data rows. In this case,
                    # the next section after the column labels will be the table footer or
                    # the end of printing.
                    bottom = next_rs ∈ (:table_footer, :end_printing)

                    _text__print_column_label_horizontal_line(
                        display,
                        tf,
                        table_data,
                        length(table_data.column_labels),
                        right_vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                        false,
                        bottom
                    )

                    _text__flush_line(display, false)
                end

            # Check if we must print an horizontal line after the current data row.
            elseif (rs == :data) && (ps.i ∈ horizontal_lines_at_data_rows)
                hline = true

                # We should only print this line if the next state is not the continuation
                # row or if we do not need to suppress the line before the continuation row.
                if (next_rs == :continuation_row) && suppress_hline_before_continuation_row
                    hline = false

                elseif _print_row_group_label(table_data, ir + 1)
                    hline = false
                end

                if hline
                    _text__print_horizontal_line(
                        display,
                        tf,
                        table_data,
                        right_vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                    )

                    _text__flush_line(display, false)
                    num_printed_data_section_lines += 1
                end

            elseif (rs == :data) &&
                (next_rs ∈ (:summary_row, :table_footer, :end_printing)) &&
                tf.horizontal_line_after_data_rows

                bottom = next_rs ∈ (:table_footer, :end_printing)

                _text__print_horizontal_line(
                    display,
                    tf,
                    table_data,
                    right_vertical_lines_at_data_columns,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths,
                    false,
                    bottom
                )

                _text__flush_line(display, false)
                num_printed_data_section_lines += 1

            # Check if we must print an horizontal line after the continuation row.
            elseif (rs == :continuation_row) && !suppress_hline_after_continuation_row
                hline = false
                bottom = next_rs ∈ (:table_footer, :end_printing)

                if ps.i ∈ horizontal_lines_at_data_rows
                    hline = true
                end

                if (next_rs !== :data) && tf.horizontal_line_after_data_rows
                    hline = true
                end

                if hline
                    _text__print_horizontal_line(
                        display,
                        tf,
                        table_data,
                        right_vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                        false,
                        bottom
                    )

                    _text__flush_line(display, false)
                end

            elseif (rs == :row_group_label)
                if tf.horizontal_line_after_row_group_label
                    _text__print_horizontal_line(
                        display,
                        tf,
                        table_data,
                        right_vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                        false,
                        true,
                        true
                    )

                    _text__flush_line(display, false)
                    num_printed_data_section_lines += 1
                end

            # Check if the must print the horizontal line at the end of the table.
            elseif (rs == :summary_row) && (next_rs != :summary_row)
                # If the next section is the table footer, we must draw the last table line.
                if tf.horizontal_line_after_summary_rows
                    _text__print_horizontal_line(
                        display,
                        tf,
                        table_data,
                        right_vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                        false,
                        true
                    )

                    _text__flush_line(display, false)
                end
            end

            # == Omitted Cell Summary ======================================================

            # We also must show the omitted cell summary if the user requested it.
            if (ps.row_section == :table_footer) && pspec.show_omitted_cell_summary
                ocs = _omitted_cell_summary(
                    num_omitted_data_rows,
                    num_omitted_data_columns
                )

                isempty(ocs) && continue

                _text__print_aligned(
                    display,
                    ocs,
                    printed_table_width,
                    :r,
                    style.omitted_cell_summary
                )

                _text__flush_line(display)
            end

            continue
        end

        # == Table Cells ===================================================================

        # If we reach this point, we are processing table cells.

        alignment     = _current_cell_alignment(action, ps, table_data)
        cell_width    = 1
        decoration    = _TEXT__DEFAULT
        rendered_cell = ""
        vline         = false
        vline_char    = tf.borders.column

        mc_last_index = 0
        merged_cell   = false

        # -- Width, Decoration, and Rendered String ----------------------------------------

        if action == :row_number_label
            cell          = _current_cell(action, ps, table_data)
            cell_width    = row_number_column_width
            decoration    = style.row_number_label
            rendered_cell = _text__render_cell(cell, buf, renderer)

        elseif action == :stubhead_label
            cell          = _current_cell(action, ps, table_data)
            cell_width    = row_label_column_width
            decoration    = style.stubhead_label
            rendered_cell = _text__render_cell(cell, buf, renderer)

        elseif action == :row_label
            cell_width    = row_label_column_width
            decoration    = style.row_label
            rendered_cell = row_labels[ir]

        elseif action == :summary_row_number
            cell_width    = row_number_column_width
            rendered_cell = ""

        elseif action == :summary_row_label
            cell_width    = row_label_column_width
            decoration    = style.summary_row_label
            rendered_cell = table_data.summary_row_labels[ir]

        elseif action == :column_label
            cell          = _current_cell(action, ps, table_data)
            cell_width    = printed_data_column_widths[jr]
            rendered_cell = column_labels[ir, jr]
            decoration    = if ir == 1
                style.first_line_column_label
            else
                style.column_label
            end

            cell === _IGNORE_CELL && continue

            if cell isa MergeCells
                alignment = cell.alignment

                j₀ = jr
                j₁ = min(jr + cell.column_span - 1, last_printed_column_index)

                cell_width = 0

                for j in j₀:j₁
                    cell_width += printed_data_column_widths[j] + 2

                    # We must add a space if we have a vertical line in the merged cells.
                    if (j != j₁) && (j ∈ right_vertical_lines_at_data_columns)
                        cell_width += 1
                    end
                end

                # We already take into account 2 characters for the margin below.
                cell_width -= 2

                # We must store that this is a merged cell and also what is the last column
                # index of it. It is necessary when drawing the vertical lines. The user
                # can ask to suppress all the vertical lines in the column labels. In
                # this case, we will draw only the very last one if necessary. Thus, we must
                # know if we are at the last cell when drawing a merged cell.
                merged_cell   = true
                mc_last_index = j₁

                # Apply the correct decoration.
                decoration = if ir == 1
                    style.first_line_merged_column_label
                else
                    style.merged_column_label
                end
            end

        elseif action == :row_number
            cell          = _current_cell(action, ps, table_data)
            cell_width    = row_number_column_width
            decoration    = style.row_number
            rendered_cell = _text__render_cell(cell, buf, renderer)

        elseif action == :data
            cell_width    = printed_data_column_widths[jr]
            rendered_cell = if line_breaks
                tokens_jr = tokens[jr]

                if current_row_line <= length(tokens_jr)
                    string(tokens_jr[current_row_line])
                else
                    ""
                end
            else
                table_str[ir, jr]
            end

            # Check if we must apply highlighters.
            if !isempty(highlighters)
                orig_data = _get_data(table_data.data)

                for h in highlighters
                    if h.f(orig_data, ps.i, ps.j)
                        decoration = h.fd(h, orig_data, ps.i, ps.j)::Crayon
                        break
                    end
                end
            end

        elseif action == :summary_row_cell
            cell_width    = printed_data_column_widths[jr]
            decoration    = style.summary_row_cell
            rendered_cell = summary_rows[ir, jr]

        elseif action == :row_group_label
            alignment     = _current_cell_alignment(action, ps, table_data)
            cell          = _current_cell(action, ps, table_data)
            cell_width    = printed_table_width - 4
            decoration    = style.row_group_label
            rendered_cell = _text__render_cell(cell, buf, renderer)
        end

        # If we have multiple lines and we are not rendering a data cell, we must only
        # render it at the first line.
        if (current_row_line >= 2) && (action != :data)
            rendered_cell = ""
        end

        # -- Vertical Line After the Cell --------------------------------------------------

        if action ∈ (:row_number_label, :row_number, :summary_row_number)
            tf.vertical_line_after_row_number_column && (vline = true)

        elseif action ∈ (:stubhead_label, :row_label, :summary_row_label)
            tf.vertical_line_after_row_label_column && (vline = true)

        elseif action == :column_label
            if (!merged_cell && (jr == last_printed_column_index)) ||
                (merged_cell && (mc_last_index == last_printed_column_index))
                tf.vertical_line_after_data_columns && (vline = true)
            elseif ps.j ∈ right_vertical_lines_at_data_columns
                vline = true
                tf.suppress_vertical_lines_at_column_labels && (vline_char = " ")
            end

        elseif action ∈ (:column_label, :data, :summary_row_cell)
            if jr == last_printed_column_index
                tf.vertical_line_after_data_columns && (vline = true)
            elseif ps.j ∈ right_vertical_lines_at_data_columns
                vline = true

                if (action == :column_label) && tf.suppress_vertical_lines_at_column_labels
                    vline_char = " "
                end
            end

        elseif action == :row_group_label
            if tf.vertical_line_after_data_columns && !horizontally_limited_by_display
                vline = true
            end
        end

        _text__print_aligned(
            display,
            " " * rendered_cell * " " ,
            cell_width + 2,
            alignment,
            decoration
        )

        vline && _text__print(display, vline_char)
    end

    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    if !tf.new_line_at_end
        output_str = chomp(output_str)
    end

    print(context, output_str)

    return nothing
end
