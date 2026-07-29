## Description #############################################################################
#
# Typst Back End: Test highlighters.
# 
############################################################################################

@testset "Highlighters" begin
    matrix = [
        1 2 3
        4 5 6
    ]
    backend = :typst

    expected = """
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 3, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 3, stroke: 1.5pt),
    table.vline(x: 1, end: 3, stroke: 0.8pt),
    table.vline(x: 2, end: 3, stroke: 0.8pt),
    table.vline(x: 3, end: 3, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold", fill: green,)[1]],
    [#text(fill: red,)[2]],
    [#text(weight: "bold", fill: green,)[3]],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [#text(fill: red,)[4]],
    [#text(weight: "bold", fill: green,)[5]],
    [#text(fill: red,)[6]],
  )
}
"""

    result = pretty_table(
        String,
        matrix;
        backend,
        highlighters = [
            TypstHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "red"]),
            TypstHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]),
            TypstHighlighter(
                (data, i, j) -> data[i, j] % 2 != 0,
                ["text-weight" => "bold", "text-fill" => "green"],
            ),
        ],
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        backend,
        highlighters = [
            TypstHighlighter(
                (data, i, j) -> data[i, j] % 2 == 0, (_, _, _, _) -> ["text-fill" => "red"]
            ),
            TypstHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]),
            TypstHighlighter(
                (data, i, j) -> data[i, j] % 2 != 0,
                ["text-weight" => "bold"],
                "text-fill" => "green",
            ),
        ],
    )

    @test result == expected

    @testset "First Match Wins" begin
        # The applied style must be the one of the **first** matching highlighter.
        h1 = TypstHighlighter((d, i, j) -> true, ["text-fill" => "red"])
        h2 = TypstHighlighter((d, i, j) -> true, ["text-fill" => "blue"])

        result = pretty_table(String, [1]; backend = :typst, highlighters = [h1, h2])

        @test occursin("red", result)
        @test !occursin("blue", result)
    end

    @testset "Highlighter Receives the Original Data" begin
        # The highlighter callbacks must see the object the user passed to `pretty_table`,
        # not the internal table wrapper, so that they are portable across back ends.
        data = (a = [1, 2],)
        seen = []

        h = TypstHighlighter(
            (d, i, j) -> (push!(seen, typeof(d)); false),
            ["text-fill" => "red"],
        )

        pretty_table(String, data; backend = :typst, highlighters = [h])

        @test !isempty(seen)
        @test all(==(typeof(data)), seen)
    end
end
