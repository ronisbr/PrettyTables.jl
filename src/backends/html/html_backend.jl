## Description #############################################################################
#
# HTML back end of PrettyTables.jl
#
############################################################################################

# Default style and format, created once because constructing them allocates.
const _DEFAULT_HTML_TABLE_STYLE  = HtmlTableStyle()
const _DEFAULT_HTML_TABLE_FORMAT = HtmlTableFormat()

############################################################################################
#                                      Print Options                                       #
############################################################################################

"""
    struct HtmlPrintOptions

Options of the HTML back end, with one field per keyword of `pretty_table` that is specific
to this back end, plus `is_stdout`, which is `true` when the table is printed to `stdout`.
The meaning and the default of each field are documented in the HTML back end section of
`pretty_table`.

The keywords are gathered in this structure so that the rendering body has a single
positional signature. Otherwise, each distinct set of keywords passed by the user would
create a new entry point into the body, and compiling an entry point into such a large
function is expensive (hundreds of milliseconds in Julia 1.12) even when the body itself is
already compiled.
"""
@kwdef struct HtmlPrintOptions
    allow_html_in_cells::Bool                           = false
    column_label_titles::Union{Nothing, AbstractVector} = nothing
    highlighters::Vector{AbstractHighlighter}           = _NO_HIGHLIGHTERS
    is_stdout::Bool                                     = false
    line_breaks::Bool                                   = false
    maximum_column_width::String                        = ""
    minify::Bool                                        = false
    stand_alone::Bool                                   = false
    style::HtmlTableStyle                               = _DEFAULT_HTML_TABLE_STYLE
    table_class::String                                 = ""
    table_div_class::String                             = ""
    table_format::HtmlTableFormat                       = _DEFAULT_HTML_TABLE_FORMAT
    top_left_string::String                             = ""
    top_right_string::String                            = ""
    wrap_table_in_div::Bool                             = false
end

############################################################################################
#                                      Entry Points                                       #
############################################################################################

# The keyword entry point only gathers the options. It is compiled once per set of keywords,
# which is cheap because it is tiny.
function _html__print(pspec::PrintingSpec; kwargs...)
    return _html__print(pspec, HtmlPrintOptions(; kwargs...))
end

# This method must be the only caller of the rendering body and it must not be inlined into
# the keyword entry point. Otherwise, each keyword set would pay for a new entry point into
# the body (see `HtmlPrintOptions`).
@noinline function _html__print(pspec::PrintingSpec, opts::HtmlPrintOptions)
    return _html__print_core(pspec, opts)
end

function _html__print_core(pspec::PrintingSpec, opts::HtmlPrintOptions)
    # == Unpack the Options ================================================================

    allow_html_in_cells  = opts.allow_html_in_cells
    column_label_titles  = opts.column_label_titles
    highlighters         = _html__native_highlighters(opts.highlighters)
    is_stdout            = opts.is_stdout
    line_breaks          = opts.line_breaks
    maximum_column_width = opts.maximum_column_width
    minify               = opts.minify
    stand_alone          = opts.stand_alone
    style                = opts.style
    table_class          = opts.table_class
    table_div_class      = opts.table_div_class
    table_format         = opts.table_format
    top_left_string      = opts.top_left_string
    top_right_string     = opts.top_right_string
    wrap_table_in_div    = opts.wrap_table_in_div

    context    = pspec.context
    table_data = pspec.table_data
    # NOTE: `Val(pspec.renderer)` infers to the abstract `Val` because
    # `pspec.renderer` is a `Symbol`. Branching here keeps the renderer concrete, so the
    # per-cell rendering calls are statically dispatched.
    renderer   = pspec.renderer === :show ? Val(:show) : Val(:print)
    tf         = table_format

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # Reusable render buffer: one allocation per table instead of three per cell.
    rctx = RenderContext(context)

    # Create dictionaries to store properties and styles to decrease the number of
    # allocations.
    vproperties = Pair{String, String}[]
    vstyle      = Pair{String, String}[]

    num_column_label_rows = length(table_data.column_labels)

    # Check the dimensions of header cell titles.
    if !isnothing(column_label_titles)
        if length(column_label_titles) < num_column_label_rows
            error(
                "The number of vectors in `column_label_titles` must be equal to or greater than that in `column_labels`.",
            )
        end

        for k in eachindex(column_label_titles)
            if (
                !isnothing(column_label_titles[k]) &&
                (length(column_label_titles[k]) != table_data.num_columns)
            )
                error(
                    "The number of elements in each row of `column_label_titles` must match the number of columns in the table.",
                )
            end
        end
    end

    # Check the style variables.
    if style.first_line_column_label isa Vector{Vector{HtmlPair}}
        length(style.first_line_column_label) != table_data.num_columns && throw(
            ArgumentError(
                "The length of `first_line_column_label` in `style` must be equal to the number of columns ($(table_data.num_columns)).",
            ),
        )
    end

    if style.column_label isa Vector{Vector{HtmlPair}}
        length(style.column_label) != table_data.num_columns && throw(
            ArgumentError(
                "The length of `column_label` in `style` must be equal to the number of columns ($(table_data.num_columns)).",
            ),
        )
    end

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
            <head>
            <meta charset="UTF-8">
            <style>""",
            il,
            ns;
            minify,
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
            minify,
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
            minify,
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
        _aprintln(buf, _html__open_tag("div"), il, ns; minify)
        il += 1

        # Top left section.
        if !isempty(top_left_string)
            _html__print_top_bar_section(
                buf, "left", top_left_string, style.top_left_string, il, ns; minify
            )
        end

        # Top right section.
        if !isempty(top_right_string)
            _html__print_top_bar_section(
                buf, "right", top_right_string, style.top_right_string, il, ns; minify
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
        push!(vstyle, "overflow-x" => "scroll")

        _aprintln(
            buf,
            _html__open_tag("div"; properties = vproperties, style = vstyle),
            il,
            ns;
            minify,
        )

        il += 1
    end

    empty!(vproperties)
    push!(vproperties, "class" => table_class)

    # The borders at the top and bottom of the table are emitted in the `<table>` element,
    # avoiding the need to know which rows are the first and last ones. `border-collapse`
    # is required so that adjacent cell borders are merged into a single line. However, it
    # is only emitted when the format draws at least one line so that the default table has
    # no border decoration. Notice that the user style is appended afterward, allowing it
    # to override the borders.
    empty!(vstyle)

    if _html__has_any_table_line(tf)
        push!(vstyle, "border-collapse" => "collapse")

        tf.horizontal_line_at_beginning &&
            push!(vstyle, "border-top" => tf.borders.top_line)

        tf.horizontal_line_at_end &&
            push!(vstyle, "border-bottom" => tf.borders.bottom_line)
    end

    append!(vstyle, style.table)

    _aprintln(
        buf,
        _html__open_tag("table"; properties = vproperties, style = vstyle),
        il,
        ns;
        minify,
    )

    il += 1

    # == Table Borders =====================================================================

    # Process the horizontal lines at data rows.
    if tf.horizontal_lines_at_data_rows isa Symbol
        horizontal_lines_at_data_rows = if tf.horizontal_lines_at_data_rows == :all
            1:(table_data.num_rows)
        else
            1:0
        end
    else
        horizontal_lines_at_data_rows = tf.horizontal_lines_at_data_rows::Vector{Int}
    end

    # Process the vertical lines at data columns.
    if tf.vertical_lines_at_data_columns isa Symbol
        vertical_lines_at_data_columns = if tf.vertical_lines_at_data_columns == :all
            1:(table_data.num_columns)
        else
            1:0
        end
    else
        vertical_lines_at_data_columns = tf.vertical_lines_at_data_columns::Vector{Int}
    end

    num_printed_data_columns = _number_of_printed_data_columns(table_data)
    num_printed_columns      = _number_of_printed_columns(table_data)
    colspan_all              = string(num_printed_columns)
    horizontally_cropped     = _is_horizontally_cropped(table_data)
    num_summary_rows         = isnothing(table_data.summary_rows) ? 0 : length(table_data.summary_rows)
    num_footnotes            = isnothing(table_data.footnotes) ? 0 : length(table_data.footnotes)

    # == Column Borders ====================================================================

    # The vertical lines are emitted as the borders of `<col>` elements, which are applied
    # to the edges of every cell in the column when the table borders are collapsed. Hence,
    # the cells do not carry the vertical borders, reducing the output size considerably.
    # The first column also carries the border at the left of the table.
    column_borders = _html__column_borders(
        tf,
        table_data,
        vertical_lines_at_data_columns,
        num_printed_data_columns,
        horizontally_cropped,
    )

    left_border = tf.vertical_line_at_beginning ? tf.borders.left_line : ""

    if !isempty(column_borders) && (!isempty(left_border) || any(!isempty, column_borders))
        _aprintln(buf, "<colgroup>", il, ns; minify)
        il += 1

        for (k, right_border) in enumerate(column_borders)
            empty!(vstyle)
            (k == 1) && !isempty(left_border) && push!(vstyle, "border-left" => left_border)
            !isempty(right_border) && push!(vstyle, "border-right" => right_border)
            _aprintln(buf, _html__open_tag("col"; style = vstyle), il, ns; minify)
        end

        il -= 1
        _aprintln(buf, "</colgroup>", il, ns; minify)
    end

    # Variables to store the borders of the current row, filled at each `:new_row` action.
    # They are emitted in the `<tr>` element and applied to every cell of the row when the
    # table borders are collapsed.
    row_border_top    = ""
    row_border_bottom = ""

    # Row section of the previous row, required to check if the column labels are preceded
    # by a title or subtitle.
    prev_rs = :none

    action = :initialize

    # Some internal states to help printing.
    head_opened = false
    body_opened = false
    foot_opened = false

    # The highlighters must receive the object the user passed to `pretty_table`, not the
    # internal table wrapper. Notice that this is loop invariant.
    orig_data = _get_data(table_data.data)

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        if action == :new_row
            if (ps.i == 1) && (rs ∈ (:table_header, :column_labels)) && !head_opened
                _aprintln(buf, "<thead>", il, ns; minify)
                il += 1
                head_opened = true

            elseif !body_opened && (
                ((ps.i == 1) && (rs ∈ (:data, :summary_row))) || (rs == :row_group_label)
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
                    body_opened = false
                end

                _aprintln(buf, "<tfoot>", il, ns; minify)
                foot_opened = true
                il += 1
            end

            # == Row Borders ===============================================================

            row_border_top    = ""
            row_border_bottom = ""

            if rs == :column_labels
                # The line before the column labels is only emitted when the table has a
                # title or subtitle. Otherwise, this line coincides with the top border of
                # the table.
                (
                    tf.horizontal_line_before_column_labels &&
                    (ps.i == 1) &&
                    (prev_rs == :table_header)
                ) && (row_border_top = tf.borders.header_line)

                (
                    tf.horizontal_line_after_column_labels &&
                    (ps.i == num_column_label_rows)
                ) && (row_border_bottom = tf.borders.header_line)

            elseif rs == :data
                # The line after the data rows is emitted at the last data row. If the
                # table is bottom cropped, the continuation row is the last row of this
                # section.
                (
                    (ps.i ∈ horizontal_lines_at_data_rows) ||
                    (tf.horizontal_line_after_data_rows && (ps.i == table_data.num_rows))
                ) && (row_border_bottom = tf.borders.middle_line)

            elseif rs == :continuation_row
                # The continuation row is the last row of the data section if the table is
                # bottom cropped. A middle-cropped table with at most one printed data row
                # also ends with the continuation row.
                (
                    tf.horizontal_line_after_data_rows && (
                        (table_data.vertical_crop_mode == :bottom) ||
                        (table_data.maximum_number_of_rows <= 1)
                    )
                ) && (row_border_bottom = tf.borders.middle_line)

            elseif rs == :row_group_label
                tf.horizontal_line_before_row_group_label &&
                    (row_border_top = tf.borders.middle_line)

                tf.horizontal_line_after_row_group_label &&
                    (row_border_bottom = tf.borders.middle_line)

            elseif rs == :summary_row
                (tf.horizontal_line_before_summary_rows && (ps.i == 1)) &&
                    (row_border_top = tf.borders.middle_line)

                (tf.horizontal_line_after_summary_rows && (ps.i == num_summary_rows)) &&
                    (row_border_bottom = tf.borders.middle_line)

            elseif rs == :table_footer
                # NOTE: This condition must mirror the one the printing state iterator uses
                # to decide whether it is emitting a footnote row or a source note row.
                (
                    tf.horizontal_line_after_footnotes &&
                    (ps.state < _FOOTNOTES) &&
                    !isnothing(table_data.footnotes) &&
                    (ps.i == num_footnotes)
                ) && (row_border_bottom = tf.borders.middle_line)
            end

            prev_rs = rs

            # == Row Class =================================================================

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
                # NOTE: This condition must mirror the one the printing state iterator uses
                # to decide whether it is emitting a footnote row or a source note row.
                # Otherwise, a table with source notes but without footnotes would tag its
                # source note rows with the `footnote` class.
                (ps.state < _FOOTNOTES) && !isnothing(table_data.footnotes) ?
                    "footnote" : "sourceNotes"
            else
                ""
            end
            push!(vproperties, "class" => class)

            empty!(vstyle)
            !isempty(row_border_top)    && push!(vstyle, "border-top"    => row_border_top)
            !isempty(row_border_bottom) && push!(vstyle, "border-bottom" => row_border_bottom)

            _aprintln(
                buf,
                _html__open_tag("tr"; properties = vproperties, style = vstyle),
                il,
                ns;
                minify,
            )
            il += 1

        elseif (action == :diagonal_continuation_cell) ||
            (action == :horizontal_continuation_cell) ||
            (action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS)
            # `vstyle` is a buffer reused across cells. Hence, it must be cleared here.
            # Otherwise, this cell would inherit the style of whatever cell was rendered
            # before it.
            empty!(vstyle)

            content = if action == :diagonal_continuation_cell
                "&dtdot;"
            elseif action == :horizontal_continuation_cell
                "&ctdot;"
            else
                alignment = _current_cell_alignment(action, ps, table_data)
                _html__add_alignment_to_style!(vstyle, alignment)
                "&vellip;"
            end

            tag = (action == :horizontal_continuation_cell) && (rs == :column_labels) ?
                "th" : "td"

            _aprintln(buf, _html__create_tag(tag, content; style = vstyle), il, ns; minify)

        elseif action == :end_row
            il -= 1
            _aprintln(buf, "</tr>", il, ns; minify)

        else
            empty!(vproperties)
            empty!(vstyle)

            cell = _current_cell(action, ps, table_data)

            cell === _IGNORE_CELL && continue

            # If we are in a column label, check for cell titles.
            if !isnothing(column_label_titles) && (action == :column_label)
                title = column_label_titles[ps.i]
                !isnothing(title) && push!(vproperties, "title" => string(title[ps.j]))
            end

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

                # The line under the merged cell is a border of the cell, which has
                # precedence over the border of the row when the table borders are
                # collapsed. If the row already has the same border at the bottom, we do
                # not need to push it. This border must be pushed before any other
                # decoration so that the latter can override it.
                (
                    tf.horizontal_line_at_merged_column_labels &&
                    (tf.borders.merged_header_cell_line != row_border_bottom)
                ) && push!(vstyle, "border-bottom" => tf.borders.merged_header_cell_line)

                rendered_cell = _html__render_cell(
                    cell.data, rctx, renderer; allow_html_in_cells, line_breaks
                )

                alignment = cell.alignment

                append!(
                    vstyle,
                    if ps.i == 1
                        style.first_line_merged_column_label
                    else
                        style.merged_column_label
                    end,
                )

            else
                rendered_cell = _html__render_cell(
                    cell, rctx, renderer; allow_html_in_cells, line_breaks
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
            if (action == :data) && !isempty(highlighters)
                for h in highlighters
                    if h.f(orig_data, ps.i, ps.j)
                        append!(
                            vstyle, _html__highlighter_decoration(h, orig_data, ps.i, ps.j)
                        )
                        break
                    end
                end
            end

            # Obtain the cell class and style.
            if action ∈ (:title, :subtitle, :row_group_label, :footnote, :source_notes)
                # These cells span the entire printed table.
                push!(vproperties, "colspan" => colspan_all)

                (action == :footnote) &&
                    (rendered_cell = "<sup>$(ps.i)</sup> " * rendered_cell)
            else
                push!(vproperties, "class" => _html__cell_class(action))
            end

            append!(vstyle, _html__cell_style(style, action, ps.i, ps.j))

            # Create the row tag with the content.
            row_tag = rs == :column_labels ? "th" : "td"
            _aprintln(
                buf,
                _html__create_tag(
                    row_tag, rendered_cell; properties = vproperties, style = vstyle
                ),
                il,
                ns;
                minify,
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

    if wrap_table_in_div
        il -= 1
        _aprintln(buf, _html__close_tag("div"), il, ns; minify)
    end

    if stand_alone
        _aprintln(
            buf,
            """
            </body>
            </html>""",
            il,
            ns;
            minify,
        )
    end

    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    if !pspec.new_line_at_end
        output_str = chomp(output_str)
    end

    # If we are printing to `stdout`, wrap the output in a `HTML` object.
    if is_stdout
        display(MIME("text/html"), HTML(output_str))
    else
        print(context, output_str)
    end

    return nothing
end
