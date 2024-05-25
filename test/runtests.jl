using Test
using PrettyTables
using OffsetArrays
using Tables
using Markdown
using LaTeXStrings

data = Any[1    false      1.0     0x01 ;
           2     true      2.0     0x02 ;
           3    false      3.0     0x03 ;
           4     true      4.0     0x04 ;
           5    false      5.0     0x05 ;
           6     true      6.0     0x06 ;]

odata = OffsetArray(data, -4:1, -2:1)

println("== Text Back End ===========================================================================")
println()
include("./text_backend.jl")
println()

println("== HTML Back End ===========================================================================")
println()
include("./html_backend.jl")
println()

println("== LaTeX Back End ==========================================================================")
println()
include("./latex_backend.jl")
println()

println("== Markdown Back End =======================================================================")
println()
include("./markdown_backend.jl")
println()

println("== General =================================================================================")
println()
include("./general.jl")
println()
