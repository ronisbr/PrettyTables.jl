## Description #############################################################################
#
# Typst Back End: Test showing all the available fields.
#
############################################################################################

@testset "All Available Fields" verbose = true begin
    matrix = [(i, j) for i in 1:4, j in 1:4]
    backend = :typst
    @testset "Without Cropping" begin
        expected = """
#{
  // Top bar
  set par(justify: true, spacing: 1em)
  align(top+left,)[Top left string]
  // Open table
  table(
    columns: (auto, auto, 25fr, 75fr, 5em, auto),
    // Table Header
    table.header(
      // table_header Row 1
      table.cell(align: center, colspan: 6,)[
        #text(size: 1.1em, weight: "bold",)[Table Title]
      ],
      // table_header Row 1
      table.cell(align: center, colspan: 6,)[
        #text(size: 1.1em, style: "italic",)[
          Table Subtitle
        ]
      ],
      // column_labels Row 1
      table.cell(align: right,)[
        #text(weight: "bold",)[Row]
      ],
      table.cell(align: right,)[
        #text(weight: "bold",)[Rows]
      ],
      table.cell(align: right, fill: yellow,)[
        #text(fill: blue, weight: "extrabold",)[Col. 1]
      ],
      table.cell(align: center, colspan: 2, fill: blue,)[
        #text(fill: white, weight: "extrabold",)[
          Merged Column
        ]#super[1]
      ],
      table.cell(align: right, fill: red,)[
        #text(fill: rgb(30,30,30),)[Col. 4]
      ],
      // column_labels Row 2
      table.cell(align: right,)[#text(weight: "bold",)[]],
      table.cell(align: right,)[#text(weight: "bold",)[]],
      table.cell(align: right,)[
        #text(weight: "bold",)[1]
      ],
      table.cell(align: right,)[
        #text(weight: "bold",)[2]
      ],
      table.cell(align: right,)[
        #text(weight: "bold",)[3]
      ],
      table.cell(align: right,)[
        #text(weight: "bold",)[4]
      ],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[
      #text(weight: "bold",)[1]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[Row 1]
    ],
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell(align: right,)[#text()[(1, 3)]],
    table.cell(align: right,)[#text()[(1, 4)]],
    // row_group_label Row 2
    table.cell(align: left, colspan: 6,)[
      #text(weight: "bold",)[Row Group]
    ],
    // data Row 2
    table.cell(align: right,)[
      #text(weight: "bold",)[2]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[Row 2]
    ],
    table.cell(align: right,)[#text()[(2, 1)]],
    table.cell(align: right,)[#text()[(2, 2)]#super[2]],
    table.cell(align: right,)[#text()[(2, 3)]],
    table.cell(align: right,)[#text()[(2, 4)]],
    // data Row 3
    table.cell(align: right,)[
      #text(weight: "bold",)[3]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[Row 3]
    ],
    table.cell(align: right,)[#text()[(3, 1)]],
    table.cell(align: right,)[#text()[(3, 2)]],
    table.cell(align: right,)[#text()[(3, 3)]],
    table.cell(align: right,)[#text()[(3, 4)]],
    // data Row 4
    table.cell(align: right,)[
      #text(weight: "bold",)[4]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[Row 4]
    ],
    table.cell(align: right,)[#text()[(4, 1)]],
    table.cell(align: right,)[#text()[(4, 2)]],
    table.cell(align: right,)[#text()[(4, 3)]],
    table.cell(align: right,)[#text()[(4, 4)]],
    // summary_row Row 1
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[
      #text(weight: "bold",)[Summary 1]
    ],
    table.cell(align: right,)[#text()[10]],
    table.cell(align: right,)[#text()[20]],
    table.cell(align: right,)[#text()[30]],
    table.cell(align: right,)[#text()[40]],
    // summary_row Row 2
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[
      #text(weight: "bold",)[Summary 2]
    ],
    table.cell(align: right,)[#text()[20]],
    table.cell(align: right,)[#text()[40]],
    table.cell(align: right,)[#text()[60]],
    table.cell(align: right,)[#text()[80]],
    // table_footer Row 1
    table.cell(align: left, colspan: 6,)[
      #super[1]#text(size: 0.9em,)[Footnote in column label]
    ],
    // table_footer Row 2
    table.cell(align: left, colspan: 6,)[
      #super[2]#text(size: 0.9em,)[Footnote in data]
    ],
    // table_footer Row 1
    table.cell(align: left, colspan: 6,)[
      #text(fill: gray, size: 0.9em, style: "italic",)[
        Source Notes
      ]
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
                    ["fill" => "red", "text-fill" => "rgb(30,30,30)"],
                    ["fill" => "red", "text-fill" => "rgb(30,30,30)"],
                    ["fill" => "red", "text-fill" => "rgb(30,30,30)"],
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
            data_column_widths = ["25fr", "75fr", "5em"],
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            top_left_string = "Top left string",
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
  // Top bar
  set par(justify: true, spacing: 1em)
  align(top+left,)[Top left string]
  v(-1.5em)
  align(top+right,)[2 columns and 2 rows omitted]
  // Open table
  table(
    columns: (auto, auto, auto, auto, auto),
    // Table Header
    table.header(
      // table_header Row 1
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, weight: "bold",)[Table Title]],
      // table_header Row 1
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, style: "italic",)[Table Subtitle]],
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Row]],
      table.cell(align: right,)[#text(weight: "bold",)[Rows]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: center, colspan: 1,)[#text(weight: "bold",)[Merged Column]#super[1]],
      table.cell()[#text()[⋯]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text(weight: "bold",)[1]],
    table.cell(align: right,)[#text(weight: "bold",)[Row 1]],
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell()[#text()[⋯]],
    // row_group_label Row 2
    table.cell(align: left, colspan: 5,)[#text(weight: "bold",)[Row Group]],
    // data Row 2
    table.cell(align: right,)[#text(weight: "bold",)[2]],
    table.cell(align: right,)[#text(weight: "bold",)[Row 2]],
    table.cell(align: right,)[#text()[(2, 1)]],
    table.cell(align: right,)[#text()[(2, 2)]#super[2]],
    table.cell()[#text()[⋯]],
    // continuation_row Row 3
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋱]],
    // summary_row Row 1
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[#text(weight: "bold",)[Summary 1]],
    table.cell(align: right,)[#text()[10]],
    table.cell(align: right,)[#text()[20]],
    table.cell()[#text()[⋯]],
    // summary_row Row 2
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[#text(weight: "bold",)[Summary 2]],
    table.cell(align: right,)[#text()[20]],
    table.cell(align: right,)[#text()[40]],
    table.cell()[#text()[⋯]],
    // table_footer Row 1
    table.cell(align: left, colspan: 5,)[#super[1]#text(size: 0.9em,)[Footnote in column label]],
    // table_footer Row 2
    table.cell(align: left, colspan: 5,)[#super[2]#text(size: 0.9em,)[Footnote in data]],
    // table_footer Row 1
    table.cell(align: left, colspan: 5,)[#text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]],
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
            top_left_string = "Top left string",
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
  // Top bar
  set par(justify: true, spacing: 1em)
  align(top+right,)[2 columns and 2 rows omitted]
  // Open table
  table(
    columns: (auto, auto, auto, auto, auto),
    // Table Header
    table.header(
      // table_header Row 1
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, weight: "bold",)[Table Title]],
      // table_header Row 1
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, style: "italic",)[Table Subtitle]],
      // column_labels Row 1
      table.cell(align: right,)[#text(weight: "bold",)[Row]],
      table.cell(align: right,)[#text(weight: "bold",)[Rows]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: center, colspan: 1,)[#text(weight: "bold",)[Merged Column]#super[1]],
      table.cell()[#text()[⋯]],
    ),
    // Body
    // data Row 1
    table.cell(align: right,)[#text(weight: "bold",)[1]],
    table.cell(align: right,)[#text(weight: "bold",)[Row 1]],
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell()[#text()[⋯]],
    // continuation_row Row 2
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋱]],
    // data Row 4
    table.cell(align: right,)[#text(weight: "bold",)[4]],
    table.cell(align: right,)[#text(weight: "bold",)[Row 4]],
    table.cell(align: right,)[#text()[(4, 1)]],
    table.cell(align: right,)[#text()[(4, 2)]],
    table.cell()[#text()[⋯]],
    // summary_row Row 1
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[#text(weight: "bold",)[Summary 1]],
    table.cell(align: right,)[#text()[10]],
    table.cell(align: right,)[#text()[20]],
    table.cell()[#text()[⋯]],
    // summary_row Row 2
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[#text(weight: "bold",)[Summary 2]],
    table.cell(align: right,)[#text()[20]],
    table.cell(align: right,)[#text()[40]],
    table.cell()[#text()[⋯]],
    // table_footer Row 1
    table.cell(align: left, colspan: 5,)[#super[1]#text(size: 0.9em,)[Footnote in column label]],
    // table_footer Row 2
    table.cell(align: left, colspan: 5,)[#super[2]#text(size: 0.9em,)[Footnote in data]],
    // table_footer Row 1
    table.cell(align: left, colspan: 5,)[#text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]],
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
  set par(justify: true, spacing: 1em)
  align(top+right,)[2 columns and 2 rows omitted]
  table(
    columns: (auto, auto, auto, auto, auto),
    table.header(
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, weight: "bold",)[Table Title]],
      table.cell(align: center, colspan: 5,)[#text(size: 1.1em, style: "italic",)[Table Subtitle]],
      table.cell(align: right,)[#text(weight: "bold",)[Row]],
      table.cell(align: right,)[#text(weight: "bold",)[Rows]],
      table.cell(align: right,)[#text(weight: "bold",)[Col. 1]],
      table.cell(align: center, colspan: 1,)[#text(weight: "bold",)[Merged Column]#super[1]],
      table.cell()[#text()[⋯]],
    ),
    table.cell(align: right,)[#text(weight: "bold",)[1]],
    table.cell(align: right,)[#text(weight: "bold",)[Row 1]],
    table.cell(align: right,)[#text()[(1, 1)]],
    table.cell(align: right,)[#text()[(1, 2)]],
    table.cell()[#text()[⋯]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋮]],
    table.cell()[#text()[⋱]],
    table.cell(align: right,)[#text(weight: "bold",)[4]],
    table.cell(align: right,)[#text(weight: "bold",)[Row 4]],
    table.cell(align: right,)[#text()[(4, 1)]],
    table.cell(align: right,)[#text()[(4, 2)]],
    table.cell()[#text()[⋯]],
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[#text(weight: "bold",)[Summary 1]],
    table.cell(align: right,)[#text()[10]],
    table.cell(align: right,)[#text()[20]],
    table.cell()[#text()[⋯]],
    table.cell(align: right,)[#text(weight: "bold",)[]],
    table.cell(align: right,)[#text(weight: "bold",)[Summary 2]],
    table.cell(align: right,)[#text()[20]],
    table.cell(align: right,)[#text()[40]],
    table.cell()[#text()[⋯]],
    table.cell(align: left, colspan: 5,)[#super[1]#text(size: 0.9em,)[Footnote in column label]],
    table.cell(align: left, colspan: 5,)[#super[2]#text(size: 0.9em,)[Footnote in data]],
    table.cell(align: left, colspan: 5,)[#text(fill: gray, size: 0.9em, style: "italic",)[Source Notes]],
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
  set par(justify: true, spacing: 1em)
  align(top+right,)[2 columns and 2 rows omitted]
  table(
    columns: (auto, auto, auto, auto, auto),
    table.header(
      table.cell(
        align: center,
        colspan: 5,
      )[
        #text(
          size: 1.1em,
          weight: "bold",
        )[
          Table Title
        ]
      ],
      table.cell(
        align: center,
        colspan: 5,
      )[
        #text(
          size: 1.1em,
          style: "italic",
        )[
          Table Subtitle
        ]
      ],
      table.cell(align: right,)[
        #text(weight: "bold",)[
          Row
        ]
      ],
      table.cell(align: right,)[
        #text(weight: "bold",)[
          Rows
        ]
      ],
      table.cell(align: right,)[
        #text(weight: "bold",)[
          Col. 1
        ]
      ],
      table.cell(
        align: center,
        colspan: 1,
      )[
        #text(weight: "bold",)[
          Merged Column
        ]#super[1]
      ],
      table.cell()[
        #text()[
          ⋯
        ]
      ],
    ),
    table.cell(align: right,)[
      #text(weight: "bold",)[
        1
      ]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[
        Row 1
      ]
    ],
    table.cell(align: right,)[
      #text()[
        (1, 1)
      ]
    ],
    table.cell(align: right,)[
      #text()[
        (1, 2)
      ]
    ],
    table.cell()[
      #text()[
        ⋯
      ]
    ],
    table.cell()[
      #text()[
        ⋮
      ]
    ],
    table.cell()[
      #text()[
        ⋮
      ]
    ],
    table.cell()[
      #text()[
        ⋮
      ]
    ],
    table.cell()[
      #text()[
        ⋮
      ]
    ],
    table.cell()[
      #text()[
        ⋱
      ]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[
        4
      ]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[
        Row 4
      ]
    ],
    table.cell(align: right,)[
      #text()[
        (4, 1)
      ]
    ],
    table.cell(align: right,)[
      #text()[
        (4, 2)
      ]
    ],
    table.cell()[
      #text()[
        ⋯
      ]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[
        
      ]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[
        Summary 1
      ]
    ],
    table.cell(align: right,)[
      #text()[
        10
      ]
    ],
    table.cell(align: right,)[
      #text()[
        20
      ]
    ],
    table.cell()[
      #text()[
        ⋯
      ]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[
        
      ]
    ],
    table.cell(align: right,)[
      #text(weight: "bold",)[
        Summary 2
      ]
    ],
    table.cell(align: right,)[
      #text()[
        20
      ]
    ],
    table.cell(align: right,)[
      #text()[
        40
      ]
    ],
    table.cell()[
      #text()[
        ⋯
      ]
    ],
    table.cell(
      align: left,
      colspan: 5,
    )[
      #super[1]#text(size: 0.9em,)[
        Footnote in column label
      ]
    ],
    table.cell(
      align: left,
      colspan: 5,
    )[
      #super[2]#text(size: 0.9em,)[
        Footnote in data
      ]
    ],
    table.cell(
      align: left,
      colspan: 5,
    )[
      #text(
        fill: gray,
        size: 0.9em,
        style: "italic",
      )[
        Source Notes
      ]
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
