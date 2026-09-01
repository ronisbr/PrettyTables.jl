## Description #############################################################################
#
# HTML Back End: Test highlighters.
# 
############################################################################################

@testset "Highlighters" begin
    matrix = [
        1 2 3
        4 5 6
    ]

    expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; color: green; font-weight: bold; text-align: right;">1</td>
      <td style = "border-right: 1px solid black; color: red; text-align: right;">2</td>
      <td style = "border-right: 2px solid black; color: green; font-weight: bold; text-align: right;">3</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; color: red; text-align: right;">4</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; color: green; font-weight: bold; text-align: right;">5</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; color: red; text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        highlighters = [
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 == 0, "color" => "red"),
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["color" => "blue"]),
            HtmlHighlighter(
                (data, i, j) -> data[i, j] % 2 != 0,
                ["font-weight" => "bold"],
                "color" => "green",
            ),
        ],
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        highlighters = [
            HtmlHighlighter(
                (data, i, j) -> data[i, j] % 2 == 0, (_, _, _, _) -> ["color" => "red"]
            ),
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["color" => "blue"]),
            HtmlHighlighter(
                (data, i, j) -> data[i, j] % 2 != 0,
                ["font-weight" => "bold"],
                "color" => "green",
            ),
        ],
    )

    @test result == expected

    @testset "First Match Wins" begin
        # The applied style must be the one of the **first** matching highlighter.
        h1 = HtmlHighlighter((d, i, j) -> true, ["color" => "red"])
        h2 = HtmlHighlighter((d, i, j) -> true, ["color" => "blue"])

        result = pretty_table(String, [1]; backend = :html, highlighters = [h1, h2])

        @test occursin("color: red", result)
        @test !occursin("color: blue", result)
    end

    @testset "Highlighter Receives the Original Data" begin
        # The highlighter callbacks must see the object the user passed to `pretty_table`,
        # not the internal table wrapper, so that they are portable across back ends.
        data = (a = [1, 2],)
        seen = []

        h = HtmlHighlighter(
            (d, i, j) -> (push!(seen, typeof(d)); false),
            ["color" => "red"],
        )

        pretty_table(String, data; backend = :html, highlighters = [h])

        @test !isempty(seen)
        @test all(==(typeof(data)), seen)
    end
end
