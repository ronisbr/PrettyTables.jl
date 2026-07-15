## Description #############################################################################
#
# Text Back End: Test of horizontal lines.
#
############################################################################################

@testset "Horizontal Lines at Merged Column Labels" verbose = true begin
    matrix = [(i, j) for i in 1:4, j in 1:4]
    column_labels = [
        [MultiColumn(2, "Merged #1", :c), "Col. 3", "Col. 4"],
        ["Col. 1", "Col. 2", MultiColumn(2, "Merged #2", :c)],
        ["Col. 1", MultiColumn(3, "Merged #2", :c)],
        ["Col. 1", "Col. 2", "Col. 3", "Col. 4"],
    ]

    expected = """
┌─────────────────┬────────┬────────┐
│    Merged #1    │ Col. 3 │ Col. 4 │
│ ───────┬─────── │        │        │
│ Col. 1 │ Col. 2 │    Merged #2    │
│        │        │ ─────────────── │
│ Col. 1 │        Merged #2         │
│        │ ───────┬────────┬─────── │
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels = column_labels,
        table_format = TextTableFormat(
            horizontal_line_at_merged_column_labels = true
        ),
    )

    @test result == expected

    expected = """
┌───────────────────────────────────┐
│    Merged #1      Col. 3   Col. 4 │
│ ───────────────                   │
│ Col. 1   Col. 2      Merged #2    │
│                   ─────────────── │
│ Col. 1          Merged #2         │
│          ──────────────────────── │
│ Col. 1   Col. 2   Col. 3   Col. 4 │
├────────┬────────┬────────┬────────┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels = column_labels,
        table_format = TextTableFormat(
            horizontal_line_at_merged_column_labels = true,
            suppress_vertical_lines_at_column_labels   = true,
        ),
    )

    @test result == expected

    expected = """
┌─────────────────┬────────┬────────┐
│    Merged #1    │ Col. 3 │ Col. 4 │
│ ───────┬─────── │        │        │
│ Col. 1 │ Col. 2 │    Merged #2    │
├────────┼────────┴─────────────────┤
│ Col. 1 │        Merged #2         │
│        │ ───────┬────────┬─────── │
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels = column_labels,
        table_format = TextTableFormat(
            horizontal_line_at_merged_column_labels = true,
            horizontal_lines_at_column_labels          = [2],
        ),
    )

    @test result == expected

    expected = """
┌───────────────────────────────────┐
│    Merged #1      Col. 3   Col. 4 │
│ ───────────────                   │
│ Col. 1   Col. 2      Merged #2    │
├───────────────────────────────────┤
│ Col. 1          Merged #2         │
│          ──────────────────────── │
│ Col. 1   Col. 2   Col. 3   Col. 4 │
├────────┬────────┬────────┬────────┤
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels = column_labels,
        table_format = TextTableFormat(
            horizontal_line_at_merged_column_labels = true,
            horizontal_lines_at_column_labels          = [2],
            suppress_vertical_lines_at_column_labels   = true,
        ),
    )

    @test result == expected
end

@testset "Horizontal Lines Do Not Mutate the Table Format" begin
    horizontal_lines = [1, 3]
    table_format = TextTableFormat(
        horizontal_lines_at_column_labels = horizontal_lines
    )

    expected = """
┌───┬───┐
│ A │ B │
├───┼───┤
│ C │ D │
├───┼───┤
│ 1 │ 2 │
└───┴───┘
"""

    result = pretty_table(
        String,
        [1 2];
        column_labels = [["A", "B"], ["C", "D"]],
        table_format = table_format,
    )

    @test result == expected
    @test horizontal_lines == [1, 3]
end
