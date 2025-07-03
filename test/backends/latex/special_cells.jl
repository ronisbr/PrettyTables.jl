## Description #############################################################################
#
# LaTeX Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
    @testset "LatexCell" begin
        matrix = [
            latex_cell"\textbf{Test}",
            latex_cell"\(a^2 + b^2\)",
            latex_cell"\textit{Test}"
        ]

        expected = """
\\begin{tabular}{|r|}
  \\hline
  \\textbf{Col. 1} \\\\
  \\hline
  \\textbf{Test} \\\\
  \\(a^2 + b^2\\) \\\\
  \\textit{Test} \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex
        )

        @test result == expected
    end

    @testset "LaTeXString" begin
        matrix = [L"a^2 + b^2", L"\mathbf{v}_b", L"\mathbf{I}_{3 \times 3}"]

        expected = """
\\begin{tabular}{|r|}
  \\hline
  \\textbf{Col. 1} \\\\
  \\hline
  \$a^2 + b^2\$ \\\\
  \$\\mathbf{v}_b\$ \\\\
  \$\\mathbf{I}_{3 \\times 3}\$ \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex
        )

        @test result == expected
    end
end

