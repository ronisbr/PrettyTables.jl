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
    line_breaks::Bool = false,
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # Obtain general infomration about the table.
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
        rendered_cell = _markdown__render_cell(
            cell,
            buf,
            renderer;
            allow_markdown_in_cells,
            line_breaks
        )

        if (action == :column_label)
            column_labels[ir, jr] = rendered_cell

        elseif (action == :data)
            # TODO: Add footnotes.
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
            _has_summary_rows(table_data) ? maximum(textwidth, table_data.summary_row_labels) : 0
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

    ir = jr = 0

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action, rs, ps
        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        rs == :table_header && continue
        rs == :table_footer && continue
        action == :end_printing && break

        if action == :new_row
            print(buf, "|")

        elseif action == :diagonal_continuation_cell
            print(buf, " ⋱ |")

        elseif action == :horizontal_continuation_cell
            print(buf, " ⋯ |")

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            cell_width = if action == :row_number_vertical_continuation_cell
                row_number_column_width
            elseif action == :row_label_vertical_continuation_cell
                row_label_column_width
            else
                printed_data_column_widths[jr]
            end

            print(buf, " ")
            print(buf, lpad("⋮", cell_width))
            print(buf, " |")

        elseif action == :end_row
            println(buf)

            if (rs == :column_labels) && (ps.row_section == :data)
                _markdown__print_header_separator(
                    buf,
                    table_data,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths
                )
            end
        else
            cell_width = 10
            rendered_cell = "UNSUP"

            print(buf, " ")

            if action == :row_number_label
                rendered_cell = table_data.row_number_column_label
                cell_width = row_number_column_width

            elseif action == :stubhead_label
                rendered_cell = table_data.stubhead_label
                cell_width = row_label_column_width

            elseif action == :row_label
                rendered_cell = row_labels[ir]
                cell_width = row_label_column_width

            elseif action == :summary_row_number
                cell_width = row_number_column_width
                rendered_cell = ""

            elseif action == :summary_row_label
                cell_width = row_label_column_width
                rendered_cell = table_data.summary_row_labels[ir]

            elseif action == :column_label
                rendered_cell = column_labels[ir, jr]
                cell_width = printed_data_column_widths[jr]

            elseif action == :row_number
                rendered_cell = _current_cell(action, ps, table_data)
                cell_width = row_number_column_width

            elseif action == :data
                rendered_cell = table_str[ir, jr]
                cell_width = printed_data_column_widths[jr]

            elseif action == :summary_row_cell
                rendered_cell = summary_rows[ir, jr]
                cell_width = printed_data_column_widths[jr]

            end

            print(buf, lpad(rendered_cell, cell_width))
            print(buf, " |")
        end
    end

    # == Print the Buffer Into the IO ======================================================

    print(context, String(take!(buf_io)))

    return nothing
end
