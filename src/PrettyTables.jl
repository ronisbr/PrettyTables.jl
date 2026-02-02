module PrettyTables

using Markdown
using Printf
using Reexport
using StringManipulation
using Tables

# We add REPL.jl as dependency only to decrease the enormous precompilation time observed
# after Julia 1.11. For more information, check:
#
#   https://github.com/JuliaLang/julia/issues/56080
#
using REPL

@reexport using Crayons

import Base: @kwdef, axes, getindex, show
import LaTeXStrings: LaTeXString

# The performance of PrettyTables.jl does not increase by a lot of optimizations that is
# performed by the compiler. Hence, we disable then to improve compile time.
if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
   @eval Base.Experimental.@optlevel 1
end

############################################################################################
#                                          Types                                           #
############################################################################################

include("./types.jl")

############################################################################################
#                                         Includes                                         #
############################################################################################

include("./documentation.jl")
include("./main.jl")
include("./misc.jl")
include("./predefined_formatters.jl")
include("./private.jl")
include("./tables.jl")

include("./backends/latex/types.jl")
include("./backends/latex/documentation.jl")
include("./backends/latex/helpers.jl")
include("./backends/latex/latex_backend.jl")
include("./backends/latex/predefined_formats.jl")
include("./backends/latex/private.jl")
include("./backends/latex/render_cell.jl")

include("./backends/html/types.jl")
include("./backends/html/documentation.jl")
include("./backends/html/html_backend.jl")
include("./backends/html/private.jl")
include("./backends/html/render_cell.jl")

include("./backends/typst/types.jl")
include("./backends/typst/documentation.jl")
include("./backends/typst/typst_backend.jl")
include("./backends/typst/private.jl")
include("./backends/typst/render_cell.jl")

include("./backends/markdown/types.jl")
include("./backends/markdown/documentation.jl")
include("./backends/markdown/markdown_backend.jl")
include("./backends/markdown/private.jl")
include("./backends/markdown/render_cell.jl")

include("./backends/text/types.jl")
include("./backends/text/documentation.jl")
include("./backends/text/column_widths.jl")
include("./backends/text/display.jl")
include("./backends/text/helpers.jl")
include("./backends/text/predefined_formats.jl")
include("./backends/text/private.jl")
include("./backends/text/render_cell.jl")
include("./backends/text/render_table.jl")
include("./backends/text/text_backend.jl")

include("./backends/excel/types.jl")
#include("./backends/excel/documentation.jl")
#include("./backends/excel/helpers.jl")
include("./backends/excel/excel_backend.jl")

include("./printing_state/alignment.jl")
include("./printing_state/data.jl")
include("./printing_state/information.jl")
include("./printing_state/iterator.jl")

############################################################################################
#                                      Precompilation                                      #
############################################################################################

include("./precompile.jl")

end # module
