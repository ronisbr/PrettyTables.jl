## Description #############################################################################
#
# Test PrettyTable structure.
#
############################################################################################

@testset "Construction and Printing" begin
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    pt = PrettyTable(matrix; backend = :text)

    expected = """
┌────────┬────────┬────────┬────────┬────────┬─────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │  Col. 6 │
├────────┼────────┼────────┼────────┼────────┼─────────┤
│      1 │    1.0 │      1 │      a │    abc │ missing │
│      2 │    2.0 │      2 │      b │    def │ nothing │
│      3 │    3.0 │      3 │      c │    ghi │  symbol │
└────────┴────────┴────────┴────────┴────────┴─────────┘
"""

    result = pretty_table(String, pt)

    @test result == expected

    pt = PrettyTable(matrix)
    pt.column_labels = ["#1", "#2", "#3", "#4", "#5", "#6"]

    expected = """
┌────┬─────┬────┬────┬─────┬─────────┐
│ #1 │  #2 │ #3 │ #4 │  #5 │      #6 │
├────┼─────┼────┼────┼─────┼─────────┤
│  1 │ 1.0 │  1 │  a │ abc │ missing │
│  2 │ 2.0 │  2 │  b │ def │ nothing │
│  3 │ 3.0 │  3 │  c │ ghi │  symbol │
└────┴─────┴────┴────┴─────┴─────────┘
"""

    result = pretty_table(String, pt)

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">#1</th>
      <th style = "font-weight: bold; text-align: right;">#2</th>
      <th style = "font-weight: bold; text-align: right;">#3</th>
      <th style = "font-weight: bold; text-align: right;">#4</th>
      <th style = "font-weight: bold; text-align: right;">#5</th>
      <th style = "font-weight: bold; text-align: right;">#6</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">abc</td>
      <td style = "text-align: right;">missing</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">b</td>
      <td style = "text-align: right;">def</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">c</td>
      <td style = "text-align: right;">ghi</td>
      <td style = "text-align: right;">symbol</td>
    </tr>
  </tbody>
</table>
"""

    pt.backend = :html

    result = pretty_table(String, pt)
    @test result == expected

    pt = PrettyTable(matrix)
    pt.column_labels = ["#1", "#2", "#3", "#4", "#5", "#6"]
    result = pretty_table(HTML, pt)

    @test result isa HTML
    @test result.content == expected
end

@testset "Parameter Overload when Printing" begin
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    pt = PrettyTable(matrix; backend = :text)

    expected = """
┌────┬─────┬────┬────┬─────┬─────────┐
│ #1 │  #2 │ #3 │ #4 │  #5 │      #6 │
├────┼─────┼────┼────┼─────┼─────────┤
│  1 │ 1.0 │  1 │  a │ abc │ missing │
│  2 │ 2.0 │  2 │  b │ def │ nothing │
│  3 │ 3.0 │  3 │  c │ ghi │  symbol │
└────┴─────┴────┴────┴─────┴─────────┘
"""

    result = pretty_table(String, pt; column_labels = ["#1", "#2", "#3", "#4", "#5", "#6"])

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">#1</th>
      <th style = "font-weight: bold; text-align: right;">#2</th>
      <th style = "font-weight: bold; text-align: right;">#3</th>
      <th style = "font-weight: bold; text-align: right;">#4</th>
      <th style = "font-weight: bold; text-align: right;">#5</th>
      <th style = "font-weight: bold; text-align: right;">#6</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">abc</td>
      <td style = "text-align: right;">missing</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">b</td>
      <td style = "text-align: right;">def</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">c</td>
      <td style = "text-align: right;">ghi</td>
      <td style = "text-align: right;">symbol</td>
    </tr>
  </tbody>
</table>
"""

    pt.backend = :html

    result = pretty_table(String, pt; column_labels = ["#1", "#2", "#3", "#4", "#5", "#6"])
    @test result == expected

    result = pretty_table(HTML, pt; column_labels = ["#1", "#2", "#3", "#4", "#5", "#6"])

    @test result isa HTML
    @test result.content == expected
end

@testset "Show" begin
    io = IOBuffer()

    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    pt = PrettyTable(
        matrix; backend = :text, column_labels = ["#1", "#2", "#3", "#4", "#5", "#6"]
    )

    expected = """
┌────┬─────┬────┬────┬─────┬─────────┐
│ #1 │  #2 │ #3 │ #4 │  #5 │      #6 │
├────┼─────┼────┼────┼─────┼─────────┤
│  1 │ 1.0 │  1 │  a │ abc │ missing │
│  2 │ 2.0 │  2 │  b │ def │ nothing │
│  3 │ 3.0 │  3 │  c │ ghi │  symbol │
└────┴─────┴────┴────┴─────┴─────────┘"""

    show(io, pt)

    result = String(take!(io))

    @test result == expected
end

@testset "Reserved Display Lines in show" begin
    # `show` must reserve one line in addition to the lines reserved by the user.
    pt = PrettyTable(
        reshape(1:40, 20, 2);
        reserved_display_lines = 5,
        fit_table_in_display_vertically = true,
    )

    io = IOContext(IOBuffer(), :displaysize => (20, 80), :limit => true)
    show(io, pt)
    lines_show = count(==('\n'), String(take!(io.io)))

    io = IOContext(IOBuffer(), :displaysize => (20, 80), :limit => true)
    pretty_table(io, pt; new_line_at_end = false, reserved_display_lines = 6)
    lines_expected = count(==('\n'), String(take!(io.io)))

    @test lines_show == lines_expected
end
