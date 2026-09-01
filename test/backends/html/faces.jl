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

        @test occursin(
            "<th style = \"border-left: 2px solid black; border-right: 1px solid black; color: #ff0000; text-align: right;\">A</th>",
            result
        )
        @test occursin(
            "<th style = \"border-right: 2px solid black; color: blue; text-align: right;\">B</th>",
            result
        )
        @test occursin(
            "<th style = \"border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;\">C</th>",
            result
        )
        @test occursin(
            "<th style = \"border-bottom: 1px solid black; border-right: 2px solid black; font-style: italic; text-align: right;\">D</th>",
            result
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
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; color: #ff0000; font-weight: bold; text-align: right;">1</td>
      <td style = "border-right: 2px solid black; color: #ff0000; font-weight: bold; text-align: right;">2</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">3</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">4</td>
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

    @static if VERSION >= v"1.11"
        @testset "Styled Strings" begin
            matrix = [
                styled"{yellow,bold:Yellow, Bold}" styled"{blue:Blue} & <x>"
                styled"{red: Red}"                 styled"{(fg=green),(bg=blue):Green}_{italic:it}"
            ]

            expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">&lt;<span style = "color: #a51c2c;">A</span>&gt;</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">B</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;"><span style = "color: #e5a509; font-weight: bold;">Yellow, Bold</span></td>
      <td style = "border-right: 2px solid black; text-align: right;"><span style = "color: #195eb3;">Blue</span> &amp; &lt;x&gt;</td>
    </tr>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;"><span style = "color: #a51c2c;"> Red</span></td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;"><span style = "background-color: #195eb3; color: #25a268;">Green</span>_<span style = "font-style: italic;">it</span></td>
    </tr>
  </tbody>
</table>
"""

            for renderer in (:print, :show)
                result = pretty_table(
                    String,
                    matrix;
                    backend = :html,
                    column_labels = [styled"<{red:A}>", "B"],
                    renderer = renderer,
                )
                @test result == expected
            end

            # The HTML characters are not escaped if the user allows HTML in the cells.
            result = pretty_table(
                String, [styled"{bold:<b>}"]; backend = :html, allow_html_in_cells = true
            )
            @test occursin("<span style = \"font-weight: bold;\"><b></span>", result)
        end
    end
end
