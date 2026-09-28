############################################################################################
#
# Functions to compute the printed column widths.
#
############################################################################################

"""
    _text__fix_data_column_widths!(
        printed_data_column_widths::Vector{Int},
        table_data::TableData,
        column_labels::Union{Nothing, Matrix{String}},
        table_str::Matrix{String},
        summary_rows::Union{Nothing, Matrix{String}},
        fixed_data_column_widths::AbstractVector{Int},
        vertical_lines_at_data_columns::AbstractVector{Int},
        auto_wrap::Bool,
        line_breaks::Bool
    ) -> Nothing

Fix the data column widths given the user specification. This function also crops the cells
at the data columns to fit the fixed width.

# Arguments

- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
- `table_data::TableData`: Table data.
- `column_labels::Union{Nothing, Matrix{String}}`: Column labels.
- `table_str::Matrix{String}`: Rendered data cells.
- `summary_rows::Union{Nothing, Matrix{String}}`: Summary rows.
- `fixed_data_column_widths::AbstractVector{Int}`: Fixed data column widths.
- `vertical_lines_at_data_columns::AbstractVector{Int}`: List of columns where a vertical
    line must be drawn after the cell. It is required to compute the available width of
    merged column labels.
- `auto_wrap::Bool`: If `true`, the strings will be auto wrapped at each column with a fixed
    width.
- `line_breaks::Bool`: If `true`, the cells will be split into multiple lines if needed.
"""
function _text__fix_data_column_widths!(
    printed_data_column_widths::Vector{Int},
    table_data::TableData,
    column_labels::Union{Nothing, Matrix{String}},
    table_str::Matrix{String},
    summary_rows::Union{Nothing, Matrix{String}},
    fixed_data_column_widths::AbstractVector{Int},
    vertical_lines_at_data_columns::AbstractVector{Int},
    auto_wrap::Bool,
    line_breaks::Bool,
)
    for j in eachindex(printed_data_column_widths)
        fcw = fixed_data_column_widths[j - 1 + begin]
        (fcw <= 0) && continue
        printed_data_column_widths[j] = fcw

        if auto_wrap
            for i in axes(table_str, 1)
                table_str[i, j] = _auto_wrap(table_str[i, j], printed_data_column_widths[j])
            end
        end
    end

    for table in (table_str, summary_rows)
        isnothing(table) && continue

        for j in axes(table, 2)
            cw = printed_data_column_widths[j]

            for i in axes(table, 1)
                table[i, j] = _text__fit_cell_in_maximum_cell_width(
                    table[i, j], cw, line_breaks
                )
            end
        end
    end

    isnothing(column_labels) && return nothing

    num_printed_data_columns = size(column_labels, 2)

    for j in axes(column_labels, 2)
        for i in axes(column_labels, 1)
            # A merged column label spans multiple columns. Hence, its available width must
            # be computed from all the spanned columns. Notice that we only need to crop the
            # cell where the merged label is stored, which is the first one.
            j₀, j₁ = _column_label_limits(table_data, i, j)

            j != j₀ && continue

            j₁ = min(j₁, num_printed_data_columns)
            cw = _text__span_width(
                printed_data_column_widths, j₀, j₁, vertical_lines_at_data_columns
            )

            column_labels[i, j] = _text__fit_cell_in_maximum_cell_width(
                column_labels[i, j], cw, line_breaks
            )
        end
    end

    return nothing
end

"""
    _text__span_width(
        widths::AbstractVector{Int},
        j₀::Int,
        j₁::Int,
        vertical_lines_at_data_columns::AbstractVector{Int}
    ) -> Int

Return the width available for the content of a cell that spans the data columns `j₀:j₁`,
whose widths are `widths`. It includes the margins and the vertical lines between the
spanned columns.
"""
function _text__span_width(
    widths::AbstractVector{Int},
    j₀::Int,
    j₁::Int,
    vertical_lines_at_data_columns::AbstractVector{Int},
)
    w = 0

    for j in j₀:j₁
        w += widths[j]
        (j != j₁) && (w += 2 + (j ∈ vertical_lines_at_data_columns))
    end

    return w
end

"""
    _text__fit_cell_in_maximum_cell_width(
        cell_str::String,
        maximum_cell_width::Int,
        line_breaks::Bool
    ) -> String

Fit the cell with text `cell_str` in a field with a maximum width `maximum_cell_width`,
cropping each line that does not fit and adding a continuation character at its end. If
`line_breaks` is `false`, `cell_str` is treated as a single line. If `maximum_cell_width` is
lower than 1, the cell is returned unchanged.
"""
function _text__fit_cell_in_maximum_cell_width(
    cell_str::String, maximum_cell_width::Int, line_breaks::Bool
)
    maximum_cell_width < 1 && return cell_str

    if !line_breaks || !occursin('\n', cell_str)
        return _text__fit_line_in_width(cell_str, maximum_cell_width)
    end

    lines = eachsplit(cell_str, '\n')
    return join((_text__fit_line_in_width(l, maximum_cell_width) for l in lines), '\n')
end

"""
    _text__fit_line_in_width(line::AbstractString, width::Int) -> String

Crop the `line` to fit in `width`, adding a continuation character at its end, if its
printable width is larger than `width`.
"""
function _text__fit_line_in_width(line::AbstractString, width::Int)
    tw = printable_textwidth(line)
    tw <= width && return String(line)
    return first(right_crop(line, tw - width + 1)) * "…"
end

"""
    _text__row_group_labels_width(
        table_data::TableData,
        rctx::RenderContext,
        renderer::Union{Val{:print}, Val{:show}}
    ) -> Int

Return the largest printable width of the row group labels that are printed, rendered using
the render context `rctx` and the `renderer`.
"""
function _text__row_group_labels_width(
    table_data::TableData, rctx::RenderContext, renderer::Union{Val{:print}, Val{:show}}
)
    _has_row_group_labels(table_data) || return 0

    num_rows         = table_data.num_rows
    num_printed_rows = _number_of_printed_data_rows(table_data)

    # Number of rows printed before the continuation row.
    num_top_rows = if table_data.vertical_crop_mode == :bottom
        num_printed_rows
    else
        div(num_printed_rows, 2, RoundUp)
    end

    # The rows after this one are printed after the continuation row.
    first_bottom_row = num_rows - (num_printed_rows - num_top_rows)

    row_group_labels = table_data.row_group_labels
    w = 0

    for (k, (i, label)) in enumerate(row_group_labels)
        ((1 <= i <= num_top_rows) || (first_bottom_row < i <= num_rows)) || continue

        # Only the first label of each row is printed.
        any(m -> first(row_group_labels[m]) == i, 1:(k - 1)) && continue

        w = max(w, printable_textwidth(_text__render_cell(label, rctx, renderer)))
    end

    return w
end

"""
    _text__printed_column_widths(
        table_data,
        row_labels,
        column_labels,
        summary_rows,
        summary_row_labels,
        table_str,
        vertical_lines_at_data_columns,
        column_label_width_based_on_first_line_only,
        line_breaks,
        minimum_data_column_widths
    )

Compute the printed column widths.

# Arguments

- `table_data::TableData`: Table data.
- `row_labels::Union{Nothing, Vector{String}}`: Rendered row labels.
- `column_labels::Union{Nothing, Matrix{String}}`: Rendered column labels.
- `summary_rows::Union{Nothing, Matrix{String}}`: Rendered summary rows.
- `summary_row_labels::Union{Nothing, Vector{String}}`: Rendered summary row labels.
- `table_str::Matrix{String}`: Rendered data cells.
- `vertical_lines_at_data_columns::AbstractVector{Int}`: List of columns where a vertical
    line must be drawn after the cell.
- `column_label_width_based_on_first_line_only::Bool`: If `true`, the column label width
    will be computed based on the first line only.
- `line_breaks::Bool`: If `true`, the cells will be split into multiple lines if needed.
    Hence, the textwidth of each line is used to compute the column width.
- `minimum_data_column_widths::AbstractVector{Int}`: Minimum data column widths.

# Returns

- `Int`: Row number column width.
- `Int`: Row label column width.
- `Vector{Int}`: Printed data column widths.
"""
function _text__printed_column_widths(
    table_data::TableData,
    row_labels::Union{Nothing, Vector{String}},
    column_labels::Union{Nothing, Matrix{String}},
    summary_rows::Union{Nothing, Matrix{String}},
    summary_row_labels::Union{Nothing, Vector{String}},
    table_str::Matrix{String},
    vertical_lines_at_data_columns::AbstractVector{Int},
    column_label_width_based_on_first_line_only::Bool,
    line_breaks::Bool,
    minimum_data_column_widths::AbstractVector{Int},
)
    num_printed_data_rows, num_printed_data_columns = size(table_str)

    row_number_column_width    = 0
    row_label_column_width     = 0
    printed_data_column_widths = zeros(Int, num_printed_data_columns)

    if table_data.show_row_number_column
        m =
            (
                _is_vertically_cropped(table_data) &&
                (table_data.vertical_crop_mode == :bottom)
            ) ? table_data.maximum_number_of_rows : table_data.num_rows

        # The printed row numbers run from `first_row_index` to `first_row_index + m - 1`,
        # which can be negative when the data has a non 1-based row axis. Notice that
        # `ndigits` must be used instead of `floor(Int, log10(x) + 1)` because the latter is
        # float-fragile, returning 19 instead of 18 for `m = 999_999_999_999_999_999`.
        f = table_data.first_row_index
        l = f + max(m, 1) - 1

        row_number_column_width = max(
            printable_textwidth(table_data.row_number_column_label),
            ndigits(f) + (f < 0),
            ndigits(l) + (l < 0),
        )

        # The row numbers with footnotes are wider because of the footnote marks.
        if !isnothing(table_data.footnotes)
            for ((section, i, _), _) in table_data.footnotes
                section === :row_number || continue
                r = i - 1 + f
                w = ndigits(r) + (r < 0)
                w += textwidth(_text__footnote_marks(table_data, :row_number, i, 0))
                row_number_column_width = max(row_number_column_width, w)
            end
        end
    end

    if !isnothing(row_labels)
        row_label_column_width = max(
            printable_textwidth(table_data.stubhead_label),
            num_printed_data_rows > 0 ? maximum(printable_textwidth, row_labels) : 0,
            if !isnothing(summary_row_labels)
                maximum(printable_textwidth, summary_row_labels)
            else
                0
            end,
        )
    end

    @views for j in last(axes(table_str))
        m = 0

        if !isnothing(column_labels)
            for i in first(axes(column_labels))
                !table_data.show_column_labels && break

                # If the user wants to crop the additional column labels, we must consider
                # only the first one here when computing the column width.
                (column_label_width_based_on_first_line_only && (i > 1)) && break

                # At first, we must neglect all the column label merged cells. Its width
                # will be taken into account at a later stage.
                _is_column_label_cell_merged(table_data, i, j) && continue

                m = max(m, printable_textwidth(column_labels[i, j]))
            end
        end

        if num_printed_data_rows > 0
            if !line_breaks
                m = max(maximum(printable_textwidth, table_str[:, j]), m)
            else
                for cell in table_str[:, j]
                    m = max(m, _maximum_textwidth_per_line(cell))
                end
            end
        end

        if _has_summary_rows(table_data)
            m = max(maximum(printable_textwidth, summary_rows[:, j]), m)
        end

        # When the table is vertically cropped, a continuation row showing `⋮` is printed in
        # every data column. Hence, the column must be wide enough to show it. Notice that
        # this only matters when nothing else contributed to the width, which happens when
        # the column labels are hidden and no data row is printed.
        _is_vertically_cropped(table_data) && (m = max(m, 1))

        mdw = minimum_data_column_widths[j - 1 + begin]

        if mdw > 0
            m = max(m, mdw)
        end

        printed_data_column_widths[j] = m
    end

    # Resize the columns based on the merged cells. Notice that we must skip this step if
    # the column labels are not rendered since we have no reference to compute the merged
    # cell width.
    if !isnothing(table_data.merge_column_label_cells) && !isnothing(column_labels)
        @views for mc in table_data.merge_column_label_cells
            mc.j > num_printed_data_columns && continue

            # If the user wants to crop the additional column labels, only the merged cells
            # at the first line must be considered.
            (column_label_width_based_on_first_line_only && (mc.i > 1)) && continue

            j₀ = mc.j
            j₁ = min(mc.j + mc.column_span - 1, num_printed_data_columns)

            total_width = _text__span_width(
                printed_data_column_widths, j₀, j₁, vertical_lines_at_data_columns
            )

            mctw = printable_textwidth(column_labels[mc.i, mc.j])

            if mctw > total_width
                Δ = div(mctw - total_width, j₁ - j₀ + 1, RoundUp)
                printed_data_column_widths[j₀:j₁] .+= Δ
            end
        end
    end

    return row_number_column_width, row_label_column_width, printed_data_column_widths
end
