# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Descriptions
# ==============================================================================
#
#   Function that generates the precompilation statements.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

using SnoopCompile

run(`rm -rf ../src/precompile/precompile_PrettyTables.jl`)

using Pkg
Pkg.build("PrettyTables")
using PrettyTables

include("input.jl")

function create_precompile_files()
    tinf = @snoopi_deep precompilation_input()
    ttot, pcs = SnoopCompile.parcel(tinf)
    SnoopCompile.write("../src/precompile/", pcs)

    # Remove all precompile files that are not related to PrettyTables.jl.
    run(`bash -c "find ../src/precompile/precompile* -maxdepth 1 ! -name \"*PrettyTables*\" -type f -exec rm -f {} \\;"`)
end

create_precompile_files()
