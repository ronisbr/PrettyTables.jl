## Description #############################################################################
#
# Word Back End: Test the table style.
#
############################################################################################

@testset "DocxTableStyle" verbose = true begin
    matrix = [1 2 3; 4 5 6]

    table = pretty_table(
        W.Table,
        matrix;
        title = "Title",
        subtitle = "Subtitle",
        stubhead_label = "Stub",
        show_row_number_column = true,
        row_labels = ["R1", "R2"],
        summary_row_labels = ["Total"],
        summary_rows = [(data, i) -> sum(data[:, i])],
        footnotes = [(:title, 1, 1) => "Footnote"],
        source_notes = "Source note",
        style = DocxTableStyle(;
            title = ["bold" => "true", "color" => "FFA500", "size" => "18"],
            subtitle = ["italic" => "true", "font" => "Palatino"],
            row_number_label = ["size" => "9"],
            row_number = ["color" => "0000FF"],
            stubhead_label = ["bold" => "true"],
            row_label = ["italic" => "true"],
            first_line_column_label = [
                ["bold" => "true"], ["color" => "FF0000"], ["size" => "24"]
            ],
            data_cell = ["background" => "EEEEEE"],
            summary_row_label = ["bold" => "true"],
            summary_row_cell = ["italic" => "true"],
            footnote = ["color" => "FF00FF"],
            source_note = ["color" => "00FFFF"],
        ),
    )

    title = first(docx_runs(docx_cell(table, 1, 1))).properties
    @test title.bold == true
    @test docx_hex(title.color) == "FFA500"
    @test convert(W.Point, title.size).value == 18

    subtitle = first(docx_runs(docx_cell(table, 2, 1))).properties
    @test subtitle.italic == true
    @test subtitle.fonts.ascii == "Palatino"
    @test subtitle.fonts.high_ansi == "Palatino"

    row_number_label = only(docx_runs(docx_cell(table, 3, 1))).properties
    @test convert(W.Point, row_number_label.size).value == 9
    @test only(docx_runs(docx_cell(table, 3, 2))).properties.bold == true

    # Each column label of the first line has its own style.
    @test only(docx_runs(docx_cell(table, 3, 3))).properties.bold == true
    @test docx_hex(only(docx_runs(docx_cell(table, 3, 4))).properties.color) == "FF0000"
    third_column_label = only(docx_runs(docx_cell(table, 3, 5))).properties
    @test convert(W.Point, third_column_label.size).value == 24

    @test docx_hex(only(docx_runs(docx_cell(table, 4, 1))).properties.color) == "0000FF"
    @test only(docx_runs(docx_cell(table, 4, 2))).properties.italic == true

    # The background shades the entire cell.
    shading = docx_shading(docx_cell(table, 4, 3))
    @test shading.pattern == W.ShadingPattern.clear
    @test docx_hex(shading.fill) == "EEEEEE"

    @test only(docx_runs(docx_cell(table, 6, 2))).properties.bold == true
    @test only(docx_runs(docx_cell(table, 6, 3))).properties.italic == true

    @test docx_hex(docx_runs(docx_cell(table, 7, 1))[2].properties.color) == "FF00FF"
    @test docx_hex(only(docx_runs(docx_cell(table, 8, 1))).properties.color) == "00FFFF"
end

@testset "Default Style" verbose = true begin
    table = pretty_table(W.Table, [1 2; 3 4]; title = "Title")

    title = only(docx_runs(docx_cell(table, 1, 1))).properties
    @test convert(W.Point, title.size).value == 18
    @test only(docx_runs(docx_cell(table, 2, 1))).properties.bold == true
    @test only(docx_runs(docx_cell(table, 3, 1))).properties.bold === nothing
end

@testset "Underlined and Struck Text" verbose = true begin
    table = pretty_table(
        W.Table,
        [1 2; 3 4];
        title = "Title",
        style = DocxTableStyle(;
            title = ["underline" => "double", "strike" => "true"],
            data_cell = ["underline" => "single", "strike" => "false"],
        ),
    )

    title = only(docx_runs(docx_cell(table, 1, 1))).properties
    @test title.underline.pattern == W.UnderlinePattern.double
    @test title.strike == true

    data_cell = only(docx_runs(docx_cell(table, 3, 1))).properties
    @test data_cell.underline.pattern == W.UnderlinePattern.single
    @test data_cell.strike == false
end

@testset "Style From Faces and Crayons" verbose = true begin
    table = pretty_table(
        W.Table,
        [1 2; 3 4];
        title = "Title",
        style = DocxTableStyle(;
            title = Face(;
                weight = :bold,
                height = 140,
                foreground = :red,
                underline = true,
                strikethrough = true,
            ),
            first_line_column_label = crayon"blue",
        ),
    )

    title = only(docx_runs(docx_cell(table, 1, 1))).properties
    @test title.bold == true
    @test convert(W.Point, title.size).value == 14
    @test docx_hex(title.color) == "A51C2C"

    # The color and the style of the underline of a face are ignored.
    @test title.underline.pattern == W.UnderlinePattern.single
    @test title.underline.color.value === W.automatic
    @test title.strike == true

    @test docx_hex(only(docx_runs(docx_cell(table, 2, 1))).properties.color) == "195EB3"
end

@testset "Backend-Agnostic Table Style" verbose = true begin
    table = pretty_table(
        W.Table,
        [1 2; 3 4];
        backend = :docx,
        title = "Title",
        style = TableStyle(; title = Face(; slant = :italic)),
    )

    @test only(docx_runs(docx_cell(table, 1, 1))).properties.italic == true
end

@testset "Color Names and Invalid Attributes" verbose = true begin
    table = pretty_table(
        W.Table,
        [1 2; 3 4];
        title = "Title",
        style = DocxTableStyle(; title = ["color" => "#00FF00"]),
    )

    @test docx_hex(only(docx_runs(docx_cell(table, 1, 1))).properties.color) == "00FF00"

    @test_throws "is not a valid Word style attribute" pretty_table(
        W.Table, [1 2; 3 4]; style = DocxTableStyle(; data_cell = ["shadow" => "true"])
    )

    @test_throws "is not a valid Word underline pattern" pretty_table(
        W.Table,
        [1 2; 3 4];
        style = DocxTableStyle(; data_cell = ["underline" => "squiggly"]),
    )

    @test_throws "is neither a 6-digit hexadecimal string nor a known color name" begin
        pretty_table(
            W.Table,
            [1 2; 3 4];
            style = DocxTableStyle(; data_cell = ["color" => "burgundy"]),
        )
    end

    @test_throws "must be either \"true\" or \"false\"" pretty_table(
        W.Table, [1 2; 3 4]; style = DocxTableStyle(; data_cell = ["bold" => "yes"])
    )

    @test_throws "is not a valid Word border style" pretty_table(
        W.Table,
        [1 2; 3 4];
        table_format = DocxTableFormat(;
            borders = DocxTableBorders(; top_line = ["style" => "wiggly"])
        ),
    )

    # Names defined in the enum module that are not enum values, like the enum type `T`,
    # must also be rejected.
    @test_throws ArgumentError pretty_table(
        W.Table, [1 2; 3 4]; style = DocxTableStyle(; data_cell = ["underline" => "T"])
    )

    @test_throws ArgumentError pretty_table(
        W.Table,
        [1 2; 3 4];
        table_format = DocxTableFormat(;
            borders = DocxTableBorders(; top_line = ["style" => "T"])
        ),
    )
end
