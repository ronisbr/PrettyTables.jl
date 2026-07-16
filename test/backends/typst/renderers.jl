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
    table.vline(x: 5, end: 2, stroke: 1.5pt),
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
    table.vline(x: 5, end: 2, stroke: 1.5pt),
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
    stroke: none,
    // == Horizontal Lines =================================================================
    table.hline(y: 0, stroke: 1.5pt,),
    table.hline(y: 1, stroke: 0.8pt,),
    table.hline(y: 4, stroke: 1.5pt,),
    // == Vertical Lines ===================================================================
    table.vline(x: 0, end: 4, stroke: 1.5pt),
    table.vline(x: 1, end: 4, stroke: 0.8pt),
    table.vline(x: 2, end: 4, stroke: 1.5pt),
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
