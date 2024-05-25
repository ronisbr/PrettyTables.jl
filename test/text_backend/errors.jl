## Description #############################################################################
#
# Tests of errors in text backend.
#
############################################################################################

@testset "Errors in Keywords" begin
    @test_throws Exception pretty_table([1 2], header_crayon = [crayon"white"])
    @test_throws Exception pretty_table([1 2], subheader_crayon = [crayon"white"])
end
