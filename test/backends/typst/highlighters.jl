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
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "color: green; font-weight: bold; text-align: right;">1</td>
      <td style = "color: red; text-align: right;">2</td>
      <td style = "color: green; font-weight: bold; text-align: right;">3</td>
    </tr>
    <tr class = "dataRow">
      <td style = "color: red; text-align: right;">4</td>
      <td style = "color: green; font-weight: bold; text-align: right;">5</td>
      <td style = "color: red; text-align: right;">6</td>
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
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 != 0, ["font-weight" => "bold"], "color" => "green")
        ]
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        highlighters = [
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 == 0, (_, _, _, _) -> ["color" => "red"]),
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["color" => "blue"]),
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 != 0, ["font-weight" => "bold"], "color" => "green")
        ]
    )

    @test result == expected
end
