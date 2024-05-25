## Description #############################################################################
#
# Tests of formatters.
#
############################################################################################

@testset "Formatters" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: right;">Col. 3</th>
      <th style = "text-align: right;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">0</td>
    </tr>
  </tbody>
</table>
"""

    formatter = (data,i,j) -> begin
        if j != 2
            return isodd(i) ? i : 0
        else
            return data
        end
    end

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        formatters = formatter,
        standalone = false
    )

    @test result == expected
end
