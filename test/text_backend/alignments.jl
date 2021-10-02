# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of alignments.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Alignments" begin
    # Left
    # ==========================================================================
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ 1      │ false  │ 1.0    │ 1      │
│ 2      │ true   │ 2.0    │ 2      │
│ 3      │ false  │ 3.0    │ 3      │
│ 4      │ true   │ 4.0    │ 4      │
│ 5      │ false  │ 5.0    │ 5      │
│ 6      │ true   │ 6.0    │ 6      │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(String, data; alignment = :l)
    @test result == expected

    # Center
    # ==========================================================================
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│   1    │ false  │  1.0   │   1    │
│   2    │  true  │  2.0   │   2    │
│   3    │ false  │  3.0   │   3    │
│   4    │  true  │  4.0   │   4    │
│   5    │ false  │  5.0   │   5    │
│   6    │  true  │  6.0   │   6    │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(String, data; alignment = :c)
    @test result == expected

    # Per column configuration
    # ==========================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ 1      │  false │  1.0   │      1 │
│ 2      │   true │  2.0   │      2 │
│ 3      │  false │  3.0   │      3 │
│ 4      │   true │  4.0   │      4 │
│ 5      │  false │  5.0   │      5 │
│ 6      │   true │  6.0   │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(String, data; alignment = [:l, :r, :c, :r])
    @test result == expected

    # Cell override
    # ==========================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ 1      │  false │  1.0   │ 1      │
│ 2      │   true │  2.0   │      2 │
│      3 │ false  │  3.0   │   3    │
│ 4      │   true │  4.0   │   4    │
│ 5      │  false │  5.0   │      5 │
│ 6      │   true │  6.0   │ 6      │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(
        String,
        data;
        alignment = [:l, :r, :c, :r],
        cell_alignment = Dict(
            (3,1) => :r,
            (3,2) => :l,
            (1,4) => :l,
            (3,4) => :c,
            (4,4) => :c,
            (6,4) => :l
        )
    )
    @test result == expected

    # Headers
    # ==========================================================================

    header = (["A", "B", "C", "D"],
              ["a", "b", "c", "d"])

    expected = """
┌───────────┬───────────┬───────────┬───────────┐
│ A         │     B     │         C │         D │
│ a         │     b     │         c │         d │
├───────────┼───────────┼───────────┼───────────┤
│ 1         │     false │    1.0    │ 1         │
│ 2         │      true │    2.0    │         2 │
│         3 │ false     │    3.0    │     3     │
│ 4         │      true │    4.0    │     4     │
│ 5         │     false │    5.0    │         5 │
│ 6         │      true │    6.0    │ 6         │
└───────────┴───────────┴───────────┴───────────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        alignment = [:l, :r, :c, :r],
        cell_alignment = Dict(
            (3,1) => :r,
            (3,2) => :l,
            (1,4) => :l,
            (3,4) => :c,
            (4,4) => :c,
            (6,4) => :l
        ),
        columns_width = 9,
        header_alignment = [:l, :c, :r, :r]
    )
    @test result == expected

    expected = """
┌───────────┬───────────┬───────────┬───────────┐
│         A │     B     │         C │         D │
│ a         │ b         │         c │     d     │
├───────────┼───────────┼───────────┼───────────┤
│ 1         │     false │    1.0    │ 1         │
│ 2         │      true │    2.0    │         2 │
│         3 │ false     │    3.0    │     3     │
│ 4         │      true │    4.0    │     4     │
│ 5         │     false │    5.0    │         5 │
│ 6         │      true │    6.0    │ 6         │
└───────────┴───────────┴───────────┴───────────┘
"""

    result = pretty_table(
        String, data;
        header = header,
        alignment = [:l, :r, :c, :r],
        cell_alignment = Dict(
            (3,1) => :r,
            (3,2) => :l,
            (1,4) => :l,
            (3,4) => :c,
            (4,4) => :c,
            (6,4) => :l
        ),
        columns_width = 9,
        header_alignment = [:l, :c, :r, :r],
        header_cell_alignment = Dict(
            (1,1) => :r,
            (2,2) => :l,
            (2,4) => :c
        )
    )
    @test result == expected
end

@testset "Column alignment regex" begin
    matrix = [ i == 2 ? missing :
               i == 5 ? nothing : (-1)^j*10.0^(-i+j) for i = 1:7, j = 1:7]

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
        alignment_anchor_regex = Dict(0 => [r"\."])
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(i => [r"\."] for i in 1:7)
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
        alignment_anchor_regex = Dict(0 => [r"\.", r"^"])
    )

    @test result == expected

    # Filters
    # ==========================================================================

    expected = """
┌─────────┬─────────────┬──────────┐
│  Col. 1 │      Col. 4 │   Col. 5 │
├─────────┼─────────────┼──────────┤
│    -1.0 │ 1000.0      │ -10000.0 │
│ missing │     missing │  missing │
│   -0.01 │   10.0      │   -100.0 │
│  -0.001 │    1.0      │    -10.0 │
│ nothing │     nothing │  nothing │
│ -1.0e-5 │    0.01     │     -0.1 │
│ -1.0e-6 │    0.001    │    -0.01 │
└─────────┴─────────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        filters_col = ((data, j) -> j ∈ [1, 4, 5],)
    )

    @test result == expected

    # Additional rows
    # ==========================================================================

    expected = """
┌─────┬─────────┬─────────────┬──────────┐
│ Row │  Col. 1 │      Col. 4 │   Col. 5 │
├─────┼─────────┼─────────────┼──────────┤
│   1 │    -1.0 │ 1000.0      │ -10000.0 │
│   2 │ missing │     missing │  missing │
│   3 │   -0.01 │   10.0      │   -100.0 │
│   4 │  -0.001 │    1.0      │    -10.0 │
│   5 │ nothing │     nothing │  nothing │
│   6 │ -1.0e-5 │    0.01     │     -0.1 │
│   7 │ -1.0e-6 │    0.001    │    -0.01 │
└─────┴─────────┴─────────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix,
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        filters_col = ((data, j) -> j ∈ [1, 4, 5],),
        show_row_number = true
    )

    @test result == expected

    expected = """
┌─────┬───┬─────────┬─────────────┬──────────┐
│ Row │   │  Col. 1 │      Col. 4 │   Col. 5 │
├─────┼───┼─────────┼─────────────┼──────────┤
│   1 │ a │    -1.0 │ 1000.0      │ -10000.0 │
│   2 │ a │ missing │     missing │  missing │
│   3 │ a │   -0.01 │   10.0      │   -100.0 │
│   4 │ a │  -0.001 │    1.0      │    -10.0 │
│   5 │ a │ nothing │     nothing │  nothing │
│   6 │ a │ -1.0e-5 │    0.01     │     -0.1 │
│   7 │ a │ -1.0e-6 │    0.001    │    -0.01 │
└─────┴───┴─────────┴─────────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix,
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        filters_col = ((data, j) -> j ∈ [1, 4, 5],),
        row_names = ["a" for i in 1:7],
        show_row_number = true
    )

    @test result == expected

    # Column alignment
    # ==========================================================================

    expected = """
┌─────────┬──────────────────────┬──────────┐
│  Col. 1 │               Col. 4 │   Col. 5 │
├─────────┼──────────────────────┼──────────┤
│    -1.0 │          1000.0      │ -10000.0 │
│ missing │              missing │  missing │
│   -0.01 │            10.0      │   -100.0 │
│  -0.001 │             1.0      │    -10.0 │
│ nothing │              nothing │  nothing │
│ -1.0e-5 │             0.01     │     -0.1 │
│ -1.0e-6 │             0.001    │    -0.01 │
└─────────┴──────────────────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        columns_width = [-1, -1, -1, 20, -1, -1, -1],
        filters_col = ((data, j) -> j ∈ [1, 4, 5],)
    )

    @test result == expected

    expected = """
┌─────────┬──────────────────────┬──────────┐
│ Col. 1  │        Col. 4        │  Col. 5  │
├─────────┼──────────────────────┼──────────┤
│  -1.0   │     1000.0           │ -10000.0 │
│ missing │         missing      │ missing  │
│  -0.01  │       10.0           │  -100.0  │
│ -0.001  │        1.0           │  -10.0   │
│ nothing │         nothing      │ nothing  │
│ -1.0e-5 │        0.01          │   -0.1   │
│ -1.0e-6 │        0.001         │  -0.01   │
└─────────┴──────────────────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment = :c,
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        columns_width = [-1, -1, -1, 20, -1, -1, -1],
        filters_col = ((data, j) -> j ∈ [1, 4, 5],)
    )

    @test result == expected

    expected = """
┌─────────┬──────────────────────┬──────────┐
│ Col. 1  │ Col. 4               │ Col. 5   │
├─────────┼──────────────────────┼──────────┤
│ -1.0    │ 1000.0               │ -10000.0 │
│ missing │     missing          │ missing  │
│ -0.01   │   10.0               │ -100.0   │
│ -0.001  │    1.0               │ -10.0    │
│ nothing │     nothing          │ nothing  │
│ -1.0e-5 │    0.01              │ -0.1     │
│ -1.0e-6 │    0.001             │ -0.01    │
└─────────┴──────────────────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment = :l,
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        columns_width = [-1, -1, -1, 20, -1, -1, -1],
        filters_col = ((data, j) -> j ∈ [1, 4, 5],)
    )

    @test result == expected

    # Minimum and maximum column width
    # ==========================================================================

    expected = """
┌─────────────────┬─────────────────┬─────────────────┐
│          Col. 1 │          Col. 4 │          Col. 5 │
├─────────────────┼─────────────────┼─────────────────┤
│            -1.0 │     1000.0      │        -10000.0 │
│         missing │         missing │         missing │
│           -0.01 │       10.0      │          -100.0 │
│          -0.001 │        1.0      │           -10.0 │
│         nothing │         nothing │         nothing │
│         -1.0e-5 │        0.01     │            -0.1 │
│         -1.0e-6 │        0.001    │           -0.01 │
└─────────────────┴─────────────────┴─────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        minimum_columns_width = 15,
        filters_col = ((data, j) -> j ∈ [1, 4, 5],)
    )

    @test result == expected

    expected = """
┌─────────┬────────────┬──────────┐
│  Col. 1 │     Col. 4 │   Col. 5 │
├─────────┼────────────┼──────────┤
│    -1.0 │ 1000.0   … │ -10000.0 │
│ missing │     missi… │  missing │
│   -0.01 │   10.0   … │   -100.0 │
│  -0.001 │    1.0   … │    -10.0 │
│ nothing │     nothi… │  nothing │
│ -1.0e-5 │    0.01  … │     -0.1 │
│ -1.0e-6 │    0.001 … │    -0.01 │
└─────────┴────────────┴──────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(4 => [r"\.", r"^"]),
        maximum_columns_width = 10,
        filters_col = ((data, j) -> j ∈ [1, 4, 5],)
    )

    @test result == expected

    # Fallback alignment
    # ==========================================================================

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
        alignment_anchor_regex = Dict(i => [r"\."] for i in 1:7),
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
        alignment_anchor_regex = Dict(i => [r"\."] for i in 1:7),
        alignment_anchor_fallback = :r
    )

    @test result == expected

    expected = """
┌────────────┬──────────┬──────────────┬─────────────┬────────────────┬────────────────┬────────────────┐
│     Col. 1 │   Col. 2 │       Col. 3 │      Col. 4 │         Col. 5 │         Col. 6 │         Col. 7 │
├────────────┼──────────┼──────────────┼─────────────┼────────────────┼────────────────┼────────────────┤
│ -1.0       │  10.0    │ -100.0       │    1000.0   │ -10000.0       │ 100000.0       │     -1.0e6     │
│    missing │ missing  │      missing │ missing     │        missing │        missing │        missing │
│ -0.01      │   0.1    │   -1.0       │      10.0   │   -100.0       │   1000.0       │ -10000.0       │
│ -0.001     │   0.01   │   -0.1       │       1.0   │    -10.0       │    100.0       │  -1000.0       │
│    nothing │ nothing  │      nothing │ nothing     │        nothing │        nothing │        nothing │
│ -1.0e-5    │   0.0001 │   -0.001     │       0.01  │     -0.1       │      1.0       │    -10.0       │
│ -1.0e-6    │   1.0e-5 │   -0.0001    │       0.001 │     -0.01      │      0.1       │     -1.0       │
└────────────┴──────────┴──────────────┴─────────────┴────────────────┴────────────────┴────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(0 => [r"\."]),
        alignment_anchor_fallback_override = Dict(2 => :c, 4 => :r, 5 => :l)
    )

    @test result == expected

    expected = """
┌──────────┬──────────┬───────────┬─────────────┬────────────────┬────────────┬────────────┐
│   Col. 1 │   Col. 2 │    Col. 3 │      Col. 4 │         Col. 5 │     Col. 6 │     Col. 7 │
├──────────┼──────────┼───────────┼─────────────┼────────────────┼────────────┼────────────┤
│  -1.0    │  10.0    │ -100.0    │    1000.0   │ -10000.0       │ 100000.0   │     -1.0e6 │
│ missing  │ missing  │  missing  │ missing     │        missing │    missing │    missing │
│  -0.01   │   0.1    │   -1.0    │      10.0   │   -100.0       │   1000.0   │ -10000.0   │
│  -0.001  │   0.01   │   -0.1    │       1.0   │    -10.0       │    100.0   │  -1000.0   │
│ nothing  │ nothing  │  nothing  │ nothing     │        nothing │    nothing │    nothing │
│  -1.0e-5 │   0.0001 │   -0.001  │       0.01  │     -0.1       │      1.0   │    -10.0   │
│  -1.0e-6 │   1.0e-5 │   -0.0001 │       0.001 │     -0.01      │      0.1   │     -1.0   │
└──────────┴──────────┴───────────┴─────────────┴────────────────┴────────────┴────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(0 => [r"\."]),
        alignment_anchor_fallback = :c,
        alignment_anchor_fallback_override = Dict(2 => :c, 4 => :r, 5 => :l)
    )

    @test result == expected
end
