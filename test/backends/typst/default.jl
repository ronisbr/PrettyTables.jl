## Description #############################################################################
#
# Typst Back End: Test with default options.
#
############################################################################################

@testset "Default Options" begin
    backend=:typst
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    expected = """
#{
  // Open table
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 4]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 5]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 6]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[1]],
    table.cell(align: right,)[#text()[1.0]],
    table.cell(align: right,)[#text()[1]],
    table.cell(align: right,)[#text()[a]],
    table.cell(align: right,)[#text()[abc]],
    table.cell(align: right,)[#text()[missing]],
    // data Row 2
    table.cell(align: right,)[#text()[2]],
    table.cell(align: right,)[#text()[2.0]],
    table.cell(align: right,)[#text()[2]],
    table.cell(align: right,)[#text()[b]],
    table.cell(align: right,)[#text()[def]],
    table.cell(align: right,)[#text()[nothing]],
    // data Row 3
    table.cell(align: right,)[#text()[3]],
    table.cell(align: right,)[#text()[3.0]],
    table.cell(align: right,)[#text()[3]],
    table.cell(align: right,)[#text()[c]],
    table.cell(align: right,)[#text()[ghi]],
    table.cell(align: right,)[#text()[symbol]],
  )
}
"""

    result = pretty_table(String, matrix; backend)
    @test result == expected

    result = pretty_table_typst_backend(String, matrix)
    @test result == expected
end
