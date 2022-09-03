# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Default tests" verbose = true begin
    include("text_backend/default.jl")
end

@testset "Alignments" verbose = true begin
    include("text_backend/alignments.jl")
end

@testset "Column width" verbose = true begin
    include("text_backend/column_width.jl")
end

@testset "Colors" verbose = true begin
    # Those tests are failing in Windows for Julia 1.0.
    if (VERSION > v"1.1") || !Sys.iswindows()
        include("text_backend/colors.jl")
    end
end

@testset "Cropping" verbose = true begin
    include("text_backend/cropping.jl")
end

@testset "Custom text cell" verbose = true begin
    include("text_backend/custom_cells.jl")
end

@testset "Errors" verbose = true begin
    include("text_backend/errors.jl")
end

@testset "Formatters" verbose = true begin
    include("text_backend/formatters.jl")
end

@testset "Headers" verbose = true begin
    include("text_backend/headers.jl")
end

@testset "Line breaks" verbose = true begin
    include("text_backend/line_breaks.jl")
end

@testset "Markdown" verbose = true begin
    include("text_backend/markdown.jl")
end

@testset "OffsetArrays" verbose = true begin
    include("text_backend/offset_arrays.jl")
end

@testset "Renderers" verbose = true begin
    include("text_backend/renderers.jl")
end

@testset "Row labels" verbose = true begin
    include("text_backend/row_labels.jl")
end

@testset "Row numbers" verbose = true begin
    include("text_backend/row_numbers.jl")
end

@testset "Table lines" verbose = true begin
    include("text_backend/table_lines.jl")
end

@testset "Table.jl compatibility" verbose = true begin
    include("text_backend/tables.jl")
end

@testset "Titles" verbose = true begin
    include("text_backend/titles.jl")
end

@testset "UTF-8" verbose = true begin
    include("text_backend/utf8.jl")
end

@testset "Issues" verbose = true begin
    include("text_backend/issues.jl")
end
