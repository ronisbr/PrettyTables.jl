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
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black;">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "font-weight: bold; text-align: right;">Col. 4</th>
      <th style = "font-weight: bold; text-align: right;">Col. 5</th>
      <th style = "font-weight: bold; text-align: right;">Col. 6</th>
    </tr>
  </thead>
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
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
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

    result = pretty_table(String, matrix; backend = :html)
    @test result == expected

    result = pretty_table(String, matrix; table_format = HtmlTableFormat())
    @test result == expected

    result = pretty_table_html_backend(String, matrix)
    @test result == expected

    result = pretty_table(HTML, matrix)
    @test typeof(result) == HTML{String}
    @test result.content == expected

    result = pretty_table(HTML, matrix; backend = :html)
    @test typeof(result) == HTML{String}
    @test result.content == expected
end
