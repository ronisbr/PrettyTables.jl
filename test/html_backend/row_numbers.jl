# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests of row numbers.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Show row number" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowNumber">Row</th>
      <th style = "text-align: left;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: center;">Col. 3</th>
      <th style = "text-align: right;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td style = "text-align: left;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td style = "text-align: left;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td style = "text-align: left;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td style = "text-align: left;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td class = "rowNumber">5</td>
      <td style = "text-align: left;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td class = "rowNumber">6</td>
      <td style = "text-align: left;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""
    result = pretty_table(
        String,
        data;
        alignment = [:l, :r, :c, :r],
        backend = Val(:html),
        standalone = false,
        show_row_number = true
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowNumber">Row number</th>
      <th style = "text-align: left;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: center;">Col. 3</th>
      <th style = "text-align: right;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td style = "text-align: left;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td style = "text-align: left;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td style = "text-align: left;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td style = "text-align: left;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td class = "rowNumber">5</td>
      <td style = "text-align: left;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td class = "rowNumber">6</td>
      <td style = "text-align: left;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""
    result = pretty_table(
        String,
        data;
        alignment = [:l, :r, :c, :r],
        backend = Val(:html),
        standalone = false,
        row_number_column_title = "Row number",
        show_row_number = true
    )

    @test result == expected
end
