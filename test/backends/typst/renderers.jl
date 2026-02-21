## Description #############################################################################
#
# Typst Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    matrix  = ['a' :a "a" missing nothing]
    backend = :typst

    @testset ":print" begin

        expected = """
#{
  table(
    align: (right, right, right, right, right,),
    columns: (auto, auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
      [#text(weight: "bold",)[Col. 4]],
      [#text(weight: "bold",)[Col. 5]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [a],
    [a],
    [a],
    [missing],
    [nothing],
  )
}
"""

        result = pretty_table(String, matrix; backend)
        @test result == expected
    end

    @testset ":show" begin
        expected = """
#{
  table(
    align: (right, right, right, right, right,),
    columns: (auto, auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Col. 1]],
      [#text(weight: "bold",)[Col. 2]],
      [#text(weight: "bold",)[Col. 3]],
      [#text(weight: "bold",)[Col. 4]],
      [#text(weight: "bold",)[Col. 5]],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    ['a'],
    [:a],
    [a],
    [missing],
    [nothing],
  )
}
"""

        result = pretty_table(String, matrix; backend, renderer = :show)
        @test result == expected
    end

    @testset "Markdown Cells" verbose = true begin
        matrix = [
            1 md"**bold**"
            2 md"*italic*"
            3 md"""
                  ```julia
                  julia> sind(30)
                  ```

                  This is a cell block with multiple lines."""
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
    [#raw(
      "**bold**",
      block: false,
      lang: "markdown",
    )],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [2],
    [#raw(
      "*italic*",
      block: false,
      lang: "markdown",
    )],
    // -- Data: Row 3 ----------------------------------------------------------------------
    [3],
    [
      #raw(
      "```julia\n" + 
      "julia> sind(30)\n" + 
      "```\n" + 
      "\n" + 
      "This is a cell block with multiple lines.",
      block: false,
      lang: "markdown",
    )
    ],
  )
}
"""

        result = pretty_table(String, matrix; backend)
        @test result == expected
    end
end
