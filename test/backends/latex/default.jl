## Description #############################################################################
#
# LaTeX Back End: Test with default options.
#
############################################################################################

@testset "Default Option" verbose = true begin
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    expected = """
\\begin{tabular}{|r|r|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} & \\textbf{Col. 6} \\\\
  \\hline
  1 & 1.0 & 1 & a & abc & missing \\\\
  2 & 2.0 & 2 & b & def & nothing \\\\
  3 & 3.0 & 3 & c & ghi & symbol \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex
    )
    @test result == expected

    result = pretty_table(
        String,
        matrix;
        table_format = LatexTableFormat()
    )
    @test result == expected

    result = pretty_table_latex_backend(String, matrix)
    @test result == expected
end
