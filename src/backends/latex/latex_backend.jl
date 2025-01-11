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

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # == Print LaTeX Header ================================================================

    if wrap_table
        _aprintln(buf, "\\begin{table}", il, ns)
        il += 1
    end

    # Create the table header description for the current table.
    desc = _latex__table_header_description(table_data, tf)

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
                print(buf, "\$\\ddots\$ ")

            elseif action == :horizontal_continuation_cell
                print(buf, "\$\\cdots\$ ")

            elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
                print(buf, "\$\\vdots\$ ")

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

                    alignment = cell.alignment

                    rendered_cell = _latex__render_cell(cell.data, buf, renderer)
                    rendered_cell = "\\multicolumn{$cs}{$alignment}{$rendered_cell}"
                else
                    rendered_cell = _latex__render_cell(cell, buf, renderer)
                    alignment = _current_cell_alignment(action, ps, table_data)
                end

                # TODO: Check footnotes.
                if !isempty(rendered_cell)
                    print(buf, rendered_cell)
                    next_action != :end_row && print(buf, " ")
                end
            end

            next_action != :end_row && print(buf, "& ")
        end
    end

    il -= 1
    _aprintln(buf, "\\end{tabular}", il, ns)

    # == Print the Buffer Into the IO ======================================================

    print(context, String(take!(buf_io)))

    return nothing
end
