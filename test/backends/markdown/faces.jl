## Description #############################################################################
#
# Markdown Back End: Tests related with faces.
#
############################################################################################

@testset "Faces" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Table Style" begin
        native_style = MarkdownTableStyle(;
            row_number_label = MarkdownStyle(; italic = true),
            column_label     = MarkdownStyle(; strikethrough = true),
            row_number       = MarkdownStyle(),
        )

        face_style = MarkdownTableStyle(;
            row_number_label = Face(; slant = :italic),
            column_label     = Face(; strikethrough = true, foreground = :red),
            row_number       = Face(; weight = :light),
        )

        @test native_style == face_style

        kwargs = (;
            backend = :markdown,
            column_labels = [["A", "B"], ["C", "D"]],
            show_row_number_column = true,
        )

        expected = pretty_table(String, matrix; style = native_style, kwargs...)
        result   = pretty_table(String, matrix; style = face_style, kwargs...)

        @test result == expected
        @test occursin("*Row*", result)
        @test occursin("~~C~~", result)
    end

    @testset "Column Label Style Vectors" begin
        style = MarkdownTableStyle(;
            first_line_column_label = [Face(; weight = :bold), MarkdownStyle(; code = true)],
            column_label            = [Face(; slant = :italic), Face(; strikethrough = true)],
        )

        @test style.first_line_column_label ==
            [MarkdownStyle(; bold = true), MarkdownStyle(; code = true)]
        @test style.column_label ==
            [MarkdownStyle(; italic = true), MarkdownStyle(; strikethrough = true)]

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            style = style,
            column_labels = [["A", "B"], ["C", "D"]],
        )

        @test occursin("| **A**<br>*C* | `B`<br>~~D~~ |", result)

        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            backend = :markdown,
            style = MarkdownTableStyle(; column_label = [Face()]),
        )
    end
end
