using Test
using PrettyTables

using Markdown
using OffsetArrays
using Tables

############################################################################################
#                                   Types and Structures                                   #
############################################################################################

include("./types.jl")

############################################################################################
#                                          Tests                                           #
############################################################################################

@testset "Internal Functions" verbose = true begin
    include("./internal/cell_alignment.jl")
    include("./internal/cell_data.jl")
    include("./internal/print_state.jl")
end

@testset "HTML Back End Tests" verbose = true begin
    include("./backends/html/alignment.jl")
    include("./backends/html/circular_reference.jl")
    include("./backends/html/column_width.jl")
    include("./backends/html/cropping.jl")
    include("./backends/html/default.jl")
    include("./backends/html/divs.jl")
    include("./backends/html/full.jl")
    include("./backends/html/highlighters.jl")
    include("./backends/html/minify.jl")
    include("./backends/html/offset_arrays.jl")
    include("./backends/html/renderers.jl")
    include("./backends/html/special_cells.jl")
    include("./backends/html/stand_alone.jl")
end

@testset "LaTeX Back End Tests" verbose = true begin
    include("./backends/latex/default.jl")
    include("./backends/latex/full.jl")
end

@testset "Markdown Back End Tests" verbose = true begin
    include("./backends/markdown/alignment.jl")
    include("./backends/markdown/circular_reference.jl")
    include("./backends/markdown/cropping.jl")
    include("./backends/markdown/default.jl")
    include("./backends/markdown/full.jl")
    include("./backends/markdown/highlighters.jl")
    include("./backends/markdown/offset_arrays.jl")
    include("./backends/markdown/renderers.jl")
    include("./backends/markdown/special_cells.jl")
end

@testset "Text Back End Test" verbose = true begin
    include("./backends/text/circular_reference.jl")
    include("./backends/text/cropping.jl")
    include("./backends/text/custom_cells.jl")
    include("./backends/text/default.jl")
    include("./backends/text/full.jl")
    include("./backends/text/highlighters.jl")
    include("./backends/text/offset_arrays.jl")
    include("./backends/text/renderers.jl")
end
