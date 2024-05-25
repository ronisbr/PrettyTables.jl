## Description #############################################################################
#
# Tests of formatters.
#
############################################################################################

@testset "Formatters" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │      1 │      1 │
│      0 │   true │      0 │      0 │
│      3 │  false │      3 │      3 │
│      0 │   true │      0 │      0 │
│      5 │  false │      5 │      5 │
│      0 │   true │      0 │      0 │
└────────┴────────┴────────┴────────┘
"""

    # Single formatter.
    formatter = (data,i,j) -> begin
        if j != 2
            return isodd(i) ? i : 0
        else
            return data
        end
    end
    result = pretty_table(String, data; formatters = formatter)
    @test result == expected

    # Two formatters.
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │      1 │      1 │
│     -1 │   true │     -1 │     -1 │
│      3 │  false │      3 │      3 │
│     -1 │   true │     -1 │     -1 │
│      5 │  false │      5 │      5 │
│     -1 │   true │     -1 │     -1 │
└────────┴────────┴────────┴────────┘
"""

    f1 = (data,i,j) -> begin
        if j != 2
            return isodd(i) ? i : 0
        else
            return data
        end
    end

    f2 = (data,i,j) -> begin
        j != 2 && return data == 0 ? -1 : data
        return data
    end

    result = pretty_table(String, data; formatters = (f1, f2))
    @test result == expected
end

@testset "Pre-defined formatters" begin

    # == ft_round ==========================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│    1.0 │    0.0 │    1.0 │    1.0 │
│    2.0 │    1.0 │    2.0 │    2.0 │
│    3.0 │    0.0 │    3.0 │    3.0 │
│    4.0 │    1.0 │    4.0 │    4.0 │
│    5.0 │    0.0 │    5.0 │    5.0 │
│    6.0 │    1.0 │    6.0 │    6.0 │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(String, data; formatters = ft_round(1))
    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│    1.0 │  false │    1.0 │      1 │
│    2.0 │   true │    2.0 │      2 │
│    3.0 │  false │    3.0 │      3 │
│    4.0 │   true │    4.0 │      4 │
│    5.0 │  false │    5.0 │      5 │
│    6.0 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = pretty_table(String, data; formatters = ft_round(1, [3, 1]))
    @test result == expected

    # Check if `ft_round` correctly avoid unsupported types.

    vec = ["Test", :symbol, 'a', π, exp(1), log(19)]

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│   Test │
│ symbol │
│      a │
│   3.14 │
│   2.72 │
│   2.94 │
└────────┘
"""

    result = pretty_table(String, vec; formatters = ft_round(2))
    @test result == expected

    expected = """
┌─────────┐
│  Col. 1 │
├─────────┤
│  "Test" │
│ :symbol │
│     'a' │
│    3.14 │
│    2.72 │
│    2.94 │
└─────────┘
"""

    result = pretty_table(String, vec; formatters = ft_round(2), renderer = :show)
    @test result == expected

    # == ft_printf =========================================================================

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │
├──────────┼──────────┼──────────┼──────────┤
│    1.000 │    0.000 │    1.000 │    1.000 │
│    2.000 │    1.000 │    2.000 │    2.000 │
│    3.000 │    0.000 │    3.000 │    3.000 │
│    4.000 │    1.000 │    4.000 │    4.000 │
│    5.000 │    0.000 │    5.000 │    5.000 │
│    6.000 │    1.000 │    6.000 │    6.000 │
└──────────┴──────────┴──────────┴──────────┘
"""
    result = pretty_table(String, data; formatters = ft_printf("%8.3f"))
    @test result == expected

    expected = """
┌──────────┬────────┬────────┬──────────┐
│   Col. 1 │ Col. 2 │ Col. 3 │   Col. 4 │
├──────────┼────────┼────────┼──────────┤
│    1.000 │  false │    1.0 │    1.000 │
│    2.000 │   true │    2.0 │    2.000 │
│    3.000 │  false │    3.0 │    3.000 │
│    4.000 │   true │    4.0 │    4.000 │
│    5.000 │  false │    5.0 │    5.000 │
│    6.000 │   true │    6.0 │    6.000 │
└──────────┴────────┴────────┴──────────┘
"""
    result = pretty_table(String, data; formatters = ft_printf("%8.3f",[1,4]))
    @test result == expected

    expected = """
┌──────────┬────────┬────────┬──────────┐
│   Col. 1 │ Col. 2 │ Col. 3 │   Col. 4 │
├──────────┼────────┼────────┼──────────┤
│     1.00 │  false │    1.0 │   1.0000 │
│     2.00 │   true │    2.0 │   2.0000 │
│     3.00 │  false │    3.0 │   3.0000 │
│     4.00 │   true │    4.0 │   4.0000 │
│     5.00 │  false │    5.0 │   5.0000 │
│     6.00 │   true │    6.0 │   6.0000 │
└──────────┴────────┴────────┴──────────┘
"""
    result = pretty_table(
        String,
        data;
        formatters = ft_printf(["%8.2f", "%8.4f"], [1, 4])
    )
    @test result == expected

    # == ft_nomissing and ft_nonothing =====================================================

    table = Any[1 2 nothing; 3 missing 4; nothing 6 missing; 3//4 -1 1.0f0]

    expected = """
┌─────────┬────────┬─────────┐
│  Col. 1 │ Col. 2 │  Col. 3 │
├─────────┼────────┼─────────┤
│       1 │      2 │ nothing │
│       3 │        │       4 │
│ nothing │      6 │         │
│    3//4 │     -1 │     1.0 │
└─────────┴────────┴─────────┘
"""

    result = pretty_table(String, table; formatters = ft_nomissing)
    @test result == expected

    expected = """
┌────────┬─────────┬─────────┐
│ Col. 1 │  Col. 2 │  Col. 3 │
├────────┼─────────┼─────────┤
│      1 │       2 │         │
│      3 │ missing │       4 │
│        │       6 │ missing │
│   3//4 │      -1 │     1.0 │
└────────┴─────────┴─────────┘
"""

    result = pretty_table(String, table; formatters = ft_nonothing)
    @test result == expected

    expected = """
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│      1 │      2 │        │
│      3 │        │      4 │
│        │      6 │        │
│   3//4 │     -1 │    1.0 │
└────────┴────────┴────────┘
"""

    result = pretty_table(String, table; formatters = (ft_nomissing, ft_nonothing))
    @test result == expected

    result = pretty_table(String, table; formatters = (ft_nonothing, ft_nomissing))
    @test result == expected
end
