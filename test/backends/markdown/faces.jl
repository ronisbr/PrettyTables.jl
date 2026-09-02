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

    @testset "General Highlighter" begin
        f = (data, i, j) -> i == 1

        expected = """
| **Col. 1** | **Col. 2** |
|-----------:|-----------:|
|      **1** |      **2** |
|          3 |          4 |
"""

        h = Highlighter(f, Face(; weight = :bold, foreground = "#ff0000"))
        @test pretty_table(String, matrix; backend = :markdown, highlighters = [h]) ==
            expected
        @test PrettyTables._markdown__native_highlighter(h)._decoration == MarkdownStyle(; bold = true)
        @test pretty_table(String, matrix; backend = :markdown, highlighters = [h]) ==
            expected

        # The function `fd` can return a face or the native decoration.
        h = Highlighter(f, (h, data, i, j) -> Face(; weight = :bold))
        @test pretty_table(String, matrix; backend = :markdown, highlighters = [h]) ==
            expected

        h = Highlighter(f, (h, data, i, j) -> MarkdownStyle(; bold = true))
        @test pretty_table(String, matrix; backend = :markdown, highlighters = [h]) ==
            expected

        # Highlighters of different types can be mixed, and the first match wins.
        hs = AbstractHighlighter[
            MarkdownHighlighter((data, i, j) -> false, MarkdownStyle(; italic = true)),
            Highlighter(f, Face(; weight = :bold)),
            MarkdownHighlighter(f, MarkdownStyle(; italic = true)),
        ]
        @test pretty_table(String, matrix; backend = :markdown, highlighters = hs) ==
            expected

        # Highlighters of other back ends are not accepted.
        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            backend = :markdown,
            highlighters = [TextHighlighter(f, crayon"red")],
        )
    end

    @static if VERSION >= v"1.11"
        @testset "Styled Strings" begin
            matrix = [
                styled"{yellow,bold:Yellow, Bold}" styled"{blue:Blue} & <x>"
                styled"{red: Red}"                 styled"{(fg=green),(bg=blue):Green}_{italic:it}"
            ]

            expected = """
|        **\\<A\\>** |        **B** |
|-----------------:|-------------:|
| **Yellow, Bold** | Blue & \\<x\\> |
|              Red |  Green\\_*it* |
"""

            for renderer in (:print, :show)
                result = pretty_table(
                    String,
                    matrix;
                    backend = :markdown,
                    column_labels = [styled"<{red:A}>", "B"],
                    renderer = renderer,
                )
                @test result == expected
            end

            # The Markdown characters are not escaped if the user allows Markdown in the
            # cells.
            result = pretty_table(
                String,
                [styled"{bold:_a_}"];
                backend = :markdown,
                allow_markdown_in_cells = true,
            )
            @test occursin("**_a_**", result)
        end
    end
end
