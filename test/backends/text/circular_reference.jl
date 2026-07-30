## Description #############################################################################
#
# Text Back End: Test circular reference.
#
############################################################################################

@testset "Circular Reference" begin
    cr = CircularRef([1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12])

    cr.A1[2]   = cr
    cr.A4[end] = cr

    expected = """
┌──────────────────────────┬────┬────┬──────────────────────────┐
│                       A1 │ A2 │ A3 │                       A4 │
├──────────────────────────┼────┼────┼──────────────────────────┤
│                        1 │  4 │  7 │                       10 │
│ #= circular reference =# │  5 │  8 │                       11 │
│                        3 │  6 │  9 │ #= circular reference =# │
└──────────────────────────┴────┴────┴──────────────────────────┘
"""

    result = sprint(show, cr)

    @test result == expected
end

@testset "Repeated Non-Circular Reference" begin
    # The same object printed in two different cells is not a circular reference. Hence,
    # both cells must be rendered.
    inner = CircularRef([1], [2], [3], [4])
    outer = CircularRef(Any[inner], Any[inner], [1], [2])

    result = pretty_table(String, outer; renderer = :show)

    @test !occursin("#= circular reference =#", result)
end
