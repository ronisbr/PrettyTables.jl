## Description #############################################################################
#
# HTML Back End: Tests related with decorations.
#
############################################################################################

@testset "Decorations" verbose = true begin
    @testset "Decoration of Column Labels" begin
        matrix = ones(3, 3)
        backend = :typst

        expected = """
#{
  table(
    columns: (auto, auto, auto), 
    table.header(
        table.cell(align: right,fill: yellow,)[#text()[Col. 1]],table.cell(align: right,fill: yellow,)[#text()[Col. 2]],table.cell(align: right,fill: yellow,)[#text()[Col. 3]],
    ), 
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            color   = true,
            style   = TypstTableStyle(; first_line_column_label = ["fill" => "yellow"])
        )

        @test result == expected

        expected = """
#{
  table(
    columns: (auto, auto, auto), 
    table.header(
        table.cell(align: right,fill: yellow,)[#text()[Col. 1]],table.cell(align: right,fill: blue,)[#text()[Col. 2]],table.cell(align: right,fill: red,)[#text()[Col. 3]],
    ), 
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            style   = TypstTableStyle(; first_line_column_label = [
                ["fill" => "yellow"],
                ["fill" => "blue"],
                ["fill" => "red"]
            ])
        )

        @test result == expected


        expected = """
#{
  table(
    columns: (auto, auto, auto), 
    table.header(
        table.cell(align: right,fill: yellow,)[#text(fill: blue,weight: "extrabold",)[Col. 1]],table.cell(align: right,fill: blue,)[#text(fill: white,weight: "extrabold",)[Col. 2]],table.cell(align: right,fill: red,)[#text(fill: rgb(30,30,30),)[Col. 3]],
    ), 
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
    table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],table.cell(align: right,)[#text()[1.0]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            style   = TypstTableStyle(; first_line_column_label = [
                ["fill" => "yellow","text-fill"=>"blue", "text-weight"=>"extrabold"],
                ["fill" => "blue","text-fill"=>"white", "text-weight"=>"extrabold"],
                ["fill" => "red", "text-fill"=>"rgb(30,30,30)"]
            ])
        )

        @test result == expected
    end
end

