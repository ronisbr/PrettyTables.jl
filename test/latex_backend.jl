# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to the LaTeX backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Issue #38
# ==============================================================================

@testset "Issue #38 - isoverlong is not defined" begin
    data = ["2.0 ± 1" "3.0 ± 1"]

    expected = """
\\begin{table}
\\begin{tabular}{rr}
\\hline\\hline
\\textbf{Col. 1} & \\textbf{Col. 2} \\\\\\hline
2.0 ± 1 & 3.0 ± 1 \\\\\\hline\\hline
\\end{tabular}
\\end{table}
"""

    result = pretty_table(String, data, backend = :latex)
    @test result == expected
end

