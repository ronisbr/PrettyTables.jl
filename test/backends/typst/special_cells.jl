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

@testset "Multiple Footnotes in the Same Cell" begin
    # All the footnote numbers must be inside the same superscript. Otherwise, the
    # separator would be rendered with the normal text size.
    result = pretty_table(
        String,
        [1 2];
        backend = :typst,
        footnotes = [(:data, 1, 1) => "A", (:data, 1, 1) => "B"],
    )

    @test occursin("#super[1,2]", result)
end

@testset "Comments and Line-Start Markup" begin
    # `//` and `/*` start a comment, and some markups are only recognized at the beginning
    # of a line, which is the case of the beginning of every cell.
    result = pretty_table(
        String,
        ["a // b" "a /* b" "/ t: d" "= x" "== x" "- x" "+ x" "12. x" "  - x" "-1.5" "=x"];
        backend = :typst,
    )

    for escaped in (
        "[a \\/\\/ b]",
        "[a \\/\\* b]",
        "[\\/ t: d]",
        "[\\= x]",
        "[\\== x]",
        "[\\- x]",
        "[\\+ x]",
        "[12\\. x]",
        "[  \\- x]",
        "[-1.5]",
        "[=x]",
    )
        @test occursin(escaped, result)
    end
end

@testset "Markdown Cells With Quotes and Backslashes" begin
    # Each line of a Markdown cell is emitted inside a Typst string literal. Hence, the
    # double quotes and backslashes must be escaped.
    cell = md"""
        Say "hi" with `a\b`.

        Next
        """

    result = pretty_table(String, [cell;;]; annotate = false, backend = :typst)

    @test occursin(
        """
              "Say \\"hi\\" with `a\\\\b`.\\n" + 
              "\\n" + 
              "Next",
        """,
        result,
    )
end

@testset "Text After Components" begin
    # A `.` or `(` right after a component would be parsed as a field access or a function
    # call on it. Hence, it must be escaped.
    result = pretty_table(
        String,
        [1 2];
        backend = :typst,
        footnotes = [(:data, 1, 1) => ".e", (:data, 1, 2) => "(f)"],
        style = TypstTableStyle(; footnote = TypstPair[]),
    )

    @test occursin("[#super[1]\\.e]", result)
    @test occursin("[#super[2]\\(f)]", result)

    @static if VERSION >= v"1.11"
        result = pretty_table(String, [styled"{bold:x}.y" styled"{bold:a}(b)"]; backend = :typst)

        @test occursin("[#text(weight: \"bold\",)[x]\\.y]", result)
        @test occursin("[#text(weight: \"bold\",)[a]\\(b)]", result)
    end
end

@testset "Dashes and Ellipsis" begin
    # Typst converts `--`, `---`, and `...` into dashes and an ellipsis.
    result = pretty_table(String, ["a--b" "a---b" "a..." "a-b" "-1"]; backend = :typst)

    for escaped in ("[a\\--b]", "[a\\-\\--b]", "[a\\.\\..]", "[a-b]", "[-1]")
        @test occursin(escaped, result)
    end
end
