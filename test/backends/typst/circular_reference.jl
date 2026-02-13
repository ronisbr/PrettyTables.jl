## Description #############################################################################
#
# Typst Back End: Test circular reference.
#
############################################################################################

@testset "Circular Reference" begin
    cr = CircularRef([1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12])

    cr.A1[2]   = cr
    cr.A4[end] = cr

    expected = raw"""
#{
  table(
    align: (right, right, right, right,),
    columns: (auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[A1]],
      [#text(weight: "bold",)[A2]],
      [#text(weight: "bold",)[A3]],
      [#text(weight: "bold",)[A4]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1],
    [4],
    [7],
    [10],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [\#= circular reference =\#],
    [5],
    [8],
    [11],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [3],
    [6],
    [9],
    [\#= circular reference =\#],
  )
}
"""

    result = sprint(show, MIME("text/typst"), cr)

    @test result == expected
end
