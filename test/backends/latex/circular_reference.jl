## Description #############################################################################
#
# LaTeX Back End: Test circular reference.
#
############################################################################################

@testset "Circular Reference" begin
    cr = CircularRef(
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [10, 11, 12]
    )

    cr.A1[2]   = cr
    cr.A4[end] = cr

    expected = """
\\begin{tabular}{|r|r|r|r|}
  \\hline
  \\textbf{A1} & \\textbf{A2} & \\textbf{A3} & \\textbf{A4} \\\\
  \\hline
  1 & 4 & 7 & 10 \\\\
  \\#= circular reference =\\# & 5 & 8 & 11 \\\\
  3 & 6 & 9 & \\#= circular reference =\\# \\\\
  \\hline
\\end{tabular}
"""

    result = sprint(show, MIME("text/latex"), cr)

    @test result == expected
end

