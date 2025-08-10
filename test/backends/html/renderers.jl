## Description #############################################################################
#
# HTML Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    matrix = ['a' :a "a" missing nothing]

    @testset ":print" begin
        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
      <th style = "text-align: right; font-weight: bold;">Col. 3</th>
      <th style = "text-align: right; font-weight: bold;">Col. 4</th>
      <th style = "text-align: right; font-weight: bold;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
  </tbody>
</table>
"""
        result = pretty_table(
            String,
            matrix;
            backend = :html
        )

        @test result == expected
    end

    @testset ":show" begin
        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
      <th style = "text-align: right; font-weight: bold;">Col. 3</th>
      <th style = "text-align: right; font-weight: bold;">Col. 4</th>
      <th style = "text-align: right; font-weight: bold;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">&apos;a&apos;</td>
      <td style = "text-align: right;">:a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            renderer = :show
        )

        @test result == expected
    end
end
