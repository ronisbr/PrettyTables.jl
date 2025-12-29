## Description #############################################################################
#
# Typst Back End: Tests related with the cell alignment.
#
############################################################################################

@testset "Alignment" verbose = true begin
    matrix = [(i, j) for i in 1:5, j in 1:5]
    backend=:typst
    @testset "Alignment as a Symbol" verbose = true  begin
        expected = """
#{
  table(
    columns: (auto, auto, auto, auto, auto), 
    table.header(
        table.cell(align: center,)[#text(weight: "bold",)[Col. 1]],table.cell(align: center,)[#text(weight: "bold",)[Col. 2]],table.cell(align: center,)[#text(weight: "bold",)[Col. 3]],table.cell(align: center,)[#text(weight: "bold",)[Col. 4]],table.cell(align: center,)[#text(weight: "bold",)[Col. 5]],
    ), 
    table.cell(align: center,)[#text()[(1, 1)]],table.cell(align: center,)[#text()[(1, 2)]],table.cell(align: center,)[#text()[(1, 3)]],table.cell(align: center,)[#text()[(1, 4)]],table.cell(align: center,)[#text()[(1, 5)]],
    table.cell(align: center,)[#text()[(2, 1)]],table.cell(align: center,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],table.cell(align: center,)[#text()[(2, 4)]],table.cell(align: center,)[#text()[(2, 5)]],
    table.cell(align: center,)[#text()[(3, 1)]],table.cell(align: center,)[#text()[(3, 2)]],table.cell(align: center,)[#text()[(3, 3)]],table.cell(align: center,)[#text()[(3, 4)]],table.cell(align: center,)[#text()[(3, 5)]],
    table.cell(align: center,)[#text()[(4, 1)]],table.cell(align: center,)[#text()[(4, 2)]],table.cell(align: center,)[#text()[(4, 3)]],table.cell(align: center,)[#text()[(4, 4)]],table.cell(align: left,)[#text()[(4, 5)]],
    table.cell(align: center,)[#text()[(5, 1)]],table.cell(align: center,)[#text()[(5, 2)]],table.cell(align: center,)[#text()[(5, 3)]],table.cell(align: center,)[#text()[(5, 4)]],table.cell(align: center,)[#text()[(5, 5)]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            alignment = :c,
            cell_alignment = [(2, 3) => :r, (4, 5) => :l], 
        )

        @test result == expected

        expected = """
#{
  table(
    columns: (auto, auto, auto, auto, auto), 
    table.header(
        table.cell()[#text(weight: "bold",)[Col. 1]],table.cell()[#text(weight: "bold",)[Col. 2]],table.cell()[#text(weight: "bold",)[Col. 3]],table.cell()[#text(weight: "bold",)[Col. 4]],table.cell()[#text(weight: "bold",)[Col. 5]],
    ), 
    table.cell()[#text()[(1, 1)]],table.cell()[#text()[(1, 2)]],table.cell()[#text()[(1, 3)]],table.cell()[#text()[(1, 4)]],table.cell()[#text()[(1, 5)]],
    table.cell()[#text()[(2, 1)]],table.cell()[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],table.cell()[#text()[(2, 4)]],table.cell()[#text()[(2, 5)]],
    table.cell()[#text()[(3, 1)]],table.cell()[#text()[(3, 2)]],table.cell()[#text()[(3, 3)]],table.cell()[#text()[(3, 4)]],table.cell()[#text()[(3, 5)]],
    table.cell()[#text()[(4, 1)]],table.cell()[#text()[(4, 2)]],table.cell()[#text()[(4, 3)]],table.cell()[#text()[(4, 4)]],table.cell(align: left,)[#text()[(4, 5)]],
    table.cell()[#text()[(5, 1)]],table.cell()[#text()[(5, 2)]],table.cell()[#text()[(5, 3)]],table.cell()[#text()[(5, 4)]],table.cell()[#text()[(5, 5)]],
  )
}
"""
        result = pretty_table(
            String,
            matrix;
            alignment = :n,
            backend = :typst,
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected
    end

    @testset "Alignment as a Vector" verbose = true  begin
        expected = """
#{
  table(
    columns: (auto, auto, auto, auto, auto), 
    table.header(
        table.cell(align: left,)[#text(weight: "bold",)[Col. 1]],table.cell(align: center,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],table.cell(align: left,)[#text(weight: "bold",)[Col. 4]],table.cell(align: center,)[#text(weight: "bold",)[Col. 5]],
    ), 
    table.cell(align: left,)[#text()[(1, 1)]],table.cell(align: center,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],table.cell(align: left,)[#text()[(1, 4)]],table.cell(align: center,)[#text()[(1, 5)]],
    table.cell(align: left,)[#text()[(2, 1)]],table.cell(align: center,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],table.cell(align: left,)[#text()[(2, 4)]],table.cell(align: center,)[#text()[(2, 5)]],
    table.cell(align: left,)[#text()[(3, 1)]],table.cell(align: center,)[#text()[(3, 2)]],table.cell(align: right,)[#text()[(3, 3)]],table.cell(align: left,)[#text()[(3, 4)]],table.cell(align: center,)[#text()[(3, 5)]],
    table.cell(align: left,)[#text()[(4, 1)]],table.cell(align: center,)[#text()[(4, 2)]],table.cell(align: right,)[#text()[(4, 3)]],table.cell(align: left,)[#text()[(4, 4)]],table.cell(align: left,)[#text()[(4, 5)]],
    table.cell(align: left,)[#text()[(5, 1)]],table.cell(align: center,)[#text()[(5, 2)]],table.cell(align: right,)[#text()[(5, 3)]],table.cell(align: left,)[#text()[(5, 4)]],table.cell(align: center,)[#text()[(5, 5)]],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :typst,
            alignment = [:l, :c, :r, :l, :c],
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected

        expected = """
#{
  table(
    columns: (auto, auto, auto, auto, auto), 
    table.header(
        table.cell(align: left,)[#text(weight: "bold",)[Col. 1]],table.cell(align: center,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],table.cell()[#text(weight: "bold",)[Col. 4]],table.cell(align: right,)[#text(weight: "bold",)[Col. 5]],
    ), 
    table.cell(align: left,)[#text()[(1, 1)]],table.cell(align: center,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],table.cell()[#text()[(1, 4)]],table.cell(align: right,)[#text()[(1, 5)]],
    table.cell(align: left,)[#text()[(2, 1)]],table.cell(align: center,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],table.cell()[#text()[(2, 4)]],table.cell(align: right,)[#text()[(2, 5)]],
    table.cell(align: left,)[#text()[(3, 1)]],table.cell(align: center,)[#text()[(3, 2)]],table.cell(align: right,)[#text()[(3, 3)]],table.cell()[#text()[(3, 4)]],table.cell(align: right,)[#text()[(3, 5)]],
    table.cell(align: left,)[#text()[(4, 1)]],table.cell(align: center,)[#text()[(4, 2)]],table.cell(align: right,)[#text()[(4, 3)]],table.cell()[#text()[(4, 4)]],table.cell(align: left,)[#text()[(4, 5)]],
    table.cell(align: left,)[#text()[(5, 1)]],table.cell(align: center,)[#text()[(5, 2)]],table.cell(align: right,)[#text()[(5, 3)]],table.cell()[#text()[(5, 4)]],table.cell(align: right,)[#text()[(5, 5)]],
  )
}
"""
        result = pretty_table(
            String,
            matrix;
            backend = :typst,
            alignment = [:l, :c, :r, :n, :X],
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected
    end
end
