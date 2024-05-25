## Description #############################################################################
#
# Tests of default printing.
#
############################################################################################

@testset "Default" begin
    expected = """
\\begin{tabular}{rrrr}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  1 & false & 1.0 & 1 \\\\
  2 & true & 2.0 & 2 \\\\
  3 & false & 3.0 & 3 \\\\
  4 & true & 4.0 & 4 \\\\
  5 & false & 5.0 & 5 \\\\
  6 & true & 6.0 & 6 \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(String, data; backend = Val(:latex))
    @test result == expected
end

@testset "Pre-defined formats" begin
    # == Default ===========================================================================

    expected = """
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
"""

    result = pretty_table(
        String,
        data;
        hlines = :all,
        vlines = :all,
        tf = tf_latex_default
    )

    @test result == expected

    # == Double ============================================================================

    expected = """
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
"""

    result = pretty_table(
        String,
        data;
        hlines = :all,
        vlines = :all,
        tf = tf_latex_double
    )

    @test result == expected

    # == Modern ============================================================================

    expected = """
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
"""

    result = pretty_table(
        String,
        data;
        hlines = :all,
        vlines = :all,
        tf = tf_latex_modern
    )

    @test result == expected

    # == booktabs ==========================================================================

    expected = """
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

@testset "Escaping" begin
    matrix = Any[
        latex_cell"$\mathbf{\pi}$"           π
        latex_cell"\textbf{Character}"       'a'
        latex_cell"\textbf{Emoji}"           "😅 emoji 😃"
        latex_cell"\textbf{Float64}"         Float16(1)
        latex_cell"\texttt{Missing}"         missing
        latex_cell"\textbf{New line}"        "One line\nAnother line"
        LaTeXString("\\emph{Nothing}")       nothing
        LaTeXString("\\textbf{Regex}")       r"1"
        LaTeXString("\\textbf{String}")      String(UInt8[0, 1, 2, 3])
        LaTeXString("\\textbf{Symbol}")      :a
        LaTeXString("\\textbf{Sub. string}") s"1"
        LaTeXString("\\textbf{UInt64}")      0x1
        "Percents"                           "1000%"
    ]

    # == Renderer = `:printf` ==============================================================

    expected = """
        \\begin{tabular}{rr}
          \\hline
          \\textbf{Col. 1} & \\textbf{Col. 2} \\\\\\hline
          \$\\mathbf{\\pi}\$ & π \\\\
          \\textbf{Character} & a \\\\
          \\textbf{Emoji} & 😅 emoji 😃 \\\\
          \\textbf{Float64} & 1.0 \\\\
          \\texttt{Missing} & missing \\\\
          \\textbf{New line} & One line\\textbackslash{}nAnother line \\\\
          \\emph{Nothing} & nothing \\\\
          \\textbf{Regex} & r"1" \\\\
          \\textbf{String} & \\textbackslash{}0\\textbackslash{}x01\\textbackslash{}x02\\textbackslash{}x03 \\\\
          \\textbf{Symbol} & a \\\\
          \\textbf{Sub. string} & 1 \\\\
          \\textbf{UInt64} & 1 \\\\
          Percents & 1000\\% \\\\\\hline
        \\end{tabular}
        """

    result = pretty_table(String, matrix, backend = Val(:latex))
    @test result == expected

    # == Renderer = `:show` ================================================================

    expected = """
        \\begin{tabular}{rr}
          \\hline
          \\textbf{Col. 1} & \\textbf{Col. 2} \\\\\\hline
          \$\\mathbf{\\pi}\$ & π \\\\
          \\textbf{Character} & 'a' \\\\
          \\textbf{Emoji} & 😅 emoji 😃 \\\\
          \\textbf{Float64} & 1.0 \\\\
          \\texttt{Missing} & missing \\\\
          \\textbf{New line} & One line\\textbackslash{}nAnother line \\\\
          \\emph{Nothing} & nothing \\\\
          \\textbf{Regex} & r"1" \\\\
          \\textbf{String} & \\textbackslash{}0\\textbackslash{}x01\\textbackslash{}x02\\textbackslash{}x03 \\\\
          \\textbf{Symbol} & :a \\\\
          \\textbf{Sub. string} & 1 \\\\
          \\textbf{UInt64} & 0x01 \\\\
          Percents & 1000\\% \\\\\\hline
        \\end{tabular}
        """

    result = pretty_table(String, matrix, backend = Val(:latex), renderer = :show)
    @test result == expected
end

@testset "Wrap table environments" begin
    expected = """
\\begin{table}
  \\caption{Table title}
  \\begin{tabular}{rrrr}
    \\hline
    \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
    1 & false & 1.0 & 1 \\\\
    2 & true & 2.0 & 2 \\\\
    3 & false & 3.0 & 3 \\\\
    4 & true & 4.0 & 4 \\\\
    5 & false & 5.0 & 5 \\\\
    6 & true & 6.0 & 6 \\\\\\hline
  \\end{tabular}
  \\label{tab:label}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        backend    = Val(:latex),
        label      = "tab:label",
        title      = "Table title",
        wrap_table = true
    )

    @test result == expected

    expected = """
\\begin{longtable}{rrrr}
  \\caption{Table title}\\\\
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  \\endfirsthead
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\\\hline
  \\endhead
  \\hline
  \\endfoot
  \\endlastfoot
  1 & false & 1.0 & 1 \\\\
  2 & true & 2.0 & 2 \\\\
  3 & false & 3.0 & 3 \\\\
  4 & true & 4.0 & 4 \\\\
  5 & false & 5.0 & 5 \\\\
  6 & true & 6.0 & 6 \\\\\\hline
  \\label{tab:label}
\\end{longtable}
"""

    result = pretty_table(
        String,
        data;
        backend    = Val(:latex),
        label      = "tab:label",
        table_type = :longtable,
        title      = "Table title",
        wrap_table = true
    )

    @test result == expected
end
