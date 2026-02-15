## Description #############################################################################
#
# Excel Back End: Test circular reference.
#
############################################################################################

@testset "Circular Reference" verbose = true begin
    cr = CircularRef(
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [10, 11, 12]
    )

    cr.A1[2]   = cr
    cr.A4[end] = cr

#    f=pretty_table(cr; backend = :excel)#formatters = [fmt__excel_stringify(1:4)])

    
    # I can't obviously see how to address this in the Excel backend. 
    # There is an intervention upstream to flag `#= circular reference =#` 
    # which the `:excel` backend can't then handle in any way I can 
    # figure out.


#   @test result == expected
end

