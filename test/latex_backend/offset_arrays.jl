## Description #############################################################################
#
# Tests of offset arrays.
#
############################################################################################

@testset "Default Printing" begin
    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. -2} & \\textbf{Col. -1} & \\textbf{Col. 0} & \\textbf{Col. 1} \\\\\\hline
  1 & false & 1.0 & 1 \\\\
  2 & true & 2.0 & 2 \\\\
  3 & false & 3.0 & 3 \\\\
  4 & true & 4.0 & 4 \\\\
  5 & false & 5.0 & 5 \\\\
  6 & true & 6.0 & 6 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(String, odata; backend = Val(:latex))
    @test result == expected

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{1} & \\textbf{2} & \\textbf{3} & \\textbf{4} \\\\\\hline
  1 & false & 1.0 & 1 \\\\
  2 & true & 2.0 & 2 \\\\
  3 & false & 3.0 & 3 \\\\
  4 & true & 4.0 & 4 \\\\
  5 & false & 5.0 & 5 \\\\
  6 & true & 6.0 & 6 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(String, odata; backend = Val(:latex), header = 1:1:4)
    @test result == expected

    result = pretty_table(
        String,
        odata;
        backend = Val(:latex),
        header = OffsetArray(1:1:4, -5:-2)
    )
    @test result == expected
end

@testset "Formatters" begin
    ft_row = (v, i, j) -> (i == -3) ? 0 : v

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. -2} & \\textbf{Col. -1} & \\textbf{Col. 0} & \\textbf{Col. 1} \\\\\\hline
  1 & 0.0 & 1.0 & 1 \\\\
  0 & 0 & 0 & 0 \\\\
  3 & 0.0 & 3.0 & 3 \\\\
  4 & 1.0 & 4.0 & 4 \\\\
  5 & 0.0 & 5.0 & 5 \\\\
  6 & 1.0 & 6.0 & 6 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:latex),
        formatters = (ft_round(2, [-1]), ft_row)
    )
    @test result == expected
end

@testset "Highlighters" begin
    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. -2} & \\textbf{Col. -1} & \\textbf{Col. 0} & \\textbf{Col. 1} \\\\\\hline
  1 & false & 1.0 & \\textbf{1} \\\\
  2 & true & 2.0 & \\textbf{2} \\\\
  3 & false & 3.0 & \\textbf{3} \\\\
  \\textbf{4} & \\textbf{true} & \\textbf{4.0} & \\textbf{4} \\\\
  5 & false & 5.0 & \\textbf{5} \\\\
  6 & true & 6.0 & \\textbf{6} \\\\\\hline
\\end{tabular}
"""

    # TODO: Add predefined highlighters in LaTeX backend.
    latex_hl_row = LatexHighlighter((data, i, j) -> i == -1, "textbf")
    latex_hl_col = LatexHighlighter((data, i, j) -> j ==  1, "textbf")

    result = pretty_table(
        String,
        odata;
        backend = Val(:latex),
        highlighters = (latex_hl_row, latex_hl_col)
    )
end

@testset "Row Labels" begin
    expected = """
\\begin{tabular}{rrrrr}
  \\hline
  \\textbf{Label} & \\textbf{Col. -2} & \\textbf{Col. -1} & \\textbf{Col. 0} & \\textbf{Col. 1} \\\\\\hline
  1 & 1 & false & 1.0 & 1 \\\\
  3 & 2 & true & 2.0 & 2 \\\\
  5 & 3 & false & 3.0 & 3 \\\\
  7 & 4 & true & 4.0 & 4 \\\\
  9 & 5 & false & 5.0 & 5 \\\\
  11 & 6 & true & 6.0 & 6 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:latex),
        row_labels = 1:2:12,
        row_label_column_title = "Label"
    )
    @test result == expected

    result = pretty_table(
        String,
        odata;
        backend = Val(:latex),
        row_labels = OffsetArray(1:2:12, -5:0),
        row_label_column_title = "Label"
    )
    @test result == expected
end

@testset "Row Numbers" begin
    expected = """
\\begin{tabular}{rrrrr}
  \\hline
  \\textbf{Row} & \\textbf{Col. -2} & \\textbf{Col. -1} & \\textbf{Col. 0} & \\textbf{Col. 1} \\\\\\hline
  -4 & 1 & false & 1.0 & 1 \\\\
  -3 & 2 & true & 2.0 & 2 \\\\
  -2 & 3 & false & 3.0 & 3 \\\\
  -1 & 4 & true & 4.0 & 4 \\\\
  0 & 5 & false & 5.0 & 5 \\\\
  1 & 6 & true & 6.0 & 6 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:latex),
        show_row_number = true
    )
    @test result == expected
end
