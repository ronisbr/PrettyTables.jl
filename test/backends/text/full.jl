## Description #############################################################################
#
# Text Back End: Test showing all the available fields.
#
############################################################################################

@testset "All Available Fields" verbose = true begin
    matrix = [(i, j) for i in 1:3, j in 1:3]

    @testset "Without Cropping" verbose = true begin
        @testset "Without Colors" begin
            expected = """
                  Table Title
                Table Subtitle
┌─────┬───────────┬────────┬──────────────────┐
│ Row │      Rows │ Col. 1 │  Merged Column¹  │
│     │           │      1 │       2 │      3 │
├─────┼───────────┼────────┼─────────┼────────┤
│   1 │     Row 1 │ (1, 1) │  (1, 2) │ (1, 3) │
├─────┴───────────┴────────┴─────────┴────────┤
│ Row Group                                   │
├─────┬───────────┬────────┬─────────┬────────┤
│   2 │     Row 2 │ (2, 1) │ (2, 2)² │ (2, 3) │
│   3 │     Row 3 │ (3, 1) │  (3, 2) │ (3, 3) │
├─────┼───────────┼────────┼─────────┼────────┤
│     │ Summary 1 │     10 │      20 │     30 │
│     │ Summary 2 │     20 │      40 │     60 │
└─────┴───────────┴────────┴─────────┴────────┘
¹: Footnote in column label
²: Footnote in data
Source Notes
"""

            result = pretty_table(
                String,
                matrix;
                column_labels = [["Col. $i" for i in 1:3], ["$i" for i in 1:3]],
                footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
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

        @testset "With Colors" begin
            expected = """
\e[1m                  Table Title\e[0m
                Table Subtitle
┌─────┬───────────┬────────┬──────────────────┐
│\e[1m Row \e[0m│\e[1m      Rows \e[0m│\e[1m Col. 1 \e[0m│\e[1;4m  Merged Column¹  \e[0m│
│\e[1m     \e[0m│\e[1m           \e[0m│\e[90m      1 \e[0m│\e[90m       2 \e[0m│\e[90m      3 \e[0m│
├─────┼───────────┼────────┼─────────┼────────┤
│   1 │\e[1m     Row 1 \e[0m│ (1, 1) │  (1, 2) │ (1, 3) │
├─────┴───────────┴────────┴─────────┴────────┤
│\e[1m Row Group                                   \e[0m│
├─────┬───────────┬────────┬─────────┬────────┤
│   2 │\e[1m     Row 2 \e[0m│ (2, 1) │ (2, 2)² │ (2, 3) │
│   3 │\e[1m     Row 3 \e[0m│ (3, 1) │  (3, 2) │ (3, 3) │
├─────┼───────────┼────────┼─────────┼────────┤
│     │\e[1m Summary 1 \e[0m│     10 │      20 │     30 │
│     │\e[1m Summary 2 \e[0m│     20 │      40 │     60 │
└─────┴───────────┴────────┴─────────┴────────┘
¹: Footnote in column label
²: Footnote in data
\e[90mSource Notes\e[0m
"""

            result = pretty_table(
                String,
                matrix;
                color = true,
                column_labels = [["Col. $i" for i in 1:3], ["$i" for i in 1:3]],
                footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
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
    end

    @testset "With Bottom Cropping" verbose = true begin
        @testset "Without Colors" begin
            expected = """
                   Table Title
                 Table Subtitle
┌─────┬───────────┬────────┬────────────────┬───┐
│ Row │      Rows │ Col. 1 │ Merged Column¹ │ ⋯ │
├─────┼───────────┼────────┼────────────────┼───┤
│   1 │     Row 1 │ (1, 1) │         (1, 2) │ ⋯ │
├─────┴───────────┴────────┴────────────────┴───┤
│ Row Group                                     │
├─────┬───────────┬────────┬────────────────┬───┤
│   2 │     Row 2 │ (2, 1) │        (2, 2)² │ ⋯ │
│   ⋮ │         ⋮ │      ⋮ │              ⋮ │ ⋱ │
├─────┼───────────┼────────┼────────────────┼───┤
│     │ Summary 1 │     10 │             20 │ ⋯ │
│     │ Summary 2 │     20 │             40 │ ⋯ │
└─────┴───────────┴────────┴────────────────┴───┘
                       1 column and 1 row omitted
¹: Footnote in column label
²: Footnote in data
Source Notes
"""

            result = pretty_table(
                String,
                matrix;
                footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
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

        @testset "With Colors" begin
            expected = """
\e[1m                   Table Title\e[0m
                 Table Subtitle
┌─────┬───────────┬────────┬────────────────┬───┐
│\e[1m Row \e[0m│\e[1m      Rows \e[0m│\e[1m Col. 1 \e[0m│\e[1;4m Merged Column¹ \e[0m│ ⋯ │
├─────┼───────────┼────────┼────────────────┼───┤
│   1 │\e[1m     Row 1 \e[0m│ (1, 1) │         (1, 2) │ ⋯ │
├─────┴───────────┴────────┴────────────────┴───┤
│\e[1m Row Group                                     \e[0m│
├─────┬───────────┬────────┬────────────────┬───┤
│   2 │\e[1m     Row 2 \e[0m│ (2, 1) │        (2, 2)² │ ⋯ │
│   ⋮ │         ⋮ │      ⋮ │              ⋮ │ ⋱ │
├─────┼───────────┼────────┼────────────────┼───┤
│     │\e[1m Summary 1 \e[0m│     10 │             20 │ ⋯ │
│     │\e[1m Summary 2 \e[0m│     20 │             40 │ ⋯ │
└─────┴───────────┴────────┴────────────────┴───┘
\e[36m                       1 column and 1 row omitted\e[0m
¹: Footnote in column label
²: Footnote in data
\e[90mSource Notes\e[0m
"""

            result = pretty_table(
                String,
                matrix;
                color = true,
                footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
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
    end

    @testset "With Middle Cropping" verbose = true begin
        @testset "Without Colors" begin
            expected = """
                   Table Title
                 Table Subtitle
┌─────┬───────────┬────────┬────────────────┬───┐
│ Row │      Rows │ Col. 1 │ Merged Column¹ │ ⋯ │
├─────┼───────────┼────────┼────────────────┼───┤
│   1 │     Row 1 │ (1, 1) │         (1, 2) │ ⋯ │
│   ⋮ │         ⋮ │      ⋮ │              ⋮ │ ⋱ │
│   3 │     Row 3 │ (3, 1) │         (3, 2) │ ⋯ │
├─────┼───────────┼────────┼────────────────┼───┤
│     │ Summary 1 │     10 │             20 │ ⋯ │
│     │ Summary 2 │     20 │             40 │ ⋯ │
└─────┴───────────┴────────┴────────────────┴───┘
                       1 column and 1 row omitted
¹: Footnote in column label
²: Footnote in data
Source Notes
"""

            result = pretty_table(
                String,
                matrix;
                footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
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
                vertical_crop_mode = :middle
            )

            @test result == expected
        end

        @testset "With Colors" begin
            expected = """
\e[1m                   Table Title\e[0m
                 Table Subtitle
┌─────┬───────────┬────────┬────────────────┬───┐
│\e[1m Row \e[0m│\e[1m      Rows \e[0m│\e[1m Col. 1 \e[0m│\e[1;4m Merged Column¹ \e[0m│ ⋯ │
├─────┼───────────┼────────┼────────────────┼───┤
│   1 │\e[1m     Row 1 \e[0m│ (1, 1) │         (1, 2) │ ⋯ │
│   ⋮ │         ⋮ │      ⋮ │              ⋮ │ ⋱ │
│   3 │\e[1m     Row 3 \e[0m│ (3, 1) │         (3, 2) │ ⋯ │
├─────┼───────────┼────────┼────────────────┼───┤
│     │\e[1m Summary 1 \e[0m│     10 │             20 │ ⋯ │
│     │\e[1m Summary 2 \e[0m│     20 │             40 │ ⋯ │
└─────┴───────────┴────────┴────────────────┴───┘
\e[36m                       1 column and 1 row omitted\e[0m
¹: Footnote in column label
²: Footnote in data
\e[90mSource Notes\e[0m
"""

            result = pretty_table(
                String,
                matrix;
                color = true,
                footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
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
                vertical_crop_mode = :middle
            )

            @test result == expected
        end
    end
end

