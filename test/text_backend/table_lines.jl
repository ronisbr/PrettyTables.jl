# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of table lines.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Horizontal lines" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
├────────┼────────┼────────┼────────┤
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
├────────┼────────┼────────┼────────┤
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(
        String,
        data;
        body_hlines = vcat(findall(x->x == true, data[:,2]))
    )
    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
├........+........+........+........┤
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
├........+........+........+........┤
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(
        String,
        data;
        body_hlines = vcat(findall(x -> x == true, data[:, 2])),
        body_hlines_format = ('├','+','┤','.')
    )
    @test result == expected

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
├───┼───────┼─────┼───┤
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
├───┼───────┼─────┼───┤
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""
    result = pretty_table(
        String,
        data;
        noheader = true,
        body_hlines = vcat(findall(x -> x == true, data[:, 2]))
    )
    @test result == expected

    # Test the case when `hlines` is a symbol
    # --------------------------------------------------------------------------

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
├────────┼────────┼────────┼────────┤
│      2 │   true │    2.0 │      2 │
├────────┼────────┼────────┼────────┤
│      3 │  false │    3.0 │      3 │
├────────┼────────┼────────┼────────┤
│      4 │   true │    4.0 │      4 │
├────────┼────────┼────────┼────────┤
│      5 │  false │    5.0 │      5 │
├────────┼────────┼────────┼────────┤
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(String, data; hlines = :all)
    @test result == expected

    expected = """
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
"""

    result = pretty_table(String, data; hlines = :none)
    @test result == expected
end

@testset "Vertical lines" begin
    expected = """
────────────────────────
  C1     C2     C3   C4
 Int   Bool  Float  Hex
────────────────────────
   1  false    1.0    1
   2   true    2.0    2
   3  false    3.0    3
   4   true    4.0    4
   5  false    5.0    5
   6   true    6.0    6
────────────────────────
"""

    result1 = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        vlines = []
    )
    result2 = pretty_table(
        String, data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        vlines = :none
    )
    @test result1 == expected
    @test result2 == expected

    expected = """
┌────────────────────────┐
│  C1     C2     C3   C4 │
│ Int   Bool  Float  Hex │
├────────────────────────┤
│   1  false    1.0    1 │
│   2   true    2.0    2 │
│   3  false    3.0    3 │
│   4   true    4.0    4 │
│   5  false    5.0    5 │
│   6   true    6.0    6 │
└────────────────────────┘
"""

    result1 = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        vlines = [:begin, :end]
    )
    result2 = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        vlines = [0, 4]
    )
    @test result1 == expected
    @test result2 == expected

    expected = """
┌─────┬────────────────────────┐
│ Row │  C1     C2     C3   C4 │
│     │ Int   Bool  Float  Hex │
├─────┼────────────────────────┤
│   1 │   1  false    1.0    1 │
│   2 │   2   true    2.0    2 │
│   3 │   3  false    3.0    3 │
│   4 │   4   true    4.0    4 │
│   5 │   5  false    5.0    5 │
│   6 │   6   true    6.0    6 │
└─────┴────────────────────────┘
"""

    result = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        vlines = [:begin, 1 ,:end],
        show_row_number = true
    )
    @test result == expected

    expected = """
┌─────┬───────────┬────────────────────────┐
│ Row │ Row names │  C1     C2     C3   C4 │
│     │           │ Int   Bool  Float  Hex │
├─────┼───────────┼────────────────────────┤
│   1 │   Row 1   │   1  false    1.0    1 │
│   2 │   Row 2   │   2   true    2.0    2 │
│   3 │   Row 3   │   3  false    3.0    3 │
│   4 │   Row 4   │   4   true    4.0    4 │
│   5 │   Row 5   │   5  false    5.0    5 │
│   6 │   Row 6   │   6   true    6.0    6 │
└─────┴───────────┴────────────────────────┘
"""

    result = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        vlines = [:begin, 1, 2, :end],
        show_row_number = true,
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row names",
        row_name_alignment = :c
    )
    @test result == expected

    expected = """
┌─────┬───────────┬────────────┬───
│ Row │ Row names │  C1     C2 │  ⋯
│     │           │ Int   Bool │  ⋯
├─────┼───────────┼────────────┼───
│   1 │   Row 1   │   1  false │  ⋯
│   2 │   Row 2   │   2   true │  ⋯
│   3 │   Row 3   │   3  false │  ⋯
│  ⋮  │     ⋮     │  ⋮     ⋮   │  ⋱
└─────┴───────────┴────────────┴───
       2 columns and 3 rows omitted
"""

    result = pretty_table(
        String,
        data;
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        crop = :both,
        display_size = (12, 35),
        show_row_number = true,
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row names",
        row_name_alignment = :c,
        vlines = [:begin, 1, 2, 4, :end]
    )
    @test result == expected
end
