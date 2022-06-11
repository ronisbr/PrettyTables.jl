# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests related with cropping.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Cropping" begin
    matrix = [(i, j) for i in 1:7, j in 1:7]
    header = (
        ["Column $i" for i in 1:7],
        ["C$i" for i in 1:7]
    )

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">⋯</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">⋯</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋱</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        maximum_number_of_rows = 3,
        maximum_number_of_columns = 3
    )
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">Column 4</th>
      <th style = "text-align: right;">Column 5</th>
      <th style = "text-align: right;">Column 6</th>
      <th style = "text-align: right;">Column 7</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">C4</th>
      <th style = "text-align: right;">C5</th>
      <th style = "text-align: right;">C6</th>
      <th style = "text-align: right;">C7</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">(1, 4)</td>
      <td style = "text-align: right;">(1, 5)</td>
      <td style = "text-align: right;">(1, 6)</td>
      <td style = "text-align: right;">(1, 7)</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">(2, 4)</td>
      <td style = "text-align: right;">(2, 5)</td>
      <td style = "text-align: right;">(2, 6)</td>
      <td style = "text-align: right;">(2, 7)</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td style = "text-align: right;">(3, 4)</td>
      <td style = "text-align: right;">(3, 5)</td>
      <td style = "text-align: right;">(3, 6)</td>
      <td style = "text-align: right;">(3, 7)</td>
    </tr>
    <tr>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        maximum_number_of_rows = 3
    )
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">⋯</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">⋯</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(4, 1)</td>
      <td style = "text-align: right;">(4, 2)</td>
      <td style = "text-align: right;">(4, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(5, 1)</td>
      <td style = "text-align: right;">(5, 2)</td>
      <td style = "text-align: right;">(5, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(6, 1)</td>
      <td style = "text-align: right;">(6, 2)</td>
      <td style = "text-align: right;">(6, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(7, 1)</td>
      <td style = "text-align: right;">(7, 2)</td>
      <td style = "text-align: right;">(7, 3)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        maximum_number_of_columns = 3
    )
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 4</th>
      <th style = "text-align: right;">⋯</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C4</th>
      <th style = "text-align: right;">⋯</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 4)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 4)</td>
      <td style = "text-align: right;">⋯</td>
    </tr>
    <tr>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋮</td>
      <td style = "text-align: right;">⋱</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        column_filters = ((data, i) -> i % 2 == 0,),
        header = header,
        maximum_number_of_columns = 2,
        maximum_number_of_rows = 2,
        row_filters = ((data, i) -> i % 2 == 1,)
    )
    @test result == expected
end
