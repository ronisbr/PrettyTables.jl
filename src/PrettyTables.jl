module PrettyTables

using Formatting
using Reexport
using Tables
using Markdown

@reexport using Crayons

import Base: Dict, ismalformed, isoverlong, @kwdef

# The performance of PrettyTables.jl does not increase by a lot of optimizations
# that is performed by the compiler. Hence, we disable then to improve compile
# time.
if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
       @eval Base.Experimental.@optlevel 1
end

################################################################################
#                                    Types
################################################################################

include("types.jl")
include("backends/text/types.jl")
include("backends/html/types.jl")
include("backends/latex/types.jl")

################################################################################
#                                  Includes
################################################################################

include("configuration.jl")
include("deprecations.jl")
include("files.jl")
include("helpers.jl")
include("misc.jl")
include("predefined_formatters.jl")
include("print.jl")
include("private.jl")
include("tables.jl")

# Backends
# ========

# Text backend
include("backends/text/alignment.jl")
include("backends/text/cell_parse.jl")
include("backends/text/display.jl")
include("backends/text/fill.jl")
include("backends/text/misc.jl")
include("backends/text/predefined_formats.jl")
include("backends/text/predefined_highlighters.jl")
include("backends/text/print.jl")
include("backends/text/print_aux.jl")
include("backends/text/recipes.jl")
include("backends/text/string.jl")
include("backends/text/title.jl")

include("backends/text/custom_text_cells/custom_text_cell.jl")
include("backends/text/custom_text_cells/url_text_cell.jl")
include("backends/text/custom_text_cells/ansi_text_cell.jl")

# HTML backend
include("backends/html/cell_parse.jl")
include("backends/html/predefined_formats.jl")
include("backends/html/predefined_highlighters.jl")
include("backends/html/print.jl")
include("backends/html/private.jl")
include("backends/html/string.jl")

# LaTeX backend
include("backends/latex/cell_parse.jl")
include("backends/latex/predefined_formats.jl")
include("backends/latex/private.jl")
include("backends/latex/print.jl")
include("backends/latex/string.jl")

if Base.VERSION >= v"1.4.2"
    # This try/catch is necessary in case the precompilation statements do not
    # exists. In this case, PrettyTables.jl will work correctly but without the
    # optimizations.
    try
        include("precompile/precompile_PrettyTables.jl")
        _precompile_()
    catch
    end
end

end # module
