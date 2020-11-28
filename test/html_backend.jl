# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Alignment" begin
    include("./html_backend/alignments.jl")
end

@testset "Default" begin
    include("./html_backend/default.jl")
end

@testset "Filters" begin
    include("./html_backend/filters.jl")
end

@testset "Formatters" begin
    include("./html_backend/formatters.jl")
end

@testset "Headers" begin
    include("./html_backend/headers.jl")
end

@testset "Highlighters" begin
    include("./html_backend/highlighters.jl")
end

@testset "Linebreaks" begin
    include("./html_backend/linebreaks.jl")
end

@testset "Markdown" begin
    include("./html_backend/markdown.jl")
end

@testset "Renderers" begin
    include("./html_backend/renderers.jl")
end

@testset "Row numbers" begin
    include("./html_backend/row_numbers.jl")
end

@testset "Titles" begin
    include("./html_backend/titles.jl")
end
