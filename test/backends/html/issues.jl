## Description #############################################################################
#
# HTML Back End: Issues.
#
############################################################################################

@testset "Issues" verbose = true begin
    @static if VERSION >= v"1.11"
        @testset "StyledStrings Support" begin
            A = [
                (1, 1)                          styled"({red:2}, {blue:3})"
                styled"({green:2}, {yellow:3})" "(2, 4)"
            ]

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black;">
      <th style = "font-weight: bold; text-align: right;">&lt;<span style = "color: #a51c2c;">Column 1</span>&gt;</th>
      <th style = "font-weight: bold; text-align: right;">&lt;Column 2&gt;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(<span style = "color: #a51c2c;">2</span>, <span style = "color: #195eb3;">3</span>)</td>
    </tr>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td style = "text-align: right;">(<span style = "color: #25a268;">2</span>, <span style = "color: #e5a509;">3</span>)</td>
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
            )

            @test result == expected

            expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black;">
      <th style = "font-weight: bold; text-align: right;">&lt;<span style = "color: #a51c2c;">Column 1</span>&gt;</th>
      <th style = "font-weight: bold; text-align: right;">&lt;Column 2&gt;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(<span style = "color: #a51c2c;">2</span>, <span style = "color: #195eb3;">3</span>)</td>
    </tr>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td style = "text-align: right;">(<span style = "color: #25a268;">2</span>, <span style = "color: #e5a509;">3</span>)</td>
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
                renderer      = :show,
            )
        end
    end
end
