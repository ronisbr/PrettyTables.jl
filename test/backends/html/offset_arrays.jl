## Description #############################################################################
#
# HTML Back End: Test related with offset arrays.
#
############################################################################################

@testset "Offset Arrays" begin
    matrix = Matrix{Any}(undef, 3, 3)
    matrix[1, 1] = (1, 1)
    matrix[1, 2] = (1, 2)
    matrix[2, 1] = nothing
    matrix[2, 2] = missing
    matrix[3, 3] = (3, 3)

    omatrix = OffsetArray(matrix, -2:0, -3:-1)

    expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "text-align: right; font-weight: bold;">Row</th>
      <th style = "text-align: right; font-weight: bold;">Col. -3</th>
      <th style = "text-align: right; font-weight: bold;">Col. -2</th>
      <th style = "text-align: right; font-weight: bold;">Col. -1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">-2</td>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">-1</td>
      <td style = "text-align: right;">nothing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">0</td>
      <td style = "text-align: right;">#undef</td>
      <td style = "text-align: right;">#undef</td>
      <td style = "text-align: right;">(3, 3)</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        omatrix;
        backend = :html,
        show_row_number_column = true
    )

    @test result == expected
end
