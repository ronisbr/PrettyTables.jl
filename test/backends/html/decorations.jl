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
      <th style = "color: yellow; text-align: right;">Col. 1</th>
      <th style = "color: yellow; text-align: right;">Col. 2</th>
      <th style = "color: yellow; text-align: right;">Col. 3</th>
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
            style   = HtmlTableStyle(; first_line_column_label = ["color" => "yellow"]),
        )

        @test result == expected

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "color: yellow; text-align: right;">Col. 1</th>
      <th style = "color: blue; text-align: right;">Col. 2</th>
      <th style = "color: red; text-align: right;">Col. 3</th>
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
            style   = HtmlTableStyle(; first_line_column_label = [["color" => "yellow"], ["color" => "blue"], ["color" => "red"]]),
        )

        @test result == expected
    end
    @testset "Per-Column Style for the Column Labels" begin
        # `column_label` may be a single style applied to every column, or a vector holding
        # one style per column. Only the scalar form was covered.
        result = pretty_table(
            String,
            [1 2];
            backend = :html,
            column_labels = [["A", "B"], ["a", "b"]],
            style = HtmlTableStyle(;
                column_label = [["color" => "red"], ["color" => "blue"]]
            ),
        )

        @test occursin("<th style = \"color: red; text-align: right;\">a</th>", result)
        @test occursin("<th style = \"color: blue; text-align: right;\">b</th>", result)
    end

    @testset "Escaping of the Style Properties" begin
        # The style is an attribute value. Hence, a quote in a property must not close it.
        output = pretty_table(
            String,
            [1;;];
            backend = :html,
            style = HtmlTableStyle(;
                first_line_column_label = [
                    "font-family" => "\"Times New Roman\", 'Serif'",
                    "background"  => "url(\"a.png?x=1&y=<2>\")",
                ],
            ),
        )

        @test occursin(
            "<th style = \"background: url(&quot;a.png?x=1&amp;y=&lt;2&gt;&quot;); font-family: &quot;Times New Roman&quot;, &apos;Serif&apos;; text-align: right;\">Col. 1</th>",
            output,
        )
    end

    @testset "Style of Merged Column Labels" begin
        # The merged column labels must only receive the style of the merged cells.
        output = pretty_table(
            String,
            [1 2];
            backend = :html,
            column_labels = [[MultiColumn(2, "M")], ["a", "b"]],
            style = HtmlTableStyle(;
                first_line_column_label        = ["color" => "blue"],
                first_line_merged_column_label = ["color" => "red"],
            ),
        )

        @test occursin(
            "<th colspan = \"2\" style = \"color: red; text-align: center;\">M</th>", output
        )
    end

    @testset "Shorthand Properties" begin
        # A shorthand property pushed after one of its longhands must override it. Hence,
        # the properties of the same family must keep their insertion order.
        output = pretty_table(
            String,
            [1 2];
            backend = :html,
            column_labels = [[MultiColumn(2, "M")], ["a", "b"]],
            style = HtmlTableStyle(; first_line_merged_column_label = ["border" => "none"]),
            table_format = HtmlTableFormat(;
                horizontal_line_at_merged_column_labels = true
            ),
        )

        @test occursin(
            "<th colspan = \"2\" style = \"border-bottom: 1px solid black; border: none; text-align: center;\">M</th>",
            output,
        )
    end
end
