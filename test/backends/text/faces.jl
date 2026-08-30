## Description #############################################################################
#
# Text Back End: Tests related with faces.
#
############################################################################################

@testset "Faces" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Table Style" begin
        # The default style must render the same bytes as the equivalent crayons.
        crayon_style = TextTableStyle(;
            title                          = crayon"bold",
            column_label                   = crayon"fg:dark_gray",
            first_line_merged_column_label = crayon"bold underline",
            merged_column_label            = crayon"fg:dark_gray underline",
            omitted_cell_summary           = crayon"fg:cyan",
        )

        kwargs = (;
            color = true,
            title = "Title",
            column_labels = [[MultiColumn(2, "Merged")], ["A", "B"]],
            maximum_number_of_columns = 1,
        )

        expected = pretty_table(String, matrix; kwargs...)
        @test pretty_table(String, matrix; style = crayon_style, kwargs...) == expected

        face_style = TextTableStyle(;
            title                          = Face(; weight = :bold),
            column_label                   = Face(; foreground = :bright_black),
            first_line_merged_column_label = Face(; weight = :bold, underline = true),
            merged_column_label            = Face(; foreground = :bright_black, underline = true),
            omitted_cell_summary           = Face(; foreground = :cyan),
        )

        @test pretty_table(String, matrix; style = face_style, kwargs...) == expected
        @test occursin("\e[1m", expected) && occursin("Title\e[0m", expected)
        @test occursin("\e[1;4m", expected)
        @test occursin("\e[90m", expected)
        @test occursin("\e[36m", expected)

        # A style with faces and one with the equivalent crayons must have the same fields.
        crayon_style = TextTableStyle(;
            table_border = crayon"blue",
            row_label    = crayon"bold red",
        )

        face_style = TextTableStyle(;
            table_border = Face(; foreground = :blue),
            row_label    = Face(; weight = :bold, foreground = :red),
        )

        for field in fieldnames(TextTableStyle)
            @test getfield(crayon_style, field) == getfield(face_style, field)
        end

        # The style must not add escape sequences if the color is disabled.
        style  = TextTableStyle(; table_border = Face(; foreground = :blue))
        result = pretty_table(String, matrix; style = style, color = false)
        @test !occursin("\e", result)

        result = pretty_table(String, matrix; style = style, color = true)
        @test occursin("\e[34m┌", result)
    end

    @testset "Column Label Style Vectors" begin
        style = TextTableStyle(;
            first_line_column_label = [Face(; foreground = :red), crayon"blue"],
            column_label            = Face[Face(; weight = :bold), Face(; slant = :italic)],
        )

        @test style.first_line_column_label ==
            [Face(; foreground = :red), Face(; foreground = :blue)]

        result = pretty_table(
            String,
            matrix;
            style         = style,
            color         = true,
            column_labels = [["A", "B"], ["C", "D"]],
        )

        @test occursin("\e[31m A \e[0m", result)
        @test occursin("\e[34m B \e[0m", result)
        @test occursin("\e[1m C \e[0m", result)
        @test occursin("\e[3m D \e[0m", result)

        @test_throws ArgumentError pretty_table(
            String, matrix; style = TextTableStyle(; column_label = [Face()])
        )
    end

    @testset "Highlighters" begin
        f = (data, i, j) -> i == 1

        expected = pretty_table(
            String,
            matrix;
            color = true,
            highlighters = [TextHighlighter(f, crayon"bold italics")],
        )

        @test occursin("\e[1;3m      1 \e[0m", expected)

        h = TextHighlighter(f, Face(; weight = :bold, slant = :italic))
        @test h._sgr == "\e[1;3m"
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected

        h = TextHighlighter(f; weight = :bold, slant = :italic)
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected

        h = TextHighlighter(f; bold = true, italics = true)
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected

        # The function `fd` can return a face or a crayon.
        h = TextHighlighter(f, (h, data, i, j) -> Face(; weight = :bold, slant = :italic))
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected

        h = TextHighlighter(f, (h, data, i, j) -> crayon"bold italics")
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected

        h = TextHighlighter(f, (h, data, i, j) -> "bold")
        @test_throws ArgumentError pretty_table(
            String, matrix; color = true, highlighters = [h]
        )

        # A face without attributes must not add escape sequences.
        h = TextHighlighter(f, Face())
        @test pretty_table(String, matrix; color = true, highlighters = [h]) ==
            pretty_table(String, matrix; color = true)

        # The named colors of the crayons are translated to the ones of the faces.
        h = TextHighlighter(f; foreground = :dark_gray, background = :light_red)
        @test h._decoration == Face(; foreground = :bright_black, background = :bright_red)
        @test h._sgr == "\e[90;101m"
    end

    @testset "General Highlighter" begin
        f = (data, i, j) -> i == 1

        expected = pretty_table(
            String,
            matrix;
            color = true,
            highlighters = [TextHighlighter(f, Face(; weight = :bold, slant = :italic))],
        )

        h = Highlighter(f, Face(; weight = :bold, slant = :italic))
        @test isnothing(h._text)
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected
        @test h._text == "\e[1;3m"
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected

        # The function `fd` can return a face or a crayon, which are not cached.
        h = Highlighter(f, (h, data, i, j) -> Face(; weight = :bold, slant = :italic))
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected
        @test isnothing(h._text)

        h = Highlighter(f, (h, data, i, j) -> crayon"bold italics")
        @test pretty_table(String, matrix; color = true, highlighters = [h]) == expected

        # Highlighters of different types can be mixed, and the first match wins.
        hs = AbstractHighlighter[
            TextHighlighter((data, i, j) -> false, crayon"red"),
            Highlighter(f, Face(; weight = :bold, slant = :italic)),
            TextHighlighter(f, crayon"red"),
        ]
        @test pretty_table(String, matrix; color = true, highlighters = hs) == expected

        # Highlighters of other back ends are not accepted.
        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            color = true,
            highlighters = [HtmlHighlighter(f, ["color" => "red"])],
        )
    end
end
