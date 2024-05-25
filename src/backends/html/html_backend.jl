## Description #############################################################################
#
# Print function of the HTML back end.
#
############################################################################################

# Low-level function to print the table using the text backend.
function _print_table_with_html_back_end(
    pinfo::PrintInfo;
    tf::HtmlTableFormat = tf_html_default,
    allow_html_in_cells::Bool = false,
    continuation_row_alignment::Symbol = :r,
    header_cell_titles::Union{Nothing, Tuple} = nothing,
    highlighters::Union{HtmlHighlighter, Tuple} = (),
    is_stdout::Bool = false,
    linebreaks::Bool = false,
    maximum_columns_width::String = "",
    minify::Bool = false,
    sortkeys::Bool = false,
    show_omitted_cell_summary::Bool = false,
    standalone::Bool = false,
    table_div_class::String = "",
    table_class::String = "",
    table_style::Dict{String, String} = Dict{String, String}(),
    top_left_str::String = "",
    top_right_str::String = "",
    vcrop_mode::Symbol = :bottom,
    wrap_table_in_div::Bool = false,
    # Decorations
    row_label_decoration::HtmlDecoration = HtmlDecoration(font_weight = "bold"),
    row_number_decoration::HtmlDecoration = HtmlDecoration(font_weight = "bold"),
    top_left_str_decoration::HtmlDecoration = HtmlDecoration(),
    top_right_str_decoration::HtmlDecoration = HtmlDecoration(),
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

    # Get the number of data rows and columns.
    num_data_rows, num_data_columns = _data_size(ptable)

    # Make sure that `highlighters` is always a Tuple.
    if !(highlighters isa Tuple)
        highlighters = (highlighters,)
    end

    # Check the dimensions of header cell titles.
    if !isnothing(header_cell_titles)
        if length(header_cell_titles) < num_header_rows
            error("The number of vectors in `header_cell_titles` must be equal or greater than that in `header`.")
        end

        for k in 1:num_header_rows
            if !isnothing(header_cell_titles[k]) && (length(header_cell_titles[k]) != num_data_columns)
                error("The number of elements in each row of `header_cell_titles` must match the number of columns in the table.")
            end
        end
    end

    # Create dictionaries to store properties and styles to decrease the number
    # of allocations.
    properties = Dict{String, String}()
    style      = Dict{String, String}()

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # == Print HTML Header =================================================================

    if standalone
        _aprintln(
            buf,
            """
            <!DOCTYPE html>
            <html>
            <meta charset=\"UTF-8\">
            <head>
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
            </head>
            <body>""",
            il,
            ns,
            minify
        )
    end

    # == Omitted Cell Summary ==============================================================

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

            # If we reached this point, we need to show the omitted cell summary. Hence, we
            # replace whatever it in the top right string.
            top_right_str = str
        end
    end

    # == Top Bar ===========================================================================

    _print_top_bar(
        buf,
        top_left_str,
        top_left_str_decoration,
        top_right_str,
        top_right_str_decoration,
        il,
        ns,
        minify
    )

    # == Table =============================================================================

    if wrap_table_in_div
        empty!(properties)
        properties["class"] = table_div_class

        empty!(style)
        style["overflow-x"] = "scroll"

        _aprintln(buf, _open_html_tag("div"; properties, style), il, ns, minify)

        il += 1
    end

    empty!(properties)
    properties["class"] = table_class

    _aprintln(
        buf,
        _open_html_tag("table"; properties, style = table_style),
        il,
        ns,
        minify
    )

    il += 1

    # -- Table Title -----------------------------------------------------------------------

    if length(title) > 0
        empty!(style)
        style["text-align"] = _html_alignment[title_alignment]

        _aprintln(buf, _create_html_tag( "caption", title; style), il, ns, minify)
    end

    # If there is no column or row to be printed, then just exit.
    if _data_size(ptable) == (0, 0)
        @goto print_to_output
    end

    # == Vertical Cropping Mode ============================================================

    if hidden_rows_at_end
        continuation_line_id = vcrop_mode == :middle ?
            num_header_rows + div(num_rows - num_header_rows, 2, RoundUp) :
            num_rows
    else
        continuation_line_id = 0
    end

    # == Print the Table ===================================================================

    # Offset in the rows used when we have middle cropping. In this case, after drawing the
    # continuation line, we use this variable to render the bottom part of the table.
    Δr = 0

    @inbounds for i in 1:num_rows
        # Get the identification of the current row.
        row_id = _get_row_id(ptable, i + Δr)

        # HTML tag for the row.
        html_row_tag = ""

        # Class of the row.
        row_class = ""

        if (num_header_rows == 0) && (i == 1)
            _aprintln(buf, _open_html_tag("tbody"), il, ns, minify)
            il += 1
        end

        if _is_header_row(row_id)
            html_row_tag = "th"

            # If we have a header row and `i = 1`, then we need to start the header. We can
            # do this because the header is always at the beginning of the table.
            if i == 1
                _aprintln(buf, _open_html_tag("thead"), il, ns, minify)
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

        empty!(properties)
        properties["class"] = row_class
        _aprintln(buf, _open_html_tag("tr"; properties), il, ns, minify)
        il += 1

        @inbounds for j in 1:num_columns
            # Get the identification of the current column.
            column_id = _get_column_id(ptable, j)

            # Get the alignment for the current cell.
            cell_alignment = _get_cell_alignment(ptable, i + Δr, j)

            # Get the cell data.
            cell_data = _get_element(ptable, i + Δr, j)

            # If we do not annotate the type here, we get type instability due to
            # `_html_parse_cell`.
            cell_str::String = ""

            # The class of the cell.
            cell_class = ""

            # The title of the cell (used only for the header).
            cell_title = ""

            # Style of the cell.
            empty!(style)
            _add_text_alignment_to_style!(style, cell_alignment)

            if !isempty(maximum_columns_width)
                style["max-width"]     = maximum_columns_width
                style["overflow"]      = "hidden"
                style["text-overflow"] = "ellipsis"
                style["white-space"]   = "nowrap"
            end

            if column_id == :row_number
                cell_class = "rowNumber"
                merge!(style, Dict(row_number_decoration))
            elseif column_id == :row_label
                cell_class = "rowLabel"
                merge!(style, Dict(row_label_decoration))
            end

            if _is_header_row(row_id)

                # Check if the user wants to add a title to this header cell.
                if column_id == :__ORIGINAL_DATA__
                    # TODO: This code only works because the header is always at top.

                    if !isnothing(header_cell_titles) && !isnothing(header_cell_titles[i])
                        jh = _get_data_column_index(ptable, j)
                        cell_title = _escape_html_str(string(header_cell_titles[i][jh]))
                    end
                end

                cell_str = _html_parse_cell(
                    io,
                    cell_data;
                    allow_html_in_cells = allow_html_in_cells,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    renderer = Val(:print)
                )

                empty!(properties)
                properties["class"] = cell_class
                properties["title"] = cell_title

                _aprintln(
                    buf,
                    _create_html_tag(html_row_tag, cell_str; properties, style),
                    il,
                    ns,
                    minify
                )

                # Check if we need to draw the continuation character.
                if (j == num_columns) && hidden_columns_at_end
                    empty!(style)
                    _add_text_alignment_to_style!(style, continuation_row_alignment)

                    _aprintln(
                        buf,
                        _create_html_tag(html_row_tag, "&ctdot;"; properties, style),
                        il,
                        ns,
                        minify
                    )
                end

            else
                is_original_data = column_id == :__ORIGINAL_DATA__

                if is_original_data
                    ir = _get_data_row_index(ptable, i + Δr)
                    jr = _get_data_column_index(ptable, j)

                    # Notice that `(ir, jr)` are the indices of the printed data. It means
                    # that it refers to the ir-th data row and jr-th data column that will
                    # be printed. We need to convert those indices to the actual indices in
                    # the input table.
                    tir, tjr = _convert_axes(ptable.data, ir, jr)

                    for f in formatters.x
                        cell_data = f(cell_data, tir, tjr)
                    end

                    # Apply highlighters.
                    for h in highlighters
                        if h.f(_getdata(ptable), tir, tjr)
                            merge!(style, Dict(h.fd(h, _getdata(ptable), tir, tjr)))
                            break
                        end
                    end
                end

                cell_str = _html_parse_cell(
                    io,
                    cell_data;
                    allow_html_in_cells = allow_html_in_cells,
                    cell_first_line_only = cell_first_line_only,
                    compact_printing = compact_printing,
                    limit_printing = limit_printing,
                    linebreaks = linebreaks,
                    renderer = renderer
                )

                empty!(properties)
                properties["class"] = cell_class

                _aprintln(
                    buf,
                    _create_html_tag(html_row_tag, cell_str; properties, style),
                    il,
                    ns,
                    minify
                )

                # Check if we need to draw the continuation character.
                if (j == num_columns) && hidden_columns_at_end
                    empty!(style)
                    _add_text_alignment_to_style!(style, continuation_row_alignment)

                    _aprintln(
                        buf,
                        _create_html_tag(html_row_tag, "&ctdot;"; properties, style),
                        il,
                        ns,
                        minify
                    )
                end
            end
        end

        il -= 1
        _aprintln(buf, _close_html_tag("tr"), il, ns, minify)

        if i == num_header_rows
            il -= 1
            _aprintln(buf, _close_html_tag("thead"), il, ns, minify)
            _aprintln(buf, _open_html_tag("tbody"),  il, ns, minify)
            il += 1
        end

        # If we have hidden rows, we need to print an additional row with the continuation
        # characters.
        if i == continuation_line_id
            _aprintln(buf, _open_html_tag("tr"), il, ns, minify)
            il += 1

            empty!(style)
            _add_text_alignment_to_style!(style, continuation_row_alignment)

            for j in 1:num_columns
                _aprintln(
                    buf,
                    _create_html_tag(html_row_tag, "&vellip;"; style),
                    il,
                    ns,
                    minify
                )

                if (j == num_columns) && hidden_columns_at_end
                    _aprintln(
                        buf,
                        _create_html_tag(html_row_tag, "&dtdot;"; style),
                        il,
                        ns,
                        minify
                    )
                end
            end

            il -= 1
            _aprintln(buf, _close_html_tag("tr"), il, ns, minify)

            # Apply the offset in case we are using middle cropping.
            Δr = _total_size(ptable)[1] - num_rows
        end
    end

    il -= 1
    _aprintln(buf, _close_html_tag("tbody"), il, ns, minify)

    @label print_to_output

    # == Print HTML Footer =================================================================

    il -= 1
    _aprintln(buf, _close_html_tag("table"), il, ns, minify)
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

    if wrap_table_in_div
        il -= 1
        _aprintln(buf, _close_html_tag("div"), il, ns, minify)
    end

    # == Print the Buffer Into the IO ======================================================

    # If we are printing to `stdout`, wrap the output in a `HTML` object.
    if is_stdout
        display(MIME("text/html"), HTML(String(take!(buf_io))))
    else
        print(io, String(take!(buf_io)))
    end

    return nothing
end
