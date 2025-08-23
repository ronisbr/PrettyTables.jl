## Description #############################################################################
#
# Markdown back end for PrettyTables.jl.
#
############################################################################################

function _markdown__print(
    pspec::PrintingSpec;
    allow_markdown_in_cells::Bool = false,
    highlighters::Vector{MarkdownHighlighter} = MarkdownHighlighter[],
    line_breaks::Bool = false,
    style::MarkdownTableStyle = MarkdownTableStyle(),
    table_format::MarkdownTableFormat = MarkdownTableFormat(),
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)
    tf         = table_format

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # Obtain general information about the table.
    num_column_label_lines   = length(table_data.column_labels)
    num_printed_data_columns = _number_of_printed_data_columns(table_data)
    num_printed_data_rows    = _number_of_printed_data_rows(table_data)
    num_summary_rows         = _has_summary_rows(table_data) ? length(table_data.summary_rows) : 0

    # == Render the Table ==================================================================

    # For Markdown, we need to render the entire table before printing to take into account
    # the required column width.

    # Let's allocate all the sections.
    column_labels = if table_data.show_column_labels
        Matrix{String}(undef, num_column_label_lines, num_printed_data_columns)
    else
        nothing
    end

    row_labels = if _has_row_labels(table_data)
        Vector{String}(undef, num_printed_data_rows)
    else
        nothing
    end

    table_str = Matrix{String}(undef, num_printed_data_rows, num_printed_data_columns)

    summary_rows = if _has_summary_rows(table_data)
        Matrix{String}(undef, num_summary_rows, num_printed_data_columns)
    else
        nothing
    end

    action = :initialize

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        # Here, we only want actions related to table cells.
        action ∉ (:column_label, :data, :summary_row_cell, :row_label) && continue

        cell = _current_cell(action, ps, table_data)

        rendered_cell = if cell !== _IGNORE_CELL
            _markdown__render_cell(
                cell,
                buf,
                renderer;
                allow_markdown_in_cells,
                line_breaks
            )
        else
            ""
        end

        # Check for footnotes.
        footnotes = _current_cell_footnotes(table_data, action, ps.i, ps.j)

        if !isnothing(footnotes) && !isempty(footnotes)
            for i in eachindex(footnotes)
                f = footnotes[i]
                rendered_cell *= "[^$f]"
            end
        end

        if table_data.show_column_labels && (action == :column_label)
            # Apply the style to the column label.
            rendered_cell = _markdown__apply_style(
                ir == 1 ? style.first_column_label : style.column_label,
                rendered_cell
            )

            column_labels[ir, jr] = rendered_cell

        elseif action == :data
            # Check if we must apply highlighters.
            if !isempty(highlighters)
                orig_data = _get_data(table_data.data)

                for h in highlighters
                    if h.f(orig_data, ps.i, ps.j)
                        d = h.fd(h, orig_data, ps.i, ps.j)
                        rendered_cell = _markdown__apply_style(d, rendered_cell)
                        break
                    end
                end
            end

            table_str[ir, jr] = rendered_cell

        elseif !isnothing(summary_rows) && (action == :summary_row_cell)
            rendered_cell = _markdown__apply_style(
                style.summary_row_cell,
                rendered_cell
            )

            summary_rows[ir, jr] = rendered_cell

        elseif !isnothing(row_labels) && (action == :row_label)
            rendered_cell = _markdown__apply_style(
                style.row_label,
                rendered_cell
            )

            row_labels[ir] = rendered_cell
        end
    end

    # We now must unify the column labels into one cell because Markdown does not support
    # headers with multiple lines.
    if !isnothing(column_labels)
        for j in last(axes(column_labels))
            for i in first(axes(column_labels))
                i == first(first(axes(column_labels))) && continue
                column_labels[1, j] *= "<br>" * column_labels[i, j]
            end
        end
    end

    # Finally, we must apply the style to the other fields in the header.
    decorated_row_number_column_label = _markdown__apply_style(
        style.row_number_label,
        table_data.row_number_column_label
    )

    decorated_stubhead_label = _markdown__apply_style(
        style.stubhead_label,
        table_data.stubhead_label
    )

    # == Compute the Column Width ==========================================================

    row_number_column_width    = 1
    row_label_column_width     = 1
    printed_data_column_widths = ones(Int, num_printed_data_columns)

    # We we are printing in compact mode, we do not need to compute the column widths.
    if !tf.compact_table
        if table_data.show_row_number_column
            m = if (_is_vertically_cropped(table_data) && (table_data.vertical_crop_mode == :bottom))
                table_data.maximum_number_of_rows
            else
                table_data.num_rows
            end

            row_number_column_width = max(
                textwidth(decorated_row_number_column_label),
                floor(Int, log10(m) + 1)
            )
        end

        if _has_row_labels(table_data)
            row_label_column_width = max(
                textwidth(decorated_stubhead_label),

                num_printed_data_rows > 0 ? maximum(textwidth, row_labels) : 0,

                if _has_summary_rows(table_data)
                    maximum(textwidth, table_data.summary_row_labels) +
                    _markdown__style_textwidth(style.summary_row_label)
                else
                    0
                end
            )
        end

        @views for j in last(axes(table_str))
            m = if !isnothing(column_labels)
                maximum(textwidth, column_labels[:, j])
            else
                0
            end

            if num_printed_data_rows > 0
                m = max(maximum(textwidth, table_str[:, j]), m)

                if _has_summary_rows(table_data)
                    m = max(maximum(textwidth, summary_rows[:, j]), m)
                end
            end

            printed_data_column_widths[j] = m
        end

        # Markdown does not support merging rows. Hence, if we have a row group label, we must
        # add the information in the first column. Thus, we need to possibly increase this cell
        # accordingly.
        if _has_row_group_labels(table_data)
            m = maximum(x -> textwidth(last(x)), table_data.row_group_labels) +
                _markdown__style_textwidth(style.row_group_label)

            if table_data.show_row_number_column
                row_number_column_width = max(row_number_column_width, m)

            elseif _has_row_labels(table_data)
                row_label_column_width = max(row_label_column_width, m)

            else
                printed_data_column_widths[1] = max(printed_data_column_widths[1], m)
            end
        end
    end

    # == Print the Table ===================================================================

    ps     = PrintingTableState()
    action = :initialize

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    # Variable to store if the header was already printed.
    header_printed = false

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action == :end_printing && break

        # We must skip if we are at the column label section but not in the first line.
        (rs == :column_labels && header_printed) && continue

        # Special treatment for table header and footer.
        if rs == :table_header
            l = if action == :title
                max(tf.title_heading_level, 1)
            elseif action == :subtitle
                max(tf.subtitle_heading_level, 1)
            else
                0
            end

            l <= 0 && continue

            print(buf, "#"^l)
            print(buf, " ")
            println(buf, _current_cell(action, ps, table_data))
            println(buf)
            continue

        elseif rs == :table_footer
            if action == :footnote
                rendered_cell = _markdown__escape_str(
                    _current_cell(action, ps, table_data),
                    line_breaks,
                    true
                )

                ps.i == 1 && println(buf)
                print(buf, "[^$(ps.i)]: ")
                println(buf, _markdown__apply_style(style.footnote, rendered_cell))

            elseif action == :source_notes
                rendered_cell = _markdown__escape_str(
                    _current_cell(action, ps, table_data),
                    line_breaks,
                    true
                )

                println(buf)
                println(buf, _markdown__apply_style(style.source_note, rendered_cell))
            end

            continue
        end

        if action == :new_row
            # In case we do not have column labels, we must at least print the header line.
            if !header_printed && (rs == :data)
                _markdown__print_header_separator(
                    buf,
                    table_data,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths
                )
                header_printed = true
            end

            print(buf, "|")

        elseif action == :diagonal_continuation_cell
            print(buf, " ⋱ |")

        elseif action == :horizontal_continuation_cell
            print(buf, " ⋯ |")

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            alignment = _current_cell_alignment(action, ps, table_data)

            cell_width = if action == :row_number_vertical_continuation_cell
                row_number_column_width
            elseif action == :row_label_vertical_continuation_cell
                row_label_column_width
            else
                printed_data_column_widths[jr]
            end

            print(buf, " ")

            if !tf.compact_table
                _markdown__print_aligned(buf, "⋮", cell_width, alignment)
            else
                print(buf, "⋮")
            end

            print(buf, " |")

        elseif action == :end_row
            # Obtain the next row section since some actions depends on it.
            _, next_rs, _ = _next(ps, table_data)

            println(buf)

            if (rs == :column_labels)
                header_printed = true

                # We only reach this point at the first line.
                _markdown__print_header_separator(
                    buf,
                    table_data,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths
                )

            elseif tf.line_before_summary_rows && (rs != :summary_row) &&
                (next_rs == :summary_row)

                _markdown__print_separation_line(
                    buf,
                    table_data,
                    tf.horizontal_line_char,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths
                )

            elseif next_rs ∈ (:table_footer, :end_printing)
                # We reach this point only once because the Markdown table ends here. Thus,
                # we need to check if we must print the omitted cell summary.
                if pspec.show_omitted_cell_summary
                    ocs = _omitted_cell_summary(table_data, pspec)

                    if !isempty(ocs)
                        println(buf)
                        println(buf, _markdown__apply_style(
                            style.omitted_cell_summary,
                            ocs
                        ))
                    end
                end
            end

        elseif action == :row_group_label
            row_group_label = _markdown__apply_style(
                style.row_group_label,
                _current_cell(action, ps, table_data)
            )

            # In this case, we write the row group to the first cell and fill the entire
            # table with empty data.
            _markdown__print_row_group_line(
                buf,
                row_group_label,
                table_data,
                tf.horizontal_line_char,
                row_number_column_width,
                row_label_column_width,
                printed_data_column_widths
            )

        else
            alignment     = _current_cell_alignment(action, ps, table_data)
            cell_width    = 1
            rendered_cell = ""

            print(buf, " ")

            if action == :row_number_label
                cell_width    = row_number_column_width
                rendered_cell = decorated_row_number_column_label

            elseif action == :stubhead_label
                cell_width    = row_label_column_width
                rendered_cell = decorated_stubhead_label

            elseif action == :row_label
                cell_width    = row_label_column_width
                rendered_cell = row_labels[ir]

            elseif action == :summary_row_number
                cell_width    = row_number_column_width
                rendered_cell = ""

            elseif action == :summary_row_label
                cell_width    = row_label_column_width
                rendered_cell = _markdown__apply_style(
                    style.summary_row_label,
                    table_data.summary_row_labels[ir]
                )

            elseif action == :column_label
                cell_width = printed_data_column_widths[jr]

                # If need to check if we are in a cell that should be merged. Since Markdown
                # does not support such an operation, we only fill the field with `-`.
                rendered_cell = if _current_cell(action, ps, table_data) === _IGNORE_CELL
                    string(tf.horizontal_line_char)^cell_width
                else
                    column_labels[ir, jr]
                end

            elseif action == :row_number
                cell          = _current_cell(action, ps, table_data)
                cell_width    = row_number_column_width
                rendered_cell = _markdown__render_cell(cell, buf, renderer)

            elseif action == :data
                cell_width    = printed_data_column_widths[jr]
                rendered_cell = table_str[ir, jr]

            elseif action == :summary_row_cell
                cell_width    = printed_data_column_widths[jr]
                rendered_cell = summary_rows[ir, jr]

            end

            if !tf.compact_table
                _markdown__print_aligned(buf, rendered_cell, cell_width, alignment)
            else
                print(buf, rendered_cell)
            end

            print(buf, " |")
        end
    end

    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    if !pspec.new_line_at_end
        output_str = chomp(output_str)
    end

    print(context, output_str)

    return nothing
end
