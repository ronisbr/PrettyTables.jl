using Test
using PrettyTables

using LaTeXStrings
using Markdown
using OffsetArrays
using StyledStrings
using Tables

############################################################################################
#                                   Types and Structures                                   #
############################################################################################

include("./types.jl")

############################################################################################
#                                          Tests                                           #
############################################################################################

@testset "Internal Functions" verbose = true begin
    include("./internal/cell_alignment.jl")
    include("./internal/cell_data.jl")
    include("./internal/print_state.jl")
end

@testset "HTML Back End Tests" verbose = true begin
    include("./backends/html/alignment.jl")
    include("./backends/html/cell_titles.jl")
    include("./backends/html/circular_reference.jl")
    include("./backends/html/column_width.jl")
    include("./backends/html/cropping.jl")
    include("./backends/html/decorations.jl")
    include("./backends/html/default.jl")
    include("./backends/html/divs.jl")
    include("./backends/html/full.jl")
    include("./backends/html/highlighters.jl")
    include("./backends/html/issues.jl")
    include("./backends/html/minify.jl")
    include("./backends/html/offset_arrays.jl")
    include("./backends/html/renderers.jl")
    include("./backends/html/special_cells.jl")
    include("./backends/html/stand_alone.jl")
end

@testset "LaTeX Back End Tests" verbose = true begin
    include("./backends/latex/alignment.jl")
    include("./backends/latex/circular_reference.jl")
    include("./backends/latex/cropping.jl")
    include("./backends/latex/decorations.jl")
    include("./backends/latex/default.jl")
    include("./backends/latex/full.jl")
    include("./backends/latex/highlighters.jl")
    include("./backends/latex/offset_arrays.jl")
    include("./backends/latex/renderers.jl")
    include("./backends/latex/special_cells.jl")
end

@testset "Markdown Back End Tests" verbose = true begin
    include("./backends/markdown/alignment.jl")
    include("./backends/markdown/circular_reference.jl")
    include("./backends/markdown/compact.jl")
    include("./backends/markdown/cropping.jl")
    include("./backends/markdown/decorations.jl")
    include("./backends/markdown/default.jl")
    include("./backends/markdown/full.jl")
    include("./backends/markdown/highlighters.jl")
    include("./backends/markdown/offset_arrays.jl")
    include("./backends/markdown/renderers.jl")
    include("./backends/markdown/special_cells.jl")
end

@testset "Text Back End Test" verbose = true begin
    include("./backends/text/alignment.jl")
    include("./backends/text/circular_reference.jl")
    include("./backends/text/column_widths.jl")
    include("./backends/text/cropping.jl")
    include("./backends/text/custom_cells.jl")
    include("./backends/text/decorations.jl")
    include("./backends/text/default.jl")
    include("./backends/text/errors.jl")
    include("./backends/text/full.jl")
    include("./backends/text/highlighters.jl")
    include("./backends/text/horizontal_lines.jl")
    include("./backends/text/issues.jl")
    include("./backends/text/line_breaks.jl")
    include("./backends/text/offset_arrays.jl")
    include("./backends/text/renderers.jl")
    include("./backends/text/special_cells.jl")
end

@testset "Typst Back End Tests" verbose = true begin
    include("./backends/typst/alignment.jl")
    include("./backends/typst/caption.jl")
    include("./backends/typst/cell_titles.jl")
    include("./backends/typst/circular_reference.jl")
    include("./backends/typst/data_column_widths.jl")
    include("./backends/typst/cropping.jl")
    include("./backends/typst/decorations.jl")
    include("./backends/typst/default.jl")
    include("./backends/typst/full.jl")
    include("./backends/typst/highlighters.jl")
    include("./backends/typst/offset_arrays.jl")
    include("./backends/typst/renderers.jl")
    include("./backends/typst/types.jl")
    include("./ext/pretty_tables_typstry_ext.jl")
end

@testset "Tables.jl" verbose = true begin
    include("./tables.jl")
end

@testset "General Tests" verbose = true begin
    include("./general.jl")
end

@testset "PrettyTable Structure" verbose = true begin
    include("./pretty_table_structure.jl")
end

@testset "Pre-defined Formatters" verbose = true begin
    include("./predefined_formatters.jl")
end

@testset "Errors" verbose = true begin
    include("./errors.jl")
end
