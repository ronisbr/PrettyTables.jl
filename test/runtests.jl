using Test
using PrettyTables

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
