# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to general functions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Back-ends" verbose = true begin
    include("./general/backend.jl")
end

@testset "Configurations" verbose = true begin
    include("./general/configurations.jl")
end

@testset "Compact types" verbose = true begin
    include("./general/compact_types.jl")
end

@testset "Errors" verbose = true begin
    include("./general/errors.jl")
end

@testset "Table to file" verbose = true begin
    include("./general/files.jl")
end

@testset "Table to string" verbose = true begin
    include("./general/string.jl")
end

@testset "Tables.jl API" verbose = true begin
    include("./general/tables.jl")
end
