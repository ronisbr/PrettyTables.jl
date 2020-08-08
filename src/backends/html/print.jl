# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Print function of the html backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Low-level function to print the table using the text backend.
function _pt_html(io, pinfo;
                  tf::HTMLTableFormat = html_default,
                  highlighters::Union{HTMLHighlighter,Tuple} = (),
                  linebreaks::Bool = false,
                  noheader::Bool = false,
                  nosubheader::Bool = false,
                  show_row_number::Bool = false,
                  standalone::Bool = true,
                   # Deprecated
                   formatter = nothing)

    @unpack_PrintInfo pinfo
    @unpack_HTMLTableFormat tf

    # Let's create a `IOBuffer` to write everything and then transfer to `io`.
    buf_io = IOBuffer()
    buf    = IOContext(buf_io)

    !noheader && num_cols != header_num_cols &&
    error("The header length must be equal to the number of columns.")

    # Additional processing necessary if the user wants to print the header.
    if !noheader
        # If the user do not want to print the sub-header but wants to print the
        # header, then just force the number of rows in header to be 1.
        if nosubheader
            # Now, `header` will be a view of the first line of the matrix that
            # has the header.
            header = @view header[1:header_num_rows:end]
            header_num_rows = 1
        end
    end

    # Make sure that `highlighters` is always a tuple.
    !(highlighters isa Tuple) && (highlighters = (highlighters,))

    # Get the string which is printed when `print` is called in each element of
    # the matrix. Notice that we must create only the matrix with the printed
    # rows and columns.
    header_str = Matrix{String}(undef, header_num_rows, num_printed_cols)
    data_str   = Matrix{AbstractString}(undef, num_printed_rows, num_printed_cols)

    @inbounds for i = 1:num_printed_cols
        # Index of the i-th printed column in `data`.
        ic = id_cols[i]

        if !noheader
            for j = 1:header_num_rows
                header_str[j,i] = _str_escaped(sprint(print, header[(ic-1)*header_num_rows + j];
                                                      context = :compact => compact_printing))
            end
        end

        for j = 1:num_printed_rows
            # Index of the j-th printed row in `data`.
            jr = id_rows[j]

            # Apply the formatters.
            data_ij = isassigned(data,jr,ic) ? data[jr,ic] : undef

            for f in formatters
                data_ij = f(data_ij, jr, ic)
            end

            # Handle `nothing`, `missing`, and `undef`.
            if ismissing(data_ij)
                data_str_ij = "missing"
            elseif data_ij == nothing
                data_str_ij = "nothing"
            elseif data_ij == undef
                data_str_ij = "#undef"
            else
                data_str_ij = sprint(print, data_ij;
                                     context = :compact => compact_printing)
            end

            # If `linebreaks` is true, then replace `\n` to `<BR>`.
            if linebreaks
                data_str_ij = replace(data_str_ij, "\n" => "<BR>")
            end

            data_str_ij_esc = _str_escaped(data_str_ij)
            data_str[j,i]   = data_str_ij_esc
        end
    end

    # Print HTML header
    # ==========================================================================

    if standalone
        println(buf, """
                <!DOCTYPE html>
                <html>
                <meta charset=\"UTF-8\">
                <style>""")

        !isempty(table_width) && println(buf, """
                table {
                    width: $table_width;
                }
                """)

        println(buf, """
                $css
                </style>
                <body>""")
    end

    println(buf, "<table>")

    # Data header
    # ==========================================================================

    # Header and sub-header texts
    # --------------------------------------------------------------------------

    if !noheader
        @inbounds @views for i = 1:header_num_rows
            if (i == 1) && (header_num_rows == 1)
                println(buf, "<tr class = \"header headerLastRow\">")
            elseif i == 1
                println(buf, "<tr class = header>")
            elseif i == header_num_rows
                println(buf, "<tr class = \"subheader headerLastRow\">")
            else
                println(buf, "<tr class = subheader>")
            end

            # The text "Row" must appear only on the first line.
            if show_row_number
                if i == 1
                    println(buf, "<th class = rowNumber>Row</th>")
                else
                    println(buf, "<th></th>")
                end
            end

            for j = 1:num_printed_cols
                # Index of the j-th printed column in `data`.
                jc = id_cols[j]

                # Alignment of this cell.
                style = Dict{String,String}("text-align" => _html_alignment[alignment[j]])

                println(buf, _styled_html("th", header_str[i,j], style))
            end

            println(buf, "</tr>")
        end
    end

    # Data
    # ==========================================================================

    @inbounds @views for i = 1:num_printed_rows
        ir = id_rows[i]

        println(buf, "<tr>")

        if show_row_number
            println(buf, "<td class = rowNumber>" * string(ir) * "</td>")
        end

        for j = 1:num_printed_cols
            jc = id_cols[j]

            # Check the alignment of this cell.
            alignment_ij = alignment[jc]

            for f in cell_alignment
                aux = f(_getdata(data), ir, jc)

                if aux ∈ [:l, :c, :r, :L, :C, :R]
                    alignment_ij = aux
                    break
                end
            end

            # Alignment of this cell.
            style = Dict{String,String}("text-align" => _html_alignment[alignment_ij])

            # If we have highlighters defined, then we need to verify if this
            # data should be highlight.
            for h in highlighters
                if h.f(_getdata(data), ir, jc)
                    merge!(style, Dict(h.fd(h,_getdata(data),i,j)))
                    break
                end
            end

            println(buf, _styled_html("td", data_str[i,j], style))
        end

        println(buf, "</tr>")
    end

    # Print HTML footer
    # ==========================================================================

    println(buf, "</table>")
    if standalone
        println(buf, """
                </body>
                </html>""")
    end

    # Print the buffer into the io.
    # ==========================================================================

    if io == stdout
        display("text/html", HTML(String(take!(buf_io))))
    else
        print(io, String(take!(buf_io)))
    end

    return nothing
end
