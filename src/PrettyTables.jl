module PrettyTables

using Formatting
using Parameters
using Reexport
using Tables

@reexport using Crayons

################################################################################
#                                    Types
################################################################################

include("types.jl")
include("backends/text/types.jl")

################################################################################
#                                  Includes
################################################################################

include("helpers.jl")
include("predefined_formatters.jl")
include("print.jl")

# Backends
# ========

# Text backend
include("backends/text/predefined_formats.jl")
include("backends/text/predefined_highlighters.jl")
include("backends/text/print.jl")
include("backends/text/private.jl")

end # module
