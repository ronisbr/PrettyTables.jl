## Description #############################################################################
#
# HTML Back End: Tests related with decorations.
#
############################################################################################

@testset "Decorations" verbose = true begin
    @testset "Decoration of Column Labels" begin
        matrix = ones(3, 3)

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; color: yellow;">Col. 1</th>
      <th style = "text-align: right; color: yellow;">Col. 2</th>
      <th style = "text-align: right; color: yellow;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            color   = true,
            style   = HtmlTableStyle(; first_line_column_label = ["color" => "yellow"])
        )

        @test result == expected

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; color: yellow;">Col. 1</th>
      <th style = "text-align: right; color: blue;">Col. 2</th>
      <th style = "text-align: right; color: red;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            color   = true,
            style   = HtmlTableStyle(; first_line_column_label = [
                ["color" => "yellow"],
                ["color" => "blue"],
                ["color" => "red"]
            ])
        )

        @test result == expected
    end
end

