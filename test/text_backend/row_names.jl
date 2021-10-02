# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of row name column.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Show row names" begin
    expected = """
┌───────┬─────┬───────┬───────┬─────┐
│       │  C1 │    C2 │    C3 │  C4 │
│       │ Int │  Bool │ Float │ Hex │
├───────┼─────┼───────┼───────┼─────┤
│ Row 1 │   1 │ false │   1.0 │   1 │
│ Row 2 │   2 │  true │   2.0 │   2 │
│ Row 3 │   3 │ false │   3.0 │   3 │
│ Row 4 │   4 │  true │   4.0 │   4 │
│ Row 5 │   5 │ false │   5.0 │   5 │
│ Row 6 │   6 │  true │   6.0 │   6 │
└───────┴─────┴───────┴───────┴─────┘
"""

    result = pretty_table(
        String, data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        row_names = ["Row $i" for i in 1:6]
    )

    @test result == expected

    expected = """
┌───────────┬─────┬───────┬───────┬─────┐
│ Row names │  C1 │    C2 │    C3 │  C4 │
│           │ Int │  Bool │ Float │ Hex │
├───────────┼─────┼───────┼───────┼─────┤
│     Row 1 │   1 │ false │   1.0 │   1 │
│     Row 2 │   2 │  true │   2.0 │   2 │
│     Row 3 │   3 │ false │   3.0 │   3 │
│     Row 4 │   4 │  true │   4.0 │   4 │
│     Row 5 │   5 │ false │   5.0 │   5 │
│     Row 6 │   6 │  true │   6.0 │   6 │
└───────────┴─────┴───────┴───────┴─────┘
"""

    result = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row names"
    )

    @test result == expected

    expected = """
┌───────────┬─────┬───────┬───────┬─────┐
│ Row names │  C1 │    C2 │    C3 │  C4 │
│           │ Int │  Bool │ Float │ Hex │
├───────────┼─────┼───────┼───────┼─────┤
│   Row 1   │   1 │ false │   1.0 │   1 │
│   Row 2   │   2 │  true │   2.0 │   2 │
│   Row 3   │   3 │ false │   3.0 │   3 │
│   Row 4   │   4 │  true │   4.0 │   4 │
│   Row 5   │   5 │ false │   5.0 │   5 │
│   Row 6   │   6 │  true │   6.0 │   6 │
└───────────┴─────┴───────┴───────┴─────┘
"""

    result = pretty_table(
        String, data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row names",
        row_name_alignment = :c
    )

    @test result == expected

    expected = """
┌───────────┬─────┬───────┬───────┬─────
│ Row names │  C1 │    C2 │    C3 │  C ⋯
│           │ Int │  Bool │ Float │ He ⋯
├───────────┼─────┼───────┼───────┼─────
│   Row 1   │   1 │ false │   1.0 │    ⋯
│   Row 2   │   2 │  true │   2.0 │    ⋯
│   Row 3   │   3 │ false │   3.0 │    ⋯
│     ⋮     │  ⋮  │   ⋮   │   ⋮   │  ⋮ ⋱
└───────────┴─────┴───────┴───────┴─────
             1 column and 3 rows omitted
"""

    result = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        crop = :both,
        display_size = (12, 40),
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row names",
        row_name_alignment = :c
    )
    @test result == expected
end
