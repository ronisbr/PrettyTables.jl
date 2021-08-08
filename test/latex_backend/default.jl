# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of default printing.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Default" begin
    expected = """
\\begin{table}
  \\begin{tabular}{rrrr}
    \\hline\\hline
    \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
    1 & false & 1.0 & 1 \\\\
    2 & true & 2.0 & 2 \\\\
    3 & false & 3.0 & 3 \\\\
    4 & true & 4.0 & 4 \\\\
    5 & false & 5.0 & 5 \\\\
    6 & true & 6.0 & 6 \\\\\\hline\\hline
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(String, data; backend = Val(:latex))
    @test result == expected
end

@testset "Pre-defined formats" begin

    # Default
    # ==========================================================================

    expected = """
\\begin{table}
  \\begin{tabular}{|r|r|r|r|}
    \\hline\\hline
    \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
    1 & false & 1.0 & 1 \\\\\\hline
    2 & true & 2.0 & 2 \\\\\\hline
    3 & false & 3.0 & 3 \\\\\\hline
    4 & true & 4.0 & 4 \\\\\\hline
    5 & false & 5.0 & 5 \\\\\\hline
    6 & true & 6.0 & 6 \\\\\\hline\\hline
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        hlines = :all,
        vlines = :all,
        tf = tf_latex_default
    )

    @test result == expected

    # Simple
    # ==========================================================================

    expected = """
\\begin{table}
  \\begin{tabular}{|r|r|r|r|}
    \\hline
    \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
    1 & false & 1.0 & 1 \\\\\\hline
    2 & true & 2.0 & 2 \\\\\\hline
    3 & false & 3.0 & 3 \\\\\\hline
    4 & true & 4.0 & 4 \\\\\\hline
    5 & false & 5.0 & 5 \\\\\\hline
    6 & true & 6.0 & 6 \\\\\\hline
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        hlines = :all,
        vlines = :all,
        tf = tf_latex_simple
    )

    @test result == expected

    # Modern
    # ==========================================================================

    expected = """
\\begin{table}
  \\begin{tabular}{!{\\vrule width 2pt}r!{\\vrule width 1pt}r!{\\vrule width 1pt}r!{\\vrule width 1pt}r!{\\vrule width 2pt}}
    \\noalign{\\hrule height 2pt}
    \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\noalign{\\hrule height 2pt}
    1 & false & 1.0 & 1 \\\\\\noalign{\\hrule height 1pt}
    2 & true & 2.0 & 2 \\\\\\noalign{\\hrule height 1pt}
    3 & false & 3.0 & 3 \\\\\\noalign{\\hrule height 1pt}
    4 & true & 4.0 & 4 \\\\\\noalign{\\hrule height 1pt}
    5 & false & 5.0 & 5 \\\\\\noalign{\\hrule height 1pt}
    6 & true & 6.0 & 6 \\\\\\noalign{\\hrule height 2pt}
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        hlines = :all,
        vlines = :all,
        tf = tf_latex_modern
    )

    @test result == expected

    # booktabs
    # ==========================================================================

    expected = """
\\begin{table}
  \\begin{tabular}{rrrr}
    \\toprule
    \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\midrule
    1 & false & 1.0 & 1 \\\\\\midrule
    2 & true & 2.0 & 2 \\\\\\midrule
    3 & false & 3.0 & 3 \\\\\\midrule
    4 & true & 4.0 & 4 \\\\\\midrule
    5 & false & 5.0 & 5 \\\\\\midrule
    6 & true & 6.0 & 6 \\\\\\bottomrule
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        hlines = :all,
        vlines = :all,
        tf = tf_latex_booktabs
    )

    @test result == expected
end

@testset "Caption" begin
    expected = """
\\begin{table}
  \\caption{Table title}
  \\begin{tabular}{rrrr}
    \\hline\\hline
    \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
    1 & false & 1.0 & 1 \\\\
    2 & true & 2.0 & 2 \\\\
    3 & false & 3.0 & 3 \\\\
    4 & true & 4.0 & 4 \\\\
    5 & false & 5.0 & 5 \\\\
    6 & true & 6.0 & 6 \\\\\\hline\\hline
  \\end{tabular}
  \\label{tab:label}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:latex),
        label = "tab:label",
        title = "Table title"
    )

    @test result == expected

    expected = """
\\begin{longtable}{rrrr}
  \\caption{Table title}\\\\
  \\hline\\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  \\endfirsthead
  \\hline\\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  \\endhead
  \\hline\\hline
  \\endfoot
  \\endlastfoot
  1 & false & 1.0 & 1 \\\\
  2 & true & 2.0 & 2 \\\\
  3 & false & 3.0 & 3 \\\\
  4 & true & 4.0 & 4 \\\\
  5 & false & 5.0 & 5 \\\\
  6 & true & 6.0 & 6 \\\\\\hline\\hline
  \\label{tab:label}
\\end{longtable}
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:latex),
        label = "tab:label",
        table_type = :longtable,
        title = "Table title"
    )

    @test result == expected
end
