## Description #############################################################################
#
# Typst Back End: Test related with the column  widths.
#
############################################################################################
@testset "Data Column Widths" verbose = true begin
    matrix  = [(i, j) for i in 1:3, j in 1:3]
    backend = :typst

    @testset "Constant value 10fr" begin
        expected = """
#{
  table(
    align: (right, right, right,),
    columns: (10fr, 10fr, 10fr,),
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
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [(1, 1)],
    [(1, 2)],
    [(1, 3)],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [(2, 1)],
    [(2, 2)],
    [(2, 3)],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [(3, 1)],
    [(3, 2)],
    [(3, 3)],
  )
}
"""

        result = pretty_table(String, matrix; backend, data_column_widths = "10fr")
        @test result == expected
    end

    @testset "First column width 30pt, `auto` for rest " begin
        expected = """
#{
  table(
    align: (right, right, right,),
    columns: (30pt, auto, 30pt,),
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
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [(1, 1)],
    [(1, 2)],
    [(1, 3)],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [(2, 1)],
    [(2, 2)],
    [(2, 3)],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [(3, 1)],
    [(3, 2)],
    [(3, 3)],
  )
}
"""

        result = pretty_table(
            String, matrix; backend, data_column_widths = [1 => "30pt", 3 => "30pt"]
        )

        @test result == expected
    end
end
