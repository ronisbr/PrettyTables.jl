# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related with the top bar.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Top bar" begin
    expected = """
<div style="height: 14px">
  <div style="position: absolute; text-align: left">
    <span style = "color: black;">Top left</span>
  </div>
  <div style="position: absolute; right: 0; text-align: right">
    <span style = "color: yellow;">Top right</span>
  </div>
  <div style="position: absolute; left: 0; right: 0; text-align: center">
    <span style = "color: green;">Top center</span>
  </div>
</div>
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

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        top_left_str = "Top left",
        top_left_str_decoration = HTMLDecoration(color = "black"),
        top_center_str = "Top center",
        top_center_str_decoration = HTMLDecoration(color = "green"),
        top_right_str = "Top right",
        top_right_str_decoration = HTMLDecoration(color = "yellow")
    )

    @test result == expected
end
