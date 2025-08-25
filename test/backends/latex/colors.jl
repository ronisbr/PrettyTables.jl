## Description #############################################################################
#
# LaTeX Back End: Tests related with colors.
#
############################################################################################

@testset "Colors" verbose = true begin
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
            style = LatexTableStyle(; first_line_column_label = ["textbf"])
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
            style = LatexTableStyle(; first_line_column_label = [
                ["color{red}",   "textbf"],
                ["color{blue}",  "textbf"],
                ["color{green}", "textbf"]
            ])
        )

        @test result == expected
    end
end

