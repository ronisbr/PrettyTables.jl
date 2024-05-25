## Description #############################################################################
#
# Fill the string matrix that will be printed in the markdown back end.
#
############################################################################################

function _markdown_fill_string_matrix!(
    @nospecialize(io::IOContext),
    table_str::Matrix{String},
    ptable::ProcessedTable,
    actual_columns_width::Vector{Int},
    @nospecialize(formatters::Ref{Any}),
    @nospecialize(highlighters::Ref{Any}),
    # Configuration options.
    allow_markdown_in_cells::Bool,
    compact_printing::Bool,
    limit_printing::Bool,
    linebreaks::Bool,
    renderer::Union{Val{:print}, Val{:show}},
    # Decorations.
    header_decoration::MarkdownDecoration,
    row_label_decoration::MarkdownDecoration,
    row_number_decoration::MarkdownDecoration,
    subheader_decoration::MarkdownDecoration,
)
    num_rows, num_columns = _size(ptable)
    num_header_rows, ~ = _header_size(ptable)

    @inbounds for j in 1:num_columns
        # Get the identification of the current column.
        column_id = _get_column_id(ptable, j)

        # Get the column index in the original data. Notice that this is ignored if the
        # column is not from the original data.
        jr = _get_data_column_index(ptable, j)

        # Store the largest cell width in this column.
        largest_cell_width = 0

        for i in 1:num_rows
            # We need to force `cell_str` to `String` to avoid type instabilities.
            local cell_str::String

            # Get the identification of the current row.
            row_id = _get_row_id(ptable, i)

            # Get the cell data.
            cell_data = _get_element(ptable, i, j)

            if (row_id == :__HEADER__) || (row_id == :__SUBHEADER__)
                cell_str = _markdown_parse_cell(
                    io,
                    cell_data;
                    allow_markdown_in_cells = allow_markdown_in_cells,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    renderer = Val(:print)
                )

                cell_str = _apply_markdown_decoration(
                    cell_str,
                    row_id == :__HEADER__ ? header_decoration : subheader_decoration
                )

            elseif (column_id == :row_number) || (column_id == :row_label)
                cell_str = _markdown_parse_cell(
                    io,
                    cell_data;
                    allow_markdown_in_cells = allow_markdown_in_cells,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    renderer = Val(:print)
                )

                cell_str = _apply_markdown_decoration(
                    cell_str, 
                    column_id == :row_number ? row_number_decoration : row_label_decoration
                )

            elseif (column_id == :__ORIGINAL_DATA__) && (row_id == :__ORIGINAL_DATA__)
                # Get the row index in the original data.
                ir = _get_data_row_index(ptable, i)

                # Get the original type of the cell, which is used in some special cases in
                # the renderers.
                cell_data_type = typeof(cell_data)

                # Apply the formatters.

                # Notice that `(ir, jr)` are the indices of the printed data. It means that
                # it refers to the ir-th data row and jr-th data column that will be
                # printed. We need to convert those indices to the actual indices in the
                # input table.
                tir, tjr = _convert_axes(ptable.data, ir, jr)

                for f in formatters.x
                    cell_data = f(cell_data, tir, tjr)
                end

                # Render the cell.
                cell_str = _markdown_parse_cell(
                    io,
                    cell_data;
                    allow_markdown_in_cells = allow_markdown_in_cells,
                    cell_data_type = cell_data_type,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    linebreaks = linebreaks,
                    renderer = renderer
                )

                # The highlighting in markdown involves adding text to the cell. Hence, we
                # must apply it here.
                for h in highlighters.x
                    if h.f(_getdata(ptable), tir, tjr)
                        decoration = h.fd(h, _getdata(ptable), tir, tjr)::MarkdownDecoration
                        cell_str = _apply_markdown_decoration(cell_str, decoration)
                        break
                    end
                end

            else
                cell_str = string(cell_data)

            end

            table_str[i, j] = cell_str

            largest_cell_width = max(largest_cell_width, textwidth.(cell_str))
        end

        actual_columns_width[j] = largest_cell_width
    end

    # Since markdown does not support multiple header lines, we need to merge them.
    @inbounds for i in 1:num_rows
        # Get the identification of the current row.
        row_id = _get_row_id(ptable, i)

        row_id == :__HEADER__ && continue
        row_id != :__SUBHEADER__ && break

        for j in 1:num_columns
            isempty(table_str[i ,j]) && continue
            table_str[1, j] *= "<br>$(table_str[i, j])"
        end
    end

    @inbounds for j in 1:num_columns
        actual_columns_width[j] = max(actual_columns_width[j], textwidth(table_str[1, j]))
    end

    return nothing
end
