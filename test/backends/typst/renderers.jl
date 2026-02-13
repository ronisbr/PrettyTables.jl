## Description #############################################################################
#
# Typst Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    @testset ":print" begin
        matrix = ['a' :a "a" missing nothing]
        backend = :typst
        expected = """
  #{
    // Open table
    table(
      columns: (auto, auto, auto, auto, auto),
      // Table Header
      table.header(
        // column_labels Row 1
        table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
        table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
        table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
        table.cell(align: right,)[#text(weight: "bold",)[Col. 4]],
        table.cell(align: right,)[#text(weight: "bold",)[Col. 5]],
      ),
      // Body
      // data Row 1
      table.cell(align: right,)[#text()[a]],
      table.cell(align: right,)[#text()[a]],
      table.cell(align: right,)[#text()[a]],
      table.cell(align: right,)[#text()[missing]],
      table.cell(align: right,)[#text()[nothing]],
    )
  }
  """
        result = pretty_table(String, matrix; backend)

        @test result == expected
    end

    @testset ":show" begin
        matrix = ['a' :a "a" missing nothing]
        backend = :typst
        expected = """
#{
  // Open table
  table(
    columns: (auto, auto, auto, auto, auto),
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 4]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 5]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text()['a']],
    table.cell(align: right,)[#text()[:a]],
    table.cell(align: right,)[#text()[a]],
    table.cell(align: right,)[#text()[missing]],
    table.cell(align: right,)[#text()[nothing]],
  )
}
"""

        result = pretty_table(String, matrix; backend, renderer = :show)

        @test result == expected
    end

    @testset "Markdown Cells" verbose = true begin
        backend = :typst
        matrix = [
            1 md"**bold**"
            2 md"*italic*"
            3 md"""
                  ```julia
                  julia> sind(30)
                  ```

                  This is a cell block with multiple lines."""
        ]

        expected = """
#{
  // Open table
  table(
    columns: (auto, auto),
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[1]],
    table.cell(align: right,)[
      #raw(
        "**bold**",
        block: false,
        lang: "markdown",
      )
    ],
    // data Row 2
    table.cell(align: right,)[#text()[2]],
    table.cell(align: right,)[
      #raw(
        "*italic*",
        block: false,
        lang: "markdown",
      )
    ],
    // data Row 3
    table.cell(align: right,)[#text()[3]],
    table.cell(align: right,)[
      #raw(
        "```julia\\n" + 
        "julia> sind(30)\\n" + 
        "```\\n" + 
        "\\n" + 
        "This is a cell block with multiple lines.",
        block: false,
        lang: "markdown",
      )
    ],
  )
}
"""
        # Test String Output
        result = pretty_table(String, matrix; backend)

        @test result == expected
    end
end
