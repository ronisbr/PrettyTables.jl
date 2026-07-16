## Description #############################################################################
#
# Typst Back End: Tests related with decorations.
#
############################################################################################

@testset "Decorations" verbose = true begin
    matrix = ones(3, 3)
    backend = :typst

    @testset "Decoration of Column Labels" begin
        expected = """
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      table.cell(fill: yellow,)[Col. 1],
      table.cell(fill: yellow,)[Col. 2],
      table.cell(fill: yellow,)[Col. 3],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            color = true,
            style = TypstTableStyle(; first_line_column_label = ["fill" => "yellow"]),
        )

        @test result == expected

        expected = """
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(fill: yellow, weight: "bold",)[Col. 1]],
      table.cell(fill: blue,)[Col. 2],
      table.cell(fill: red,)[Col. 3],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            style = TypstTableStyle(;
                first_line_column_label = [
                    ["text-fill" => "yellow", "text-weight" => "bold"],
                    ["fill" => "blue"],
                    ["fill" => "red"],
                ],
            ),
        )

        @test result == expected

        expected = """
#{
  table(
    align: (right, right, right,),
    columns: (auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 2, stroke: 0.8pt,),
    table.hline(y: 5, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 5, stroke: 1.5pt),
    table.vline(x: 1, end: 5, stroke: 0.8pt),
    table.vline(x: 2, end: 5, stroke: 0.8pt),
    table.vline(x: 3, end: 5, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "extrabold",)[Col. 1]],
      [#text(weight: "extrabold",)[Col. 2]],
      [#text(weight: "extrabold",)[Col. 3]],
      // -- Column Labels: Row 2 -----------------------------------------------------------
      [#text(font: "Roboto Mono",)[\\#1]],
      [#text(font: "Roboto Mono",)[\\#2]],
      [#text(font: "Roboto Mono",)[\\#3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [1.0],
    [1.0],
    [1.0],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            column_labels = [["Col. 1", "Col. 2", "Col. 3"], ["#1", "#2", "#3"]],
            style = TypstTableStyle(;
                first_line_column_label = ["text-weight" => "extrabold"],
                column_label = ["text-font" => "Roboto Mono"],
            ),
        )

        @test result == expected
    end

    @testset "Table Property Validation" verbose = true begin
        @test_warn "Unused table properties:" begin
            result = pretty_table(
                String,
                matrix;
                backend,
                style = TypstTableStyle(;
                    table = [
                        "fill"        => "yellow",
                        "text-fill"   => "blue",
                        "text-weight" => "extrabold",
                        "weigth"      => "",
                    ],
                ),
            )
        end
    end
end
