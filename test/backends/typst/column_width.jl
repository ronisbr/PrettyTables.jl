## Description #############################################################################
#
# Typst Back End: Test related with the column  widths.
#
############################################################################################
@testset "Column Widths" verbose = true begin

  @testset "Constant value 30pt" begin
      matrix = [(i, j) for i in 1:3, j in 1:3]
      backend=:typst
      expected = """
  #{
    table(
      columns: (30pt, 30pt, 30pt), 
      table.header(
          table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      ), 
      table.cell(align: right,)[#text()[(1, 1)]],table.cell(align: right,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],
      table.cell(align: right,)[#text()[(2, 1)]],table.cell(align: right,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],
      table.cell(align: right,)[#text()[(3, 1)]],table.cell(align: right,)[#text()[(3, 2)]],table.cell(align: right,)[#text()[(3, 3)]],
    )
  }
  """

      result = pretty_table(
          String,
          matrix;
          backend,
          columns_width = "30pt"
      )

      @test result == expected
  end

  @testset "Firs column sith 15pt, `auto` for the rest " begin
      matrix = [(i, j) for i in 1:3, j in 1:3]
      backend=:typst
      expected = """
  #{
    table(
      columns: (30pt, auto, auto), 
      table.header(
          table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      ), 
      table.cell(align: right,)[#text()[(1, 1)]],table.cell(align: right,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],
      table.cell(align: right,)[#text()[(2, 1)]],table.cell(align: right,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],
      table.cell(align: right,)[#text()[(3, 1)]],table.cell(align: right,)[#text()[(3, 2)]],table.cell(align: right,)[#text()[(3, 3)]],
    )
  }
  """

      result = pretty_table(
          String,
          matrix;
          backend,
          columns_width = ["30pt"]
      )

      @test result == expected

      # using pairs

      result = pretty_table(
          String,
          matrix;
          backend,
          columns_width = [1=>"30pt"]
      )
      @test result == expected
  end

  @testset "Just first and last columns set width 30pt " begin
      matrix = [(i, j) for i in 1:3, j in 1:3]
      backend=:typst
      expected = """
  #{
    table(
      columns: (30pt, auto, 30pt), 
      table.header(
          table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],table.cell(align: right,)[#text(weight: "bold",)[Col. 2]],table.cell(align: right,)[#text(weight: "bold",)[Col. 3]],
      ), 
      table.cell(align: right,)[#text()[(1, 1)]],table.cell(align: right,)[#text()[(1, 2)]],table.cell(align: right,)[#text()[(1, 3)]],
      table.cell(align: right,)[#text()[(2, 1)]],table.cell(align: right,)[#text()[(2, 2)]],table.cell(align: right,)[#text()[(2, 3)]],
      table.cell(align: right,)[#text()[(3, 1)]],table.cell(align: right,)[#text()[(3, 2)]],table.cell(align: right,)[#text()[(3, 3)]],
    )
  }
  """

      result = pretty_table(
          String,
          matrix;
          backend,
          columns_width = [1 => "30pt", 3 => "30pt"]
      )

      @test result == expected

  end


end