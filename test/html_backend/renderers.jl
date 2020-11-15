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

    header = ["C1" "C2" "C3" "C4"
              "S1" "S2" "S3" "S4"]

    row_names = [1,2,"3",'4']

    expected = """
<table>
  <tr class = "header">
    <th class = "rowNumber">#</th>
    <th class = "rowName" style = "text-align: right; ">Test</th>
    <th style = "text-align: right; ">C1</th>
    <th style = "text-align: right; ">C2</th>
    <th style = "text-align: right; ">C3</th>
    <th style = "text-align: right; ">C4</th>
  </tr>
  <tr class = "subheader headerLastRow">
    <th></th>
    <th></th>
    <th style = "text-align: right; ">S1</th>
    <th style = "text-align: right; ">S2</th>
    <th style = "text-align: right; ">S3</th>
    <th style = "text-align: right; ">S4</th>
  </tr>
  <tr>
    <td class = "rowNumber">1</td>
    <td class = "rowName" style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">3.141592653589793238462643383279502884197169399375105820974944592307816406286198</td>
    <td style = "text-align: right; ">3.14159</td>
    <td style = "text-align: right; ">10.0</td>
    <td style = "text-align: right; ">1.0</td>
  </tr>
  <tr>
    <td class = "rowNumber">2</td>
    <td class = "rowName" style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td class = "rowNumber">3</td>
    <td class = "rowName" style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
  </tr>
  <tr>
    <td class = "rowNumber">4</td>
    <td class = "rowName" style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">Teste</td>
    <td style = "text-align: right; ">Teste<BR>Teste</td>
    <td style = "text-align: right; ">Teste "quote" Teste</td>
    <td style = "text-align: right; ">Teste<BR>"quote"<BR>Teste</td>
  </tr>
</table>
"""

    result = pretty_table(String, matrix, header;
                          backend = :html,
                          linebreaks = true,
                          row_names = row_names,
                          row_name_column_title = "Test",
                          row_number_column_title = "#",
                          show_row_number = true,
                          standalone = false)

    @test expected == result

    expected = """
<table>
  <tr class = "header">
    <th class = "rowNumber">#</th>
    <th class = "rowName" style = "text-align: right; ">Test</th>
    <th style = "text-align: right; ">C1</th>
    <th style = "text-align: right; ">C2</th>
    <th style = "text-align: right; ">C3</th>
    <th style = "text-align: right; ">C4</th>
  </tr>
  <tr class = "subheader headerLastRow">
    <th></th>
    <th></th>
    <th style = "text-align: right; ">S1</th>
    <th style = "text-align: right; ">S2</th>
    <th style = "text-align: right; ">S3</th>
    <th style = "text-align: right; ">S4</th>
  </tr>
  <tr>
    <td class = "rowNumber">1</td>
    <td class = "rowName" style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">3.141592653589793238462643383279502884197169399375105820974944592307816406286198</td>
    <td style = "text-align: right; ">3.141592653589793</td>
    <td style = "text-align: right; ">10.0</td>
    <td style = "text-align: right; ">1.0</td>
  </tr>
  <tr>
    <td class = "rowNumber">2</td>
    <td class = "rowName" style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td class = "rowNumber">3</td>
    <td class = "rowName" style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
  </tr>
  <tr>
    <td class = "rowNumber">4</td>
    <td class = "rowName" style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">Teste</td>
    <td style = "text-align: right; ">Teste<BR>Teste</td>
    <td style = "text-align: right; ">Teste "quote" Teste</td>
    <td style = "text-align: right; ">Teste<BR>"quote"<BR>Teste</td>
  </tr>
</table>
"""

    result = pretty_table(String, matrix, header;
                          backend = :html,
                          compact_printing = false,
                          linebreaks = true,
                          row_names = row_names,
                          row_name_column_title = "Test",
                          row_number_column_title = "#",
                          show_row_number = true,
                          standalone = false)

    @test expected == result
end

@testset "Renderers - show" begin
    matrix = Any[BigFloat(pi) float(pi) 10.0f0  Float16(1)
                 0x01         0x001     0x00001 0x000000001
                 true         false     true    false
                 "Teste" "Teste\nTeste" "Teste \"quote\" Teste" "Teste\n\"quote\"\nTeste"]

    header = ["C1" "C2" "C3" "C4"
              "S1" "S2" "S3" "S4"]

    row_names = [1,2,"3",'4']

    expected = """
<table>
  <tr class = "header">
    <th class = "rowNumber">#</th>
    <th class = "rowName" style = "text-align: right; ">Test</th>
    <th style = "text-align: right; ">C1</th>
    <th style = "text-align: right; ">C2</th>
    <th style = "text-align: right; ">C3</th>
    <th style = "text-align: right; ">C4</th>
  </tr>
  <tr class = "subheader headerLastRow">
    <th></th>
    <th></th>
    <th style = "text-align: right; ">S1</th>
    <th style = "text-align: right; ">S2</th>
    <th style = "text-align: right; ">S3</th>
    <th style = "text-align: right; ">S4</th>
  </tr>
  <tr>
    <td class = "rowNumber">1</td>
    <td class = "rowName" style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">3.14159</td>
    <td style = "text-align: right; ">3.14159</td>
    <td style = "text-align: right; ">10.0</td>
    <td style = "text-align: right; ">1.0</td>
  </tr>
  <tr>
    <td class = "rowNumber">2</td>
    <td class = "rowName" style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">0x01</td>
    <td style = "text-align: right; ">0x0001</td>
    <td style = "text-align: right; ">0x00000001</td>
    <td style = "text-align: right; ">0x0000000000000001</td>
  </tr>
  <tr>
    <td class = "rowNumber">3</td>
    <td class = "rowName" style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
  </tr>
  <tr>
    <td class = "rowNumber">4</td>
    <td class = "rowName" style = "text-align: right; ">'4'</td>
    <td style = "text-align: right; ">Teste</td>
    <td style = "text-align: right; ">Teste<BR>Teste</td>
    <td style = "text-align: right; ">Teste "quote" Teste</td>
    <td style = "text-align: right; ">Teste<BR>"quote"<BR>Teste</td>
  </tr>
</table>
"""

    result = pretty_table(String, matrix, header;
                          backend = :html,
                          linebreaks = true,
                          renderer = :show,
                          row_names = row_names,
                          row_name_column_title = "Test",
                          row_number_column_title = "#",
                          show_row_number = true,
                          standalone = false)

    @test expected == result

    expected = """
<table>
  <tr class = "header">
    <th class = "rowNumber">#</th>
    <th class = "rowName" style = "text-align: right; ">Test</th>
    <th style = "text-align: right; ">C1</th>
    <th style = "text-align: right; ">C2</th>
    <th style = "text-align: right; ">C3</th>
    <th style = "text-align: right; ">C4</th>
  </tr>
  <tr class = "subheader headerLastRow">
    <th></th>
    <th></th>
    <th style = "text-align: right; ">S1</th>
    <th style = "text-align: right; ">S2</th>
    <th style = "text-align: right; ">S3</th>
    <th style = "text-align: right; ">S4</th>
  </tr>
  <tr>
    <td class = "rowNumber">1</td>
    <td class = "rowName" style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">3.141592653589793238462643383279502884197169399375105820974944592307816406286198</td>
    <td style = "text-align: right; ">3.141592653589793</td>
    <td style = "text-align: right; ">10.0f0</td>
    <td style = "text-align: right; ">Float16(1.0)</td>
  </tr>
  <tr>
    <td class = "rowNumber">2</td>
    <td class = "rowName" style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">0x01</td>
    <td style = "text-align: right; ">0x0001</td>
    <td style = "text-align: right; ">0x00000001</td>
    <td style = "text-align: right; ">0x0000000000000001</td>
  </tr>
  <tr>
    <td class = "rowNumber">3</td>
    <td class = "rowName" style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">false</td>
  </tr>
  <tr>
    <td class = "rowNumber">4</td>
    <td class = "rowName" style = "text-align: right; ">'4'</td>
    <td style = "text-align: right; ">Teste</td>
    <td style = "text-align: right; ">Teste<BR>Teste</td>
    <td style = "text-align: right; ">Teste "quote" Teste</td>
    <td style = "text-align: right; ">Teste<BR>"quote"<BR>Teste</td>
  </tr>
</table>
"""

    result = pretty_table(String, matrix, header;
                          backend = :html,
                          compact_printing = false,
                          linebreaks = true,
                          renderer = :show,
                          row_names = row_names,
                          row_name_column_title = "Test",
                          row_number_column_title = "#",
                          standalone = false,
                          show_row_number = true)

    @test expected == result
end
