## Description #############################################################################
#
# LaTeX Back End: Tests related to the horizontal and vertical line specifications.
#
############################################################################################

@testset "Line Specifications" verbose = true begin
    # `horizontal_lines_at_data_rows` and `vertical_lines_at_data_columns` accept either a
    # `Symbol` (`:all` / `:none`) or an explicit `Vector{Int}`. The vector branch is what
    # narrows the field type in the back end, and it must select exactly the requested rows
    # and columns.
    matrix = [1 2 3; 4 5 6]

    @testset "Vector of Indices" begin
        expected = """
\\begin{tabular}{|r|rr|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1 & 2 & 3 \\\\
  \\hline
  4 & 5 & 6 \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            table_format = LatexTableFormat(;
                horizontal_lines_at_data_rows = [1], vertical_lines_at_data_columns = [1]
            ),
        )

        @test result == expected
    end

    @testset "All Lines" begin
        expected = """
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1 & 2 & 3 \\\\
  \\hline
  4 & 5 & 6 \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            table_format = LatexTableFormat(;
                horizontal_lines_at_data_rows = :all, vertical_lines_at_data_columns = :all
            ),
        )

        @test result == expected
    end
end

@testset "Line Before a Row Group Label" begin
    # `horizontal_line_before_row_group_label` had no coverage in this back end.
    expected = """
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1 & 2 & 3 \\\\
  \\hline
  \\multicolumn{3}{|l|}{\\textbf{G}} \\\\
  \\hline
  4 & 5 & 6 \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        [1 2 3; 4 5 6];
        backend = :latex,
        row_group_labels = [2 => "G"],
        table_format = LatexTableFormat(; horizontal_line_before_row_group_label = true),
    )

    @test result == expected
end
@testset "Merged Column Label Truncated by the Column Limit" begin
    # When a merged column label spans more columns than are actually printed, its span must
    # be clamped to the remaining columns.
    result = pretty_table(
        String,
        [1 2 3 4; 5 6 7 8];
        backend = :latex,
        column_labels = [[MultiColumn(4, "Wide")], ["a", "b", "c", "d"]],
        maximum_number_of_columns = 2,
    )

    @test occursin("\\multicolumn{2}{", result)
    @test !occursin("\\multicolumn{4}{", result)
end

@testset "Line Roles" begin
    # The rule after the title uses `top_line`, the rule after the column labels uses
    # `header_line`, and the rules around the row group labels use `middle_line`.
    expected = """
\\begin{tabular}{|r|r|r|}
  \\multicolumn{3}{@{}c@{}}{\\textbf{\\large{T}}} \\\\
  \\toprule
   & \\textbf{Col. 1} & \\textbf{Col. 2} \\\\
  \\midrule
   & 1 & 2 \\\\
  \\hline
  \\multicolumn{3}{|l|}{\\textbf{G}} \\\\
  \\hline
   & 3 & 4 \\\\
  \\hline
  \\textbf{S} & 4 & 6 \\\\
  \\bottomrule
\\end{tabular}
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
        backend = :latex,
        row_group_labels = [2 => "G"],
        summary_row_labels = ["S"],
        summary_rows = [(data, j) -> sum(data[:, j])],
        table_format = LatexTableFormat(;
            borders = LatexTableBorders(;
                top_line    = "\\toprule",
                header_line = "\\midrule",
                middle_line = "\\hline",
                bottom_line = "\\bottomrule",
            ),
        ),
        title = "T",
    )

    @test result == expected
end
