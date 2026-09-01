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
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;">(1, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 2)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 3)</td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;">(2, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 2)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 3)</td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black;">&dtdot;</td>
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
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;">(1, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 2)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 3)</td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-right: 2px solid black;">&dtdot;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">(100, 1)</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">(100, 2)</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">(100, 3)</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black;">&ctdot;</td>
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
            vertical_crop_mode = :middle,
        )

        @test result == expected
    end

    @testset "Omitted Cell Summary" begin
        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;">(1, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 2)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 3)</td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;">(2, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 2)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 3)</td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black;">&dtdot;</td>
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
            show_omitted_cell_summary = false,
        )

        @test result == expected
    end
end
