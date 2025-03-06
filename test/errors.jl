## Description #############################################################################
#
# Test errors and exceptions.
#
############################################################################################

@testset "Alignment Vector Length" begin
    data = [1 2 3 4]
    @test_throws ArgumentError pretty_table(data; alignment = [:c])
    @test_throws ArgumentError pretty_table(data; alignment = [:c, :c, :c])
    @test_throws ArgumentError pretty_table(data; alignment = [:c, :c, :c, :c, :c])
end

@testset "Merge Cell Specifications" begin
    data = [1 2 3 4]
    merge_column_label_cells = [MergeCells(1, 1, 2, :c), MergeCells(1, 2, 2, :c)]
    @test_throws ArgumentError pretty_table(data; merge_column_label_cells)
end

@testset "Renderer Selection" begin
    data = [1 2 3 4]
    @test_throws ArgumentError pretty_table(data; renderer = :something)
end
