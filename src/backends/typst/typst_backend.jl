## Description #############################################################################
#
# Typst back end of PrettyTables.jl
#
############################################################################################

function _typst__print(
    pspec::PrintingSpec;
    caption::Union{Nothing, AbstractString} = nothing,
    color = nothing,
    column_label_titles::Union{Nothing, AbstractVector} = nothing,
    data_column_widths:: L = TypstLength(),
    highlighters::Vector{TypstHighlighter} = TypstHighlighter[],
    is_stdout::Bool = false,
    style::TypstTableStyle = TypstTableStyle(),
    top_left_string::AbstractString = "",
    wrap_column ::Integer = 100,
    annotate=true,
) where L <: Union{String, Vector{String}, Vector{Pair{Int64, String}},AbstractTypstLength}

    context    = pspec.context
    table_data = pspec.table_data
    renderer   = Val(pspec.renderer)

    ps     = PrintingTableState()
    buf_io = IOBuffer()
    buf    = IOContext(buf_io, context)

    # Create dictionaries to store properties and styles to decrease the number of
    # allocations.
    vproperties = Pair{String, String}[]
    vstyle      = Pair{String, String}[]

    # Check the dimensions of header cell titles.
    if !isnothing(column_label_titles)
        num_column_label_rows = length(table_data.column_labels)

        if length(column_label_titles) < num_column_label_rows
            error("The number of vectors in `column_label_titles` must be equal or greater than that in `column_labels`.")
        end

        for k in eachindex(column_label_titles)
            if (
                !isnothing(column_label_titles[k]) &&
                (length(column_label_titles[k]) != table_data.num_columns)
            )
                error("The number of elements in each row of `column_label_titles` must match the number of columns in the table.")
            end
        end
    end

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # -- Top Bar ---------------------------------------------------------------------------

    _aprintln(buf, "#{", il, ns)
    il += 1

    # Check if the user wants the omitted cell summary.
    ocs = _omitted_cell_summary(table_data, pspec)
    top_right_string = ocs

    # Print the top bar if necessary.
    if !isempty(top_left_string) || !isempty(top_right_string)
        # Top left section.
        annotate && _aprintln(buf,"// Top bar", il, ns)

        _aprintln(buf, "set par(justify: true, spacing: 1em)", il, ns)

        if !isempty(top_left_string)
            _aprintln(
                buf,
                _typst__create_component("align", top_left_string, args=["top+left"]),
                il,
                ns
            )
        end
        # Top right section.
        if !isempty(top_right_string)
            !isempty(top_left_string) && _aprintln(buf, "v(-1.5em)", il, ns)

            _aprintln(
                buf,
                _typst__create_component("align", top_right_string; args = ["top+right"]),
                il,
                ns
            )
        end

        # We need to clear the floats so that the table is rendered below the top bar.
        empty!(vstyle)
    end

    # == Table =============================================================================

    empty!(vproperties)

    # if we have a caption, we need to open a figure environment
    if !isnothing(caption)
        annotate && _aprintln(buf,"// Figure for table to add caption", il, ns)
        _aprintln(
            buf,
            "figure(",
            il,
            ns
        )
        il += 1
    end
    # Open the table component.
    annotate && _aprintln(buf,"// Open table", il, ns)
    _aprintln(
        buf,
        "table(",
        il,
        ns
    )
    il += 1

    columns = _typst__get_data_column_widths(
        data_column_widths,
        _number_of_printed_data_columns(table_data),
        _number_of_printed_columns(table_data),
    )

    _aprintln(buf, "columns: $columns,", il, ns)

    map(style.table) do (k, s)
        if occursin(r"^[0-9]", s) || k ∉ _TYPST__STRING_ATTRIBUTES
            _aprintln(buf, "$k:$s,", il, ns)
        else
            _aprintln(buf, "$k:\"$s\",", il, ns)
        end
    end

    action = :initialize

    # Some internal states to help printing.
    head_opened = false
    body_opened = false

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        action == :end_printing && break

        footnote = _current_cell_footnotes(table_data, action, ps.i, ps.j)
        append = if !isnothing(footnote) && !isempty(footnote)
            join(string.("#super[", footnote, "]"), ", ")
        end

        if action == :new_row
            if (ps.i == 1) && (rs ∈ (:table_header, :column_labels)) && !head_opened
                annotate && _aprintln(buf,"// Table Header", il, ns)
                _aprintln(buf, "table.header(", il, ns)
                il +=1
                head_opened = true

            elseif !body_opened && (
                ((ps.i == 1) && (rs ∈ (:data, :summary_row))) ||
                (rs == :row_group_label)
            )
                if head_opened
                    il -= 1
                    _aprintln(buf, "),", il, ns)
                    head_opened = false
                end
                annotate && _aprintln(buf,"// Body", il, ns)

                body_opened = true
            end
            annotate && _aprintln(buf, "// $rs Row $(ps.i)", il, ns)

            empty!(vproperties)


        elseif action == :diagonal_continuation_cell
            comp = _typst__create_component(
                "table.cell",
                _typst__create_component("#text", " ⋱ "; wrap_column); 
                wrap_column
            )

            _aprintln(buf, comp * ",", il, ns)

        elseif action == :horizontal_continuation_cell
            comp = _typst__create_component(
                "table.cell",
                _typst__create_component("#text", " ⋯ "; wrap_column);
                wrap_column
            )

            _aprintln(buf, comp * ",", il, ns)

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            # Obtain the cell style.
            empty!(vstyle)
            alignment = _current_cell_alignment(action, ps, table_data)

            comp = _typst__create_component(
                "table.cell",
                _typst__create_component("#text", "  ⋮ "; wrap_column); 
                wrap_column
            )

            _aprintln(buf, comp * ",", il, ns)

        elseif action == :end_row
            # _aprintln(buf, "// $rs", il, ns)
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
                rendered_cell = _typst__render_cell(
                    cell.data,
                    buf,
                    renderer
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
                rendered_cell = _typst__render_cell(
                    cell,
                    buf,
                    renderer
                )

                alignment = _current_cell_alignment(action, ps, table_data)
            end

            # Obtain the cell alignment.
            _typst__add_alignment_to_style!(vstyle, alignment)

            # If we are in a data cell, we must check for highlighters.
            if action == :data
                orig_data = _get_data(table_data.data)

                if !isnothing(highlighters)
                    for h in highlighters
                        if h.f(orig_data, ps.i, ps.j)
                            _typst__merge_style!(vstyle, h.fd(h, orig_data, ps.i, ps.j))
                            break
                        end
                    end
                end
            end

            # Obtain the cell class and style.

            if action == :title
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                _typst__merge_style!(vstyle, style.title)

            elseif action == :subtitle
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                _typst__merge_style!(vstyle, style.subtitle)

            elseif action == :row_number_label
                _typst__merge_style!(vstyle, style.row_number_label)

            elseif action == :row_number
                _typst__merge_style!(vstyle, style.row_number)

            elseif action == :summary_row_number
                _typst__merge_style!(vstyle, style.row_number)

            elseif action == :stubhead_label
                _typst__merge_style!(vstyle, style.stubhead_label)

            elseif action == :row_group_label
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                _typst__merge_style!(vstyle, style.row_group_label)

            elseif action == :row_label
                _typst__merge_style!(vstyle, style.row_label)
 
            elseif action == :summary_row_label
                _typst__merge_style!(vstyle, style.summary_row_label)

            elseif action == :column_label
                if ps.i == 1
                    _typst__merge_style!(
                        vstyle,
                        if style.first_line_column_label isa Vector{Vector{TypstPair}}
                            style.first_line_column_label[ps.j]
                        else
                            style.first_line_column_label
                        end
                    )
                else
                    _typst__merge_style!(
                        vstyle,
                        if style.column_label isa Vector{Vector{TypstPair}}
                            style.column_label[ps.j]
                        else
                            style.column_label
                        end
                    )
                end

            elseif action == :summary_row_cell
                _typst__merge_style!(vstyle, style.summary_row_cell)

            elseif action == :footnote
                # The footnote must be a cell that span the entire printed table.
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                _typst__merge_style!(vstyle, style.footnote)

            elseif action == :source_notes
                # The source notes must be a cell that span the entire printed table.   
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                _typst__merge_style!(vstyle, style.source_note)
            end

            # Separate cell and text attributes.
            filter_cell_attributes = filter(x -> x[1] ∈ _TYPST__CELL_ATTRIBUTES)

            cell_style = _typst__merge_style!(
                filter_cell_attributes(vstyle),
                filter_cell_attributes(vproperties)
            )
            
            # Build the text style.
            text_style = map(
                    _typst__merge_style!(
                        _typst__filter_text_atributes(vstyle),
                        _typst__filter_text_atributes(vproperties)
                    )
                ) do l
                occursin(r"text-", l[1]) ? replace(l[1], "text-" => "") => l[2] : l
            end
            
            # Create the row component with the content.
            comp_prefix = action ∈ [:footnote] ? "#super[$(ps.i)]" : ""
            open_comp=_typst__open_component(
                "table.cell"; 
                properties = cell_style, 
                wrap_column, 
            )
            content_comp = comp_prefix *
                _typst__create_component("#text", rendered_cell; properties = text_style, wrap_column) *
                something(append, "")
            
            if any([
                    length(split(content_comp,"\n")) > 1, 
                    length(content_comp)+length(open_comp) > wrap_column
                ]) 
                _aprintln(buf, open_comp, il, ns)
                _aprintln(buf, content_comp, il+1, ns)
                _aprintln(buf,_typst__close_component()*",",il, ns)
            else
                _aprint(buf, open_comp, il, ns)
                _aprint(buf, content_comp, 0, ns)
                _aprintln(buf,_typst__close_component()*",",0, ns)
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
        _aprintln(buf, "caption: \"$caption\"", il, ns)
        il -= 1
    end
    _aprintln(buf, ")", il, ns)
    il -=1
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


