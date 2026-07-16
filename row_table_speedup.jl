using PrettyTables
using Statistics
using Tables

"""
    BenchmarkRows

A row-oriented Tables.jl source without `Tables.subset` support.
"""
struct BenchmarkRows
    names::Vector{Symbol}
    lookup::Dict{Symbol, Int}
    data::Matrix{Int}
end

"""
    BenchmarkRow

One row from `BenchmarkRows`.
"""
struct BenchmarkRow <: Tables.AbstractRow
    index::Int
    source::BenchmarkRows
end

Tables.istable(::Type{BenchmarkRows}) = true
Tables.rowaccess(::Type{BenchmarkRows}) = true
Tables.rows(source::BenchmarkRows) = source

Base.length(source::BenchmarkRows) = size(getfield(source, :data), 1)

function Base.iterate(source::BenchmarkRows, state::Int = 1)
    state > length(source) && return nothing
    return BenchmarkRow(state, source), state + 1
end

Tables.columnnames(row::BenchmarkRow) = getfield(getfield(row, :source), :names)

function Tables.getcolumn(row::BenchmarkRow, name::Symbol)
    source = getfield(row, :source)
    i = getfield(row, :index)
    j = getfield(source, :lookup)[name]
    return getfield(source, :data)[i, j]
end

number_of_rows = 300
number_of_columns = 8

names = [Symbol(:column_, j) for j in 1:number_of_columns]
lookup = Dict(name => j for (j, name) in enumerate(names))
data = [i for i in 1:number_of_rows, _ in 1:number_of_columns]

source = BenchmarkRows(names, lookup, data)
