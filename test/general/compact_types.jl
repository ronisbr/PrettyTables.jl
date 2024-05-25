## Description #############################################################################
#
# Tests of compact type strings.
#
############################################################################################

@testset "Compact Types" begin
    # == Dictionary ========================================================================

    data = Dict(:a => Int64(1), missing => Int64(2), :c => missing)

    expected = """
┌─────────┬─────────┐
│    Keys │  Values │
│ Symbol? │  Int64? │
├─────────┼─────────┤
│       a │       1 │
│       c │ missing │
│ missing │       2 │
└─────────┴─────────┘
"""
    result = pretty_table(String, data, sortkeys = true)
    @test result == expected

    # == Tables.jl API =====================================================================

    table = (
        a = [missing, Int64(1), Int64(2), Int64(3)],
        b = [nothing, Int64(1), missing, Int64(1)]
    )

    expected = """
┌─────────┬────────────────────┐
│       a │                  b │
│  Int64? │ U{Nothing, Int64}? │
├─────────┼────────────────────┤
│ missing │            nothing │
│       1 │                  1 │
│       2 │            missing │
│       3 │                  1 │
└─────────┴────────────────────┘
"""
    result = pretty_table(String, table)
    @test result == expected
end
