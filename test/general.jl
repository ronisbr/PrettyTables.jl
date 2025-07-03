## Description #############################################################################
#
# General tests.
#
############################################################################################

@testset "Automatic Column Label Merge" begin
    matrix = [1 2 3 4 5; 6 7 8 9 10]
    column_labels = [
        MultiColumn(2, "Merged Col. 1"),
        MultiColumn(2, "Merged Col. 2", :l),
        EmptyCells(1)
    ]

    expected = """
┌───────────────────────────────────┬───────────────────────────────────┬─────────────────┐
│           Merged Col. 1           │ Merged Col. 2                     │                 │
├─────────────────┬─────────────────┼─────────────────┬─────────────────┼─────────────────┤
│               1 │               2 │               3 │               4 │               5 │
│               6 │               7 │               8 │               9 │              10 │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels,
        fixed_data_column_widths = 15
    )
    @test result == expected
end

@testset "Merge Column Label Cells" begin
    matrix = [1 2 3; 4 5 6]
    column_labels = [MultiColumn(2, "Test"), "B", "C"]

    expected = """
┌──────────────────────────────┬───┬───┐
│ MultiColumn(2, \\"Test\\", :c) │ B │ C │
├──────────────────────────────┼───┼───┤
│                            1 │ 2 │ 3 │
│                            4 │ 5 │ 6 │
└──────────────────────────────┴───┴───┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels,
        merge_column_label_cells = :something
    )
    @test result == expected

    @test_throws ArgumentError pretty_table(
        String,
        matrix;
        column_labels
    )
end

@testset "Show Only First Column Label" begin
    matrix = [1 2 3; 4 5 6]
    column_labels = [["A", "B", "C"], ["D", "E", "F"]]

    expected = """
┌───┬───┬───┐
│ A │ B │ C │
├───┼───┼───┤
│ 1 │ 2 │ 3 │
│ 4 │ 5 │ 6 │
└───┴───┴───┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels,
        show_first_column_label_only = true
    )
    @test result == expected
end
