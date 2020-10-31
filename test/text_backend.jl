# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

data = Any[1    false      1.0     0x01 ;
           2     true      2.0     0x02 ;
           3    false      3.0     0x03 ;
           4     true      4.0     0x04 ;
           5    false      5.0     0x05 ;
           6     true      6.0     0x06 ;]

@testset "Default tests" begin
    include("text_backend/default.jl")
end

@testset "Alignments" begin
    include("text_backend/alignments.jl")
end

@testset "Column width" begin
    include("text_backend/column_width.jl")
end

@testset "Cropping" begin
    include("text_backend/cropping.jl")
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

@testset "Helpers" begin
    include("text_backend/helpers.jl")
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
