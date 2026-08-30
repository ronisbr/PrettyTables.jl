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
end
