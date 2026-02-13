## Description #############################################################################
#
# Typst Back End: Test related Typst.jl extender
#
############################################################################################
using Typstry

@testset "Typst Extension" verbose = true begin
    backend = :typst
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    @testset "Typst Type ouptut" verbose = true begin
        text_expected = """
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

        # Test String Output.
        text_result = pretty_table(String, matrix; backend)
        @test text_result == text_expected

        # Test Typst Output.
        expected = Typst(TypstText(text_expected))
        result   = pretty_table(Typst, matrix; backend)

        @test result == expected

        # Test backend inferred by Typst Output.
        result_inferred = pretty_table(Typst, matrix;)

        @test expected == result_inferred
    end

    @testset "Raw Typst Cells" verbose = true begin
        backend = :typst
        matrix = [
            1 typst"#text(fill: blue, weight: \"bold\")[Typst Cell \#1]"
            2 typst"#text(fill: red, weight: \"bold\")[Typst Cell \#2]"
        ]

        expected = raw"""
#{
  table(
    align: (right, right,),
    columns: (auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [1],
    [#text(fill: blue, weight: "bold")[Typst Cell \#1]],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [2],
    [#text(fill: red, weight: "bold")[Typst Cell \#2]],
  )
}
"""

        # Test String Output
        result = pretty_table(String, matrix; backend)

        @test result == expected
    end
end

