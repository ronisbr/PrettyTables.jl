## Description #############################################################################
#
# Tests related to general functions.
#
############################################################################################

@testset "Back Ends" verbose = true begin
    include("./general/backend.jl")
end

@testset "Circular Reference" verbose = true begin
    include("./general/circular_reference.jl")
end

@testset "Configurations" verbose = true begin
    include("./general/configurations.jl")
end

@testset "Compact Types" verbose = true begin
    include("./general/compact_types.jl")
end

@testset "Errors" verbose = true begin
    include("./general/errors.jl")
end

@testset "Issues" verbose = true begin
    include("./general/issues.jl")
end

@testset "Table to File" verbose = true begin
    include("./general/files.jl")
end

@testset "Table to String" verbose = true begin
    include("./general/string.jl")
end

@testset "Tables.jl API" verbose = true begin
    include("./general/tables.jl")
end
