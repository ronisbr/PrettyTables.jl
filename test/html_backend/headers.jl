## Description #############################################################################
#
# Tests of headers and sub-headers.
#
############################################################################################

@testset "Headers and Sub-headers" begin
    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">1</th>
      <th style = "text-align: right;">2</th>
      <th style = "text-align: right;">3</th>
      <th style = "text-align: right;">4</th>
    </tr>
    <tr class = "subheader">
      <th style = "text-align: right;">A</th>
      <th style = "text-align: right;">B</th>
      <th style = "text-align: right;">C</th>
      <th style = "text-align: right;">D</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">E</th>
      <th style = "text-align: right;">F</th>
      <th style = "text-align: right;">G</th>
      <th style = "text-align: right;">H</th>
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

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        header = (
            ["1", "2", "3", "4"],
            [:A,  :B,  :C,  :D],
            [:E,  :F,  :G,  :H]
        ),
        standalone = false
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">1</th>
      <th style = "text-align: right;">2</th>
      <th style = "text-align: right;">3</th>
      <th style = "text-align: right;">4</th>
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

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        header = (
            ["1", "2", "3", "4"],
            [:A,  :B,  :C,  :D],
            [:E,  :F,  :G,  :H]
        ),
        show_subheader = false,
        standalone = false
    )

    @test result == expected

    expected = """
<table>
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

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        header = (
            ["1", "2", "3", "4"],
            [:A,  :B,  :C,  :D],
            [:E,  :F,  :G,  :H]
        ),
        show_header = false,
        standalone = false
    )

    @test result == expected
end

@testset "Header Cell Titles" begin
    expected = """
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">1</th>
      <th style = "text-align: right;">2</th>
      <th style = "text-align: right;">3</th>
      <th style = "text-align: right;">4</th>
    </tr>
    <tr class = "subheader">
      <th title = "T1" style = "text-align: right;">A</th>
      <th title = "T2" style = "text-align: right;">B</th>
      <th title = "T3" style = "text-align: right;">C</th>
      <th title = "T4" style = "text-align: right;">D</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">E</th>
      <th style = "text-align: right;">F</th>
      <th style = "text-align: right;">G</th>
      <th style = "text-align: right;">H</th>
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

    result = pretty_table(
        String,
        data;
        backend = Val(:html),
        header = (
            ["1", "2", "3", "4"],
            [:A,  :B,  :C,  :D],
            [:E,  :F,  :G,  :H]
        ),
        header_cell_titles = (
            nothing,
            ["T1", "T2", "T3", "T4"],
            nothing
        ),
        standalone = false
    )
end

