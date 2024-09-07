## Description #############################################################################
#
# HTML Back End: Test to print stand alone tables.
#
############################################################################################

@testset "Stand Alone Tables" begin
    matrix = [1 2]

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<head>
<style>
  table, td, th {
    border-collapse: collapse;
    font-family: sans-serif;
  }

  td, th {
    padding-bottom: 6px !important;
    padding-left: 8px !important;
    padding-right: 8px !important;
    padding-top: 6px !important;
  }

  tr.title td {
    padding-bottom: 2px !important;
  }

  tr.footnote td {
    padding-bottom: 2px !important;
  }

  tr.sourceNotes td {
    padding-bottom: 2px !important;
  }

  table > *:first-child > tr:first-child {
    border-top: 2px solid black;
  }

  table > *:last-child > tr:last-child {
    border-bottom: 2px solid black;
  }

  thead > tr:nth-child(1 of .columnLabelRow) {
    border-top: 1px solid black;
  }

  thead tr:last-child {
    border-bottom: 1px solid black;
  }

  tbody tr:last-child {
    border-bottom: 1px solid black;
  }

  tbody > tr:nth-child(1 of .summaryRow) {
    border-top: 1px solid black;
  }

  tbody > tr:nth-last-child(1 of .summaryRow) {
    border-bottom: 1px solid black;
  }

  tfoot tr:nth-last-child(1 of .footnote) {
    border-bottom: 1px solid black;
  }
</style>
</head>
<body>
<table>
  <tr class = "columnLabelRow">
    <th style = "text-align: right; font-weight: bold;">Col. 1</th>
    <th style = "text-align: right; font-weight: bold;">Col. 2</th>
  </tr>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">2</td>
    </tr>
  </tbody>
</table>
</body>
</html>
"""

    result = pretty_table(String, matrix; backend = :html, stand_alone = true)

    @test result == expected
end
