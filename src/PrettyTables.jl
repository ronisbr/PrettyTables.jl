module PrettyTables

using Tables

import Base: @kwdef

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
include("./print_state.jl")
include("./tables.jl")

include("./backends/html/types.jl")
include("./backends/html/html_back_end.jl")
include("./backends/html/private.jl")
include("./backends/html/render_cell.jl")

############################################################################################
#                                      Precompilation                                      #
############################################################################################

include("./precompile.jl")

end # module
