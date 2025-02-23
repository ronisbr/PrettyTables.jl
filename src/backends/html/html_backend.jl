## Description #############################################################################
#
# HTML back end of PrettyTables.jl
#
############################################################################################

function _html__print(
    pspec::PrintingSpec;
    allow_html_in_cells::Bool = false,
    highlighters::Vector{HtmlHighlighter} = HtmlHighlighter[],
    is_stdout::Bool = false,
    line_breaks::Bool = false,
    maximum_column_width::String = "",
    minify::Bool = false,
    stand_alone::Bool = false,
    style::HtmlTableStyle = HtmlTableStyle(),
    table_class::String = "",
    table_div_class::String = "",
    table_format::HtmlTableFormat = HtmlTableFormat(),
    top_left_string::AbstractString = "",
    top_right_string::AbstractString = "",
    wrap_table_in_div::Bool = false,
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)
    tf         = table_format

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # Create dictionaries to store properties and styles to decrease the number of
    # allocations.
    vproperties = Pair{String, String}[]
    vstyle      = Pair{String, String}[]

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # == Print HTML Header =================================================================

    if stand_alone
        _aprintln(
            buf,
            """
            <!DOCTYPE html>
            <html>
            <meta charset="UTF-8">
            <head>
            <style>""",
            il,
            ns;
            minify
        )
        il += 1

        !isempty(tf.table_width) && _aprintln(
            buf,
            """
            table {
                width: $(tf.table_width);
            }
            """,
            il,
            ns;
            minify
        )

        _aprintln(buf, tf.css, il, ns; minify)
        il -= 1

        _aprintln(
            buf,
            """
            </style>
            </head>
            <body>""",
            il,
            ns;
            minify
        )
    end

    # == Top Bar ===========================================================================

    # Check if the user wants the omitted cell summary.
    ocs = _omitted_cell_summary(table_data, pspec)

    if !isempty(ocs)
        top_right_string = ocs
    end

    # Print the top bar if necessary.
    if !isempty(top_left_string) || !isempty(top_right_string)
        _aprintln(
            buf,
            _html__open_tag("div"),
            il,
            ns;
            minify
        )
        il += 1

        # Top left section.
        if !isempty(top_left_string)
            _html__print_top_bar_section(
                buf,
                "left",
                top_left_string,
                style.top_left_string,
                il,
                ns;
                minify,
            )
        end

        # Top right section.
        if !isempty(top_right_string)
            _html__print_top_bar_section(
                buf,
                "right",
                top_right_string,
                style.top_right_string,
                il,
                ns;
                minify,
            )
        end

        # We need to clear the floats so that the table is rendered below the top bar.
        empty!(vstyle)
        push!(vstyle, "clear" => "both")
        _aprintln(buf, _html__create_tag("div", ""; style = vstyle), il, ns; minify)

        il -= 1
        _aprintln(buf, _html__close_tag("div"), il, ns; minify)
    end

    # == Table =============================================================================

    if wrap_table_in_div
        empty!(vproperties)
        push!(vproperties, "class" => table_div_class)

        empty!(vstyle)
        push!(vproperties, "overflow-x" => "scroll")

        _aprintln(
            buf,
            _html__open_tag("div"; properties = vproperties, style = vstyle),
            il,
            ns;
            minify
        )

        il += 1
    end

    empty!(vproperties)
    push!(vproperties, "class" => table_class)

    _aprintln(
        buf,
        _html__open_tag("table"; properties = vproperties, style = style.table),
        il,
        ns;
        minify
    )

    il += 1

    action = :initialize

    # Some internal states to help printing.
    head_opened = false
    body_opened = false
    foot_opened = false

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        if action == :new_row

            if (ps.i == 1) && (rs ∈ (:table_header, :column_label)) && !head_opened
                _aprintln(buf, "<thead>", il, ns; minify)
                il += 1
                head_opened = true

            elseif !body_opened && (
                    ((ps.i == 1) && (rs ∈ (:data, :summary_row))) ||
                    (rs == :row_group_label)
                )

                if head_opened
                    il -= 1
                    _aprintln(buf, "</thead>", il, ns; minify)
                    head_opened = false
                end

                _aprintln(buf, "<tbody>", il, ns; minify)
                body_opened = true
                il += 1

            elseif (ps.i == 1) && (rs == :table_footer) && !foot_opened
                if head_opened
                    il -= 1
                    _aprintln(buf, "</thead>", il, ns; minify)
                    head_opened = false
                elseif body_opened
                    il -= 1
                    _aprintln(buf, "</tbody>", il, ns; minify)
                    head_opened = false
                end

                _aprintln(buf, "<tfoot>", il, ns; minify)
                foot_opened = true
                il += 1
            end

            empty!(vproperties)
            class = if rs == :table_header
                ps.state < _TITLE ? "title" : "subtitle"
            elseif rs == :column_labels
                "columnLabelRow"
            elseif rs == :row_group_label
                "rowGroupLabel"
            elseif rs == :data
                "dataRow"
            elseif rs == :summary_row
                "summaryRow"
            elseif rs == :table_footer
                ps.state < _FOOTNOTES ? "footnote" : "sourceNotes"
            else
                ""
            end
            push!(vproperties, "class" => class)

            _aprintln(buf, _html__open_tag("tr"; properties = vproperties), il, ns; minify)
            il += 1

        elseif action == :diagonal_continuation_cell
            _aprintln(
                buf,
                _html__create_tag("td", "&dtdot;"; style = vstyle),
                il,
                ns;
                minify
            )

        elseif action == :horizontal_continuation_cell
            _aprintln(buf, _html__create_tag("td", "&ctdot;"), il, ns; minify)

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            # Obtain the cell style.
            empty!(vstyle)
            alignment = _current_cell_alignment(action, ps, table_data)
            _html__add_alignment_to_style!(vstyle, alignment)

            _aprintln(
                buf,
                _html__create_tag("td", "&vellip;"; style = vstyle),
                il,
                ns;
                minify
            )

        elseif action == :end_row
            il -= 1
            _aprintln(buf, "</tr>", il, ns; minify)

        else
            empty!(vproperties)
            empty!(vstyle)

            cell = _current_cell(action, ps, table_data)

            cell === _IGNORE_CELL && continue

            # If we are in a column label, check if we must merge the cell.
            if (action == :column_label) && (cell isa MergeCells)
                # Check if we have enough data columns to merge the cell.
                num_data_columns = _number_of_printed_data_columns(table_data)

                cs = if (ps.j + cell.column_span - 1) > num_data_columns
                    num_data_columns - ps.j + 1
                else
                    cell.column_span
                end

                push!(vproperties, "colspan" => string(cs))
                rendered_cell = _html__render_cell(
                    cell.data,
                    buf,
                    renderer;
                    allow_html_in_cells,
                    line_breaks
                )

                alignment = cell.alignment

                append!(
                    vstyle,
                    if ps.i == 1
                        style.first_line_merged_column_label
                    else
                        style.merged_column_label
                    end
                )

            else
                rendered_cell = _html__render_cell(
                    cell,
                    buf,
                    renderer;
                    allow_html_in_cells,
                    line_breaks
                )

                alignment = _current_cell_alignment(action, ps, table_data)
            end

            # Obtain the cell alignment.
            _html__add_alignment_to_style!(vstyle, alignment)

            # Check if the user wants to limit the column width.
            if !isempty(maximum_column_width)
                push!(
                    vstyle,
                    "max-width"     => maximum_column_width,
                    "overflow"      => "hidden",
                    "text-overflow" => "ellipsis",
                    "white-space"   => "nowrap",
                )
            end

            # Check for footnotes.
            footnotes = _current_cell_footnotes(table_data, action, ps.i, ps.j)

            if !isnothing(footnotes) && !isempty(footnotes)
                rendered_cell *= "<sup>"
                for i in eachindex(footnotes)
                    f = footnotes[i]
                    if i != last(eachindex(footnotes))
                        rendered_cell *= "$f,"
                    else
                        rendered_cell *= "$f</sup>"
                    end
                end
            end

            # If we are in a data cell, we must check for highlighters.
            if action == :data
                orig_data = _get_data(table_data.data)

                if !isnothing(highlighters)
                    for h in highlighters
                        if h.f(orig_data, ps.i, ps.j)
                            append!(vstyle, h.fd(h, orig_data, ps.i, ps.j))
                            break
                        end
                    end
                end
            end

            # Obtain the cell class and style.

            if action == :title
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                append!(vstyle, style.title)

            elseif action == :subtitle
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                append!(vstyle, style.subtitle)

            elseif action == :row_number_label
                push!(vproperties, "class" => "rowNumberLabel")
                append!(vstyle, style.row_number_label)

            elseif action == :row_number
                push!(vproperties, "class" => "rowNumber")
                append!(vstyle, style.row_number)

            elseif action == :summary_row_number
                push!(vproperties, "class" => "summaryRowNumber")
                append!(vstyle, style.row_number)

            elseif action == :stubhead_label
                push!(vproperties, "class" => "stubheadLabel")
                append!(vstyle, style.stubhead_label)

            elseif action == :row_group_label
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                append!(vstyle, style.row_group_label)

            elseif action == :row_label
                push!(vproperties, "class" => "rowLabel")
                append!(vstyle, style.row_label)

            elseif action == :summary_row_label
                push!(vproperties, "class" => "summaryRowLabel")
                append!(vstyle, style.summary_row_label)

            elseif action == :column_label
                if ps.i == 1
                    append!(vstyle, style.first_line_column_label)
                else
                    append!(vstyle, style.column_label)
                end

            elseif action == :summary_row_cell
                append!(vstyle, style.summary_row_cell)

            elseif action == :footnote
                # The footnote must be a cell that span the entire printed table.
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                append!(vstyle, style.footnote)
                rendered_cell = "<sup>$(ps.i)</sup> " * rendered_cell

            elseif action == :source_notes
                # The source notes must be a cell that span the entire printed table.
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                append!(vstyle, style.source_note)

            else
                push!(vproperties, "class" => "")
            end

            # Create the row tag with the content.
            row_tag = rs == :column_labels ? "th" : "td"
            _aprintln(
                buf,
                _html__create_tag(
                    row_tag,
                    rendered_cell;
                    properties = vproperties,
                    style = vstyle
                ),
                il,
                ns;
                minify
            )
        end
    end

    # Close the section that was left opened.
    if head_opened
        il -= 1
        _aprintln(buf, "</thead>", il, ns; minify)
    elseif body_opened
        il -= 1
        _aprintln(buf, "</tbody>", il, ns; minify)
    elseif foot_opened
        il -= 1
        _aprintln(buf, "</tfoot>", il, ns; minify)
    end

    il -= 1
    _aprintln(buf, _html__close_tag("table"), il, ns; minify)

    if stand_alone
        _aprintln(
            buf,
            """
            </body>
            </html>""",
            il,
            ns;
            minify
        )
    end

    if wrap_table_in_div
        il -= 1
        _aprintln(buf, _html__close_tag("div"), il, ns; minify)
    end

    # == Print the Buffer Into the IO ======================================================

    # If we are printing to `stdout`, wrap the output in a `HTML` object.
    if is_stdout
        display(MIME("text/html"), HTML(String(take!(buf_io))))
    else
        print(context, String(take!(buf_io)))
    end

    return nothing
end
