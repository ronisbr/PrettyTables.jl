## Description #############################################################################
#
# Function to render the table in the text back end.
#
############################################################################################

function _text__render_table(
    table_data::TableData,
    context::IOContext,
    renderer::Union{Val{:print}, Val{:show}}
)
    num_column_label_lines   = length(table_data.column_labels)
    num_printed_data_columns = _number_of_printed_data_columns(table_data)
    num_printed_data_rows    = _number_of_printed_data_rows(table_data)
    num_summary_rows         = _has_summary_rows(table_data) ? length(table_data.summary_rows) : 0
    num_footnotes            = _has_footnotes(table_data) ? length(table_data.footnotes) : 0

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

    ps = PrintingTableState()

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action ∉ (:column_label, :data, :summary_row_cell, :row_label, :footnote) && continue

        cell = _current_cell(action, ps, table_data)

        rendered_cell = if cell !== _IGNORE_CELL
            _text__render_cell(cell, context, renderer)
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

    return row_labels, column_labels, table_str, summary_rows, footnotes
end