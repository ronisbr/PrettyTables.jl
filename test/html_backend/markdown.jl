# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of default tables with Markdown.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Markdown" begin
    data = [1 md"[This is a link](https://ronanarraes.com)"
            2 md"**Bold** *italics*"]

    expected = """
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: right;">Col. 1</th>
    <th style = "text-align: right;">Col. 2</th>
  </tr>
  <tr>
    <td style = "text-align: right;">1</td>
    <td style = "text-align: right;"><div class="markdown"><p><a href="https://ronanarraes.com">This is a link</a></p></div></td>
  </tr>
  <tr>
    <td style = "text-align: right;">2</td>
    <td style = "text-align: right;"><div class="markdown"><p><strong>Bold</strong> <em>italics</em></p></div></td>
  </tr>
</table>
"""

    result = pretty_table(String, data, backend = :html, standalone = false)

    @test result == expected
end
