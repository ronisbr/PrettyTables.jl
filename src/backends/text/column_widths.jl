############################################################################################
#
# Functions to compute the printed column widths.
#
############################################################################################

"""
    _text__fix_data_column_widths!(printed_data_column_widths::Vector{Int}, column_labels::Matrix{String}, table_str::Matrix{String}, summary_rows::Union{Nothing, Matrix{String}}, fixed_data_column_widths::AbstractVector{Int}) -> Nothing

Fix the data column widths given the user specification. This function also crops the cells
at the data columns to fit the fixed width.

# Arguments

- `printed_data_column_widths::Vector{Int}`: Printed data column widths.
- `column_labels::Matrix{String}`: Column labels.
- `table_str::Matrix{String}`: Rendered data cells.
- `summary_rows::Union{Nothing, Matrix{String}}`: Summary rows.
- `fixed_data_column_widths::AbstractVector{Int}`: Fixed data column widths.
- `auto_wrap::Bool`: If `true`, the strings will be auto wrapped at each column with a fixed
    width.
- `line_breaks::Bool`: If `true`, the cells will be split into multiple lines if needed.
"""
function _text__fix_data_column_widths!(
    printed_data_column_widths::Vector{Int},
    column_labels::Matrix{String},
    table_str::Matrix{String},
    summary_rows::Union{Nothing, Matrix{String}},
    fixed_data_column_widths::AbstractVector{Int},
    auto_wrap::Bool,
    line_breaks::Bool
)
    for j in eachindex(printed_data_column_widths)
        fcw = fixed_data_column_widths[j - 1 + begin]
        (fcw < 0) && continue
        printed_data_column_widths[j] = fixed_data_column_widths[j - 1 + begin]

        if auto_wrap
            for i in axes(table_str, 1)
                table_str[i, j] = _auto_wrap(table_str[i, j], printed_data_column_widths[j])
            end
        end
    end

    for table in (column_labels, table_str, summary_rows)
        isnothing(table) && continue

        for j in axes(table, 2)
            cw = printed_data_column_widths[j]

            for i in axes(table, 1)
                str = table[i, j]

                if !line_breaks
                    tw = printable_textwidth(str)
                    tw <= cw && continue

                    str = first(right_crop(str, tw - cw + 1))
                    str *= "…"
                    table[i, j] = str
                else
                    tokens = split(str, '\n')

                    for l in eachindex(tokens)
                        line = tokens[l]
                        tw   = printable_textwidth(line)
                        tw <= cw && continue

                        line  = first(right_crop(line, tw - cw + 1))
                        line *= "…"
                        tokens[l] = line
                    end

                    table[i, j] = join(tokens, '\n')
                end
            end
        end
    end

    return nothing
end

"""
    _text__fit_cell_in_maximum_cell_width(cell_str::String, maximum_cell_width::Int, line_breaks::Bool) -> String

Fit the cell with text `cell_str` in a field with a maximum width `maximum_cell_width`. If
`line_breaks` is `true`, the cell will be split into multiple lines before fitting it.
"""
function _text__fit_cell_in_maximum_cell_width(
    cell_str::String,
    maximum_cell_width::Int,
    line_breaks::Bool
)
    maximum_cell_width < 1 && return cell_str

    if !line_breaks
        tw = printable_textwidth(cell_str)
        tw <= maximum_cell_width && return cell_str

        cell_str, _ = right_crop(cell_str, tw - maximum_cell_width + 1)
        cell_str *= "…"
    else
        tokens = split(cell_str, '\n')
        str    = ""

        for k in eachindex(tokens)
            t  = tokens[k]
            tw = printable_textwidth(t)

            if tw > maximum_cell_width
                t = first(right_crop(t, tw - maximum_cell_width + 1))
                t *= "…"
            end

            str *= t

            if k != last(eachindex(tokens))
                str *= "\n"
            end
        end

        cell_str = str
    end

    return cell_str
end

"""
    _text__printed_column_widths(table_data::TableData, row_labels::Union{Nothing, Vector{String}}, column_labels::Union{Nothing, Matrix{String}}, summary_rows::Union{Nothing, Matrix{String}}, table_str::Matrix{String}, vertical_lines_at_data_columns::AbstractVector{Int}, column_label_width_based_on_first_line_only::Bool, line_breaks::Bool)

Compute the printed column widths.

# Arguments

- `table_data::TableData`: Table data.
- `row_labels::Union{Nothing, Vector{String}}`: Rendered row labels.
- `column_labels::Union{Nothing, Matrix{String}}`: Rendered column labels.
- `summary_rows::Union{Nothing, Vector{String}}`: Rendered summary rows.
- `table_str::Matrix{String}`: Rendered data cells.
- `vertical_lines_at_data_columns::AbstractVector{Int}`: List of columns where a vertical
    line must be drawn after the cell.
- `column_label_width_based_on_first_line_only::Bool`: If `true`, the column label width
    will be computed based on the first line only.
- `line_breaks::Bool`: If `true`, the cells will be split into multiple lines if needed.
    Hence, the textwidth of each line is used to compute the column width.

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
    table_str::Matrix{String},
    vertical_lines_at_data_columns::AbstractVector{Int},
    column_label_width_based_on_first_line_only::Bool,
    line_breaks::Bool
)
    num_printed_data_rows, num_printed_data_columns = size(table_str)

    row_number_column_width    = 0
    row_label_column_width     = 0
    printed_data_column_widths = zeros(Int, num_printed_data_columns)

    if table_data.show_row_number_column
        m = (_is_vertically_cropped(table_data) && (table_data.vertical_crop_mode == :bottom)) ?
            table_data.maximum_number_of_rows :
            table_data.num_rows

        row_number_column_width = max(
            printable_textwidth(table_data.row_number_column_label),
            floor(Int, log10(m) + 1)
        )
    end

    if !isnothing(row_labels)
        row_label_column_width = max(
            printable_textwidth(table_data.stubhead_label),

            num_printed_data_rows > 0 ? maximum(printable_textwidth, row_labels) : 0,

            if _has_summary_rows(table_data)
                maximum(printable_textwidth, table_data.summary_row_labels)
            else
                0
            end
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
                # will be taken into account at a latter stage.
                #
                # Notice that the function `_is_column_label_cell_merged` returns `true`
                # only if `(i, j)` is in the middle of the merged cell. Since a merged cell
                # spans at least two columns, if is sufficient to check if `j + 1` is in the
                # merged cell. At the left most merged column, we are in a `_IGNORE_CELL`
                # that has 0 width.
                if !_is_column_label_cell_merged(table_data, i, j + 1)
                    m = max(m, printable_textwidth(column_labels[i, j]))
                end
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

            if _has_summary_rows(table_data)
                m = max(maximum(printable_textwidth, summary_rows[:, j]), m)
            end
        end

        printed_data_column_widths[j] = m
    end

    # Resize the columns based on the merged cells.
    if !isnothing(table_data.merge_column_label_cells)
        @views for mc in table_data.merge_column_label_cells
            mc.j > num_printed_data_columns && continue

            j₀ = mc.j
            j₁ = min(mc.j + mc.column_span - 1, num_printed_data_columns)

            total_width = 0

            for j in j₀:j₁
                total_width += printed_data_column_widths[j]

                if j != j₁
                    total_width += 2 + (j ∈ vertical_lines_at_data_columns)
                end
            end

            mctw = printable_textwidth(column_labels[mc.i, mc.j])

            if mctw > total_width
                Δ = div(mctw - total_width, j₁ - j₀ + 1, RoundUp)
                printed_data_column_widths[j₀:j₁] .+= Δ
            end
        end
    end

    return row_number_column_width, row_label_column_width, printed_data_column_widths
end
