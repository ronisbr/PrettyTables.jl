## Description #############################################################################
#
# LaTeX Back End: Test related with offset arrays.
#
############################################################################################

@testset "Offset Arrays" begin
    matrix = Matrix{Any}(undef, 3, 3)
    matrix[1, 1] = (1, 1)
    matrix[1, 2] = (1, 2)
    matrix[2, 1] = nothing
    matrix[2, 2] = missing
    matrix[3, 3] = (3, 3)

    omatrix = OffsetArray(matrix, -2:0, -3:-1)

    expected = """
\\begin{tabular}{|r|r|r|r|}
  \\hline
  \\textbf{Row} & \\textbf{Col. -3} & \\textbf{Col. -2} & \\textbf{Col. -1} \\\\
  \\hline
  -2 & (1, 1) & (1, 2) & \\#undef \\\\
  -1 & nothing & missing & \\#undef \\\\
  0 & \\#undef & \\#undef & (3, 3) \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        omatrix;
        backend = :latex,
        show_row_number_column = true
    )

    @test result == expected
end

