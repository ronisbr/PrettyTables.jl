# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests of alignments.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Column alignments" begin
    # Left
    # ==========================================================================

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: left;">Col. 1</th>
      <th style = "text-align: left;">Col. 2</th>
      <th style = "text-align: left;">Col. 3</th>
      <th style = "text-align: left;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: left;">1</td>
      <td style = "text-align: left;">false</td>
      <td style = "text-align: left;">1.0</td>
      <td style = "text-align: left;">1</td>
    </tr>
    <tr>
      <td style = "text-align: left;">2</td>
      <td style = "text-align: left;">true</td>
      <td style = "text-align: left;">2.0</td>
      <td style = "text-align: left;">2</td>
    </tr>
    <tr>
      <td style = "text-align: left;">3</td>
      <td style = "text-align: left;">false</td>
      <td style = "text-align: left;">3.0</td>
      <td style = "text-align: left;">3</td>
    </tr>
    <tr>
      <td style = "text-align: left;">4</td>
      <td style = "text-align: left;">true</td>
      <td style = "text-align: left;">4.0</td>
      <td style = "text-align: left;">4</td>
    </tr>
    <tr>
      <td style = "text-align: left;">5</td>
      <td style = "text-align: left;">false</td>
      <td style = "text-align: left;">5.0</td>
      <td style = "text-align: left;">5</td>
    </tr>
    <tr>
      <td style = "text-align: left;">6</td>
      <td style = "text-align: left;">true</td>
      <td style = "text-align: left;">6.0</td>
      <td style = "text-align: left;">6</td>
    </tr>
  </tbody>
</table>
"""
    result = pretty_table(
        String,
        data;
        alignment = :l,
        backend = Val(:html),
        standalone = false
    )

    @test result == expected

    # Center
    # ==========================================================================

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: center;">Col. 1</th>
      <th style = "text-align: center;">Col. 2</th>
      <th style = "text-align: center;">Col. 3</th>
      <th style = "text-align: center;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: center;">1</td>
      <td style = "text-align: center;">false</td>
      <td style = "text-align: center;">1.0</td>
      <td style = "text-align: center;">1</td>
    </tr>
    <tr>
      <td style = "text-align: center;">2</td>
      <td style = "text-align: center;">true</td>
      <td style = "text-align: center;">2.0</td>
      <td style = "text-align: center;">2</td>
    </tr>
    <tr>
      <td style = "text-align: center;">3</td>
      <td style = "text-align: center;">false</td>
      <td style = "text-align: center;">3.0</td>
      <td style = "text-align: center;">3</td>
    </tr>
    <tr>
      <td style = "text-align: center;">4</td>
      <td style = "text-align: center;">true</td>
      <td style = "text-align: center;">4.0</td>
      <td style = "text-align: center;">4</td>
    </tr>
    <tr>
      <td style = "text-align: center;">5</td>
      <td style = "text-align: center;">false</td>
      <td style = "text-align: center;">5.0</td>
      <td style = "text-align: center;">5</td>
    </tr>
    <tr>
      <td style = "text-align: center;">6</td>
      <td style = "text-align: center;">true</td>
      <td style = "text-align: center;">6.0</td>
      <td style = "text-align: center;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        alignment = :c,
        backend = Val(:html),
        standalone = false
    )

    @test result == expected

    # Per column configuration
    # ==========================================================================

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: left;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: center;">Col. 3</th>
      <th style = "text-align: right;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: left;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">1.0</td>
      <td style = "text-align: right;">1</td>
    </tr>
    <tr>
      <td style = "text-align: left;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: left;">3</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">3.0</td>
      <td style = "text-align: right;">3</td>
    </tr>
    <tr>
      <td style = "text-align: left;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">4.0</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr>
      <td style = "text-align: left;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: left;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">6.0</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
</table>
"""
    result = pretty_table(
        String,
        data;
        alignment = [:l, :r, :c, :r],
        backend = Val(:html),
        standalone = false
    )

    @test result == expected
end

@testset "Cell alignment override" begin
    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: left;">Col. 1</th>
      <th style = "text-align: right;">Col. 2</th>
      <th style = "text-align: center;">Col. 3</th>
      <th style = "text-align: right;">Col. 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: left;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">1.0</td>
      <td style = "text-align: left;">1</td>
    </tr>
    <tr>
      <td style = "text-align: left;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: left;">false</td>
      <td style = "text-align: center;">3.0</td>
      <td style = "text-align: center;">3</td>
    </tr>
    <tr>
      <td style = "text-align: left;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">4.0</td>
      <td style = "text-align: center;">4</td>
    </tr>
    <tr>
      <td style = "text-align: left;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: left;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">6.0</td>
      <td style = "text-align: left;">6</td>
    </tr>
  </tbody>
</table>
"""
    result = pretty_table(
        String,
        data;
        alignment = [:l, :r, :c, :r],
        backend = Val(:html),
        cell_alignment = Dict(
            (3,1) => :r,
            (3,2) => :l,
            (1,4) => :l,
            (3,4) => :c,
            (4,4) => :c,
            (6,4) => :l
        ),
        standalone = false
    )

    @test result == expected
end

@testset "Header alignment" begin
    header = (["A", "B", "C", "D"],
              ["a", "b", "c", "d"])

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: left;">A</th>
      <th style = "text-align: center;">B</th>
      <th style = "text-align: right;">C</th>
      <th style = "text-align: right;">D</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: left;">a</th>
      <th style = "text-align: center;">b</th>
      <th style = "text-align: right;">c</th>
      <th style = "text-align: right;">d</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: left;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">1.0</td>
      <td style = "text-align: left;">1</td>
    </tr>
    <tr>
      <td style = "text-align: left;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: left;">false</td>
      <td style = "text-align: center;">3.0</td>
      <td style = "text-align: center;">3</td>
    </tr>
    <tr>
      <td style = "text-align: left;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">4.0</td>
      <td style = "text-align: center;">4</td>
    </tr>
    <tr>
      <td style = "text-align: left;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: left;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">6.0</td>
      <td style = "text-align: left;">6</td>
    </tr>
  </tbody>
</table>
"""
    result = pretty_table(
        String,
        data;
        header = header,
        alignment = [:l, :r, :c, :r],
        backend = Val(:html),
        cell_alignment = Dict( (3,1) => :r,
            (3,2) => :l,
            (1,4) => :l,
            (3,4) => :c,
            (4,4) => :c,
            (6,4) => :l
        ),
        header_alignment = [:l, :c, :r, :r],
        standalone = false
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">A</th>
      <th style = "text-align: center;">B</th>
      <th style = "text-align: right;">C</th>
      <th style = "text-align: right;">D</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: left;">a</th>
      <th style = "text-align: left;">b</th>
      <th style = "text-align: right;">c</th>
      <th style = "text-align: center;">d</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: left;">1</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">1.0</td>
      <td style = "text-align: left;">1</td>
    </tr>
    <tr>
      <td style = "text-align: left;">2</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">2.0</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: left;">false</td>
      <td style = "text-align: center;">3.0</td>
      <td style = "text-align: center;">3</td>
    </tr>
    <tr>
      <td style = "text-align: left;">4</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">4.0</td>
      <td style = "text-align: center;">4</td>
    </tr>
    <tr>
      <td style = "text-align: left;">5</td>
      <td style = "text-align: right;">false</td>
      <td style = "text-align: center;">5.0</td>
      <td style = "text-align: right;">5</td>
    </tr>
    <tr>
      <td style = "text-align: left;">6</td>
      <td style = "text-align: right;">true</td>
      <td style = "text-align: center;">6.0</td>
      <td style = "text-align: left;">6</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        data;
        header = header,
        alignment = [:l, :r, :c, :r],
        backend = Val(:html),
        cell_alignment = Dict(
            (3,1) => :r,
            (3,2) => :l,
            (1,4) => :l,
            (3,4) => :c,
            (4,4) => :c,
            (6,4) => :l
        ),
        header_alignment = [:l, :c, :r, :r],
        header_cell_alignment = Dict(
            (1,1) => :r,
            (2,2) => :l,
            (2,4) => :c
        ),
        standalone = false
    )

    @test result == expected
end
