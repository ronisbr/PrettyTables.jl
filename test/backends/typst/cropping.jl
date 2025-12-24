## Description #############################################################################
#
# HTML Back End: Tests related to table cropping.
#
############################################################################################

@testset "Table Cropping" verbose = true begin
    matrix = [(i, j) for i in 1:100, j in 1:100]
    backend=:typst
    @testset "Bottom Cropping" begin
        expected = """
#align(top+right, )[97 columns and 98 rows omitted]
#{
  table(
    columns: (auto, auto, auto, auto), 
    table.header(
        table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],table.cell()[#text()[ ⋯ ]],
    ), 
    table.cell(align: right,)[#text()[(1, 1)]],table.cell(align: right,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],table.cell()[#text()[ ⋯ ]],
    table.cell(align: right,)[#text()[(2, 1)]],table.cell(align: right,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],table.cell()[#text()[ ⋯ ]],
    table.cell()[#text()[  ⋮ ]],table.cell()[#text()[  ⋮ ]],table.cell()[#text()[  ⋮ ]],table.cell()[#text()[ ⋱ ]],
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
#align(top+right, )[97 columns and 98 rows omitted]
#{
  table(
    columns: (auto, auto, auto, auto), 
    table.header(
        table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],table.cell()[#text()[ ⋯ ]],
    ), 
    table.cell(align: right,)[#text()[(1, 1)]],table.cell(align: right,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],table.cell()[#text()[ ⋯ ]],
    table.cell()[#text()[  ⋮ ]],table.cell()[#text()[  ⋮ ]],table.cell()[#text()[  ⋮ ]],table.cell()[#text()[ ⋱ ]],
    table.cell(align: right,)[#text()[(100, 1)]],table.cell(align: right,)[#text()[(100, 2)]],table.cell(align: right,)[#text()[(100, 3)]],table.cell()[#text()[ ⋯ ]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            vertical_crop_mode = :middle
        )

        @test result == expected
    end

    @testset "Omitted Cell Summary" begin
        expected = """
#{
  table(
    columns: (auto, auto, auto, auto), 
    table.header(
        table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],table.cell()[#text()[ ⋯ ]],
    ), 
    table.cell(align: right,)[#text()[(1, 1)]],table.cell(align: right,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],table.cell()[#text()[ ⋯ ]],
    table.cell(align: right,)[#text()[(2, 1)]],table.cell(align: right,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],table.cell()[#text()[ ⋯ ]],
    table.cell()[#text()[  ⋮ ]],table.cell()[#text()[  ⋮ ]],table.cell()[#text()[  ⋮ ]],table.cell()[#text()[ ⋱ ]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            show_omitted_cell_summary = false
        )

        @test result == expected
    end
end
