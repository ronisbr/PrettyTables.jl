## Description #############################################################################
#
# Tests related to wrong arguments.
#
############################################################################################

@testset "Errors" begin
    @test_throws Exception pretty_table(data, vlines = :nothing)
    @test_throws Exception pretty_table(data, hlines = :nothing)
end
