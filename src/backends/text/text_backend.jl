## Description #############################################################################
#
using Markdown: horizontalrule
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
    display_size::NTuple{2, Int} = displaysize(pspec.context),
    fit_table_in_display_horizontally::Bool = true,
    fit_table_in_display_vertically::Bool = true,
    highlighters::Vector{TextHighlighter} = TextHighlighter[],
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
            tf.right_vertical_lines_at_data_columns == :all ?
                (1:table_data.num_columns) :
                (1:0)
    else
        right_vertical_lines_at_data_columns =
            tf.right_vertical_lines_at_data_columns::Vector{Int}
    end

    # Process the horizontal lines at data rows.
    if tf.horizontal_lines_at_data_rows isa Symbol
        horizontal_lines_at_data_rows = tf.horizontal_lines_at_data_rows == :all ?
            (1:table_data.num_rows) :
            (1:0)
    else
        horizontal_lines_at_data_rows = tf.horizontal_lines_at_data_rows::Vector{Int}
    end

    # Limit the number of rendered cells given the display size if the user wants.
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

    if fit_table_in_display_vertically && (display_size[1] > 0)
        mr, suppress_vline_before_continuation_row, suppress_vline_after_continuation_row =
            _text__design_vertical_cropping(
                table_data,
                tf,
                horizontal_lines_at_data_rows,
                pspec.show_omitted_cell_summary,
                display.size[1]
            )

        if table_data.maximum_number_of_rows >= 0
            table_data.maximum_number_of_rows = min(
                table_data.maximum_number_of_rows,
                mr
            )
        else
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
    )

    num_printed_data_rows, num_printed_data_columns = size(table_str)

    # == Compute the Column Width ==========================================================

    row_number_column_width    = 0
    row_label_column_width     = 0
    printed_data_column_widths = zeros(Int, num_printed_data_columns)

    if table_data.show_row_number_column
        m = (_is_vertically_cropped(table_data) && (table_data.vertical_crop_mode == :bottom)) ?
            table_data.maximum_number_of_rows :
            table_data.num_rows

        row_number_column_width = max(
            textwidth(table_data.row_number_column_label),
            floor(Int, log10(m) + 1)
        )
    end

    if _has_row_labels(table_data)
        row_label_column_width = max(
            textwidth(table_data.stubhead_label),

            num_printed_data_rows > 0 ? maximum(textwidth, row_labels) : 0,

            _has_summary_rows(table_data) ?
                maximum(
                    textwidth,
                    table_data.summary_row_labels
                ) :
                0
        )
    end

    @views for j in last(axes(table_str))
        m = maximum(textwidth, column_labels[:, j])

        if num_printed_data_rows > 0
            m = max(maximum(textwidth, table_str[:, j]), m)

            if _has_summary_rows(table_data)
                m = max(maximum(textwidth, summary_rows[:, j]), m)
            end
        end

        printed_data_column_widths[j] = m
    end

    # == Omitted Columns ===================================================================

    # In text back end, the printed column can be limited either by the user specification
    # or by the display limit. Now, we have access to the width of all candidate columns to
    # be printed. Hence, we can update the number of printed columns accordingly. Notice
    # that we also must analyze if the table continuation column is required since in text
    # back end we also have the continuation caused by the display end-of-line.

    # Compute the required width to display the table using the user specification.
    total_table_width = _text__total_table_width(
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

    if fit_table_in_display_horizontally &&
        (display.size[2] > 0) &&
        _is_horizontally_cropped(table_data)

        # Here we have three possibilities:
        #
        #   1. We cannot show the table continuation column, meaning that the table is
        #      horizontally limited by the display.
        #   2. We can partially show the continuation column, meaning that the table is
        #      horizontally limited by the display but there is a continuation column.
        #   3. We can show the continuation column, meaning that the table is horizontally
        #      cropped by the user specification.

        num_remaining_columns = display_size[2] - total_table_width

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
    last_printed_column_index = table_data.maximum_number_of_columns

    # Finally, we can compute the printed table width.
    printed_table_width = total_table_width

    if _is_horizontally_cropped(table_data)
        printed_table_width += 3 + tf.vertical_line_after_continuation_column
    end

    if horizontally_limited_by_display
        printed_table_width = display_size[2]
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

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action == :end_printing && break

        # Special treatment for table header and footer.
        if rs == :table_header
            if action ∈ (:title, :subtitle)
                alignment     = _current_cell_alignment(action, ps, table_data)
                cell          = _current_cell(action, ps, table_data)
                decoration    = action == :title ? tf.title_decoration : tf.subtitle_decoration
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

        elseif (rs == :table_footer)
            if action == :footnote
                alignment = _current_cell_alignment(action, ps, table_data)
                decoration = tf.footnote_decoration
                _text__print_aligned(
                    display,
                    footnotes[ps.i],
                    printed_table_width,
                    alignment,
                    decoration
                )
                _text__flush_line(display)

            elseif action == :source_notes
                alignment = _current_cell_alignment(action, ps, table_data)
                cell = _current_cell(action, ps, table_data)
                rendered_cell = _text__render_cell(cell, buf, renderer)
                decoration = tf.source_note_decoration

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

        if action == :new_row

            # If this is the very first row, we must check if a horizontal line must be
            # printed.
            if tf.horizontal_line_at_beginning && !top_line_printed
                _text__print_horizontal_line(
                    display,
                    tf,
                    table_data,
                    right_vertical_lines_at_data_columns,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths,
                    true
                )

                _text__flush_line(display, false)

                top_line_printed = true
            end

            # Check if we need to draw a horizontal line before the summary rows.
            if (rs == :summary_row) && (ps.i == 1) && tf.horizontal_line_before_summary_rows
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
            end

            tf.vertical_line_at_beginning && _text__print(display, tf.column)

        elseif action == :diagonal_continuation_cell
            _text__print(display, " ⋱ ")
            tf.vertical_line_after_continuation_column && _text__print(display, tf.column)

        elseif action == :horizontal_continuation_cell
            _text__print(display, " ⋯ ")
            tf.vertical_line_after_continuation_column && _text__print(display, tf.column)

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            alignment = _current_cell_alignment(action, ps, table_data)

            if action == :row_number_vertical_continuation_cell
                cell_width = row_number_column_width
                vline      = tf.vertical_line_after_row_number_column
            elseif action == :row_label_vertical_continuation_cell
                cell_width = row_label_column_width
                vline      = tf.vertical_line_after_row_label_column
            else
                cell_width = printed_data_column_widths[jr]
                vline = false

                if (jr == last_printed_column_index)
                    tf.vertical_line_after_data_columns && (vline = true)
                elseif ps.j ∈ right_vertical_lines_at_data_columns
                    vline = true
                end
            end

            _text__print(display, " ")
            _text__print_aligned(display, "⋮", cell_width, alignment)
            _text__print(display, " ")
            vline && _text__print(display, tf.column)

        elseif action == :end_row
            (rs == :data) && (num_data_lines += 1)

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

            # == Handle the Table Horizontal Line ==========================================

            # Print the horizontal line after the column labels.
            if (rs == :column_labels) &&
                (ps.row_section != :column_labels) &&
                tf.horizontal_line_after_column_labels

                # We must handle that case where there is no data rows. In this case, the
                # next section after the column labels will be the table footer.
                bottom = ps.row_section == :table_footer

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

            # Check if we must print an horizontal line after the current data row.
            elseif (rs == :data) && (ps.i ∈ horizontal_lines_at_data_rows)

                # We should only print this line if the next state is not the continuation
                # row or if we do not need to suppress the line before the continuation row.
                if (ps.row_section != :continuation_row) || !suppress_vline_before_continuation_row
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
                end

            # Check if we must print an horizontal line after the continuation row.
            elseif (rs == :continuation_row) &&
                (ps.i ∈ horizontal_lines_at_data_rows) &&
                !suppress_vline_after_continuation_row

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

            # Check if the must print the horizontal line at the end of the table.
            elseif ps.row_section == :table_footer
                # If the next section is the table footer, we must draw the last table line.
                if tf.horizontal_line_at_end
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
                    tf.omitted_cell_summary_decoration
                )

                _text__flush_line(display)
            end

        elseif action == :row_group_label

        else
            # Here, we treat all normal cells in the table.
            alignment     = _current_cell_alignment(action, ps, table_data)

            # == Width, Decoration, and Rendered String ====================================

            cell_width    = 1
            decoration    = _TEXT__DEFAULT
            rendered_cell = ""

            if action == :row_number_label
                cell          = _current_cell(action, ps, table_data)
                cell_width    = row_number_column_width
                rendered_cell = _text__render_cell(cell, buf, renderer)

            elseif action == :stubhead_label
                cell          = _current_cell(action, ps, table_data)
                cell_width    = row_label_column_width
                rendered_cell = _text__render_cell(cell, buf, renderer)

            elseif action == :row_label
                cell_width    = row_label_column_width
                rendered_cell = row_labels[ir]

            elseif action == :summary_row_number
                cell_width    = row_number_column_width
                rendered_cell = ""

            elseif action == :summary_row_label
                cell_width    = row_label_column_width
                rendered_cell = table_data.summary_row_labels[ir]

            elseif action == :column_label
                cell_width = printed_data_column_widths[jr]

                decoration = ir == 1 ?
                    tf.first_column_label_decoration :
                    tf.column_label_decoration

                # If need to check if we are in a cell that should be merged. Since Markdown
                # does not support such an operation, we only fill the field with `-`.
                rendered_cell = column_labels[ir, jr]

            elseif action == :row_number
                cell          = _current_cell(action, ps, table_data)
                cell_width    = row_number_column_width
                rendered_cell = _text__render_cell(cell, buf, renderer)

            elseif action == :data
                cell_width    = printed_data_column_widths[jr]
                rendered_cell = table_str[ir, jr]

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
                rendered_cell = summary_rows[ir, jr]

            end

            # == Vertical Line After the Cell ==============================================

            vline = false

            if action ∈ (:row_number_label, :summary_row_label, :row_number, :summary_row_number)
                tf.vertical_line_after_row_number_column && (vline = true)

            elseif action ∈ (:stubhead_label, :row_label, :summary_row_label)
                tf.vertical_line_after_row_label_column && (vline = true)

            elseif action ∈ (:column_label, :data, :summary_row_cell)
                if (jr == last_printed_column_index)
                    tf.vertical_line_after_data_columns && (vline = true)
                elseif ps.j ∈ right_vertical_lines_at_data_columns
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
            vline && _text__print(display, tf.column)
        end
    end

    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    if !tf.new_line_at_end
        output_str = chomp(output_str)
    end

    print(context, output_str)

    return nothing
end
