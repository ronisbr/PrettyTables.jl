## Description #############################################################################
#
# HTML Back End: Issues.
#
############################################################################################

@testset "Issues" verbose = true begin
    @testset "StyledStrings Support" begin
        A = [
            (1, 1)                          styled"({red:2}, {blue:3})"
            styled"({green:2}, {yellow:3})" "(2, 4)"
        ]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;"><Column 1></th>
      <th style = "font-weight: bold; text-align: right;"><Column 2></th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(2, 3)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">(2, 4)</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            A;
            backend       = :html,
            column_labels = [styled"<{red:Column 1}>", "<Column 2>"]
        )

        @test result == expected

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">&lt;<span style="color: #a51c2c">Column 1</span>&gt;</th>
      <th style = "font-weight: bold; text-align: right;">&lt;Column 2&gt;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(<span style="color: #a51c2c">2</span>, <span style="color: #195eb3">3</span>)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">(<span style="color: #25a268">2</span>, <span style="color: #e5a509">3</span>)</td>
      <td style = "text-align: right;">(2, 4)</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            A;
            backend       = :html,
            column_labels = [styled"<{red:Column 1}>", "<Column 2>"],
            renderer      = :show
        )
    end
end
