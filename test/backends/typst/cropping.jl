## Description #############################################################################
#
# Typst Back End: Tests related to table cropping.
#
############################################################################################

@testset "Table Cropping" verbose = true begin
    matrix  = [(i, j) for i in 1:100, j in 1:100]
    backend = :typst

    @testset "Bottom Cropping" begin
        expected = """
#{
  table(
    align: (right, right, right, center,),
    columns: (auto, auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 0.8pt),
    table.vline(x: 4, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
      [⋯],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [(1, 1)],
    [(1, 2)],
    [(1, 3)],
    [⋯],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [(2, 1)],
    [(2, 2)],
    [(2, 3)],
    [⋯],
    // -- Continuation Row -----------------------------------------------------------------
    [⋮],
    [⋮],
    [⋮],
    [⋱],
    // -- Omitted Cell Summary -------------------------------------------------------------
    table.cell(align: right, colspan: 4, inset: (right: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[97 columns and 98 rows omitted]
    ],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
        )

        @test result == expected
    end

    @testset "Middle Cropping" begin
        expected = """
#{
  table(
    align: (right, right, right, center,),
    columns: (auto, auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 0.8pt),
    table.vline(x: 4, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
      [⋯],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [(1, 1)],
    [(1, 2)],
    [(1, 3)],
    [⋯],
    // -- Continuation Row -----------------------------------------------------------------
    [⋮],
    [⋮],
    [⋮],
    [⋱],
    // -- Data: Row 100 --------------------------------------------------------------------
    [(100, 1)],
    [(100, 2)],
    [(100, 3)],
    [⋯],
    // -- Omitted Cell Summary -------------------------------------------------------------
    table.cell(align: right, colspan: 4, inset: (right: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[97 columns and 98 rows omitted]
    ],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            vertical_crop_mode = :middle,
        )

        @test result == expected
    end

    @testset "Omitted Cell Summary" begin
        expected = """
#{
  table(
    align: (right, right, right, center,),
    columns: (auto, auto, auto, auto,),
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 0.8pt),
    table.vline(x: 3, end: 4, stroke: 0.8pt),
    table.vline(x: 4, end: 4, stroke: 1.5pt),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
      [⋯],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [(1, 1)],
    [(1, 2)],
    [(1, 3)],
    [⋯],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [(2, 1)],
    [(2, 2)],
    [(2, 3)],
    [⋯],
    // -- Continuation Row -----------------------------------------------------------------
    [⋮],
    [⋮],
    [⋮],
    [⋱],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            show_omitted_cell_summary = false,
        )

        @test result == expected
    end
end
