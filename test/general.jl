## Description #############################################################################
#
# General tests.
#
############################################################################################

@testset "Automatic Column Label Merge" begin
    matrix = [1 2 3 4 5; 6 7 8 9 10]
    column_labels = [
        MultiColumn(2, "Merged Col. 1"), MultiColumn(2, "Merged Col. 2", :l), EmptyCells(1)
    ]

    expected = """
┌───────────────────────────────────┬───────────────────────────────────┬─────────────────┐
│           Merged Col. 1           │ Merged Col. 2                     │                 │
├─────────────────┬─────────────────┼─────────────────┬─────────────────┼─────────────────┤
│               1 │               2 │               3 │               4 │               5 │
│               6 │               7 │               8 │               9 │              10 │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────┘
"""

    result = pretty_table(String, matrix; column_labels, fixed_data_column_widths = 15)
    @test result == expected
end

@testset "Merge Column Label Cells" begin
    matrix = [1 2 3; 4 5 6]
    column_labels = [MultiColumn(2, "Test"), "B", "C"]

    expected = """
┌────────────────────────────┬───┬───┐
│ MultiColumn(2, "Test", :c) │ B │ C │
├────────────────────────────┼───┼───┤
│                          1 │ 2 │ 3 │
│                          4 │ 5 │ 6 │
└────────────────────────────┴───┴───┘
"""

    result = pretty_table(
        String, matrix; column_labels, merge_column_label_cells = :something
    )
    @test result == expected

    @test_throws ArgumentError pretty_table(String, matrix; column_labels)
end

@testset "Show Only First Column Label" begin
    matrix = [1 2 3; 4 5 6]
    column_labels = [["A", "B", "C"], ["D", "E", "F"]]

    expected = """
┌───┬───┬───┐
│ A │ B │ C │
├───┼───┼───┤
│ 1 │ 2 │ 3 │
│ 4 │ 5 │ 6 │
└───┴───┴───┘
"""

    result = pretty_table(
        String, matrix; column_labels, show_first_column_label_only = true
    )
    @test result == expected
end

@testset "Zero-Column Tables" verbose = true begin
    # A table without columns must be rendered exactly the same whether or not the column
    # labels are shown, and it must never throw.
    matrix = Matrix{Int}(undef, 3, 0)

    @testset "Column Labels Do Not Change the Output" begin
        for backend in (:text, :latex, :markdown, :typst, :html)
            shown  = pretty_table(String, matrix; backend, show_column_labels = true)
            hidden = pretty_table(String, matrix; backend, show_column_labels = false)

            @test shown == hidden
        end
    end

    @testset "Text Back End Keywords" begin
        # `line_breaks` used to index a 3×0 matrix at `[1, 1:1]`, and
        # `equal_data_column_widths` used to reduce over an empty collection.
        @test pretty_table(String, matrix; line_breaks = true) == ""
        @test pretty_table(String, matrix; equal_data_column_widths = true) == ""
    end
end

@testset "Cropping to Zero Rows" verbose = true begin
    matrix = [10i + j for i in 1:6, j in 1:2]

    @testset "Column Labels Hidden" begin
        # The `show_column_labels` shortcut in the printing state iterator used to jump over
        # the rule that sends a table cropped to zero rows to the continuation row. Hence,
        # the text back end indexed a 0×2 matrix and the HTML back end silently printed every
        # data row.
        expected = """
┌───┬───┐
│ ⋮ │ ⋮ │
└───┴───┘
6 rows omitted
"""

        result = pretty_table(
            String,
            matrix;
            maximum_number_of_rows = 0,
            show_column_labels = false,
        )

        @test result == expected

        # No back end may leak a data row.
        for backend in (:text, :latex, :markdown, :typst, :html)
            result = pretty_table(
                String,
                matrix;
                backend,
                maximum_number_of_rows = 0,
                show_column_labels = false,
            )

            @test !occursin("11", result)
        end
    end
end

@testset "Maximum Number of Columns Equal to Zero" begin
    # `maximum_number_of_columns == 0` means "no limit", exactly like a negative value. Some
    # back ends used to treat it as "crop to a single column", laying out one column while
    # the iterator fed them all of them, which produced uncompilable LaTeX and Typst.
    matrix = [1 2 3; 4 5 6]

    for backend in (:text, :latex, :markdown, :typst, :html)
        limited   = pretty_table(String, matrix; backend, maximum_number_of_columns = 0)
        unlimited = pretty_table(String, matrix; backend)

        @test limited == unlimited
    end

    @test occursin("{|r|r|r|}", pretty_table(
        String,
        matrix;
        backend = :latex,
        maximum_number_of_columns = 0,
    ))
end

@testset "Width Keyword Validation" verbose = true begin
    matrix = [1 2 3; 4 5 6]

    @testset "Text Back End" begin
        for name in (
            :fixed_data_column_widths,
            :minimum_data_column_widths,
            :maximum_data_column_widths,
        )
            @test_throws ArgumentError pretty_table(
                String,
                matrix;
                NamedTuple{(name,)}(([5],))...,
            )
        end
    end
end

@testset "Multiple Footnotes in the Same Cell" verbose = true begin
    # A cell may carry more than one footnote. The loop that appends the second and further
    # references was never executed, since every existing test attaches at most one footnote
    # per cell.
    matrix = [1 2]

    footnotes = [
        (:data, 1, 1) => "one",
        (:data, 1, 1) => "two",
    ]

    @testset "Text" begin
        result = pretty_table(String, matrix; footnotes)
        @test occursin("1¹ʼ²", result)
    end

    @testset "LaTeX" begin
        result = pretty_table(String, matrix; backend = :latex, footnotes)
        @test occursin("1\$^{1,2}\$", result)
    end

    @testset "HTML" begin
        result = pretty_table(String, matrix; backend = :html, footnotes)
        @test occursin("1<sup>1,2</sup>", result)
    end

    @testset "Markdown" begin
        result = pretty_table(String, matrix; backend = :markdown, footnotes)
        @test occursin("1[^1][^2]", result)
    end

    @testset "Typst" begin
        result = pretty_table(String, matrix; backend = :typst, footnotes)
        @test occursin("[1#super[1], #super[2]],", result)
    end
end
