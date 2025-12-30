## Description #############################################################################
#
# Typst Back End: Tests related with the cell titles.
#
############################################################################################

@testset "Cell Titles" verbose = true begin
    @testset  "Column Label Titles" begin
        matrix              = [(i, j) for i in 1:2, j in 1:4]
        column_labels       = [[(i, j) for j in 1:4] for i in 1:3]
        column_label_titles = [[1, 2, 3, 4], nothing, ["5", "6", "7", "8"]]
        backend = :typst
        expected = """
#{
  // Open table
  table(
    columns: (auto, auto, auto, auto), 
    // Table Header 
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[(1, 1)]],
      table.cell(align: right,)[#text(weight: "bold",)[(1, 2)]],
      table.cell(align: right,)[#text(weight: "bold",)[(1, 3)]],
      table.cell(align: right,)[#text(weight: "bold",)[(1, 4)]],
      // column_labels Row 2
      table.cell(align: right,)[#text(weight: "bold",)[(2, 1)]],
      table.cell(align: right,)[#text(weight: "bold",)[(2, 2)]],
      table.cell(align: right,)[#text(weight: "bold",)[(2, 3)]],
      table.cell(align: right,)[#text(weight: "bold",)[(2, 4)]],
      // column_labels Row 3
      table.cell(align: right,)[#text(weight: "bold",)[(3, 1)]],
      table.cell(align: right,)[#text(weight: "bold",)[(3, 2)]],
      table.cell(align: right,)[#text(weight: "bold",)[(3, 3)]],
      table.cell(align: right,)[#text(weight: "bold",)[(3, 4)]],
    ), 
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell(align: right,)[#text()[(1, 3)]],
    table.cell(align: right,)[#text()[(1, 4)]],
    // data Row 2
    table.cell(align: right,)[#text()[(2, 1)]],
    table.cell(align: right,)[#text()[(2, 2)]],
    table.cell(align: right,)[#text()[(2, 3)]],
    table.cell(align: right,)[#text()[(2, 4)]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )

        @test result == expected
    end

    @testset "Errors" verbose = true begin
        matrix              = [(i, j) for i in 1:2, j in 1:4]
        column_labels       = [[(i, j) for j in 1:4] for i in 1:3]


        column_label_titles = [[1, 2, 3, 4], ["5", "6", "7", "8"]]
        @test_throws Exception pretty_table(
            matrix;
            backend,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )

        column_label_titles = [[1, 2, 3, 4], nothing, ["5", "6", "7", "8", "9"]]
        @test_throws Exception pretty_table(
            matrix;
            backend,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )

        column_label_titles = [[1, 2, 3], nothing, ["5", "6", "7", "8"]]
        @test_throws Exception pretty_table(
            matrix;
            backend,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )
    end
end
