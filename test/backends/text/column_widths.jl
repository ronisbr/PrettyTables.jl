## Description #############################################################################
#
# Tests related with the column widths.
#
############################################################################################

@testset "Fit Multiline Cell in Maximum Width" begin
    fit_cell = PrettyTables._text__fit_cell_in_maximum_cell_width

    @test fit_cell("", 3, true) == ""
    @test fit_cell("abcd\n", 3, true) == "ab…\n"
    @test fit_cell("\nabc", 3, true) == "\nabc"
    @test fit_cell("ab\n\ncdef", 3, true) == "ab\n\ncd…"

    mixed = "\e[31mαβγδ\e[0m\nok\nabcdef"
    @test fit_cell(mixed, 3, true) == "\e[31mαβ…\nok\nab…"

    many_lines = join(fill("abcdef", 1_000), '\n')
    @test fit_cell(many_lines, 3, true) == join(fill("ab…", 1_000), '\n')
    @test fit_cell("unchanged\nlines", 0, true) == "unchanged\nlines"
end

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

@testset "Fixed Data Column Widths Limited by the Display" verbose = true begin
    # When `fixed_data_column_widths` is set, the back end uses those widths, instead of a
    # rough estimate, to decide how many columns fit in the display. That estimation loop was
    # never executed, since no test combined a fixed width with a constrained display.
    matrix = [1 2 3; 4 5 6]

    render(width) = begin
        io = IOContext(IOBuffer(), :displaysize => (30, width), :color => false)
        pretty_table(io, matrix; fixed_data_column_widths = [6, 6, 6])
        String(take!(io.io))
    end

    @testset "Every Column Fits" begin
        expected = """
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │      3 │
│      4 │      5 │      6 │
└────────┴────────┴────────┘
"""

        @test render(40) == expected
    end

    @testset "One Column Omitted" begin
        expected = """
┌────────┬──────────
│ Col. 1 │ Col. 2  ⋯
├────────┼──────────
│      1 │      2  ⋯
│      4 │      5  ⋯
└────────┴──────────
    1 column omitted
"""

        @test render(20) == expected
    end

    @testset "Two Columns Omitted" begin
        expected = """
┌────────┬────
│ Col. 1 │ C ⋯
├────────┼────
│      1 │   ⋯
│      4 │   ⋯
└────────┴────
2 columns omitted
"""

        @test render(14) == expected
    end
end
