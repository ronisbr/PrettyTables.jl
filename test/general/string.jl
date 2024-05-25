## Description #############################################################################
#
# Tests related to printing a table to a string.
#
############################################################################################

@testset "Print Table to String" begin
    data     = rand(10, 4)
    header_m = [1, 2, 3, 4]
    header_v = [1, 2, 3, 4]

    expected = sprint(pretty_table, data)
    result   = pretty_table(String, data)
    @test result == expected

    expected = sprint((io,data)->pretty_table(io, data; header = header_m), data)
    result   = pretty_table(String, data; header = header_m)
    @test result == expected

    expected = sprint((io,data)->pretty_table(io, data; header = header_v), data)
    result   = pretty_table(String, data; header = header_v)
    @test result == expected

    dict = Dict(
        :a => 1,
        :b => 2,
        :c => 3,
        :d => 4
    )

    expected = sprint(pretty_table, data)
    result   = pretty_table(String, data)
    @test result == expected

    expected = """
    ┌────────┬────────┐
    │\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│
    ├────────┼────────┤
    │      1 │\e[33;1m      2 \e[0m│
    └────────┴────────┘
    """

    result = pretty_table(String, [1 2], color = true, highlighters = hl_value(2))
    @test result == expected
end
