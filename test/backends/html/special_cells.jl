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
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
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

        result = pretty_table(String, matrix; backend = :html)

        @test result == expected

        result = pretty_table(String, matrix; backend = :html, renderer = :show)

        @test result == expected
    end

    @testset "HTML Cells" begin
        matrix = ["<BR>", "<p>Test<p>", html"<p>&vellip;</p>"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
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

        result = pretty_table(String, matrix; backend = :html)

        @test result == expected

        result = pretty_table(String, matrix; backend = :html, renderer = :show)

        @test result == expected
    end

    @testset "Allow HTML in Cells" begin
        matrix = ["<BR>", "<p>Test<p>", "<p>&vellip;</p>"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
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

    @testset "Allow HTML Only in the Cells" begin
        # The sections that span the entire table must always be escaped.
        result = pretty_table(
            String,
            ["<b>x</b>";;];
            allow_html_in_cells = true,
            backend             = :html,
            column_labels       = ["<em>L</em>"],
            footnotes           = [(:data, 1, 1) => "<s>F</s>"],
            row_group_labels    = [1 => "<u>G</u>"],
            source_notes        = "<a>S</a>",
            subtitle            = "<i>ST</i>",
            title               = "<i>T</i>",
        )

        @test occursin(">&lt;i&gt;T&lt;/i&gt;</td>", result)
        @test occursin(">&lt;i&gt;ST&lt;/i&gt;</td>", result)
        @test occursin(">&lt;u&gt;G&lt;/u&gt;</td>", result)
        @test occursin("<sup>1</sup> &lt;s&gt;F&lt;/s&gt;</td>", result)
        @test occursin(">&lt;a&gt;S&lt;/a&gt;</td>", result)
        @test occursin("><em>L</em></th>", result)
        @test occursin("><b>x</b><sup>1</sup></td>", result)
    end

    @testset "Line Breaks" begin
        matrix = ["First Line\nSecond Line" "Third Line\nFourth Line"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
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

        result = pretty_table(String, matrix; backend = :html)

        @test result == expected

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
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

        result = pretty_table(String, matrix; backend = :html, line_breaks = true)

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
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
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

        result = pretty_table(String, v; backend = :html)

        @test result == expected

        result = pretty_table(String, v; backend = :html, renderer = :show)

        @test result == expected
    end

    @testset "Markdown" begin
        matrix = [md"**Bold**" md"*Italic*" md"_**Bold and Italic**_"]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
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

        result = pretty_table(String, matrix; backend = :html)
        @test result == expected

        result = pretty_table(String, matrix; backend = :html, renderer = :show)
        @test result == expected
    end

    @testset "Markdown With Multiple Blocks" begin
        # The line breaks inside the code blocks are part of the content and must be kept.
        cell = md"""
            First **paragraph**.

            Second paragraph.

            ```
            x
              y
            ```
            """

        result = pretty_table(String, [cell;;]; backend = :html)

        @test occursin(
            "<td style = \"text-align: right;\"><div class=\"markdown\"><p>First <strong>paragraph</strong>.</p><p>Second paragraph.</p><pre><code>x\n  y</code></pre></div></td>",
            result,
        )
    end
end

@static if VERSION >= v"1.11"
    @testset "Views Into Styled Strings" begin
        # A view into a styled string must be rendered as a styled string, escaping the text.
        # It used to be emitted without escaping, allowing the injection of HTML code.
        s   = styled"{bold:<script>x</script>} & more"
        sub = SubString(s, 1, lastindex(s))

        result = pretty_table(String, [sub;;]; backend = :html)

        @test !occursin("<script>", result)
        @test occursin("&lt;script&gt;", result)
        @test occursin("font-weight: bold", result)
    end
end

@testset "Strings Showable as HTML With the Print Renderer" begin
    # With the renderer `:print`, a string whose type has an HTML representation must be
    # escaped, since only its plain text is rendered.
    struct HtmlShowableString <: AbstractString
        s::String
    end

    Base.iterate(x::HtmlShowableString) = iterate(x.s)
    Base.iterate(x::HtmlShowableString, i::Int) = iterate(x.s, i)
    Base.ncodeunits(x::HtmlShowableString) = ncodeunits(x.s)
    Base.codeunit(x::HtmlShowableString, i::Integer) = codeunit(x.s, i)
    Base.isvalid(x::HtmlShowableString, i::Integer) = isvalid(x.s, i)
    Base.show(io::IO, ::MIME"text/html", x::HtmlShowableString) = print(io, x.s)

    result = pretty_table(String, [HtmlShowableString("<b>x</b>");;]; backend = :html)
    @test occursin("&lt;b&gt;x&lt;/b&gt;", result)
end
