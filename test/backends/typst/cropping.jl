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
  // Open table
  table(
    columns: (auto, auto, auto, auto),
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      table.cell()[#text()[⋯]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell(align: right,)[#text()[(1, 3)]],
    table.cell()[#text()[⋯]],
    // data Row 2
    table.cell(align: right,)[#text()[(2, 1)]],
    table.cell(align: right,)[#text()[(2, 2)]],
    table.cell(align: right,)[#text()[(2, 3)]],
    table.cell()[#text()[⋯]],
    // continuation_row Row 3
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋱]],
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
  // Open table
  table(
    columns: (auto, auto, auto, auto),
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      table.cell()[#text()[⋯]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell(align: right,)[#text()[(1, 3)]],
    table.cell()[#text()[⋯]],
    // continuation_row Row 2
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋱]],
    // data Row 100
    table.cell(align: right,)[#text()[(100, 1)]],
    table.cell(align: right,)[#text()[(100, 2)]],
    table.cell(align: right,)[#text()[(100, 3)]],
    table.cell()[#text()[⋯]],
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
  // Open table
  table(
    columns: (auto, auto, auto, auto),
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      table.cell()[#text()[⋯]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell(align: right,)[#text()[(1, 3)]],
    table.cell()[#text()[⋯]],
    // data Row 2
    table.cell(align: right,)[#text()[(2, 1)]],
    table.cell(align: right,)[#text()[(2, 2)]],
    table.cell(align: right,)[#text()[(2, 3)]],
    table.cell()[#text()[⋯]],
    // continuation_row Row 3
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋱]],
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
