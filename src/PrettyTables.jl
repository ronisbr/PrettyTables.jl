module PrettyTables

using Formatting
using Parameters
using Reexport
using Tables

@reexport using Crayons

import Base: Dict, ismalformed, isoverlong

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

include("deprecations.jl")
include("files.jl")
include("helpers.jl")
include("misc.jl")
include("predefined_formatters.jl")
include("print.jl")

# Backends
# ========

# Text backend
include("backends/text/predefined_formats.jl")
include("backends/text/predefined_highlighters.jl")
include("backends/text/print.jl")
include("backends/text/private.jl")

# HTML backend
include("backends/html/predefined_formats.jl")
include("backends/html/predefined_highlighters.jl")
include("backends/html/print.jl")
include("backends/html/private.jl")

# LaTeX backend
include("backends/latex/predefined_formats.jl")
include("backends/latex/private.jl")
include("backends/latex/print.jl")

end # module
