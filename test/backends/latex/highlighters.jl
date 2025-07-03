## Description #############################################################################
#
# LaTeX Back End: Test highlighters.
#
############################################################################################

@testset "Highlighters" begin
    matrix = [
        1 2 3
        4 5 6
    ]

    expected = """
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  \\textit{\\textbf{1}} & \\textit{2} & \\textit{\\textbf{3}} \\\\
  \\textit{4} & \\textit{\\textbf{5}} & \\textit{6} \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        color = true,
        highlighters = [
            LatexHighlighter((data, i, j) -> data[i, j] % 2 == 0, (_, _, _, _) -> ["textbf"])
            LatexHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["textit"])
            LatexHighlighter((data, i, j) -> data[i, j] % 2 != 0, ["textbf", "textit"])
        ]
    )

    @test result == expected
end
