## Description #############################################################################
#
# LaTeX Back End: Tests related with decorations.
#
############################################################################################

@testset "Decorations" verbose = true begin
    @testset "Decoration of Column Labels" begin
        matrix = ones(3, 3)

        expected = """
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            style = LatexTableStyle(; first_line_column_label = ["textbf"]),
        )

        @test result == expected

        expected = """
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{\\color{red}{Col. 1}} & \\textbf{\\color{blue}{Col. 2}} & \\textbf{\\color{green}{Col. 3}} \\\\
  \\hline
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  1.0 & 1.0 & 1.0 \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            style = LatexTableStyle(;
                first_line_column_label = [
                    ["color{red}", "textbf"],
                    ["color{blue}", "textbf"],
                    ["color{green}", "textbf"],
                ],
            ),
        )

        @test result == expected
    end
    @testset "Per-Column Style for the Column Labels" begin
        # `column_label` may be a single style applied to every column, or a vector holding
        # one style per column. Only the scalar form was covered.
        expected = """
\\begin{tabular}{|r|r|}
  \\hline
  \\textbf{A} & \\textbf{B} \\\\
  \\textbf{a} & \\textit{b} \\\\
  \\hline
  1 & 2 \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            [1 2];
            backend = :latex,
            column_labels = [["A", "B"], ["a", "b"]],
            style = LatexTableStyle(; column_label = [["textbf"], ["textit"]]),
        )

        @test result == expected
    end
end
