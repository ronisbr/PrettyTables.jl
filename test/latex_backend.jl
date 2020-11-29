# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to the LaTeX backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Default" begin
    include("latex_backend/default.jl")
end

@testset "Formatters" begin
    include("latex_backend/formatters.jl")
end

@testset "Highlighters" begin
    include("latex_backend/highlighters.jl")
end

@testset "Issues" begin
    include("latex_backend/issues.jl")
end

@testset "Row names" begin
    include("latex_backend/row_names.jl")
end
