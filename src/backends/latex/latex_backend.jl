## Description #############################################################################
#
# LaTeX back end for PrettyTables.jl.
#
############################################################################################

function _latex__circular_reference(io::IOContext)
    print(io, "#= circular reference =#")
    return nothing
end

function _latex__print(
    pspec::PrintingSpec;
    highlighters::Union{Nothing, Vector{LatexHighlighter}} = nothing,
    style::LatexTableStyle = LatexTableStyle(),
    table_format::LatexTableFormat = LatexTableFormat(),
    wrap_table::Bool = false
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)
    tf         = table_format

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

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

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # == Print LaTeX Header ================================================================

    if wrap_table
        _aprintln(buf, "\\begin{table}", il, ns)
        il += 1
    end

    # Create the table header description for the current table.
    desc = _latex__table_header_description(
        table_data,
        tf,
        right_vertical_lines_at_data_columns
    )

    _aprintln(buf, "\\begin{tabular}{$desc}", il, ns)
    il += 1

    # Print the top line, if required.
    tf.horizontal_line_at_beginning && _aprintln(buf, tf.borders.top_line, il, ns)

    # == Table =============================================================================

    action = :initialize

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        # Obtain the next action since some actions depends on it.
        next_action, next_rs, _ = _next(ps, table_data)

        if action == :new_row
            # Here, we just need to apply the indentation.
            print(buf, " "^(ns * il))

        elseif action == :end_row
            print(buf, " \\\\")

            # == Handle the Horizontal Lines ===============================================

            # Print the horizontal line after the column labels.
            if (rs == :column_labels) && (ps.row_section != :column_labels) &&
                tf.horizontal_line_after_column_labels

                print(buf, tf.borders.header_line)

            # Check if the next line is a row group label and the user request a line before
            # it.
            elseif (next_rs == :row_group_label) && tf.horizontal_line_before_row_group_label
                print(buf, tf.borders.middle_line)

            # Check if we must print an horizontal line after the current data row.
            elseif (rs == :data) && (ps.i ∈ horizontal_lines_at_data_rows)
                print(buf, tf.borders.middle_line)

            elseif (
                    (rs ∈ (:data, :continuation_row)) &&
                    (next_rs ∈ (:summary_row, :table_footer, :end_printing)) &&
                    tf.horizontal_line_after_data_rows
                )

                bottom = next_rs ∈ (:table_footer, :end_printing)

                print(buf, bottom ? tf.borders.bottom_line : tf.borders.middle_line)

            elseif (rs == :row_group_label) && tf.horizontal_line_after_row_group_label
                print(buf, tf.borders.header_line)

            # Check if the must print the horizontal line at the end of the table.
            elseif (rs == :summary_row) && (next_rs != :summary_row) &&
                tf.horizontal_line_after_summary_rows

                print(buf, tf.borders.header_line)
            end

            println(buf)
        elseif action == :row_group_label
            cell          = _current_cell(action, ps, table_data)

            alignment     = _current_cell_alignment(action, ps, table_data)
            rendered_cell = _latex__render_cell(cell, buf, renderer)
            cs            = _number_of_printed_columns(table_data)

            print(buf, "\\multicolumn{$cs}{$alignment}{$rendered_cell}")

        else
            if action == :diagonal_continuation_cell
                print(buf, " & \$\\ddots\$")

            elseif action == :horizontal_continuation_cell
                print(buf, " & \$\\cdots\$")

            elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
                print(buf, " & \$\\vdots\$")

            else
                cell = _current_cell(action, ps, table_data)

                cell === _IGNORE_CELL && continue

                # If we are in a column label, check if we must merge the cell.
                if (action == :column_label) && (cell isa MergeCells)
                    # Check if we have enough data columns to merge the cell.
                    num_data_columns = _number_of_printed_data_columns(table_data)

                    cs = if (ps.j + cell.column_span - 1) > num_data_columns
                        num_data_columns - ps.j + 1
                    else
                        cell.column_span
                    end

                    alignment = _latex__alignment_to_str(cell.alignment)

                    # We must check if we have a vertical line after the cell merge.
                    vline = if (
                        (ps.j + cs - 1 ∈ right_vertical_lines_at_data_columns) ||
                        (
                            (ps.j + cs - 1 == num_data_columns) &&
                            tf.vertical_line_after_data_columns
                        )
                    )
                        true
                    else
                        false
                    end

                    if vline
                        alignment *= "|"
                    end

                    rendered_cell = _latex__render_cell(cell.data, buf, renderer)

                    # Apply the style to the text.
                    envs = ps.j == 1 ? style.first_line_column_label : style.column_label
                    rendered_cell = _latex__add_environments(rendered_cell, envs)

                    # Merge the cells.
                    rendered_cell = "\\multicolumn{$cs}{$alignment}{$rendered_cell}"

                else
                    rendered_cell = _latex__render_cell(cell, buf, renderer)
                    alignment = _current_cell_alignment(action, ps, table_data)

                    # Check for footnotes.
                    footnotes = _current_cell_footnotes(table_data, action, ps.i, ps.j)

                    if !isnothing(footnotes) && !isempty(footnotes)
                        rendered_cell *= "\$^{"
                        for i in eachindex(footnotes)
                            f = footnotes[i]
                            if i != last(eachindex(footnotes))
                                rendered_cell *= "$f,"
                            else
                                rendered_cell *= "$f}\$"
                            end
                        end
                    end

                    # Apply the style to the cell.
                    envs = nothing

                    # Get the environment of the cell, if any.
                    if action == :title
                        envs = style.title

                    elseif action == :subtitle
                        envs = style.subtitle

                    elseif action == :row_number_label
                        envs = style.row_number_label

                    elseif action == :row_number
                        envs = style.row_number

                    elseif action == :summary_row_number
                        envs = style.row_number

                    elseif action == :stubhead_label
                        envs = style.stubhead_label

                    elseif action == :row_group_label
                        envs = style.row_group_label

                    elseif action == :row_label
                        envs = style.row_label

                    elseif action == :summary_row_label
                        envs = style.summary_row_label

                    elseif action == :column_label
                        envs = ps.i == 1 ? style.first_line_column_label : style.column_label

                    elseif action == :summary_row_cell
                        envs = style.summary_row_cell

                    elseif action == :footnote
                        envs = style.footnote

                    elseif action == :source_notes
                        envs = style.source_note

                    else
                        # Here we have a data cell. Hence, let's check if we have a
                        # highlighter to apply.
                        if !isnothing(highlighters)
                            for h in highlighters
                                if h.f(table_data.data, ps.i, ps.j)
                                    envs = h.fd(h, table_data.data, ps.i, ps.j)
                                end
                            end
                        end
                    end

                    rendered_cell = _latex__add_environments(rendered_cell, envs)

                    # Check if we must merge the cell to render the footnotes or source
                    # notes.
                    if (action == :footnote)
                        alignment = _latex__alignment_to_str(table_data.footnote_alignment)
                        cs = _number_of_printed_columns(table_data)
                        id = "\$^{$(ps.i)}\$"
                        rendered_cell = "\\multicolumn{$cs}{$alignment}{$id: $rendered_cell}"
                    end
                end

                first_column = ps.j == 1 || (action == :footnote)

                # TODO: Check footnotes.
                if !isempty(rendered_cell)
                    !first_column && print(buf, " & ")
                    print(buf, rendered_cell)
                end
            end
        end
    end

    il -= 1
    _aprintln(buf, "\\end{tabular}", il, ns)

    # == Print the Buffer Into the IO ======================================================

    print(context, String(take!(buf_io)))

    return nothing
end
