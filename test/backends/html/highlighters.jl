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
  <tr class = "columnLabelRow">
    <th style = "text-align: right; font-weight: bold;">Col. 1</th>
    <th style = "text-align: right; font-weight: bold;">Col. 2</th>
    <th style = "text-align: right; font-weight: bold;">Col. 3</th>
  </tr>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right; font-weight: bold; color: green;">1</td>
      <td style = "text-align: right; color: red;">2</td>
      <td style = "text-align: right; font-weight: bold; color: green;">3</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right; color: red;">4</td>
      <td style = "text-align: right; font-weight: bold; color: green;">5</td>
      <td style = "text-align: right; color: red;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        highlighters = [
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["color" => "red"]),
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["color" => "blue"]),
            HtmlHighlighter((data, i, j) -> data[i, j] % 2 != 0, ["font-weight" => "bold", "color" => "green"])
        ]
    )

    @test result == expected
end
