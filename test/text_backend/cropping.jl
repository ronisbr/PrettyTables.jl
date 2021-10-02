# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests related to cropping.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Table cropping - bottom vertical cropping" begin
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

    result = pretty_table(String, data; display_size = (10, 10), crop = :none)
    @test result == expected

    result = pretty_table(String, data; display_size = (-1, -1), crop = :both)
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

    result = pretty_table(String, data; display_size = (11, 30), crop = :both)
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

    result = pretty_table(
        String,
        data;
        display_size = (11, 30),
        crop = :horizontal
    )
    @test result == expected

    result = pretty_table(String, data; display_size = (-1, 30), crop = :both)
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

    result = pretty_table(
        String,
        data,
        display_size = (11, 30),
        crop = :vertical
    )
    @test result == expected

    result = pretty_table(String, data; display_size = (11, -1), crop = :both)
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

    result = pretty_table(String, data; display_size = (11, 25), crop = :both)
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

    result = pretty_table(String, data; display_size = (12, -1), crop = :both)
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

    result = pretty_table(
        String,
        data_text;
        crop = :both,
        display_size = (12, -1),
        linebreaks = true
    )
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

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (17, -1),
        linebreaks = true,
        hlines = :all
    )

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
    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (16, -1),
        linebreaks = true,
        hlines = :all
    )

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
    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (15,-1),
        linebreaks = true,
        hlines = :all
    )

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
    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (16, -1),
        linebreaks = true,
        hlines = [0, 1, 2, 3]
    )

    @test result == expected

    # Additional columns
    # --------------------------------------------------------------------------

    expected = """
┌─────┬──────────┬────────┬────────
│ Row │ Row name │ Col. 1 │ Col.  ⋯
├─────┼──────────┼────────┼────────
│   1 │    Row 1 │      1 │  fals ⋯
│   2 │    Row 2 │      2 │   tru ⋯
│   3 │    Row 3 │      3 │  fals ⋯
│   4 │    Row 4 │      4 │   tru ⋯
│  ⋮  │    ⋮     │   ⋮    │   ⋮   ⋱
└─────┴──────────┴────────┴────────
       3 columns and 2 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (12, 35),
        linebreaks = true,
        show_row_number = true,
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row name"
    )

    @test result == expected

    expected = """
┌─────┬──────────┬───────
│ Row │ Row name │ Col. ⋯
├─────┼──────────┼───────
│   1 │    Row 1 │      ⋯
│   2 │    Row 2 │      ⋯
│   3 │    Row 3 │      ⋯
│   4 │    Row 4 │      ⋯
│  ⋮  │    ⋮     │   ⋮  ⋱
└─────┴──────────┴───────
4 columns and 2 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (12, 25),
        linebreaks = true,
        show_row_number = true,
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row name"
    )

    @test result == expected

    expected = """
┌─────┬────────
│ Row │ Row n ⋯
├─────┼────────
│   1 │    Ro ⋯
│   2 │    Ro ⋯
│   3 │    Ro ⋯
│   4 │    Ro ⋯
│  ⋮  │    ⋮  ⋱
└─────┴────────
4 columns and 2 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (12, 15),
        linebreaks = true,
        show_row_number = true,
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row name"
    )

    @test result == expected
end

@testset "Table cropping - middle vertical cropping" begin
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

    result = pretty_table(
        String,
        data;
        crop = :none,
        display_size = (10, 10),
        vcrop_mode = :middle
    )

    @test result == expected

    result = pretty_table(
        String,
        data;
        display_size = (-1, -1),
        crop = :both,
        vcrop_mode = :middle
    )

    @test result == expected

    expected = """
┌────────┬────────┬────────┬──
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼──
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│   ⋮    │   ⋮    │   ⋮    │ ⋱
│      6 │   true │    6.0 │ ⋯
└────────┴────────┴────────┴──
   1 column and 3 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (11, 30),
        vcrop_mode = :middle
    )

    @test result == expected

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (11, 30),
        vcrop_mode = :middle
    )

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

    result = pretty_table(
        String,
        data;
        crop = :horizontal,
        display_size = (11, 30),
        vcrop_mode = :middle
    )

    @test result == expected

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (-1, 30),
        vcrop_mode = :middle
    )

    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│   ⋮    │   ⋮    │   ⋮    │   ⋮    │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
                       3 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :vertical,
        display_size = (11, 30),
        vcrop_mode = :middle
    )

    @test result == expected

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (11, -1),
        vcrop_mode = :middle
    )

    @test result == expected

    expected = """
┌────────┬────────┬──────
│ Col. 1 │ Col. 2 │ Col ⋯
├────────┼────────┼──────
│      1 │  false │     ⋯
│      2 │   true │     ⋯
│   ⋮    │   ⋮    │   ⋮ ⋱
│      6 │   true │     ⋯
└────────┴────────┴──────
2 columns and 3 rows omitted
"""

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (11, 25),
        vcrop_mode = :middle
    )

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

    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (12, -1),
        vcrop_mode = :middle
    )

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
│   ⋮    │   ⋮    │   ⋮    │   ⋮    │
│      6 │  teste │    6.0 │      6 │
│        │  teste │        │        │
└────────┴────────┴────────┴────────┘
                       3 rows omitted
"""

    result = pretty_table(
        String,
        data_text;
        crop = :both,
        display_size = (12, -1),
        linebreaks = true,
        vcrop_mode = :middle
    )

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

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (17, -1),
        linebreaks = true,
        hlines = :all,
        vcrop_mode = :middle
    )

    @test result == expected

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      1 │
│      1 │
│      1 │
├────────┤
│   ⋮    │
├────────┤
│      3 │
│      3 │
│      3 │
└────────┘
1 row omitted
"""
    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (16, -1),
        linebreaks = true,
        hlines = :all,
        vcrop_mode = :middle
    )

    @test result == expected

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      1 │
│      1 │
│      1 │
├────────┤
│   ⋮    │
│      3 │
│      3 │
│      3 │
└────────┘
1 row omitted
"""
    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (15, -1),
        linebreaks = true,
        hlines = :all,
        vcrop_mode = :middle
    )

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

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (16, -1),
        linebreaks = true,
        hlines = [0, 1, 2, 3],
        vcrop_mode = :middle
    )

    @test result == expected

    matrix = ["1\n1\n1"; "1\n2\n3\n4\n5\n6\n7"]

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      1 │
│      1 │
│      1 │
├────────┤
│   ⋮    │
│      4 │
│      5 │
│      6 │
│      7 │
└────────┘
1 row omitted
"""

    result = pretty_table(
        String,
        matrix;
        crop = :both,
        display_size = (16, -1),
        hlines = :all,
        linebreaks = true,
        vcrop_mode = :middle
    )

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

    result = pretty_table(
        String,
        model;
        columns_width = [1, 0, 2, 3, 4, 5, 6, 7, 8, 9],
        alignment = [:l, :l, :r, :c, :r, :c, :l, :l, :c, :r]
    )

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

    result = pretty_table(
        String,
        model;
        columns_width = 6,
        alignment = [:l, :l, :r, :c, :r, :c, :l, :l, :c, :r]
    )

    @test result == expected

    # Sub-header cropping
    # --------------------------------------------------------------------------

    header = (["A",            "B",             "C",            "D"],
              ["First column", "Second column", "Third column", "Fourth column"])

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

    result = pretty_table(
        String,
        data;
        header = header,
        crop_subheader = true
    )

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

    result = pretty_table(
        String,
        data;
        continuation_row_alignment = :l,
        crop = :both,
        display_size = (11, 30)
    )
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

    result = pretty_table(
        String,
        data;
        continuation_row_alignment = :r,
        crop = :both,
        display_size = (11, 30)
    )
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

    result = pretty_table(
        String,
        data;
        alignment = :l,
        continuation_row_alignment = :l,
        crop = :both,
        display_size = (11, 40),
        vlines = :none
    )

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

    result = pretty_table(
        String,
        data;
        header = (
            ["Col. 1", "Col. 2", "Col. 3", "Col. 4"],
            ["A",      "B",      "C",      "D"]
        ),
        crop = :both,
        display_size = (-1, 25),
        ellipsis_line_skip = 3
    )
    @test result == expected
end
