## Description #############################################################################
#
# Tests of column width.
#
############################################################################################

@testset "Maximum Column Width" begin

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 1</th>
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 2</th>
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 3</th>
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">1</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">false</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">1.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">1</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">2</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">true</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">2.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">2</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">3</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">false</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">3.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">3</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">4</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">true</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">4.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">4</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">5</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">false</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">5.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">5</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">6</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">true</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">6.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        maximum_columns_width = "100px"
    )
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 1</th>
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 2</th>
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 3</th>
      <th style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">1</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">false</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">1.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">1</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">2</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">true</td>
      <td style = "font-weight: bold; max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">2.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">2</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">3</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">false</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">3.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">3</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">4</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">true</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">4.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">4</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">5</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">false</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">5.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">5</td>
    </tr>
    <tr>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">6</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">true</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">6.0</td>
      <td style = "max-width: 100px; overflow: hidden; text-align: right; text-overflow: ellipsis; white-space: nowrap;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = (hl_cell(2, 3, HtmlDecoration(font_weight = "bold")),),
        maximum_columns_width = "100px"
    )
    @test result == expected
end
