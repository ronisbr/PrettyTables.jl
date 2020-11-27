# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of reported issues.
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

@testset "Controlling wrap_table" begin
    data = [1 2; 3 4]

    expected = """
\\begin{tabular}{rr}
  \\hline\\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} \\\\\\hline
  1 & 2 \\\\
  3 & 4 \\\\\\hline\\hline
\\end{tabular}
"""

	result = pretty_table(String, data, backend = :latex, wrap_table = false)
	@test result == expected

    expected = """
\\begin{longtable}{rr}
  \\hline\\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} \\\\\\hline
  \\endhead
  \\hline\\hline
  \\endfoot
  \\endlastfoot
  1 & 2 \\\\
  3 & 4 \\\\\\hline\\hline
\\end{longtable}
"""
	result = pretty_table(String, data, backend = :latex, wrap_table = true,
		                    table_type = :longtable)
    @test result == expected
end
