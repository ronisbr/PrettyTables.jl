## Description #############################################################################
#
# HTML Back End: Test footnotes.
#
############################################################################################

@testset "Footnotes at Summary Row Labels" begin
    expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th class = "stubheadLabel" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowLabel" style = "border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td style = "border-right: 1px solid black; text-align: right;">1</td>
      <td style = "border-right: 2px solid black; text-align: right;">2</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowLabel" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">3</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">4</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowLabel" style = "border-left: 2px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Sum</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">4</td>
      <td style = "border-right: 2px solid black; border-top: 1px solid black; text-align: right;">6</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowLabel" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Max<sup>1</sup></td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">3</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">4</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote">
      <td colspan = "3" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-size: small; text-align: left;"><sup>1</sup> Footnote in summary row label</td>
    </tr>
  </tfoot>
</table>
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
        backend = :html,
        footnotes = [(:summary_row_label, 2, 0) => "Footnote in summary row label"],
        summary_rows = [(data, i) -> sum(data[:, i]), (data, i) -> maximum(data[:, i])],
        summary_row_labels = ["Sum", "Max"],
    )

    @test result == expected
end
