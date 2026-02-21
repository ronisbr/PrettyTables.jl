## Description #############################################################################
#
# Typst Back End: Test showing all the available fields.
#
############################################################################################

@testset "All Available Fields" verbose = true begin
    matrix  = [(i, j) for i in 1:4, j in 1:4]
    backend = :typst

    @testset "Without Cropping" begin
        expected = """
#{
  table(
    align: (right, right, right, right, right, right,),
    columns: (auto, auto, 25fr, 75fr, 5em, auto,),
    // == Table Header ===========================
    table.header(
      // -- Table Header: Title ------------------
      table.cell(align: center, colspan: 6,)[
        #text(size: 1.1em, weight: "bold",)[Table Title]
      ],
      // -- Table Header: Subtitle ---------------
      table.cell(align: center, colspan: 6,)[
        #text(size: 1.1em, style: "italic",)[Table Subtitle]
      ],
      // -- Column Labels: Row 1 -----------------
      [#text(weight: "bold",)[Row]],
      [#text(weight: "bold",)[Rows]],
      table.cell(fill: yellow,)[
        #text(fill: blue, weight: "extrabold",)[Col. 1]
      ],
      table.cell(colspan: 2, fill: blue,)[
        #text(fill: white, weight: "extrabold",)[Merged Column]#super[1]
      ],
      table.cell(fill: red,)[
        #text(fill: rgb(30, 30, 30),)[Col. 4]
      ],
      // -- Column Labels: Row 2 -----------------
      [],
      [],
      [#text(weight: "bold",)[1]],
      [#text(weight: "bold",)[2]],
      [#text(weight: "bold",)[3]],
      [#text(weight: "bold",)[4]],
    ),
    // == Table Body =============================
    // -- Data: Row 1 ----------------------------
    [#text(weight: "bold",)[1]],
    [#text(weight: "bold",)[Row 1]],
    [(1, 1)],
    [(1, 2)],
    [(1, 3)],
    [(1, 4)],
    // -- Row Group Label: Row 2 -----------------
    table.cell(align: left, colspan: 6,)[
      #text(weight: "bold",)[Row Group]
    ],
    // -- Data: Row 2 ----------------------------
    [#text(weight: "bold",)[2]],
    [#text(weight: "bold",)[Row 2]],
    [(2, 1)],
    [(2, 2)#super[2]],
    [(2, 3)],
    [(2, 4)],
    // -- Data: Row 3 ----------------------------
    [#text(weight: "bold",)[3]],
    [#text(weight: "bold",)[Row 3]],
    [(3, 1)],
    [(3, 2)],
    [(3, 3)],
    [(3, 4)],
    // -- Data: Row 4 ----------------------------
    [#text(weight: "bold",)[4]],
    [#text(weight: "bold",)[Row 4]],
    [(4, 1)],
    [(4, 2)],
    [(4, 3)],
    [(4, 4)],
    // -- Summary Row: Row 1 ---------------------
    [],
    [#text(weight: "bold",)[Summary 1]],
    [10],
    [20],
    [30],
    [40],
    // -- Summary Row: Row 2 ---------------------
    [],
    [#text(weight: "bold",)[Summary 2]],
    [20],
    [40],
    [60],
    [80],
    // -- Table Footer: Footnote 1 ---------------
    table.cell(align: left, colspan: 6, inset: (left: 0pt), stroke: none,)[
      #super[1]#text(size: 0.9em,)[Footnote in column label]
    ],
    // -- Table Footer: Footnote 2 ---------------
    table.cell(align: left, colspan: 6, inset: (left: 0pt), stroke: none,)[
      #super[2]#text(size: 0.9em,)[Footnote in data]
    ],
    // -- Table Footer: Source Notes -------------
    table.cell(align: left, colspan: 6, inset: (left: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]
    ],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            style = TypstTableStyle(;
                first_line_column_label = [
                    [
                        "fill" => "yellow",
                        "text-fill" => "blue",
                        "text-weight" => "extrabold",
                    ],
                    [
                        "fill" => "blue",
                        "text-fill" => "white",
                        "text-weight" => "extrabold",
                    ],
                    ["fill" => "red", "text-fill" => "rgb(30, 30, 30)"],
                    ["fill" => "red", "text-fill" => "rgb(30, 30, 30)"],
                    ["fill" => "red", "text-fill" => "rgb(30, 30, 30)"],
                ],
            ),
            column_labels = [["Col. $i" for i in 1:4], ["$i" for i in 1:4]],
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
            merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            data_column_widths = ["25fr", "75fr", "5em", "auto"],
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
            subtitle = "Table Subtitle",
            wrap_column = 50,
        )

        @test result == expected
    end

    @testset "With Bottom Cropping" begin
        expected = """
#{
  table(
    align: (right, right, right, right, center,),
    columns: (auto, auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Table Header: Title ------------------------------------------------------------
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, weight: "bold",)[Table Title]],
      // -- Table Header: Subtitle ---------------------------------------------------------
      table.cell(align: center, colspan: 5,)[
        #text(size: 1.1em, style: "italic",)[Table Subtitle]
      ],
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Row]],
      [#text(weight: "bold",)[Rows]],
      [#text(weight: "bold",)[Col. 1]],
      table.cell(colspan: 1,)[#text(weight: "bold",)[Merged Column]#super[1]],
      [⋯],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold",)[1]],
    [#text(weight: "bold",)[Row 1]],
    [(1, 1)],
    [(1, 2)],
    [⋯],
    // -- Row Group Label: Row 2 -----------------------------------------------------------
    table.cell(align: left, colspan: 5,)[#text(weight: "bold",)[Row Group]],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [#text(weight: "bold",)[2]],
    [#text(weight: "bold",)[Row 2]],
    [(2, 1)],
    [(2, 2)#super[2]],
    [⋯],
    // -- Continuation Row -----------------------------------------------------------------
    [⋮],
    [⋮],
    [⋮],
    [⋮],
    [⋱],
    // -- Summary Row: Row 1 ---------------------------------------------------------------
    [],
    [#text(weight: "bold",)[Summary 1]],
    [10],
    [20],
    [⋯],
    // -- Summary Row: Row 2 ---------------------------------------------------------------
    [],
    [#text(weight: "bold",)[Summary 2]],
    [20],
    [40],
    [⋯],
    // -- Omitted Cell Summary -------------------------------------------------------------
    table.cell(align: right, colspan: 5, inset: (right: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[2 columns and 2 rows omitted]
    ],
    // -- Table Footer: Footnote 1 ---------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[1]#text(size: 0.9em,)[Footnote in column label]
    ],
    // -- Table Footer: Footnote 2 ---------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[2]#text(size: 0.9em,)[Footnote in data]
    ],
    // -- Table Footer: Source Notes -------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]
    ],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
        )

        @test result == expected
    end

    @testset "With Middle Cropping" begin
        expected = """
#{
  table(
    align: (right, right, right, right, center,),
    columns: (auto, auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Table Header: Title ------------------------------------------------------------
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, weight: "bold",)[Table Title]],
      // -- Table Header: Subtitle ---------------------------------------------------------
      table.cell(align: center, colspan: 5,)[
        #text(size: 1.1em, style: "italic",)[Table Subtitle]
      ],
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Row]],
      [#text(weight: "bold",)[Rows]],
      [#text(weight: "bold",)[Col. 1]],
      table.cell(colspan: 1,)[#text(weight: "bold",)[Merged Column]#super[1]],
      [⋯],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold",)[1]],
    [#text(weight: "bold",)[Row 1]],
    [(1, 1)],
    [(1, 2)],
    [⋯],
    // -- Continuation Row -----------------------------------------------------------------
    [⋮],
    [⋮],
    [⋮],
    [⋮],
    [⋱],
    // -- Data: Row 4 ----------------------------------------------------------------------
    [#text(weight: "bold",)[4]],
    [#text(weight: "bold",)[Row 4]],
    [(4, 1)],
    [(4, 2)],
    [⋯],
    // -- Summary Row: Row 1 ---------------------------------------------------------------
    [],
    [#text(weight: "bold",)[Summary 1]],
    [10],
    [20],
    [⋯],
    // -- Summary Row: Row 2 ---------------------------------------------------------------
    [],
    [#text(weight: "bold",)[Summary 2]],
    [20],
    [40],
    [⋯],
    // -- Omitted Cell Summary -------------------------------------------------------------
    table.cell(align: right, colspan: 5, inset: (right: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[2 columns and 2 rows omitted]
    ],
    // -- Table Footer: Footnote 1 ---------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[1]#text(size: 0.9em,)[Footnote in column label]
    ],
    // -- Table Footer: Footnote 2 ---------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[2]#text(size: 0.9em,)[Footnote in data]
    ],
    // -- Table Footer: Source Notes -------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]
    ],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
            vertical_crop_mode = :middle,
        )

        @test result == expected
    end
    @testset "Without Annotation" begin
        expected = """
#{
  table(
    align: (right, right, right, right, center,),
    columns: (auto, auto, auto, auto, auto,),
    table.header(
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, weight: "bold",)[Table Title]],
      table.cell(align: center, colspan: 5,)[
        #text(size: 1.1em, style: "italic",)[Table Subtitle]
      ],
      [#text(weight: "bold",)[Row]],
      [#text(weight: "bold",)[Rows]],
      [#text(weight: "bold",)[Col. 1]],
      table.cell(colspan: 1,)[#text(weight: "bold",)[Merged Column]#super[1]],
      [⋯],
    ),
    [#text(weight: "bold",)[1]],
    [#text(weight: "bold",)[Row 1]],
    [(1, 1)],
    [(1, 2)],
    [⋯],
    [⋮],
    [⋮],
    [⋮],
    [⋮],
    [⋱],
    [#text(weight: "bold",)[4]],
    [#text(weight: "bold",)[Row 4]],
    [(4, 1)],
    [(4, 2)],
    [⋯],
    [],
    [#text(weight: "bold",)[Summary 1]],
    [10],
    [20],
    [⋯],
    [],
    [#text(weight: "bold",)[Summary 2]],
    [20],
    [40],
    [⋯],
    table.cell(align: right, colspan: 5, inset: (right: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[2 columns and 2 rows omitted]
    ],
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[1]#text(size: 0.9em,)[Footnote in column label]
    ],
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[2]#text(size: 0.9em,)[Footnote in data]
    ],
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]
    ],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
            vertical_crop_mode = :middle,
            annotate = false,
        )

        @test result == expected
    end
    @testset "Wrap Column Tests" begin
        expected = """
#{
  table(
    align: (right, right, right, right, center,),
    columns: (auto, auto, auto, auto, auto,),
    table.header(
      table.cell(align: center, colspan: 5,)[
        #text(size: 1.1em, weight: "bold",)[Table Title]
      ],
      table.cell(align: center, colspan: 5,)[
        #text(size: 1.1em, style: "italic",)[Table Subtitle]
      ],
      [
        #text(weight: "bold",)[Row]
      ],
      [
        #text(weight: "bold",)[Rows]
      ],
      [
        #text(weight: "bold",)[Col. 1]
      ],
      table.cell(colspan: 1,)[
        #text(weight: "bold",)[Merged Column]#super[1]
      ],
      [
        ⋯
      ],
    ),
    [
      #text(weight: "bold",)[1]
    ],
    [
      #text(weight: "bold",)[Row 1]
    ],
    [
      (1, 1)
    ],
    [
      (1, 2)
    ],
    [
      ⋯
    ],
    [
      ⋮
    ],
    [
      ⋮
    ],
    [
      ⋮
    ],
    [
      ⋮
    ],
    [
      ⋱
    ],
    [
      #text(weight: "bold",)[4]
    ],
    [
      #text(weight: "bold",)[Row 4]
    ],
    [
      (4, 1)
    ],
    [
      (4, 2)
    ],
    [
      ⋯
    ],
    [
      
    ],
    [
      #text(weight: "bold",)[Summary 1]
    ],
    [
      10
    ],
    [
      20
    ],
    [
      ⋯
    ],
    [
      
    ],
    [
      #text(weight: "bold",)[Summary 2]
    ],
    [
      20
    ],
    [
      40
    ],
    [
      ⋯
    ],
    table.cell(align: right, colspan: 5, inset: (right: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[2 columns and 2 rows omitted]
    ],
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[1]#text(size: 0.9em,)[Footnote in column label]
    ],
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #super[2]#text(size: 0.9em,)[Footnote in data]
    ],
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]
    ],
  )
}
"""

        result = pretty_table(
            String,
            matrix;
            backend,
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
            vertical_crop_mode = :middle,
            wrap_column = 1, # any attribute will need a new line
            annotate = false,
        )

        @test result == expected
    end
end
