# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests of issues.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Issue #65 - Data type in filters with Tables.jl" begin
    table = (A = Int64.(1:20), B = Float64.(1:20))
    rowfilter1(data,i) = i <= div(length(first(data)),2)
    rowfilter2(data,i) = i <= div(length(data),2)

    result1 = pretty_table(String, table;                 filters_row = (rowfilter1,))
    result2 = pretty_table(String, Tables.columns(table); filters_row = (rowfilter1,))
    result3 = pretty_table(String, Tables.rows(table);    filters_row = (rowfilter2,))

    expected = """
┌───────┬─────────┐
│     A │       B │
│ Int64 │ Float64 │
├───────┼─────────┤
│     1 │     1.0 │
│     2 │     2.0 │
│     3 │     3.0 │
│     4 │     4.0 │
│     5 │     5.0 │
│     6 │     6.0 │
│     7 │     7.0 │
│     8 │     8.0 │
│     9 │     9.0 │
│    10 │    10.0 │
└───────┴─────────┘
"""

    @test result1 == expected
    @test result2 == expected
    @test result3 == expected

    table = (
        A = Int64.(1:10),
        B = Float64.(1:10),
        C = Int64.(1:10),
        D = Float64.(1:10)
    )
    colfilter1(data,j) = j <= div(length(data),2)
    colfilter2(data,j) = j <= div(length(first(data)),2)

    result1 = pretty_table(String, table;                 filters_col = (colfilter1,))
    result2 = pretty_table(String, Tables.columns(table); filters_col = (colfilter1,))
    result3 = pretty_table(String, Tables.rows(table);    filters_col = (colfilter2,))

    @test result1 == expected
    @test result2 == expected
    @test result3 == expected
end

struct SimpleTable{T}
    data::Matrix{T}
end

Tables.istable(::SimpleTable) = true
Tables.columnaccess(::SimpleTable) = true
Tables.columnnames(x::SimpleTable) = [Symbol(i) for i = 1:size(x.data, 2)]
Tables.columns(x::SimpleTable) = x
Tables.getcolumn(x::SimpleTable, i::Symbol) = tuple(x.data[parse(Int,string(i)),:]...)

table = SimpleTable([10.0^(i+j) for i in 1:10, j in 1:5])

@testset "Issue #90 - Tables.jl returning tuples as columns" begin
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
