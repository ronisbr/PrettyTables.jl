## Description #############################################################################
#
# Tests related to the LaTeX backend.
#
############################################################################################

@testset "Default" verbose = true begin
    include("latex_backend/default.jl")
end

@testset "Cropping"  verbose = true begin
    include("latex_backend/crop.jl")
end

@testset "Formatters" verbose = true begin
    include("latex_backend/formatters.jl")
end

@testset "Highlighters" verbose = true begin
    include("latex_backend/highlighters.jl")
end

@testset "Issues" verbose = true begin
    include("latex_backend/issues.jl")
end

@testset "OffsetArrays" verbose = true begin
    include("latex_backend/offset_arrays.jl")
end

@testset "Row Labels" verbose = true begin
    include("latex_backend/row_labels.jl")
end
