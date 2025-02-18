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
    table_format::LatexTableFormat = LatexTableFormat()
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

    # Create the table header description for the current table.
    desc = _latex__table_header_description(
        table_data,
        tf,
        right_vertical_lines_at_data_columns
    )

    _aprintln(buf, "\\begin{tabular}{$desc}", il, ns)
    il += 1

    # == Table =============================================================================

    action = :initialize

    first_table_line = true
    first_element_in_row = true

    # This variable stores where a merged column label begins and ends. Hence, we are able
    # to draw a line after them if the user wants.
    merged_column_labels = Tuple{Int, Int}[]

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        # Obtain the next action since some actions depends on it.
        next_action, next_rs, _ = _next(ps, table_data)

        if action == :new_row
            empty!(merged_column_labels)
            first_element_in_row = true

            # If we are in the very first row after the title section, we need to check if
            # the user wants a vertical line before the table.
            if (rs != :table_header) && first_table_line && tf.horizontal_line_at_beginning
                _aprintln(buf, tf.borders.top_line, il, ns)
                first_table_line = false
            end

            # Here, we just need to apply the indentation.
            print(buf, " "^(ns * il))

        elseif action == :end_row
            println(buf, " \\\\")

            # == Handle the Horizontal Lines ===============================================

            hline_str = ""

            # Print the horizontal line after the column labels.
            if (rs == :table_header) && (next_rs != :table_header) && tf.horizontal_line_at_beginning
                hline_str *= tf.borders.header_line
                first_table_line = false

            elseif (rs == :column_labels)

                if ps.row_section == :column_labels

                    if tf.horizontal_line_at_merged_column_labels
                        # The specification in `merged_column_labels` refers to the data
                        # columns. Hence, we need to add the offset regarding the previous
                        # columns if they exist.
                        Δc = table_data.show_row_number_column + _has_row_labels(table_data)
                        for m in merged_column_labels
                            c₀ = Δc + m[1]
                            c₁ = Δc + m[2]
                            hline_str *= "\\cline{$c₀-$c₁}"
                        end
                    end
                else
                    if tf.horizontal_line_after_column_labels
                        hline_str *= tf.borders.header_line
                    end
                end

            # Check if the next line is a row group label and the user request a line before
            # it.
            elseif (next_rs == :row_group_label) && tf.horizontal_line_before_row_group_label
                hline_str *= tf.borders.middle_line

            # Check if we must print an horizontal line after the current data row.
            elseif (rs == :data) && (ps.i ∈ horizontal_lines_at_data_rows)
                hline_str *= tf.borders.middle_line

            elseif (
                    (rs ∈ (:data, :continuation_row)) &&
                    (next_rs ∈ (:summary_row, :table_footer, :end_printing)) &&
                    tf.horizontal_line_after_data_rows
                )
                hline_str *= tf.borders.middle_line

            elseif (rs == :row_group_label) && tf.horizontal_line_after_row_group_label
                hline_str *= tf.borders.header_line

            # Check if the must print the horizontal line at the end of the table.
            elseif (rs == :summary_row) && (next_rs != :summary_row) &&
                tf.horizontal_line_after_summary_rows

                hline_str *= tf.borders.header_line
            end

            # If the next section if the end of the table and we need to draw a horizontal
            # line, we should change it to the bottom line.
            if next_rs ∈ (:table_footer, :end_printing) && !isempty(hline_str)
                hline_str = tf.borders.bottom_line
            end

            !isempty(hline_str) && _aprintln(buf, hline_str, il, ns)

        elseif action == :row_group_label
            cell          = _current_cell(action, ps, table_data)
            alignment     = _current_cell_alignment(action, ps, table_data)
            rendered_cell = _latex__render_cell(cell, buf, renderer)
            cs            = _number_of_printed_columns(table_data)

            # Check for vertical lines.
            vline_before = tf.vertical_line_at_beginning
            vline_after  = if _is_horizontally_cropped(table_data)
                tf.vertical_line_after_continuation_column
            else
                tf.vertical_line_after_data_columns
            end

            border₀ = vline_before ? "|" : ""
            border₁ = vline_after ? "|" : ""

            print(buf, "\\multicolumn{$cs}{$border₀$alignment$border₁}{$rendered_cell}")

        else
            # Check for footnotes.
            footnotes    = _current_cell_footnotes(table_data, action, ps.i, ps.j)
            footnote_str = ""

            if !isnothing(footnotes) && !isempty(footnotes)
                footnote_str = "\$^{"
                for i in eachindex(footnotes)
                    f = footnotes[i]
                    if i != last(eachindex(footnotes))
                        footnote_str *= "$f,"
                    else
                        footnote_str *= "$f}\$"
                    end
                end
            end

            rendered_cell = nothing

            if action == :diagonal_continuation_cell
                rendered_cell = "\$\\ddots\$"

            elseif action == :horizontal_continuation_cell
                rendered_cell = "\$\\cdots\$"

            elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
                rendered_cell = "\$\\vdots\$"

            else
                cell = _current_cell(action, ps, table_data)

                cell === _IGNORE_CELL && continue

                # First, we handle merged cells.
                if (action ∈ (:title, :subtitle))
                    alignment = _latex__alignment_to_str(
                        action == :title ?
                            table_data.title_alignment :
                            table_data.subtitle_alignment
                    )

                    cs = _number_of_printed_columns(table_data)

                    rendered_cell = _latex__render_cell(cell, buf, renderer)

                    rendered_cell = _latex__add_environments(
                        rendered_cell,
                        action == :title ? style.title : style.subtitle
                    )

                    rendered_cell = rendered_cell * footnote_str
                    rendered_cell = "\\multicolumn{$cs}{$alignment}{$rendered_cell}"

                elseif (action == :column_label) && (cell isa MergeCells)
                    # Check if we have enough data columns to merge the cell.
                    num_data_columns = _number_of_printed_data_columns(table_data)

                    cs = if (ps.j + cell.column_span - 1) > num_data_columns
                        num_data_columns - ps.j + 1
                    else
                        cell.column_span
                    end

                    push!(merged_column_labels, (ps.j, ps.j + cs - 1))

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
                    envs = ps.i == 1 ? style.first_line_column_label : style.column_label
                    rendered_cell = _latex__add_environments(rendered_cell, envs)
                    rendered_cell = rendered_cell * footnote_str

                    # Merge the cells.
                    rendered_cell = "\\multicolumn{$cs}{$alignment}{$rendered_cell}"

                # Check if we must merge the cell to render the footnotes or source
                # notes.
                elseif (action == :footnote)
                    alignment     = _latex__alignment_to_str(table_data.footnote_alignment)
                    cs            = _number_of_printed_columns(table_data)
                    rendered_cell = "\$^{$(ps.i)}\$" * _latex__render_cell(cell, buf, renderer)
                    rendered_cell = _latex__add_environments(rendered_cell, style.footnote)
                    rendered_cell = rendered_cell * footnote_str
                    rendered_cell = "\\multicolumn{$cs}{$alignment}{$rendered_cell}"

                elseif (action == :source_notes)
                    alignment     = _latex__alignment_to_str(table_data.footnote_alignment)
                    cs            = _number_of_printed_columns(table_data)
                    rendered_cell = _latex__render_cell(cell, buf, renderer)
                    rendered_cell = _latex__add_environments(rendered_cell, style.source_note)
                    rendered_cell = rendered_cell * footnote_str
                    rendered_cell = "\\multicolumn{$cs}{$alignment}{$rendered_cell}"

                else
                    rendered_cell = _latex__render_cell(cell, buf, renderer)
                    alignment = _current_cell_alignment(action, ps, table_data)

                    # Apply the style to the cell.
                    envs = nothing

                    # Get the environment of the cell, if any.
                    if action == :row_number_label
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
                    rendered_cell = rendered_cell * footnote_str

                    # Check if we need to override the alignment.
                    if (
                        action == :data &&
                        alignment != _data_column_alignment(table_data, ps.j)
                    )
                        vline_before = (ps.j - 1) ∈ right_vertical_lines_at_data_columns
                        vline_after  = ps.j ∈ right_vertical_lines_at_data_columns

                        border₀ = vline_before ? "|" : ""
                        border₁ = vline_after ? "|" : ""

                        rendered_cell = "\\multicolumn{1}{$border₀$alignment$border₁}{$rendered_cell}"
                    end
                end

                # If `rendered_cell` is `nothing`, we did not processed the cell. Hence, we
                # should just skip.
                isnothing(rendered_cell) && continue

                if first_element_in_row
                    first_element_in_row = false
                else
                    print(buf, " & ")
                end

                print(buf, rendered_cell)
            end
        end
    end

    il -= 1
    _aprintln(buf, "\\end{tabular}", il, ns)

    # == Print the Buffer Into the IO ======================================================

    print(context, String(take!(buf_io)))

    return nothing
end
