## Description #############################################################################
#
# Tests of offset arrays.
#
############################################################################################

@testset "Default Printing" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. -2</th>
      <th style = "text-align: right;">Col. -1</th>
      <th style = "text-align: right;">Col. 0</th>
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(String, odata; backend = Val(:html))
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">1</th>
      <th style = "text-align: right;">2</th>
      <th style = "text-align: right;">3</th>
      <th style = "text-align: right;">4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(String, odata; backend = Val(:html), header = 1:1:4)
    @test result == expected

    result = pretty_table(
        String,
        odata;
        backend = Val(:html),
        header = OffsetArray(1:1:4, -5:-2)
    )
    @test result == expected
end

@testset "Formatters" begin
    ft_row = (v, i, j) -> (i == -3) ? 0 : v

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. -2</th>
      <th style = "text-align: right;">Col. -1</th>
      <th style = "text-align: right;">Col. 0</th>
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">0.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">0</td>
      <td style = "text-align: right;">0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">0.0</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">0.0</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:html),
        formatters = (ft_round(2, [-1]), ft_row)
    )
    @test result == expected
end

@testset "Highlighters" begin

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. -2</th>
      <th style = "text-align: right;">Col. -1</th>
      <th style = "text-align: right;">Col. 0</th>
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "font-weight: bold; text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "font-weight: bold; text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "font-weight: bold; text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "font-weight: bold; text-align: right;">4</td>
      <td style = "font-weight: bold; text-align: right;">true</td>
      <td style = "font-weight: bold; text-align: right;">4.0</td>
      <td style = "font-weight: bold; text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "font-weight: bold; text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "font-weight: bold; text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    c = HtmlDecoration(font_weight = "bold")
    result = pretty_table(
        String,
        odata;
        backend = Val(:html),
        highlighters = (hl_row(-1, c), hl_col(1, c))
    )
end

@testset "Row Labels" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowLabel" style = "font-weight: bold; text-align: right;">Label</th>
      <th style = "text-align: right;">Col. -2</th>
      <th style = "text-align: right;">Col. -1</th>
      <th style = "text-align: right;">Col. 0</th>
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">3</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">5</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">7</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">9</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">11</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:html),
        row_labels = 1:2:12,
        row_label_column_title = "Label"
    )
    @test result == expected

    result = pretty_table(
        String,
        odata;
        backend = Val(:html),
        row_labels = OffsetArray(1:2:12, -5:0),
        row_label_column_title = "Label"
    )
    @test result == expected
end

@testset "Row Numbers" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowNumber" style = "font-weight: bold; text-align: right;">Row</th>
      <th style = "text-align: right;">Col. -2</th>
      <th style = "text-align: right;">Col. -1</th>
      <th style = "text-align: right;">Col. 0</th>
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">-4</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">-3</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">-2</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">-1</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">0</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">1</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        odata;
        backend = Val(:html),
        show_row_number = true
    )
    @test result == expected
end
