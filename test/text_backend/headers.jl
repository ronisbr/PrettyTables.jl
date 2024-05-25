## Description #############################################################################
#
# Tests of headers and sub-headers.
#
############################################################################################

@testset "Sub-headers" begin
    expected = """
┌───┬───────┬─────┬───┐
│ 1 │     2 │   3 │ 4 │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""
    result = pretty_table(String, data; header = [1, 2, 3, 4])
    @test result == expected

    result = pretty_table(String, data; header = [1, 2, 3, 4])
    @test result == expected

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │     2 │   3 │ 4 │
│ 5 │     6 │   7 │ 8 │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""
    result = pretty_table(String, data; header = ([1, 2, 3, 4], [5, 6, 7, 8]))
    @test result == expected
end

@testset "Hide Header and Sub-header" begin

    # == Header ============================================================================

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    result = pretty_table(String, data; show_header = false)
    @test result == expected

    result = pretty_table(String, data; header = [1, 2], show_header = false)
    @test result == expected

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │ false │ 1.0 │ 1 │
│ 2 │ true  │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │ true  │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │ true  │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""
    result = pretty_table(
        String,
        data;
        header = [1, 2],
        alignment = :l,
        show_header = false
    )
    @test result == expected

    # == Sub-header ========================================================================

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │     2 │   3 │ 4 │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    header = (
        [1, 2, 3, 4],
        ["this is", "a very very", "big", "sub-header"]
    )
    result = pretty_table(
        String,
        data;
        header = header,
        show_subheader = false
    )
    @test result == expected
end
