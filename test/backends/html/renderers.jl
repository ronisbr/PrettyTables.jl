## Description #############################################################################
#
# HTML Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    matrix = ['a' :a "a" missing nothing]

    @testset ":print" begin
        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "font-weight: bold; text-align: right;">Col. 4</th>
      <th style = "font-weight: bold; text-align: right;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
  </tbody>
</table>
"""
        result = pretty_table(String, matrix; backend = :html)

        @test result == expected
    end

    @testset ":show" begin
        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
      <th style = "font-weight: bold; text-align: right;">Col. 3</th>
      <th style = "font-weight: bold; text-align: right;">Col. 4</th>
      <th style = "font-weight: bold; text-align: right;">Col. 5</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">&apos;a&apos;</td>
      <td style = "text-align: right;">:a</td>
      <td style = "text-align: right;">a</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">nothing</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(String, matrix; backend = :html, renderer = :show)

        @test result == expected
    end
end

@testset "MIME Representation With the Show Renderer" begin
    # With the renderer `:show`, the HTML representation of a cell must be emitted without
    # escaping, whereas the text representation must be escaped.
    struct RendererMimeCellHtml end
    Base.show(io::IO, ::MIME"text/html", ::RendererMimeCellHtml) = print(io, "<b>foo</b>")
    Base.show(io::IO, ::RendererMimeCellHtml) = print(io, "FooCell")

    result = pretty_table(
        String, [RendererMimeCellHtml();;]; backend = :html, renderer = :show
    )
    @test occursin("<b>foo</b>", result)

    result = pretty_table(
        String, [RendererMimeCellHtml();;]; backend = :html, renderer = :print
    )
    @test occursin("FooCell", result)
end
