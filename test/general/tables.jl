# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests of Tables.jl API.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

struct TestVec{T} <: AbstractArray{T,1}
    data::Array{T,1}
end
Base.IndexStyle(::Type{A}) where {A<:TestVec} = Base.IndexCartesian()
Base.size(A::TestVec) = size(getfield(A, :data))
Base.getindex(A::TestVec, index::Int) = getindex(getfield(A, :data), index)
Base.collect(::Type{T}, itr::TestVec) where {T} = TestVec(collect(T, getfield(itr, :data)))

struct MinimalTable
    data::Matrix
    colnames::TestVec
end

Tables.istable(x::MinimalTable) = true
Tables.columnaccess(::MinimalTable) = true
Tables.columnnames(x::MinimalTable) = getfield(x, :colnames)
Tables.columns(x::MinimalTable) = x
Base.getindex(x::MinimalTable, i1, i2) = getindex(getfield(x, :data), i1, i2)
Base.getproperty(x::MinimalTable, s::Symbol) = getindex(x, :, findfirst(==(s), Tables.columnnames(x)))
Base.convert(::Type{<:TestVec}, x::Array) = TestVec(x)

@testset "Tables.jl with custom column name vector" begin
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
