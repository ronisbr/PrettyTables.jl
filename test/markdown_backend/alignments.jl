## Description #############################################################################
#
# Tests of alignments.
#
############################################################################################

@testset "Column Alignments" begin
    # == Left ==============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|:-----------|:-----------|:-----------|:-----------|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| 3          | false      | 3.0        | 3          |
| 4          | true       | 4.0        | 4          |
| 5          | false      | 5.0        | 5          |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        alignment = :l,
        backend = Val(:markdown),
    )

    @test result == expected

    # == Center ============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|:----------:|:----------:|:----------:|:----------:|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| 3          | false      | 3.0        | 3          |
| 4          | true       | 4.0        | 4          |
| 5          | false      | 5.0        | 5          |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        alignment = :c,
        backend = Val(:markdown),
    )

    @test result == expected

    # == Right =============================================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| 3          | false      | 3.0        | 3          |
| 4          | true       | 4.0        | 4          |
| 5          | false      | 5.0        | 5          |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        alignment = :r,
        backend = Val(:markdown),
    )

    @test result == expected

    # == Per Column Configuration ==========================================================

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|:----------:|:-----------|-----------:|
| 1          | false      | 1.0        | 1          |
| 2          | true       | 2.0        | 2          |
| 3          | false      | 3.0        | 3          |
| 4          | true       | 4.0        | 4          |
| 5          | false      | 5.0        | 5          |
| 6          | true       | 6.0        | 6          |
"""

    result = pretty_table(
        String,
        data;
        alignment = [:r, :c, :l, :r],
        backend = Val(:markdown),
    )

    @test result == expected
end
