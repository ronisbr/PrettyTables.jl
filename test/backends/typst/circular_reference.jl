## Description #############################################################################
#
# Typst Back End: Test circular reference.
#
############################################################################################

@testset "Circular Reference" begin
    cr = CircularRef(
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [10, 11, 12]
    )

    cr.A1[2]   = cr
    cr.A4[end] = cr

    expected = raw"""
#{
  table(
    columns: (auto, auto, auto, auto), 
    table.header(
        table.cell(align: right,)[#text(weight: "bold",)[A1]],table.cell(align: right,)[#text(weight: "bold",)[A2]],table.cell(align: right,)[#text(weight: "bold",)[A3]],table.cell(align: right,)[#text(weight: "bold",)[A4]],
    ), 
    table.cell(align: right,)[#text()[1]],table.cell(align: right,)[#text()[4]],table.cell(align: right,)[#text()[7]],table.cell(align: right,)[#text()[10]],
    table.cell(align: right,)[#text()[\#= circular reference =\#]],table.cell(align: right,)[#text()[5]],table.cell(align: right,)[#text()[8]],table.cell(align: right,)[#text()[11]],
    table.cell(align: right,)[#text()[3]],table.cell(align: right,)[#text()[6]],table.cell(align: right,)[#text()[9]],table.cell(align: right,)[#text()[\#= circular reference =\#]],
  )
}
"""

    result = sprint(show, MIME("text/typst"), cr)

    @test result == expected
end

