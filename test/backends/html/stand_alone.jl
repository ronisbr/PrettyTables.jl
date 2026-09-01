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
<head>
<meta charset="UTF-8">
<style>
  table, td, th {
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
</style>
</head>
<body>
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">1</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">2</td>
    </tr>
  </tbody>
</table>
</body>
</html>
"""

    result = pretty_table(String, matrix; backend = :html, stand_alone = true)

    @test result == expected
end

@testset "Stand Alone Tables With Table Div" begin
    # The div that wraps the table must be closed before the end of the document.
    result = pretty_table(
        String,
        [1 2];
        backend = :html,
        stand_alone = true,
        wrap_table_in_div = true,
    )

    @test occursin("</div>\n</body>\n</html>", result)
    @test !occursin("</html>\n</div>", result)
end
