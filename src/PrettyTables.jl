module PrettyTables

using Formatting
using Parameters
using Reexport
using Tables

@reexport using Crayons

export Highlighter, PrettyTableFormat

################################################################################
#                                    Types
################################################################################

include("types.jl")

################################################################################
#                                  Constants
################################################################################

# Crayon used to reset all the styling.
const _reset_crayon = Crayon(reset = true)

################################################################################
#                                  Includes
################################################################################

include("predefined_formats.jl")
include("predefined_highlighters.jl")
include("predefined_formatters.jl")
include("helpers.jl")
include("print.jl")
include("private.jl")

end # module
