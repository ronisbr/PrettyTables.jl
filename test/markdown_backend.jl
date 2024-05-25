## Description #############################################################################
#
# Tests related to the markdown back end.
#
############################################################################################

@testset "Alignment" verbose = true begin
    include("./markdown_backend/alignments.jl")
end

@testset "Cropping" verbose = true begin
    include("./markdown_backend/crop.jl")
end

@testset "Default" verbose = true begin
    include("./markdown_backend/default.jl")
end

@testset "Formatters" verbose = true begin
    include("./markdown_backend/formatters.jl")
end

@testset "Headers" verbose = true begin
    include("./markdown_backend/headers.jl")
end

@testset "Highlighters" verbose = true begin
    include("./markdown_backend/highlighters.jl")
end

@testset "Linebreaks" verbose = true begin
    include("./markdown_backend/linebreaks.jl")
end

@testset "OffsetArrays" verbose = true begin
    include("./markdown_backend/offset_arrays.jl")
end

@testset "Renderers" verbose = true begin
    include("./markdown_backend/renderers.jl")
end

@testset "Row numbers" verbose = true begin
    include("./markdown_backend/row_numbers.jl")
end
