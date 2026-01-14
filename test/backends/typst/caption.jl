## Description #############################################################################
#
# Typst Back End: Test Caption.
# 
############################################################################################

@testset "Caption" begin
    matrix = [
        1 2 3
        4 5 6
    ]
    backend=:typst

    expected = """
#{
  // Figure for table to add caption
  figure(
    // Open table
    table(
      columns: (auto, auto, auto),
      // Table Header
      table.header(
        // column_labels Row 1
        table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
        table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],
        table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      ),
      // Body
      // data Row 1
      table.cell(align: right,)[#text(fill: green, weight: "bold",)[1]],
      table.cell(align: right,)[#text(fill: red,)[2]],
      table.cell(align: right,)[#text(fill: green, weight: "bold",)[3]],
      // data Row 2
      table.cell(align: right,)[#text(fill: red,)[4]],
      table.cell(align: right,)[#text(fill: green, weight: "bold",)[5]],
      table.cell(align: right,)[#text(fill: red,)[6]],
    ),
    caption: "Caption table"
  )
}
"""

    result = pretty_table(
        String,
        matrix;
        backend,
        highlighters = [
            TypstHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "red"]),
            TypstHighlighter((data, i, j) -> data[i, j] % 2 == 0, ["text-fill" => "blue"]),
            TypstHighlighter((data, i, j) -> data[i, j] % 2 != 0, ["text-weight" => "bold", "text-fill" => "green"])
        ],
        caption="Caption table"
    )
    @test result == expected
   
end
