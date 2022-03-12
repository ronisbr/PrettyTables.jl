# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Descriptions
# ==============================================================================
#
#   Function that generates the precompilation statements.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

using SnoopCompile

run(`rm -rf precompile_PrettyTables.jl`)

using Pkg
Pkg.build("PrettyTables")
using PrettyTables

include("input.jl")

function create_precompile_files()
    run(`bash -c "mkdir -p snoopcompile"`)

    tinf = @snoopi_deep precompilation_input()
    ttot, pcs = SnoopCompile.parcel(tinf)
    SnoopCompile.write("./snoopcompile/", pcs)

    # Remove all precompile files that are not related to PrettyTables.jl.
    run(`bash -c "find ./snoopcompile/precompile* -maxdepth 1 ! -name \"*PrettyTables*\" -type f -exec rm -f {} \\;"`)
    run(`bash -c "mv ./snoopcompile/* ./"`)
    run(`bash -c "rm -rf ./snoopcompile/"`)
end

create_precompile_files()
