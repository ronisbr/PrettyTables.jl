module PrettyTables

using Crayons
using Markdown
using StringManipulation
using Tables

import Base: @kwdef, axes, getindex

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

include("./main.jl")
include("./misc.jl")
include("./private.jl")
include("./tables.jl")

include("./backends/html/types.jl")
include("./backends/html/html_backend.jl")
include("./backends/html/private.jl")
include("./backends/html/render_cell.jl")

include("./backends/markdown/types.jl")
include("./backends/markdown/markdown_backend.jl")
include("./backends/markdown/private.jl")
include("./backends/markdown/render_cell.jl")

include("./backends/text/types.jl")
include("./backends/text/display.jl")
include("./backends/text/private.jl")
include("./backends/text/render_cell.jl")
include("./backends/text/text_backend.jl")

include("./printing_state/alignment.jl")
include("./printing_state/data.jl")
include("./printing_state/information.jl")
include("./printing_state/iterator.jl")

############################################################################################
#                                      Precompilation                                      #
############################################################################################

include("./precompile.jl")

end # module
