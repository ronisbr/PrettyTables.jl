## Description #############################################################################
#
# Typst Back End: Test with default options.
#
############################################################################################

@testset "Default Options" begin
    backend = :typst
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    expected = """
#{
  table(
    align: (right, right, right, right, right, right,),
    columns: (auto, auto, auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
      [#text(weight: "bold",)[Col. 4]],
      [#text(weight: "bold",)[Col. 5]],
      [#text(weight: "bold",)[Col. 6]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1],
    [1.0],
    [1],
    [a],
    [abc],
    [missing],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [2],
    [2.0],
    [2],
    [b],
    [def],
    [nothing],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [3],
    [3.0],
    [3],
    [c],
    [ghi],
    [symbol],
  )
}
"""

    result = pretty_table(String, matrix; backend)
    @test result == expected

    result = pretty_table_typst_backend(String, matrix)
    @test result == expected
end
