## Description #############################################################################
#
# HTML Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
    @testset "HTML Code Espaping" begin
        matrix = ["<BR>", "<p>Test<p>", "<p>&vellip;</p>"]

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">&lt;BR&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">&lt;p&gt;Test&lt;p&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; text-align: right;">&lt;p&gt;&amp;vellip;&lt;/p&gt;</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html)

        @test result == expected

        result = pretty_table(String, matrix; backend = :html, renderer = :show)

        @test result == expected
    end

    @testset "HTML Cells" begin
        matrix = ["<BR>", "<p>Test<p>", html"<p>&vellip;</p>"]

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">&lt;BR&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">&lt;p&gt;Test&lt;p&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; text-align: right;"><p>&vellip;</p></td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html)

        @test result == expected

        result = pretty_table(String, matrix; backend = :html, renderer = :show)

        @test result == expected
    end

    @testset "Allow HTML in Cells" begin
        matrix = ["<BR>", "<p>Test<p>", "<p>&vellip;</p>"]

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;"><BR></td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;"><p>Test<p></td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; text-align: right;"><p>&vellip;</p></td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html, allow_html_in_cells = true)

        @test result == expected

        result = pretty_table(
            String, matrix; backend = :html, allow_html_in_cells = true, renderer = :show
        )

        @test result == expected
    end

    @testset "Allow HTML in Cells With Line Breaks" begin
        # The line breaks must be kept in raw HTML cells. Otherwise, we would corrupt the
        # HTML code with a literal `\\n`.
        matrix = ["<div>\na\n</div>";;]

        result = pretty_table(String, matrix; backend = :html, allow_html_in_cells = true)

        @test !occursin("\\n", result)
        @test occursin("<div>", result)
    end

    @testset "Line Breaks" begin
        matrix = ["First Line\nSecond Line" "Third Line\nFourth Line"]

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">First Line\\nSecond Line</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">Third Line\\nFourth Line</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html)

        @test result == expected

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">First Line<br>Second Line</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">Third Line<br>Fourth Line</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html, line_breaks = true)

        @test result == expected
    end

    @testset "Undefined Cells" begin
        v    = Vector{Any}(undef, 5)
        v[1] = undef
        v[2] = "String"
        v[5] = π

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">UndefInitializer()</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">String</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">#undef</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 2px solid black; text-align: right;">#undef</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; text-align: right;">π</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, v; backend = :html)

        @test result == expected

        result = pretty_table(String, v; backend = :html, renderer = :show)

        @test result == expected
    end

    @testset "Markdown" begin
        matrix = [md"**Bold**" md"*Italic*" md"_**Bold and Italic**_"]

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;"><div class="markdown"><p><strong>Bold</strong></p></div></td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;"><div class="markdown"><p><em>Italic</em></p></div></td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;"><div class="markdown"><p><em><strong>Bold and Italic</strong></em></p></div></td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html)
        @test result == expected

        result = pretty_table(String, matrix; backend = :html, renderer = :show)
        @test result == expected
    end
end
