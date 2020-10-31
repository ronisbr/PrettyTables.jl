# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#    Tests related to cropping.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Table cropping" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(String, data, screen_size = (10,10), crop = :none)
    @test result == expected

    result = pretty_table(String, data, screen_size = (-1,-1), crop = :both)
    @test result == expected

    expected = """
┌────────┬────────┬────────┬──
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼──
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│      3 │  false │    3.0 │ ⋯
│   ⋮    │   ⋮    │   ⋮    │ ⋱
└────────┴────────┴────────┴──
   1 column and 3 rows omitted
"""

    result = pretty_table(String, data, screen_size = (11,30), crop = :both)
    @test result == expected

    result = pretty_table(String, data, screen_size = (11,30))
    @test result == expected

    expected = """
┌────────┬────────┬────────┬──
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼──
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│      3 │  false │    3.0 │ ⋯
│      4 │   true │    4.0 │ ⋯
│      5 │  false │    5.0 │ ⋯
│      6 │   true │    6.0 │ ⋯
└────────┴────────┴────────┴──
              1 column omitted
"""

    result = pretty_table(String, data, screen_size = (11,30), crop = :horizontal)
    @test result == expected

    result = pretty_table(String, data, screen_size = (-1,30), crop = :both)
    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│   ⋮    │   ⋮    │   ⋮    │   ⋮    │
└────────┴────────┴────────┴────────┘
                       3 rows omitted
"""

    result = pretty_table(String, data, screen_size = (11,30), crop = :vertical)
    @test result == expected

    result = pretty_table(String, data, screen_size = (11,-1), crop = :both)
    @test result == expected

    expected = """
┌────────┬────────┬──────
│ Col. 1 │ Col. 2 │ Col ⋯
├────────┼────────┼──────
│      1 │  false │     ⋯
│      2 │   true │     ⋯
│      3 │  false │     ⋯
│   ⋮    │   ⋮    │   ⋮ ⋱
└────────┴────────┴──────
2 columns and 3 rows omitted
"""

    result = pretty_table(String, data, screen_size = (11,25), crop = :both)
    @test result == expected

    # Limits
    # --------------------------------------------------------------------------

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(String, data, screen_size = (12,-1))
    @test result == expected

    data_text = Any[1    false            1.0     0x01 ;
                    2     true            2.0     0x02 ;
                    3    false            3.0     0x03 ;
                    4     true            4.0     0x04 ;
                    5    false            5.0     0x05 ;
                    6    "teste\nteste"   6.0     0x06 ;]

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│   ⋮    │   ⋮    │   ⋮    │   ⋮    │
└────────┴────────┴────────┴────────┘
                       2 rows omitted
"""

    result = pretty_table(String, data_text,
                          linebreaks = true,
                          screen_size = (12,-1))
    @test result == expected

    # Sub-header cropping
    # --------------------------------------------------------------------------

    header = ["A"            "B"             "C"            "D"
              "First column" "Second column" "Third column" "Fourth column"]

    expected = """
┌───┬───────┬─────┬───┐
│ A │     B │   C │ D │
│ … │ Seco… │ Th… │ … │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    result = pretty_table(String, data, header, crop_subheader = true)

    @test result == expected

    # Linebreaks
    # --------------------------------------------------------------------------

    matrix = ["1\n1\n1"; "2\n2\n2"; "3\n3\n3"]

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      1 │
│      1 │
│      1 │
├────────┤
│      2 │
│      2 │
│      2 │
├────────┤
│      3 │
│      3 │
│      3 │
└────────┘
"""

    result = pretty_table(String, matrix,
                          crop = :both,
                          linebreaks = true,
                          hlines = :all,
                          screen_size = (17,-1))

    @test result == expected

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      1 │
│      1 │
│      1 │
├────────┤
│      2 │
│      2 │
│      2 │
├────────┤
│   ⋮    │
└────────┘
1 row omitted
"""
    result = pretty_table(String, matrix,
                          crop = :both,
                          linebreaks = true,
                          hlines = :all,
                          screen_size = (16,-1))

    @test result == expected

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      1 │
│      1 │
│      1 │
├────────┤
│      2 │
│      2 │
│      2 │
│   ⋮    │
└────────┘
1 row omitted
"""
    result = pretty_table(String, matrix,
                          crop = :both,
                          linebreaks = true,
                          hlines = :all,
                          screen_size = (15,-1))

    @test result == expected

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      1 │
│      1 │
│      1 │
├────────┤
│      2 │
│      2 │
│      2 │
├────────┤
│      3 │
│      3 │
│      3 │
"""
    result = pretty_table(String, matrix,
                          crop = :both,
                          linebreaks = true,
                          hlines = [0,1,2,3],
                          screen_size = (16,-1))

    @test result == expected
end

@testset "Cell cropping" begin

    model = [1.123456789 for i = 1:8, j = 1:10]

    expected = """
┌───┬─────────────┬────┬─────┬──────┬───────┬────────┬─────────┬──────────┬───────────┐
│ … │ Col. 2      │ C… │ Co… │ Col… │ Col.… │ Col. 7 │ Col. 8  │  Col. 9  │   Col. 10 │
├───┼─────────────┼────┼─────┼──────┼───────┼────────┼─────────┼──────────┼───────────┤
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
└───┴─────────────┴────┴─────┴──────┴───────┴────────┴─────────┴──────────┴───────────┘
"""

    result = pretty_table(String, model,
                          columns_width = [1, 0, 2, 3, 4, 5, 6, 7, 8, 9],
                          alignment = [:l, :l, :r, :c, :r, :c, :l, :l, :c, :r])

    expected = """
┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col. 6 │ Col. 7 │ Col. 8 │ Col. 9 │ Col. … │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┼────────┼────────┼────────┤
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
└────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┘
"""

    result = pretty_table(String, model,
                          columns_width = 6,
                          alignment = [:l, :l, :r, :c, :r, :c, :l, :l, :c, :r])

    @test result == expected
end


@testset "Continuation row" begin

    # Continuation row alignment
    # --------------------------------------------------------------------------

    expected = """
┌────────┬────────┬────────┬──
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼──
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│      3 │  false │    3.0 │ ⋯
│ ⋮      │ ⋮      │ ⋮      │ ⋱
└────────┴────────┴────────┴──
   1 column and 3 rows omitted
"""

    result = pretty_table(String, data,
                          continuation_row_alignment = :l,
                          screen_size = (11,30))
    @test result == expected

    expected = """
┌────────┬────────┬────────┬──
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼──
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│      3 │  false │    3.0 │ ⋯
│      ⋮ │      ⋮ │      ⋮ │ ⋱
└────────┴────────┴────────┴──
   1 column and 3 rows omitted
"""

    result = pretty_table(String, data,
                          continuation_row_alignment = :r,
                          screen_size = (11,30))
    @test result == expected

    # Trailing spaces at continuation line
    # --------------------------------------------------------------------------

    expected = """
────────────────────────────────
 Col. 1  Col. 2  Col. 3  Col. 4
────────────────────────────────
 1       false   1.0     1
 2       true    2.0     2
 3       false   3.0     3
 ⋮       ⋮       ⋮       ⋮
────────────────────────────────
                  3 rows omitted
"""

    result = pretty_table(String, data,
                          alignment = :l,
                          continuation_row_alignment = :l,
                          screen_size = (11,40),
                          vlines = :none)

    @test result == expected

    # Skip lines with ellipsis
    # --------------------------------------------------------------------------

    expected = """
┌────────┬────────┬──────
│ Col. 1 │ Col. 2 │ Col ⋯
│      A │      B │     ⋯
├────────┼────────┼──────
│      1 │  false │     ⋯
│      2 │   true │
│      3 │  false │
│      4 │   true │
│      5 │  false │     ⋯
│      6 │   true │
└────────┴────────┴──────
        2 columns omitted
"""

    result = pretty_table(String, data,
                          ["Col. 1" "Col. 2" "Col. 3" "Col. 4"; "A" "B" "C" "D"],
                          screen_size = (-1,25),
                          crop = :both,
                          ellipsis_line_skip = 3)
    @test result == expected
end
