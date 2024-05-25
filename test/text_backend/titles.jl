## Description #############################################################################
#
# Tests of table titles.
#
############################################################################################

@testset "Titles" begin
    title = "This is a very very long title that will be displayed above the table."

    expected = """
This is a very very long title that will be displayed above the table.
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
    result = pretty_table(String, data, title = title)
    @test result == expected

    expected = """
This is a very very long title that …
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
        title = title,
        title_same_width_as_table = true
    )
    @test result == expected

    expected = """
This is a very very long title that
will be displayed above the table.
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
        title = title,
        title_autowrap = true,
        title_same_width_as_table = true
    )
    @test result == expected

    expected = """
 This is a very very long title that
 will be displayed above the table.
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
        title = title,
        title_alignment = :c,
        title_autowrap = true,
        title_same_width_as_table = true
    )
    @test result == expected

    expected = """
  This is a very very long title that
   will be displayed above the table.
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
        title = title,
        title_alignment = :r,
        title_autowrap = true,
        title_same_width_as_table = true
    )
    @test result == expected
end

@testset "Title With Table Cropping" begin

    # == Cropping ==========================================================================

    expected = """
This is a long long long long long…
That has two lines.
┌────────┬────────┬────────┬───────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. ⋯
├────────┼────────┼────────┼───────
│      1 │  false │    1.0 │      ⋯
│      2 │   true │    2.0 │      ⋯
│      3 │  false │    3.0 │      ⋯
│   ⋮    │   ⋮    │   ⋮    │   ⋮  ⋱
└────────┴────────┴────────┴───────
        1 column and 3 rows omitted
"""
    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (13, 35),
        title = "This is a long long long long long long title\nThat has two lines."
    )
    @test result == expected

    expected = """
This is a long long long long long
long title
That has two lines.
┌────────┬────────┬────────┬───────
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. ⋯
├────────┼────────┼────────┼───────
│      1 │  false │    1.0 │      ⋯
│      2 │   true │    2.0 │      ⋯
│   ⋮    │   ⋮    │   ⋮    │   ⋮  ⋱
└────────┴────────┴────────┴───────
        1 column and 4 rows omitted
"""
    result = pretty_table(
        String,
        data;
        crop = :both,
        display_size = (13, 35),
        title = "This is a long long long long long long title\nThat has two lines.",
        title_autowrap = true
    )
    @test result == expected
end
