## Description #############################################################################
#
# Tests of Tables.jl API.
#
############################################################################################

@testset "Tables.jl Compatibility" begin
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

    # If a header is passed, it must replace the Tables.jl schema.
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

@testset "Tables.jl without Schema" begin

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

    # == Column Table ======================================================================

    struct MyColumnTable{T <: AbstractMatrix}
        names::Vector{Symbol}
        lookup::Dict{Symbol, Int}
        matrix::T
    end

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

    # == Row Table =========================================================================

    struct MyRowTable{T <: AbstractMatrix}
        names::Vector{Symbol}
        lookup::Dict{Symbol, Int}
        matrix::T
    end

    struct MyMatrixRow{T} <: Tables.AbstractRow
        row::Int
        source::MyRowTable{T}
    end

    Tables.istable(::Type{<:MyRowTable}) = true
    names(m::MyRowTable) = getfield(m, :names)
    mat(m::MyRowTable) = getfield(m, :matrix)
    lookup(m::MyRowTable) = getfield(m, :lookup)

    Tables.rowaccess(::Type{<:MyRowTable}) = true
    Tables.rows(m::MyRowTable) = m
    Base.eltype(m::MyRowTable{T}) where {T} = MyMatrixRow{T}
    Base.length(m::MyRowTable) = size(mat(m), 1)
    Base.iterate(m::MyRowTable, st = 1) = st > length(m) ? nothing : (MyMatrixRow(st, m), st + 1)

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

    # This test does not have a valid `Tables.subet` implementation.
    result = pretty_table(String, table)
    @test Tables.schema(table) == nothing
    @test result == expected

    # Now, let's define a Tables.subset.
    Tables.subset(m::MyMatrixRow, inds; viewhint = nothing) = data[inds]

    result = pretty_table(String, table)
    @test result == expected
end

@testset "Tables.jl with Custom Column Name Vector" begin
    struct TestVec{T} <: AbstractArray{T,1}
        data::Array{T,1}
    end

    struct MinimalTable
        data::Matrix
        colnames::TestVec
    end

    Base.IndexStyle(::Type{A}) where {A<:TestVec} = Base.IndexCartesian()
    Base.size(A::TestVec) = size(getfield(A, :data))
    Base.getindex(A::TestVec, index::Int) = getindex(getfield(A, :data), index)
    Base.collect(::Type{T}, itr::TestVec) where {T} = TestVec(collect(T, getfield(itr, :data)))

    Tables.istable(x::MinimalTable) = true
    Tables.columnaccess(::MinimalTable) = true
    Tables.columnnames(x::MinimalTable) = getfield(x, :colnames)
    Tables.columns(x::MinimalTable) = x
    Base.getindex(x::MinimalTable, i1, i2) = getindex(getfield(x, :data), i1, i2)
    Base.getproperty(x::MinimalTable, s::Symbol) = getindex(x, :, findfirst(==(s), Tables.columnnames(x)))
    Base.convert(::Type{<:TestVec}, x::Array) = TestVec(x)

    data     = [10.0^(i + j) for i in 1:10, j in 1:5]
    mintable = MinimalTable(data, [:C1, :C2, :C3, :C4, :C5])

    str_data = pretty_table(
        String,
        data;
        header = ["C1", "C2", "C3", "C4", "C5"]
    )

    str_mintable = pretty_table(String, mintable)

    @test str_data == str_mintable
end

@testset "Tables.jl with Undefined Elements" begin
    expected = """
┌────────┬────────┬────────┐
│      A │      B │      C │
├────────┼────────┼────────┤
│      1 │ #undef │ #undef │
│ #undef │      1 │ #undef │
│ #undef │ #undef │    1.0 │
└────────┴────────┴────────┘
"""

    # == Column Tables =====================================================================

    struct MinimalColumnTable{T}
        columns::Vector{Vector{T}}
        colnames::Vector{Symbol}
    end

    Tables.istable(x::MinimalColumnTable) = true
    Tables.columnaccess(::MinimalColumnTable) = true
    Tables.columnnames(m::MinimalColumnTable) = getfield(m, :colnames)
    Tables.columns(m::MinimalColumnTable) = m
    Tables.getcolumn(m::MinimalColumnTable, i::Int) = m.columns[i]
    Tables.getcolumn(m::MinimalColumnTable, nm::Symbol) = getindex(m.columns, findfirst(==(nm), m.colnames))

    table = MinimalColumnTable(
        [Vector{Any}(undef, 3) for _ in 1:3],
        [:A, :B, :C]
    )

    table.columns[1][1] = UInt64(1)
    table.columns[2][2] = Int64(1)
    table.columns[3][3] = 1.0

    result = pretty_table(String, table)
    @test result == expected

    # == Row Tables ========================================================================

    struct MinimalRow{T}
        data::Vector{T}
        colnames::Vector{Symbol}
    end

    struct MinimalRowTable{T}
        rows::Vector{MinimalRow{T}}

        function MinimalRowTable(data::Vector{Vector{T}}, colnames::Vector{Symbol}) where T
            new{T}(
                [MinimalRow{T}(data[i], colnames) for i in 1:length(data)],
            )
        end
    end

    Tables.istable(x::MinimalRowTable) = true
    Tables.rowaccess(::MinimalRowTable) = true
    Tables.rows(m::MinimalRowTable) = m.rows

    Tables.columnnames(m::MinimalRow) = getfield(m, :colnames)
    Tables.getcolumn(m::MinimalRow, i::Int) = m.data[i]
    Tables.getcolumn(m::MinimalRow, nm::Symbol) = getindex(m.data, findfirst(==(nm), m.colnames))

    table = MinimalRowTable(
        [Vector{Any}(undef, 3) for _ in 1:3],
        [:A, :B, :C]
    )

    table.rows[1].data[1] = UInt64(1)
    table.rows[2].data[2] = Int64(1)
    table.rows[3].data[3] = 1.0

    # This test happens without `Tables.subset` application.
    result = pretty_table(String, table)
    @test result == expected

    # Define the `Tables.subset` API and test again.
    Tables.subset(m::MinimalRowTable, i::Int; viewhint = nothing) = m.rows[i]

    result = pretty_table(String, table)
    @test result == expected
end
