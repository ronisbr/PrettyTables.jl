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

    @testset "Handle Correctly Empty Tables" begin

        expected = """
Title
Notes
"""

        result = pretty_table(String, []; title = "Title", source_notes = "Notes")
        @test result == expected
    end
end
