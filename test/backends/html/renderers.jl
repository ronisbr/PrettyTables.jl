## Description #############################################################################
#
# HTML Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    matrix = ['a' :a "a" missing nothing]

    @testset ":print" begin
        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black;">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "font-weight: bold; text-align: right;">Col. 4</th>
      <th style = "font-weight: bold; text-align: right;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
  </tbody>
</table>
"""
        result = pretty_table(String, matrix; backend = :html)

        @test result == expected
    end

    @testset ":show" begin
        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black;">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "font-weight: bold; text-align: right;">Col. 4</th>
      <th style = "font-weight: bold; text-align: right;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td style = "text-align: right;">&apos;a&apos;</td>
      <td style = "text-align: right;">:a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html, renderer = :show)

        @test result == expected
    end
end
