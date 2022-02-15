# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Default tests" begin
    include("text_backend/default.jl")
end

@testset "Alignments" begin
    include("text_backend/alignments.jl")
end

@testset "Column width" begin
    include("text_backend/column_width.jl")
end

@testset "Colors" begin
    # Those tests are failing in Windows for Julia 1.0.
    if (VERSION > v"1.1") || !Sys.iswindows()
        include("text_backend/colors.jl")
    end
end

@testset "Cropping" begin
    include("text_backend/cropping.jl")
end

@testset "Custom text cell" begin
    include("text_backend/custom_cells.jl")
end

@testset "Errors" begin
    include("text_backend/errors.jl")
end

@testset "Filters" begin
    include("text_backend/filters.jl")
end

@testset "Formatters" begin
    include("text_backend/formatters.jl")
end

@testset "Headers" begin
    include("text_backend/headers.jl")
end

@testset "Line breaks" begin
    include("text_backend/line_breaks.jl")
end

@testset "Markdown" begin
    include("text_backend/markdown.jl")
end

@testset "Renderers" begin
    include("text_backend/renderers.jl")
end

@testset "Row names" begin
    include("text_backend/row_names.jl")
end

@testset "Row numbers" begin
    include("text_backend/row_numbers.jl")
end

@testset "Table lines" begin
    include("text_backend/table_lines.jl")
end

@testset "Table.jl compatibility" begin
    include("text_backend/tables.jl")
end

@testset "Titles" begin
    include("text_backend/titles.jl")
end

@testset "UTF-8" begin
    include("text_backend/utf8.jl")
end

@testset "Issues" begin
    include("text_backend/issues.jl")
end
