## Description #############################################################################
#
#  Tests of reported issues.
#
############################################################################################

struct NewLineObject end
Base.show(io::IO, ::NewLineObject) = print(io, "a\nb\nc")

@testset "Issue #4 - Header with escape sequences" begin

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │   2\\n │   3 │ 4 │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    result = pretty_table(
        String,
        data;
        header = ["1", "2\n", "3", "4"]
    )
    @test result == expected
end

@testset "Issue #9 - Printing table with row number column and sub-headers" begin
    expected = """
┌─────┬───┬───────┬─────┬────┐
│ Row │ 1 │     2 │   3 │  4 │
│     │ 5 │     6 │   7 │  8 │
│     │ 9 │    10 │  11 │ 12 │
├─────┼───┼───────┼─────┼────┤
│   1 │ 1 │ false │ 1.0 │  1 │
│   2 │ 2 │  true │ 2.0 │  2 │
│   3 │ 3 │ false │ 3.0 │  3 │
│   4 │ 4 │  true │ 4.0 │  4 │
│   5 │ 5 │ false │ 5.0 │  5 │
│   6 │ 6 │  true │ 6.0 │  6 │
└─────┴───┴───────┴─────┴────┘
"""
    result = pretty_table(
        String,
        data;
        header = (
            [1,  2,  3,  4],
            [5,  6,  7,  8],
            [9, 10, 11, 12]
        ),
        show_row_number = true
    )
    @test result == expected
end

@testset "Issue #10 - Size of the row number column without header" begin
    v = 0:1:6

    expected = """
┌───┬───┐
│ 1 │ 0 │
│ 2 │ 1 │
│ 3 │ 2 │
│ 4 │ 3 │
│ 5 │ 4 │
│ 6 │ 5 │
│ 7 │ 6 │
└───┴───┘
"""

    result = pretty_table(String, v; show_header = false, show_row_number = true)
    @test result == expected
end

@testset "Issue #19 - ft_printf with cells that are not numbers" begin
    matrix = [1 1; 2 2; 3 3; "teste" "teste"; 4 4; 5 5; true true; :s :s]

    expected = """
┌────────────┬────────┐
│     Col. 1 │ Col. 2 │
├────────────┼────────┤
│       1.00 │      1 │
│       2.00 │      2 │
│       3.00 │      3 │
│      teste │  teste │
│       4.00 │      4 │
│       5.00 │      5 │
│       1.00 │   true │
│          s │      s │
└────────────┴────────┘
"""

    result = pretty_table(String, matrix; formatters = ft_printf("%10.2f", [1]))
    @test result == expected

end

@testset "Issue #22 - Strings with quotes" begin
    # Without linebreaks.
    matrix = [1 "teste\"teste"
              2 "teste\"\"teste"]

    expected = """
┌────────┬──────────────┐
│ Col. 1 │       Col. 2 │
├────────┼──────────────┤
│      1 │  teste"teste │
│      2 │ teste""teste │
└────────┴──────────────┘
"""

    result = pretty_table(String, matrix)
    @test result == expected

    # With linebreaks.
    matrix = [ 1 """
    function str(str = "one string")
        return str
    end"""
    2 """
    function str(str = "")
        if isempty(str)
            return "one string"
        else
            return str
        end
    end"""]

    expected = """
┌────────┬──────────────────────────────────┐
│ Col. 1 │ Col. 2                           │
├────────┼──────────────────────────────────┤
│ 1      │ function str(str = "one string") │
│        │     return str                   │
│        │ end                              │
│ 2      │ function str(str = "")           │
│        │     if isempty(str)              │
│        │         return "one string"      │
│        │     else                         │
│        │         return str               │
│        │     end                          │
│        │ end                              │
└────────┴──────────────────────────────────┘
"""

    result = pretty_table(String, matrix; alignment = :l, linebreaks = true)

    @test result == expected
end

@testset "Issue #24 - Tables compatibility" begin
    # Labeld tuple of vectors (satisfies Tables interface).
    ctable = (x = Int64[1, 2, 3, 4], y = ["a", "b", "c", "d"])

    cresult = sprint(pretty_table, ctable)

    expected = """
┌───────┬────────┐
│     x │      y │
│ Int64 │ String │
├───────┼────────┤
│     1 │      a │
│     2 │      b │
│     3 │      c │
│     4 │      d │
└───────┴────────┘
"""

  @test cresult == expected
end

@testset "Issue #28 - Tables.jl API must have priority when printing" begin
    # A LabeldTuple is compliant with Tables.jl API.
    table = (x = Int64(1):Int64(3),
             y = 'a':'c',
             z = ["String 1";"String 2";"String 3"]);

    # Thus, the following 3 calls must provide the same results.
    result_1 = pretty_table(String, table)
    result_2 = pretty_table(String, Tables.rowtable(table))
    result_3 = pretty_table(String, Tables.columns(table))

    expected = """
┌───────┬──────┬──────────┐
│     x │    y │        z │
│ Int64 │ Char │   String │
├───────┼──────┼──────────┤
│     1 │    a │ String 1 │
│     2 │    b │ String 2 │
│     3 │    c │ String 3 │
└───────┴──────┴──────────┘
"""

    @test result_1 == result_2 == result_3 == expected
end

@testset "Issue #93 - Cropping with max. column width" begin
    matrix = [1111111111111111111 2222222222222222222 3333333333333333333
              1111111111111111111 2222222222222222222 3333333333333333333]

    expected = """
┌──────────────────┬────────────────────
│           Col. 1 │           Col. 2  ⋯
├──────────────────┼────────────────────
│ 111111111111111… │ 222222222222222…  ⋯
│ 111111111111111… │ 222222222222222…  ⋯
└──────────────────┴────────────────────
                        1 column omitted
"""

    result = pretty_table(String, matrix;
                          crop = :both,
                          display_size = (-1, 40),
                          maximum_columns_width = 16)

    @test result == expected
end

@testset "Issue #112 - Segmentation fault due to alignment anchor" begin
    matrix = [j ∈ [1,2,3] ? 10.0^(mod(i+j,8)) : missing for i = 1:30, j = 1:30];

    expected = """
┌────────────┬────────────┬─────────────
│     Col. 1 │     Col. 2 │     Col. 3 ⋯
├────────────┼────────────┼─────────────
│    100.0   │   1000.0   │  10000.0   ⋯
│   1000.0   │  10000.0   │ 100000.0   ⋯
│  10000.0   │ 100000.0   │      1.0e6 ⋯
│ 100000.0   │      1.0e6 │      1.0e7 ⋯
│      1.0e6 │      1.0e7 │      1.0   ⋯
│      1.0e7 │      1.0   │     10.0   ⋯
│      1.0   │     10.0   │    100.0   ⋯
│     10.0   │    100.0   │   1000.0   ⋯
│    100.0   │   1000.0   │  10000.0   ⋯
│   1000.0   │  10000.0   │ 100000.0   ⋯
│  10000.0   │ 100000.0   │      1.0e6 ⋯
│ 100000.0   │      1.0e6 │      1.0e7 ⋯
│     ⋮      │     ⋮      │     ⋮      ⋱
└────────────┴────────────┴─────────────
          27 columns and 18 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(0 => [r"\."]),
        crop = :both,
        display_size = (20, 40)
    )

    @test result == expected

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(i => [r"\."] for i in 1:1000),
        crop = :both,
        display_size = (20, 40)
    )

    @test result == expected

    expected = """
┌─────┬────────────┬──────────┬──────────────
│ Row │     Col. 1 │   Col. 2 │     Col. 3  ⋯
├─────┼────────────┼──────────┼──────────────
│   1 │    100.0   │   1000.0 │  10000.0    ⋯
│   2 │   1000.0   │  10000.0 │ 100000.0    ⋯
│   3 │  10000.0   │ 100000.0 │      1.0e6  ⋯
│   4 │ 100000.0   │    1.0e6 │      1.0e7  ⋯
│   5 │      1.0e6 │    1.0e7 │      1.0    ⋯
│   6 │      1.0e7 │      1.0 │     10.0    ⋯
│   7 │      1.0   │     10.0 │    100.0    ⋯
│   8 │     10.0   │    100.0 │   1000.0    ⋯
│   9 │    100.0   │   1000.0 │  10000.0    ⋯
│  10 │   1000.0   │  10000.0 │ 100000.0    ⋯
│  11 │  10000.0   │ 100000.0 │      1.0e6  ⋯
│  12 │ 100000.0   │    1.0e6 │      1.0e7  ⋯
│  ⋮  │     ⋮      │    ⋮     │     ⋮       ⋱
└─────┴────────────┴──────────┴──────────────
               27 columns and 18 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(i => [r"\."] for i in vcat(1, 3:1000)),
        crop = :both,
        display_size = (20, 45),
        show_row_number = true
    )

    @test result == expected

    expected = """
┌─────┬──────┬────────────┬──────────┬────────────
│ Row │      │     Col. 1 │   Col. 2 │     Col.  ⋯
├─────┼──────┼────────────┼──────────┼────────────
│   1 │ NAME │    100.0   │   1000.0 │  10000.0  ⋯
│   2 │ NAME │   1000.0   │  10000.0 │ 100000.0  ⋯
│   3 │ NAME │  10000.0   │ 100000.0 │      1.0e ⋯
│   4 │ NAME │ 100000.0   │    1.0e6 │      1.0e ⋯
│   5 │ NAME │      1.0e6 │    1.0e7 │      1.0  ⋯
│   6 │ NAME │      1.0e7 │      1.0 │     10.0  ⋯
│   7 │ NAME │      1.0   │     10.0 │    100.0  ⋯
│   8 │ NAME │     10.0   │    100.0 │   1000.0  ⋯
│   9 │ NAME │    100.0   │   1000.0 │  10000.0  ⋯
│  10 │ NAME │   1000.0   │  10000.0 │ 100000.0  ⋯
│  11 │ NAME │  10000.0   │ 100000.0 │      1.0e ⋯
│  12 │ NAME │ 100000.0   │    1.0e6 │      1.0e ⋯
│  ⋮  │  ⋮   │     ⋮      │    ⋮     │     ⋮     ⋱
└─────┴──────┴────────────┴──────────┴────────────
                    28 columns and 18 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(i => [r"\."] for i in vcat(1, 3:1000)),
        crop = :both,
        display_size = (20, 50),
        row_labels = ["NAME" for i in 1:30],
        show_row_number = true
    )

    @test result == expected
end

@testset "Issue #118 - Cropping empty columns" begin
    matrix = hcat(1:1:9, 1:1:9, fill("", 9), fill("", 9), fill("", 9))
    header = [1, 2, "", "", ""]

    expected = """
┌───┬───┬───┬───┬───┐
│ 1 │ 2 │   │   │   │
├───┼───┼───┼───┼───┤
│ 1 │ 1 │   │   │   │
│ 2 │ 2 │   │   │   │
│ 3 │ 3 │   │   │   │
│ 4 │ 4 │   │   │   │
│ 5 │ 5 │   │   │   │
│ 6 │ 6 │   │   │   │
│ 7 │ 7 │   │   │   │
│ 8 │ 8 │   │   │   │
│ 9 │ 9 │   │   │   │
└───┴───┴───┴───┴───┘
"""

    result = pretty_table(String, matrix, header = header)
    @test result == expected

    expected = """
┌───┬───┬───┬───
│ 1 │ 2 │   │  ⋯
├───┼───┼───┼───
│ 1 │ 1 │   │  ⋯
│ 2 │ 2 │   │  ⋯
│ 3 │ 3 │   │  ⋯
│ 4 │ 4 │   │  ⋯
│ ⋮ │ ⋮ │ ⋮ │  ⋱
└───┴───┴───┴───
2 columns and 5 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        header = header,
        crop = :both,
        display_size = (12, 16)
    )
    @test result == expected

    expected = """
┌───┬───┬───┬───
│ 1 │ 2 │   │  ⋯
├───┼───┼───┼───
│ 1 │ 1 │   │  ⋯
│ 2 │ 2 │   │  ⋯
│ ⋮ │ ⋮ │ ⋮ │  ⋱
│ 8 │ 8 │   │  ⋯
│ 9 │ 9 │   │  ⋯
└───┴───┴───┴───
2 columns and 5 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        header = header,
        crop = :both,
        display_size = (12, 16),
        vcrop_mode = :middle
    )
    @test result == expected
end

@testset "Issue #133 - Horizontal lines with middle cropping" begin
    matrix = [collect(0:1:100) collect(0:2:200) collect(0:3:300)]

    expected = """
┌─────┬────┬────────┬────────┬─────
│ Row │    │ Col. 1 │ Col. 2 │ Co ⋯
├─────┼────┼────────┼────────┼─────
│   1 │  0 │      0 │      0 │    ⋯
│   2 │  1 │      1 │      2 │    ⋯
│   3 │  2 │      2 │      4 │    ⋯
│   4 │  3 │      3 │      6 │    ⋯
│   5 │  4 │      4 │      8 │    ⋯
├─────┼────┼────────┼────────┼─────
│   6 │  5 │      5 │     10 │    ⋯
│   7 │  6 │      6 │     12 │    ⋯
│   8 │  7 │      7 │     14 │    ⋯
│   9 │  8 │      8 │     16 │    ⋯
│  10 │  9 │      9 │     18 │    ⋯
├─────┼────┼────────┼────────┼─────
│  ⋮  │ ⋮  │   ⋮    │   ⋮    │    ⋱
└─────┴────┴────────┴────────┴─────
       1 column and 91 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        body_hlines = collect(0:5:100),
        display_size = (20, 35),
        row_labels = 0:1:100,
        show_row_number = true
    )

    @test result == expected

    expected = """
┌─────┬─────┬────────┬────────┬────
│ Row │     │ Col. 1 │ Col. 2 │ C ⋯
├─────┼─────┼────────┼────────┼────
│   1 │   0 │      0 │      0 │   ⋯
│   2 │   1 │      1 │      2 │   ⋯
│   3 │   2 │      2 │      4 │   ⋯
│   4 │   3 │      3 │      6 │   ⋯
│   5 │   4 │      4 │      8 │   ⋯
├─────┼─────┼────────┼────────┼────
│  ⋮  │  ⋮  │   ⋮    │   ⋮    │   ⋱
│  97 │  96 │     96 │    192 │   ⋯
│  98 │  97 │     97 │    194 │   ⋯
│  99 │  98 │     98 │    196 │   ⋯
│ 100 │  99 │     99 │    198 │   ⋯
├─────┼─────┼────────┼────────┼────
│ 101 │ 100 │    100 │    200 │   ⋯
└─────┴─────┴────────┴────────┴────
       1 column and 91 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        body_hlines = collect(0:5:100),
        display_size = (20, 35),
        row_labels = 0:1:100,
        show_row_number = true,
        vcrop_mode = :middle
    )

    @test result == expected
end

@testset "Issue #149 - Column width and horizontal cropping" begin
    matrix = hcat(["a"^100 for _ in 1:100], 1:100, 1:100, 1:2:200);

    expected = """
┌──────────────────────────────────┬────────┬────────┬────────┐
│                           Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├──────────────────────────────────┼────────┼────────┼────────┤
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      1 │      1 │      1 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      2 │      2 │      3 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      3 │      3 │      5 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      4 │      4 │      7 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      5 │      5 │      9 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      6 │      6 │     11 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      7 │      7 │     13 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      8 │      8 │     15 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      9 │      9 │     17 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     10 │     10 │     19 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     11 │     11 │     21 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     12 │     12 │     23 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     13 │     13 │     25 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     14 │     14 │     27 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     15 │     15 │     29 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     16 │     16 │     31 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     17 │     17 │     33 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     18 │     18 │     35 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     19 │     19 │     37 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     20 │     20 │     39 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     21 │     21 │     41 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     22 │     22 │     43 │
│                ⋮                 │   ⋮    │   ⋮    │   ⋮    │
└──────────────────────────────────┴────────┴────────┴────────┘
                                                78 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (30, 100),
        maximum_columns_width = 32
    )

    @test result == expected

    expected = """
┌──────────────────────────────────┬────────┬────────┬────────┐
│                           Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├──────────────────────────────────┼────────┼────────┼────────┤
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      1 │      1 │      1 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      2 │      2 │      3 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      3 │      3 │      5 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      4 │      4 │      7 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      5 │      5 │      9 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      6 │      6 │     11 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      7 │      7 │     13 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      8 │      8 │     15 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │      9 │      9 │     17 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     10 │     10 │     19 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     11 │     11 │     21 │
│                ⋮                 │   ⋮    │   ⋮    │   ⋮    │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     90 │     90 │    179 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     91 │     91 │    181 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     92 │     92 │    183 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     93 │     93 │    185 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     94 │     94 │    187 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     95 │     95 │    189 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     96 │     96 │    191 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     97 │     97 │    193 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     98 │     98 │    195 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │     99 │     99 │    197 │
│ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… │    100 │    100 │    199 │
└──────────────────────────────────┴────────┴────────┴────────┘
                                                78 rows omitted
"""

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (30, 100),
        maximum_columns_width = 32,
        vcrop_mode = :middle
    )

    @test result == expected

    # == Using Alignment Regex with Big Headers ============================================

    # This test is not directly related to the bug, but describes a bug introduced in the
    # first version of the algorithm to fix the issue.

    matrix = hcat(
        Any[10.0^i for i in -10:1:10],
        Any[i for i in 0:1:20]
    )

    expected = """
┌──────────────┬────────────┐
│   Header one │ Header two │
├──────────────┼────────────┤
│      1.0e-10 │         0  │
│      1.0e-9  │         1  │
│      1.0e-8  │         2  │
│      1.0e-7  │         3  │
│      1.0e-6  │         4  │
│      1.0e-5  │         5  │
│      0.0001  │         6  │
│      0.001   │         7  │
│      0.01    │         8  │
│      0.1     │         9  │
│      1.0     │         10 │
│     10.0     │         11 │
│    100.0     │         12 │
│   1000.0     │         13 │
│  10000.0     │         14 │
│ 100000.0     │         15 │
│      1.0e6   │         16 │
│      1.0e7   │         17 │
│      1.0e8   │         18 │
│      1.0e9   │         19 │
│      1.0e10  │         20 │
└──────────────┴────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(0 => [r"\."]),
        header = ["Header one", "Header two"]
    )

    @test result == expected

    expected = """
┌──────────────┬────────────┐
│  Header one  │ Header two │
├──────────────┼────────────┤
│      1.0e-10 │     0      │
│      1.0e-9  │     1      │
│      1.0e-8  │     2      │
│      1.0e-7  │     3      │
│      1.0e-6  │     4      │
│      1.0e-5  │     5      │
│      0.0001  │     6      │
│      0.001   │     7      │
│      0.01    │     8      │
│      0.1     │     9      │
│      1.0     │     10     │
│     10.0     │     11     │
│    100.0     │     12     │
│   1000.0     │     13     │
│  10000.0     │     14     │
│ 100000.0     │     15     │
│      1.0e6   │     16     │
│      1.0e7   │     17     │
│      1.0e8   │     18     │
│      1.0e9   │     19     │
│      1.0e10  │     20     │
└──────────────┴────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment = :c,
        alignment_anchor_regex = Dict(0 => [r"\."]),
        header = ["Header one", "Header two"]
    )

    @test result == expected

    expected = """
┌──────────────┬────────────┐
│ Header one   │ Header two │
├──────────────┼────────────┤
│      1.0e-10 │ 0          │
│      1.0e-9  │ 1          │
│      1.0e-8  │ 2          │
│      1.0e-7  │ 3          │
│      1.0e-6  │ 4          │
│      1.0e-5  │ 5          │
│      0.0001  │ 6          │
│      0.001   │ 7          │
│      0.01    │ 8          │
│      0.1     │ 9          │
│      1.0     │ 10         │
│     10.0     │ 11         │
│    100.0     │ 12         │
│   1000.0     │ 13         │
│  10000.0     │ 14         │
│ 100000.0     │ 15         │
│      1.0e6   │ 16         │
│      1.0e7   │ 17         │
│      1.0e8   │ 18         │
│      1.0e9   │ 19         │
│      1.0e10  │ 20         │
└──────────────┴────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment = :l,
        alignment_anchor_regex = Dict(0 => [r"\."]),
        header = ["Header one", "Header two"]
    )

    @test result == expected

    expected = """
┌──────────────┬────
│ Header one   │ H ⋯
├──────────────┼────
│      1.0e-10 │ 0 ⋯
│      1.0e-9  │ 1 ⋯
│      1.0e-8  │ 2 ⋯
│      1.0e-7  │ 3 ⋯
│      1.0e-6  │ 4 ⋯
│      1.0e-5  │ 5 ⋯
│      0.0001  │ 6 ⋯
│      0.001   │ 7 ⋯
│      0.01    │ 8 ⋯
│      0.1     │ 9 ⋯
│      1.0     │ 1 ⋯
│     10.0     │ 1 ⋯
│    100.0     │ 1 ⋯
│   1000.0     │ 1 ⋯
│  10000.0     │ 1 ⋯
│ 100000.0     │ 1 ⋯
│      1.0e6   │ 1 ⋯
│      1.0e7   │ 1 ⋯
│      1.0e8   │ 1 ⋯
│      1.0e9   │ 1 ⋯
│      1.0e10  │ 2 ⋯
└──────────────┴────
    1 column omitted
"""

    result = pretty_table(
        String,
        matrix;
        alignment = :l,
        alignment_anchor_regex = Dict(0 => [r"\."]),
        crop = :both,
        display_size = (-1, 20),
        header = ["Header one", "Header two"]
    )

    @test result == expected
end

@testset "Issue #153 - Alignment anchor regex with UTF-8 chars" begin
    matrix = ["¹⁹/₄", "¹⁰/₄₁", "⁴²⁵/₁₁₄", "⁷⁷⁷⁷⁷⁷/₄₈₈₈₈₈₈₈₈₈"]

    expected = """
┌───────────────────┐
│            Col. 1 │
├───────────────────┤
│     ¹⁹/₄          │
│     ¹⁰/₄₁         │
│    ⁴²⁵/₁₁₄        │
│ ⁷⁷⁷⁷⁷⁷/₄₈₈₈₈₈₈₈₈₈ │
└───────────────────┘
"""

    result = pretty_table(
        String,
        matrix;
        alignment_anchor_regex = Dict(0 => [r"/"])
    )
    @test result == expected
end

@testset "Issue #154 - Alignment anchor regex with unvalid columns" begin
    data = [1 2 3]

    expected = """
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │      3 │
└────────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        data;
        alignment_anchor_regex = Dict(10 => [r"/"])
    )
    @test result == expected

    result = pretty_table(
        String,
        data;
        alignment_anchor_regex = Dict(-10 => [r"/"])
    )
    @test result == expected

    result = pretty_table(
        String,
        data;
        alignment_anchor_regex = Dict(-10 => [r"/"], -5 => [r"\."])
    )
    @test result == expected
end

@testset "Issue #161 - Wrong computation of EOL when using CustomTextCells" begin
    g = crayon"green bold"
    y = crayon"yellow bold"
    b = crayon"blue bold"

    ansi_table = hcat(
        hcat([AnsiTextCell("$(g)This $(y)is $(b)awesome!") for _ in 1:10]...)...
    )

    expected = """
┌──────────┬────────
│   Col. 1 │   Col ⋯
├──────────┼────────
│ \e[32;1mThis \e[33;1mis\e[0m… │ \e[32;1mThis\e[0m… ⋯
└──────────┴────────
   9 columns omitted
"""

    result = pretty_table(
        String,
        ansi_table;
        crop = :both,
        display_size = (-1, 20),
        maximum_columns_width = 8
    )

    @test expected == result
end

@testset "Issue #170 - Pringint of UndefInitializer()" begin
    v = Vector{Any}(undef, 5)
    v[1] = undef
    v[2] = "String"
    v[5] = π

    expected = """
┌────────────────────┐
│             Col. 1 │
├────────────────────┤
│ UndefInitializer() │
│             String │
│             #undef │
│             #undef │
│                  π │
└────────────────────┘
"""

    result = pretty_table(
        String,
        v
    )

    @test result == expected

    expected = """
┌────────────────────┐
│             Col. 1 │
├────────────────────┤
│ UndefInitializer() │
│           "String" │
│             #undef │
│             #undef │
│                  π │
└────────────────────┘
"""

    result = pretty_table(
        String,
        v;
        renderer = :show
    )

    @test result == expected
end

@testset "Issue #179 - Header does not fit into the display" begin
    header = (
        ["Column 1", "Column 2", "Column 3", "Column 4"],
        ["Int", "Bool", "Float", "Hex"]
    )

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │ Column 4 │
│      Int │     Bool │    Float │      Hex │
│    ⋮     │    ⋮     │    ⋮     │    ⋮     │
└──────────┴──────────┴──────────┴──────────┘
                               6 rows omitted
"""

    for r in 1:8
        result = pretty_table(
            String,
            data;
            crop = :both,
            display_size = (r, -1),
            header = header,
        )

        @test expected == result


        result = pretty_table(
            String,
            data;
            crop = :both,
            display_size = (r, -1),
            header = header,
            vcrop_mode = :middle,
        )
    end

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │ Column 4 │
│      Int │     Bool │    Float │      Hex │
├──────────┼──────────┼──────────┼──────────┤
│    ⋮     │    ⋮     │    ⋮     │    ⋮     │
└──────────┴──────────┴──────────┴──────────┘
                               6 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (9, -1),
        header = header,
    )

    @test expected == result

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (9, -1),
        header = header,
        vcrop_mode = :middle,
    )

    @test expected == result

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │ Column 4 │
│      Int │     Bool │    Float │      Hex │
├──────────┼──────────┼──────────┼──────────┤
│        1 │    false │      1.0 │        1 │
│    ⋮     │    ⋮     │    ⋮     │    ⋮     │
└──────────┴──────────┴──────────┴──────────┘
                               5 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (10, -1),
        header = header,
    )

    @test expected == result

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (10, -1),
        header = header,
        vcrop_mode = :middle,
    )

    @test expected == result

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │ Column 4 │
│      Int │     Bool │    Float │      Hex │
├──────────┼──────────┼──────────┼──────────┤
│        1 │    false │      1.0 │        1 │
│        2 │     true │      2.0 │        2 │
│    ⋮     │    ⋮     │    ⋮     │    ⋮     │
└──────────┴──────────┴──────────┴──────────┘
                               4 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (11, -1),
        header = header,
    )

    @test expected == result

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│ Column 1 │ Column 2 │ Column 3 │ Column 4 │
│      Int │     Bool │    Float │      Hex │
├──────────┼──────────┼──────────┼──────────┤
│        1 │    false │      1.0 │        1 │
│    ⋮     │    ⋮     │    ⋮     │    ⋮     │
│        6 │     true │      6.0 │        6 │
└──────────┴──────────┴──────────┴──────────┘
                               4 rows omitted
"""
    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (11, -1),
        header = header,
        vcrop_mode = :middle,
    )

    @test expected == result
end

@testset "Issue #194 - Newlines in object that is not string" begin
    nlo = NewLineObject()
    table = [nlo nlo; nlo nlo]

    expected = """
┌─────────┬─────────┐
│  Col. 1 │  Col. 2 │
├─────────┼─────────┤
│ a\\nb\\nc │ a\\nb\\nc │
│ a\\nb\\nc │ a\\nb\\nc │
└─────────┴─────────┘
"""

    result = pretty_table(
        String,
        table
    )

    @test result === expected

    result = pretty_table(
        String,
        table;
        renderer = :show
    )

    @test result === expected


    expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
├────────┼────────┤
│      a │      a │
│      b │      b │
│      c │      c │
│      a │      a │
│      b │      b │
│      c │      c │
└────────┴────────┘
"""

    result = pretty_table(
        String,
        table;
        linebreaks = true
    )

    @test result === expected

    result = pretty_table(
        String,
        table;
        linebreaks = true,
        renderer = :show
    )

    @test result === expected
end

@testset "Issues #201 - Wrong horizontal line when headers is omitted" begin
    matrix = [1 2; 3 4]

    expected = """
 1  2
 3  4
"""

    result = pretty_table(
        String,
        matrix;
        hlines = :none,
        vlines = :none,
        show_header = false
    )

    @test result == expected

    expected = """
──────
 1  2
 3  4
"""

    result = pretty_table(
        String,
        matrix;
        hlines = [0],
        vlines = :none,
        show_header = false
    )

    @test result == expected

    expected = """
 1  2
──────
 3  4
"""

    result = pretty_table(
        String,
        matrix;
        hlines = [1],
        vlines = :none,
        show_header = false
    )

    @test result == expected

    expected = """
──────
 1  2
──────
 3  4
"""

    result = pretty_table(
        String,
        matrix;
        hlines = [0, 1],
        vlines = :none,
        show_header = false
    )

    @test result == expected

    expected = """
──────
 1  2
 3  4
──────
"""

    result = pretty_table(
        String,
        matrix;
        hlines = [0, :end],
        vlines = :none,
        show_header = false
    )

    @test result == expected
end

@testset "Issue #207 - Wrong cell type and alignment with vcrop_mode = :middle" begin
    data = Dict(
        "B" => collect(1:100),
        "A" => [AnsiTextCell(string(x)) for x in collect(1:100)]
    )

    expected = """
┌─────┬───────┬──────────────┐
│ Row │     B │            A │
│     │ Int64 │ AnsiTextCell │
├─────┼───────┼──────────────┤
│   1 │     1 │            1\e[0m │
│   2 │     2 │            2\e[0m │
│   3 │     3 │            3\e[0m │
│  ⋮  │   ⋮   │      ⋮       │
│  98 │    98 │           98\e[0m │
│  99 │    99 │      99     \e[0m │
│ 100 │ 100   │          100\e[0m │
└─────┴───────┴──────────────┘
               94 rows omitted
"""

    result = pretty_table(
        String,
        data;
        cell_alignment = Dict(
            (99,  2) => :c,
            (100, 1) => :l
        ),
        crop = :both,
        display_size = (15, -1),
        show_row_number = true,
        vcrop_mode = :middle
    )

    @test result == expected
end

@testset "Issue #208 - Wrong cell type with custom cells and showing row numbers" begin
    table = Dict(
        :x => ["totally not an a"],
        :xx => [AnsiTextCell("a")],
    )

    expected = """
┌─────┬──────────────┬──────────────────┐
│ Row │           xx │                x │
│     │ AnsiTextCell │           String │
├─────┼──────────────┼──────────────────┤
│   1 │            a\e[0m │ totally not an a │
└─────┴──────────────┴──────────────────┘
"""

    result = pretty_table(String, table; show_row_number = true)

    @test result == expected
end
