## Description #############################################################################
#
# HTML Back End: Tests related with faces.
#
############################################################################################

@testset "Faces" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Table Style" begin
        native_style = HtmlTableStyle(;
            title            = ["color" => "#a51c2c", "font-weight" => "bold"],
            row_number_label = ["font-style" => "italic"],
            column_label     = ["text-decoration" => "underline"],
        )

        face_style = HtmlTableStyle(;
            title            = Face(; weight = :bold, foreground = :red),
            row_number_label = Face(; slant = :italic),
            column_label     = Face(; underline = true),
        )

        for field in fieldnames(HtmlTableStyle)
            @test getfield(native_style, field) == getfield(face_style, field)
        end

        kwargs = (;
            backend = :html,
            title = "Title",
            column_labels = [["A", "B"], ["C", "D"]],
            show_row_number_column = true,
        )

        expected = pretty_table(String, matrix; style = native_style, kwargs...)
        result   = pretty_table(String, matrix; style = face_style, kwargs...)

        @test result == expected
        @test occursin("color: #a51c2c; font-weight: bold;", result)
        @test occursin("text-decoration: underline;", result)
    end

    @testset "Column Label Style Vectors" begin
        style = HtmlTableStyle(;
            first_line_column_label = [Face(; foreground = "#ff0000"), ["color" => "blue"]],
            column_label            = [Face(; weight = :bold), Face(; slant = :italic)],
        )

        @test style.first_line_column_label == [["color" => "#ff0000"], ["color" => "blue"]]
        @test style.column_label == [["font-weight" => "bold"], ["font-style" => "italic"]]

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            style = style,
            column_labels = [["A", "B"], ["C", "D"]],
        )

        @test occursin("<th style = \"color: #ff0000; text-align: right;\">A</th>", result)
        @test occursin("<th style = \"color: blue; text-align: right;\">B</th>", result)
        @test occursin(
            "<th style = \"font-weight: bold; text-align: right;\">C</th>", result
        )
        @test occursin(
            "<th style = \"font-style: italic; text-align: right;\">D</th>", result
        )

        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            backend = :html,
            style = HtmlTableStyle(; column_label = [Face()]),
        )
    end

    @testset "General Highlighter" begin
        f = (data, i, j) -> i == 1

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "color: #ff0000; font-weight: bold; text-align: right;">1</td>
      <td style = "color: #ff0000; font-weight: bold; text-align: right;">2</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
  </tbody>
</table>
"""

        h = Highlighter(f, Face(; weight = :bold, foreground = "#ff0000"))
        @test isnothing(h._html)
        @test pretty_table(String, matrix; backend = :html, highlighters = [h]) == expected
        @test h._html == ["color" => "#ff0000", "font-weight" => "bold"]
        @test pretty_table(String, matrix; backend = :html, highlighters = [h]) == expected

        # The function `fd` can return a face or the native decoration, which are not cached.
        h = Highlighter(
            f, (h, data, i, j) -> Face(; weight = :bold, foreground = "#ff0000")
        )
        @test pretty_table(String, matrix; backend = :html, highlighters = [h]) == expected
        @test isnothing(h._html)

        h = Highlighter(
            f, (h, data, i, j) -> ["color" => "#ff0000", "font-weight" => "bold"]
        )
        @test pretty_table(String, matrix; backend = :html, highlighters = [h]) == expected

        # Highlighters of different types can be mixed, and the first match wins.
        hs = AbstractHighlighter[
            HtmlHighlighter((data, i, j) -> false, ["color" => "blue"]),
            Highlighter(f, Face(; weight = :bold, foreground = "#ff0000")),
            HtmlHighlighter(f, ["color" => "blue"]),
        ]
        @test pretty_table(String, matrix; backend = :html, highlighters = hs) == expected

        # Highlighters of other back ends are not accepted.
        @test_throws ArgumentError pretty_table(
            String,
            matrix;
            backend = :html,
            highlighters = [TextHighlighter(f, crayon"red")],
        )
    end
end
