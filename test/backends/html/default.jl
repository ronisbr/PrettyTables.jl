## Description #############################################################################
#
# HTML Back End: Test with default options.
#
############################################################################################

@testset "Default Options" begin
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    expected = """
<table>
  <tr class = "columnLabelRow">
    <th style = "text-align: right; font-weight: bold;">Col. 1</th>
    <th style = "text-align: right; font-weight: bold;">Col. 2</th>
    <th style = "text-align: right; font-weight: bold;">Col. 3</th>
    <th style = "text-align: right; font-weight: bold;">Col. 4</th>
    <th style = "text-align: right; font-weight: bold;">Col. 5</th>
    <th style = "text-align: right; font-weight: bold;">Col. 6</th>
  </tr>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">abc</td>
      <td style = "text-align: right;">missing</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">b</td>
      <td style = "text-align: right;">def</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">c</td>
      <td style = "text-align: right;">ghi</td>
      <td style = "text-align: right;">symbol</td>
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

    result = pretty_table(
        String,
        matrix;
        table_format = HtmlTableFormat()
    )
    @test result == expected

    result = pretty_table(
        HTML,
        matrix
    )
    @test typeof(result) == HTML{String}
    @test result.content == expected
end

