## Description #############################################################################
#
# Typst Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
    backend = :typst

    @testset "Escaping of Typst Metacharacters" begin
        # Every character here carries a special meaning in Typst markup. Since the cell
        # content is emitted inside a content block (`[...]`), leaving any of them unescaped
        # either breaks the block or changes how the document is typeset.
        matrix = ["]" "[" "*" "_" "\$" "\\" "`" "@" "<" ">" "~" "#"]

        expected = """
#{
  table(
    align: (right, right, right, right, right, right, right, right, right, right, right, right,),
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 2, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 2, stroke: 1.5pt),
    table.vline(x: 1, end: 2, stroke: 0.8pt),
    table.vline(x: 2, end: 2, stroke: 0.8pt),
    table.vline(x: 3, end: 2, stroke: 0.8pt),
    table.vline(x: 4, end: 2, stroke: 0.8pt),
    table.vline(x: 5, end: 2, stroke: 0.8pt),
    table.vline(x: 6, end: 2, stroke: 0.8pt),
    table.vline(x: 7, end: 2, stroke: 0.8pt),
    table.vline(x: 8, end: 2, stroke: 0.8pt),
    table.vline(x: 9, end: 2, stroke: 0.8pt),
    table.vline(x: 10, end: 2, stroke: 0.8pt),
    table.vline(x: 11, end: 2, stroke: 0.8pt),
    table.vline(x: 12, end: 2, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
      [#text(weight: "bold",)[Col. 4]],
      [#text(weight: "bold",)[Col. 5]],
      [#text(weight: "bold",)[Col. 6]],
      [#text(weight: "bold",)[Col. 7]],
      [#text(weight: "bold",)[Col. 8]],
      [#text(weight: "bold",)[Col. 9]],
      [#text(weight: "bold",)[Col. 10]],
      [#text(weight: "bold",)[Col. 11]],
      [#text(weight: "bold",)[Col. 12]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [\\]],
    [\\[],
    [\\*],
    [\\_],
    [\\\$],
    [\\\\],
    [\\`],
    [\\@],
    [\\<],
    [\\>],
    [\\~],
    [\\#],
  )
}
"""

        result = pretty_table(String, matrix; backend)

        @test result == expected
    end

    @testset "Escaped Metacharacters Inside a Cell" begin
        # An unescaped `]` closes the content block early, whereas an unescaped `[` opens a
        # block that is never closed. Both silently corrupt the whole document.
        result = pretty_table(String, ["a]b" "c[d"]; backend)

        @test occursin("[a\\]b],", result)
        @test occursin("[c\\[d],", result)
    end
end

@testset "Non-Printable Characters" begin
    # Typst has no `\xNN` escape sequence, and its Unicode escape requires braces. Hence,
    # the non-printable characters must be emitted as `\u{...}`.
    result = pretty_table(String, ["a\x01b​c" ;;]; backend = :typst)

    @test occursin("[a\\u{1}b\\u{200b}c],", result)
end

@testset "Style Properties Are Not Markup Escaped" begin
    # The style properties are emitted in Typst code mode. Hence, applying the markup
    # escaping would corrupt values like `rgb("#ff0000")`.
    result = pretty_table(
        String,
        [1 2];
        backend = :typst,
        style = TypstTableStyle(; first_line_column_label = ["fill" => "rgb(\"#ff0000\")"]),
    )

    @test occursin("rgb(\"#ff0000\")", result)
end
