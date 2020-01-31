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
\\begin{tabular}{rr}
\\hline\\hline
\\textbf{Col. 1} & \\textbf{Col. 2} \\\\\\hline
2.0 ± 1 & 3.0 ± 1 \\\\\\hline\\hline
\\end{tabular}
"""

    result = sprint((io,data)->pretty_table(io, data, backend = :latex), data)
    @test result == expected
end

