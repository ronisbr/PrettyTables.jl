## Description #############################################################################
#
# Tests of default printing.
#
############################################################################################

@testset "Default" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: right;">Col. 3</th>
      <th style = "text-align: right;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(String, data, backend = Val(:html))
    @test result == expected

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<head>
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
</head>
<body>
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: right;">Col. 3</th>
      <th style = "text-align: right;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
</body>
</html>
"""

    result = pretty_table(String, data, backend = Val(:html), standalone = true)
    @test result == expected
end

@testset "Dictionaries" begin
    dict = Dict{Int64,String}(1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr",
                              5 => "May", 6 => "Jun")

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Keys</th>
      <th style = "text-align: right;">Values</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">String</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">Jan</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">Feb</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">Mar</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">Apr</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">May</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">Jun</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        dict;
        backend = Val(:html),
        sortkeys = true,
        standalone = false
    )

    @test result == expected
end

@testset "Vectors" begin

    vec = 0:1:5

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(String, vec, backend = Val(:html), standalone = false)
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th class = "rowNumber" style = "font-weight: bold; text-align: right;">Row</th>
      <th style = "text-align: center;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">1</td>
      <td style = "text-align: center;">0</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">2</td>
      <td style = "text-align: center;">1</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">3</td>
      <td style = "text-align: center;">2</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">4</td>
      <td style = "text-align: center;">3</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">5</td>
      <td style = "text-align: center;">4</td>
    </tr>
    <tr>
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">6</td>
      <td style = "text-align: center;">5</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        vec;
        alignment = :c,
        backend = Val(:html),
        show_row_number = true,
        standalone = false
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">A</th>
    </tr>
    <tr class = "subheader">
      <th style = "text-align: right;">B</th>
    </tr>
    <tr class = "subheader">
      <th style = "text-align: right;">C</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">D</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        vec;
        backend = Val(:html),
        header = (["A"], ["B"], ["C"], ["D"]),
        standalone = false
    )

    @test result == expected
end

@testset "Print missing, nothing, and #undef" begin

    matrix = Matrix{Any}(undef,3,3)
    matrix[1,1:2] .= missing
    matrix[2,1:2] .= nothing
    matrix[3,1]   = missing
    matrix[3,2]   = nothing

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: right;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr>
      <td style = "text-align: right;">nothing</td>
      <td style = "text-align: right;">nothing</td>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">nothing</td>
      <td style = "text-align: right;">#undef</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        tf = tf_html_default,
        standalone = false
    )

    @test result == expected
end

@testset "HTML Escaping" begin
    header = [
        "<span style = \"color: blue;\">1</span>",
        "<span style = \"color: blue;\">2</span>"
    ]

    matrix = [
        1 "<b>Bold</b>"
        2 "<em>Italics</em>"
        3 "<p class=\"myClass\">Paragraph</p>"
    ]

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">&lt;span style = &quot;color: blue;&quot;&gt;1&lt;/span&gt;</th>
      <th style = "text-align: right;">&lt;span style = &quot;color: blue;&quot;&gt;2&lt;/span&gt;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">&lt;b&gt;Bold&lt;/b&gt;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">&lt;em&gt;Italics&lt;/em&gt;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">&lt;p class=&quot;myClass&quot;&gt;Paragraph&lt;/p&gt;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header = header,
        standalone = false
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;"><span style = "color: blue;">1</span></th>
      <th style = "text-align: right;"><span style = "color: blue;">2</span></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;"><b>Bold</b></td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;"><em>Italics</em></td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;"><p class="myClass">Paragraph</p></td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        allow_html_in_cells = true,
        backend = Val(:html),
        header = header,
        standalone = false
    )

    @test result == expected

    header = [
        html_cell"<span style = \"color: blue;\">1</span>",
        "<span style = \"color: blue;\">2</span>"
    ]

    matrix = [
        1 html_cell"<b>Bold</b>"
        2 html_cell"<em>Italics</em>"
        3 "<p class=\"myClass\">Paragraph</p>"
    ]

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;"><span style = "color: blue;">1</span></th>
      <th style = "text-align: right;">&lt;span style = &quot;color: blue;&quot;&gt;2&lt;/span&gt;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;"><b>Bold</b></td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;"><em>Italics</em></td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">&lt;p class=&quot;myClass&quot;&gt;Paragraph&lt;/p&gt;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header = header,
        standalone = false
    )
end

@testset "Table Class" begin
    expected = """
<table class = "tableClass">
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data[1:2, 1:2];
        backend = Val(:html),
        table_class = "tableClass",
    )
    @test result == expected

expected = """
<div class = "tableDivClass" style = "overflow-x: scroll;">
  <table class = "tableClass">
    <thead>
      <tr class = "header headerLastRow">
        <th style = "text-align: right;">Col. 1</th>
        <th style = "text-align: right;">Col. 2</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td style = "text-align: right;">1</td>
        <td style = "text-align: right;">false</td>
      </tr>
      <tr>
        <td style = "text-align: right;">2</td>
        <td style = "text-align: right;">true</td>
      </tr>
    </tbody>
  </table>
</div>
"""

    result = pretty_table(
        String,
        data[1:2, 1:2];
        backend = Val(:html),
        table_class = "tableClass",
        wrap_table_in_div = true,
        table_div_class = "tableDivClass"
    )
    @test result == expected
end

@testset "Table Style" begin

    expected = """
<div class = "tableDivClass" style = "overflow-x: scroll;">
  <table class = "tableClass" style = "margin-bottom: 10px; margin-top: 10px;">
    <thead>
      <tr class = "header headerLastRow">
        <th style = "text-align: right;">Col. 1</th>
        <th style = "text-align: right;">Col. 2</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td style = "text-align: right;">1</td>
        <td style = "text-align: right;">false</td>
      </tr>
      <tr>
        <td style = "text-align: right;">2</td>
        <td style = "text-align: right;">true</td>
      </tr>
    </tbody>
  </table>
</div>
"""

    result = pretty_table(
        String,
        data[1:2, 1:2];
        backend = Val(:html),
        table_style = Dict("margin-bottom" => "10px", "margin-top" => "10px"),
        table_class = "tableClass",
        table_div_class = "tableDivClass",
        wrap_table_in_div = true,
    )
    @test result == expected
end
