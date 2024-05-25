## Description #############################################################################
#
# Tests of highlighters.
#
############################################################################################

@testset "Highlighters" begin
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
      <td style = "color: red; text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "color: red; text-align: right;">5.0</td>
      <td style = "color: red; text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "color: red; text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "color: red; text-align: right;">6.0</td>
      <td style = "color: red; text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = HtmlHighlighter(
            (data, i, j) -> data[i, j] > 4,
            HtmlDecoration(color = "red")
        ),
        standalone = true
    )
end

@testset "Pre-defined highlighters" begin
    # == hl_cell ===========================================================================

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
      <td style = "background: blue; text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "background: blue; text-align: right;">3.0</td>
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

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = (
            hl_cell(2, 2, HtmlDecoration(background = "blue")),
            hl_cell(3, 3, HtmlDecoration(background = "blue"))
        ),
        standalone = false
    )

    @test result == expected

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = hl_cell(
            [(2, 2), (3, 3)],
            HtmlDecoration(background = "blue")
        ),
        standalone = false
    )

    # == hl_col ============================================================================

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
      <td style = "font-weight: bold; text-align: right;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "font-weight: bold; text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "font-weight: bold; text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "font-weight: bold; text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "font-weight: bold; text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "font-weight: bold; text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "font-weight: bold; text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "font-weight: bold; text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "font-weight: bold; text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "font-weight: bold; text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "font-weight: bold; text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "font-weight: bold; text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = (
            hl_col(1, HtmlDecoration(font_weight = "bold")),
            hl_col(4, HtmlDecoration(font_weight = "bold"))
        ),
        standalone = false
    )

    @test result == expected

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = hl_col([1, 4], HtmlDecoration(font_weight = "bold")),
        standalone = false
    )

    @test result == expected

    # == hl_row ============================================================================

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
      <td style = "font-family: monospace; text-align: right;">1</td>
      <td style = "font-family: monospace; text-align: right;">false</td>
      <td style = "font-family: monospace; text-align: right;">1.0</td>
      <td style = "font-family: monospace; text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "font-family: monospace; text-align: right;">3</td>
      <td style = "font-family: monospace; text-align: right;">false</td>
      <td style = "font-family: monospace; text-align: right;">3.0</td>
      <td style = "font-family: monospace; text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "font-family: monospace; text-align: right;">5</td>
      <td style = "font-family: monospace; text-align: right;">false</td>
      <td style = "font-family: monospace; text-align: right;">5.0</td>
      <td style = "font-family: monospace; text-align: right;">5</td>
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

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = (
            hl_row(1, HtmlDecoration(font_family = "monospace")),
            hl_row(3, HtmlDecoration(font_family = "monospace")),
            hl_row(5, HtmlDecoration(font_family = "monospace"))
        ),
        standalone = false
    )

    @test result == expected

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = hl_row(
            [1, 3, 5],
            HtmlDecoration(font_family = "monospace")
        ),
        standalone = false
    )

    @test result == expected

    # == hl_lt =============================================================================

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
      <td style = "background: black; color: white; text-align: right;">1</td>
      <td style = "background: black; color: white; text-align: right;">false</td>
      <td style = "background: black; color: white; text-align: right;">1.0</td>
      <td style = "background: black; color: white; text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">2</td>
      <td style = "background: black; color: white; text-align: right;">true</td>
      <td style = "background: black; color: white; text-align: right;">2.0</td>
      <td style = "background: black; color: white; text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "background: black; color: white; text-align: right;">false</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "background: black; color: white; text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "background: black; color: white; text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "background: black; color: white; text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = hl_lt(
            3,
            HtmlDecoration(color = "white",
            background = "black")
        ),
        standalone = false
    )

    @test result == expected

    # == hl_leq ============================================================================

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
      <td style = "background: black; color: white; text-align: right;">1</td>
      <td style = "background: black; color: white; text-align: right;">false</td>
      <td style = "background: black; color: white; text-align: right;">1.0</td>
      <td style = "background: black; color: white; text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">2</td>
      <td style = "background: black; color: white; text-align: right;">true</td>
      <td style = "background: black; color: white; text-align: right;">2.0</td>
      <td style = "background: black; color: white; text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">3</td>
      <td style = "background: black; color: white; text-align: right;">false</td>
      <td style = "background: black; color: white; text-align: right;">3.0</td>
      <td style = "background: black; color: white; text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: right;">4</td>
      <td style = "background: black; color: white; text-align: right;">true</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: right;">5</td>
      <td style = "background: black; color: white; text-align: right;">false</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">6</td>
      <td style = "background: black; color: white; text-align: right;">true</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = hl_leq(
            3,
            HtmlDecoration(color = "white",
            background = "black")
        ),
        standalone = false
    )

    @test result == expected

    # == hl_gt =============================================================================

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
      <td style = "background: black; color: white; text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "background: black; color: white; text-align: right;">4.0</td>
      <td style = "background: black; color: white; text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "background: black; color: white; text-align: right;">5.0</td>
      <td style = "background: black; color: white; text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "background: black; color: white; text-align: right;">6.0</td>
      <td style = "background: black; color: white; text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = hl_gt(
            3,
            HtmlDecoration(color = "white",
            background = "black")
        ),
        standalone = false
    )

    @test result == expected

    # == hl_geq ============================================================================

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
      <td style = "background: black; color: white; text-align: right;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "background: black; color: white; text-align: right;">3.0</td>
      <td style = "background: black; color: white; text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "background: black; color: white; text-align: right;">4.0</td>
      <td style = "background: black; color: white; text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "background: black; color: white; text-align: right;">5.0</td>
      <td style = "background: black; color: white; text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "background: black; color: white; text-align: right;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "background: black; color: white; text-align: right;">6.0</td>
      <td style = "background: black; color: white; text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        highlighters = hl_geq(
            3,
            HtmlDecoration(color = "white",
            background = "black")
        ),
        standalone = false
    )

    @test result == expected

    # == hl_value ==========================================================================

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
      <td style = "text-align: right; text-decoration: line-through;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: right; text-decoration: line-through;">3.0</td>
      <td style = "text-align: right; text-decoration: line-through;">3</td>
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

    result = pretty_table(
        String, data;
        backend = Val(:html),
        highlighters = hl_value(
            3,
            HtmlDecoration(text_decoration = "line-through")
        ),
        standalone = false
    )

    @test result == expected
end
