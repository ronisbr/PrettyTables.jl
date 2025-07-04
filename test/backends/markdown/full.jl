## Description #############################################################################
#
# Markdown Back End: Test showing all the available fields.
#
############################################################################################

@testset "All Available Fields" verbose = true begin
    matrix = [(i, j) for i in 1:3, j in 1:3]

    @testset "Without Cropping" begin
        expected = """
# Table Title

## Table Subtitle

|       **Row** |      **Rows** | **Col. 1**<br>`1` | **Merged Column[^1]**<br>`2` | ─────── |
|--------------:|--------------:|------------------:|-----------------------------:|--------:|
|             1 |     **Row 1** |            (1, 1) |                       (1, 2) |  (1, 3) |
| **Row Group** | ───────────── | ───────────────── | ──────────────────────────── | ─────── |
|             2 |     **Row 2** |            (2, 1) |                   (2, 2)[^2] |  (2, 3) |
|             3 |     **Row 3** |            (3, 1) |                       (3, 2) |  (3, 3) |
| ───────────── | ───────────── | ───────────────── | ──────────────────────────── | ─────── |
|               | **Summary 1** |                10 |                           20 |      30 |
|               | **Summary 2** |                20 |                           40 |      60 |

[^1]: Footnote in column label
[^2]: Footnote in data

Source Notes
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
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

        expected = """
# Table Title

## Table Subtitle

|      **Rows** | **Col. 1**<br>`1` | **Merged Column[^1]**<br>`2` | ─────── |
|--------------:|------------------:|-----------------------------:|--------:|
|     **Row 1** |            (1, 1) |                       (1, 2) |  (1, 3) |
| **Row Group** | ───────────────── | ──────────────────────────── | ─────── |
|     **Row 2** |            (2, 1) |                   (2, 2)[^2] |  (2, 3) |
|     **Row 3** |            (3, 1) |                       (3, 2) |  (3, 3) |
| ───────────── | ───────────────── | ──────────────────────────── | ─────── |
| **Summary 1** |                10 |                           20 |      30 |
| **Summary 2** |                20 |                           40 |      60 |

[^1]: Footnote in column label
[^2]: Footnote in data

Source Notes
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            column_labels = [["Col. $i" for i in 1:3], ["$i" for i in 1:3]],
            footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
            merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = false,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
        )

        @test result == expected
    end

    @testset "With Bottom Cropping" begin
        expected = """
# Table Title

## Table Subtitle

|       **Row** |      **Rows** | **Col. 1** | **Merged Column[^1]** | ⋯ |
|--------------:|--------------:|-----------:|----------------------:|---|
|             1 |     **Row 1** |     (1, 1) |                (1, 2) | ⋯ |
| **Row Group** | ───────────── | ────────── | ───────────────────── | ⋯ |
|             2 |     **Row 2** |     (2, 1) |            (2, 2)[^2] | ⋯ |
|             ⋮ |             ⋮ |          ⋮ |                     ⋮ | ⋱ |
| ───────────── | ───────────── | ────────── | ───────────────────── | ─ |
|               | **Summary 1** |         10 |                    20 | ⋯ |
|               | **Summary 2** |         20 |                    40 | ⋯ |

*1 column and 1 row omitted*

[^1]: Footnote in column label
[^2]: Footnote in data

Source Notes
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
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

    @testset "With Middle Cropping" begin
        expected = """
# Table Title

## Table Subtitle

|       **Row** |      **Rows** | **Col. 1** | **Merged Column[^1]** | ⋯ |
|--------------:|--------------:|-----------:|----------------------:|---|
|             1 |     **Row 1** |     (1, 1) |                (1, 2) | ⋯ |
|             ⋮ |             ⋮ |          ⋮ |                     ⋮ | ⋱ |
|             3 |     **Row 3** |     (3, 1) |                (3, 2) | ⋯ |
| ───────────── | ───────────── | ────────── | ───────────────────── | ─ |
|               | **Summary 1** |         10 |                    20 | ⋯ |
|               | **Summary 2** |         20 |                    40 | ⋯ |

*1 column and 1 row omitted*

[^1]: Footnote in column label
[^2]: Footnote in data

Source Notes
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
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
