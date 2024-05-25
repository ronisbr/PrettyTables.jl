## Description #############################################################################
#
# Tests related with cropping.
#
############################################################################################

@testset "Cropping" begin
    # == Bottom Cropping (Default) =========================================================

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
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
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
        backend = Val(:html),
        header  = header,
        max_num_of_rows = 3,
        max_num_of_columns = 3
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
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        max_num_of_rows = 3
    )
    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(4, 1)</td>
      <td style = "text-align: right;">(4, 2)</td>
      <td style = "text-align: right;">(4, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(5, 1)</td>
      <td style = "text-align: right;">(5, 2)</td>
      <td style = "text-align: right;">(5, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(6, 1)</td>
      <td style = "text-align: right;">(6, 2)</td>
      <td style = "text-align: right;">(6, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(7, 1)</td>
      <td style = "text-align: right;">(7, 2)</td>
      <td style = "text-align: right;">(7, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        max_num_of_columns = 3
    )
    @test result == expected

    # == Middle Cropping ===================================================================

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(7, 1)</td>
      <td style = "text-align: right;">(7, 2)</td>
      <td style = "text-align: right;">(7, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        max_num_of_rows = 3,
        max_num_of_columns = 3,
        vcrop_mode = :middle
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(7, 1)</td>
      <td style = "text-align: right;">(7, 2)</td>
      <td style = "text-align: right;">(7, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        max_num_of_rows = 2,
        max_num_of_columns = 3,
        vcrop_mode = :middle
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
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(7, 1)</td>
      <td style = "text-align: right;">(7, 2)</td>
      <td style = "text-align: right;">(7, 3)</td>
      <td style = "text-align: right;">(7, 4)</td>
      <td style = "text-align: right;">(7, 5)</td>
      <td style = "text-align: right;">(7, 6)</td>
      <td style = "text-align: right;">(7, 7)</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        max_num_of_rows = 3,
        vcrop_mode = :middle
    )

    @test result == expected
end

@testset "Omitted Cell Summary" begin
    matrix = [(i, j) for i in 1:7, j in 1:7]
    header = (
        ["Column $i" for i in 1:7],
        ["C$i" for i in 1:7]
    )

    expected = """
<div>
  <div style = "float: right;">
    <span>4 columns and 4 rows omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
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
        backend = Val(:html),
        header  = header,
        max_num_of_rows = 3,
        max_num_of_columns = 3,
        show_omitted_cell_summary = true
    )
    @test result == expected

    expected = """
<div>
  <div style = "float: right;">
    <span>4 columns and 4 rows omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">Column 1</th>
      <th style = "text-align: right;">Column 2</th>
      <th style = "text-align: right;">Column 3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">C1</th>
      <th style = "text-align: right;">C2</th>
      <th style = "text-align: right;">C3</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">(7, 1)</td>
      <td style = "text-align: right;">(7, 2)</td>
      <td style = "text-align: right;">(7, 3)</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        header  = header,
        max_num_of_rows = 3,
        max_num_of_columns = 3,
        show_omitted_cell_summary = true,
        vcrop_mode = :middle
    )
    @test result == expected
end

@testset "Formatters after Middle Cropping" begin
    matrix = OffsetArray(
        vcat(ones(10, 11), fill(missing, 1, 11)),
        -5:5, -5:5
    )

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. -5</th>
      <th style = "text-align: right;">Col. -4</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">M</td>
      <td style = "text-align: right;">M</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        formatters = ((v, i, j) -> i == 5 ? "M" : v),
        max_num_of_rows = 2,
        max_num_of_columns = 2,
        vcrop_mode = :middle
    )

    @test result == expected
end

@testset "Highlighters after Middle Cropping" begin
    matrix = OffsetArray(
        vcat(ones(10, 11), fill(missing, 1, 11)),
        -5:5, -5:5
    )

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. -5</th>
      <th style = "text-align: right;">Col. -4</th>
      <th style = "text-align: right;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr>
      <td style = "font-style: italic; text-align: right;">missing</td>
      <td style = "font-style: italic; text-align: right;">missing</td>
      <td style = "text-align: right;">&ctdot;</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:html),
        highlighters = HtmlHighlighter(
            (data, i, j) -> data[i, j] === missing,
            HtmlDecoration(font_style = "italic"),
        ),
        max_num_of_rows = 2,
        max_num_of_columns = 2,
        vcrop_mode = :middle
    )

    @test result == expected
end
