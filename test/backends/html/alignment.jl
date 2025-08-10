## Description #############################################################################
#
# HTML Back End: Tests related with the cell alignment.
#
############################################################################################

@testset "Alignment" verbose = true begin
    matrix = [(i, j) for i in 1:5, j in 1:5]

    @testset "Alignment as a Symbol" verbose = true  begin
        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: center; font-weight: bold;">Col. 1</th>
      <th style = "text-align: center; font-weight: bold;">Col. 2</th>
      <th style = "text-align: center; font-weight: bold;">Col. 3</th>
      <th style = "text-align: center; font-weight: bold;">Col. 4</th>
      <th style = "text-align: center; font-weight: bold;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: center;">(1, 1)</td>
      <td style = "text-align: center;">(1, 2)</td>
      <td style = "text-align: center;">(1, 3)</td>
      <td style = "text-align: center;">(1, 4)</td>
      <td style = "text-align: center;">(1, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: center;">(2, 1)</td>
      <td style = "text-align: center;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: center;">(2, 4)</td>
      <td style = "text-align: center;">(2, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: center;">(3, 1)</td>
      <td style = "text-align: center;">(3, 2)</td>
      <td style = "text-align: center;">(3, 3)</td>
      <td style = "text-align: center;">(3, 4)</td>
      <td style = "text-align: center;">(3, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: center;">(4, 1)</td>
      <td style = "text-align: center;">(4, 2)</td>
      <td style = "text-align: center;">(4, 3)</td>
      <td style = "text-align: center;">(4, 4)</td>
      <td style = "text-align: left;">(4, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: center;">(5, 1)</td>
      <td style = "text-align: center;">(5, 2)</td>
      <td style = "text-align: center;">(5, 3)</td>
      <td style = "text-align: center;">(5, 4)</td>
      <td style = "text-align: center;">(5, 5)</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            alignment = :c,
            backend = :html,
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold;">Col. 1</th>
      <th style = "font-weight: bold;">Col. 2</th>
      <th style = "font-weight: bold;">Col. 3</th>
      <th style = "font-weight: bold;">Col. 4</th>
      <th style = "font-weight: bold;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td>(1, 1)</td>
      <td>(1, 2)</td>
      <td>(1, 3)</td>
      <td>(1, 4)</td>
      <td>(1, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td>(2, 1)</td>
      <td>(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td>(2, 4)</td>
      <td>(2, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td>(3, 1)</td>
      <td>(3, 2)</td>
      <td>(3, 3)</td>
      <td>(3, 4)</td>
      <td>(3, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td>(4, 1)</td>
      <td>(4, 2)</td>
      <td>(4, 3)</td>
      <td>(4, 4)</td>
      <td style = "text-align: left;">(4, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td>(5, 1)</td>
      <td>(5, 2)</td>
      <td>(5, 3)</td>
      <td>(5, 4)</td>
      <td>(5, 5)</td>
    </tr>
  </tbody>
</table>
"""
        result = pretty_table(
            String,
            matrix;
            alignment = :n,
            backend = :html,
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected
    end

    @testset "Alignment as a Vector" verbose = true  begin
        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: left; font-weight: bold;">Col. 1</th>
      <th style = "text-align: center; font-weight: bold;">Col. 2</th>
      <th style = "text-align: right; font-weight: bold;">Col. 3</th>
      <th style = "text-align: left; font-weight: bold;">Col. 4</th>
      <th style = "text-align: center; font-weight: bold;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: left;">(1, 1)</td>
      <td style = "text-align: center;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: left;">(1, 4)</td>
      <td style = "text-align: center;">(1, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(2, 1)</td>
      <td style = "text-align: center;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: left;">(2, 4)</td>
      <td style = "text-align: center;">(2, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(3, 1)</td>
      <td style = "text-align: center;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td style = "text-align: left;">(3, 4)</td>
      <td style = "text-align: center;">(3, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(4, 1)</td>
      <td style = "text-align: center;">(4, 2)</td>
      <td style = "text-align: right;">(4, 3)</td>
      <td style = "text-align: left;">(4, 4)</td>
      <td style = "text-align: left;">(4, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(5, 1)</td>
      <td style = "text-align: center;">(5, 2)</td>
      <td style = "text-align: right;">(5, 3)</td>
      <td style = "text-align: left;">(5, 4)</td>
      <td style = "text-align: center;">(5, 5)</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            alignment = [:l, :c, :r, :l, :c],
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: left; font-weight: bold;">Col. 1</th>
      <th style = "text-align: center; font-weight: bold;">Col. 2</th>
      <th style = "text-align: right; font-weight: bold;">Col. 3</th>
      <th style = "font-weight: bold;">Col. 4</th>
      <th style = "text-align: right; font-weight: bold;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: left;">(1, 1)</td>
      <td style = "text-align: center;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td>(1, 4)</td>
      <td style = "text-align: right;">(1, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(2, 1)</td>
      <td style = "text-align: center;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td>(2, 4)</td>
      <td style = "text-align: right;">(2, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(3, 1)</td>
      <td style = "text-align: center;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td>(3, 4)</td>
      <td style = "text-align: right;">(3, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(4, 1)</td>
      <td style = "text-align: center;">(4, 2)</td>
      <td style = "text-align: right;">(4, 3)</td>
      <td>(4, 4)</td>
      <td style = "text-align: left;">(4, 5)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: left;">(5, 1)</td>
      <td style = "text-align: center;">(5, 2)</td>
      <td style = "text-align: right;">(5, 3)</td>
      <td>(5, 4)</td>
      <td style = "text-align: right;">(5, 5)</td>
    </tr>
  </tbody>
</table>
"""
        result = pretty_table(
            String,
            matrix;
            backend = :html,
            alignment = [:l, :c, :r, :n, :X],
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected
    end
end
