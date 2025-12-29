## Description #############################################################################
#
# Typst Back End: Test related Typst.jl extender
#
############################################################################################
using Typstry

@testset "Renderers" verbose = true begin
    backend=:typst
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    @testset "Alignment as a Symbol" verbose = true  begin
      expected = """"""
      true
    end
end