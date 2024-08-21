## Description #############################################################################
#
# HTML back end of PrettyTables.jl
#
############################################################################################

function _html__circular_reference(io::IOContext)
    print(io, "#= circular reference =#")
    return nothing
end

function _html__print(
    pspec::PrintingSpec;
    tf::HtmlTableFormat = _HTML__DEFAULT_TABLE_FORMAT,
    allow_html_in_cells::Bool = false,
    highlighters::Vector{HtmlHighlighter} = HtmlHighlighter[],
    is_stdout::Bool = false,
    line_breaks::Bool = false,
    maximum_column_width::String = "",
    minify::Bool = false,
    stand_alone::Bool = false,
    table_class::String = "",
    table_div_class::String = "",
    table_style::Dict{String, String} = Dict{String, String}(),
    top_left_string::AbstractString = "",
    top_right_string::AbstractString = "",
    wrap_table_in_div::Bool = false,
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # Create dictionaries to store properties and styles to decrease the number of
    # allocations.
    properties = Dict{String, String}()
    style      = Dict{String, String}()

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

        _aprint(buf, tf.css, il, ns; minify)
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
                tf.top_left_string_decoration,
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
                tf.top_right_string_decoration,
                il,
                ns;
                minify,
            )
        end

        # We need to clear the floats so that the table is rendered below the top bar.
        empty!(style)
        style["clear"] = "both"
        _aprintln(buf, _html__create_tag("div", ""; style), il, ns; minify)

        il -= 1
        _aprintln(buf, _html__close_tag("div"), il, ns; minify)
    end

    # == Table =============================================================================

    if wrap_table_in_div
        empty!(properties)
        properties["class"] = table_div_class

        empty!(style)
        style["overflow-x"] = "scroll"

        _aprintln(buf, _html__open_tag("div"; properties, style), il, ns; minify)

        il += 1
    end

    empty!(properties)
    properties["class"] = table_class

    _aprintln(
        buf,
        _html__open_tag("table"; properties, style = table_style),
        il,
        ns;
        minify
    )

    il += 1

    action = :initialize

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        if action == :new_row
            if (ps.i == 1) && (rs == :column_labels)
                _aprintln(buf, "<thead>", il, ns; minify)
                il += 1
            end

            if (ps.i == 1) && (rs == :data)
                _aprintln(buf, "<tbody>", il, ns; minify)
                il += 1
            end

            empty!(properties)
            properties["class"] = if rs == :column_labels
                "columnLabelRow"
            elseif rs == :data
                "dataRow"
            elseif rs == :summary_row
                "summaryRow"
            else
                ""
            end

            _aprintln(buf, _html__open_tag("tr"; properties), il, ns; minify)
            il += 1

        elseif action == :diagonal_continuation_cell
            _aprintln(buf, _html__create_tag("td", "&dtdot;"; style), il, ns; minify)

        elseif action == :horizontal_continuation_cell
            _aprintln(buf, _html__create_tag("td", "&ctdot;"), il, ns; minify)

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            # Obtain the cell style.
            empty!(style)
            alignment = _current_cell_alignment(action, ps, table_data)
            _html__add_alignment_to_style!(style, alignment)

            _aprintln(buf, _html__create_tag("td", "&vellip;"; style), il, ns; minify)

        elseif action == :end_row
            il -= 1
            _aprintln(buf, "</tr>", il, ns; minify)

            if (rs == :column_labels) && (ps.row_section != :column_labels)
                il -= 1
                _aprintln(buf, "</thead>", il, ns; minify)
            end

        else
            cell = _current_cell(action, ps, table_data)
            rendered_cell = _html__render_cell(
                cell,
                buf,
                renderer;
                allow_html_in_cells,
                line_breaks
            )

            # Obtain the cell alignment.
            empty!(style)
            alignment = _current_cell_alignment(action, ps, table_data)
            _html__add_alignment_to_style!(style, alignment)

            # Check if the user wants to limit the column width.
            if !isempty(maximum_column_width)
                style["max-width"]     = maximum_column_width
                style["overflow"]      = "hidden"
                style["text-overflow"] = "ellipsis"
                style["white-space"]   = "nowrap"
            end

            # If we are in a data cell, we must check for highlighters.
            if action == :data
                orig_data = _getdata(table_data.data)

                if !isnothing(highlighters)
                    for h in highlighters
                        if h.f(orig_data, ps.i, ps.j)
                            merge!(style, Dict{String, String}(h.fd(h, orig_data, ps.i, ps.j)))
                            break
                        end
                    end
                end
            end

            # Obtain the cell class and style.
            empty!(properties)

            if action == :row_number_label
                properties["class"] = "rowNumberLabel"
                merge!(style, tf.row_number_label_decoration)

            elseif action == :row_number
                properties["class"] = "rowNumber"
                merge!(style, tf.row_number_decoration)

            elseif action == :summary_row_number
                properties["class"] = "summaryRowNumber"
                merge!(style, tf.row_number_decoration)

            elseif action == :stubhead_label
                properties["class"] = "stubheadLabel"
                merge!(style, tf.stubhead_label_decoration)

            elseif action == :row_label
                properties["class"] = "rowLabel"
                merge!(style, tf.row_label_decoration)

            elseif action == :summary_row_label
                properties["class"] = "summaryRowLabel"
                merge!(style, tf.row_label_decoration)

            elseif action == :column_label
                properties["class"] = "columnLabel"

                if ps.i == 1
                    merge!(style, tf.first_column_label_decoration)
                else
                    merge!(style, tf.column_label_decoration)
                end

            elseif action == :data
                properties["class"] = ""

            elseif action == :summary_cell
                properties["class"] = "summaryCell"
                merge!(style, tf.summary_cell_decoration)

            elseif action == :source_notes
                properties["class"] = "sourceNotes"
                properties["colspan"] = string(_number_of_printed_columns(table_data))
                merge!(style, tf.source_note_decoration)

            else
                properties["class"] = ""
            end

            # Create the row tag with the content.
            row_tag = rs == :column_labels ? "th" : "td"
            _aprintln(
                buf,
                _html__create_tag(row_tag, rendered_cell; properties, style),
                il,
                ns;
                minify
            )
        end
    end

    il -= 1
    _aprintln(buf, "</tbody>", il, ns; minify)

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
