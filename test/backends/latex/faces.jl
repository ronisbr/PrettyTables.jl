## Description #############################################################################
#
# LaTeX Back End: Tests related with faces.
#
############################################################################################

@testset "Faces" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Table Style" begin
        native_style = LatexTableStyle(;
            title            = ["textbf", "textcolor[HTML]{A51C2C}"],
            row_number_label = ["textit"],
            column_label     = ["underline"],
        )

        face_style = LatexTableStyle(;
            title            = Face(; weight = :bold, foreground = :red),
            row_number_label = Face(; slant = :italic),
            column_label     = Face(; underline = true),
        )

        for field in fieldnames(LatexTableStyle)
            @test getfield(native_style, field) == getfield(face_style, field)
        end

        kwargs = (;
            backend = :latex,
            title = "Title",
            column_labels = [["A", "B"], ["C", "D"]],
            show_row_number_column = true,
        )

        expected = pretty_table(String, matrix; style = native_style, kwargs...)
        result   = pretty_table(String, matrix; style = face_style, kwargs...)

        @test result == expected
        @test occursin("\\textcolor[HTML]{A51C2C}{\\textbf{Title}}", result)
        @test occursin("\\underline{C}", result)
    end

    @testset "Column Label Style Vectors" begin
        style = LatexTableStyle(;
            first_line_column_label = [Face(; foreground = "#ff0000"), ["textsc"]],
            column_label            = [Face(; weight = :bold), Face(; slant = :italic)],
        )

        @test style.first_line_column_label == [["textcolor[HTML]{FF0000}"], ["textsc"]]
        @test style.column_label == [["textbf"], ["textit"]]

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            style = style,
            column_labels = [["A", "B"], ["C", "D"]],
        )

        @test occursin("\\textcolor[HTML]{FF0000}{A} & \\textsc{B}", result)
        @test occursin("\\textbf{C} & \\textit{D}", result)

        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            backend = :latex,
            style = LatexTableStyle(; column_label = [Face()]),
        )
    end

    @testset "General Highlighter" begin
        f = (data, i, j) -> i == 1

        expected = """
\\begin{tabular}{|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} \\\\
  \\hline
  \\textcolor[HTML]{FF0000}{\\textbf{1}} & \\textcolor[HTML]{FF0000}{\\textbf{2}} \\\\
  3 & 4 \\\\
  \\hline
\\end{tabular}
"""

        h = Highlighter(f, Face(; weight = :bold, foreground = "#ff0000"))
        @test pretty_table(String, matrix; backend = :latex, highlighters = [h]) == expected
        @test PrettyTables._latex__native_highlighter(h)._environments == ["textbf", "textcolor[HTML]{FF0000}"]
        @test pretty_table(String, matrix; backend = :latex, highlighters = [h]) == expected

        # The function `fd` can return a face or the native decoration.
        h = Highlighter(
            f, (h, data, i, j) -> Face(; weight = :bold, foreground = "#ff0000")
        )
        @test pretty_table(String, matrix; backend = :latex, highlighters = [h]) == expected

        h = Highlighter(f, (h, data, i, j) -> ["textbf", "textcolor[HTML]{FF0000}"])
        @test pretty_table(String, matrix; backend = :latex, highlighters = [h]) == expected

        # Highlighters of different types can be mixed, and the first match wins.
        hs = AbstractHighlighter[
            LatexHighlighter((data, i, j) -> false, ["textit"]),
            Highlighter(f, Face(; weight = :bold, foreground = "#ff0000")),
            LatexHighlighter(f, ["textit"]),
        ]
        @test pretty_table(String, matrix; backend = :latex, highlighters = hs) == expected

        # Highlighters of other back ends are not accepted.
        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            backend = :latex,
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
\\begin{tabular}{|r|r|}
  \\hline
  \\textbf{<\\textcolor[HTML]{A51C2C}{A}>} & \\textbf{B} \\\\
  \\hline
  \\textcolor[HTML]{E5A509}{\\textbf{Yellow, Bold}} & \\textcolor[HTML]{195EB3}{Blue} \\& <x> \\\\
  \\textcolor[HTML]{A51C2C}{ Red} & \\colorbox[HTML]{195EB3}{\\textcolor[HTML]{25A268}{Green}}\\_\\textit{it} \\\\
  \\hline
\\end{tabular}
"""

            for renderer in (:print, :show)
                result = pretty_table(
                    String,
                    matrix;
                    backend = :latex,
                    column_labels = [styled"<{red:A}>", "B"],
                    renderer = renderer,
                )
                @test result == expected
            end
        end
    end
end
