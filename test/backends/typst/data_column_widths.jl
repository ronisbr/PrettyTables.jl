## Description #############################################################################
#
# Typst Back End: Test related with the column  widths.
#
############################################################################################
@testset "Data Column Widths" verbose = true begin
  @testset "Constant value 10fr" begin
    matrix = [(i, j) for i in 1:3, j in 1:3]
    backend=:typst

      expected = """
#{
  // Open table
  table(
    columns: (10fr, 10fr, 10fr), 
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]], 
    ), 
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[(1, 1)]], 
    table.cell(align: right,)[#text()[(1, 2)]], 
    table.cell(align: right,)[#text()[(1, 3)]], 
    // data Row 2
    table.cell(align: right,)[#text()[(2, 1)]], 
    table.cell(align: right,)[#text()[(2, 2)]], 
    table.cell(align: right,)[#text()[(2, 3)]], 
    // data Row 3
    table.cell(align: right,)[#text()[(3, 1)]], 
    table.cell(align: right,)[#text()[(3, 2)]], 
    table.cell(align: right,)[#text()[(3, 3)]], 
  )
}
"""

      result = pretty_table(
          String,
          matrix;
          backend,
          data_column_widths = "10fr"
      )

      @test result == expected
  end

  @testset "First column width 30pt, `auto` for rest " begin
    matrix = [(i, j) for i in 1:3, j in 1:3]
    backend=:typst

      expected = """
#{
  // Open table
  table(
    columns: (30pt, auto, auto), 
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]], 
    ), 
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[(1, 1)]], 
    table.cell(align: right,)[#text()[(1, 2)]], 
    table.cell(align: right,)[#text()[(1, 3)]], 
    // data Row 2
    table.cell(align: right,)[#text()[(2, 1)]], 
    table.cell(align: right,)[#text()[(2, 2)]], 
    table.cell(align: right,)[#text()[(2, 3)]], 
    // data Row 3
    table.cell(align: right,)[#text()[(3, 1)]], 
    table.cell(align: right,)[#text()[(3, 2)]], 
    table.cell(align: right,)[#text()[(3, 3)]], 
  )
}
"""

      result = pretty_table(
          String,
          matrix;
          backend,
          data_column_widths = ["30pt"]
      )

      @test result == expected

      # using pairs

      result = pretty_table(
          String,
          matrix;
          backend,
          data_column_widths = [1=>"30pt"]
      )
      @test result == expected
  end

  @testset "Only first and last columns set width 30pt " begin
      matrix = [(i, j) for i in 1:3, j in 1:3]
      backend=:typst
      expected = """
#{
  // Open table
  table(
    columns: (30pt, auto, 30pt), 
    // Table Header
    table.header(
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. 2]], 
      table.cell(align: right,)[#text(weight: "bold",)[Col. 3]], 
    ), 
    // Body
    // data Row 1
    table.cell(align: right,)[#text()[(1, 1)]], 
    table.cell(align: right,)[#text()[(1, 2)]], 
    table.cell(align: right,)[#text()[(1, 3)]], 
    // data Row 2
    table.cell(align: right,)[#text()[(2, 1)]], 
    table.cell(align: right,)[#text()[(2, 2)]], 
    table.cell(align: right,)[#text()[(2, 3)]], 
    // data Row 3
    table.cell(align: right,)[#text()[(3, 1)]], 
    table.cell(align: right,)[#text()[(3, 2)]], 
    table.cell(align: right,)[#text()[(3, 3)]], 
  )
}
"""

      result = pretty_table(
          String,
          matrix;
          backend,
          data_column_widths = [1 => "30pt", 3 => "30pt"]
      )

      @test result == expected

  end


end