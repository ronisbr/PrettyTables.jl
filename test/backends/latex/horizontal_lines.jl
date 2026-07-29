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
                horizontal_lines_at_data_rows  = [1],
                vertical_lines_at_data_columns = [1],
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
                horizontal_lines_at_data_rows  = :all,
                vertical_lines_at_data_columns = :all,
            ),
        )

        @test result == expected
    end
end
