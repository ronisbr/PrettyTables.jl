# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of Tables.jl compatibility.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# These structures must not be defined inside a @testset. Otherwise, the test
# will fail for Julia 1.0.
struct MyColumnTable{T <: AbstractMatrix}
    names::Vector{Symbol}
    lookup::Dict{Symbol, Int}
    matrix::T
end

struct MyRowTable{T <: AbstractMatrix}
    names::Vector{Symbol}
    lookup::Dict{Symbol, Int}
    matrix::T
end

struct MyMatrixRow{T} <: Tables.AbstractRow
    row::Int
    source::MyRowTable{T}
end

@testset "Tables.jl compatibility" begin
    # A NamedTuple is compliant with Tables.jl API.
    table = (
        x = Int64(1):Int64(3),
        y = 'a':'c',
        z = ["String 1";"String 2";"String 3"]
    )

    # Thus, the following 5 calls must provide the same results.
    result_1 = pretty_table(String, table)
    result_2 = pretty_table(String, Tables.rowtable(table))
    result_3 = pretty_table(String, Tables.columntable(table))
    result_4 = pretty_table(String, Tables.columns(table))
    result_5 = pretty_table(String, Tables.rows(table))

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

    @test result_1 == result_2 == result_3 == result_4 == result_5 == expected

    # If a header is passed, then it must replace the Tables.jl schema.

    result = pretty_table(
        String,
        table;
        header = ["My col. 1", "My col. 2", "My col. 3"]
    )

    expected = """
┌───────────┬───────────┬───────────┐
│ My col. 1 │ My col. 2 │ My col. 3 │
├───────────┼───────────┼───────────┤
│         1 │         a │  String 1 │
│         2 │         b │  String 2 │
│         3 │         c │  String 3 │
└───────────┴───────────┴───────────┘
"""

    @test result == expected
end

@testset "Tables.jl without schema" begin

    expected = """
┌───┬───────┬─────┬───┐
│ a │     b │   c │ d │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    # Column table
    # --------------------------------------------------------------------------

    Tables.istable(::Type{<:MyColumnTable}) = true
    names(m::MyColumnTable) = getfield(m, :names)
    mat(m::MyColumnTable) = getfield(m, :matrix)
    lookup(m::MyColumnTable) = getfield(m, :lookup)

    Tables.columnaccess(::Type{<:MyColumnTable}) = true
    Tables.columns(m::MyColumnTable) = m
    Tables.getcolumn(m::MyColumnTable, ::Type{T}, col::Int, nm::Symbol) where {T} = mat(m)[:, col]
    Tables.getcolumn(m::MyColumnTable, nm::Symbol) = mat(m)[:, lookup(m)[nm]]
    Tables.getcolumn(m::MyColumnTable, i::Int) = mat(m)[:, i]
    Tables.columnnames(m::MyColumnTable) = names(m)

    table = MyColumnTable(
        [:a, :b, :c, :d],
        Dict(:a => 1, :b => 2, :c => 3, :d => 4),
        data
    )

    result = pretty_table(String, table)

    @test Tables.schema(table) == nothing
    @test result == expected

    # Row table
    # --------------------------------------------------------------------------

    # First, we need to create a object that complies with Tables.jl and that
    # does not have a schema. This is based on Tables.jl documentation.

    Tables.istable(::Type{<:MyRowTable}) = true
    names(m::MyRowTable) = getfield(m, :names)
    mat(m::MyRowTable) = getfield(m, :matrix)
    lookup(m::MyRowTable) = getfield(m, :lookup)

    Tables.rowaccess(::Type{<:MyRowTable}) = true
    Tables.rows(m::MyRowTable) = m
    Base.eltype(m::MyRowTable{T}) where {T} = MyMatrixRow{T}
    Base.length(m::MyRowTable) = size(mat(m), 1)
    Base.iterate(m::MyRowTable, st=1) = st > length(m) ? nothing : (MyMatrixRow(st, m), st + 1)

    Tables.getcolumn(m::MyMatrixRow, ::Type, col::Int, nm::Symbol) =
        getfield(getfield(m, :source), :matrix)[getfield(m, :row), col]
    Tables.getcolumn(m::MyMatrixRow, i::Int) =
        getfield(getfield(m, :source), :matrix)[getfield(m, :row), i]
    Tables.getcolumn(m::MyMatrixRow, nm::Symbol) = getfield(
        getfield(m, :source), :matrix)[
            getfield(m, :row),
            getfield(getfield(m, :source), :lookup)[nm]
        ]
    Tables.columnnames(m::MyMatrixRow) = names(getfield(m, :source))

    table = MyRowTable(
        [:a, :b, :c, :d],
        Dict(:a => 1, :b => 2, :c => 3, :d => 4),
        data
    )

    result = pretty_table(String, table)

    @test Tables.schema(table) == nothing
    @test result == expected
end
