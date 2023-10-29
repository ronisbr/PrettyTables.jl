# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Print function of the markdown backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the markdown backend.
function _print_table_with_markdown_back_end(
    pinfo::PrintInfo;
    allow_markdown_in_cells::Bool = false,
    highlighters::Union{MarkdownHighlighter, Tuple} = (),
    ## Decorations #########################################################################
    header_decoration::MarkdownDecoration = MarkdownDecoration(bold = true),
    row_label_decoration::MarkdownDecoration = MarkdownDecoration(),
    row_number_decoration::MarkdownDecoration = MarkdownDecoration(bold = true),
    subheader_decoration::MarkdownDecoration = MarkdownDecoration(code = true),
    sortkeys::Bool = false,
)
    # Unpack fields of `pinfo`.
    ptable               = pinfo.ptable
    cell_first_line_only = pinfo.cell_first_line_only
    compact_printing     = pinfo.compact_printing
    formatters           = pinfo.formatters
    io                   = pinfo.io
    limit_printing       = pinfo.limit_printing
    renderer             = pinfo.renderer
    title                = pinfo.title
    title_alignment      = pinfo.title_alignment

    hidden_rows_at_end = _get_num_of_hidden_rows(ptable) > 0
    hidden_columns_at_end = _get_num_of_hidden_columns(ptable) > 0

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    buf_io = IOBuffer()
    buf    = IOContext(buf_io)

    # Get the number of lines and columns in the table.
    num_rows, num_columns = _size(ptable)

    # If there is no columns and no row to be printed, just exit.
    if _data_size(ptable) == (0, 0)
        @goto print_to_output
    end

    # Make sure that `highlighters` is always a Ref{Any}(Tuple).
    if !(highlighters isa Tuple)
        highlighters = Ref{Any}((highlighters,))
    else
        highlighters = Ref{Any}(highlighters)
    end

    # Create the String Matrix with the Rendered Cells
    # ======================================================================================

    # In markdown back end, we must convert all the matrix to text before printing. This
    # procedure is necessary to obtain the column width so that we can align the table
    # lines.
    table_str = Matrix{String}(undef, num_rows, num_columns)

    # Vector that must contain the width of each column.
    actual_columns_width = ones(Int, num_columns)

    _markdown_fill_string_matrix!(
        io,
        table_str,
        ptable,
        actual_columns_width,
        formatters,
        highlighters,
        allow_markdown_in_cells,
        compact_printing,
        limit_printing,
        renderer,
        header_decoration,
        row_label_decoration,
        row_number_decoration,
        subheader_decoration,
    )

    # Print the Table
    # ======================================================================================

    @inbounds for i in 1:num_rows
        # Get the identification of the current row.
        row_id = _get_row_id(ptable, i)

        # We should skip if we find sub-headers because they were merged into the headers.
        row_id == :__SUBHEADER__ && continue

        print(buf, "|")

        @inbounds for j in 1:num_columns
            # Get the identification of the current column.
            column_id = _get_column_id(ptable, j)

            # Get the column alignment.
            column_alignment = _get_column_alignment(ptable, j)

            print(buf, " ")
            print(buf, rpad(table_str[i, j], actual_columns_width[j] + 1))
            print(buf, "|")
        end

        # Check if we have hidden columns.
        if hidden_columns_at_end
            print(buf, " ⋯ |")
        end

        println(buf)

        if row_id == :__HEADER__
            _markdown_print_header_line(
                buf,
                ptable,
                actual_columns_width,
                hidden_columns_at_end
            )
        end
    end

    # Print the continuation row if we have hidden rows.
    if hidden_rows_at_end
        print(buf, "|")

        @inbounds for j in 1:num_columns
            print(buf, " ")
            print(buf, rpad("⋮", actual_columns_width[j] + 1))
            print(buf, "|")
        end

        if hidden_columns_at_end
            print(buf, " ⋱ |")
        end

        println(buf)
    end

    # Print the Buffer Into The IO.
    # ======================================================================================

    @label print_to_output

    print(io, String(take!(buf_io)))

    return nothing
end
