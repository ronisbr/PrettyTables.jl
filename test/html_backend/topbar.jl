## Description #############################################################################
#
# Tests related with the top bar.
#
############################################################################################

@testset "Top Bar" begin
    expected = """
<div>
  <div style = "float: left;">
    <span style = "color: black;">Top left</span>
  </div>
  <div style = "float: right;">
    <span style = "color: yellow;">Top right</span>
  </div>
  <div style = "clear: both;"></div>
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
        top_left_str_decoration = HtmlDecoration(color = "black"),
        top_right_str = "Top right",
        top_right_str_decoration = HtmlDecoration(color = "yellow")
    )

    expected = """
<div>
  <div style = "float: left;">
    <span style = "color: black;">Top left</span>
  </div>
  <div style = "float: right;">
    <span style = "color: yellow;">Top right</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<div class = "tableClass" style = "overflow-x: scroll;">
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
</div>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        table_div_class = "tableClass",
        top_left_str = "Top left",
        top_left_str_decoration = HtmlDecoration(color = "black"),
        top_right_str = "Top right",
        top_right_str_decoration = HtmlDecoration(color = "yellow"),
        wrap_table_in_div = true,
    )

    @test result == expected
end
