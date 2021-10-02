# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to general functions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Back-ends" begin
    include("./general/backend.jl")
end

@testset "Configurations" begin
    include("./general/configurations.jl")
end

@testset "Compact types" begin
    include("./general/compact_types.jl")
end

@testset "Errors" begin
    include("./general/errors.jl")
end

@testset "Table to file" begin
    include("./general/files.jl")
end

@testset "Table to string" begin
    include("./general/string.jl")
end

@testset "Tables.jl API" begin
    include("./general/tables.jl")
end
