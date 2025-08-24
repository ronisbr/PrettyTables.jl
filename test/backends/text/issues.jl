## Description #############################################################################
#
# Text Back End: Issues.
#
############################################################################################

@testset "Issues" verbose = true begin
    @testset "Do not Escape Quotes" begin
        matrix = ["'" "\""]

        expected = """
┌────────┬────────┐
│ Col. 1 │ Col. 2 │
├────────┼────────┤
│      ' │      " │
└────────┴────────┘
"""

        result = pretty_table(String, matrix)

        @test result == expected
    end
end
