## Description #############################################################################
#
# HTML Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
    @testset "HTML Code Espaping" begin
        matrix = ["<BR>", "<p>Test<p>", "<p>&vellip;</p>"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">&lt;BR&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">&lt;p&gt;Test&lt;p&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">&lt;p&gt;&amp;vellip;&lt;/p&gt;</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html
        )

        @test result == expected

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            renderer = :show
        )

        @test result == expected
    end

    @testset "HTML Cells" begin
        matrix = ["<BR>", "<p>Test<p>", html"<p>&vellip;</p>"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">&lt;BR&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">&lt;p&gt;Test&lt;p&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;"><p>&vellip;</p></td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html
        )

        @test result == expected

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            renderer = :show
        )

        @test result == expected
    end

    @testset "Allow HTML in Cells" begin
        matrix = ["<BR>", "<p>Test<p>", "<p>&vellip;</p>"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;"><BR></td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;"><p>Test<p></td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;"><p>&vellip;</p></td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            allow_html_in_cells = true
        )

        @test result == expected

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            allow_html_in_cells = true,
            renderer = :show
        )

        @test result == expected
    end

    @testset "Line Breaks" begin
        matrix = ["First Line\nSecond Line" "Third Line\nFourth Line"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">First Line\\nSecond Line</td>
      <td style = "text-align: right;">Third Line\\nFourth Line</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html
        )

        @test result == expected

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">First Line<br>Second Line</td>
      <td style = "text-align: right;">Third Line<br>Fourth Line</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            line_breaks = true
        )

        @test result == expected
    end

    @testset "Undefined Cells" begin
        v    = Vector{Any}(undef, 5)
        v[1] = undef
        v[2] = "String"
        v[5] = π

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">UndefInitializer()</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">String</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">π</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            v;
            backend = :html
        )

        @test result == expected

        result = pretty_table(
            String,
            v;
            backend = :html,
            renderer = :show
        )

        @test result == expected
    end

    @testset "Markdown" begin
        matrix = [md"**Bold**" md"*Italic*" md"_**Bold and Italic**_"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th style = "text-align: right; font-weight: bold;">Col. 2</th>
      <th style = "text-align: right; font-weight: bold;">Col. 3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;"><div class="markdown"><p><strong>Bold</strong></p></div></td>
      <td style = "text-align: right;"><div class="markdown"><p><em>Italic</em></p></div></td>
      <td style = "text-align: right;"><div class="markdown"><p><em><strong>Bold and Italic</strong></em></p></div></td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html
        )
        @test result == expected

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            renderer = :show
        )
        @test result == expected
    end
end
