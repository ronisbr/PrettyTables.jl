## Description #############################################################################
#
# HTML Back End: Test footnotes.
#
############################################################################################

@testset "Footnotes at Summary Row Labels" begin
    expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black;">
      <th class = "stubheadLabel" style = "font-weight: bold; text-align: right;"></th>
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;"></td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;"></td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr class = "summaryRow" style = "border-top: 1px solid black;">
      <td class = "summaryRowLabel" style = "font-weight: bold; text-align: right;">Sum</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">6</td>
    </tr>
    <tr class = "summaryRow" style = "border-bottom: 1px solid black;">
      <td class = "summaryRowLabel" style = "font-weight: bold; text-align: right;">Max<sup>1</sup></td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote" style = "border-bottom: 1px solid black;">
      <td colspan = "3" style = "font-size: small; text-align: left;"><sup>1</sup> Footnote in summary row label</td>
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
