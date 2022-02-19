using Test
using PrettyTables
using Tables
using Markdown

data = Any[1    false      1.0     0x01 ;
           2     true      2.0     0x02 ;
           3    false      3.0     0x03 ;
           4     true      4.0     0x04 ;
           5    false      5.0     0x05 ;
           6     true      6.0     0x06 ;]

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
