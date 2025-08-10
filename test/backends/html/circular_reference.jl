## Description #############################################################################
#
# HTML Back End: Test circular reference.
#
############################################################################################

@testset "Circular Reference" begin
    cr = CircularRef(
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [10, 11, 12]
    )

    cr.A1[2]   = cr
    cr.A4[end] = cr

    expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">A1</th>
      <th style = "text-align: right; font-weight: bold;">A2</th>
      <th style = "text-align: right; font-weight: bold;">A3</th>
      <th style = "text-align: right; font-weight: bold;">A4</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">7</td>
      <td style = "text-align: right;">10</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">#= circular reference =#</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">11</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">9</td>
      <td style = "text-align: right;">#= circular reference =#</td>
    </tr>
  </tbody>
</table>
"""

    result = sprint(show, MIME("text/html"), cr)

    @test result == expected
end

