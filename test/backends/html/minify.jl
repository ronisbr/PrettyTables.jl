## Description #############################################################################
#
# HTML Back End: Test with minification.
#
############################################################################################

@testset "Minify" begin
    matrix = [1 2]

    expected = """
<table><thead><tr class = "columnLabelRow"><th style = "font-weight: bold; text-align: right;">Col. 1</th><th style = "font-weight: bold; text-align: right;">Col. 2</th></tr></thead><tbody><tr class = "dataRow"><td style = "text-align: right;">1</td><td style = "text-align: right;">2</td></tr></tbody></table>"""

    result = pretty_table(String, matrix; backend = :html, minify = true)

    @test result == expected
end

@testset "Cell Content With Line Breaks" begin
    # The cell content must be written verbatim with or without minification. Otherwise,
    # the line breaks and the indentation inside `<pre>` elements would change.
    matrix = [HTML("<pre>x\n  y</pre>");;]

    expected = """
<table><thead><tr class = "columnLabelRow"><th style = "font-weight: bold; text-align: right;">Col. 1</th></tr></thead><tbody><tr class = "dataRow"><td style = "text-align: right;"><pre>x
  y</pre></td></tr></tbody></table>"""

    result = pretty_table(String, matrix; backend = :html, minify = true)
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;"><pre>x
  y</pre></td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(String, matrix; allow_html_in_cells = true, backend = :html)
    @test result == expected
end
