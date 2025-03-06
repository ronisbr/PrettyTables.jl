## Description #############################################################################
#
# Test errors and exceptions regarding text backend.
#
############################################################################################

struct MyCustomCell <: AbstractCustomTextCell end

@testset "Errors" verbose = true begin
    @testset "CustomCells" begin
        mcc = MyCustomCell()

        @test_throws Exception CustomTextCell.add_suffix!(mcc, "suffix")
        @test_throws Exception CustomTextCell.crop!(mcc, 10)
        @test_throws Exception CustomTextCell.init!(mcc, IOContext(IOBuffer()), Val(:print))
        @test_throws Exception CustomTextCell.init!(mcc, IOContext(IOBUffer()), Val(:show))
        @test_throws Exception CustomTextCell.left_padding!(mcc, 10)
        @test_throws Exception CustomTextCell.right_padding!(mcc, 10)
        @test_throws Exception CustomTextCell.rendered_cell(mcc)
        @test_throws Exception CustomTextCell.printable_cell_text(mcc)
    end
end
