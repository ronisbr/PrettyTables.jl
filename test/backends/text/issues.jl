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
            String,
            matrix;
            display_size = (15, 50),
            show_column_labels = false
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
            vertical_crop_mode = :middle
        )

        @test result == expected
    end
end
