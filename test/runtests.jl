using Test
using PrettyTables

@testset "Internal Functions" verbose = true begin
    include("./internal/cell_alignment.jl")
    include("./internal/cell_data.jl")
    include("./internal/print_state.jl")
end
