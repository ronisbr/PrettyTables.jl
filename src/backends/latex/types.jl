## Description #############################################################################
#
# Types and structures for the LaTeX back end.
#
############################################################################################

export LatexTableBorders, LatexTableFormat, LatexTableStyle

############################################################################################
#                                       Table Format                                       #
############################################################################################

# Pair that defines LaTeX properties.
const LatexEnvironments = Vector{String}

# Create some default decorations to reduce allocations.
const _LATEX__DEFAULT = String[]
const _LATEX__BOLD    = ["\\textbf"]

@kwdef struct LatexTableBorders
    top_line::String    = "\\hline"
    header_line::String = "\\hline"
    middle_line::String    = "\\hline"
    bottom_line::String = "\\hline"
end

"""
    struct LatexTableFormat

Define the format of the tables printed with the LaTeX back end.

# Fields

- `borders::LatexTableBorders`: Format of the borders.
- `horizontal_line_at_beginning::Bool`: If `true`, a horizontal line will be drawn at the
    beginning of the table.
- `horizontal_line_after_column_labels::Bool`: If `true`, a horizontal line will be drawn
    after the column labels.
- `horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}}`: A horizontal line will be
    drawn after each data row index listed in this vector. If the symbol `:all` is passed, a
    horizontal line will be drawn after every data column. If the symbol `:none` is passed,
    no horizontal lines will be drawn after the data rows.
- `horizontal_line_before_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn before the row group label.
- `horizontal_line_after_row_group_label::Bool`: If `true`, a horizontal line will be
    drawn after the row group label.
- `horizontal_line_after_data_rows::Bool`: If `true`, a horizontal line will be drawn
    after the data rows.
- `horizontal_line_after_summary_rows::Bool`: If `true`, a horizontal line will be drawn
    after the summary rows.
- `right_vertical_lines_at_data_columns::Union{Symbol, Vector{Int}}`: A vertical line will
    be drawn after each data column index listed in this vector. If the symbol `:all` is
    passed, a vertical line will be drawn after every data column. If the symbol `:none` is
    passed, no vertical lines will be drawn after the data columns.
- `vertical_line_at_beginning::Bool`: If `true`, a vertical line will be drawn at the
    beginning of the table.
- `vertical_line_after_row_number_column::Bool`: If `true`, a vertical line will be drawn
    after the row number column.
- `vertical_line_after_row_label_column::Bool`: If `true`, a vertical line will be drawn
    after the row label column.
- `vertical_line_after_data_columns::Bool`: If `true`, a vertical line will be drawn after
    the data columns.
- `vertical_line_after_continuation_column::Bool`: If `true`, a vertical line will be
    drawn after the continuation column.
"""
@kwdef struct LatexTableFormat
    # == Border and Lines ==================================================================

    borders::LatexTableBorders = LatexTableBorders()

    # == Configuration for the Horizontal and Vertical Lines ===============================

    horizontal_line_at_beginning::Bool = true
    horizontal_line_after_column_labels::Bool = true
    horizontal_lines_at_data_rows::Union{Symbol, Vector{Int}} = :none
    horizontal_line_before_row_group_label::Bool = true
    horizontal_line_after_row_group_label::Bool = true
    horizontal_line_after_data_rows::Bool = true
    horizontal_line_after_summary_rows::Bool = true

    vertical_line_at_beginning::Bool = true
    vertical_line_after_row_number_column::Bool = true
    vertical_line_after_row_label_column::Bool = true
    vertical_line_after_data_columns::Bool = true
    vertical_line_after_continuation_column::Bool = true

    right_vertical_lines_at_data_columns::Union{Symbol, Vector{Int}} = :all
end

"""
    struct TextTableStyle

Define the style of the tables printed with the text back end.

# Fields

- `row_number::Crayon`: Crayon with the style for the row numbers.
- `stubhead_label::Crayon`:  Crayon with the style for the stubhead label.
- `row_label::Crayon`: Crayon with the style for the row labels.
- `row_group_label::Crayon`: Crayon with the style for the row group label.
- `first_line_column_label::Crayon`: Crayon with the style for the first column label lines.
- `column_label::Crayon`: Crayon with the style for the rest of the column labels.
- `first_line_merged_column_label::Crayon`: Crayon with the style for the merged cells at
    the first column label line.
- `merged_column_label::Crayon`: Crayon with the style for the merged cells at the rest of
    the column labels.
- `summary_row_cell::Crayon`: Crayon with the style for the summary row cell.
- `summary_row_label::Crayon`: Crayon with the style for the summary row label.
- `footnote::Crayon`: Crayon with the style for the footnotes.
- `source_note::Crayon`: Crayon with the style for the source notes.
- `omitted_cell_summary::Crayon`: Crayon with the style for the omitted cell summary.
- `table_border::Crayon`: Crayon with the style for the table border.
"""
@kwdef struct LatexTableStyle
    title::LatexEnvironments                          = _LATEX__BOLD
    subtitle::LatexEnvironments                       = _LATEX__DEFAULT
    row_number_label::LatexEnvironments               = _LATEX__BOLD
    row_number::LatexEnvironments                     = _LATEX__DEFAULT
    stubhead_label::LatexEnvironments                 = _LATEX__BOLD
    row_label::LatexEnvironments                      = _LATEX__BOLD
    row_group_label::LatexEnvironments                = _LATEX__BOLD
    first_line_column_label::LatexEnvironments        = _LATEX__BOLD
    column_label::LatexEnvironments                   = _LATEX__BOLD
    first_line_merged_column_label::LatexEnvironments = _LATEX__BOLD
    merged_column_label::LatexEnvironments            = _LATEX__BOLD
    summary_row_cell::LatexEnvironments               = _LATEX__DEFAULT
    summary_row_label::LatexEnvironments              = _LATEX__BOLD
    footnote::LatexEnvironments                       = _LATEX__DEFAULT
    source_note::LatexEnvironments                    = _LATEX__BOLD
    omitted_cell_summary::LatexEnvironments           = _LATEX__DEFAULT
end
