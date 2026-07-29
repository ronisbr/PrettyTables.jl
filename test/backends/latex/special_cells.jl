## Description #############################################################################
#
# LaTeX Back End: Tests related to special cells.
#
############################################################################################

#! format: off

@testset "Special Cells" verbose = true begin
    @testset "LatexCell" begin
        matrix = [
            latex_cell"\textbf{Test}",
            latex_cell"\(a^2 + b^2\)",
            latex_cell"\textit{Test}"
        ]

        expected = """
\\begin{tabular}{|r|}
  \\hline
  \\textbf{Col. 1} \\\\
  \\hline
  \\textbf{Test} \\\\
  \\(a^2 + b^2\\) \\\\
  \\textit{Test} \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex
        )

        @test result == expected
    end

    @testset "LaTeXString" begin
        matrix = [L"a^2 + b^2", L"\mathbf{v}_b", L"\mathbf{I}_{3 \times 3}"]

        expected = """
\\begin{tabular}{|r|}
  \\hline
  \\textbf{Col. 1} \\\\
  \\hline
  \$a^2 + b^2\$ \\\\
  \$\\mathbf{v}_b\$ \\\\
  \$\\mathbf{I}_{3 \\times 3}\$ \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex
        )

        @test result == expected
    end

    @testset "Markdown" begin
        matrix = [
            md"**Bold Text**",
            md"*Italic Text*",
            md"`Code Snippet`"
        ]

        expected = """
\\begin{tabular}{|r|}
  \\hline
  \\textbf{Col. 1} \\\\
  \\hline
  \\textbf{Bold Text} \\\\
  \\emph{Italic Text} \\\\
  \\texttt{Code Snippet} \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex
        )

        @test result == expected
    end

    @testset "Escaping of LaTeX Metacharacters" begin
        # `^` must be escaped as `\textasciicircum{}`. Notice that `\^` is the circumflex
        # *accent* command, which takes the next character as its argument. Hence, `a\^b`
        # would typeset `b` with a circumflex instead of showing a literal caret.
        matrix = ["a^b" "c%d" "e&f" "g_h" "i#j" "k{l}" "m~n" "o\\p" "q\$r"]

        result = pretty_table(String, matrix; backend = :latex)

        @test occursin("a\\textasciicircum{}b", result)
        @test occursin("c\\%d", result)
        @test occursin("e\\&f", result)
        @test occursin("g\\_h", result)
        @test occursin("i\\#j", result)
        @test occursin("k\\{l\\}", result)
        @test occursin("m\\textasciitilde{}n", result)
        @test occursin("o\\textbackslash{}p", result)
        @test occursin("q\\\$r", result)
    end
end

#! format: on
