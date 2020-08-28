# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

data = Any[1    false      1.0     0x01 ;
           2     true      2.0     0x02 ;
           3    false      3.0     0x03 ;
           4     true      4.0     0x04 ;
           5    false      5.0     0x05 ;
           6     true      6.0     0x06 ;]

# Default
# ==============================================================================

@testset "Default" begin

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">1.0</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">3.0</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">4.0</td>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">6.0</td>
    <td style = "text-align: right; ">6</td>
  </tr>
</table>
</body>
</html>
"""
    result = pretty_table(String, data, backend = :html)
    @test result == expected
end

# Alignments
# ==============================================================================

@testset "Alignments" begin
    # Left
    # ==========================================================================
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: left; ">Col. 1</th>
    <th style = "text-align: left; ">Col. 2</th>
    <th style = "text-align: left; ">Col. 3</th>
    <th style = "text-align: left; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: left; ">1</td>
    <td style = "text-align: left; ">false</td>
    <td style = "text-align: left; ">1.0</td>
    <td style = "text-align: left; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">2</td>
    <td style = "text-align: left; ">true</td>
    <td style = "text-align: left; ">2.0</td>
    <td style = "text-align: left; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">3</td>
    <td style = "text-align: left; ">false</td>
    <td style = "text-align: left; ">3.0</td>
    <td style = "text-align: left; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">4</td>
    <td style = "text-align: left; ">true</td>
    <td style = "text-align: left; ">4.0</td>
    <td style = "text-align: left; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">5</td>
    <td style = "text-align: left; ">false</td>
    <td style = "text-align: left; ">5.0</td>
    <td style = "text-align: left; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">6</td>
    <td style = "text-align: left; ">true</td>
    <td style = "text-align: left; ">6.0</td>
    <td style = "text-align: left; ">6</td>
  </tr>
</table>
</body>
</html>
"""
    result = pretty_table(String, data; alignment = :l, backend = :html)
    @test result == expected

    # Center
    # ==========================================================================
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: center; ">Col. 1</th>
    <th style = "text-align: center; ">Col. 2</th>
    <th style = "text-align: center; ">Col. 3</th>
    <th style = "text-align: center; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: center; ">1</td>
    <td style = "text-align: center; ">false</td>
    <td style = "text-align: center; ">1.0</td>
    <td style = "text-align: center; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: center; ">2</td>
    <td style = "text-align: center; ">true</td>
    <td style = "text-align: center; ">2.0</td>
    <td style = "text-align: center; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: center; ">3</td>
    <td style = "text-align: center; ">false</td>
    <td style = "text-align: center; ">3.0</td>
    <td style = "text-align: center; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: center; ">4</td>
    <td style = "text-align: center; ">true</td>
    <td style = "text-align: center; ">4.0</td>
    <td style = "text-align: center; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: center; ">5</td>
    <td style = "text-align: center; ">false</td>
    <td style = "text-align: center; ">5.0</td>
    <td style = "text-align: center; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: center; ">6</td>
    <td style = "text-align: center; ">true</td>
    <td style = "text-align: center; ">6.0</td>
    <td style = "text-align: center; ">6</td>
  </tr>
</table>
</body>
</html>
"""
    result = pretty_table(String, data; alignment = :c, backend = :html)
    @test result == expected

    # Per column configuration
    # ==========================================================================

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: left; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: center; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: left; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">1.0</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">3.0</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">4.0</td>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">6.0</td>
    <td style = "text-align: right; ">6</td>
  </tr>
</table>
</body>
</html>
"""
    result = pretty_table(String, data;
                          alignment = [:l,:r,:c,:r],
                          backend   = :html)
    @test result == expected

    # Cell override
    # ==========================================================================

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: left; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: center; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: left; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">1.0</td>
    <td style = "text-align: left; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: left; ">false</td>
    <td style = "text-align: center; ">3.0</td>
    <td style = "text-align: center; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">4.0</td>
    <td style = "text-align: center; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">6.0</td>
    <td style = "text-align: left; ">6</td>
  </tr>
</table>
</body>
</html>
"""
    result = pretty_table(String, data;
                          alignment = [:l,:r,:c,:r],
                          backend = :html,
                          cell_alignment = Dict((3,1) => :r,
                                                (3,2) => :l,
                                                (1,4) => :l,
                                                (3,4) => :c,
                                                (4,4) => :c,
                                                (6,4) => :l ))
    @test result == expected

    # Headers
    # ==========================================================================

    header = ["A" "B" "C" "D"
              "a" "b" "c" "d"]

    expected = """
<table>
  <tr class = header>
    <th style = "text-align: left; ">A</th>
    <th style = "text-align: center; ">B</th>
    <th style = "text-align: right; ">C</th>
    <th style = "text-align: right; ">D</th>
  </tr>
  <tr class = "subheader headerLastRow">
    <th style = "text-align: left; ">a</th>
    <th style = "text-align: center; ">b</th>
    <th style = "text-align: right; ">c</th>
    <th style = "text-align: right; ">d</th>
  </tr>
  <tr>
    <td style = "text-align: left; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">1.0</td>
    <td style = "text-align: left; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: left; ">false</td>
    <td style = "text-align: center; ">3.0</td>
    <td style = "text-align: center; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">4.0</td>
    <td style = "text-align: center; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">6.0</td>
    <td style = "text-align: left; ">6</td>
  </tr>
</table>
"""

    result = pretty_table(String, data, header;
                          alignment = [:l,:r,:c,:r],
                          backend = :html,
                          cell_alignment = Dict( (3,1) => :r,
                                                 (3,2) => :l,
                                                 (1,4) => :l,
                                                 (3,4) => :c,
                                                 (4,4) => :c,
                                                 (6,4) => :l ),
                          header_alignment = [:l,:c,:r,:r],
                          standalone = false)
    @test result == expected

    expected = """
<table>
  <tr class = header>
    <th style = "text-align: right; ">A</th>
    <th style = "text-align: center; ">B</th>
    <th style = "text-align: right; ">C</th>
    <th style = "text-align: right; ">D</th>
  </tr>
  <tr class = "subheader headerLastRow">
    <th style = "text-align: left; ">a</th>
    <th style = "text-align: left; ">b</th>
    <th style = "text-align: right; ">c</th>
    <th style = "text-align: center; ">d</th>
  </tr>
  <tr>
    <td style = "text-align: left; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">1.0</td>
    <td style = "text-align: left; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: left; ">false</td>
    <td style = "text-align: center; ">3.0</td>
    <td style = "text-align: center; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">4.0</td>
    <td style = "text-align: center; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: left; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">6.0</td>
    <td style = "text-align: left; ">6</td>
  </tr>
</table>
"""

    result = pretty_table(String, data, header;
                          alignment = [:l,:r,:c,:r],
                          backend = :html,
                          cell_alignment = Dict( (3,1) => :r,
                                                 (3,2) => :l,
                                                 (1,4) => :l,
                                                 (3,4) => :c,
                                                 (4,4) => :c,
                                                 (6,4) => :l ),
                          header_alignment = [:l,:c,:r,:r],
                          header_cell_alignment = Dict( (1,1) => :r,
                                                        (2,2) => :l,
                                                        (2,4) => :c),
                          standalone = false)
    @test result == expected
end

# Filters
# ==============================================================================

@testset "Filters" begin
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th class = rowNumber>Row</th>
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 3</th>
  </tr>
  <tr>
    <td class = rowNumber>2</td>
    <td style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">2.0</td>
  </tr>
  <tr>
    <td class = rowNumber>4</td>
    <td style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">4.0</td>
  </tr>
  <tr>
    <td class = rowNumber>6</td>
    <td style = "text-align: right; ">6</td>
    <td style = "text-align: right; ">6.0</td>
  </tr>
</table>
</body>
</html>
"""

    result = pretty_table(String, data;
                          backend         = :html,
                          filters_row     = ((data,i) -> i%2 == 0,),
                          filters_col     = ((data,i) -> i%2 == 1,),
                          formatters      = ft_printf("%.1f",3),
                          show_row_number = true)
    @test result == expected

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th class = rowNumber>Row</th>
    <th style = "text-align: center; ">Col. 1</th>
    <th style = "text-align: left; ">Col. 3</th>
  </tr>
  <tr>
    <td class = rowNumber>2</td>
    <td style = "text-align: center; ">2</td>
    <td style = "text-align: left; ">2.0</td>
  </tr>
  <tr>
    <td class = rowNumber>4</td>
    <td style = "text-align: center; ">4</td>
    <td style = "text-align: left; ">4.0</td>
  </tr>
  <tr>
    <td class = rowNumber>6</td>
    <td style = "text-align: center; ">6</td>
    <td style = "text-align: left; ">6.0</td>
  </tr>
</table>
</body>
</html>
"""

    result = pretty_table(String, data;
                          backend         = :html,
                          filters_row     = ((data,i) -> i%2 == 0,),
                          filters_col     = ((data,i) -> i%2 == 1,),
                          formatters      = ft_printf("%.1f",3),
                          show_row_number = true,
                          alignment       = [:c,:l,:l,:c])
    @test result == expected
end

# Formatters
# ==============================================================================

@testset "Formatters" begin
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">0</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">0</td>
    <td style = "text-align: right; ">0</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">0</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">0</td>
    <td style = "text-align: right; ">0</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">0</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">0</td>
    <td style = "text-align: right; ">0</td>
  </tr>
</table>
</body>
</html>
"""
    formatter = (data,i,j) -> begin
        if j != 2
            return isodd(i) ? i : 0
        else
            return data
        end
    end
    result = pretty_table(String, data; backend = :html, formatters = formatter)
    @test result == expected
end

# Not standalone printing
# ==============================================================================

@testset "Not standalone printing" begin
    expected = """
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">1.0</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">3.0</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">4.0</td>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">6.0</td>
    <td style = "text-align: right; ">6</td>
  </tr>
</table>
"""

    result = pretty_table(String, data, backend = :html, standalone = false)
    @test result == expected
end

# Show row number
# ==============================================================================

@testset "Show row number" begin
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th class = rowNumber>Row</th>
    <th style = "text-align: left; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: center; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td class = rowNumber>1</td>
    <td style = "text-align: left; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">1.0</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td class = rowNumber>2</td>
    <td style = "text-align: left; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td class = rowNumber>3</td>
    <td style = "text-align: left; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">3.0</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td class = rowNumber>4</td>
    <td style = "text-align: left; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">4.0</td>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td class = rowNumber>5</td>
    <td style = "text-align: left; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: center; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td class = rowNumber>6</td>
    <td style = "text-align: left; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: center; ">6.0</td>
    <td style = "text-align: right; ">6</td>
  </tr>
</table>
</body>
</html>
"""
    result = pretty_table(String, data;
                          alignment       = [:l,:r,:c,:r],
                          backend         = :html,
                          show_row_number = true)
    @test result == expected
end

# Sub-headers
# ==============================================================================

# Hiding header and sub-header
# ==============================================================================

# Print vectors
# ==============================================================================

@testset "Print vectors" begin

    vec = 0:1:10

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">0</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">6</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">7</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">8</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">9</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">10</td>
  </tr>
</table>
</body>
</html>
"""

    result = pretty_table(String, vec, backend = :html)
    @test result == expected

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <tr class = "header headerLastRow">
    <th class = rowNumber>Row</th>
    <th style = "text-align: center; ">Col. 1</th>
  </tr>
  <tr>
    <td class = rowNumber>1</td>
    <td style = "text-align: center; ">0</td>
  </tr>
  <tr>
    <td class = rowNumber>2</td>
    <td style = "text-align: center; ">1</td>
  </tr>
  <tr>
    <td class = rowNumber>3</td>
    <td style = "text-align: center; ">2</td>
  </tr>
  <tr>
    <td class = rowNumber>4</td>
    <td style = "text-align: center; ">3</td>
  </tr>
  <tr>
    <td class = rowNumber>5</td>
    <td style = "text-align: center; ">4</td>
  </tr>
  <tr>
    <td class = rowNumber>6</td>
    <td style = "text-align: center; ">5</td>
  </tr>
  <tr>
    <td class = rowNumber>7</td>
    <td style = "text-align: center; ">6</td>
  </tr>
  <tr>
    <td class = rowNumber>8</td>
    <td style = "text-align: center; ">7</td>
  </tr>
  <tr>
    <td class = rowNumber>9</td>
    <td style = "text-align: center; ">8</td>
  </tr>
  <tr>
    <td class = rowNumber>10</td>
    <td style = "text-align: center; ">9</td>
  </tr>
  <tr>
    <td class = rowNumber>11</td>
    <td style = "text-align: center; ">10</td>
  </tr>
</table>
</body>
</html>
"""

    result = pretty_table(String, vec;
                          alignment       = :c,
                          backend         = :html,
                          show_row_number = true)
    @test result == expected

    # TODO: test sub-headers.
end

# Dictionaries
# ==============================================================================

# Helpers
# ==============================================================================

# Test if we can print `missing`, `nothing`, and `#undef`
# ==============================================================================

@testset "Print missing, nothing, and #undef" begin

    matrix = Matrix{Any}(undef,3,3)
    matrix[1,1:2] .= missing
    matrix[2,1:2] .= nothing
    matrix[3,1]   = missing
    matrix[3,2]   = nothing

    expected = """
<table>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">missing</td>
    <td style = "text-align: right; ">missing</td>
    <td style = "text-align: right; ">#undef</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">nothing</td>
    <td style = "text-align: right; ">nothing</td>
    <td style = "text-align: right; ">#undef</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">missing</td>
    <td style = "text-align: right; ">nothing</td>
    <td style = "text-align: right; ">#undef</td>
  </tr>
</table>
"""

    result = pretty_table(String, matrix, tf = html_default, standalone = false)
    @test result == expected
end

# Titles
# ==============================================================================

@testset "Titles" begin
    title = "This is a very very long title that will be displayed above the table."

    expected = """
<table>
  <caption style = "text-align: left; ">This is a very very long title that will be displayed above the table.</caption>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">1.0</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">3.0</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">4.0</td>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">6.0</td>
    <td style = "text-align: right; ">6</td>
  </tr>
</table>
"""

    result = pretty_table(String, data, tf = html_default, standalone = false,
                          title = title)
    @test result == expected

    expected = """
<table>
  <caption style = "text-align: center; ">This is a very very long title that will be displayed above the table.</caption>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">1.0</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">3.0</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">4.0</td>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">6.0</td>
    <td style = "text-align: right; ">6</td>
  </tr>
</table>
"""

    result = pretty_table(String, data, tf = html_default, standalone = false,
                          title = title,
                          title_alignment = :c)
    @test result == expected

    expected = """
<table>
  <caption style = "text-align: right; ">This is a very very long title that will be displayed above the table.</caption>
  <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
    <th style = "text-align: right; ">Col. 4</th>
  </tr>
  <tr>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">1.0</td>
    <td style = "text-align: right; ">1</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">2.0</td>
    <td style = "text-align: right; ">2</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">3</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">3.0</td>
    <td style = "text-align: right; ">3</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">4.0</td>
    <td style = "text-align: right; ">4</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">false</td>
    <td style = "text-align: right; ">5.0</td>
    <td style = "text-align: right; ">5</td>
  </tr>
  <tr>
    <td style = "text-align: right; ">6</td>
    <td style = "text-align: right; ">true</td>
    <td style = "text-align: right; ">6.0</td>
    <td style = "text-align: right; ">6</td>
  </tr>
</table>
"""

    result = pretty_table(String, data, tf = html_default, standalone = false,
                          title = title,
                          title_alignment = :r)
    @test result == expected
end
