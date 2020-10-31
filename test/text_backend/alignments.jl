# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
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
    result = pretty_table(String, data; alignment = [:l,:r,:c,:r])
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
    result = pretty_table(String, data;
                          alignment = [:l,:r,:c,:r],
                          cell_alignment = Dict( (3,1) => :r,
                                                 (3,2) => :l,
                                                 (1,4) => :l,
                                                 (3,4) => :c,
                                                 (4,4) => :c,
                                                 (6,4) => :l ))
    @test result == expected

    # Headers
    # ==========================================================================

    header = ["A" "B" "C" "D"
              "a" "b" "c" "d"]

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

    result = pretty_table(String, data, header;
                          alignment = [:l,:r,:c,:r],
                          cell_alignment = Dict( (3,1) => :r,
                                                 (3,2) => :l,
                                                 (1,4) => :l,
                                                 (3,4) => :c,
                                                 (4,4) => :c,
                                                 (6,4) => :l ),
                          columns_width = 9,
                          header_alignment = [:l,:c,:r,:r])
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

    result = pretty_table(String, data, header;
                          alignment = [:l,:r,:c,:r],
                          cell_alignment = Dict( (3,1) => :r,
                                                 (3,2) => :l,
                                                 (1,4) => :l,
                                                 (3,4) => :c,
                                                 (4,4) => :c,
                                                 (6,4) => :l ),
                          columns_width = 9,
                          header_alignment = [:l,:c,:r,:r],
                          header_cell_alignment = Dict( (1,1) => :r,
                                                        (2,2) => :l,
                                                        (2,4) => :c))
    @test result == expected
end
