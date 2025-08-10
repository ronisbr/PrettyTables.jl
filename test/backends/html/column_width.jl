## Description #############################################################################
#
# HTML Back End: Test related with the column  widths.
#
############################################################################################

@testset "Maximum Column Width" begin
    matrix = [(i, j) for i in 1:3, j in 1:3]

    expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: bold;">Col. 2</th>
      <th style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: bold;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(1, 1)</td>
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(1, 2)</td>
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(1, 3)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(2, 1)</td>
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(2, 2)</td>
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(2, 3)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(3, 1)</td>
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(3, 2)</td>
      <td style = "text-align: right; max-width: 30px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">(3, 3)</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        maximum_column_width = "30px"
    )

    @test result == expected
end
