# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests of line breaks.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Cells with multiple lines" begin
    data = ["This line contains\nthe velocity [m/s]" 10.0;
            "This line contains\nthe acceleration [m/s^2]" 1.0;
            "This line contains\nthe time from the\nbeginning of the simulation" 10;]

    header = ["Information", "Value"]

    # Line breaks
    # --------------------------------------------------------------------------

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Information</th>
      <th style = "text-align: right;">Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">This line contains<BR>the velocity [m/s]</td>
      <td style = "text-align: right;">10.0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">This line contains<BR>the acceleration [m/s^2]</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">This line contains<BR>the time from the<BR>beginning of the simulation</td>
      <td style = "text-align: right;">10</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        header = header,
        linebreaks = true,
        standalone = false
    )

    @test result == expected

    # Show only the first line
    # --------------------------------------------------------------------------

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Information</th>
      <th style = "text-align: right;">Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">This line contains</td>
      <td style = "text-align: right;">10.0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">This line contains</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">This line contains</td>
      <td style = "text-align: right;">10</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        header = header,
        cell_first_line_only = true,
        standalone = false
    )

    @test result == expected
end
