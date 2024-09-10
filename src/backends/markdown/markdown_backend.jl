## Description #############################################################################
#
# Markdown back end for PrettyTables.jl.
#
############################################################################################

function _markdown__circular_reference(io::IOContext)
    print(io, "\\#= circular reference =\\#")
    return nothing
end

function _markdown__print(
    pspec::PrintingSpec;
    tf::MarkdownTableFormat = MarkdownTableFormat(),
    allow_markdown_in_cells::Bool = false,
    highlighters::Vector{MarkdownHighlighter} = MarkdownHighlighter[],
    line_breaks::Bool = false,
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)

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
    column_labels = Matrix{String}(undef, num_column_label_lines, num_printed_data_columns)

    row_labels = _has_row_labels(table_data) ?
        Vector{String}(undef, num_printed_data_rows) :
        nothing

    table_str = Matrix{String}(undef, num_printed_data_rows, num_printed_data_columns)

    summary_rows = _has_summary_rows(table_data) ?
        Matrix{String}(undef, num_summary_rows, num_printed_data_columns) :
        nothing

    action = :initialize

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

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

        if (action == :column_label)
            # Apply the decoration to the column label.
            rendered_cell = _markdown__apply_decoration(
                ir == 1 ? tf.first_column_label_decoration : tf.column_label_decoration,
                rendered_cell
            )

            column_labels[ir, jr] = rendered_cell

        elseif (action == :data)
            # Check if we must apply highlighters.
            if !isempty(highlighters)
                orig_data = _get_data(table_data.data)

                for h in highlighters
                    if h.f(orig_data, ps.i, ps.j)
                        d = h.fd(h, orig_data, ps.i, ps.j)
                        rendered_cell = _markdown__apply_decoration(d, rendered_cell)
                        break
                    end
                end
            end

            table_str[ir, jr] = rendered_cell

        elseif !isnothing(summary_rows) && (action == :summary_row_cell)
            rendered_cell = _markdown__apply_decoration(
                tf.summary_row_cell_decoration,
                rendered_cell
            )
            summary_rows[ir, jr] = rendered_cell

        elseif !isnothing(row_labels) && (action == :row_label)
            rendered_cell = _markdown__apply_decoration(
                tf.row_label_decoration,
                rendered_cell
            )
            row_labels[ir] = rendered_cell
        end
    end

    # We now must unify the column labels into one cell because Markdown does not support
    # headers with multiple lines.
    for j in last(axes(column_labels))
        for i in first(axes(column_labels))
            i == first(first(axes(column_labels))) && continue
            column_labels[1, j] *= "<br>" * column_labels[i, j]
        end
    end

    # Finally, we must apply the decoration to the other fields in the header.
    decorated_row_number_column_label = _markdown__apply_decoration(
        tf.row_number_label_decoration,
        table_data.row_number_column_label
    )

    decorated_stubhead_label = _markdown__apply_decoration(
        tf.stubhead_label_decoration,
        table_data.stubhead_label
    )

    # == Compute the Column Width ==========================================================

    row_number_column_width    = 0
    row_label_column_width     = 0
    printed_data_column_widths = zeros(Int, num_printed_data_columns)

    if table_data.show_row_number_column
        m = (_is_vertically_cropped(table_data) && (table_data.vertical_crop_mode == :bottom)) ?
            table_data.maximum_number_of_rows :
            table_data.num_rows

        row_number_column_width = max(
            textwidth(decorated_row_number_column_label),
            floor(Int, log10(m) + 1)
        )
    end

    if _has_row_labels(table_data)
        row_label_column_width = max(
            textwidth(decorated_stubhead_label),

            num_printed_data_rows > 0 ? maximum(textwidth, row_labels) : 0,

            _has_summary_rows(table_data) ? 
                maximum(
                    textwidth,
                    table_data.summary_row_labels
                ) + _markdown__decoration_textwidth(tf.summary_row_label_decoration) :
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

    # Markdown does not support merging rows. Hence, if we have a row group, we must add the
    # information in the first column. Thus, we need to possibly increase this cell
    # accordingly.
    if _has_row_groups(table_data)
        m = maximum(x -> textwidth(last(x)), table_data.row_group_labels) +
            _markdown__decoration_textwidth(tf.row_group_label_decoration)

        if table_data.show_row_number_column
            row_number_column_width = max(row_number_column_width, m)

        elseif _has_row_labels(table_data)
            row_label_column_width = max(row_label_column_width, m)

        else
            printed_data_column_widths[1] = max(printed_data_column_widths[1], m)
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
                println(buf, _markdown__apply_decoration(
                    tf.footnote_decoration, rendered_cell
                ))
                continue

            elseif action == :source_notes
                rendered_cell = _markdown__escape_str(
                    _current_cell(action, ps, table_data),
                    line_breaks,
                    true
                )

                println(buf)
                println(buf, _markdown__apply_decoration(
                    tf.source_note_decoration,
                    rendered_cell
                ))
                continue
            end

            continue
        end

        if action == :new_row
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
            _markdown__print_aligned(buf, "⋮", cell_width, alignment)
            print(buf, " |")

        elseif action == :end_row
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

            elseif tf.line_before_summary_rows &&
                (rs != :summary_row) &&
                (ps.row_section == :summary_row)
                _markdown__print_separation_line(
                    buf,
                    table_data,
                    tf.horizontal_line_char,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths
                )
            elseif ps.row_section == :table_footer
                # We reach this point only once because the Markdown table ends here. Thus,
                # we need to check if we must print the omitted cell summary.
                if pspec.show_omitted_cell_summary
                    ocs = _omitted_cell_summary(table_data, pspec)

                    if !isempty(ocs)
                        println(buf)
                        println(buf, _markdown__apply_decoration(
                            tf.omitted_cell_summary_decoration,
                            ocs
                        ))
                    end
                end
            end

        elseif action == :row_group_label
            row_group_label = _markdown__apply_decoration(
                tf.row_group_label_decoration,
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
                rendered_cell = _markdown__apply_decoration(
                    tf.summary_row_label_decoration,
                    table_data.summary_row_labels[ir]
                )

            elseif action == :column_label
                cell_width = printed_data_column_widths[jr]

                # If need to check if we are in a cell that should be merged. Since Markdown
                # does not support such an operation, we only fill the field with `-`.
                rendered_cell = _current_cell(action, ps, table_data) === _IGNORE_CELL ?
                    string(tf.horizontal_line_char)^cell_width :
                    column_labels[ir, jr]

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

            _markdown__print_aligned(buf, rendered_cell, cell_width, alignment)
            print(buf, " |")
        end
    end

    # == Print the Buffer Into the IO ======================================================

    print(context, String(take!(buf_io)))

    return nothing
end
