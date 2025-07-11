## Description #############################################################################
#
# Tests related with alignment of cells in the table.
#
############################################################################################

@testset "Column Alignment Regex" begin
    matrix = [
        i == 2 ? missing :
        i == 5 ? nothing : (-1)^j * 10.0^(-i + j) for i in 1:7, j in 1:7
    ]

    expected = """
┌────────────┬────────────┬──────────────┬──────────────┬────────────────┬────────────────┬────────────────┐
│     Col. 1 │     Col. 2 │       Col. 3 │       Col. 4 │         Col. 5 │         Col. 6 │         Col. 7 │
├────────────┼────────────┼──────────────┼──────────────┼────────────────┼────────────────┼────────────────┤
│ -1.0       │ 10.0       │ -100.0       │ 1000.0       │ -10000.0       │ 100000.0       │     -1.0e6     │
│    missing │    missing │      missing │      missing │        missing │        missing │        missing │
│ -0.01      │  0.1       │   -1.0       │   10.0       │   -100.0       │   1000.0       │ -10000.0       │
│ -0.001     │  0.01      │   -0.1       │    1.0       │    -10.0       │    100.0       │  -1000.0       │
│    nothing │    nothing │      nothing │      nothing │        nothing │        nothing │        nothing │
│ -1.0e-5    │  0.0001    │   -0.001     │    0.01      │     -0.1       │      1.0       │    -10.0       │
│ -1.0e-6    │  1.0e-5    │   -0.0001    │    0.001     │     -0.01      │      0.1       │     -1.0       │
└────────────┴────────────┴──────────────┴──────────────┴────────────────┴────────────────┴────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [r"\."]
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [i => [r"\."] for i in 1:7]
    )

    @test result == expected

    expected = """
┌───────────┬───────────┬─────────────┬─────────────┬───────────────┬───────────────┬───────────────┐
│    Col. 1 │    Col. 2 │      Col. 3 │      Col. 4 │        Col. 5 │        Col. 6 │        Col. 7 │
├───────────┼───────────┼─────────────┼─────────────┼───────────────┼───────────────┼───────────────┤
│ -1.0      │ 10.0      │ -100.0      │ 1000.0      │ -10000.0      │ 100000.0      │     -1.0e6    │
│   missing │   missing │     missing │     missing │       missing │       missing │       missing │
│ -0.01     │  0.1      │   -1.0      │   10.0      │   -100.0      │   1000.0      │ -10000.0      │
│ -0.001    │  0.01     │   -0.1      │    1.0      │    -10.0      │    100.0      │  -1000.0      │
│   nothing │   nothing │     nothing │     nothing │       nothing │       nothing │       nothing │
│ -1.0e-5   │  0.0001   │   -0.001    │    0.01     │     -0.1      │      1.0      │    -10.0      │
│ -1.0e-6   │  1.0e-5   │   -0.0001   │    0.001    │     -0.01     │      0.1      │     -1.0      │
└───────────┴───────────┴─────────────┴─────────────┴───────────────┴───────────────┴───────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [r"\.", r"^"]
    )

    @test result == expected

    # == Additional Rows ===================================================================

    expected = """
┌─────┬─────────┬─────────┬─────────┬─────────────┬──────────┬──────────┬──────────┐
│ Row │  Col. 1 │  Col. 2 │  Col. 3 │      Col. 4 │   Col. 5 │   Col. 6 │   Col. 7 │
├─────┼─────────┼─────────┼─────────┼─────────────┼──────────┼──────────┼──────────┤
│   1 │    -1.0 │    10.0 │  -100.0 │ 1000.0      │ -10000.0 │ 100000.0 │   -1.0e6 │
│   2 │ missing │ missing │ missing │     missing │  missing │  missing │  missing │
│   3 │   -0.01 │     0.1 │    -1.0 │   10.0      │   -100.0 │   1000.0 │ -10000.0 │
│   4 │  -0.001 │    0.01 │    -0.1 │    1.0      │    -10.0 │    100.0 │  -1000.0 │
│   5 │ nothing │ nothing │ nothing │     nothing │  nothing │  nothing │  nothing │
│   6 │ -1.0e-5 │  0.0001 │  -0.001 │    0.01     │     -0.1 │      1.0 │    -10.0 │
│   7 │ -1.0e-6 │  1.0e-5 │ -0.0001 │    0.001    │    -0.01 │      0.1 │     -1.0 │
└─────┴─────────┴─────────┴─────────┴─────────────┴──────────┴──────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix,
        alignment_anchor_regex = [4 => [r"\.", r"^"]],
        show_row_number_column = true
    )

    @test result == expected

    expected = """
┌─────┬───┬─────────┬─────────┬─────────┬─────────────┬──────────┬──────────┬──────────┐
│ Row │   │  Col. 1 │  Col. 2 │  Col. 3 │      Col. 4 │   Col. 5 │   Col. 6 │   Col. 7 │
├─────┼───┼─────────┼─────────┼─────────┼─────────────┼──────────┼──────────┼──────────┤
│   1 │ a │    -1.0 │    10.0 │  -100.0 │ 1000.0      │ -10000.0 │ 100000.0 │   -1.0e6 │
│   2 │ a │ missing │ missing │ missing │     missing │  missing │  missing │  missing │
│   3 │ a │   -0.01 │     0.1 │    -1.0 │   10.0      │   -100.0 │   1000.0 │ -10000.0 │
│   4 │ a │  -0.001 │    0.01 │    -0.1 │    1.0      │    -10.0 │    100.0 │  -1000.0 │
│   5 │ a │ nothing │ nothing │ nothing │     nothing │  nothing │  nothing │  nothing │
│   6 │ a │ -1.0e-5 │  0.0001 │  -0.001 │    0.01     │     -0.1 │      1.0 │    -10.0 │
│   7 │ a │ -1.0e-6 │  1.0e-5 │ -0.0001 │    0.001    │    -0.01 │      0.1 │     -1.0 │
└─────┴───┴─────────┴─────────┴─────────┴─────────────┴──────────┴──────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix,
        alignment_anchor_regex = [4 => [r"\.", r"^"]],
        row_labels = ["a" for i in 1:7],
        show_row_number_column = true
    )

    @test result == expected

    # == Column Alignment ==================================================================

    expected = """
┌─────────┬─────────┬─────────┬──────────────────────┬──────────┬──────────┬──────────┐
│  Col. 1 │  Col. 2 │  Col. 3 │               Col. 4 │   Col. 5 │   Col. 6 │   Col. 7 │
├─────────┼─────────┼─────────┼──────────────────────┼──────────┼──────────┼──────────┤
│    -1.0 │    10.0 │  -100.0 │          1000.0      │ -10000.0 │ 100000.0 │   -1.0e6 │
│ missing │ missing │ missing │              missing │  missing │  missing │  missing │
│   -0.01 │     0.1 │    -1.0 │            10.0      │   -100.0 │   1000.0 │ -10000.0 │
│  -0.001 │    0.01 │    -0.1 │             1.0      │    -10.0 │    100.0 │  -1000.0 │
│ nothing │ nothing │ nothing │              nothing │  nothing │  nothing │  nothing │
│ -1.0e-5 │  0.0001 │  -0.001 │             0.01     │     -0.1 │      1.0 │    -10.0 │
│ -1.0e-6 │  1.0e-5 │ -0.0001 │             0.001    │    -0.01 │      0.1 │     -1.0 │
└─────────┴─────────┴─────────┴──────────────────────┴──────────┴──────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [4 => [r"\.", r"^"]],
        fixed_data_column_widths = [-1, -1, -1, 20, -1, -1, -1]
    )

    @test result == expected

    expected = """
┌─────────┬─────────┬─────────┬──────────────────────┬──────────┬──────────┬──────────┐
│ Col. 1  │ Col. 2  │ Col. 3  │        Col. 4        │  Col. 5  │  Col. 6  │  Col. 7  │
├─────────┼─────────┼─────────┼──────────────────────┼──────────┼──────────┼──────────┤
│  -1.0   │  10.0   │ -100.0  │     1000.0           │ -10000.0 │ 100000.0 │  -1.0e6  │
│ missing │ missing │ missing │         missing      │ missing  │ missing  │ missing  │
│  -0.01  │   0.1   │  -1.0   │       10.0           │  -100.0  │  1000.0  │ -10000.0 │
│ -0.001  │  0.01   │  -0.1   │        1.0           │  -10.0   │  100.0   │ -1000.0  │
│ nothing │ nothing │ nothing │         nothing      │ nothing  │ nothing  │ nothing  │
│ -1.0e-5 │ 0.0001  │ -0.001  │        0.01          │   -0.1   │   1.0    │  -10.0   │
│ -1.0e-6 │ 1.0e-5  │ -0.0001 │        0.001         │  -0.01   │   0.1    │   -1.0   │
└─────────┴─────────┴─────────┴──────────────────────┴──────────┴──────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment = :c,
        alignment_anchor_regex = [4 => [r"\.", r"^"]],
        fixed_data_column_widths = [-1, -1, -1, 20, -1, -1, -1]
    )

    @test result == expected

    expected = """
┌─────────┬─────────┬─────────┬──────────────────────┬──────────┬──────────┬──────────┐
│ Col. 1  │ Col. 2  │ Col. 3  │ Col. 4               │ Col. 5   │ Col. 6   │ Col. 7   │
├─────────┼─────────┼─────────┼──────────────────────┼──────────┼──────────┼──────────┤
│ -1.0    │ 10.0    │ -100.0  │ 1000.0               │ -10000.0 │ 100000.0 │ -1.0e6   │
│ missing │ missing │ missing │     missing          │ missing  │ missing  │ missing  │
│ -0.01   │ 0.1     │ -1.0    │   10.0               │ -100.0   │ 1000.0   │ -10000.0 │
│ -0.001  │ 0.01    │ -0.1    │    1.0               │ -10.0    │ 100.0    │ -1000.0  │
│ nothing │ nothing │ nothing │     nothing          │ nothing  │ nothing  │ nothing  │
│ -1.0e-5 │ 0.0001  │ -0.001  │    0.01              │ -0.1     │ 1.0      │ -10.0    │
│ -1.0e-6 │ 1.0e-5  │ -0.0001 │    0.001             │ -0.01    │ 0.1      │ -1.0     │
└─────────┴─────────┴─────────┴──────────────────────┴──────────┴──────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment = :l,
        alignment_anchor_regex = [4 => [r"\.", r"^"]],
        fixed_data_column_widths = [-1, -1, -1, 20, -1, -1, -1]
    )

    @test result == expected

    # == Maximum Column Width ==============================================================

    expected = """
┌─────────┬─────────┬─────────┬────────────┬──────────┬──────────┬──────────┐
│  Col. 1 │  Col. 2 │  Col. 3 │     Col. 4 │   Col. 5 │   Col. 6 │   Col. 7 │
├─────────┼─────────┼─────────┼────────────┼──────────┼──────────┼──────────┤
│    -1.0 │    10.0 │  -100.0 │ 1000.0   … │ -10000.0 │ 100000.0 │   -1.0e6 │
│ missing │ missing │ missing │     missi… │  missing │  missing │  missing │
│   -0.01 │     0.1 │    -1.0 │   10.0   … │   -100.0 │   1000.0 │ -10000.0 │
│  -0.001 │    0.01 │    -0.1 │    1.0   … │    -10.0 │    100.0 │  -1000.0 │
│ nothing │ nothing │ nothing │     nothi… │  nothing │  nothing │  nothing │
│ -1.0e-5 │  0.0001 │  -0.001 │    0.01  … │     -0.1 │      1.0 │    -10.0 │
│ -1.0e-6 │  1.0e-5 │ -0.0001 │    0.001 … │    -0.01 │      0.1 │     -1.0 │
└─────────┴─────────┴─────────┴────────────┴──────────┴──────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [4 => [r"\.", r"^"]],
        maximum_data_column_widths = 10
    )

    @test result == expected

    # == Fallback Alignment ================================================================

    expected = """
┌──────────┬──────────┬───────────┬──────────┬────────────┬────────────┬────────────┐
│   Col. 1 │   Col. 2 │    Col. 3 │   Col. 4 │     Col. 5 │     Col. 6 │     Col. 7 │
├──────────┼──────────┼───────────┼──────────┼────────────┼────────────┼────────────┤
│  -1.0    │  10.0    │ -100.0    │ 1000.0   │ -10000.0   │ 100000.0   │     -1.0e6 │
│ missing  │ missing  │  missing  │  missing │    missing │    missing │    missing │
│  -0.01   │   0.1    │   -1.0    │   10.0   │   -100.0   │   1000.0   │ -10000.0   │
│  -0.001  │   0.01   │   -0.1    │    1.0   │    -10.0   │    100.0   │  -1000.0   │
│ nothing  │ nothing  │  nothing  │  nothing │    nothing │    nothing │    nothing │
│  -1.0e-5 │   0.0001 │   -0.001  │    0.01  │     -0.1   │      1.0   │    -10.0   │
│  -1.0e-6 │   1.0e-5 │   -0.0001 │    0.001 │     -0.01  │      0.1   │     -1.0   │
└──────────┴──────────┴───────────┴──────────┴────────────┴────────────┴────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [i => [r"\."] for i in 1:7],
        alignment_anchor_fallback = :c
    )

    @test result == expected

    expected = """
┌──────────────┬──────────────┬──────────────┬─────────────┬────────────┬───────────┬─────────────┐
│       Col. 1 │       Col. 2 │       Col. 3 │      Col. 4 │     Col. 5 │    Col. 6 │      Col. 7 │
├──────────────┼──────────────┼──────────────┼─────────────┼────────────┼───────────┼─────────────┤
│      -1.0    │      10.0    │    -100.0    │    1000.0   │  -10000.0  │  100000.0 │      -1.0e6 │
│ missing      │ missing      │ missing      │ missing     │ missing    │ missing   │ missing     │
│      -0.01   │       0.1    │      -1.0    │      10.0   │    -100.0  │    1000.0 │  -10000.0   │
│      -0.001  │       0.01   │      -0.1    │       1.0   │     -10.0  │     100.0 │   -1000.0   │
│ nothing      │ nothing      │ nothing      │ nothing     │ nothing    │ nothing   │ nothing     │
│      -1.0e-5 │       0.0001 │      -0.001  │       0.01  │      -0.1  │       1.0 │     -10.0   │
│      -1.0e-6 │       1.0e-5 │      -0.0001 │       0.001 │      -0.01 │       0.1 │      -1.0   │
└──────────────┴──────────────┴──────────────┴─────────────┴────────────┴───────────┴─────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [i => [r"\."] for i in 1:7],
        alignment_anchor_fallback = :r
    )

    @test result == expected

    # == Summary Row Alignment =============================================================

    expected = """
┌───────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┐
│           │         Col. 1 │         Col. 2 │         Col. 3 │         Col. 4 │         Col. 5 │         Col. 6 │         Col. 7 │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│           │     -1.0       │     10.0       │   -100.0       │   1000.0       │ -10000.0       │ 100000.0       │     -1.0e6     │
│           │        missing │        missing │        missing │        missing │        missing │        missing │        missing │
│           │     -0.01      │      0.1       │     -1.0       │     10.0       │   -100.0       │   1000.0       │ -10000.0       │
│           │     -0.001     │      0.01      │     -0.1       │      1.0       │    -10.0       │    100.0       │  -1000.0       │
│           │        nothing │        nothing │        nothing │        nothing │        nothing │        nothing │        nothing │
│           │     -1.0e-5    │      0.0001    │     -0.001     │      0.01      │     -0.1       │      1.0       │    -10.0       │
│           │     -1.0e-6    │      1.0e-5    │     -0.0001    │      0.001     │     -0.01      │      0.1       │     -1.0       │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│ Summary 1 │ 123456.7890    │ 123456.7890    │ 123456.7890    │ 123456.7890    │ 123456.7890    │ 123456.7890    │ 123456.7890    │
│ Summary 2 │   0987.654321  │   0987.654321  │   0987.654321  │   0987.654321  │   0987.654321  │   0987.654321  │   0987.654321  │
└───────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [r"\."],
        apply_alignment_regex_to_summary_rows = true,
        summary_rows = [c -> "123456.7890", c -> "0987.654321"]
    )

    expected = """
┌───────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┬────────────────┐
│           │         Col. 1 │         Col. 2 │         Col. 3 │         Col. 4 │         Col. 5 │         Col. 6 │         Col. 7 │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│           │      -1.0      │      10.0      │    -100.0      │    1000.0      │  -10000.0      │  100000.0      │      -1.0e6    │
│           │ missing        │ missing        │ missing        │ missing        │ missing        │ missing        │ missing        │
│           │      -0.01     │       0.1      │      -1.0      │      10.0      │    -100.0      │    1000.0      │  -10000.0      │
│           │      -0.001    │       0.01     │      -0.1      │       1.0      │     -10.0      │     100.0      │   -1000.0      │
│           │ nothing        │ nothing        │ nothing        │ nothing        │ nothing        │ nothing        │ nothing        │
│           │      -1.0e-5   │       0.0001   │      -0.001    │       0.01     │      -0.1      │       1.0      │     -10.0      │
│           │      -1.0e-6   │       1.0e-5   │      -0.0001   │       0.001    │      -0.01     │       0.1      │      -1.0      │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│ Summary 1 │  123456.7890   │  123456.7890   │  123456.7890   │  123456.7890   │  123456.7890   │  123456.7890   │  123456.7890   │
│ Summary 2 │    0987.654321 │    0987.654321 │    0987.654321 │    0987.654321 │    0987.654321 │    0987.654321 │    0987.654321 │
└───────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┴────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_fallback = :r,
        alignment_anchor_regex = [r"\."],
        apply_alignment_regex_to_summary_rows = true,
        summary_rows = [c -> "123456.7890", c -> "0987.654321"]
    )

    expected = """
┌───────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┐
│           │     Col. 1 │     Col. 2 │     Col. 3 │     Col. 4 │     Col. 5 │     Col. 6 │     Col. 7 │
├───────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│           │      -1.0… │      10.0… │    -100.0… │    1000.0… │  -10000.0… │  100000.0… │      -1.0… │
│           │ missing  … │ missing  … │ missing  … │ missing  … │ missing  … │ missing  … │ missing  … │
│           │      -0.0… │       0.1… │      -1.0… │      10.0… │    -100.0… │    1000.0… │  -10000.0… │
│           │      -0.0… │       0.0… │      -0.1… │       1.0… │     -10.0… │     100.0… │   -1000.0… │
│           │ nothing  … │ nothing  … │ nothing  … │ nothing  … │ nothing  … │ nothing  … │ nothing  … │
│           │      -1.0… │       0.0… │      -0.0… │       0.0… │      -0.1… │       1.0… │     -10.0… │
│           │      -1.0… │       1.0… │      -0.0… │       0.0… │      -0.0… │       0.1… │      -1.0… │
├───────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│ Summary 1 │  123456.7… │  123456.7… │  123456.7… │  123456.7… │  123456.7… │  123456.7… │  123456.7… │
│ Summary 2 │    0987.6… │    0987.6… │    0987.6… │    0987.6… │    0987.6… │    0987.6… │    0987.6… │
└───────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_fallback = :r,
        alignment_anchor_regex = [r"\."],
        apply_alignment_regex_to_summary_rows = true,
        maximum_data_column_widths = 10,
        summary_rows = [c -> "123456.7890", c -> "0987.654321"]
    )

    expected = """
┌───────────┬─────────────┬─────────────┬───────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│           │      Col. 1 │      Col. 2 │        Col. 3 │      Col. 4 │      Col. 5 │      Col. 6 │      Col. 7 │
├───────────┼─────────────┼─────────────┼───────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│           │        -1.0 │        10.0 │   -100.0      │      1000.0 │    -10000.0 │    100000.0 │      -1.0e6 │
│           │     missing │     missing │       missing │     missing │     missing │     missing │     missing │
│           │       -0.01 │         0.1 │     -1.0      │        10.0 │      -100.0 │      1000.0 │    -10000.0 │
│           │      -0.001 │        0.01 │     -0.1      │         1.0 │       -10.0 │       100.0 │     -1000.0 │
│           │     nothing │     nothing │       nothing │     nothing │     nothing │     nothing │     nothing │
│           │     -1.0e-5 │      0.0001 │     -0.001    │        0.01 │        -0.1 │         1.0 │       -10.0 │
│           │     -1.0e-6 │      1.0e-5 │     -0.0001   │       0.001 │       -0.01 │         0.1 │        -1.0 │
├───────────┼─────────────┼─────────────┼───────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│ Summary 1 │ 123456.7890 │ 123456.7890 │ 123456.7890   │ 123456.7890 │ 123456.7890 │ 123456.7890 │ 123456.7890 │
│ Summary 2 │ 0987.654321 │ 0987.654321 │   0987.654321 │ 0987.654321 │ 0987.654321 │ 0987.654321 │ 0987.654321 │
└───────────┴─────────────┴─────────────┴───────────────┴─────────────┴─────────────┴─────────────┴─────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_fallback = :r,
        alignment_anchor_regex = [3 => [r"\.", r"^"]],
        apply_alignment_regex_to_summary_rows = true,
        summary_rows = [c -> "123456.7890", c -> "0987.654321"]
    )
end

@testset "Column Alignment Regex With Multiple Lines" begin
    matrix = [
        i == 2 ? missing :
        i == 5 ? nothing :
        "$((-1)^j * round(10.0^(-i + j); digits = 3))\n$((-1)^j * round(10.0^(-i + (j + 1)); digits = 3))"
        for i in 1:4, j in 1:4
    ]

    expected = """
┌─────────────┬─────────────┬───────────────┬───────────────┐
│      Col. 1 │      Col. 2 │        Col. 3 │        Col. 4 │
├─────────────┼─────────────┼───────────────┼───────────────┤
│  -1.0       │  10.0       │  -100.0       │  1000.0       │
│ -10.0       │ 100.0       │ -1000.0       │ 10000.0       │
├─────────────┼─────────────┼───────────────┼───────────────┤
│     missing │     missing │       missing │       missing │
├─────────────┼─────────────┼───────────────┼───────────────┤
│  -0.01      │   0.1       │    -1.0       │    10.0       │
│  -0.1       │   1.0       │   -10.0       │   100.0       │
├─────────────┼─────────────┼───────────────┼───────────────┤
│  -0.001     │   0.01      │    -0.1       │     1.0       │
│  -0.01      │   0.1       │    -1.0       │    10.0       │
└─────────────┴─────────────┴───────────────┴───────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [r"\."],
        line_breaks = true,
        table_format = TextTableFormat(; @text__all_horizontal_lines)
    )

    @test result == expected

    expected = """
┌─────┬─────────┬─────────┬───────────┬───────────┐
│ Row │  Col. 1 │  Col. 2 │    Col. 3 │    Col. 4 │
├─────┼─────────┼─────────┼───────────┼───────────┤
│   1 │  -1.0   │  10.0   │  -100.0   │  1000.0   │
│     │ -10.0   │ 100.0   │ -1000.0   │ 10000.0   │
├─────┼─────────┼─────────┼───────────┼───────────┤
│   2 │ missing │ missing │   missing │   missing │
├─────┼─────────┼─────────┼───────────┼───────────┤
│   3 │  -0.01  │   0.1   │    -1.0   │    10.0   │
│     │  -0.1   │   1.0   │   -10.0   │   100.0   │
├─────┼─────────┼─────────┼───────────┼───────────┤
│   4 │  -0.001 │   0.01  │    -0.1   │     1.0   │
│     │  -0.01  │   0.1   │    -1.0   │    10.0   │
└─────┴─────────┴─────────┴───────────┴───────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_fallback = :c,
        alignment_anchor_regex = [r"\."],
        line_breaks = true,
        show_row_number_column = true,
        table_format = TextTableFormat(; @text__all_horizontal_lines)
    )

    @test result == expected

    # == Summary Row Alignment =============================================================

    expected = """
┌───────────┬────────────────┬────────────────┬────────────────┬────────────────┐
│           │         Col. 1 │         Col. 2 │         Col. 3 │         Col. 4 │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│           │     -1.0       │     10.0       │   -100.0       │   1000.0       │
│           │    -10.0       │    100.0       │  -1000.0       │  10000.0       │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│           │        missing │        missing │        missing │        missing │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│           │     -0.01      │      0.1       │     -1.0       │     10.0       │
│           │     -0.1       │      1.0       │    -10.0       │    100.0       │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│           │     -0.001     │      0.01      │     -0.1       │      1.0       │
│           │     -0.01      │      0.1       │     -1.0       │     10.0       │
├───────────┼────────────────┼────────────────┼────────────────┼────────────────┤
│ Summary 1 │ 123456.7890    │ 123456.7890    │ 123456.7890    │ 123456.7890    │
│ Summary 2 │   0987.654321  │   0987.654321  │   0987.654321  │   0987.654321  │
└───────────┴────────────────┴────────────────┴────────────────┴────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = [r"\."],
        line_breaks = true,
        apply_alignment_regex_to_summary_rows = true,
        summary_rows = [c -> "123456.7890", c -> "0987.654321"],
        table_format = TextTableFormat(; @text__all_horizontal_lines)
    )

    expected = """
┌─────┬───────────┬───────────────┬───────────────┬───────────────┬───────────────┐
│ Row │           │        Col. 1 │        Col. 2 │        Col. 3 │        Col. 4 │
├─────┼───────────┼───────────────┼───────────────┼───────────────┼───────────────┤
│   1 │           │     -1.0      │     10.0      │   -100.0      │   1000.0      │
│     │           │    -10.0      │    100.0      │  -1000.0      │  10000.0      │
├─────┼───────────┼───────────────┼───────────────┼───────────────┼───────────────┤
│   2 │           │    missing    │    missing    │    missing    │    missing    │
├─────┼───────────┼───────────────┼───────────────┼───────────────┼───────────────┤
│   3 │           │     -0.01     │      0.1      │     -1.0      │     10.0      │
│     │           │     -0.1      │      1.0      │    -10.0      │    100.0      │
├─────┼───────────┼───────────────┼───────────────┼───────────────┼───────────────┤
│   4 │           │     -0.001    │      0.01     │     -0.1      │      1.0      │
│     │           │     -0.01     │      0.1      │     -1.0      │     10.0      │
├─────┼───────────┼───────────────┼───────────────┼───────────────┼───────────────┤
│     │ Summary 1 │ 123456.7890   │ 123456.7890   │ 123456.7890   │ 123456.7890   │
│     │ Summary 2 │   0987.654321 │   0987.654321 │   0987.654321 │   0987.654321 │
└─────┴───────────┴───────────────┴───────────────┴───────────────┴───────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_fallback = :c,
        alignment_anchor_regex = [r"\."],
        apply_alignment_regex_to_summary_rows = true,
        line_breaks = true,
        show_row_number_column = true,
        summary_rows = [c -> "123456.7890", c -> "0987.654321"],
        table_format = TextTableFormat(; @text__all_horizontal_lines)
    )
end
