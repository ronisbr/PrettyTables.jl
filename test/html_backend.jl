## Description #############################################################################
#
# Tests related to the text backend.
#
############################################################################################

@testset "Alignment" verbose = true begin
    include("./html_backend/alignments.jl")
end

@testset "Column Width" verbose = true begin
    include("./html_backend/column_width.jl")
end

@testset "Cropping" verbose = true begin
    include("./html_backend/crop.jl")
end

@testset "Default" verbose = true begin
    include("./html_backend/default.jl")
end

@testset "Formatters" verbose = true begin
    include("./html_backend/formatters.jl")
end

@testset "Headers" verbose = true begin
    include("./html_backend/headers.jl")
end

@testset "Highlighters" verbose = true begin
    include("./html_backend/highlighters.jl")
end

@testset "Linebreaks" verbose = true begin
    include("./html_backend/linebreaks.jl")
end

@testset "Markdown" verbose = true begin
    include("./html_backend/markdown.jl")
end

@testset "OffsetArrays" verbose = true begin
    include("./html_backend/offset_arrays.jl")
end

@testset "Renderers" verbose = true begin
    include("./html_backend/renderers.jl")
end

@testset "Row numbers" verbose = true begin
    include("./html_backend/row_numbers.jl")
end

@testset "Titles" verbose = true begin
    include("./html_backend/titles.jl")
end

@testset "Top Bar" verbose = true begin
    include("./html_backend/topbar.jl")
end
