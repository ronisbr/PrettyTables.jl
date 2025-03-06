## Description #############################################################################
#
# General tests.
#
############################################################################################

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
