## Description #############################################################################
#
# LaTeX Back End: Test highlighters.
#
############################################################################################

@testset "Highlighters" begin
    matrix = [
        1 2 3
        4 5 6
    ]

    # NOTE: The even cells match both the 1st and the 2nd highlighters. Since the applied
    # style must be the one of the **first** match, they are decorated with `textbf` only.
    expected = """
\\begin{tabular}{|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  \\textit{\\textbf{1}} & \\textbf{2} & \\textit{\\textbf{3}} \\\\
  \\textbf{4} & \\textit{\\textbf{5}} & \\textbf{6} \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        color = true,
        highlighters = [
            LatexHighlighter(
                (data, i, j) -> data[i, j] % 2 == 0, (_, _, _, _) -> ["textbf"]
            )
            LatexHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["textit"])
            LatexHighlighter((data, i, j) -> data[i, j] % 2 != 0, ["textbf", "textit"])
        ],
    )

    @test result == expected

    @testset "First Match Wins" begin
        # The applied style must be the one of the **first** matching highlighter.
        h1 = LatexHighlighter((d, i, j) -> true, ["textbf"])
        h2 = LatexHighlighter((d, i, j) -> true, ["small"])

        result = pretty_table(String, [1]; backend = :latex, highlighters = [h1, h2])

        @test occursin("\\textbf{1}", result)
        @test !occursin("\\small", result)
    end

    @testset "Highlighter Receives the Original Data" begin
        # The highlighter callbacks must see the object the user passed to `pretty_table`,
        # not the internal table wrapper, so that they are portable across back ends.
        data = (a = [1, 2],)
        seen = []

        h = LatexHighlighter((d, i, j) -> (push!(seen, typeof(d)); false), ["textbf"])

        pretty_table(String, data; backend = :latex, highlighters = [h])

        @test !isempty(seen)
        @test all(==(typeof(data)), seen)
    end
end
