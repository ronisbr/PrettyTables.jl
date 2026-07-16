## Description #############################################################################
#
# Typst back end of PrettyTables.jl
#
############################################################################################

function _typst__print(
    pspec::PrintingSpec;
    annotate::Bool = true,
    caption::Union{Nothing, String, TypstCaption} = nothing,
    data_column_widths::Union{Nothing, String, Vector{String}, Vector{Pair{Int, String}}} = nothing,
    highlighters::Vector{TypstHighlighter} = TypstHighlighter[],
    is_stdout::Bool = false,
    minify::Bool = false,
    style::TypstTableStyle = TypstTableStyle(),
    table_format::TypstTableFormat = TypstTableFormat(),
    wrap_column::Integer = 92,
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)
    tf         = table_format

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    buf_hlines = IOBuffer()
    buf_tc     = IOBuffer()

    # Check inputs.
    if data_column_widths isa Vector{String}
        nc = _number_of_printed_data_columns(table_data)
        length(data_column_widths) < nc && throw(
            ArgumentError(
                "The length of `data_column_widths` must be equal to or larger than the number of printed columns ($nc).",
            ),
        )

    elseif data_column_widths isa String
        data_column_widths = Base.Iterators.repeated(
            data_column_widths, table_data.num_columns
        )

    elseif data_column_widths isa Vector{Pair{Int, String}}
        dc = data_column_widths
        data_column_widths = Base.Generator(
            i -> begin
                id = findfirst(==(i), first.(dc))
                isnothing(id) && return "auto"
                return last(dc[id])
            end, 1:(table_data.num_columns)
        )
    end

    # If `minify` is `true`, we do not wrap lines.
    if minify
        wrap_column = -1
    end

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

    # Create dictionaries to store properties to decrease the number of allocations.
    vproperties = Pair{String, String}[]

    # Check if the user wants the omitted cell summary.
    ocs = _omitted_cell_summary(table_data, pspec)
    ocs_printed = false

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # == Table =============================================================================

    _aprintln(buf, "#{", il, ns)
    il += 1

    empty!(vproperties)

    _, table_text_properties = _typst__cell_and_text_properties(style.table)

    if !isempty(table_text_properties)
        prop_str = _typst__property_list(table_text_properties)
        _aprintln(buf, "set text($prop_str)", il, ns)
    end

    # If we have a caption, we need to open a figure environment.
    if !isnothing(caption)
        _aprintln(buf, "figure(", il, ns)
        il += 1
    end

    # Open the table component.
    _aprintln(buf, "table(", il, ns)
    il += 1

    alignment_str = _typst__alignment_configuration(table_data)
    _aprintln(buf, "align: ($alignment_str),", il, ns)

    columns = _typst__get_data_column_widths(table_data, data_column_widths)

    _aprintln(buf, "columns: $columns,", il, ns)
    _aprintln(buf, "stroke: none,", il, ns)

    unused_table_properties = String[]

    for (k, s) in style.table
        if !startswith(k, "text-")
            if k ∉ _TYPST__TABLE_ATTRIBUTES
                push!(unused_table_properties, k)
                continue
            end

            _aprintln(buf, "$k: $s,", il, ns)
        end
    end

    !isempty(unused_table_properties) &&
        @warn ("Unused table properties: " * join(unused_table_properties, ", ", " and "))

    action = :initialize

    # Some internal states to help printing.
    head_opened = false
    body_opened = false

    # This variable stores whether the first column of the current row is being printed. It
    # is used to simplify the logic when `minify` is `true`.
    first_column = false

    # This variable stores where a merged column label begins and ends. Hence, we are able
    # to draw a line after them if the user wants.
    merged_column_labels = Tuple{Int, Int}[]

    # This variable stores the current line in Typst. It is used to print the horizontal
    # lines in the right place.
    current_typst_line = 1

    table_lines = 0

    # This variable stores the indentation level to print the horizontal lines.
    il_table  = il
    hline_pad = " "^max(il_table * ns, 0)

    # This variable is used to check if we are printing the first line of the table. It is
    # used to check if we need to print the horizontal line at the beginning of the table.
    first_table_line = true

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        action == :end_printing && break

        # Obtain the next action since some actions depends on it.
        next_action, next_rs, _ = _next(ps, table_data)

        footnote = _current_cell_footnotes(table_data, action, ps.i, ps.j)

        append = if !isnothing(footnote) && !isempty(footnote)
            join(string.("#super[", footnote, "]"), ", ")
        end

        if action == :new_row
            empty!(merged_column_labels)
            first_column = true

            # If we are in the very first row after the title section, we need to check if
            # the user wants a vertical line before the table.
            if (rs != :table_header) && first_table_line && tf.horizontal_line_at_beginning
                # Using only one argument in `print` to avoid intermediate string
                # allocations.
                @_println(
                    buf_hlines,
                    hline_pad,
                    "table.hline(y: ",
                    current_typst_line - 1,
                    ", stroke: ",
                    tf.borders.top_line,
                    ",),"
                )
                first_table_line = false
            end

            if (ps.i == 1) && (rs ∈ (:table_header, :column_labels)) && !head_opened
                annotate && _aprintln_section_annotation(
                    buf_tc, "// == Table Header", il, ns, wrap_column, '='
                )

                _aprintln(buf_tc, "table.header(", il, ns)
                il += 1
                head_opened = true

            elseif !body_opened && (
                ((ps.i == 1) && (rs ∈ (:data, :summary_row))) || (rs == :row_group_label)
            )
                if head_opened
                    il -= 1
                    _aprintln(buf_tc, "),", il, ns)
                    head_opened = false
                end

                annotate && _aprintln_section_annotation(
                    buf_tc, "// == Table Body", il, ns, wrap_column, '='
                )

                body_opened = true
            end

            annotate && _aprintln_section_annotation(
                buf_tc,
                "// -- " * _current_table_row_section_info(next_rs, next_action, ps.i),
                il,
                ns,
                wrap_column,
                '-',
            )

            empty!(vproperties)

            minify && print(buf_tc, repeat(" ", il * ns))

        elseif action == :diagonal_continuation_cell
            cell_str = _typst__table_cell("⋱"; il, ns, wrap_column)
            _typst__print_cell(buf_tc, cell_str, first_column, il, ns, minify)
            first_column = false

        elseif action == :horizontal_continuation_cell
            cell_str = _typst__table_cell("⋯"; il, ns, wrap_column)
            _typst__print_cell(buf_tc, cell_str, first_column, il, ns, minify)
            first_column = false

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            cell_str = _typst__table_cell("⋮"; il, ns, wrap_column)
            _typst__print_cell(buf_tc, cell_str, first_column, il, ns, minify)
            first_column = false

        elseif action == :end_row
            minify && println(buf_tc)

            if rs ∈
                (:column_labels, :data, :row_group_label, :continuation_row, :summary_row)
                table_lines += 1
            end

            # == Handle the Horizontal Lines ===============================================

            hline  = ""
            stroke = ""

            # Print the horizontal line after the column labels.
            if (rs == :table_header) &&
                (next_rs != :table_header) &&
                tf.horizontal_line_at_beginning
                hline  = "y: $(current_typst_line)"
                stroke = tf.borders.top_line

                first_table_line = false

            elseif (rs == :column_labels)
                if ps.row_section == :column_labels
                    if tf.horizontal_line_at_merged_column_labels
                        # The specification in `merged_column_labels` refers to the data
                        # columns. Hence, we need to add the offset regarding the previous
                        # columns if they exist.
                        Δc = table_data.show_row_number_column + _has_row_labels(table_data)
                        for m in merged_column_labels
                            c₀ = Δc + m[1] - 1
                            c₁ = Δc + m[2]

                            hline  = "y: $current_typst_line, start: $c₀, end: $c₁"
                            stroke = tf.borders.merged_header_cell_line
                        end
                    end

                elseif tf.horizontal_line_after_column_labels
                    hline  = "y: $(current_typst_line)"
                    stroke = tf.borders.header_line
                end

                # Check if the next line is a row group label and the user request a line before
                # it.
            elseif (next_rs == :row_group_label) &&
                tf.horizontal_line_before_row_group_label
                hline  = "y: $(current_typst_line)"
                stroke = tf.borders.middle_line

                # Check if we must print an horizontal line after the current data row.
            elseif (rs == :data) && (ps.i ∈ horizontal_lines_at_data_rows)
                hline  = "y: $(current_typst_line)"
                stroke = tf.borders.middle_line

            elseif (
                (rs ∈ (:data, :continuation_row)) &&
                (next_rs ∈ (:summary_row, :table_footer, :end_printing)) &&
                tf.horizontal_line_after_data_rows
            )
                hline  = "y: $(current_typst_line)"
                stroke = tf.borders.middle_line

            elseif (
                (rs ∈ (:data, :continuation_row)) &&
                (next_rs == :summary_row) &&
                tf.horizontal_line_before_summary_rows
            )
                hline  = "y: $(current_typst_line)"
                stroke = tf.borders.middle_line

            elseif (rs == :row_group_label) && tf.horizontal_line_after_row_group_label
                hline  = "y: $(current_typst_line)"
                stroke = tf.borders.middle_line

                # Check if the must print the horizontal line at the end of the table.
            elseif (rs == :summary_row) &&
                (next_rs != :summary_row) &&
                tf.horizontal_line_after_summary_rows
                hline  = "y: $(current_typst_line)"
                stroke = tf.borders.middle_line
            end

            # If the next section if the end of the table and we need to draw a horizontal
            # line, we should change it to the bottom line.
            if next_rs ∈ (:table_footer, :end_printing) && !isempty(hline)
                stroke = tf.borders.bottom_line
            end

            !isempty(hline) && @_println(
                buf_hlines,
                hline_pad,
                "table.hline(",
                hline,
                ", stroke: ",
                stroke,
                ",),"
            )

            # == Omitted Cell Summary ======================================================

            # We need the print the omitted cell summary as soon as we enter the table
            # footer.
            if (!isempty(ocs) && next_rs ∈ (:table_footer, :end_printing) && !ocs_printed)
                cell_properties, text_properties = _typst__cell_and_text_properties(
                    style.omitted_cell_summary
                )

                push!(
                    cell_properties,
                    "align"   => _typst__alignment(:r),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(right: 0pt)",
                    "stroke"  => "none",
                )

                cell_content = _typst__text(ocs, text_properties)
                cell_str = _typst__table_cell(
                    cell_content, cell_properties; il, ns, wrap_column
                )

                annotate && _aprintln_section_annotation(
                    buf_tc, "// -- Omitted Cell Summary", il, ns, wrap_column, '-'
                )

                _aprintln(buf_tc, cell_str * ",", il, ns)

                ocs_printed = true
            end

            current_typst_line += 1
        else
            empty!(vproperties)

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

                push!(merged_column_labels, (ps.j, ps.j + cs - 1))

                push!(vproperties, "colspan" => string(cs))
                rendered_cell = _typst__render_cell(cell.data, buf, renderer)

                alignment = cell.alignment

                append!(
                    vproperties,
                    if ps.i == 1
                        style.first_line_merged_column_label
                    else
                        style.merged_column_label
                    end,
                )

            else
                rendered_cell = _typst__render_cell(cell, buf, renderer)

                alignment = _current_cell_alignment(action, ps, table_data)
            end

            # If we are in a data cell, we must check for highlighters.
            if action == :data
                orig_data = _get_data(table_data.data)

                if !isnothing(highlighters)
                    for h in highlighters
                        if h.f(orig_data, ps.i, ps.j)
                            _typst__merge_properties!(
                                vproperties, h.fd(h, orig_data, ps.i, ps.j)
                            )
                            break
                        end
                    end
                end

                (alignment != _data_column_alignment(table_data, ps.j)) &&
                    push!(vproperties, "align" => _typst__alignment(alignment))
            end

            # Obtain the cell properties.
            if action == :title
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                )
                _typst__merge_properties!(vproperties, style.title)

            elseif action == :subtitle
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                )
                _typst__merge_properties!(vproperties, style.subtitle)

            elseif action == :row_number_label
                _typst__merge_properties!(vproperties, style.row_number_label)

            elseif action == :row_number
                _typst__merge_properties!(vproperties, style.row_number)

            elseif action == :summary_row_number
                _typst__merge_properties!(vproperties, style.row_number)

            elseif action == :stubhead_label
                _typst__merge_properties!(vproperties, style.stubhead_label)

            elseif action == :row_group_label
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                )
                _typst__merge_properties!(vproperties, style.row_group_label)

            elseif action == :row_label
                _typst__merge_properties!(vproperties, style.row_label)

            elseif action == :summary_row_label
                _typst__merge_properties!(vproperties, style.summary_row_label)

            elseif action == :column_label
                if ps.i == 1
                    _typst__merge_properties!(
                        vproperties,
                        if style.first_line_column_label isa Vector{Vector{TypstPair}}
                            style.first_line_column_label[ps.j]
                        else
                            style.first_line_column_label
                        end,
                    )
                else
                    _typst__merge_properties!(
                        vproperties,
                        if style.column_label isa Vector{Vector{TypstPair}}
                            style.column_label[ps.j]
                        else
                            style.column_label
                        end,
                    )
                end

            elseif action == :summary_row_cell
                _typst__merge_properties!(vproperties, style.summary_row_cell)

            elseif action == :footnote
                # The footnote must be a cell that span the entire printed table.
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(left: 0pt)",
                    "stroke"  => "none",
                )
                _typst__merge_properties!(vproperties, style.footnote)

            elseif action == :source_notes
                # The source notes must be a cell that span the entire printed table.   
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(left: 0pt)",
                    "stroke"  => "none",
                )
                _typst__merge_properties!(vproperties, style.source_note)
            end

            # Create the table cell.
            cell_properties, text_properties = _typst__cell_and_text_properties(vproperties)

            cell_prefix = action ∈ [:footnote] ? "#super[$(ps.i)]" : ""

            # If the type is `Markdown.MD` or if Typstry.jl is loaded and the cell is a
            # `TypstString`, we do not wrap it in a #text. Treat it as a raw Typst
            # component.
            cell_content =
                if (
                    (cell isa Markdown.MD) ||
                    (isdefined(Main, :TypstString) && (cell isa Main.TypstString))
                )
                    rendered_cell
                else
                    _typst__text(rendered_cell, text_properties)
                end

            cell_str = _typst__table_cell(
                cell_prefix * cell_content * something(append, ""),
                cell_properties;
                il,
                ns,
                wrap_column,
            )

            _typst__print_cell(buf_tc, cell_str, first_column, il, ns, minify)
            first_column = false
        end
    end

    # Close the section that was left opened.
    if head_opened
        il -= 1
        _aprintln(buf_tc, "),", il, ns)
    end

    # Join the horizontal and vertical lines with the table content.
    annotate && _aprintln_section_annotation(
        buf, "// == Horizontal Lines", il_table, ns, wrap_column, '='
    )

    write(buf, take!(buf_hlines))

    annotate && _aprintln_section_annotation(
        buf, "// == Vertical Lines", il_table, ns, wrap_column, '='
    )

    _typst__vertical_lines!(
        buf, table_data, tf, table_lines, vertical_lines_at_data_columns, il_table, ns
    )

    write(buf, take!(buf_tc))

    il -= 1

    if !isnothing(caption)
        _aprintln(buf, "),", il, ns)

        if caption isa AbstractString
            _aprintln(buf, "caption: \"$caption\",", il, ns)
            _aprintln(buf, "kind: auto,", il, ns)
        elseif caption isa TypstCaption
            _aprint(buf, _typst__process_caption(caption, il), il, ns)
        end

        il -= 1
    end

    _aprintln(buf, ")", il, ns)
    il -= 1

    _aprintln(buf, "}", il, ns)
    il -= 1

    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    # If we are printing to `stdout`, wrap the output in a `String` object.
    if is_stdout && isdefined(Main, :Typst)
        display("image/png", (Main.Typst ∘ Main.TypstText)(output_str))
    else
        print(context, output_str)
    end

    return nothing
end
