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
    r_io::Ref{Any},
    pinfo::PrintInfo;
    tf::HTMLTableFormat = tf_html_default,
    allow_html_in_cells::Bool = false,
    highlighters::Union{HTMLHighlighter, Tuple} = (),
    linebreaks::Bool = false,
    minify::Bool = false,
    noheader::Bool = false,
    nosubheader::Bool = false,
    sortkeys::Bool = false,
    standalone::Bool = true
)
    # `r_io` must always be a reference to `IO`. Here, we unpack it. This is
    # done to improve inference and reduce compilation time. Ideally, we need to
    # add the `@nospecialize` annotation to `io`. However, it returns the
    # message that this annotation is not supported with more than 32 arguments.
    io = r_io.x

    # Unpack fields of `pinfo`.
    data                    = pinfo.data
    header                  = pinfo.header
    id_cols                 = pinfo.id_cols
    id_rows                 = pinfo.id_rows
    num_rows                = pinfo.num_rows
    num_cols                = pinfo.num_cols
    num_printed_cols        = pinfo.num_printed_cols
    num_printed_rows        = pinfo.num_printed_rows
    header_num_rows         = pinfo.header_num_rows
    header_num_cols         = pinfo.header_num_cols
    show_row_number         = pinfo.show_row_number
    row_number_column_title = pinfo.row_number_column_title
    show_row_names          = pinfo.show_row_names
    row_names               = pinfo.row_names
    row_name_alignment      = pinfo.row_name_alignment
    row_name_column_title   = pinfo.row_name_column_title
    alignment               = pinfo.alignment
    cell_alignment          = pinfo.cell_alignment
    formatters              = pinfo.formatters
    compact_printing        = pinfo.compact_printing
    title                   = pinfo.title
    title_alignment         = pinfo.title_alignment
    header_alignment        = pinfo.header_alignment
    header_cell_alignment   = pinfo.header_cell_alignment
    cell_first_line_only    = pinfo.cell_first_line_only
    renderer                = pinfo.renderer
    limit_printing          = pinfo.limit_printing

    # Unpack fields of `tf`.
    css         = tf.css
    table_width = tf.table_width

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    buf_io = IOBuffer()
    buf    = IOContext(buf_io)

    if !noheader && (num_cols != header_num_cols)
        error("The header length must be equal to the number of columns.")
    end

    # Additional processing necessary if the user wants to print the header.
    if !noheader
        # If the user do not want to print the sub-header but wants to print the
        # header, then just force the number of rows in header to be 1.
        nosubheader && (header_num_rows = 1)
    end

    # Make sure that `highlighters` is always a Ref{Any}(Tuple).
    if !(highlighters isa Tuple)
        highlighters = Ref{Any}((highlighters,))
    else
        highlighters = Ref{Any}(highlighters)
    end

    # Get the string which is printed when `print` is called in each element of
    # the matrix. Notice that we must create only the matrix with the printed
    # rows and columns.
    header_str = Matrix{String}(undef, header_num_rows, num_printed_cols)
    data_str   = Matrix{String}(undef, num_printed_rows, num_printed_cols)

    @inbounds for i = 1:num_printed_cols
        # Index of the i-th printed column in `data`.
        ic = id_cols[i]

        if !noheader
            for j = 1:header_num_rows
                header_str[j, i] = _parse_cell_html(
                    header[j][ic],
                    allow_html_in_cells = allow_html_in_cells,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    renderer = Val(:print)
                )
            end
        end

        for j = 1:num_printed_rows
            # Index of the j-th printed row in `data`.
            jr = id_rows[j]

            # Apply the formatters.
            data_ij = isassigned(data, jr, ic) ? data[jr, ic] : undef

            for f in formatters.x
                data_ij = f(data_ij, jr, ic)
            end

            data_str[j, i] = _parse_cell_html(
                data_ij;
                allow_html_in_cells = allow_html_in_cells,
                cell_first_line_only = cell_first_line_only,
                compact_printing = compact_printing,
                limit_printing = limit_printing,
                linebreaks = linebreaks,
                renderer = renderer
            )
        end
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

    _aprintln(buf, "<table>", il, ns, minify)
    il += 1

    # Table title
    # ==========================================================================

    if length(title) > 0
        style = Dict{String,String}("text-align" => _html_alignment[title_alignment])
        _aprintln(buf, _styled_html("caption", title, style), il, ns, minify)
    end

    # If there is no column or row to be printed, then just exit.
    if (num_printed_cols == 0) || (num_printed_rows == 0)
        @goto print_to_output
    end

    # Data header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        _aprintln(buf, "<thead>", il, ns, minify)
        il += 1

        @inbounds @views for i = 1:header_num_rows
            if (i == 1) && (header_num_rows == 1)
                _aprintln(
                    buf,
                    "<tr class = \"header headerLastRow\">",
                    il,
                    ns,
                    minify
                )
            elseif i == 1
                _aprintln(buf, "<tr class = \"header\">", il, ns, minify)
            elseif i == header_num_rows
                _aprintln(
                    buf,
                    "<tr class = \"subheader headerLastRow\">",
                    il,
                    ns,
                    minify
                )
            else
                _aprintln(buf, "<tr class = \"subheader\">", il, ns, minify)
            end
            il += 1

            # The text "Row" must appear only on the first line.
            if show_row_number
                if i == 1
                    _aprintln(
                        buf,
                        "<th class = \"rowNumber\">" * row_number_column_title * "</th>",
                        il,
                        ns,
                        minify
                    )
                else
                    _aprintln(buf, "<th></th>", il, ns, minify)
                end
            end

            # The row name column title must appear only on the first line.
            if show_row_names
                if i == 1
                    style = _html_text_alignment_dict(row_name_alignment)

                    row_name_title_html = _styled_html(
                        "th",
                        row_name_column_title,
                        style;
                        class = "rowName"
                    )

                    _aprintln(buf, row_name_title_html, il, ns, minify)
                else
                    _aprintln(buf, "<th></th>", il, ns, minify)
                end
            end

            for j = 1:num_printed_cols
                # Index of the j-th printed column in `data`.
                jc = id_cols[j]

                # Check the alignment of this cell.
                alignment_ij::Symbol = header_alignment[jc]

                for f in header_cell_alignment.x
                    aux = f(header, i, jc)

                    if aux ∈ (:l, :c, :r, :L, :C, :R, :s, :S)
                        alignment_ij = aux
                        break
                    end
                end

                # If alignment is `:s`, then we must use the column alignment.
                alignment_ij ∈ (:s, :S) && (alignment_ij = alignment[jc])

                # Alignment of this cell.
                style = _html_text_alignment_dict(alignment_ij)

                _aprintln(buf, _styled_html("th", header_str[i, j], style), il, ns, minify)
            end
            il -= 1
            _aprintln(buf, "</tr>", il, ns, minify)
        end

        il -= 1
        _aprintln(buf, "</thead>", il, ns, minify)
    end

    # Data
    # ==========================================================================

    _aprintln(buf, "<tbody>", il, ns, minify)
    il += 1

    @inbounds @views for i = 1:num_printed_rows
        ir = id_rows[i]

        _aprintln(buf, "<tr>", il, ns, minify)
        il += 1

        if show_row_number
            _aprintln(buf, "<td class = \"rowNumber\">" * string(ir) * "</td>", il, ns, minify)
        end

        if show_row_names
            # Due to the non-specialization of `row_names`, `row_name_i_str`
            # here is inferred as `Any`. However, we know that the output of
            # `_parse_cell_latex` must be a String.
            row_name_i_str::String = _parse_cell_html(
                row_names[i];
                cell_first_line_only = false,
                compact_printing = compact_printing,
                linebreaks = false,
                renderer = renderer
            )

            style = Dict{String,String}(
                "text-align" => _html_alignment[row_name_alignment]
            )

            row_name_i_html = _styled_html(
                "td",
                row_name_i_str,
                style;
                class = "rowName"
            )

            _aprintln(buf, row_name_i_html, il, ns, minify)
        end

        for j = 1:num_printed_cols
            jc = id_cols[j]

            # Check the alignment of this cell.
            alignment_ij::Symbol = alignment[jc]

            for f in cell_alignment.x
                aux = f(_getdata(data), ir, jc)

                if aux ∈ [:l, :c, :r, :L, :C, :R]
                    alignment_ij = aux
                    break
                end
            end

            # Alignment of this cell.
            style = _html_text_alignment_dict(alignment_ij)

            # If we have highlighters defined, then we need to verify if this
            # data should be highlight.
            for h in highlighters.x
                if h.f(_getdata(data), ir, jc)
                    merge!(style, Dict(h.fd(h,_getdata(data),i,j)))
                    break
                end
            end

            _aprintln(
                buf,
                _styled_html("td", data_str[i, j], style),
                il,
                ns,
                minify
            )
        end

        il -= 1
        _aprintln(buf, "</tr>", il, ns, minify)
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
