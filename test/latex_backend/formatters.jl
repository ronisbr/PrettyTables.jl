## Description #############################################################################
#
# Tests of formatters.
#
############################################################################################

@testset "Formatters" begin
    ft = (v,i,j)->v === missing ? LatexCell("\$\\emptyset\$") : v

    matrix = deepcopy(data)
    matrix[3,3] = missing

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  1 & false & 1.0 & 1 \\\\
  2 & true & 2.0 & 2 \\\\
  3 & false & \$\\emptyset\$ & 3 \\\\
  4 & true & 4.0 & 4 \\\\
  5 & false & 5.0 & 5 \\\\
  6 & true & 6.0 & 6 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(String, matrix, backend = Val(:latex), formatters = ft)
    @test result == expected
end

@testset "Pre-defined Formatters" begin
    matrix = hcat(
        1:1:11,
        1:1.0:11,
        [10^i for i in -5:1.:5],
        [ i == 5 ? nothing : "Teste" for i in 1:11]
    )

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  1 & 1 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2 & 0.0001 & Teste \\\\
  3 & 3 & 0.001 & Teste \\\\
  4 & 4 & 0.01 & Teste \\\\
  5 & 5 & 0.1 & nothing \\\\
  6 & 6 & 1 & Teste \\\\
  7 & 7 & \$1 \\cdot 10^{1}\$ & Teste \\\\
  8 & 8 & \$1 \\cdot 10^{2}\$ & Teste \\\\
  9 & 9 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{4}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{5}\$ & Teste \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:latex),
        formatters = ft_latex_sn(1)
    )
    @test result == expected

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  1 & 1 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2 & 0.0001 & Teste \\\\
  3 & 3 & 0.001 & Teste \\\\
  4 & 4 & 0.01 & Teste \\\\
  5 & 5 & 0.1 & nothing \\\\
  6 & 6 & 1 & Teste \\\\
  7 & 7 & 10 & Teste \\\\
  8 & 8 & \$1 \\cdot 10^{2}\$ & Teste \\\\
  9 & 9 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  10 & 10 & \$1 \\cdot 10^{4}\$ & Teste \\\\
  11 & 11 & \$1 \\cdot 10^{5}\$ & Teste \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:latex),
        formatters = ft_latex_sn(2)
    )
    @test result == expected

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  1 & 1.0 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2.0 & 0.0001 & Teste \\\\
  3 & 3.0 & 0.001 & Teste \\\\
  4 & 4.0 & 0.01 & Teste \\\\
  5 & 5.0 & 0.1 & nothing \\\\
  6 & 6.0 & 1 & Teste \\\\
  7 & 7.0 & \$1 \\cdot 10^{1}\$ & Teste \\\\
  8 & 8.0 & \$1 \\cdot 10^{2}\$ & Teste \\\\
  9 & 9.0 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 10.0 & \$1 \\cdot 10^{4}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 11.0 & \$1 \\cdot 10^{5}\$ & Teste \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:latex),
        formatters = ft_latex_sn(1, [1, 3])
    )
    @test result == expected

    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  1 & 1.0 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2.0 & 0.0001 & Teste \\\\
  3 & 3.0 & 0.001 & Teste \\\\
  4 & 4.0 & 0.01 & Teste \\\\
  5 & 5.0 & 0.1 & nothing \\\\
  6 & 6.0 & 1 & Teste \\\\
  7 & 7.0 & 10 & Teste \\\\
  8 & 8.0 & 100 & Teste \\\\
  9 & 9.0 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 10.0 & \$1 \\cdot 10^{4}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 11.0 & \$1 \\cdot 10^{5}\$ & Teste \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:latex),
        formatters = ft_latex_sn([1, 3], [1, 3])
    )
    @test result == expected
end
