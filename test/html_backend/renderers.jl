# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests of renderers.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Renderers - printf" begin
    matrix = Any[BigFloat(pi) float(pi) 10.0f0  Float16(1)
                 0x01         0x001     0x00001 0x000000001
                 true         false     true    false
                 "Teste" "Teste\nTeste" "Teste \"quote\" Teste" "Teste\n\"quote\"\nTeste"]

    header = (["C1", "C2", "C3", "C4"],
              ["S1", "S2", "S3", "S4"])

    row_names = [1, 2, "3", '4']

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">#</th>
      <th class = "rowName" style = "text-align: right;">Test</th>
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">C4</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th></th>
      <th style = "text-align: right;">S1</th>
      <th style = "text-align: right;">S2</th>
      <th style = "text-align: right;">S3</th>
      <th style = "text-align: right;">S4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td class = "rowName" style = "text-align: right;">1</td>
      <td style = "text-align: right;">3.141592653589793238462643383279502884197169399375105820974944592307816406286198</td>
      <td style = "text-align: right;">3.14159</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td class = "rowName" style = "text-align: right;">2</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td class = "rowName" style = "text-align: right;">3</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td class = "rowName" style = "text-align: right;">4</td>
      <td style = "text-align: right;">Teste</td>
      <td style = "text-align: right;">Teste<BR>Teste</td>
      <td style = "text-align: right;">Teste &quot;quote&quot; Teste</td>
      <td style = "text-align: right;">Teste<BR>&quot;quote&quot;<BR>Teste</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header = header,
        linebreaks = true,
        row_names = row_names,
        row_name_column_title = "Test",
        row_number_column_title = "#",
        show_row_number = true,
        standalone = false
    )

    @test expected == result

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">#</th>
      <th class = "rowName" style = "text-align: right;">Test</th>
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">C4</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th></th>
      <th style = "text-align: right;">S1</th>
      <th style = "text-align: right;">S2</th>
      <th style = "text-align: right;">S3</th>
      <th style = "text-align: right;">S4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td class = "rowName" style = "text-align: right;">1</td>
      <td style = "text-align: right;">3.141592653589793238462643383279502884197169399375105820974944592307816406286198</td>
      <td style = "text-align: right;">3.141592653589793</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td class = "rowName" style = "text-align: right;">2</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td class = "rowName" style = "text-align: right;">3</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td class = "rowName" style = "text-align: right;">4</td>
      <td style = "text-align: right;">Teste</td>
      <td style = "text-align: right;">Teste<BR>Teste</td>
      <td style = "text-align: right;">Teste &quot;quote&quot; Teste</td>
      <td style = "text-align: right;">Teste<BR>&quot;quote&quot;<BR>Teste</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header = header,
        compact_printing = false,
        linebreaks = true,
        row_names = row_names,
        row_name_column_title = "Test",
        row_number_column_title = "#",
        show_row_number = true,
        standalone = false
    )

    @test expected == result

    # Limit printing
    # --------------------------------------------------------------------------

    matrix = [[collect(1:1:30)] [collect(1:1:21)]
              [collect(1:1:20)] [collect(1:1:2)]]

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  21, 22, 23, 24, 25, 26, 27, 28, 29, 30]</td>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  12, 13, 14, 15, 16, 17, 18, 19, 20, 21]</td>
    </tr>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]</td>
      <td style = "text-align: right;">[1, 2]</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:html),
        standalone = false
    )

    @test expected == result

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]</td>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]</td>
    </tr>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]</td>
      <td style = "text-align: right;">[1, 2]</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:html),
        limit_printing = false,
        standalone = false
    )
    @test expected == result
end

@testset "Renderers - show" begin
    matrix = Any[BigFloat(pi) float(pi) 10.0f0  Float16(1)
                 0x01         0x001     0x00001 0x000000001
                 true         false     true    false
                 "Teste" "Teste\nTeste" "Teste \"quote\" Teste" "Teste\n\"quote\"\nTeste"]

    header = (["C1", "C2", "C3", "C4"],
              ["S1", "S2", "S3", "S4"])

    row_names = [1, 2, "3", '4']

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">#</th>
      <th class = "rowName" style = "text-align: right;">Test</th>
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">C4</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th></th>
      <th style = "text-align: right;">S1</th>
      <th style = "text-align: right;">S2</th>
      <th style = "text-align: right;">S3</th>
      <th style = "text-align: right;">S4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td class = "rowName" style = "text-align: right;">1</td>
      <td style = "text-align: right;">3.14159</td>
      <td style = "text-align: right;">3.14159</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">1.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td class = "rowName" style = "text-align: right;">2</td>
      <td style = "text-align: right;">0x01</td>
      <td style = "text-align: right;">0x0001</td>
      <td style = "text-align: right;">0x00000001</td>
      <td style = "text-align: right;">0x0000000000000001</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td class = "rowName" style = "text-align: right;">3</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td class = "rowName" style = "text-align: right;">&apos;4&apos;</td>
      <td style = "text-align: right;">Teste</td>
      <td style = "text-align: right;">Teste<BR>Teste</td>
      <td style = "text-align: right;">Teste &quot;quote&quot; Teste</td>
      <td style = "text-align: right;">Teste<BR>&quot;quote&quot;<BR>Teste</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header = header,
        linebreaks = true,
        renderer = :show,
        row_names = row_names,
        row_name_column_title = "Test",
        row_number_column_title = "#",
        show_row_number = true,
        standalone = false
    )

    @test expected == result

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">#</th>
      <th class = "rowName" style = "text-align: right;">Test</th>
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">C4</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th></th>
      <th style = "text-align: right;">S1</th>
      <th style = "text-align: right;">S2</th>
      <th style = "text-align: right;">S3</th>
      <th style = "text-align: right;">S4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td class = "rowName" style = "text-align: right;">1</td>
      <td style = "text-align: right;">3.141592653589793238462643383279502884197169399375105820974944592307816406286198</td>
      <td style = "text-align: right;">3.141592653589793</td>
      <td style = "text-align: right;">10.0f0</td>
      <td style = "text-align: right;">Float16(1.0)</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td class = "rowName" style = "text-align: right;">2</td>
      <td style = "text-align: right;">0x01</td>
      <td style = "text-align: right;">0x0001</td>
      <td style = "text-align: right;">0x00000001</td>
      <td style = "text-align: right;">0x0000000000000001</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td class = "rowName" style = "text-align: right;">3</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">false</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td class = "rowName" style = "text-align: right;">&apos;4&apos;</td>
      <td style = "text-align: right;">Teste</td>
      <td style = "text-align: right;">Teste<BR>Teste</td>
      <td style = "text-align: right;">Teste &quot;quote&quot; Teste</td>
      <td style = "text-align: right;">Teste<BR>&quot;quote&quot;<BR>Teste</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header = header,
        compact_printing = false,
        linebreaks = true,
        renderer = :show,
        row_names = row_names,
        row_name_column_title = "Test",
        row_number_column_title = "#",
        standalone = false,
        show_row_number = true
    )

    @test expected == result

    # Limit printing
    # --------------------------------------------------------------------------

    matrix = [[collect(1:1:30)] [collect(1:1:21)]
              [collect(1:1:20)] [collect(1:1:2)]]

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  21, 22, 23, 24, 25, 26, 27, 28, 29, 30]</td>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10  …  12, 13, 14, 15, 16, 17, 18, 19, 20, 21]</td>
    </tr>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]</td>
      <td style = "text-align: right;">[1, 2]</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:html),
        renderer = :show,
        standalone = false
    )
    @test expected == result

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]</td>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]</td>
    </tr>
    <tr>
      <td style = "text-align: right;">[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]</td>
      <td style = "text-align: right;">[1, 2]</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix,
        backend = Val(:html),
        limit_printing = false,
        renderer = :show,
        standalone = false
    )
    @test expected == result
end
