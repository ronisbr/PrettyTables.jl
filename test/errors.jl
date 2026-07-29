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

    # Both indices are 1-based, meaning 0 must be rejected by the validator instead of
    # blowing up later inside a back end with a `BoundsError`.
    @test_throws ArgumentError pretty_table(
        data; merge_column_label_cells = [MergeCells(1, 0, 2, "X")]
    )

    @test_throws ArgumentError pretty_table(
        data; merge_column_label_cells = [MergeCells(0, 1, 2, "X")]
    )
end

@testset "Renderer Selection" begin
    data = [1 2 3 4]
    @test_throws ArgumentError pretty_table(data; renderer = :something)
end

@testset "Summary Row and Summary Row Label Lengths" begin
    data = [
        1 2 3
        4 5 6
    ]

    @test_throws ArgumentError pretty_table(
        data, summary_rows = [(data, i) -> i], summary_row_labels = ["First", "Second"]
    )

    # The error message used to interpolate the `length` *function* instead of calling it.
    msg = try
        pretty_table(
            String,
            data;
            summary_rows = [sum],
            summary_row_labels = ["a", "b"],
        )
        ""
    catch e
        sprint(showerror, e)
    end

    @test occursin("`summary_rows` (1)", msg)
    @test occursin("`summary_row_labels` (2)", msg)
    @test !occursin("length(summary_rows)", msg)
end
