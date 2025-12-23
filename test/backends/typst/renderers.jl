## Description #############################################################################
#
# HTML Back End: Test renderers.
#
############################################################################################

@testset "Renderers" verbose = true begin
    matrix = ['a' :a "a" missing nothing]
    backend= :typst
    @testset ":print" begin
        expected = """
#{
  table(
    columns: (auto, auto, auto, auto, auto), 
    table.header(
        table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],table.cell(align: right,)[#text(weight: "bold",)[Col. 4]],table.cell(align: right,)[#text(weight: "bold",)[Col. 5]],
    ), 
    table.cell(align: right,)[#text()['a']],table.cell(align: right,)[#text()[:a]],table.cell(align: right,)[#text()[a]],table.cell(align: right,)[#text()[missing]],table.cell(align: right,)[#text()[nothing]],
  )
}
"""
        result = pretty_table(
            String,
            matrix;
            backend
        )

        @test result == expected
    end

    @testset ":show" begin
        expected = """
#{
  table(
    columns: (auto, auto, auto, auto, auto), 
    table.header(
        table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],table.cell(align: right,)[#text(weight: "bold",)[Col. 4]],table.cell(align: right,)[#text(weight: "bold",)[Col. 5]],
    ), 
    table.cell(align: right,)[#text()['a']],table.cell(align: right,)[#text()[:a]],table.cell(align: right,)[#text()[a]],table.cell(align: right,)[#text()[missing]],table.cell(align: right,)[#text()[nothing]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            renderer = :show
        )

        @test result == expected
    end
end
