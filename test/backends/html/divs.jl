## Description #############################################################################
#
# HTML Back End: Tests related to divs.
#
############################################################################################

@testset "Divs" verbose = true begin
    matrix = [1 2]

    expected = """
<div overflow-x = "scroll">
  <table class = "myClass">
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
    </tr>
    <tbody>
      <tr class = "dataRow">
        <td style = "text-align: right;">1</td>
        <td style = "text-align: right;">2</td>
      </tr>
    </tbody>
  </table>
</div>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        table_class = "myClass",
        wrap_table_in_div = true,
    )

    @test result == expected

    expected = """
<div>
  <div style = "font-weight: bold; float: left;">
    <span>Top Left</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<div overflow-x = "scroll">
  <table class = "myClass">
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
    </tr>
    <tbody>
      <tr class = "dataRow">
        <td style = "text-align: right;">1</td>
        <td style = "text-align: right;">2</td>
      </tr>
    </tbody>
  </table>
</div>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        table_class = "myClass",
        top_left_string = "Top Left",
        wrap_table_in_div = true,
    )

    @test result == expected

    expected = """
<div>
  <div style = "font-weight: bold; float: left;">
    <span>Top Left</span>
  </div>
  <div style = "font-style: italic; float: right;">
    <span>Top Right</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<div overflow-x = "scroll">
  <table class = "myClass">
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
    </tr>
    <tbody>
      <tr class = "dataRow">
        <td style = "text-align: right;">1</td>
        <td style = "text-align: right;">2</td>
      </tr>
    </tbody>
  </table>
</div>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        table_class = "myClass",
        top_left_string = "Top Left",
        top_right_string = "Top Right",
        wrap_table_in_div = true,
    )

    @test result == expected
end
