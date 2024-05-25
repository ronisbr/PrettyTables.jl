## Description #############################################################################
#
# Tests of column width.
#
############################################################################################

@testset "Minimum and maximum column width" begin
    header = ["A", "B", "C", "D"]

    # == Minimum column width ==============================================================

    expected = """
┌──────┬───────┬──────┬──────┐
│    A │     B │    C │    D │
├──────┼───────┼──────┼──────┤
│    1 │ false │  1.0 │    1 │
│    2 │  true │  2.0 │    2 │
│    3 │ false │  3.0 │    3 │
│    4 │  true │  4.0 │    4 │
│    5 │ false │  5.0 │    5 │
│    6 │  true │  6.0 │    6 │
└──────┴───────┴──────┴──────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        minimum_columns_width = 4
    )
    @test result == expected

    # Precedence of `columns_width`.

    expected = """
┌────┬────┬────┬────┐
│  A │  B │  C │  D │
├────┼────┼────┼────┤
│  1 │ f… │ 1… │  1 │
│  2 │ t… │ 2… │  2 │
│  3 │ f… │ 3… │  3 │
│  4 │ t… │ 4… │  4 │
│  5 │ f… │ 5… │  5 │
│  6 │ t… │ 6… │  6 │
└────┴────┴────┴────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        columns_width = 2,
        minimum_columns_width = 4
    )
    @test result == expected

    # Test with a vector in `minimum_column_width`.

    expected = """
┌────┬───────┬────────┬──────────┐
│  A │     B │      C │        D │
├────┼───────┼────────┼──────────┤
│  1 │ false │    1.0 │        1 │
│  2 │  true │    2.0 │        2 │
│  3 │ false │    3.0 │        3 │
│  4 │  true │    4.0 │        4 │
│  5 │ false │    5.0 │        5 │
│  6 │  true │    6.0 │        6 │
└────┴───────┴────────┴──────────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        minimum_columns_width = [2, 4, 6, 8]
    )
    @test result == expected

    # Test with the option `equal_columns_width``.

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│        A │        B │        C │        D │
├──────────┼──────────┼──────────┼──────────┤
│        1 │    false │      1.0 │        1 │
│        2 │     true │      2.0 │        2 │
│        3 │    false │      3.0 │        3 │
│        4 │     true │      4.0 │        4 │
│        5 │    false │      5.0 │        5 │
│        6 │     true │      6.0 │        6 │
└──────────┴──────────┴──────────┴──────────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        minimum_columns_width = [2, 4, 6, 8],
        equal_columns_width = true
    )
    @test result == expected

    # == Maximum column width ==============================================================

    expected = """
┌───┬─────┬─────┬───┐
│ A │   B │   C │ D │
├───┼─────┼─────┼───┤
│ 1 │ fa… │ 1.0 │ 1 │
│ 2 │ tr… │ 2.0 │ 2 │
│ 3 │ fa… │ 3.0 │ 3 │
│ 4 │ tr… │ 4.0 │ 4 │
│ 5 │ fa… │ 5.0 │ 5 │
│ 6 │ tr… │ 6.0 │ 6 │
└───┴─────┴─────┴───┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        maximum_columns_width = 3
    )
    @test result == expected

    # Precedence of `columns_width`.

    expected = """
┌───┬────┬─────┬──────┐
│ A │  B │   C │    D │
├───┼────┼─────┼──────┤
│ 1 │ f… │ 1.0 │    1 │
│ 2 │ t… │ 2.0 │    2 │
│ 3 │ f… │ 3.0 │    3 │
│ 4 │ t… │ 4.0 │    4 │
│ 5 │ f… │ 5.0 │    5 │
│ 6 │ t… │ 6.0 │    6 │
└───┴────┴─────┴──────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        columns_width = [1, 2, 3, 4],
        maximum_columns_width = 3
    )
    @test result == expected

    # Test with a vector in `maximum_column_width`.

    expected = """
┌───┬─────┬────┬───┐
│ A │   B │  C │ D │
├───┼─────┼────┼───┤
│ 1 │ fa… │ 1… │ 1 │
│ 2 │ tr… │ 2… │ 2 │
│ 3 │ fa… │ 3… │ 3 │
│ 4 │ tr… │ 4… │ 4 │
│ 5 │ fa… │ 5… │ 5 │
│ 6 │ tr… │ 6… │ 6 │
└───┴─────┴────┴───┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        maximum_columns_width = [20, 3, 2, 5]
    )
    @test result == expected

    # Test with the option `equal_columns_width``.

    expected = """
┌─────┬─────┬─────┬─────┐
│   A │   B │   C │   D │
├─────┼─────┼─────┼─────┤
│   1 │ fa… │ 1.0 │   1 │
│   2 │ tr… │ 2.0 │   2 │
│   3 │ fa… │ 3.0 │   3 │
│   4 │ tr… │ 4.0 │   4 │
│   5 │ fa… │ 5.0 │   5 │
│   6 │ tr… │ 6.0 │   6 │
└─────┴─────┴─────┴─────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        equal_columns_width = true,
        maximum_columns_width = [20, 3, 2, 5]
    )
    @test result == expected
end
