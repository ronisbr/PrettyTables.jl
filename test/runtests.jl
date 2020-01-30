using Test
using PrettyTables
using DataFrames
using Tables

println("Text backend")
println("============")
println()
include("./text_backend.jl")
println()

println("HTML backend")
println("============")
println()
include("./html_backend.jl")
println()

println("LaTeX backend")
println("=============")
println()
include("./latex_backend.jl")
println()

println("General")
println("=======")
println()
include("./general.jl")
println()
