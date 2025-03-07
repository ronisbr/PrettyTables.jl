## Description #############################################################################
#
# Text Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
    @testset "Undefined Cells" begin
        v    = Vector{Any}(undef, 5)
        v[1] = undef
        v[2] = "String"
        v[5] = π

        expected = """
┌────────────────────┐
│             Col. 1 │
├────────────────────┤
│ UndefInitializer() │
│             String │
│             #undef │
│             #undef │
│                  π │
└────────────────────┘
"""

        result = pretty_table(
            String,
            v
        )

        @test result == expected

        result = pretty_table(
            String,
            v;
            renderer = :show
        )

        @test result == expected
    end

end
