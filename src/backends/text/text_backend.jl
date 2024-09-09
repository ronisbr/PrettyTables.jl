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
    display_size::NTuple{2, Int} = displaysize(pspec.context),
    fit_table_in_display_horizontally::Bool = true,
    fit_table_in_display_vertically::Bool = true,
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

    # Create the structure that holds the display information.
    display = Display(
        display_size,
        1,
        0,
        get(context, :color, false),
        tf.continuation_char,
        buf_io,
        IOBuffer()
    )

    # Process the vertical lines at data columns.
    if tf.vertical_lines_at_data_columns isa Symbol
        vertical_lines_at_data_columns = tf.vertical_lines_at_data_columns == :all ?
            (1:table_data.num_columns) :
            Int[]
    else
        vertical_lines_at_data_columns = tf.vertical_lines_at_data_columns
    end

    # Process the horizontal lines at data rows.
    if tf.horizontal_lines_at_data_rows isa Symbol
        horizontal_lines_at_data_rows = tf.horizontal_lines_at_data_rows == :all ?
            (1:table_data.num_rows) :
            Int[]
    else
        horizontal_lines_at_data_rows = tf.horizontal_lines_at_data_rows
    end

    # Limit the number of rendered cells given the display size if the user wants.
    if fit_table_in_display_horizontally
        table_data.maximum_number_of_columns = div(display.size[2], 5, RoundUp)
    end

    if fit_table_in_display_vertically
        table_data.maximum_number_of_rows, suppress_vline_before_continuation_row =
            _text__design_vertical_cropping(
                table_data,
                tf,
                horizontal_lines_at_data_rows,
                pspec.show_omitted_cell_summary,
                display.size[1]
            )
    end

    # Obtain general information about the table.
    num_column_label_lines   = length(table_data.column_labels)
    num_printed_data_columns = _number_of_printed_data_columns(table_data)
    num_printed_data_rows    = _number_of_printed_data_rows(table_data)
    num_summary_rows         = _has_summary_rows(table_data) ? length(table_data.summary_rows) : 0
    num_footnotes            = _has_footnotes(table_data) ? length(table_data.footnotes) : 0

    # == Render the Table ==================================================================

    # For the text backend, we need to render the entire table before printing to take into
    # account the required column width.

    # Let's allocate all the sections.
    column_labels = Matrix{String}(undef, num_column_label_lines, num_printed_data_columns)

    row_labels = _has_row_labels(table_data) ?
        Vector{String}(undef, num_printed_data_rows) :
        nothing

    table_str = Matrix{String}(undef, num_printed_data_rows, num_printed_data_columns)

    summary_rows = _has_summary_rows(table_data) ?
        Matrix{String}(undef, num_summary_rows, num_printed_data_columns) :
        nothing

    footnotes = _has_footnotes(table_data) ? Vector{String}(undef, num_footnotes) : nothing

    action = :initialize

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action ∉ (:column_label, :data, :summary_row_cell, :row_label, :footnote) && continue

        cell = _current_cell(action, ps, table_data)

        rendered_cell = if cell !== _IGNORE_CELL
            _text__render_cell(cell, buf, renderer)
        else
            ""
        end

        # Check for footnotes.
        cell_footnotes = _current_cell_footnotes(table_data, action, ps.i, ps.j)

        if !isnothing(cell_footnotes) && !isempty(cell_footnotes)
            for i in eachindex(cell_footnotes)
                f = cell_footnotes[i]
                rendered_cell *= _text__render_footnote_superscript(f)
                (i != last(eachindex(cell_footnotes))) && (rendered_cell *= "ʼ")
            end
        end

        if (action == :column_label)
            column_labels[ir, jr] = rendered_cell

        elseif (action == :data)
            table_str[ir, jr] = rendered_cell

        elseif !isnothing(summary_rows) && (action == :summary_row_cell)
            summary_rows[ir, jr] = rendered_cell

        elseif !isnothing(row_labels) && (action == :row_label)
            row_labels[ir] = rendered_cell

        elseif !isnothing(footnotes) && (action == :footnote)
            id = ps.i
            footnotes[id] = _text__render_footnote_superscript(id) * ": " * rendered_cell
        end
    end

    # == Compute the Column Width ==========================================================

    row_number_column_width    = 0
    row_label_column_width     = 0
    printed_data_column_widths = zeros(Int, num_printed_data_columns)
    footnote_column_width      = 0

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
            maximum(textwidth, row_labels),
            _has_summary_rows(table_data) ? maximum(
                textwidth,
                table_data.summary_row_labels
            ) : 0
        )
    end

    @views for j in last(axes(table_str))
        m = maximum(textwidth, column_labels[:, j])
        m = max(maximum(textwidth, table_str[:, j]), m)

        if _has_summary_rows(table_data)
            m = max(maximum(textwidth, summary_rows[:, j]), m)
        end

        printed_data_column_widths[j] = m
    end

    # == Print the Table ===================================================================

    ps     = PrintingTableState()
    action = :initialize

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    if tf.horizontal_line_at_beginning
        _text__print_horizontal_line(
            display,
            tf,
            table_data,
            vertical_lines_at_data_columns,
            row_number_column_width,
            row_label_column_width,
            printed_data_column_widths,
            true
        )

        _text__flush_line(display, false)
    end

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action == :end_printing && break

        # Special treatment for table header and footer.
        if rs == :table_header
            continue

        elseif rs == :table_footer
            if action == :footnote
                _text__aligned_print(display, footnotes[ps.i], footnote_column_width, :l)
                _text__flush_line(display)
            end

            continue
        end

        if action == :new_row

            # Check if we need to draw a horizontal line before the summary rows.
            if (rs == :summary_row) && (ps.i == 1) && tf.horizontal_line_before_summary_rows
                _text__print_horizontal_line(
                    display,
                    tf,
                    table_data,
                    vertical_lines_at_data_columns,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths
                )

                _text__flush_line(display, false)
            end

            tf.vertical_line_at_beginning && _text__print(display, tf.column)

        elseif action == :diagonal_continuation_cell
            _text__print(display, " ⋱ $(tf.column)")

        elseif action == :horizontal_continuation_cell
            _text__print(display, " ⋯ $(tf.column)")

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
                vline =
                    (jr ∈ vertical_lines_at_data_columns) ||
                    ((jr == num_printed_data_columns) && tf.vertical_line_at_end)
            end

            _text__print(display, " ")
            _text__aligned_print(display, "⋮", cell_width, alignment)
            _text__print(display, " ")
            vline && _text__print(display, "$(tf.column)")

        elseif action == :end_row
            _text__flush_line(display)

            if (rs == :column_labels) &&
                (ps.row_section != :column_labels) &&
                tf.horizontal_line_after_column_labels

                _text__print_horizontal_line(
                    display,
                    tf,
                    table_data,
                    vertical_lines_at_data_columns,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths
                )

                _text__flush_line(display, false)

            elseif (rs == :data) && (ps.i ∈ horizontal_lines_at_data_rows)

                if (ps.row_section != :continuation_row) || !suppress_vline_before_continuation_row
                    _text__print_horizontal_line(
                        display,
                        tf,
                        table_data,
                        vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths
                    )

                    _text__flush_line(display, false)
                end

            elseif ps.row_section == :table_footer
                # If the next section is the table footer, we must draw the last table line.
                if tf.horizontal_line_at_end
                    _text__print_horizontal_line(
                        display,
                        tf,
                        table_data,
                        vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                        false,
                        true
                    )

                    _text__flush_line(display, false)
                end

                # We also must show the omitted cell summary if the user requested it.
                if pspec.show_omitted_cell_summary
                    ocs = _omitted_cell_summary(table_data, pspec)

                    if !isempty(ocs)
                        _text__print(display, align_string(ocs, display_size[2], :r))
                        _text__flush_line(display)
                    end
                end
            end

        elseif action == :row_group_label

        elseif action == :footnote
            _text__aligned_print(display, footnotes[ps.i], footnote_column_width, :l)
            tf.vertical_line_at_end && _text__print(display, tf.column)

        else
            alignment     = _current_cell_alignment(action, ps, table_data)
            cell_width    = 1
            decoration    = _TEXT__RESET
            rendered_cell = ""
            vline         = false

            if action == :row_number_label
                cell          = _current_cell(action, ps, table_data)
                cell_width    = row_number_column_width
                rendered_cell = _text__render_cell(cell, buf, renderer)

                tf.vertical_line_after_row_number_column && (vline = true)

            elseif action == :stubhead_label
                cell          = _current_cell(action, ps, table_data)
                cell_width    = row_label_column_width
                rendered_cell = _text__render_cell(cell, buf, renderer)

                tf.vertical_line_after_row_label_column && (vline = true)

            elseif action == :row_label
                cell_width    = row_label_column_width
                rendered_cell = row_labels[ir]

                tf.vertical_line_after_row_label_column && (vline = true)

            elseif action == :summary_row_number
                cell_width    = row_number_column_width
                rendered_cell = ""

                tf.vertical_line_after_row_number_column && (vline = true)

            elseif action == :summary_row_label
                cell_width    = row_label_column_width
                rendered_cell = table_data.summary_row_labels[ir]

                tf.vertical_line_after_row_label_column && (vline = true)

            elseif action == :column_label
                cell_width = printed_data_column_widths[jr]

                decoration = ir == 1 ?
                    tf.first_column_label_decoration :
                    tf.column_label_decoration

                # If need to check if we are in a cell that should be merged. Since Markdown
                # does not support such an operation, we only fill the field with `-`.
                rendered_cell = column_labels[ir, jr]

                if jr ∈ vertical_lines_at_data_columns
                    vline = true
                end

                if (jr == num_printed_data_columns) && tf.vertical_line_at_end
                    vline = true
                end

            elseif action == :row_number
                cell          = _current_cell(action, ps, table_data)
                cell_width    = row_number_column_width
                rendered_cell = _text__render_cell(cell, buf, renderer)

                tf.vertical_line_after_row_number_column && (vline = true)

            elseif action == :data
                cell_width    = printed_data_column_widths[jr]
                rendered_cell = table_str[ir, jr]

                if jr ∈ vertical_lines_at_data_columns
                    vline = true
                end

                if (jr == num_printed_data_columns) && tf.vertical_line_at_end
                    vline = true
                end

            elseif action == :summary_row_cell
                cell_width    = printed_data_column_widths[jr]
                rendered_cell = summary_rows[ir, jr]

                if jr ∈ vertical_lines_at_data_columns
                    vline = true
                end

                if (jr == num_printed_data_columns) && tf.vertical_line_at_end
                    vline = true
                end
            end

            _text__aligned_print(
                display,
                " " * rendered_cell * " " ,
                cell_width,
                alignment,
                decoration
            )
            vline && _text__print(display, tf.column)
        end
    end

    # == Print the Buffer Into the IO ======================================================

    print(context, String(take!(buf_io)))

    return nothing
end
