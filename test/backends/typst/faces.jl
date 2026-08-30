## Description #############################################################################
#
# Typst Back End: Tests related with faces.
#
############################################################################################

@testset "Faces" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Table Style" begin
        native_style = TypstTableStyle(;
            title            = ["text-weight" => "bold", "text-fill" => "rgb(\"#a51c2c\")"],
            row_number_label = ["text-style" => "italic"],
            column_label     = ["fill" => "rgb(\"#0000ff\")"],
        )

        face_style = TypstTableStyle(;
            title            = Face(; weight = :bold, foreground = :red),
            row_number_label = Face(; slant = :italic),
            column_label     = Face(; background = 0x0000ff),
        )

        for field in fieldnames(TypstTableStyle)
            @test getfield(native_style, field) == getfield(face_style, field)
        end

        kwargs = (;
            backend = :typst,
            title = "Title",
            column_labels = [["A", "B"], ["C", "D"]],
            show_row_number_column = true,
        )

        expected = pretty_table(String, matrix; style = native_style, kwargs...)
        result   = pretty_table(String, matrix; style = face_style, kwargs...)

        @test result == expected
        @test occursin("#text(weight: \"bold\", fill: rgb(\"#a51c2c\"),)[Title]", result)
        @test occursin("table.cell(fill: rgb(\"#0000ff\"),)[C]", result)
    end

    @testset "Column Label Style Vectors" begin
        style = TypstTableStyle(;
            first_line_column_label = [Face(; foreground = "#ff0000"), ["text-fill" => "blue"]],
            column_label            = [Face(; weight = :bold), Face(; slant = :italic)],
        )

        @test style.first_line_column_label ==
            [["text-fill" => "rgb(\"#ff0000\")"], ["text-fill" => "blue"]]
        @test style.column_label == [["text-weight" => "bold"], ["text-style" => "italic"]]

        result = pretty_table(
            String,
            matrix;
            backend = :typst,
            style = style,
            column_labels = [["A", "B"], ["C", "D"]],
        )

        @test occursin("[#text(fill: rgb(\"#ff0000\"),)[A]]", result)
        @test occursin("[#text(fill: blue,)[B]]", result)
        @test occursin("[#text(weight: \"bold\",)[C]]", result)
        @test occursin("[#text(style: \"italic\",)[D]]", result)
    end

    @testset "General Highlighter" begin
        f = (data, i, j) -> i == 1

        h = Highlighter(f, Face(; weight = :bold, foreground = "#ff0000"))
        @test isnothing(h._typst)

        expected = pretty_table(
            String,
            matrix;
            backend = :typst,
            highlighters = [
                TypstHighlighter(
                    f, ["text-weight" => "bold", "text-fill" => "rgb(\"#ff0000\")"]
                ),
            ],
        )

        @test occursin("[#text(weight: \"bold\", fill: rgb(\"#ff0000\"),)[1]]", expected)
        @test pretty_table(String, matrix; backend = :typst, highlighters = [h]) == expected
        @test h._typst == ["text-weight" => "bold", "text-fill" => "rgb(\"#ff0000\")"]
        @test pretty_table(String, matrix; backend = :typst, highlighters = [h]) == expected

        # A background is a cell property.
        h = Highlighter(f, Face(; background = "#00ff00"))
        result = pretty_table(String, matrix; backend = :typst, highlighters = [h])
        @test occursin("table.cell(fill: rgb(\"#00ff00\"),)[1]", result)

        # The function `fd` can return a face or the native decoration, which are not cached.
        h = Highlighter(
            f, (h, data, i, j) -> Face(; weight = :bold, foreground = "#ff0000")
        )
        @test pretty_table(String, matrix; backend = :typst, highlighters = [h]) == expected
        @test isnothing(h._typst)

        h = Highlighter(
            f,
            (h, data, i, j) -> ["text-weight" => "bold", "text-fill" => "rgb(\"#ff0000\")"],
        )
        @test pretty_table(String, matrix; backend = :typst, highlighters = [h]) == expected

        # Highlighters of different types can be mixed, and the first match wins.
        hs = AbstractHighlighter[
            TypstHighlighter((data, i, j) -> false, ["text-fill" => "blue"]),
            Highlighter(f, Face(; weight = :bold, foreground = "#ff0000")),
            TypstHighlighter(f, ["text-fill" => "blue"]),
        ]
        @test pretty_table(String, matrix; backend = :typst, highlighters = hs) == expected

        # Highlighters of other back ends are not accepted.
        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            backend = :typst,
            highlighters = [TextHighlighter(f, crayon"red")],
        )
    end
end
