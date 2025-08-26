## Description #############################################################################
#
# HTML Back End: Tests related to table cropping.
#
############################################################################################

@testset "Table Cropping" verbose = true begin
    matrix = [(i, j) for i in 1:100, j in 1:100]

    @testset "Bottom Cropping" begin
        expected = """
<div>
  <div style = "float: right; font-style: italic;">
    <span>97 columns and 98 rows omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <td>&ctdot;</td>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td>&ctdot;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td>&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3
        )

        @test result == expected
    end

    @testset "Middle Cropping" begin
        expected = """
<div>
  <div style = "float: right; font-style: italic;">
    <span>97 columns and 98 rows omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <td>&ctdot;</td>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td>&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">(100, 1)</td>
      <td style = "text-align: right;">(100, 2)</td>
      <td style = "text-align: right;">(100, 3)</td>
      <td>&ctdot;</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            vertical_crop_mode = :middle
        )

        @test result == expected
    end

    @testset "Omitted Cell Summary" begin
        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <td>&ctdot;</td>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td>&ctdot;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td>&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            show_omitted_cell_summary = false
        )

        @test result == expected
    end
end
