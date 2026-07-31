## Description #############################################################################
#
# Typst Back End: Test Caption.
# 
############################################################################################

@testset "Caption" begin
    matrix = [
        1 2 3
        4 5 6
    ]
    backend = :typst

    @testset "Text Caption" begin
        expected = """
#{
  figure(
    table(
      align: (right, right, right,),
      columns: (auto, auto, auto,),
      stroke: none,
      // == Horizontal Lines ===============================================================
      table.hline(y: 0, stroke: 1.5pt,),
      table.hline(y: 1, stroke: 0.8pt,),
      table.hline(y: 3, stroke: 1.5pt,),
      // == Vertical Lines =================================================================
      table.vline(x: 0, end: 3, stroke: 1.5pt),
      table.vline(x: 1, end: 3, stroke: 0.8pt),
      table.vline(x: 2, end: 3, stroke: 0.8pt),
      table.vline(x: 3, end: 3, stroke: 1.5pt),
      // == Table Header ===================================================================
      table.header(
        // -- Column Labels: Row 1 ---------------------------------------------------------
        [#text(weight: "bold",)[Col. 1]],
        [#text(weight: "bold",)[Col. 2]],
        [#text(weight: "bold",)[Col. 3]],
      ),
      // == Table Body =====================================================================
      // -- Data: Row 1 --------------------------------------------------------------------
      [#text(weight: "bold", fill: green,)[1]],
      [#text(fill: red,)[2]],
      [#text(weight: "bold", fill: green,)[3]],
      // -- Data: Row 2 --------------------------------------------------------------------
      [#text(fill: red,)[4]],
      [#text(weight: "bold", fill: green,)[5]],
      [#text(fill: red,)[6]],
    ),
    caption: "Caption table",
    kind: auto,
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            highlighters = [
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "red"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 != 0,
                    ["text-weight" => "bold", "text-fill" => "green"],
                ),
            ],
            caption = "Caption table",
        )
        @test result == expected
    end

    @testset "Caption - Auto Kind " begin
        expected = """
#{
  figure(
    table(
      align: (right, right, right,),
      columns: (auto, auto, auto,),
      stroke: none,
      // == Horizontal Lines ===============================================================
      table.hline(y: 0, stroke: 1.5pt,),
      table.hline(y: 1, stroke: 0.8pt,),
      table.hline(y: 3, stroke: 1.5pt,),
      // == Vertical Lines =================================================================
      table.vline(x: 0, end: 3, stroke: 1.5pt),
      table.vline(x: 1, end: 3, stroke: 0.8pt),
      table.vline(x: 2, end: 3, stroke: 0.8pt),
      table.vline(x: 3, end: 3, stroke: 1.5pt),
      // == Table Header ===================================================================
      table.header(
        // -- Column Labels: Row 1 ---------------------------------------------------------
        [#text(weight: "bold",)[Col. 1]],
        [#text(weight: "bold",)[Col. 2]],
        [#text(weight: "bold",)[Col. 3]],
      ),
      // == Table Body =====================================================================
      // -- Data: Row 1 --------------------------------------------------------------------
      [#text(weight: "bold", fill: green,)[1]],
      [#text(fill: red,)[2]],
      [#text(weight: "bold", fill: green,)[3]],
      // -- Data: Row 2 --------------------------------------------------------------------
      [#text(fill: red,)[4]],
      [#text(weight: "bold", fill: green,)[5]],
      [#text(fill: red,)[6]],
    ),
    caption: figure.caption(
      [Caption table]
    ),
    kind: auto,
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            highlighters = [
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "red"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 != 0,
                    ["text-weight" => "bold", "text-fill" => "green"],
                ),
            ],
            caption = TypstCaption("Caption table"),
        )
        @test result == expected
    end

    @testset "Caption - Table Kind " begin
        expected = """
#{
  figure(
    table(
      align: (right, right, right,),
      columns: (auto, auto, auto,),
      stroke: none,
      // == Horizontal Lines ===============================================================
      table.hline(y: 0, stroke: 1.5pt,),
      table.hline(y: 1, stroke: 0.8pt,),
      table.hline(y: 3, stroke: 1.5pt,),
      // == Vertical Lines =================================================================
      table.vline(x: 0, end: 3, stroke: 1.5pt),
      table.vline(x: 1, end: 3, stroke: 0.8pt),
      table.vline(x: 2, end: 3, stroke: 0.8pt),
      table.vline(x: 3, end: 3, stroke: 1.5pt),
      // == Table Header ===================================================================
      table.header(
        // -- Column Labels: Row 1 ---------------------------------------------------------
        [#text(weight: "bold",)[Col. 1]],
        [#text(weight: "bold",)[Col. 2]],
        [#text(weight: "bold",)[Col. 3]],
      ),
      // == Table Body =====================================================================
      // -- Data: Row 1 --------------------------------------------------------------------
      [#text(weight: "bold", fill: green,)[1]],
      [#text(fill: red,)[2]],
      [#text(weight: "bold", fill: green,)[3]],
      // -- Data: Row 2 --------------------------------------------------------------------
      [#text(fill: red,)[4]],
      [#text(weight: "bold", fill: green,)[5]],
      [#text(fill: red,)[6]],
    ),
    caption: figure.caption(
      [Caption table]
    ),
    kind: table,
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            highlighters = [
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "red"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 != 0,
                    ["text-weight" => "bold", "text-fill" => "green"],
                ),
            ],
            caption = TypstCaption("Caption table"; kind = "table"),
        )
        @test result == expected
    end

    @testset "Caption - Custom Kind " begin
        expected = """
#{
  set text(size: 1em,)
  figure(
    table(
      align: (right, right, right,),
      columns: (auto, auto, auto,),
      stroke: none,
      // == Horizontal Lines ===============================================================
      table.hline(y: 0, stroke: 1.5pt,),
      table.hline(y: 1, stroke: 0.8pt,),
      table.hline(y: 3, stroke: 1.5pt,),
      // == Vertical Lines =================================================================
      table.vline(x: 0, end: 3, stroke: 1.5pt),
      table.vline(x: 1, end: 3, stroke: 0.8pt),
      table.vline(x: 2, end: 3, stroke: 0.8pt),
      table.vline(x: 3, end: 3, stroke: 1.5pt),
      // == Table Header ===================================================================
      table.header(
        // -- Column Labels: Row 1 ---------------------------------------------------------
        [#text(weight: "bold",)[Col. 1]],
        [#text(weight: "bold",)[Col. 2]],
        [#text(weight: "bold",)[Col. 3]],
      ),
      // == Table Body =====================================================================
      // -- Data: Row 1 --------------------------------------------------------------------
      [#text(weight: "bold", fill: green,)[1]],
      [#text(fill: red,)[2]],
      [#text(weight: "bold", fill: green,)[3]],
      // -- Data: Row 2 --------------------------------------------------------------------
      [#text(fill: red,)[4]],
      [#text(weight: "bold", fill: green,)[5]],
      [#text(fill: red,)[6]],
    ),
    caption: figure.caption(
      [Custom kind]
    ),
    kind: "pretty-tables",
    supplement: [Pretty Tables],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            highlighters = [
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "red"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 != 0,
                    ["text-weight" => "bold", "text-fill" => "green"],
                ),
            ],
            style = TypstTableStyle(; table = ["text-size" => "1em"]),
            caption = TypstCaption(
                "Custom kind"; kind = "pretty-tables", supplement = "Pretty Tables"
            ),
        )
        @test result == expected
    end

    @testset "Caption - Kind Table - Custom Suplement " begin
        expected = """
#{
  set text(size: 1em,)
  figure(
    table(
      align: (right, right, right,),
      columns: (auto, auto, auto,),
      stroke: none,
      // == Horizontal Lines ===============================================================
      table.hline(y: 0, stroke: 1.5pt,),
      table.hline(y: 1, stroke: 0.8pt,),
      table.hline(y: 3, stroke: 1.5pt,),
      // == Vertical Lines =================================================================
      table.vline(x: 0, end: 3, stroke: 1.5pt),
      table.vline(x: 1, end: 3, stroke: 0.8pt),
      table.vline(x: 2, end: 3, stroke: 0.8pt),
      table.vline(x: 3, end: 3, stroke: 1.5pt),
      // == Table Header ===================================================================
      table.header(
        // -- Column Labels: Row 1 ---------------------------------------------------------
        [#text(weight: "bold",)[Col. 1]],
        [#text(weight: "bold",)[Col. 2]],
        [#text(weight: "bold",)[Col. 3]],
      ),
      // == Table Body =====================================================================
      // -- Data: Row 1 --------------------------------------------------------------------
      [#text(weight: "bold", fill: green,)[1]],
      [#text(fill: red,)[2]],
      [#text(weight: "bold", fill: green,)[3]],
      // -- Data: Row 2 --------------------------------------------------------------------
      [#text(fill: red,)[4]],
      [#text(weight: "bold", fill: green,)[5]],
      [#text(fill: red,)[6]],
    ),
    caption: figure.caption(
      [Table with custom supplement]
    ),
    kind: table,
    supplement: [Pretty Tables],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            highlighters = [
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "red"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]
                ),
                TypstHighlighter(
                    (data, i, j) -> data[i, j] % 2 != 0,
                    ["text-weight" => "bold", "text-fill" => "green"],
                ),
            ],
            style = TypstTableStyle(; table = ["text-size" => "1em"]),
            caption = TypstCaption(
                "Table with custom supplement"; kind = "table", supplement = "Pretty Tables"
            ),
        )
        @test result == expected
    end
end
