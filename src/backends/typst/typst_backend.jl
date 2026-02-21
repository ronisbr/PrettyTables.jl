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
    wrap_column::Integer = 92,
)
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # Check inputs.
    if data_column_widths isa Vector{String}
        nc = _number_of_printed_data_columns(table_data)
        length(data_column_widths) < nc &&
            throw(ArgumentError(
                "The length of `data_column_widths` must be equal to or larger than the number of printed columns ($nc)."
            ))

    elseif data_column_widths isa String
        data_column_widths = Base.Iterators.repeated(data_column_widths, table_data.num_columns)

    elseif data_column_widths isa Vector{Pair{Int, String}}
        dc = data_column_widths
        data_column_widths = Base.Generator(
            i -> begin
                id = findfirst(==(i), first.(dc))
                isnothing(id) && return "auto"
                return last(dc[id])
            end,
            1:table_data.num_columns
        )
    end

    # If `minify` is `true`, we do not wrap lines.
    if minify
        wrap_column = -1
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

    !isempty(unused_table_properties) && @warn (
        "Unused table properties: " * join(unused_table_properties, ", ", " and ")
    )

    action = :initialize

    # Some internal states to help printing.
    head_opened = false
    body_opened = false

    # This variable stores whether the first column of the current row is being printed. It
    # is used to simplify the logic when `minify` is `true`.
    first_column = false

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
            first_column = true

            if (ps.i == 1) && (rs ∈ (:table_header, :column_labels)) && !head_opened
                annotate && _aprintln_section_annotation(
                    buf,
                    "// == Table Header",
                    il,
                    ns,
                    wrap_column,
                    '='
                )

                _aprintln(buf, "table.header(", il, ns)
                il += 1
                head_opened = true

            elseif !body_opened && (
                ((ps.i == 1) && (rs ∈ (:data, :summary_row))) || (rs == :row_group_label)
            )
                if head_opened
                    il -= 1
                    _aprintln(buf, "),", il, ns)
                    head_opened = false
                end

                annotate && _aprintln_section_annotation(
                    buf,
                    "// == Table Body",
                    il,
                    ns,
                    wrap_column,
                    '='
                )

                body_opened = true
            end

            annotate && _aprintln_section_annotation(
                buf,
                "// -- " * _current_table_row_section_info(next_rs, next_action, ps.i),
                il,
                ns,
                wrap_column,
                '-'
            )

            empty!(vproperties)

            minify && print(buf, repeat(" ", il * ns))

        elseif action == :diagonal_continuation_cell
            cell_str = _typst__table_cell("⋱"; il, ns, wrap_column)
            _typst__print_cell(buf, cell_str, first_column, il, ns, minify)
            first_column = false

        elseif action == :horizontal_continuation_cell
            cell_str = _typst__table_cell("⋯"; il, ns, wrap_column)
            _typst__print_cell(buf, cell_str, first_column, il, ns, minify)
            first_column = false

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            cell_str = _typst__table_cell("⋮"; il, ns, wrap_column)
            _typst__print_cell(buf, cell_str, first_column, il, ns, minify)
            first_column = false

        elseif action == :end_row
            minify && println(buf)

            # We need the print the omitted cell summary as soon as we enter the table
            # footer.
            if (!isempty(ocs) && next_rs ∈ (:table_footer, :end_printing) && !ocs_printed)
                cell_properties, text_properties =
                    _typst__cell_and_text_properties(style.omitted_cell_summary)

                push!(
                    cell_properties,
                    "align"   => _typst__alignment(:r),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(right: 0pt)",
                    "stroke"  => "none",
                )

                cell_content = _typst__text(ocs, text_properties)
                cell_str = _typst__table_cell(
                    cell_content,
                    cell_properties;
                    il,
                    ns,
                    wrap_column
                )

                annotate && _aprintln_section_annotation(
                    buf,
                    "// -- Omitted Cell Summary",
                    il,
                    ns,
                    wrap_column,
                    '-'
                )

                _aprintln(buf, cell_str * ",", il, ns)

                ocs_printed = true
            end
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
                            _typst__merge_properties!(vproperties, h.fd(h, orig_data, ps.i, ps.j))
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
                    "colspan" => string(_number_of_printed_columns(table_data))
                )
                _typst__merge_properties!(vproperties, style.title)

            elseif action == :subtitle
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data))
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
                    "colspan" => string(_number_of_printed_columns(table_data))
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
                    "stroke"  => "none"
                )
                _typst__merge_properties!(vproperties, style.footnote)

            elseif action == :source_notes
                # The source notes must be a cell that span the entire printed table.   
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(left: 0pt)",
                    "stroke"  => "none"
                )
                _typst__merge_properties!(vproperties, style.source_note)
            end

            # Create the table cell.
            cell_properties, text_properties = _typst__cell_and_text_properties(vproperties)

            cell_prefix = action ∈ [:footnote] ? "#super[$(ps.i)]" : ""

            # If the type is `Markdown.MD` or if Typstry.jl is loaded and the cell is a
            # `TypstString`, we do not wrap it in a #text. Treat it as a raw Typst
            # component.
            cell_content = if (
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
                wrap_column
            )

            _typst__print_cell(buf, cell_str, first_column, il, ns, minify)
            first_column = false
        end
    end

    # Close the section that was left opened.
    if head_opened
        il -= 1
        _aprintln(buf, "),", il, ns)
    end

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
