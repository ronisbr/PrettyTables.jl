# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to printing a table to a string.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Print table to string" begin
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
end
