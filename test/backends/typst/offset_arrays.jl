## Description #############################################################################
#
# Typst Back End: Test related with offset arrays.
#
############################################################################################

@testset "Offset Arrays" begin
    backend = :typst
    matrix = Matrix{Any}(undef, 3, 3)
    matrix[1, 1] = (1, 1)
    matrix[1, 2] = (1, 2)
    matrix[2, 1] = nothing
    matrix[2, 2] = missing
    matrix[3, 3] = (3, 3)

    omatrix = OffsetArray(matrix, -2:0, -3:-1)

    expected = raw"""
#{
  table(
    align: (right, right, right, right,),
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
      [#text(weight: "bold",)[Row]],
      [#text(weight: "bold",)[Col. -3]],
      [#text(weight: "bold",)[Col. -2]],
      [#text(weight: "bold",)[Col. -1]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold",)[-2]],
    [(1, 1)],
    [(1, 2)],
    [\#undef],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [#text(weight: "bold",)[-1]],
    [nothing],
    [missing],
    [\#undef],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [#text(weight: "bold",)[0]],
    [\#undef],
    [\#undef],
    [(3, 3)],
  )
}
"""

    result = pretty_table(String, omatrix; backend, show_row_number_column = true)
    @test result == expected
end
