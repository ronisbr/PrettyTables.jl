## Description #############################################################################
#
# HTML back end of PrettyTables.jl
#
############################################################################################
function _typst__print(
    pspec::PrintingSpec;
    column_label_titles::Union{Nothing, AbstractVector} = nothing,
    highlighters::Vector{TypstHighlighter} = TypstHighlighter[],
    is_stdout::Bool = false,
    columns_width::Union{Nothing,String,Vector{String}, Vector{Pair{Int64,String}}} = nothing,
    top_left_string::AbstractString = "",
    color = nothing,
    style::TypstTableStyle = TypstTableStyle(),
    caption::Union{Nothing,AbstractString} = nothing,
)
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

    # == Print HTML Header =================================================================

    # == Top Bar ===========================================================================

    # Check if the user wants the omitted cell summary.
    ocs = _omitted_cell_summary(table_data, pspec)
    top_right_string = ""
    if !isempty(ocs)
        top_right_string = ocs
    end

    # top_right_string = if !isempty(ocs)
    #     top_right_string = ocs
    # else 
    #     []
    # end

    # Print the top bar if necessary.
    if !isempty(top_left_string) || !isempty(top_right_string)
        # Top left section.
        if !isempty(top_left_string)
          _aprintln(
              buf,
              _typst__create_component("#align",top_left_string,args = ["top+left"]),
              il,
              ns;
              
          )
        end

        # Top right section.
        if !isempty(top_right_string)
          _aprintln(
              buf,
              _typst__create_component("#align",top_right_string,args = ["top+right"]),
              il,
              ns;
              
          )
        end

        # We need to clear the floats so that the table is rendered below the top bar.
        empty!(vstyle)
        push!(vstyle, "clear" => "both")

    end

    # == Table =============================================================================

    empty!(vproperties)
    _aprintln(buf,"#{", il,ns)
    il += 1
    if !isnothing(caption)
      _aprintln(
          buf,
          "figure(",
          il,
          ns;
          
      )
      il += 1
    end
    _aprintln(
        buf,
        "table(",
        il,
        ns;
        
    )
    il += 1
    num_columns = _number_of_printed_columns(table_data)
    columns = _typst__get_columns_widths(columns_width, num_columns)
    _aprintln(buf,"columns: $columns, ",il,ns;)
    map(style.table) do (k,s)
        if occursin(r"^[0-9]",s) || k ∉ _TYPST_STRING_ATTRIBUTES
            _aprintln(buf,"$k:$s, ", il, ns)
        else
            _aprintln(buf,"$k:\"$s\", ", il, ns)
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
            join(string.("#super[",footnote,"]"),", ")

        end

        if action == :new_row
            if (ps.i == 1) && (rs ∈ (:table_header, :column_labels)) && !head_opened
                _aprintln(buf, "table.header(", il, ns; )
                il += 1
                head_opened = true

            elseif !body_opened && (
                    ((ps.i == 1) && (rs ∈ (:data, :summary_row))) ||
                    (rs == :row_group_label)
                )

                if head_opened
                    il -= 1
                    _aprintln(buf, "), ", il, ns; )
                    il -= 1
                    head_opened = false
                end

                body_opened = true

            end

            empty!(vproperties)

            il += 1
            
        elseif action == :diagonal_continuation_cell
            _aprint(
                buf,
                _typst__create_component("table.cell", _typst__create_component("#text"," ⋱ ")) * ",",
                0,
                ns;
            )
        elseif action == :horizontal_continuation_cell
            _aprint(buf, _typst__create_component("table.cell", _typst__create_component("#text"," ⋯ ")) * ",", 0, ns; )

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            # Obtain the cell style.
            empty!(vstyle)
            alignment = _current_cell_alignment(action, ps, table_data)

            _aprint( buf,
                _typst__create_component("table.cell", _typst__create_component("#text","  ⋮ "))*",", 
                ps.j ==1 ? il : 0,
                ns;
            )

        elseif action == :end_row
            il -= 1
            _aprintln(buf, "", il, ns; )

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
                    renderer;
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
                    renderer;
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
                            merge_style!(vstyle, h.fd(h, orig_data, ps.i, ps.j))
                            break
                        end
                    end
                end
            end

            # Obtain the cell class and style.

            if action == :title
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                merge_style!(vstyle, style.title)

            elseif action == :subtitle
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                merge_style!(vstyle, style.subtitle)

            elseif action == :row_number_label
                push!(vproperties, "class" => "rowNumberLabel")
                merge_style!(vstyle, style.row_number_label)

            elseif action == :row_number
                push!(vproperties, "class" => "rowNumber")
                merge_style!(vstyle, style.row_number)

            elseif action == :summary_row_number
                push!(vproperties, "class" => "summaryRowNumber")
                merge_style!(vstyle, style.row_number)

            elseif action == :stubhead_label
                push!(vproperties, "class" => "stubheadLabel")
                merge_style!(vstyle, style.stubhead_label)

            elseif action == :row_group_label
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                merge_style!(vstyle, style.row_group_label)

            elseif action == :row_label
                push!(vproperties, "class" => "rowLabel")
                merge_style!(vstyle, style.row_label)

            elseif action == :summary_row_label
                push!(vproperties, "class" => "summaryRowLabel")
                merge_style!(vstyle, style.summary_row_label)

            elseif action == :column_label
                if ps.i == 1
                    merge_style!(
                        vstyle,
                        if style.first_line_column_label isa Vector{Vector{HtmlPair}}
                            style.first_line_column_label[ps.j]
                        else
                            style.first_line_column_label
                        end
                    )
                else
                    merge_style!(
                        vstyle,
                        if style.column_label isa Vector{Vector{HtmlPair}}
                            style.column_label[ps.j]
                        else
                            style.column_label
                        end
                    )
                end

            elseif action == :summary_row_cell
                merge_style!(vstyle, style.summary_row_cell)

            elseif action == :footnote
                # The footnote must be a cell that span the entire printed table.
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                merge_style!(vstyle, style.footnote)
            #     rendered_cell = "#super[$(ps.i)] " * rendered_cell



            elseif action == :source_notes
                # The source notes must be a cell that span the entire printed table.
                push!(vproperties, "colspan" => string(_number_of_printed_columns(table_data)))
                merge_style!(vstyle, style.source_note)

            else
                push!(vproperties, "class" => "")
            end
            
            cell_attributes = ["colspan", "rowspan", "inset", "align", "fill", "stroke", "breakable"]
            filter_cell_attributes=filter(x-> x[1] ∈ cell_attributes)
            cell_style = merge_style!(filter_cell_attributes(vstyle),filter_cell_attributes(vproperties))
            # unique!(x->x[1],cell_style)
            text_attributes = ["font", "fallback", "style", "weight", "stretch", "size", "tracking", "spacing", "cjk-latin-spacing", "baseline", "overhang", "top-edge", "bottom-edge", "lang", "region", "script", "dir", "hyphenate", "costs", "kerning", "alternates", "stylistic-set", "ligatures", "discretionary-ligatures", "historical-ligatures", "number-type", "number-width", "slashed-zero", "fractions", "features",]              
            filter_text_atributes = filter(x-> x[1] ∈ text_attributes || occursin(r"text-",x[1]))

            text_style = map(merge_style!(filter_text_atributes(vstyle),filter_text_atributes(vproperties))) do l
                occursin(r"text-",l[1]) ? replace(l[1],"text-"=>"") =>l[2] : l
            end
            # unique!(x->x[1], text_style)

            # Create the row component with the content.
            _aprint(
                buf,
                _typst__create_component(
                    "table.cell",
                    (action ∈ [:footnote] ? "#super[$(ps.i)]" : "")*_typst__create_component("#text",rendered_cell, properties= text_style)*something(append,"");
                    properties = cell_style,
                )*",",
                ps.j==0 || (ps.j==1 && !table_data.show_row_number_column) || action ∈ [:footnote,:source_notes] ? il : 0,
                ns;
            )
        end
    end

    # Close the section that was left opened.
    if head_opened
        il -= 1
        _aprintln(buf, "),", il, ns; )
    end

    _aprintln(buf, ")", il, ns; )
    il -= 1

    if !isnothing(caption)
      _aprintln(buf, """, caption: "$caption")""", 0,ns; )
      il -= 1
    end
    _aprintln(buf,"}", il,ns)
    il -= 1
    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    if !pspec.new_line_at_end
        output_str = chomp(output_str)
    end

    # If we are printing to `stdout`, wrap the output in a `String` object.
    if is_stdout && isdefined(Main,:Typst) 
        display("image/png",(Main.Typst ∘ Main.TypstText)(output_str))
    else
        print(context, output_str)
    end

    return nothing
end


function merge_style!(bstyle,nstyle)
    filter!(bstyle) do l
        l[1] ∉ map(first,nstyle)
    end
    append!(bstyle,nstyle)
    bstyle
end