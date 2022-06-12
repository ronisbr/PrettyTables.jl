# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Print function of the html backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the text backend.
function _pt_html(
    io::IO,
    pinfo::PrintInfo;
    tf::HTMLTableFormat = tf_html_default,
    allow_html_in_cells::Bool = false,
    highlighters::Union{HTMLHighlighter, Tuple} = (),
    linebreaks::Bool = false,
    minify::Bool = false,
    sortkeys::Bool = false,
    show_omitted_cell_summary::Bool = false,
    standalone::Bool = false,
    vcrop_mode::Symbol = :bottom
)
    # Unpack fields of `pinfo`.
    ptable               = pinfo.ptable
    cell_first_line_only = pinfo.cell_first_line_only
    compact_printing     = pinfo.compact_printing
    formatters           = pinfo.formatters
    limit_printing       = pinfo.limit_printing
    renderer             = pinfo.renderer
    title                = pinfo.title
    title_alignment      = pinfo.title_alignment

    num_hidden_rows_at_end = _get_num_of_hidden_rows(ptable)
    num_hidden_columns_at_end = _get_num_of_hidden_columns(ptable)

    hidden_rows_at_end = num_hidden_rows_at_end > 0
    hidden_columns_at_end = num_hidden_columns_at_end > 0

    # Unpack fields of `tf`.
    css         = tf.css
    table_width = tf.table_width

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    buf_io = IOBuffer()
    buf    = IOContext(buf_io)

    # Get the number of lines and columns.
    num_rows, num_columns = _size(ptable)

    # Get the number of header rows.
    num_header_rows, ~ = _header_size(ptable)

    # Make sure that `highlighters` is always a Tuple.
    if !(highlighters isa Tuple)
        highlighters = (highlighters,)
    end

    # Variables to store information about indentation
    # ==========================================================================

    il = 0 # ......................................... Current indentation level
    ns = 2 # ........................ Number of spaces in each indentation level

    # Print HTML header
    # ==========================================================================

    if standalone
        _aprintln(
            buf,
            """
            <!DOCTYPE html>
            <html>
            <meta charset=\"UTF-8\">
            <style>""",
            il,
            ns,
            minify
        )
        il += 1

        if !isempty(table_width)
            _aprintln(
                buf,
                """
                table {
                    width: $table_width;
                }
                """,
                il,
                ns,
                minify
            )
        end

        _aprintln(buf, css, il, ns, minify)
        il -= 1

        _aprintln(
            buf,
            """
            </style>
            <body>""",
            il,
            ns,
            minify
        )
    end

    # Check if the user wants the omitted cell summary.
    if show_omitted_cell_summary
        str = ""

        if num_hidden_columns_at_end > 1
            str *= string(num_hidden_columns_at_end) * " columns"
        elseif num_hidden_columns_at_end == 1
            str *= string(num_hidden_columns_at_end) * " column"
        end

        if !isempty(str) && hidden_rows_at_end
            str *= " and "
        end

        if num_hidden_rows_at_end > 1
            str *= string(num_hidden_rows_at_end) * " rows"
        elseif num_hidden_rows_at_end == 1
            str *= string(num_hidden_rows_at_end) * " row"
        end

        if !isempty(str)
            str *= " omitted"
        end

        style = Dict{String,String}(
            "position" => "absolute",
            "top"      => "0",
            "right"    => "0"
        )
        _aprintln(
            buf,
            _styled_html("div", "<p>" * str * "</p>", style),
            il,
            ns,
            minify
        )
    end

    _aprintln(buf, "<table>", il, ns, minify)
    il += 1

    # Table title and omitted cell summary
    # ==========================================================================

    if length(title) > 0
        style = Dict{String,String}("text-align" => _html_alignment[title_alignment])
        _aprintln(buf, _styled_html("caption", title, style), il, ns, minify)
    end

    # If there is no column or row to be printed, then just exit.
    if (num_rows == 0) || (num_columns == 0)
        @goto print_to_output
    end

    # Vertical cropping mode
    # ==========================================================================

    if hidden_rows_at_end
        continuation_line_id = vcrop_mode == :middle ?
            _header_size(ptable)[1] + div(num_rows, 2, RoundUp) - 1 :
            num_rows
    else
        continuation_line_id = 0
    end

    # Print the table
    # ==========================================================================

    # Offset in the rows used when we have middle cropping. In this case, after
    # drawing the continuation line, we use this variable to render the bottom
    # part of the table.
    Δr = 0

    @inbounds for i in 1:num_rows
        # Get the identification of the current row.
        row_id = _get_row_id(ptable, i + Δr)

        # HTML tag for the row.
        html_row_tag = ""

        # Class of the row.
        row_class = ""

        if (num_header_rows == 0) && (i == 1)
            _aprintln(buf, "<tbody>", il, ns, minify)
            il += 1
        end

        if _is_header_row(row_id)
            html_row_tag = "th"

            # If we have a header row and `i = 1`, then we need to start the
            # header. We can do this because the header is always at the
            # beginning of the table.
            if i == 1
                _aprintln(buf, "<thead>", il, ns, minify)
                il += 1
            end

            # Check the row class.
            if (i == 1) && (num_header_rows == 1)
                row_class = "header headerLastRow"
            elseif (i == 1)
                row_class = "header"
            elseif (i == num_header_rows)
                row_class = "subheader headerLastRow"
            else
                row_class = "subheader"
            end

        else
            html_row_tag = "td"

        end

        if isempty(row_class)
            _aprintln(buf, "<tr>", il, ns, minify)
        else
            _aprintln(buf, "<tr class = \"" * row_class * "\">", il, ns, minify)
        end
        il += 1

        @inbounds for j in 1:num_columns
            # Get the identification of the current column.
            column_id = _get_column_id(ptable, j)

            # Get the alignment for the current cell.
            cell_alignment = _get_cell_alignment(ptable, i + Δr, j)

            # Get the cell data.
            cell_data = _get_element(ptable, i + Δr, j)

            # If we do not annotate the type here, then we get type instability
            # due to `_parse_cell_text`.
            cell_str::String = ""

            # The class of the cell.
            cell_class = ""

            # Style of the cell.
            style = _html_text_alignment_dict(cell_alignment)

            if column_id == :row_number
                cell_class = "rowNumber"
            elseif column_id == :row_name
                cell_class = "rowName"
            end

            if _is_header_row(row_id)
                cell_str = _parse_cell_html(
                    cell_data,
                    allow_html_in_cells = allow_html_in_cells,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    renderer = Val(:print)
                )

                _aprintln(
                    buf,
                    _styled_html(
                        html_row_tag,
                        cell_str,
                        style;
                        class = cell_class
                    ),
                    il,
                    ns,
                    minify
                )

                # Check if we need to draw the continuation character.
                if (j == num_columns) && hidden_columns_at_end
                    _aprintln(
                        buf,
                        _styled_html(
                            html_row_tag,
                            "⋯",
                            style;
                            class = cell_class
                        ),
                        il,
                        ns,
                        minify
                    )
                end

            else
                is_original_data = column_id == :__ORIGINAL_DATA__

                if is_original_data
                    ir = _get_data_row_index(ptable, i)
                    jr = _get_data_column_index(ptable, j)

                    for f in formatters.x
                        cell_data = f(cell_data, ir, jr)
                    end
                end

                cell_str = _parse_cell_html(
                    cell_data;
                    allow_html_in_cells = allow_html_in_cells,
                    cell_first_line_only = cell_first_line_only,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    linebreaks = linebreaks,
                    renderer = renderer
                )

                if is_original_data
                    # Apply highlighters.
                    for h in highlighters
                        if h.f(_getdata(ptable), ir, jr)
                            merge!(style, Dict(h.fd(h, _getdata(ptable), ir, jr)))
                            break
                        end
                    end
                end

                _aprintln(
                    buf,
                    _styled_html(html_row_tag, cell_str, style; class = cell_class),
                    il,
                    ns,
                    minify
                )

                # Check if we need to draw the continuation character.
                if (j == num_columns) && hidden_columns_at_end
                    _aprintln(
                        buf,
                        _styled_html(
                            html_row_tag,
                            "⋯",
                            style;
                            class = cell_class
                        ),
                        il,
                        ns,
                        minify
                    )
                end
            end
        end

        il -= 1
        _aprintln(buf, "</tr>", il, ns, minify)

        if i == num_header_rows
            il -= 1
            _aprintln(buf, "</thead>", il, ns, minify)
            _aprintln(buf, "<tbody>", il, ns, minify)
            il += 1
        end

        # If we have hidden rows, we need to print an additional row with the
        # continuation characters.
        if i == continuation_line_id
            _aprintln(buf, "<tr>", il, ns, minify)
            il += 1

            for j in 1:num_columns
                _aprintln(buf, _styled_html(html_row_tag, "⋮", style), il, ns, minify)

                if (j == num_columns) && hidden_columns_at_end
                    _aprintln(buf, _styled_html(html_row_tag, "⋱", style), il, ns, minify)
                end
            end

            il -= 1
            _aprintln(buf, "</tr>", il, ns, minify)

            # Apply the offset in case we are using middle cropping.
            Δr = _total_size(ptable)[1] - num_rows
        end
    end

    il -= 1
    _aprintln(buf, "</tbody>", il, ns, minify)

    @label print_to_output

    # Print HTML footer
    # ==========================================================================

    il -= 1
    _aprintln(buf, "</table>", il, ns, minify)
    if standalone
        _aprintln(
            buf,
            """
            </body>
            </html>""",
            il,
            ns,
            minify
        )
    end

    # Print the buffer into the io.
    # ==========================================================================

    # If we are printing to `stdout`, then wrap the output in a `HTML` object.
    if (io == stdout) || ( (io isa IOContext) && (io.io == stdout) )
        display("text/html", HTML(String(take!(buf_io))))
    else
        print(io, String(take!(buf_io)))
    end

    return nothing
end
