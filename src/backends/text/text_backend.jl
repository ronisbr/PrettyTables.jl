## Description #############################################################################
#
# Text back end for PrettyTables.jl.
#
############################################################################################

# Pre-allocate some default values for keywords to avoid allocations. Notice that we must do
# this only to the values that **are not** modified inside the algorithm. Otherwise, we will
# not be thread safe.
const _DEFAULT_ALIGNMENT_ANCHOR_REGEX = Regex[]

# Default style and format, created once because constructing them allocates.
const _DEFAULT_TEXT_TABLE_STYLE  = TextTableStyle()
const _DEFAULT_TEXT_TABLE_FORMAT = TextTableFormat()

############################################################################################
#                                      Print Options                                       #
############################################################################################

"""
    struct TextPrintOptions

Options of the text back end, with one field per keyword of `pretty_table` that is specific
to this back end. The meaning and the default of each field are documented in the text back
end section of `pretty_table`.

The keywords are gathered in this structure so that the rendering body,
`_text__print_table_core`, has a single positional signature. Otherwise, each distinct set
of keywords passed by the user would create a new entry point into the body, and compiling
an entry point into such a large function is expensive (hundreds of milliseconds in Julia
1.12) even when the body itself is already compiled.

`display_size` is `nothing` when the user did not pass it, in which case the size of the
display is obtained from the printing context by the rendering body.
"""
@kwdef struct TextPrintOptions
    alignment_anchor_fallback::Symbol                                              = :l
    alignment_anchor_regex::Union{Vector{Regex}, Vector{Pair{Int, Vector{Regex}}}} = _DEFAULT_ALIGNMENT_ANCHOR_REGEX
    apply_alignment_regex_to_summary_rows::Bool                                    = false
    auto_wrap::Bool                                                                = false
    column_label_width_based_on_first_line_only::Bool                              = false
    display_size::Union{Nothing, NTuple{2, Int}}                                   = nothing
    equal_data_column_widths::Bool                                                 = false
    fit_table_in_display_horizontally::Bool                                        = true
    fit_table_in_display_vertically::Bool                                          = true
    fixed_data_column_widths::Union{Int, Vector{Int}}                              = 0
    highlighters::Vector{AbstractHighlighter}                                      = _NO_HIGHLIGHTERS
    line_breaks::Bool                                                              = false
    minimum_data_column_widths::Union{Int, Vector{Int}}                            = 0
    maximum_data_column_widths::Union{Int, Vector{Int}}                            = 0
    overwrite_display::Bool                                                        = false
    reserved_display_lines::Int                                                    = 0
    shrinkable_data_column::Int                                                    = 0
    shrinkable_column_minimum_width::Int                                           = 0
    style::TextTableStyle                                                          = _DEFAULT_TEXT_TABLE_STYLE
    table_format::TextTableFormat                                                  = _DEFAULT_TEXT_TABLE_FORMAT
end

############################################################################################
#                                      Entry Points                                       #
############################################################################################

# The keyword entry point only gathers the options. It is compiled once per set of keywords,
# which is cheap because it is tiny.
function _text__print_table(pspec::PrintingSpec; kwargs...)
    _check_backend_keywords(TextPrintOptions, kwargs, "text")
    return _text__print_table(pspec, TextPrintOptions(; kwargs...))
end

# This method must be the only caller of the rendering body and it must not be inlined into
# the keyword entry point. Otherwise, each keyword set would pay for a new entry point into
# the body (see `TextPrintOptions`).
@noinline function _text__print_table(pspec::PrintingSpec, opts::TextPrintOptions)
    return _text__print_table_core(pspec, opts)
end

function _text__print_table_core(
    pspec::PrintingSpec, opts::TextPrintOptions, omitted_columns::Bool = false
)
    # The fields of the table data modified by the fitting of the table in the display. They
    # must be restored if the process is restarted (see the section "Omitted Columns").
    user_maximum_number_of_columns = pspec.table_data.maximum_number_of_columns
    user_maximum_number_of_rows    = pspec.table_data.maximum_number_of_rows
    user_vertical_crop_mode        = pspec.table_data.vertical_crop_mode

    # == Unpack the Options ================================================================

    alignment_anchor_fallback                   = opts.alignment_anchor_fallback
    alignment_anchor_regex                      = opts.alignment_anchor_regex
    apply_alignment_regex_to_summary_rows       = opts.apply_alignment_regex_to_summary_rows
    auto_wrap                                   = opts.auto_wrap
    column_label_width_based_on_first_line_only = opts.column_label_width_based_on_first_line_only
    equal_data_column_widths                    = opts.equal_data_column_widths
    fit_table_in_display_horizontally           = opts.fit_table_in_display_horizontally
    fit_table_in_display_vertically             = opts.fit_table_in_display_vertically
    fixed_data_column_widths                    = opts.fixed_data_column_widths
    highlighters                                = _text__native_highlighters(opts.highlighters)
    line_breaks                                 = opts.line_breaks
    minimum_data_column_widths                  = opts.minimum_data_column_widths
    maximum_data_column_widths                  = opts.maximum_data_column_widths
    overwrite_display                           = opts.overwrite_display
    reserved_display_lines                      = opts.reserved_display_lines
    shrinkable_data_column                      = opts.shrinkable_data_column
    shrinkable_column_minimum_width             = opts.shrinkable_column_minimum_width
    style                                       = opts.style
    table_format                                = opts.table_format

    # If the user did not pass the display size, obtain it from the printing context.
    display_size = if isnothing(opts.display_size)
        displaysize(pspec.context)
    else
        opts.display_size
    end

    context    = pspec.context
    table_data = pspec.table_data
    # NOTE: `Val(pspec.renderer)` infers to the abstract `Val` because
    # `pspec.renderer` is a `Symbol`. Branching here keeps the renderer concrete, so the
    # per-cell rendering calls are statically dispatched.
    renderer   = pspec.renderer === :show ? Val(:show) : Val(:print)
    tf         = table_format

    buf_io = IOBuffer()

    # Reusable render buffer: one allocation per table instead of three per cell.
    rctx = RenderContext(context)

    # == Process Input Variables ===========================================================

    # Auto wrap implies line breaks.
    if auto_wrap
        line_breaks = true
    end

    # If the user does not want to crop the table horizontally, we set the display width to
    # -1, meaning that we do not have a limit.
    if !fit_table_in_display_horizontally
        display_size = (display_size[1], -1)
    end

    # If the user does not want to crop the table vertically, we set the display length to
    # -1, meaning that we do not have a limit.
    if !fit_table_in_display_vertically
        display_size = (-1, display_size[2])
    end

    # If the user wants to reserve some display lines, remove them from the display size.
    # Notice that the display must keep at least one line. Otherwise, the display height
    # would become unlimited.
    if (reserved_display_lines > 0) && (display_size[1] > 0)
        display_size = (max(display_size[1] - reserved_display_lines, 1), display_size[2])
    end

    # Create the structure that holds the display information.
    display = Display(display_size, 0, get(context, :color, false), buf_io, IOBuffer())

    # The escape sequences of the style are rendered when it is created, so that the loop
    # only writes strings. The printing functions skip them if the display has no color.
    rstyle = style._rendered::TextRenderedStyle

    # Resolve the characters and escape sequences used to draw each table line, taking the
    # line characters and line faces into account. If none is set, this object only
    # references the characters in `tf.borders` and the escape sequence of `table_border`.
    rl = _text__resolve_table_lines(tf, style)

    # Process the vertical lines at data columns.
    vertical_lines_at_data_columns =
        _line_spec_indices(tf.vertical_lines_at_data_columns, table_data.num_columns)

    # The width keywords are indexed inside the per-cell loop. Hence, we must check their
    # length here to raise a meaningful error instead of a `BoundsError` deep in the back
    # end.
    for (name, v) in (
        ("fixed_data_column_widths", fixed_data_column_widths),
        ("minimum_data_column_widths", minimum_data_column_widths),
        ("maximum_data_column_widths", maximum_data_column_widths),
    )
        (v isa AbstractVector) && (length(v) != table_data.num_columns) && throw(
            ArgumentError(
                "The length of `$name` ($(length(v))) must be equal to the number of columns ($(table_data.num_columns)).",
            ),
        )
    end

    # Normalize the width keywords into locals of a single concrete type, which are indexed
    # inside the per-cell loop.
    min_data_column_widths = _text__column_widths(
        minimum_data_column_widths, table_data.num_columns
    )

    max_data_column_widths = _text__column_widths(
        maximum_data_column_widths, table_data.num_columns
    )

    fix_data_column_widths = _text__column_widths(
        fixed_data_column_widths, table_data.num_columns
    )

    has_fixed_data_column_widths = any(>(0), fix_data_column_widths)

    # The fixed width of a column has precedence over its maximum width. Otherwise, the
    # cells would be cropped to the maximum width before being fitted in the fixed width.
    for j in eachindex(fix_data_column_widths)
        (fix_data_column_widths[j] > 0) && (max_data_column_widths[j] = 0)
    end

    if alignment_anchor_regex isa Vector{Pair{Int, Vector{Regex}}}
        for (j, _) in alignment_anchor_regex
            (j <= 0) && throw(
                ArgumentError(
                    "The column index in the alignment anchor regex must be greater than 0.",
                ),
            )

            (j > table_data.num_columns) && throw(
                ArgumentError(
                    "The column index in the alignment anchor regex must not be greater than the number of columns ($(table_data.num_columns)).",
                ),
            )
        end
    end

    # Check the style variables.
    _check_column_label_styles(
        style.first_line_column_label,
        style.column_label,
        Vector,
        table_data.num_columns,
    )

    # == Table Fitting in the Display ======================================================

    # Process the horizontal lines at column labels.
    if tf.horizontal_lines_at_column_labels isa Symbol
        horizontal_lines_at_column_labels = if tf.horizontal_lines_at_column_labels == :all
            1:(length(table_data.column_labels) - 1)
        else
            1:0
        end
    else
        # Notice that a line after the last column label row is drawn by the option
        # `horizontal_line_after_column_labels`. Hence, we must neglect it here. Otherwise,
        # we would reserve a display line for a horizontal line that is never drawn.
        horizontal_lines_at_column_labels = filter(
            x -> 1 <= x <= length(table_data.column_labels) - 1,
            tf.horizontal_lines_at_column_labels::Vector{Int},
        )
    end

    # Process the horizontal lines at data rows.
    horizontal_lines_at_data_rows =
        _line_spec_indices(tf.horizontal_lines_at_data_rows, table_data.num_rows)

    # Limit the number of rendered columns given the display size if the user wants. Notice
    # that this is only an upper bound, since the number of printed columns is computed
    # after the column widths. Hence, we assume the minimum width of each column, which is
    # 3 characters (one character and the margins).
    if fit_table_in_display_horizontally && (display_size[2] > 0)
        mc = div(display.size[2], 3, RoundUp)

        # If the user provided a fixed data column width, we can use it to check how many
        # columns we can display.
        if has_fixed_data_column_widths
            aux = 0
            mc = 1

            for j in eachindex(fix_data_column_widths)
                fcw  = fix_data_column_widths[j]
                aux += fcw <= 0 ? 3 : fcw + 2
                aux > display.size[2] && break
                mc += 1
            end
        end

        if table_data.maximum_number_of_columns >= 0
            table_data.maximum_number_of_columns = min(
                table_data.maximum_number_of_columns, mc
            )
        else
            table_data.maximum_number_of_columns = mc
        end
    end

    # Limit the number of rendered rows given the display size if the user wants.
    vertically_limited_by_display          = false
    suppress_hline_before_continuation_row = false
    suppress_hline_after_continuation_row  = false

    if fit_table_in_display_vertically && (display_size[1] > 0)
        # NOTE: In case we have line breaks, this design is only preliminary. In this case,
        # we perform the following actions:
        #
        #   1. Design the number of rendered rows assuming one line per row.
        #   2. Render the table.
        #   3. Compute the number of rendered columns.
        #   4. Re-design the number of rendered rows considering the actual number of lines.

        # Notice that, at this point, we only know if data columns will be omitted by the
        # user specification or by our estimate of the number of columns that fits in the
        # display.
        omitted_columns = omitted_columns || _is_horizontally_cropped(table_data)

        design = _text__design_vertical_cropping(
            table_data,
            tf,
            horizontal_lines_at_column_labels,
            horizontal_lines_at_data_rows,
            pspec.show_omitted_cell_summary,
            display.size[1],
            pspec.new_line_at_end,
            omitted_columns,
        )

        # We do not support the middle cropping by the display when using line breaks since
        # it will require a much more complex algorithm, decreasing the maintainability.
        # Hence, if the display limits the rows even with one line per row, we must use the
        # bottom cropping. Otherwise, the middle cropping is checked again after rendering
        # the table (see below).
        if (
            line_breaks &&
            (table_data.vertical_crop_mode == :middle) &&
            (first(design) < _number_of_printed_data_rows(table_data))
        )
            table_data.vertical_crop_mode = :bottom

            design = _text__design_vertical_cropping(
                table_data,
                tf,
                horizontal_lines_at_column_labels,
                horizontal_lines_at_data_rows,
                pspec.show_omitted_cell_summary,
                display.size[1],
                pspec.new_line_at_end,
                omitted_columns,
            )
        end

        mr, suppress_hline_before_continuation_row, suppress_hline_after_continuation_row = design

        if table_data.maximum_number_of_rows >= 0
            vertically_limited_by_display = mr < table_data.maximum_number_of_rows
            table_data.maximum_number_of_rows = min(table_data.maximum_number_of_rows, mr)
        else
            vertically_limited_by_display = mr < table_data.num_rows
            table_data.maximum_number_of_rows = mr
        end

    end

    # == Render the Table ==================================================================

    # For the text back end, we need to render the entire table before printing to take into
    # account the required column width.

    row_labels, column_labels, table_str, summary_rows, summary_row_labels, footnotes,
        custom_cells = _text__render_table(
            table_data,
            rctx,
            renderer,
            line_breaks,
            max_data_column_widths,
            vertical_lines_at_data_columns,
        )

    num_printed_data_rows, num_printed_data_columns = size(table_str)

    # == Column Alignment Regex ============================================================

    if !isempty(alignment_anchor_regex)
        # We will create a vector to copy each column string that will be aligned. This
        # procedure is necessary because if the user wants to also apply the alignment to
        # the summary rows, we need to copy those lines before the alignment process.

        if isnothing(summary_rows)
            # We should not apply the alignment regex to the summary rows if there is none.
            apply_alignment_regex_to_summary_rows = false
        end

        num_summary_rows = apply_alignment_regex_to_summary_rows ? size(summary_rows, 1) : 0

        column_str = Vector{String}(undef, num_printed_data_rows + num_summary_rows)

        # Check if we have one set of regexes to be applied to all the columns or if the
        # user specified regexes for some columns.
        if alignment_anchor_regex isa Vector{Regex}
            for j in 1:num_printed_data_columns
                _text__align_column_with_regex!(
                    table_str,
                    summary_rows,
                    column_str,
                    j,
                    alignment_anchor_regex,
                    alignment_anchor_fallback,
                    apply_alignment_regex_to_summary_rows,
                    max_data_column_widths[j],
                    line_breaks,
                )
            end
        else
            for (j, regex) in alignment_anchor_regex
                j > num_printed_data_columns && continue

                _text__align_column_with_regex!(
                    table_str,
                    summary_rows,
                    column_str,
                    j,
                    regex,
                    alignment_anchor_fallback,
                    apply_alignment_regex_to_summary_rows,
                    max_data_column_widths[j],
                    line_breaks,
                )
            end
        end
    end

    # == Compute the Column Width ==========================================================

    row_number_column_width, row_label_column_width, printed_data_column_widths = _text__printed_column_widths(
        table_data,
        row_labels,
        column_labels,
        summary_rows,
        summary_row_labels,
        table_str,
        vertical_lines_at_data_columns,
        column_label_width_based_on_first_line_only,
        line_breaks,
        min_data_column_widths,
    )

    # Now, we crop the additional column labels if the user wants to do so. Notice that a
    # merged column label is stored in its first column and it must be cropped to the width
    # of all the spanned columns.
    if column_label_width_based_on_first_line_only && !isnothing(column_labels)
        for j in axes(column_labels, 2), i in axes(column_labels, 1)
            j₀, j₁ = _column_label_limits(table_data, i, j)
            j != j₀ && continue

            cw = _text__span_width(
                printed_data_column_widths,
                j₀,
                min(j₁, num_printed_data_columns),
                vertical_lines_at_data_columns,
            )

            column_labels[i, j] = _text__fit_cell_in_maximum_cell_width(
                column_labels[i, j], cw, false
            )
        end
    end

    # If the user wants a fixed column width, we must reprocess all the data columns to crop
    # to the correct size if necessary.
    #
    # TODO: This can be integrated in the first column width computation!
    if has_fixed_data_column_widths
        _text__fix_data_column_widths!(
            printed_data_column_widths,
            table_data,
            column_labels,
            table_str,
            summary_rows,
            fix_data_column_widths,
            vertical_lines_at_data_columns,
            auto_wrap,
            line_breaks,
            equal_data_column_widths,
        )

    elseif equal_data_column_widths
        # If the user wants equal data column widths, make every column width equal to the
        # largest one. Notice that `init` is required because the table can have no columns
        # at all.
        printed_data_column_widths .= maximum(printed_data_column_widths; init = 0)
    end

    # == Row Group Labels ==================================================================

    # The row group labels span the entire table. Hence, if a printed label is wider than
    # the table, we must widen the data columns, distributing the additional width among
    # the ones without a fixed width. Otherwise, the label is cropped when printed. Notice
    # that the continuation column is not considered here because it depends on the
    # horizontal printing limit, which depends on the column widths.
    if _has_row_group_labels(table_data) && (num_printed_data_columns > 0)
        available_width =
            _text__table_width_wo_cont_column(
                table_data,
                tf,
                vertical_lines_at_data_columns,
                row_number_column_width,
                row_label_column_width,
                printed_data_column_widths,
            ) -
            tf.vertical_line_at_beginning -
            tf.vertical_line_after_data_columns -
            2

        Δw = _text__row_group_labels_width(table_data, rctx, renderer) - available_width

        if Δw > 0
            columns = if has_fixed_data_column_widths
                filter(j -> fix_data_column_widths[j] <= 0, 1:num_printed_data_columns)
            else
                1:num_printed_data_columns
            end

            n = length(columns)

            # The remainder of the division is added to the last columns.
            for (k, j) in enumerate(columns)
                printed_data_column_widths[j] += div(Δw, n) + (k > n - rem(Δw, n))
            end
        end
    end

    # == Horizontal Printing Limit =========================================================

    # In text back end, the printed column can be limited either by the user specification
    # or by the display limit. Now, we have access to the width of all candidate columns to
    # be printed. Hence, we can update the number of printed columns accordingly. Notice
    # that we also must analyze if the table continuation column is required since in text
    # back end we also have the continuation caused by the display end-of-line.

    # Compute the required width to display the table using the user specification without
    # the continuation column.
    table_width_wo_cont_col = _text__table_width_wo_cont_column(
        table_data,
        tf,
        vertical_lines_at_data_columns,
        row_number_column_width,
        row_label_column_width,
        printed_data_column_widths,
    )

    # We need to check if we are limiting the number of columns by the display or by the
    # user specification.
    horizontally_limited_by_display = _text__is_printing_horizontally_limited(
        table_data,
        fit_table_in_display_horizontally,
        display.size[2],
        num_printed_data_columns,
        table_width_wo_cont_col,
    )

    # If we are limited by the display, we need to update the number of printed columns and
    # rows.
    if horizontally_limited_by_display
        # Check if the user selects one visible column to shrink to fit the table in the
        # display.
        if (1 <= shrinkable_data_column <= num_printed_data_columns)
            # Number of characters we should remove from the shrinkable data column to fit
            # the table in the display, including the continuation column, if any.
            Δc = table_width_wo_cont_col - display_size[2]

            _is_horizontally_cropped(table_data) &&
                (Δc += 3 + tf.vertical_line_after_continuation_column)

            # Compute the new column width.
            cw = max(
                1,
                shrinkable_column_minimum_width,
                printed_data_column_widths[shrinkable_data_column] - Δc,
            )

            printed_data_column_widths[shrinkable_data_column] = cw

            # Shrink the column labels.
            if !isnothing(column_labels)
                for i in 1:size(column_labels, 1)
                    # Compute the column limits of this column label.
                    j₀, j₁ = _column_label_limits(table_data, i, shrinkable_data_column)

                    # Compute the available width, making sure we are not accessing a
                    # column out of the bounds.
                    j₁ = min(j₁, num_printed_data_columns)
                    cell_width = _text__span_width(
                        printed_data_column_widths, j₀, j₁, vertical_lines_at_data_columns
                    )

                    # We need to modify the first field of this column label to take into
                    # account merged labels.
                    column_labels[i, j₀] = _text__fit_cell_in_maximum_cell_width(
                        column_labels[i, j₀], cell_width, line_breaks
                    )
                end
            end

            # Shrink the data cells.
            for i in 1:num_printed_data_rows
                table_str[i, shrinkable_data_column] = _text__fit_cell_in_maximum_cell_width(
                    table_str[i, shrinkable_data_column],
                    printed_data_column_widths[shrinkable_data_column],
                    line_breaks,
                )
            end

            # Shrink the summary rows.
            if !isnothing(summary_rows)
                for i in 1:size(summary_rows, 1)
                    summary_rows[i, shrinkable_data_column] = _text__fit_cell_in_maximum_cell_width(
                        summary_rows[i, shrinkable_data_column],
                        printed_data_column_widths[shrinkable_data_column],
                        line_breaks,
                    )
                end
            end
        end

        # Since the table width has changed, we must recompute the following variables.
        num_printed_data_columns = _text__number_of_printed_data_columns(
            display.size[2],
            table_data,
            tf,
            vertical_lines_at_data_columns,
            row_number_column_width,
            row_label_column_width,
            printed_data_column_widths,
        )

        # `table_str` was rendered using an earlier, coarser estimate of the number of
        # columns. Hence, we must never claim to print more columns than were actually
        # rendered. Otherwise, the main loop would emit one `:data` action too many and index
        # past the end of `table_str` and `printed_data_column_widths`.
        table_data.maximum_number_of_columns = min(
            num_printed_data_columns + 1, table_data.num_columns, size(table_str, 2)
        )

        horizontally_limited_by_display = _text__is_printing_horizontally_limited(
            table_data,
            fit_table_in_display_horizontally,
            display.size[2],
            num_printed_data_columns,
            table_width_wo_cont_col,
        )
    end

    # == Omitted Columns ===================================================================

    # If this is the very first row, we must check if a horizontal line must be printed.
    num_omitted_data_columns = table_data.num_columns - num_printed_data_columns
    num_omitted_data_rows    = table_data.num_rows - num_printed_data_rows

    # If data columns are omitted, the omitted cell summary is printed even if the table is
    # not cropped vertically. Hence, if the vertical cropping design did not consider this
    # line and its result would change, we must restart the process considering it. Notice
    # that the rendering must be restarted because, in the middle cropping, the rendered
    # rows depend on the number of printed rows. When we have line breaks, the vertical
    # cropping is designed again below.
    if (
        !omitted_columns &&
        (num_omitted_data_columns > 0) &&
        pspec.show_omitted_cell_summary &&
        fit_table_in_display_vertically &&
        (display_size[1] > 0) &&
        !line_breaks
    )
        current_maximum_number_of_rows    = table_data.maximum_number_of_rows
        table_data.maximum_number_of_rows = user_maximum_number_of_rows

        new_design = _text__design_vertical_cropping(
            table_data,
            tf,
            horizontal_lines_at_column_labels,
            horizontal_lines_at_data_rows,
            pspec.show_omitted_cell_summary,
            display.size[1],
            pspec.new_line_at_end,
            true,
        )

        old_design = (
            mr,
            suppress_hline_before_continuation_row,
            suppress_hline_after_continuation_row,
        )

        if new_design != old_design
            table_data.maximum_number_of_columns = user_maximum_number_of_columns
            table_data.vertical_crop_mode        = user_vertical_crop_mode
            return _text__print_table_core(pspec, opts, true)
        end

        table_data.maximum_number_of_rows = current_maximum_number_of_rows
    end

    # We must compute what will be the last printed column index to draw the correct
    # vertical lines. Notice that, at this point, we might be printing a column partially.
    last_printed_column_index = if horizontally_limited_by_display
        table_data.maximum_number_of_columns
    else
        num_printed_data_columns
    end

    # Never index past what was actually rendered.
    last_printed_column_index = min(last_printed_column_index, size(table_str, 2))

    # Finally, we can compute the printed table width.
    printed_table_width = table_width_wo_cont_col

    if _is_horizontally_cropped(table_data)
        printed_table_width += 3 + tf.vertical_line_after_continuation_column
    end

    if horizontally_limited_by_display
        printed_table_width = display_size[2]
    end

    # == Vertical Cropping Design with Line Breaks =========================================

    # Up to now, we consider that each table row has only one line. Now that we know how
    # many columns we must print, we can redesign the vertical cropping if the user wants
    # line breaks. In this case, we will analyze each line and check how many data rows we
    # can print considering the multiple lines.

    if fit_table_in_display_vertically && (display_size[1] > 0) && line_breaks
        num_design_rows = size(table_str, 1)

        # If the user cropped the table in the middle, the rendered rows are the ones at the
        # beginning and at the end of the table. If this table does not fit in the display,
        # we must crop it at the bottom, which is the only mode supported with line breaks,
        # using only the rendered rows at the beginning of the table.
        if (table_data.vertical_crop_mode == :middle) && _is_vertically_cropped(table_data)
            middle_cropped_table_lines = _text__middle_cropped_table_lines(
                table_data,
                table_str,
                tf,
                horizontal_lines_at_column_labels,
                horizontal_lines_at_data_rows,
                pspec.show_omitted_cell_summary,
                pspec.new_line_at_end,
                last_printed_column_index,
            )

            if middle_cropped_table_lines > display.size[1]
                num_design_rows = div(num_design_rows, 2, RoundUp)
                table_data.vertical_crop_mode = :bottom
                table_data.maximum_number_of_rows = num_design_rows
            else
                # The lines of the middle cropping were counted without suppressing any
                # horizontal line.
                suppress_hline_before_continuation_row = false
                suppress_hline_after_continuation_row  = false
            end
        end
    end

    if (
        fit_table_in_display_vertically &&
        (display_size[1] > 0) &&
        line_breaks &&
        (table_data.vertical_crop_mode == :bottom || !_is_vertically_cropped(table_data))
    )
        # Notice that `mr` contains the number of fully printed data rows. Furthermore, if
        # `lrc` is `true`, the last row is cropped, meaning that we need to print `mr + 1`
        # rows from the rendered table.
        mr, lrc, suppress_hline_before_continuation_row = _text__design_vertical_cropping_with_line_breaks(
            table_data,
            @view(table_str[1:num_design_rows, :]),
            tf,
            horizontal_lines_at_column_labels,
            horizontal_lines_at_data_rows,
            pspec.show_omitted_cell_summary,
            display.size[1],
            pspec.new_line_at_end,
            last_printed_column_index,
            num_omitted_data_columns > 0,
        )

        # Notice that the maximum number of rows is not negative here because it was set by
        # the preliminary design.
        vertically_limited_by_display =
            vertically_limited_by_display || (mr < table_data.maximum_number_of_rows)

        table_data.maximum_number_of_rows = min(table_data.maximum_number_of_rows, mr + lrc)

        # Now that we have the number of fully printed data rows, we must update those
        # variables.
        num_printed_data_rows = table_data.maximum_number_of_rows
        num_omitted_data_rows = table_data.num_rows - mr

        # Only the bottom cropping is supported if the display crops a table with line
        # breaks. Notice that, if the table was not cropped by the user, all the rows were
        # rendered in order.
        _is_vertically_cropped(table_data) && (table_data.vertical_crop_mode = :bottom)
    end

    # == Print the Table ===================================================================

    # If the table has a continuation column, the vertical line after the data columns is
    # not at the right edge of the table. We compute this information here to select the
    # correct vertical line character inside the loop.
    table_continuation_column = _is_horizontally_cropped(table_data)

    # The row group labels span the entire table. Hence, the vertical line after them is the
    # one at the right edge of the table, which is not printed if the display crops the
    # table. Notice that the width of the label must not include the vertical lines at the
    # edges of the table and the margins.
    row_group_label_vline = !horizontally_limited_by_display && (
        table_continuation_column ?
        tf.vertical_line_after_continuation_column :
        tf.vertical_line_after_data_columns
    )

    row_group_label_width =
        printed_table_width - tf.vertical_line_at_beginning - row_group_label_vline - 2

    ps     = PrintingTableState()
    action = :initialize

    # We must store the index related to the rendered tables. These indices differ from the
    # actual table indices due to cropping.
    ir = jr = 0

    # Variable to store how many data lines were printed.
    num_data_lines = 0

    top_line_printed = false

    # Those variables are used to process rows with multiple lines.
    #
    # Number of lines in the current row. It is computed by the maximum number of lines
    # inside a data cell in a specific row.
    num_lines_in_row = 0

    # Number of lines available in the display for the data section. Notice that it only
    # makes sense if the display is limiting the table.
    num_available_data_section_lines = if vertically_limited_by_display
        _, num_lines_before_data, num_lines_after_data = _text__number_of_required_lines(
            table_data,
            tf,
            horizontal_lines_at_column_labels,
            horizontal_lines_at_data_rows,
            pspec.new_line_at_end,
        )

        (
            display.size[1] - num_lines_before_data - num_lines_after_data -
            pspec.show_omitted_cell_summary - 1 # ........................................................... Continuation row
        )
    else
        0
    end

    # Number of lines printed in data section, including horizontal lines and row group
    # labels.
    num_printed_data_section_lines = 0

    # Stored state at the beginning of the row with multiple lines. We use those values to
    # reiterate the printing state until we have no more new rows.
    saved_ps = PrintingTableState()
    saved_ir = 0

    # Current row line that is being printed. If it is 0, the current row does not have
    # multiple lines.
    current_row_line = 0

    tokens = if !line_breaks
        nothing
    else
        Vector{Vector{SubString{String}}}(undef, last_printed_column_index)
    end

    # The highlighters must receive the object the user passed to `pretty_table`, not the
    # internal table wrapper. Notice that this is loop invariant.
    orig_data = _get_data(table_data.data)

    while action != :end_printing
        if current_row_line == 0
            saved_ps = ps
            saved_ir = ir
        end

        action, rs, ps = _next(ps, table_data)

        ir, jr = _update_data_cell_indices(action, rs, ps, ir, jr)

        action == :end_printing && break

        # If we already printed the number of available lines in data section, skip
        # everything until we exit the data section.
        if line_breaks &&
            (rs == :data) &&
            (num_available_data_section_lines > 0) &&
            (num_printed_data_section_lines >= num_available_data_section_lines)
            current_row_line = 0
            continue
        end

        # == Table Header and Footer =======================================================

        if rs == :table_header
            if action ∈ (:title, :subtitle)
                alignment     = _current_cell_alignment(action, ps, table_data)
                cell          = _current_cell(action, ps, table_data)
                decoration    = action == :title ? rstyle.title : rstyle.subtitle
                rendered_cell = _text__render_cell(cell, rctx, renderer) *
                    _text__footnote_marks(table_data, action, ps.i, ps.j)

                _text__print_aligned(
                    display,
                    rendered_cell,
                    printed_table_width,
                    alignment,
                    decoration,
                    false,
                )
                _text__flush_line(display)
            end

            continue

        elseif rs == :table_footer
            if action == :footnote
                alignment  = _current_cell_alignment(action, ps, table_data)
                decoration = rstyle.footnote

                _text__print_aligned(
                    display,
                    footnotes[ps.i],
                    printed_table_width,
                    alignment,
                    decoration,
                    false,
                )
                _text__flush_line(display)

            elseif action == :source_notes
                alignment     = _current_cell_alignment(action, ps, table_data)
                cell          = _current_cell(action, ps, table_data)
                decoration    = rstyle.source_note
                rendered_cell = _text__render_cell(cell, rctx, renderer)

                _text__print_aligned(
                    display,
                    rendered_cell,
                    printed_table_width,
                    alignment,
                    decoration,
                    false,
                )
                _text__flush_line(display)
            end

            continue
        end

        # == New Row =======================================================================

        if action == :new_row

            # If the table begins with a row group label, which happens when the column
            # labels are hidden, there is nothing above it to separate. Hence, the line
            # before it is not drawn, and the top line, if any, has no intersections.
            first_row_group_label = (rs == :row_group_label) && (ps.i == 1) &&
                !table_data.show_column_labels

            # If this is the very first row, we must check if a horizontal line must be
            # printed.
            if tf.horizontal_line_at_beginning && !top_line_printed
                _text__print_horizontal_line(
                    display,
                    tf,
                    rl.top,
                    table_data,
                    vertical_lines_at_data_columns,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths;
                    top = true,
                    column_label_row = first_row_group_label ? nothing : ir - 1,
                    top_row_group_label = first_row_group_label,
                )

                _text__flush_line(display, false)

                top_line_printed = true
            end

            if (rs == :row_group_label) && !first_row_group_label
                # We must draw the horizontal line here if the user requested, if the last
                # row has a horizontal line due to the intersections, or if the last row was
                # a column label and the user wants a line after it. Notice that `ps.i` is
                # the data index of the row after the label, which differs from the rendered
                # index `ir` in the middle cropping.
                if tf.horizontal_line_before_row_group_label ||
                    (ps.i - 1 ∈ horizontal_lines_at_data_rows) || (
                        (ps.i == 1) &&
                        table_data.show_column_labels &&
                        tf.horizontal_line_after_column_labels
                    )
                    _text__print_horizontal_line(
                        display,
                        tf,
                        rl.middle,
                        table_data,
                        vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths;
                        top = true,
                        row_group_label = true,
                    )

                    _text__flush_line(display, false)
                    num_printed_data_section_lines += 1
                end
            end

            # Check if we need to start processing multiple row lines.
            if line_breaks && (rs == :data) && (current_row_line == 0)
                # NOTE: Only the columns that are actually printed may contribute to the
                # height of the row. Otherwise, a column cropped away horizontally could add
                # spurious blank lines. This also avoids allocating a `Vector` per row.
                num_lines_in_row = 1

                for jt in 1:last_printed_column_index
                    n = count(==('\n'), table_str[ir, jt]) + 1
                    n > num_lines_in_row && (num_lines_in_row = n)
                end
                current_row_line = 1

                # Obtain the tokens for each line.
                for jt in eachindex(tokens)
                    tokens[jt] = split(table_str[ir, jt], '\n')
                end
            end

            tf.vertical_line_at_beginning &&
                _text__styled_print(display, rl.left)

            continue
        end

        # == Continuation Row ==============================================================

        if action == :diagonal_continuation_cell
            _text__print(display, " ⋱ ")
            tf.vertical_line_after_continuation_column &&
                _text__styled_print(display, rl.right)
            continue

        elseif action == :horizontal_continuation_cell
            _text__print(display, " ⋯ ")
            tf.vertical_line_after_continuation_column &&
                _text__styled_print(display, rl.right)
            continue

        elseif action ∈ _VERTICAL_CONTINUATION_CELL_ACTIONS
            alignment  = _current_cell_alignment(action, ps, table_data)
            vl         = rl.center

            if action == :row_number_vertical_continuation_cell
                cell_width = row_number_column_width
                vline      = tf.vertical_line_after_row_number_column

            elseif action == :row_label_vertical_continuation_cell
                cell_width = row_label_column_width
                vline      = tf.vertical_line_after_row_label_column

            else
                cell_width = printed_data_column_widths[jr]
                vline, vl  = _text__vertical_line_after_data_column(
                    tf,
                    rl,
                    jr,
                    ps.j,
                    last_printed_column_index,
                    vertical_lines_at_data_columns,
                    table_continuation_column,
                )
            end

            _text__print_aligned(
                display, "⋮", cell_width, alignment; left_margin = 1, right_margin = 1
            )
            vline && _text__styled_print(display, vl)

            continue
        end

        # == End Row =======================================================================

        if action == :end_row
            _, next_rs, _ = _next(ps, table_data)

            if rs == :data
                num_data_lines += 1
                num_printed_data_section_lines += 1
            elseif rs == :row_group_label
                num_printed_data_section_lines += 1
            end

            # == Flush the Line ============================================================

            if rs == :continuation_row
                _text__flush_line(display, true, '⋱')

            elseif rs == :data
                _text__flush_line(
                    display,
                    true,
                    (num_data_lines - 1) % (tf.ellipsis_line_skip + 1) == 0 ? '⋯' : ' ',
                )

            else
                _text__flush_line(display)
            end

            # Check if we must render another line for this row or if we should go to the
            # next row.
            if current_row_line > 0
                current_row_line += 1

                if current_row_line <= num_lines_in_row
                    # If we reached this point, we must render another line of the same row.
                    # Hence, we will restore that saved state at the beginning of the line,
                    # and render it again. Since we increased `current_row_line`, we will
                    # render the next line of the same row.
                    ps = saved_ps
                    ir = saved_ir
                    continue
                end

                # If we reached this point, we finished rendering the row.
                current_row_line = 0
            end

            # == Handle the Horizontal Lines ===============================================

            # Line to draw after the current row, if any, and its options.
            hline            = nothing
            bottom           = false
            row_group_label  = false
            column_label_row = nothing
            count_line       = false

            if (rs == :column_labels) && (next_rs == :column_labels)
                if (ps.i ∈ horizontal_lines_at_column_labels)
                    hline            = rl.header
                    column_label_row = ps.i

                elseif tf.horizontal_line_at_merged_column_labels &&
                    _has_merged_cells(table_data, ps.i)
                    _text__print_column_label_horizontal_line_only_at_merged_labels(
                        display,
                        tf,
                        rl,
                        table_data,
                        ps.i,
                        vertical_lines_at_data_columns,
                        row_number_column_width,
                        row_label_column_width,
                        printed_data_column_widths,
                    )
                    _text__flush_line(display, false)
                end

            # Print the horizontal line after the column labels.
            elseif (rs == :column_labels) &&
                (next_rs != :column_labels) &&
                tf.horizontal_line_after_column_labels

                # We should skip this line if we have a row group label at the first column.
                if next_rs != :row_group_label
                    # We must handle that case where there are no data rows. In this case,
                    # the next section after the column labels will be the table footer or
                    # the end of printing.
                    bottom           = next_rs ∈ (:table_footer, :end_printing)
                    hline            = bottom ? rl.bottom : rl.header
                    column_label_row = length(table_data.column_labels)
                end

            # Check if we must print a horizontal line after the current data row.
            elseif (rs == :data) && (ps.i ∈ horizontal_lines_at_data_rows)
                # We should only print this line if the next state is not the continuation
                # row or if we do not need to suppress the line before the continuation row.
                # We also skip it if the next data row has a row group label, which draws its
                # own line. Notice that the vertical cropping design relies on this rule even
                # if the next data row is omitted.
                if !(
                    (next_rs == :continuation_row) && suppress_hline_before_continuation_row
                ) && !_print_row_group_label(table_data, ps.i + 1)
                    hline      = rl.middle
                    count_line = true
                end

            elseif (rs == :data) &&
                (next_rs ∈ (:summary_row, :table_footer, :end_printing)) &&
                tf.horizontal_line_after_data_rows
                bottom     = next_rs ∈ (:table_footer, :end_printing)
                hline      = bottom ? rl.bottom : rl.middle
                count_line = true

            elseif (rs ∈ (:data, :continuation_row)) &&
                (next_rs == :summary_row) &&
                tf.horizontal_line_before_summary_rows
                hline            = rl.middle
                column_label_row = length(table_data.column_labels)

            # Check if we must print a horizontal line after the continuation row.
            elseif rs == :continuation_row
                bottom = next_rs ∈ (:table_footer, :end_printing)

                # In the middle cropping, `ps.i` is the data row before the first row printed
                # after the continuation row. Notice that a row group label draws its own
                # line, that only this line can be suppressed to fit the table in the
                # display, and that the line after the data rows is only drawn if the data
                # section ends here.
                if (
                    (ps.i ∈ horizontal_lines_at_data_rows) &&
                    (next_rs == :data) &&
                    !suppress_hline_after_continuation_row
                ) || (
                    (next_rs ∈ (:summary_row, :table_footer, :end_printing)) &&
                    tf.horizontal_line_after_data_rows
                )
                    hline = bottom ? rl.bottom : rl.middle
                end

            elseif (rs == :row_group_label)
                if tf.horizontal_line_after_row_group_label
                    hline           = rl.middle
                    bottom          = true
                    row_group_label = true
                    count_line      = true
                end

            # Check if we must print the horizontal line at the end of the table.
            elseif (rs == :summary_row) && (next_rs != :summary_row)
                # If the next section is the table footer, we must draw the last table line.
                if tf.horizontal_line_after_summary_rows
                    hline  = rl.bottom
                    bottom = true
                end
            end

            if !isnothing(hline)
                _text__print_horizontal_line(
                    display,
                    tf,
                    hline,
                    table_data,
                    vertical_lines_at_data_columns,
                    row_number_column_width,
                    row_label_column_width,
                    printed_data_column_widths;
                    bottom,
                    row_group_label,
                    column_label_row,
                )

                _text__flush_line(display, false)
                count_line && (num_printed_data_section_lines += 1)
            end

            # == Omitted Cell Summary ======================================================

            # We also must show the omitted cell summary if the user requested it.
            if (next_rs == :table_footer) && pspec.show_omitted_cell_summary
                ocs = _omitted_cell_summary(num_omitted_data_rows, num_omitted_data_columns)

                isempty(ocs) && continue

                _text__print_aligned(
                    display, ocs, printed_table_width, :r, rstyle.omitted_cell_summary
                )

                _text__flush_line(display; crop_line = false)
            end

            continue
        end

        # == Table Cells ===================================================================

        # If we reach this point, we are processing table cells.

        # Notice that we only fetch the current cell in the branches that require the live
        # object. All the other sections were already rendered by `_text__render_table`,
        # and fetching the cell again would re-run the formatters and the summary row
        # functions, duplicating the work and the accesses to the user data.
        alignment     = _current_cell_alignment(action, ps, table_data)
        cell_width    = 1
        decoration    = ""
        # NOTE: The type assertion keeps the per-cell loop free of dynamic dispatches. The
        # generic `_text__render_cell` and the custom text cell API have no return type
        # annotation on their user-facing side, so inference would otherwise give `Any`
        # here. The union is concrete and small, and it avoids one string copy per line
        # when a cell line is a `SubString`.
        rendered_cell::Union{String, SubString{String}} = ""
        vline         = false
        vl            = rl.center

        mc_last_index = 0
        merged_cell   = false

        # -- Width, Decoration, and Rendered String ----------------------------------------

        if action == :row_number_label
            cell          = _current_cell(action, ps, table_data)
            cell_width    = row_number_column_width
            decoration    = rstyle.row_number_label
            rendered_cell = _text__render_cell(cell, rctx, renderer)

        elseif action == :stubhead_label
            cell          = _current_cell(action, ps, table_data)
            cell_width    = row_label_column_width
            decoration    = rstyle.stubhead_label
            rendered_cell = _text__render_cell(cell, rctx, renderer)

        elseif action == :row_label
            cell_width    = row_label_column_width
            decoration    = rstyle.row_label
            rendered_cell = row_labels[ir]

        elseif action == :summary_row_number
            cell_width    = row_number_column_width
            rendered_cell = ""

        elseif action == :summary_row_label
            cell_width    = row_label_column_width
            decoration    = rstyle.summary_row_label
            rendered_cell = summary_row_labels[ir]

        elseif action == :column_label
            # The live cell is required here to check for merged cells.
            cell          = _current_cell(action, ps, table_data)
            cell_width    = printed_data_column_widths[jr]
            rendered_cell = column_labels[ir, jr]
            decoration    = if ir == 1
                if rstyle.first_line_column_label isa String
                    rstyle.first_line_column_label
                else
                    rstyle.first_line_column_label[jr]
                end
            else
                if rstyle.column_label isa String
                    rstyle.column_label
                else
                    rstyle.column_label[jr]
                end
            end

            cell === _IGNORE_CELL && continue

            if cell isa MergeCells
                alignment = cell.alignment

                j₀ = jr
                j₁ = min(jr + cell.column_span - 1, last_printed_column_index)

                cell_width = _text__span_width(
                    printed_data_column_widths, j₀, j₁, vertical_lines_at_data_columns
                )

                # We must store that this is a merged cell and also what is the last column
                # index of it. It is necessary when drawing the vertical lines. The user
                # can ask to suppress all the vertical lines in the column labels. In
                # this case, we will draw only the very last one if necessary. Thus, we must
                # know if we are at the last cell when drawing a merged cell.
                merged_cell   = true
                mc_last_index = j₁

                # Apply the correct decoration.
                decoration = if ir == 1
                    rstyle.first_line_merged_column_label
                else
                    rstyle.merged_column_label
                end
            end

        elseif action == :row_number
            # The row number is an integer. Hence, we can convert it directly, avoiding a
            # call to the generic rendering function.
            cell_width    = row_number_column_width
            decoration    = rstyle.row_number
            rendered_cell = string(ps.i - 1 + table_data.first_row_index) *
                _text__footnote_marks(table_data, action, ps.i, ps.j)

        elseif action == :data
            # Custom text cells were recorded during the rendering pass, avoiding a new
            # fetch that would re-run the formatters.
            cell = isnothing(custom_cells) ? nothing : get(custom_cells, (ir, jr), nothing)

            if cell isa AbstractCustomTextCell
                cell_width = printed_data_column_widths[jr]

                # The rendered cell text can be cropped, e.g., by a fixed or maximum width or
                # by the shrinkable column. Hence, we must regenerate the printable cell text.
                # Otherwise, we would measure a cropped string and we would not call the API
                # functions to actually reduce the rendered string width.
                if !line_breaks || (current_row_line == 1)
                    table_str[ir, jr] = CustomTextCell.printable_cell_text(cell)

                    # Here, we have line breaks and we are in the first line. Hence, we must
                    # regenerate the line tokens.
                    line_breaks && (tokens[jr] = split(table_str[ir, jr], '\n'))
                end

                # We need to manually align the string by adding left and right padding.
                printable_cell = if !line_breaks
                    table_str[ir, jr]
                else
                    if current_row_line <= length(tokens[jr])
                        tokens[jr][current_row_line]
                    else
                        ""
                    end
                end

                tw = printable_textwidth(printable_cell)

                if tw > cell_width
                    CustomTextCell.crop!(cell, tw - cell_width + 1)
                    CustomTextCell.add_suffix!(cell, "…")
                    CustomTextCell.left_padding!(cell, 0)
                    CustomTextCell.right_padding!(cell, 0)
                else
                    # The cropping must be reset because it can remain from another line of
                    # this cell or from another position of the same cell object.
                    CustomTextCell.crop!(cell, 0)
                    CustomTextCell.add_suffix!(cell, "")

                    # The custom cell must fill the entire space, leading to a correct cell
                    # decoration.
                    Δ = cell_width - tw

                    # NOTE: `_text__print_aligned` rounds the left margin **down** when
                    # centering. Hence, a custom text cell must do the same, or a plain
                    # string and a custom cell with the same content would be centered
                    # differently in the same column.
                    left_padding = if alignment == :r
                        Δ
                    elseif alignment == :c
                        div(Δ, 2)
                    else
                        0
                    end

                    CustomTextCell.left_padding!(cell, left_padding)
                    CustomTextCell.right_padding!(cell, Δ - left_padding)
                end

                rendered_cell = if !line_breaks
                    CustomTextCell.rendered_cell(cell)
                else
                    CustomTextCell.rendered_cell_line(cell, current_row_line)
                end
            else
                cell_width    = printed_data_column_widths[jr]
                rendered_cell = if line_breaks
                    tokens_jr = tokens[jr]

                    if current_row_line <= length(tokens_jr)
                        tokens_jr[current_row_line]
                    else
                        ""
                    end
                else
                    table_str[ir, jr]
                end
            end

            # Check if we must apply highlighters.
            if !isempty(highlighters)
                di, dj = _data_indices(table_data, ps.i, ps.j)

                for h in highlighters
                    if h.f(orig_data, di, dj)
                        decoration = _text__highlighter_sgr(h, orig_data, di, dj)
                        break
                    end
                end
            end

        elseif action == :summary_row_cell
            cell_width    = printed_data_column_widths[jr]
            decoration    = rstyle.summary_row_cell
            rendered_cell = summary_rows[ir, jr]

        elseif action == :row_group_label
            cell          = _current_cell(action, ps, table_data)
            cell_width    = row_group_label_width
            decoration    = rstyle.row_group_label

            # The label is cropped if the table could not be widened to fit it, e.g., if
            # the data columns have fixed widths.
            rendered_cell = _text__fit_cell_in_maximum_cell_width(
                _text__render_cell(cell, rctx, renderer), cell_width, false
            )
        end

        # If we have multiple lines and we are not rendering a data cell, we must only
        # render it at the first line.
        if (current_row_line >= 2) && (action != :data)
            rendered_cell = ""
        end

        # -- Vertical Line After the Cell --------------------------------------------------

        if action ∈ (:row_number_label, :row_number, :summary_row_number)
            tf.vertical_line_after_row_number_column && (vline = true)

        elseif action ∈ (:stubhead_label, :row_label, :summary_row_label)
            tf.vertical_line_after_row_label_column && (vline = true)

        elseif action == :column_label
            # A merged cell ends at its last column.
            last_jr = merged_cell ? mc_last_index : jr

            vline, vl = _text__vertical_line_after_data_column(
                tf,
                rl,
                last_jr,
                ps.j,
                last_printed_column_index,
                vertical_lines_at_data_columns,
                table_continuation_column,
            )

            # The suppressed vertical lines inside the column labels must keep the default
            # border style so that a line design or face never modifies the blank space.
            if vline &&
                tf.suppress_vertical_lines_at_column_labels &&
                (last_jr != last_printed_column_index)
                vl = TextVerticalLine(' ', rstyle.table_border)
            end

        # NOTE: `:column_label` is fully consumed by the branch above, which is also the one
        # that honors `suppress_vertical_lines_at_column_labels`, and which uses the
        # merged-cell-aware last column index. Hence, it must not be listed here.
        elseif action ∈ (:data, :summary_row_cell)
            vline, vl = _text__vertical_line_after_data_column(
                tf,
                rl,
                jr,
                ps.j,
                last_printed_column_index,
                vertical_lines_at_data_columns,
                table_continuation_column,
            )

        elseif action == :row_group_label
            if row_group_label_vline
                vline = true
                vl    = rl.right
            end
        end

        _text__print_aligned(
            display,
            rendered_cell,
            cell_width,
            alignment,
            decoration,
            true;
            left_margin = 1,
            right_margin = 1,
        )

        vline && _text__styled_print(display, vl)
    end

    # == Print the Buffer Into the IO ======================================================

    output_str = String(take!(buf_io))

    if !pspec.new_line_at_end
        output_str = chomp(output_str)
    end

    if overwrite_display
        # We must move the cursor up and erase one line for each line in the output. If the
        # table does not end with a new line, the cursor is at its last line, which must
        # also be erased.
        num_new_lines = count(==('\n'), output_str)
        clear_str     = pspec.new_line_at_end ? "" : "\r\e[2K"
        print(context, clear_str * "\e[1F\e[2K"^num_new_lines * output_str)
    else
        print(context, output_str)
    end

    return nothing
end
