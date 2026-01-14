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
  // Open table
  table(
    columns: (auto, auto, auto, auto), 
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Row]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. -3]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. -2]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. -1]], 
    ), 
    // Body
    // data Row 1
    table.cell(align: right,)[#text(weight: "bold",)[-2]], 
    table.cell(align: right,)[#text()[(1, 1)]], 
    table.cell(align: right,)[#text()[(1, 2)]], 
    table.cell(align: right,)[#text()[\#undef]], 
    // data Row 2
    table.cell(align: right,)[#text(weight: "bold",)[-1]], 
    table.cell(align: right,)[#text()[nothing]], 
    table.cell(align: right,)[#text()[missing]], 
    table.cell(align: right,)[#text()[\#undef]], 
    // data Row 3
    table.cell(align: right,)[#text(weight: "bold",)[0]], 
    table.cell(align: right,)[#text()[\#undef]], 
    table.cell(align: right,)[#text()[\#undef]], 
    table.cell(align: right,)[#text()[(3, 3)]], 
  )
}
"""

    result = pretty_table(
        String,
        omatrix;
        backend,
        show_row_number_column = true,
    )
    @test result == expected
end
