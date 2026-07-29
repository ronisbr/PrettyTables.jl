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
        table_format = TextTableFormat(; horizontal_line_at_merged_column_labels = true),
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
        table_format = TextTableFormat(;
            horizontal_line_at_merged_column_labels = true,
            suppress_vertical_lines_at_column_labels = true,
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
        table_format = TextTableFormat(;
            horizontal_line_at_merged_column_labels = true,
            horizontal_lines_at_column_labels = [2],
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
        table_format = TextTableFormat(;
            horizontal_line_at_merged_column_labels  = true,
            horizontal_lines_at_column_labels        = [2],
            suppress_vertical_lines_at_column_labels = true,
        ),
    )

    @test result == expected
end

@testset "Horizontal Lines Do Not Mutate the Table Format" begin
    horizontal_lines = [1, 3]
    table_format = TextTableFormat(; horizontal_lines_at_column_labels = horizontal_lines)

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
        String, [1 2]; column_labels = [["A", "B"], ["C", "D"]], table_format = table_format
    )

    @test result == expected
    @test horizontal_lines == [1, 3]
end

@testset "Line Specifications as a Vector of Indices" verbose = true begin
    # `horizontal_lines_at_data_rows` and `vertical_lines_at_data_columns` accept either a
    # `Symbol` (`:all` / `:none`) or an explicit `Vector{Int}`. The vector branch is what
    # narrows the field type in the back end, and it must select exactly the requested rows
    # and columns.
    matrix = [1 2 3; 4 5 6]

    @testset "Vector of Indices" begin
        expected = """
┌────────┬────────────────┐
│ Col. 1 │ Col. 2  Col. 3 │
├────────┼────────────────┤
│      1 │      2       3 │
├────────┼────────────────┤
│      4 │      5       6 │
└────────┴────────────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TextTableFormat(;
                horizontal_lines_at_data_rows  = [1],
                vertical_lines_at_data_columns = [1],
            ),
        )

        @test result == expected
    end

    @testset "All Lines" begin
        expected = """
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │      3 │
├────────┼────────┼────────┤
│      4 │      5 │      6 │
└────────┴────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            table_format = TextTableFormat(;
                horizontal_lines_at_data_rows  = :all,
                vertical_lines_at_data_columns = :all,
            ),
        )

        @test result == expected
    end
end

@testset "Merged Column Label Line With Leading Columns and Cropping" begin
    # The horizontal line drawn only under the merged column labels must skip the row number
    # and row label columns, and must also span the continuation column when the table is
    # horizontally cropped. Those three fill branches were never executed together.
    matrix = [1 2 3 4; 5 6 7 8]

    expected = """
┌─────┬────┬───────┬───┐
│ Row │    │   X   │ ⋯ │
│     │    │ ──┬── │───┤
│     │    │ a │ b │ ⋯ │
├─────┼────┼───┼───┼───┤
│   1 │ r1 │ 1 │ 2 │ ⋯ │
│   2 │ r2 │ 5 │ 6 │ ⋯ │
└─────┴────┴───┴───┴───┘
       2 columns omitted
"""

    result = pretty_table(
        String,
        matrix;
        column_labels = [
            [MultiColumn(2, "X"), MultiColumn(2, "Y")],
            ["a", "b", "c", "d"],
        ],
        table_format = TextTableFormat(; horizontal_line_at_merged_column_labels = true),
        show_row_number_column = true,
        row_labels = ["r1", "r2"],
        maximum_number_of_columns = 2,
    )

    @test result == expected
end

@testset "Horizontal Lines at All Column Labels" begin
    # `horizontal_lines_at_column_labels = :all` draws a line after every column label row
    # except the last, whose line is governed by
    # `horizontal_line_after_column_labels`. The `:all` branch had no coverage.
    expected = """
┌───┬───┐
│ A │ B │
├───┼───┤
│ a │ b │
├───┼───┤
│ 1 │ 2 │
│ 3 │ 4 │
└───┴───┘
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
        column_labels = [["A", "B"], ["a", "b"]],
        table_format = TextTableFormat(; horizontal_lines_at_column_labels = :all),
    )

    @test result == expected
end
