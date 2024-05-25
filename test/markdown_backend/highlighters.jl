## Description #############################################################################
#
# Tests of highlighters.
#
############################################################################################

@testset "Highlighters" begin
    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| 3          | false      | 3.0        | 3          |
| 4          | true       | 4.0        | 4          |
| **5**      | false      | **5.0**    | **5**      |
| **6**      | true       | **6.0**    | **6**      |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = MarkdownHighlighter(
            (data, i, j) -> data[i, j] > 4,
            MarkdownDecoration(bold = true)
        ),
    )
end

@testset "Pre-defined highlighters" begin
    # == hl_cell ===========================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | **true**   | 2.0        | 2          |
| 3          | false      | _3.0_      | 3          |
| 4          | true       | 4.0        | 4          |
| 5          | false      | 5.0        | 5          |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = (
            hl_cell(2, 2, MarkdownDecoration(bold = true)),
            hl_cell(3, 3, MarkdownDecoration(italic = true))
        ),
    )

    @test result == expected

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | ~true~     | 2.0        | 2          |
| 3          | false      | ~3.0~      | 3          |
| 4          | true       | 4.0        | 4          |
| 5          | false      | 5.0        | 5          |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = hl_cell(
            [(2, 2), (3, 3)],
            MarkdownDecoration(strikethrough = true)
        ),
    )

    # == hl_col ============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| **1**      | false      | 1.0        | _1_        |
| **2**      | true       | 2.0        | _2_        |
| **3**      | false      | 3.0        | _3_        |
| **4**      | true       | 4.0        | _4_        |
| **5**      | false      | 5.0        | _5_        |
| **6**      | true       | 6.0        | _6_        |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = (
            hl_col(1, MarkdownDecoration(bold = true)),
            hl_col(4, MarkdownDecoration(italic = true))
        ),
    )

    @test result == expected

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| `1`        | false      | 1.0        | `1`        |
| `2`        | true       | 2.0        | `2`        |
| `3`        | false      | 3.0        | `3`        |
| `4`        | true       | 4.0        | `4`        |
| `5`        | false      | 5.0        | `5`        |
| `6`        | true       | 6.0        | `6`        |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = hl_col([1, 4], MarkdownDecoration(code = true)),
    )

    @test result == expected

    # == hl_row ============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| **1**      | **false**  | **1.0**    | **1**      |
| 2          | true       | 2.0        | 2          |
| _3_        | _false_    | _3.0_      | _3_        |
| 4          | true       | 4.0        | 4          |
| ~5~        | ~false~    | ~5.0~      | ~5~        |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = (
            hl_row(1, MarkdownDecoration(bold = true)),
            hl_row(3, MarkdownDecoration(italic = true)),
            hl_row(5, MarkdownDecoration(strikethrough = true))
        ),
    )

    @test result == expected

    expected = """
| **Col. 1** | **Col. 2**  | **Col. 3** | **Col. 4** |
|-----------:|------------:|-----------:|-----------:|
| **_1_**    | **_false_** | **_1.0_**  | **_1_**    |
| 2          | true        | 2.0        | 2          |
| **_3_**    | **_false_** | **_3.0_**  | **_3_**    |
| 4          | true        | 4.0        | 4          |
| **_5_**    | **_false_** | **_5.0_**  | **_5_**    |
| 6          | true        | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = hl_row(
            [1, 3, 5],
            MarkdownDecoration(bold = true, italic = true)
        ),
    )

    @test result == expected

    # == hl_lt =============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| **1**      | **false**  | **1.0**    | **1**      |
| **2**      | **true**   | **2.0**    | **2**      |
| 3          | **false**  | 3.0        | 3          |
| 4          | **true**   | 4.0        | 4          |
| 5          | **false**  | 5.0        | 5          |
| 6          | **true**   | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = hl_lt(
            3,
            MarkdownDecoration(bold = true)
        ),
    )

    @test result == expected

    # == hl_leq ============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| _1_        | _false_    | _1.0_      | _1_        |
| _2_        | _true_     | _2.0_      | _2_        |
| _3_        | _false_    | _3.0_      | _3_        |
| 4          | _true_     | 4.0        | 4          |
| 5          | _false_    | 5.0        | 5          |
| 6          | _true_     | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = hl_leq(
            3,
            MarkdownDecoration(italic = true)
        ),
    )

    @test result == expected

    # == hl_gt =============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| 3          | false      | 3.0        | 3          |
| `4`        | true       | `4.0`      | `4`        |
| `5`        | false      | `5.0`      | `5`        |
| `6`        | true       | `6.0`      | `6`        |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = hl_gt(
            3,
            MarkdownDecoration(code = true)
        ),
    )

    @test result == expected

    # == hl_geq ============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| ~3~        | false      | ~3.0~      | ~3~        |
| ~4~        | true       | ~4.0~      | ~4~        |
| ~5~        | false      | ~5.0~      | ~5~        |
| ~6~        | true       | ~6.0~      | ~6~        |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        highlighters = hl_geq(
            3,
            MarkdownDecoration(strikethrough = true)
        ),
    )

    @test result == expected

    # == hl_value ==========================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3**  | **Col. 4** |
|-----------:|-----------:|------------:|-----------:|
| 1          | false      | 1.0         | 1          |
| 2          | true       | 2.0         | 2          |
| **_~3~_**  | false      | **_~3.0~_** | **_~3~_**  |
| 4          | true       | 4.0         | 4          |
| 5          | false      | 5.0         | 5          |
| 6          | true       | 6.0         | 6          |
"""

    result = pretty_table(
        String, data;
        backend = Val(:markdown),
        highlighters = hl_value(
            3,
            MarkdownDecoration(bold = true, italic = true, strikethrough = true)
        ),
    )

    @test result == expected
end
