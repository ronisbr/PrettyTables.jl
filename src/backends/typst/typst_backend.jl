# Typst back end of PrettyTables.jl
#
############################################################################################

function _typst__print(
    pspec::PrintingSpec;
    annotate::Bool = true,
    caption::Union{Nothing, AbstractString, TypstCaption} = nothing,
    data_column_widths::L = TypstLength(),
    highlighters::Vector{TypstHighlighter} = TypstHighlighter[],
    is_stdout::Bool = false,
    style::TypstTableStyle = TypstTableStyle(),
    wrap_column::Integer = 100,
) where {
    L <: Union{String, Vector{String}, Vector{Pair{Int64, String}}, AbstractTypstLength}
}
    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

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

    text_table_properties = map(_typst__filter_text_atributes(style.table)) do l
        occursin(r"text-", l[1]) ? replace(l[1], "text-" => "") => l[2] : l
    end

    if !isempty(text_table_properties)
        _aprintln(
            buf,
            _typst__call_function("set text"; properties = text_table_properties),
            il,
            ns
        )
    end

    # if we have a caption, we need to open a figure environment
    if !isnothing(caption)
        annotate && _aprintln(buf, "// Figure for table to add caption", il, ns)
        _aprintln(buf, "figure(", il, ns)
        il += 1
    end
    # Open the table component.
    annotate && _aprintln(buf, "// Open table", il, ns)
    _aprintln(buf, "table(", il, ns)
    il += 1

    columns = _typst__get_data_column_widths(
        data_column_widths,
        _number_of_printed_data_columns(table_data),
        _number_of_printed_columns(table_data),
    )

    _aprintln(buf, "columns: $columns,", il, ns)

    unused_table_properties = []
    for (k, s) in style.table
        if k ∉ _TYPST__TABLE_ATTRIBUTES && !occursin(r"text-", k)
            push!(unused_table_properties, k)
        elseif !occursin(r"text-", k)
            _aprintln(buf, "$k: $s,", il, ns)
        end
    end

    if !isempty(unused_table_properties)
        @warn "Unused table properties: " * join(unused_table_properties, ", ", " and ")
    end

    action = :initialize

    # Some internal states to help printing.
    head_opened = false
    body_opened = false

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        action == :end_printing && break

        # Obtain the next action since some actions depends on it.
        _, next_rs, _ = _next(ps, table_data)

        footnote = _current_cell_footnotes(table_data, action, ps.i, ps.j)

        append = if !isnothing(footnote) && !isempty(footnote)
            join(string.("#super[", footnote, "]"), ", ")
        end

        if action == :new_row
            if (ps.i == 1) && (rs ∈ (:table_header, :column_labels)) && !head_opened
                annotate && _aprintln(buf, "// Table Header", il, ns)
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
                annotate && _aprintln(buf, "// Body", il, ns)

                body_opened = true
            end
            annotate && _aprintln(buf, "// $rs Row $(ps.i)", il, ns)

            empty!(vproperties)

        elseif action == :diagonal_continuation_cell
            comp = _typst__create_component(
                "table.cell",
                _typst__create_component("#text", "⋱"; wrap_column);
                wrap_column,
            )

            _aprintln(buf, comp * ",", il, ns)

        elseif action == :horizontal_continuation_cell
            comp = _typst__create_component(
                "table.cell",
                _typst__create_component("#text", "⋯"; wrap_column);
                wrap_column,
            )

            _aprintln(buf, comp * ",", il, ns)

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            alignment = _current_cell_alignment(action, ps, table_data)

            comp = _typst__create_component(
                "table.cell",
                _typst__create_component("#text", "⋮"; wrap_column);
                wrap_column,
            )

            _aprintln(buf, comp * ",", il, ns)

        elseif action == :end_row
            # We need the print the omitted cell summary as soon as we enter the table
            # footer.
            if (!isempty(ocs) && next_rs ∈ (:table_footer, :end_printing) && !ocs_printed)
                cell_properties, text_properties =
                    _typst__cell_and_text_properties(style.omitted_cell_summary)

                open_comp = _typst__open_component(
                    "table.cell";
                    properties = _typst__merge_properties!(
                        cell_properties,
                        [
                            "align"   => "right",
                            "colspan" => string(_number_of_printed_columns(table_data)),
                            "inset"   => "(right: 0pt)",
                            "stroke"  => "none",
                        ]
                    ),
                    wrap_column
                )

                content_comp =  _typst__create_component(
                    "#text",
                    ocs;
                    properties = text_properties,
                    wrap_column
                )

                _aprintln(buf, open_comp,    il,     ns)
                _aprintln(buf, content_comp, il + 1, ns)

                _aprintln(buf, _typst__close_component() * ",", il, ns)

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

            # Obtain the cell alignment.
            _typst__add_alignment_to_properties!(vproperties, alignment)

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
            end

            # Obtain the cell properties.
            if action == :title
                push!(
                    vproperties,
                    "colspan" => string(_number_of_printed_columns(table_data))
                )
                _typst__merge_properties!(vproperties, style.title)

            elseif action == :subtitle
                push!(
                    vproperties,
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
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(left: 0pt)",
                    "stroke"  => "none"
                )
                _typst__merge_properties!(vproperties, style.footnote)

            elseif action == :source_notes
                # The source notes must be a cell that span the entire printed table.   
                push!(
                    vproperties,
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(left: 0pt)",
                    "stroke"  => "none"
                )
                _typst__merge_properties!(vproperties, style.source_note)
            end

            cell_properties, text_properties = _typst__cell_and_text_properties(vproperties)

            # Create the row component with the content.
            comp_prefix = action ∈ [:footnote] ? "#super[$(ps.i)]" : ""

            open_comp = _typst__open_component(
                "table.cell";
                properties = cell_properties,
                wrap_column
            )

            # If the type is `Markdown.MD` or if Typstry.jl is loaded and the cell is a
            # `TypstString`, we do not wrap it in a #text. Treat it as a raw Typst
            # component.
            content_payload = if (
                (cell isa Markdown.MD) ||
                (isdefined(Main, :TypstString) && (cell isa Main.TypstString))
            )
                rendered_cell
            else
                _typst__create_component(
                    "#text",
                    rendered_cell;
                    properties = text_properties,
                    wrap_column
                )
            end

            content_comp = comp_prefix * content_payload * something(append, "")

            if any([
                length(split(content_comp, '\n')) > 1,
                length(content_comp) + length(open_comp) > wrap_column,
            ])
                _aprintln(buf, open_comp,    il,     ns)
                _aprintln(buf, content_comp, il + 1, ns)

                _aprintln(buf, _typst__close_component() * ",", il, ns)
            else
                _aprint(buf, open_comp,    il, ns)
                _aprint(buf, content_comp,  0, ns)

                _aprintln(buf, _typst__close_component() * ",", 0, ns)
            end
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
            _aprint(buf, "$caption", il, ns)
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
