## Description #############################################################################
#
# Typst back end of PrettyTables.jl
#
############################################################################################

# Default style and format, created once because constructing them allocates.
const _DEFAULT_TYPST_TABLE_STYLE  = TypstTableStyle()
const _DEFAULT_TYPST_TABLE_FORMAT = TypstTableFormat()

############################################################################################
#                                      Print Options                                       #
############################################################################################

"""
    struct TypstPrintOptions

Options of the Typst back end, with one field per keyword of `pretty_table` that is specific
to this back end, plus `is_stdout`, which is `true` when the table is printed to `stdout`.
The meaning and the default of each field are documented in the Typst back end section of
`pretty_table`.

The keywords are gathered in this structure so that the rendering body has a single
positional signature. Otherwise, each distinct set of keywords passed by the user would
create a new entry point into the body, and compiling an entry point into such a large
function is expensive (hundreds of milliseconds in Julia 1.12) even when the body itself is
already compiled.
"""
@kwdef struct TypstPrintOptions
    annotate::Bool                                                                        = true
    caption::Union{Nothing, String, TypstCaption}                                         = nothing
    data_column_widths::Union{Nothing, String, Vector{String}, Vector{Pair{Int, String}}} = nothing
    highlighters::Vector{AbstractHighlighter}                                             = _NO_HIGHLIGHTERS
    is_stdout::Bool                                                                       = false
    minify::Bool                                                                          = false
    style::TypstTableStyle                                                                = _DEFAULT_TYPST_TABLE_STYLE
    table_format::TypstTableFormat                                                        = _DEFAULT_TYPST_TABLE_FORMAT
    wrap_column::Int                                                                      = 92
end

############################################################################################
#                                      Entry Points                                       #
############################################################################################

# The keyword entry point only gathers the options. It is compiled once per set of keywords,
# which is cheap because it is tiny.
function _typst__print(pspec::PrintingSpec; kwargs...)
    _check_backend_keywords(TypstPrintOptions, kwargs, "Typst")
    return _typst__print(pspec, TypstPrintOptions(; kwargs...))
end

# This method must be the only caller of the rendering body and it must not be inlined into
# the keyword entry point. Otherwise, each keyword set would pay for a new entry point into
# the body (see `TypstPrintOptions`).
@noinline function _typst__print(pspec::PrintingSpec, opts::TypstPrintOptions)
    return _typst__print_core(pspec, opts)
end

function _typst__print_core(pspec::PrintingSpec, opts::TypstPrintOptions)
    # == Unpack the Options ================================================================

    annotate           = opts.annotate
    caption            = opts.caption
    data_column_widths = opts.data_column_widths
    highlighters       = _typst__native_highlighters(opts.highlighters)
    is_stdout          = opts.is_stdout
    minify             = opts.minify
    style              = opts.style
    table_format       = opts.table_format
    wrap_column        = opts.wrap_column

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

    # Check the style variables.
    _check_column_label_styles(
        style.first_line_column_label,
        style.column_label,
        Vector{Vector{TypstPair}},
        table_data.num_columns,
    )

    # If `minify` is `true`, we do not wrap lines.
    if minify
        wrap_column = -1
    end

    # Process the horizontal lines at data rows.
    horizontal_lines_at_data_rows =
        _line_spec_indices(tf.horizontal_lines_at_data_rows, table_data.num_rows)

    # Process the vertical lines at data columns.
    vertical_lines_at_data_columns =
        _line_spec_indices(tf.vertical_lines_at_data_columns, table_data.num_columns)

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

    # The highlighters must receive the object the user passed to `pretty_table`, not the
    # internal table wrapper. Notice that this is loop invariant.
    orig_data = _get_data(table_data.data)

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)
        action == :end_printing && break

        # Obtain the next action since some actions depend on it. Notice that only the
        # `:new_row` and `:end_row` branches consume the lookahead, and that it is a full run
        # of the printing state iterator. Hence, we must not pay for it on every cell.
        next_action, next_rs = if (action == :new_row) || (action == :end_row)
            na, nrs, _ = _next(ps, table_data)
            na, nrs
        else
            :initialize, :initialize
        end

        if action == :new_row
            empty!(merged_column_labels)
            first_column = true

            # If we are in the very first row after the title section, we need to check if
            # the user wants a horizontal line before the table.
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

            # The table header is closed at the end of its last row (see the `:end_row`
            # branch). Hence, here we only need to open it or to start the table body if the
            # table has no header.
            if (rs ∈ (:table_header, :column_labels)) && !head_opened && !body_opened
                annotate && _aprintln_section_annotation(
                    buf_tc, "// == Table Header", il, ns, wrap_column, '='
                )

                _aprintln(buf_tc, "table.header(", il, ns)
                il += 1
                head_opened = true

            elseif (rs ∉ (:table_header, :column_labels)) && !body_opened
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

            # The table header must be closed at the end of its last row. Otherwise, the
            # omitted cell summary, which is printed at the end of the last row before the
            # table footer, and the rows of the next sections would be placed inside it
            # when the table has no data rows.
            if head_opened && (next_rs ∉ (:table_header, :column_labels))
                il -= 1
                _aprintln(buf_tc, "),", il, ns)
                head_opened = false

                annotate && (next_rs != :end_printing) && _aprintln_section_annotation(
                    buf_tc, "// == Table Body", il, ns, wrap_column, '='
                )

                body_opened = true
            end

            # == Handle the Horizontal Lines ===============================================

            if (rs == :column_labels) && (next_rs == :column_labels)
                if tf.horizontal_line_at_merged_column_labels
                    # The specification in `merged_column_labels` refers to the data
                    # columns. Hence, we need to add the offset regarding the previous
                    # columns if they exist.
                    Δc = table_data.show_row_number_column + _has_row_labels(table_data)

                    # Each merged cell needs its own line, exactly like the LaTeX back end
                    # accumulates one `\cline` per merged cell.
                    for m in merged_column_labels
                        c₀ = Δc + m[1] - 1
                        c₁ = Δc + m[2]

                        @_println(
                            buf_hlines,
                            hline_pad,
                            "table.hline(y: ",
                            current_typst_line,
                            ", start: ",
                            c₀,
                            ", end: ",
                            c₁,
                            ", stroke: ",
                            tf.borders.merged_header_cell_line,
                            ",),"
                        )
                    end
                end
            else
                role = _horizontal_line_after_row(
                    tf, rs, next_rs, ps.i, horizontal_lines_at_data_rows
                )

                if role != :none
                    first_table_line = false

                    @_println(
                        buf_hlines,
                        hline_pad,
                        "table.hline(y: ",
                        current_typst_line,
                        ", stroke: ",
                        getfield(tf.borders, role),
                        ",),"
                    )
                end
            end

            # == Omitted Cell Summary ======================================================

            # We need to print the omitted cell summary as soon as we enter the table
            # footer.
            if (!isempty(ocs) && next_rs ∈ (:table_footer, :end_printing) && !ocs_printed)
                cell_properties, text_properties = _typst__cell_and_text_properties(
                    style.omitted_cell_summary
                )

                # We must copy the vector before pushing because the function above can
                # return a shared empty vector that must not be mutated.
                cell_properties = copy(cell_properties)

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

            # Compute the footnote superscripts to append to this cell. Notice that this must
            # be done here, and not once per action, because the result is only ever consumed
            # by a cell.
            #
            # Notice that all the footnote numbers must be inside the same superscript.
            # Otherwise, the separator would be rendered with the normal text size.
            footnote_str = _current_cell_footnote_marks(
                string, table_data, action, ps.i, ps.j, ","
            )
            append = isempty(footnote_str) ? nothing : "#super[" * footnote_str * "]"

            # If we are in a column label, check if we must merge the cell.
            if (action == :column_label) && (cell isa MergeCells)
                cs = _merged_cell_span(table_data, cell, ps.j)

                push!(merged_column_labels, (ps.j, ps.j + cs - 1))

                push!(vproperties, "colspan" => string(cs))
                rendered_cell = _typst__render_cell(cell.data, rctx, renderer)

                alignment = cell.alignment

                # NOTE: The `:column_label` property branch below never pushes an alignment,
                # since only `:data` cells do. Hence, the alignment the user selected for a
                # merged column label must be pushed here, exactly like the HTML and LaTeX
                # back ends honor it.
                push!(vproperties, "align" => _typst__alignment(alignment))

                # The style of the merged column labels can override the alignment.
                _typst__merge_properties!(
                    vproperties,
                    if ps.i == 1
                        style.first_line_merged_column_label
                    else
                        style.merged_column_label
                    end,
                )

            else
                rendered_cell = _typst__render_cell(cell, rctx, renderer)

                alignment = _current_cell_alignment(action, ps, table_data)
            end

            # If we are in a data cell, we must check for highlighters.
            if action == :data
                if !isempty(highlighters)
                    di, dj = _data_indices(table_data, ps.i, ps.j)

                    for h in highlighters
                        if h.f(orig_data, di, dj)
                            _typst__merge_properties!(
                                vproperties,
                                _typst__highlighter_decoration(h, orig_data, di, dj),
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

            # The merged column labels only receive the style of the merged cells, which
            # was merged above.
            elseif (action == :column_label) && !(cell isa MergeCells)
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
                # The footnote must be a cell that spans the entire printed table.
                push!(
                    vproperties,
                    "align"   => _typst__alignment(alignment),
                    "colspan" => string(_number_of_printed_columns(table_data)),
                    "inset"   => "(left: 0pt)",
                    "stroke"  => "none",
                )
                _typst__merge_properties!(vproperties, style.footnote)

            elseif action == :source_notes
                # The source notes must be a cell that spans the entire printed table.
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

            # NOTE: `action ∈ [:footnote]` would heap-allocate a `Vector{Symbol}` per cell.
            cell_prefix = action == :footnote ? "#super[$(ps.i)]" : ""

            # If the type is `Markdown.MD` or if Typstry.jl is loaded and the cell is a
            # `TypstString`, we do not wrap it in a #text. Treat it as a raw Typst
            # component.
            cell_content = if (cell isa Markdown.MD) || _typst__is_raw_typst_cell(cell)
                rendered_cell
            else
                _typst__text(rendered_cell, text_properties)
            end

            # The content must not be parsed as a field access or a function call on the
            # footnote superscript.
            !isempty(cell_prefix) &&
                (cell_content = _typst__escape_after_component(cell_content))

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
            # The caption is emitted inside a Typst string literal, so an embedded `"` or
            # `\` would break the document.
            _aprintln(
                buf, "caption: \"$(_typst__escape_string_literal(caption))\",", il, ns
            )
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

    # If we are printing to `stdout` and Typstry.jl is loaded, try to render the table using
    # the available displays. If it is not possible, print the plain output.
    if !(is_stdout && _typst__display(output_str))
        print(context, output_str)
    end

    return nothing
end
