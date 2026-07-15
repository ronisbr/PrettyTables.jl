## Description #############################################################################
#
# Tests related with the column widths.
#
############################################################################################

@testset "Fixed Data Column Widths" begin
    matrix = ["A = ($i, $j)\nB = ($i, $j)" for i in 1:3, j in 1:5]

    expected = """
┌────────────┬───────┬─────────┬───────────┬─────────────────┐
│     Col. 1 │ Col.… │  Col. 3 │    Col. 4 │          Col. 5 │
├────────────┼───────┼─────────┼───────────┼─────────────────┤
│ A = (1, 1) │ A = … │ A = (1… │ A = (1, … │      A = (1, 5) │
│ B = (1, 1) │ B = … │ B = (1… │ B = (1, … │      B = (1, 5) │
├────────────┼───────┼─────────┼───────────┼─────────────────┤
│ A = (2, 1) │ A = … │ A = (2… │ A = (2, … │      A = (2, 5) │
│ B = (2, 1) │ B = … │ B = (2… │ B = (2, … │      B = (2, 5) │
├────────────┼───────┼─────────┼───────────┼─────────────────┤
│ A = (3, 1) │ A = … │ A = (3… │ A = (3, … │      A = (3, 5) │
│ B = (3, 1) │ B = … │ B = (3… │ B = (3, … │      B = (3, 5) │
└────────────┴───────┴─────────┴───────────┴─────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        line_breaks = true,
        fixed_data_column_widths = [0, 5, 7, 9, 15],
        table_format = TextTableFormat(; @text__all_horizontal_lines),
    )

    @test result == expected
end

@testset "Minimum Data Column Widths" begin
    matrix = [(i, j) for i in 1:3, j in 1:5]

    expected = """
┌────────┬────────┬────────────┬──────────────────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3     │        Col. 4        │ Col. 5 │
├────────┼────────┼────────────┼──────────────────────┼────────┤
│ (1, 1) │ (1, 2) │ (1, 3)     │        (1, 4)        │ (1, 5) │
│ (2, 1) │ (2, 2) │ (2, 3)     │        (2, 4)        │ (2, 5) │
│ (3, 1) │ (3, 2) │ (3, 3)     │        (3, 4)        │ (3, 5) │
└────────┴────────┴────────────┴──────────────────────┴────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment = [:r, :c, :l, :c, :l],
        minimum_data_column_widths = [0, -1, 10, 20, 3],
    )

    @test result == expected
end

@testset "Maximum Data Column Widths" begin
    matrix = ["A = ($i, $j)\nB = ($i, $j)" for i in 1:3, j in 1:5]

    expected = """
┌────────────┬───────┬─────────┬───────────┬────────────┐
│     Col. 1 │ Col.… │  Col. 3 │    Col. 4 │     Col. 5 │
├────────────┼───────┼─────────┼───────────┼────────────┤
│ A = (1, 1) │ A = … │ A = (1… │ A = (1, … │ A = (1, 5) │
│ B = (1, 1) │ B = … │ B = (1… │ B = (1, … │ B = (1, 5) │
├────────────┼───────┼─────────┼───────────┼────────────┤
│ A = (2, 1) │ A = … │ A = (2… │ A = (2, … │ A = (2, 5) │
│ B = (2, 1) │ B = … │ B = (2… │ B = (2, … │ B = (2, 5) │
├────────────┼───────┼─────────┼───────────┼────────────┤
│ A = (3, 1) │ A = … │ A = (3… │ A = (3, … │ A = (3, 5) │
│ B = (3, 1) │ B = … │ B = (3… │ B = (3, … │ B = (3, 5) │
└────────────┴───────┴─────────┴───────────┴────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        line_breaks = true,
        maximum_data_column_widths = [0, 5, 7, 9, 10],
        table_format = TextTableFormat(; @text__all_horizontal_lines),
    )

    @test result == expected
end

@testset "Summary Widths Without Data Rows" begin
    matrix = Matrix{Int}(undef, 0, 2)

    expected = """
┌───────────┬──────────────┬────────────────────┐
│           │            A │                  B │
├───────────┼──────────────┼────────────────────┤
│ Summary 1 │ summary-wide │ even-wider-summary │
└───────────┴──────────────┴────────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        column_labels = ["A", "B"],
        summary_rows = [(data, j) -> j == 1 ? "summary-wide" : "even-wider-summary"],
    )

    @test result == expected
    @test all(textwidth(line) == 49 for line in split(chomp(result), '\n'))

    expected_without_column_labels = """
┌───────────┬──────────────┬────────────────────┐
│ Summary 1 │ summary-wide │ even-wider-summary │
└───────────┴──────────────┴────────────────────┘
"""

    result_without_column_labels = pretty_table(
        String,
        matrix;
        column_labels = ["A", "B"],
        show_column_labels = false,
        summary_rows = [(data, j) -> j == 1 ? "summary-wide" : "even-wider-summary"],
    )

    @test result_without_column_labels == expected_without_column_labels
end
