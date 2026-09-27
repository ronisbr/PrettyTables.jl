## Description #############################################################################
#
# Test errors and exceptions.
#
############################################################################################

@testset "Data With More Than Two Dimensions" begin
    @test_throws "does not support data with more than 2 dimensions" pretty_table(
        String, ones(2, 2, 2)
    )
end

@testset "Alignment Vector Length" begin
    data = [1 2 3 4]
    @test_throws ArgumentError pretty_table(data; alignment = [:c])
    @test_throws ArgumentError pretty_table(data; alignment = [:c, :c, :c])
    @test_throws ArgumentError pretty_table(data; alignment = [:c, :c, :c, :c, :c])
end

@testset "Invalid Alignments" begin
    data = [1 2]

    for kw in (
        :alignment,
        :column_label_alignment,
        :continuation_row_alignment,
        :footnote_alignment,
        :row_group_label_alignment,
        :row_label_column_alignment,
        :row_number_column_alignment,
        :source_note_alignment,
        :subtitle_alignment,
        :title_alignment,
    )
        @test_throws "Invalid alignment `:center`." pretty_table(
            String, data; (kw => :center,)...
        )
    end

    @test_throws "Invalid alignment `:x`." pretty_table(String, data; alignment = [:l, :x])

    @test_throws "Invalid alignment `:x`." pretty_table(
        String, data; cell_alignment = [(d, i, j) -> :x]
    )

    @test_throws "Invalid alignment `:x`." pretty_table(
        String, data; cell_alignment = [(1, 1) => :x]
    )

    @test_throws "Invalid alignment `:x`." MultiColumn(2, "A", :x)
    @test_throws "Invalid alignment `:x`." MergeCells(1, 1, 2, "A", :x)
end

@testset "Column Label Alignment and Row Label Lengths" begin
    data = [1 2; 3 4]

    @test_throws "The length of vector `column_label_alignment` (1) must be equal to the number of columns (2)." pretty_table(
        String, data; column_label_alignment = [:l]
    )

    @test_throws "The vector `row_labels` (1) must have at least one element per row (2)." pretty_table(
        String, data; row_labels = ["a"]
    )

    # The extra row labels are ignored.
    @test pretty_table(String, data; row_labels = ["a", "b", "c"]) ==
        pretty_table(String, data; row_labels = ["a", "b"])
end

@testset "Column Labels Without Rows" begin
    @test_throws "`column_labels` must have at least one row of labels." pretty_table(
        String, [1 2]; column_labels = Vector{String}[]
    )
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

@testset "Vertical Crop Mode" begin
    for backend in (:text, :html, :latex, :markdown, :typst)
        @test_throws "The vertical crop mode must be `:bottom` or `:middle`." pretty_table(
            String,
            collect(1:10);
            backend,
            maximum_number_of_rows = 4,
            vertical_crop_mode = :top,
        )
    end
end

@testset "Summary Row Labels Without Summary Rows" begin
    for backend in (:text, :html, :latex, :markdown, :typst)
        @test_throws "`summary_row_labels` requires `summary_rows`." pretty_table(
            String, [1 2]; backend, summary_row_labels = ["x"]
        )
    end
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

@testset "Column Label Style Vector Length" begin
    # When `first_line_column_label` or `column_label` is given as a vector, it must hold
    # exactly one style per column. Only the `first_line_column_label` check was covered.
    data = [1 2 3]

    @test_throws ArgumentError pretty_table(
        String, data; style = TextTableStyle(; column_label = [Face(; weight = :bold)])
    )

    @test_throws ArgumentError pretty_table(
        String,
        data;
        style = TextTableStyle(; first_line_column_label = [Face(; weight = :bold)])
    )

    @test_throws ArgumentError pretty_table(
        String, data; backend = :latex, style = LatexTableStyle(; column_label = [["textbf"]])
    )

    @test_throws ArgumentError pretty_table(
        String,
        data;
        backend = :html,
        style = HtmlTableStyle(; column_label = [["color" => "red"]]),
    )

    @test_throws ArgumentError pretty_table(
        String,
        data;
        backend = :markdown,
        style = MarkdownTableStyle(; column_label = [MarkdownStyle(; bold = true)]),
    )
end
