## Description #############################################################################
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
"""
function _text__fix_data_column_widths!(
    printed_data_column_widths::Vector{Int},
    column_labels::Matrix{String},
    table_str::Matrix{String},
    summary_rows::Union{Nothing, Matrix{String}},
    fixed_data_column_widths::AbstractVector{Int},
    line_breaks::Bool
)
    for j in eachindex(printed_data_column_widths)
        fcw = fixed_data_column_widths[j - 1 + begin]
        (fcw < 0) && continue
        printed_data_column_widths[j] = fixed_data_column_widths[j - 1 + begin]
    end

    for table in (column_labels, table_str, summary_rows)
        isnothing(table) && continue

        for j in axes(table, 2)
            cw = printed_data_column_widths[j]

            for i in axes(table, 1)
                str = table[i, j]

                if !line_breaks
                    tw = textwidth(str)
                    tw <= cw && continue

                    str = first(right_crop(str, tw - cw + 1))
                    str *= "…"
                    table[i, j] = str
                else
                    tokens = split(str, '\n')

                    for l in eachindex(tokens)
                        line = tokens[l]
                        tw   = textwidth(line)
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
    _text__printed_column_widths(table_data::TableData, row_labels::Union{Nothing, Vector{String}}, column_labels::Union{Nothing, Matrix{String}}, summary_rows::Union{Nothing, Matrix{String}}, table_str::Matrix{String}, right_vertical_lines_at_data_columns::AbstractVector{Int}, column_label_width_based_on_first_line_only::Bool, line_breaks::Bool)

Compute the printed column widths.

# Arguments

- `table_data::TableData`: Table data.
- `row_labels::Union{Nothing, Vector{String}}`: Rendered row labels.
- `column_labels::Union{Nothing, Matrix{String}}`: Rendered column labels.
- `summary_rows::Union{Nothing, Vector{String}}`: Rendered summary rows.
- `table_str::Matrix{String}`: Rendered data cells.
- `right_vertical_lines_at_data_columns::AbstractVector{Int}`: Location of the right
    vertical lines at the data columns.
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
    right_vertical_lines_at_data_columns::AbstractVector{Int},
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
            textwidth(table_data.row_number_column_label),
            floor(Int, log10(m) + 1)
        )
    end

    if !isnothing(row_labels)
        row_label_column_width = max(
            textwidth(table_data.stubhead_label),

            num_printed_data_rows > 0 ? maximum(textwidth, row_labels) : 0,

            if _has_summary_rows(table_data)
                maximum(textwidth, table_data.summary_row_labels)
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
                    m = max(m, textwidth(column_labels[i, j]))
                end
            end
        end

        if num_printed_data_rows > 0
            if !line_breaks
                m = max(maximum(textwidth, table_str[:, j]), m)
            else
                for cell in table_str[:, j]
                    m = max(m, _maximum_textwidth_per_line(cell))
                end
            end

            if _has_summary_rows(table_data)
                m = max(maximum(textwidth, summary_rows[:, j]), m)
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
                    total_width += 2 + (j ∈ right_vertical_lines_at_data_columns)
                end
            end

            mctw = textwidth(column_labels[mc.i, mc.j])

            if mctw > total_width
                Δ = div(mctw - total_width, j₁ - j₀ + 1, RoundUp)
                printed_data_column_widths[j₀:j₁] .+= Δ
            end
        end
    end

    return row_number_column_width, row_label_column_width, printed_data_column_widths
end
