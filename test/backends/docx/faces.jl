## Description #############################################################################
#
# Word Back End: Tests related with faces.
#
############################################################################################

@testset "Faces" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Table Style" begin
        native_style = DocxTableStyle(;
            title            = ["bold" => "true", "size" => "10.5", "color" => "A51C2C"],
            row_number_label = ["italic" => "true"],
            column_label     = ["background" => "0000FF"],
        )

        face_style = DocxTableStyle(;
            title            = Face(; weight = :bold, foreground = :red, height = 105),
            row_number_label = Face(; slant = :italic),
            column_label     = Face(; background = 0x0000ff),
        )

        for field in fieldnames(DocxTableStyle)
            @test getfield(native_style, field) == getfield(face_style, field)
        end

        table = pretty_table(
            W.Table,
            matrix;
            style = face_style,
            title = "Title",
            column_labels = [["A", "B"], ["C", "D"]],
            show_row_number_column = true,
        )

        title = only(docx_runs(docx_cell(table, 1, 1))).properties
        @test title.bold == true
        @test docx_hex(title.color) == "A51C2C"

        # Word supports font sizes in half points.
        @test convert(W.Point, title.size).value == 10.5

        @test only(docx_runs(docx_cell(table, 2, 1))).properties.italic == true
        @test docx_hex(docx_shading(docx_cell(table, 3, 2)).fill) == "0000FF"
    end

    @testset "Column Label Style Vectors" begin
        style = DocxTableStyle(;
            first_line_column_label = [Face(; foreground = "#ff0000"), ["color" => "0000FF"]],
            column_label            = [Face(; weight = :bold), Face(; slant = :italic)],
        )

        @test style.first_line_column_label == [["color" => "FF0000"], ["color" => "0000FF"]]
        @test style.column_label == [["bold" => "true"], ["italic" => "true"]]

        table = pretty_table(
            W.Table, matrix; style = style, column_labels = [["A", "B"], ["C", "D"]]
        )

        @test docx_hex(only(docx_runs(docx_cell(table, 1, 1))).properties.color) == "FF0000"
        @test docx_hex(only(docx_runs(docx_cell(table, 1, 2))).properties.color) == "0000FF"
        @test only(docx_runs(docx_cell(table, 2, 1))).properties.bold == true
        @test only(docx_runs(docx_cell(table, 2, 2))).properties.italic == true
    end

    @testset "General Highlighter" begin
        f = (data, i, j) -> i == 1

        h = Highlighter(f, Face(; weight = :bold, foreground = "#ff0000"))

        table = pretty_table(W.Table, matrix; highlighters = [h])

        # The data starts at the second row because of the column labels.
        for col in 1:2
            properties = only(docx_runs(docx_cell(table, 2, col))).properties
            @test properties.bold == true
            @test docx_hex(properties.color) == "FF0000"
        end

        @test only(docx_runs(docx_cell(table, 3, 1))).properties.color === nothing

        # A background shades the cell.
        h     = Highlighter(f, Face(; background = "#00ff00"))
        table = pretty_table(W.Table, matrix; highlighters = [h])
        @test docx_hex(docx_shading(docx_cell(table, 2, 1)).fill) == "00FF00"

        # The function `fd` can return a face or the native decoration.
        h     = Highlighter(f, (h, data, i, j) -> Face(; foreground = "#ff0000"))
        table = pretty_table(W.Table, matrix; highlighters = [h])
        @test docx_hex(only(docx_runs(docx_cell(table, 2, 1))).properties.color) == "FF0000"

        h     = Highlighter(f, (h, data, i, j) -> ["color" => "FF0000"])
        table = pretty_table(W.Table, matrix; highlighters = [h])
        @test docx_hex(only(docx_runs(docx_cell(table, 2, 1))).properties.color) == "FF0000"

        # Highlighters of different types can be mixed, and the first match wins.
        hs = AbstractHighlighter[
            DocxHighlighter((data, i, j) -> false, ["color" => "0000FF"]),
            Highlighter(f, Face(; foreground = "#ff0000")),
            DocxHighlighter(f, ["color" => "0000FF"]),
        ]

        table = pretty_table(W.Table, matrix; highlighters = hs)
        @test docx_hex(only(docx_runs(docx_cell(table, 2, 1))).properties.color) == "FF0000"

        # The Word highlighters also accept a face, a crayon, and the keywords of both.
        for h in (
            DocxHighlighter(f, Face(; slant = :italic)),
            DocxHighlighter(f, crayon"italics"),
            DocxHighlighter(f; italics = true),
        )
            table = pretty_table(W.Table, matrix; highlighters = [h])
            @test only(docx_runs(docx_cell(table, 2, 1))).properties.italic == true
        end
    end
end
