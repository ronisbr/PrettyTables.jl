# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests of Tables.jl API.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Issues
# ==============================================================================

@testset "Issue #90 - Tables.jl returning tuples as columns" begin
    struct SimpleTable{T}
        data::Matrix{T}
    end

    Tables.istable(::SimpleTable) = true
    Tables.columnaccess(::SimpleTable) = true
    Tables.columnnames(x::SimpleTable) = [Symbol(i) for i = 1:size(x.data, 2)]
    Tables.columns(x::SimpleTable) = x
    Tables.getcolumn(x::SimpleTable, i::Symbol) = tuple(x.data[parse(Int,string(i)),:]...)

    table = SimpleTable([10.0^(i+j) for i = 1:10, j = 1:5])

    expected = """
┌──────────┬──────────┬──────────┬──────────┬────────┐
│        1 │        2 │        3 │        4 │      5 │
├──────────┼──────────┼──────────┼──────────┼────────┤
│    100.0 │   1000.0 │  10000.0 │ 100000.0 │  1.0e6 │
│   1000.0 │  10000.0 │ 100000.0 │    1.0e6 │  1.0e7 │
│  10000.0 │ 100000.0 │    1.0e6 │    1.0e7 │  1.0e8 │
│ 100000.0 │    1.0e6 │    1.0e7 │    1.0e8 │  1.0e9 │
│    1.0e6 │    1.0e7 │    1.0e8 │    1.0e9 │ 1.0e10 │
└──────────┴──────────┴──────────┴──────────┴────────┘
"""

    result = pretty_table(String, table)
    @test result == expected
end
