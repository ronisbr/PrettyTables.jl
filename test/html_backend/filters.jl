# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests of filters.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Filters" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowNumber" style = "text-align: right;">Row</th>
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber" style = "text-align: right;">2</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">2.0</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "text-align: right;">4</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">4.0</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "text-align: right;">6</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">6.0</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String, data;
        backend = Val(:html),
        column_filters = ((data, i) -> i % 2 == 1,),
        formatters = ft_printf("%.1f",3),
        row_filters = ((data, i) -> i % 2 == 0,),
        standalone = false,
        show_row_number = true
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowNumber" style = "text-align: right;">Row</th>
      <th style = "text-align: center;">Col. 1</th>
      <th style = "text-align: left;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber" style = "text-align: right;">2</td>
      <td style = "text-align: center;">2</td>
      <td style = "text-align: left;">2.0</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "text-align: right;">4</td>
      <td style = "text-align: center;">4</td>
      <td style = "text-align: left;">4.0</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "text-align: right;">6</td>
      <td style = "text-align: center;">6</td>
      <td style = "text-align: left;">6.0</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String, data;
        alignment = [:c, :l, :l, :c],
        backend = Val(:html),
        column_filters = ((data ,i) -> i % 2 == 1,),
        formatters = ft_printf("%.1f", 3),
        row_filters = ((data, i) -> i % 2 == 0,),
        standalone = false,
        show_row_number = true
    )

    @test result == expected
end
