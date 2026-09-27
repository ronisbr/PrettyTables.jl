## Description #############################################################################
#
# Word Back End: Test the highlighters.
#
############################################################################################

@testset "DocxHighlighter" verbose = true begin
    matrix = [1 2; 3 4]

    table = pretty_table(
        W.Table,
        matrix;
        highlighters = [
            DocxHighlighter(
                (data, i, j) -> data[i, j] == 3,
                ["bold" => "true", "color" => "FF0000", "background" => "EEEEEE"],
            ),
            DocxHighlighter((data, i, j) -> j == 2, ["italic" => "true"]),
        ],
    )

    highlighted = only(docx_runs(docx_cell(table, 3, 1))).properties
    @test highlighted.bold == true
    @test docx_hex(highlighted.color) == "FF0000"
    @test docx_hex(docx_shading(docx_cell(table, 3, 1)).fill) == "EEEEEE"

    # Only the first matching highlighter is applied.
    @test only(docx_runs(docx_cell(table, 3, 2))).properties.italic == true
    @test only(docx_runs(docx_cell(table, 3, 1))).properties.italic === nothing

    @test only(docx_runs(docx_cell(table, 2, 1))).properties.bold === nothing
end

@testset "Highlighter Decoration Overriding the Style" verbose = true begin
    table = pretty_table(
        W.Table,
        [1 2; 3 4];
        style = DocxTableStyle(;
            data_cell = ["color" => "0000FF", "background" => "FFFFFF"]
        ),
        highlighters = [
            DocxHighlighter(
                (data, i, j) -> true,
                ["color" => "FF0000", "background" => "EEEEEE"],
            ),
        ],
    )

    @test docx_hex(only(docx_runs(docx_cell(table, 2, 1))).properties.color) == "FF0000"
    @test docx_hex(docx_shading(docx_cell(table, 2, 1)).fill) == "EEEEEE"
end

@testset "Highlighters With a Decoration Function" verbose = true begin
    table = pretty_table(
        W.Table,
        [1 2; 3 4];
        highlighters = [
            DocxHighlighter(
                (data, i, j) -> true,
                (h, data, i, j) -> data[i, j] > 2 ? ["bold" => "true"] : DocxPair[],
            ),
        ],
    )

    @test only(docx_runs(docx_cell(table, 2, 1))).properties.bold === nothing
    @test only(docx_runs(docx_cell(table, 3, 1))).properties.bold == true
end

@testset "Backend-Agnostic Highlighters" verbose = true begin
    table = pretty_table(
        W.Table,
        [1 2; 3 4];
        highlighters = [Highlighter((data, i, j) -> data[i, j] == 4; weight = :bold)],
    )

    @test only(docx_runs(docx_cell(table, 3, 2))).properties.bold == true
    @test only(docx_runs(docx_cell(table, 3, 1))).properties.bold === nothing

    @test_throws "does not support highlighters of type" pretty_table(
        W.Table,
        [1 2; 3 4];
        highlighters = [TextHighlighter((data, i, j) -> true, Face(; foreground = :red))]
    )
end
