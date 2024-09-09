## Description #############################################################################
#
# Text back end for PrettyTables.jl.
#
############################################################################################

function _text__circular_reference(io::IOContext)
    print(io, "#= circular reference =#")
    return nothing
end

function _text__print(
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

    # Limit the number of rendered cells given the display size if the user wants.
    if fit_table_in_display_horizontally
        table_data.maximum_number_of_columns = div(display.size[2], 5, RoundUp)
    end

    if fit_table_in_display_vertically
        table_data.maximum_number_of_rows = max(
            display.size[1] -
            length(table_data.column_labels) -
            (_has_summary_rows(table_data) ? length(table_data.summary_rows) : 0) -
            4,
            1
        )
    end

    # Obtain general information about the table.
    num_column_label_lines   = length(table_data.column_labels)
    num_printed_data_columns = _number_of_printed_data_columns(table_data)
    num_printed_data_rows    = _number_of_printed_data_rows(table_data)
    num_summary_rows         = _has_summary_rows(table_data) ? length(table_data.summary_rows) : 0

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
            _text__render_cell(cell, buf, renderer)
        else
            ""
        end

        if (action == :column_label)
            column_labels[ir, jr] = rendered_cell

        elseif (action == :data)
            table_str[ir, jr] = rendered_cell

        elseif !isnothing(summary_rows) && (action == :summary_row_cell)
            summary_rows[ir, jr] = rendered_cell

        elseif !isnothing(row_labels) && (action == :row_label)
            row_labels[ir] = rendered_cell
        end
    end

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

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action == :end_printing && break

        # Special treatment for table header and footer.
        if rs == :table_header
            continue

        elseif rs == :table_footer

            continue
        end

        if action == :new_row
            _text__print(display, tf.column)

        elseif action == :diagonal_continuation_cell
            _text__print(display, " ⋱ $(tf.column)")

        elseif action == :horizontal_continuation_cell
            _text__print(display, " ⋯ $(tf.column)")

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            alignment = _current_cell_alignment(action, ps, table_data)

            cell_width = if action == :row_number_vertical_continuation_cell
                row_number_column_width
            elseif action == :row_label_vertical_continuation_cell
                row_label_column_width
            else
                printed_data_column_widths[jr]
            end

            _text__print(display, " ")
            _text__aligned_print(display, "⋮", cell_width, alignment)
            _text__print(display, " $(tf.column)")

        elseif action == :end_row
            _text__flush_line(display)

            if (rs == :column_labels)
                header_printed = true

            elseif ps.row_section == :table_footer
                # We reach this point only once because the Markdown table ends here. Thus,
                # we need to check if we must print the omitted cell summary.
                if pspec.show_omitted_cell_summary
                    ocs = _omitted_cell_summary(table_data, pspec)

                    # if !isempty(ocs)
                    #     println(buf)
                    #     println(buf, _markdown__apply_decoration(
                    #         tf.omitted_cell_summary_decoration,
                    #         ocs
                    #     ))
                    # end
                end
            end

        elseif action == :row_group_label

        else
            alignment     = _current_cell_alignment(action, ps, table_data)
            cell_width    = 1
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

            elseif action == :summary_row_cell
                cell_width    = printed_data_column_widths[jr]
                rendered_cell = summary_rows[ir, jr]

            end

            _text__print(display, " ")
            _text__aligned_print(display, rendered_cell, cell_width, alignment)
            _text__print(display, " $(tf.column)")
        end
    end

    # == Print the Buffer Into the IO ======================================================

    print(context, String(take!(buf_io)))

    return nothing
end
