## Description #############################################################################
#
# Text Back End: Issues.
#
############################################################################################

@testset "Issues" verbose = true begin
    @testset "Do not Escape Quotes" begin
        matrix = ["'" "\""]

        expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
├────────┼────────┤
│      ' │      " │
└────────┴────────┘
"""

        result = pretty_table(String, matrix)

        @test result == expected
    end

    @testset "Handle Correctly Empty Tables" begin
        expected = """
Title
Notes
"""

        result = pretty_table(String, []; title = "Title", source_notes = "Notes")
        @test result == expected
    end

    @testset "Issue #270" begin
        matrix = [(i, j) for i in 1:500, j in 1:500]

        expected = """
┌────────┬────────┬────────┬────────┬────────┬────
│ (1, 1) │ (1, 2) │ (1, 3) │ (1, 4) │ (1, 5) │ ( ⋯
│ (2, 1) │ (2, 2) │ (2, 3) │ (2, 4) │ (2, 5) │ ( ⋯
│ (3, 1) │ (3, 2) │ (3, 3) │ (3, 4) │ (3, 5) │ ( ⋯
│ (4, 1) │ (4, 2) │ (4, 3) │ (4, 4) │ (4, 5) │ ( ⋯
│ (5, 1) │ (5, 2) │ (5, 3) │ (5, 4) │ (5, 5) │ ( ⋯
│ (6, 1) │ (6, 2) │ (6, 3) │ (6, 4) │ (6, 5) │ ( ⋯
│ (7, 1) │ (7, 2) │ (7, 3) │ (7, 4) │ (7, 5) │ ( ⋯
│ (8, 1) │ (8, 2) │ (8, 3) │ (8, 4) │ (8, 5) │ ( ⋯
│ (9, 1) │ (9, 2) │ (9, 3) │ (9, 4) │ (9, 5) │ ( ⋯
│      ⋮ │      ⋮ │      ⋮ │      ⋮ │      ⋮ │   ⋱
└────────┴────────┴────────┴────────┴────────┴────
                  495 columns and 491 rows omitted
"""

        result = pretty_table(
            String, matrix; display_size = (15, 50), show_column_labels = false
        )

        @test result == expected

        expected = """
┌──────────┬──────────┬──────────┬──────────┬─────
│   (1, 1) │   (1, 2) │   (1, 3) │   (1, 4) │    ⋯
│   (2, 1) │   (2, 2) │   (2, 3) │   (2, 4) │    ⋯
│   (3, 1) │   (3, 2) │   (3, 3) │   (3, 4) │    ⋯
│   (4, 1) │   (4, 2) │   (4, 3) │   (4, 4) │    ⋯
│   (5, 1) │   (5, 2) │   (5, 3) │   (5, 4) │    ⋯
│        ⋮ │        ⋮ │        ⋮ │        ⋮ │    ⋱
│ (497, 1) │ (497, 2) │ (497, 3) │ (497, 4) │ (4 ⋯
│ (498, 1) │ (498, 2) │ (498, 3) │ (498, 4) │ (4 ⋯
│ (499, 1) │ (499, 2) │ (499, 3) │ (499, 4) │ (4 ⋯
│ (500, 1) │ (500, 2) │ (500, 3) │ (500, 4) │ (5 ⋯
└──────────┴──────────┴──────────┴──────────┴─────
                  496 columns and 491 rows omitted
"""

        result = pretty_table(
            String,
            matrix;
            display_size = (15, 50),
            show_column_labels = false,
            vertical_crop_mode = :middle,
        )

        @test result == expected
    end

    @testset "Cell Width Computation with Merged Cells" begin
        matrix = ones(4, 3)

        column_labels = [
            ["Var. Value", MultiColumn(2, "Failure State", :c)],
            ["", "Failure Active", "Failure Latched"],
        ]

        expected = """
┌────────────┬──────────────────────────────────┐
│ Var. Value │          Failure State           │
│            │ ───────────────┬──────────────── │
│            │ Failure Active │ Failure Latched │
├────────────┼────────────────┼─────────────────┤
│        1.0 │            1.0 │             1.0 │
│        1.0 │            1.0 │             1.0 │
│        1.0 │            1.0 │             1.0 │
│        1.0 │            1.0 │             1.0 │
└────────────┴────────────────┴─────────────────┘
"""

        result = pretty_table(
            String,
            matrix;
            column_labels,
            table_format = TextTableFormat(;
                horizontal_line_at_merged_column_labels = true
            ),
        )

        @test result == expected
    end
end

@testset "Overwrite Display" begin
    # `overwrite_display` prefixes the table with one "move up and erase line" sequence per
    # line of output, so that a previously printed table is replaced in place.
    io = IOContext(IOBuffer(), :color => false)

    pretty_table(io, [1 2]; overwrite_display = true)

    result = String(take!(io.io))

    expected =
        "\e[1F\e[2K"^5 *
        "┌────────┬────────┐\n" *
        "│ Col. 1 │ Col. 2 │\n" *
        "├────────┼────────┤\n" *
        "│      1 │      2 │\n" *
        "└────────┴────────┘\n"

    @test result == expected
end

@testset "Merged Column Labels With Hidden Column Labels" begin
    # If the column labels are hidden, a merged column label specification can never be
    # rendered. Hence, it must be ignored instead of crashing the column width computation
    # or changing the border junctions.
    expected = """
┌───┬───┬───┐
│ 1 │ 2 │ 3 │
│ 4 │ 5 │ 6 │
│ 7 │ 8 │ 9 │
└───┴───┴───┘
"""

    result = pretty_table(
        String,
        [1 2 3; 4 5 6; 7 8 9];
        column_labels = [[MultiColumn(2, "M"), "c3"]],
        show_column_labels = false,
    )

    @test result == expected
end

@testset "Summary Rows in Tables Without Columns" begin
    # A table with rows but no columns has no printed cells. Hence, requesting summary rows
    # must keep printing nothing instead of accessing undefined label references.
    result = pretty_table(String, Matrix{Float64}(undef, 3, 0); summary_rows = [sum])

    @test result == ""
end
