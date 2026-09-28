## Description #############################################################################
#
# LaTeX back end for PrettyTables.jl.
#
############################################################################################

# Default style and format, created once because constructing them allocates.
const _DEFAULT_LATEX_TABLE_STYLE  = LatexTableStyle()
const _DEFAULT_LATEX_TABLE_FORMAT = LatexTableFormat()

############################################################################################
#                                      Print Options                                       #
############################################################################################

"""
    struct LatexPrintOptions

Options of the LaTeX back end, with one field per keyword of `pretty_table` that is
specific to this back end. The meaning and the default of each field are documented in the
LaTeX back end section of `pretty_table`.

The keywords are gathered in this structure so that the rendering body has a single
positional signature. Otherwise, each distinct set of keywords passed by the user would
create a new entry point into the body, and compiling an entry point into such a large
function is expensive (hundreds of milliseconds in Julia 1.12) even when the body itself is
already compiled.
"""
@kwdef struct LatexPrintOptions
    highlighters::Vector{AbstractHighlighter} = _NO_HIGHLIGHTERS
    style::LatexTableStyle                    = _DEFAULT_LATEX_TABLE_STYLE
    table_format::LatexTableFormat            = _DEFAULT_LATEX_TABLE_FORMAT
end

############################################################################################
#                                      Entry Points                                       #
############################################################################################

# The keyword entry point only gathers the options. It is compiled once per set of keywords,
# which is cheap because it is tiny.
function _latex__print(pspec::PrintingSpec; kwargs...)
    _check_backend_keywords(LatexPrintOptions, kwargs, "LaTeX")
    return _latex__print(pspec, LatexPrintOptions(; kwargs...))
end

# This method must be the only caller of the rendering body and it must not be inlined into
# the keyword entry point. Otherwise, each keyword set would pay for a new entry point into
# the body (see `LatexPrintOptions`).
@noinline function _latex__print(pspec::PrintingSpec, opts::LatexPrintOptions)
    return _latex__print_core(pspec, opts)
end

function _latex__print_core(pspec::PrintingSpec, opts::LatexPrintOptions)
    # == Unpack the Options ================================================================

    highlighters = _latex__native_highlighters(opts.highlighters)
    style        = opts.style
    table_format = opts.table_format

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

    # Process the horizontal lines at data rows.
    horizontal_lines_at_data_rows =
        _line_spec_indices(tf.horizontal_lines_at_data_rows, table_data.num_rows)

    # Process the vertical lines at data columns.
    vertical_lines_at_data_columns =
        _line_spec_indices(tf.vertical_lines_at_data_columns, table_data.num_columns)

    # Check the style variables.
    _check_column_label_styles(
        style.first_line_column_label,
        style.column_label,
        Vector{LatexEnvironments},
        table_data.num_columns,
    )

    # == Variables to Store Information About Indentation ==================================

    il = 0 # ..................................................... Current indentation level
    ns = 2 # .................................... Number of spaces in each indentation level

    # == Print LaTeX Header ================================================================

    # Create the table header description for the current table.
    desc = _latex__table_header_description(table_data, tf, vertical_lines_at_data_columns)

    _aprintln(buf, "\\begin{tabular}{$desc}", il, ns)
    il += 1

    # == Table =============================================================================

    # Check if the user wants the omitted cell summary.
    ocs = _omitted_cell_summary(table_data, pspec)
    ocs_printed = false

    action = :initialize

    first_table_line = true
    first_element_in_row = true

    # This variable stores where a merged column label begins and ends. Hence, we are able
    # to draw a line after them if the user wants.
    merged_column_labels = Tuple{Int, Int}[]

    # The highlighters must receive the object the user passed to `pretty_table`, not the
    # internal table wrapper. Notice that this is loop invariant.
    orig_data = _get_data(table_data.data)

    while action != :end_printing
        action, rs, ps = _next(ps, table_data)

        action == :end_printing && break

        if action == :new_row
            empty!(merged_column_labels)
            first_element_in_row = true

            # If we are in the very first row after the title section, we need to check if
            # the user wants a horizontal line before the table.
            if (rs != :table_header) && first_table_line && tf.horizontal_line_at_beginning
                _aprintln(buf, tf.borders.top_line, il, ns)
                first_table_line = false
            end

            # Here, we just need to apply the indentation.
            print(buf, " "^(ns * il))

        elseif action == :end_row
            # Obtain the next row section since some decisions below depend on it. Notice
            # that this must be done here, and not once per action, because the lookahead is
            # a full run of the printing state iterator and only this branch consumes it.
            _, next_rs, _ = _next(ps, table_data)

            println(buf, " \\\\")

            # == Handle the Horizontal Lines ===============================================

            hline_str = ""

            if (rs == :column_labels) && (next_rs == :column_labels)
                if tf.horizontal_line_at_merged_column_labels
                    # The specification in `merged_column_labels` refers to the data
                    # columns. Hence, we need to add the offset regarding the previous
                    # columns if they exist.
                    Δc = table_data.show_row_number_column + _has_row_labels(table_data)
                    for m in merged_column_labels
                        c₀ = Δc + m[1]
                        c₁ = Δc + m[2]
                        hline_str *= "$(tf.borders.merged_header_cell_line){$c₀-$c₁}"
                    end
                end
            else
                role = _horizontal_line_after_row(
                    tf, rs, next_rs, ps.i, horizontal_lines_at_data_rows
                )

                if role != :none
                    hline_str = getfield(tf.borders, role)
                    first_table_line = false
                end
            end

            !isempty(hline_str) && _aprintln(buf, hline_str, il, ns)

            # == Omitted Cell Summary ======================================================

            if (!isempty(ocs) && next_rs ∈ (:table_footer, :end_printing) && !ocs_printed)
                cs = _number_of_printed_columns(table_data)
                ocs_styled = _latex__add_environments(ocs, style.omitted_cell_summary)

                # If the table footer will be printed afterward, we must end the current
                # tabular row. Otherwise, the footer cells would be printed in the same row,
                # leading to an invalid LaTeX document.
                has_footer = _has_footnotes(table_data) || !isempty(table_data.source_notes)
                line_end   = (next_rs == :table_footer) && has_footer ? " \\\\" : ""

                _aprintln(buf, "\\multicolumn{$cs}{r@{}}{$ocs_styled}$line_end", il, ns)
                ocs_printed = true
            end

        elseif action == :row_group_label
            cell          = _current_cell(action, ps, table_data)
            alignment     = _latex__alignment_to_str(
                _current_cell_alignment(action, ps, table_data)
            )
            rendered_cell = _latex__render_cell(cell, rctx, renderer)
            cs            = _number_of_printed_columns(table_data)

            # Check for vertical lines.
            vline_before = tf.vertical_line_at_beginning
            vline_after  = if _is_horizontally_cropped(table_data)
                tf.vertical_line_after_continuation_column
            else
                tf.vertical_line_after_data_columns
            end

            border₀ = vline_before ? "|" : ""
            border₁ = vline_after ? "|" : ""

            rgl_styled = _latex__add_environments(rendered_cell, style.row_group_label)
            print(buf, "\\multicolumn{$cs}{$border₀$alignment$border₁}{$rgl_styled}")

        else
            # Check for footnotes.
            footnotes    = _current_cell_footnotes(table_data, action, ps.i, ps.j)
            footnote_str = ""

            if !isnothing(footnotes) && !isempty(footnotes)
                footnote_str = "\$^{"
                for i in eachindex(footnotes)
                    f = footnotes[i]
                    if i != last(eachindex(footnotes))
                        footnote_str *= "$f,"
                    else
                        footnote_str *= "$f}\$"
                    end
                end
            end

            rendered_cell = nothing

            if action == :diagonal_continuation_cell
                rendered_cell = "\$\\ddots\$"

            elseif action == :horizontal_continuation_cell
                rendered_cell = "\$\\cdots\$"

            elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
                rendered_cell = "\$\\vdots\$"

            else
                cell = _current_cell(action, ps, table_data)

                cell === _IGNORE_CELL && continue

                # First, we handle merged cells.
                if (action ∈ (:title, :subtitle))
                    alignment = _latex__alignment_to_str(
                        action == :title ? table_data.title_alignment :
                        table_data.subtitle_alignment,
                    )

                    cs = _number_of_printed_columns(table_data)

                    rendered_cell = _latex__render_cell(cell, rctx, renderer)

                    rendered_cell = _latex__add_environments(
                        rendered_cell, action == :title ? style.title : style.subtitle
                    )

                    rendered_cell = rendered_cell * footnote_str
                    rendered_cell = "\\multicolumn{$cs}{@{}$alignment@{}}{$rendered_cell}"

                elseif (action == :column_label) && (cell isa MergeCells)
                    num_data_columns = _number_of_printed_data_columns(table_data)
                    cs               = _merged_cell_span(table_data, cell, ps.j)

                    push!(merged_column_labels, (ps.j, ps.j + cs - 1))

                    alignment = _latex__alignment_to_str(cell.alignment)

                    # We must check if we have a vertical line after the cell merge.
                    vline =
                        (ps.j + cs - 1 ∈ vertical_lines_at_data_columns) || (
                            (ps.j + cs - 1 == num_data_columns) &&
                            tf.vertical_line_after_data_columns
                        )

                    if vline
                        alignment *= "|"
                    end

                    # The `\multicolumn` command also overrides the vertical line at the
                    # table beginning, which belongs to the descriptor of the first column.
                    # Hence, we must reconstruct it here.
                    if (
                        (ps.j == 1) &&
                        !_has_row_labels(table_data) &&
                        !table_data.show_row_number_column &&
                        tf.vertical_line_at_beginning
                    )
                        alignment = "|" * alignment
                    end

                    rendered_cell = _latex__render_cell(cell.data, rctx, renderer)

                    # Apply the style to the text.
                    envs =
                        ps.i == 1 ? style.first_line_merged_column_label :
                        style.merged_column_label
                    rendered_cell = _latex__add_environments(rendered_cell, envs)
                    rendered_cell = rendered_cell * footnote_str

                    # Merge the cells.
                    rendered_cell = "\\multicolumn{$cs}{@{}$alignment@{}}{$rendered_cell}"

                    # Check if we must merge the cell to render the footnotes or source
                    # notes.
                elseif (action == :footnote)
                    alignment     = _latex__alignment_to_str(table_data.footnote_alignment)
                    cs            = _number_of_printed_columns(table_data)
                    rendered_cell =
                        "\$^{$(ps.i)}\$" * _latex__render_cell(cell, rctx, renderer)
                    rendered_cell = _latex__add_environments(rendered_cell, style.footnote)
                    rendered_cell = "\\multicolumn{$cs}{@{}$alignment@{}}{$rendered_cell}"

                elseif (action == :source_notes)
                    alignment     = _latex__alignment_to_str(table_data.footnote_alignment)
                    cs            = _number_of_printed_columns(table_data)
                    rendered_cell = _latex__render_cell(cell, rctx, renderer)
                    rendered_cell = _latex__add_environments(rendered_cell, style.source_note)
                    rendered_cell = "\\multicolumn{$cs}{@{}$alignment@{}}{$rendered_cell}"

                else
                    rendered_cell = _latex__render_cell(cell, rctx, renderer)
                    alignment = _current_cell_alignment(action, ps, table_data)

                    # Apply the style to the cell.
                    envs = nothing

                    # Get the environment of the cell, if any.
                    if action == :row_number_label
                        envs = style.row_number_label

                    elseif action == :row_number
                        envs = style.row_number

                    elseif action == :summary_row_number
                        envs = style.row_number

                    elseif action == :stubhead_label
                        envs = style.stubhead_label

                    elseif action == :row_label
                        envs = style.row_label

                    elseif action == :summary_row_label
                        envs = style.summary_row_label

                    elseif action == :column_label
                        envs = if ps.i == 1
                            if style.first_line_column_label isa Vector{LatexEnvironments}
                                style.first_line_column_label[ps.j]
                            else
                                style.first_line_column_label
                            end
                        else
                            if style.column_label isa Vector{LatexEnvironments}
                                style.column_label[ps.j]
                            else
                                style.column_label
                            end
                        end

                    elseif action == :summary_row_cell
                        envs = style.summary_row_cell

                    # Notice that `:footnote` and `:source_notes` cannot reach this point
                    # because they are fully consumed by the dedicated `\multicolumn`
                    # branches above.
                    else
                        # Here we have a data cell. Hence, apply the highlighters in
                        # order, stopping at the first match.
                        di, dj = _data_indices(table_data, ps.i, ps.j)

                        for h in highlighters
                            if h.f(orig_data, di, dj)
                                envs = _latex__highlighter_decoration(h, orig_data, di, dj)
                                break
                            end
                        end
                    end

                    rendered_cell = _latex__add_environments(rendered_cell, envs)
                    rendered_cell = rendered_cell * footnote_str

                    # Check if we need to override the alignment. Notice that we must
                    # normalize the alignment symbols before comparing them because, e.g.,
                    # `:c` and `:C` lead to the same LaTeX column descriptor.
                    alignment_str = _latex__alignment_to_str(alignment)

                    if (
                        action == :data &&
                        alignment_str != _latex__alignment_to_str(
                            _data_column_alignment(table_data, ps.j)
                        )
                    )
                        # The `\multicolumn` command overrides the column descriptor in the
                        # preamble, including the vertical line after the cell. Hence, we
                        # must reconstruct it here. The vertical line before the cell
                        # belongs to the descriptor of the previous column, except when the
                        # cell is at the very first table column.
                        vline_before =
                            (ps.j == 1) &&
                            !_has_row_labels(table_data) &&
                            !table_data.show_row_number_column &&
                            tf.vertical_line_at_beginning

                        vline_after = (ps.j ∈ vertical_lines_at_data_columns) || (
                            (ps.j == _number_of_printed_data_columns(table_data)) &&
                            tf.vertical_line_after_data_columns
                        )

                        border₀ = vline_before ? "|" : ""
                        border₁ = vline_after ? "|" : ""

                        rendered_cell = "\\multicolumn{1}{$border₀$alignment_str$border₁}{$rendered_cell}"
                    end
                end
            end

            # If `rendered_cell` is `nothing`, we did not process the cell. Hence, we
            # should just skip.
            isnothing(rendered_cell) && continue

            if first_element_in_row
                first_element_in_row = false
            else
                print(buf, " & ")
            end

            print(buf, rendered_cell)
        end
    end

    il -= 1
    _aprintln(buf, "\\end{tabular}", il, ns)

    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    if !pspec.new_line_at_end
        output_str = chomp(output_str)
    end

    print(context, output_str)

    return nothing
end
