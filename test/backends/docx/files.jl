## Description #############################################################################
#
# Word Back End: Test writing the table to a document.
#
############################################################################################

@testset "Writing Files" verbose = true begin
    matrix = [1 2; 3 4]

    mktempdir() do dir
        filename = joinpath(dir, "table.docx")

        @test pretty_table(matrix; backend = :docx, filename) == filename
        @test isfile(filename)

        @test_throws "Path does not end in .docx" pretty_table(
            matrix; backend = :docx, filename = joinpath(dir, "table.txt")
        )

        # An existing file is only replaced if `overwrite = true`.
        write(filename, "Not a Word document")

        @test_throws "already exists and `overwrite = false`" pretty_table(
            matrix; backend = :docx, filename
        )

        @test read(filename, String) == "Not a Word document"

        @test pretty_table(matrix; backend = :docx, filename, overwrite = true) == filename
        @test read(filename, String) != "Not a Word document"
    end

    @test pretty_table(matrix; backend = :docx) isa W.Table
    @test pretty_table_docx_backend(matrix) isa W.Table

    # The convenience constructors must always return the object, even if the user asks for
    # a file.
    @test pretty_table(W.Table, matrix; filename = "table.docx") isa W.Table
    @test pretty_table(W.Table, matrix; backend = :text) isa W.Table

    document = pretty_table(W.Document, matrix)
    @test document isa W.Document
    @test only(only(document.body.sections).children) isa W.Table
end

@testset "Default Font" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Documents" begin
        fonts = pretty_table(W.Document, matrix).styles.doc_defaults.run.fonts
        @test fonts.ascii == "Calibri"
        @test fonts.high_ansi == "Calibri"

        document = pretty_table(W.Document, matrix; default_font = "Arial")
        fonts    = document.styles.doc_defaults.run.fonts
        @test fonts.ascii == "Arial"
        @test fonts.high_ansi == "Arial"
    end

    @testset "Files" begin
        mktempdir() do dir
            filename = joinpath(dir, "table.docx")

            pretty_table(matrix; backend = :docx, filename)
            @test occursin(
                "<w:rFonts w:ascii=\"Calibri\" w:hAnsi=\"Calibri\"/>",
                docx_file_styles(filename),
            )

            pretty_table(
                matrix; backend = :docx, default_font = "Arial", filename, overwrite = true
            )
            @test occursin(
                "<w:rFonts w:ascii=\"Arial\" w:hAnsi=\"Arial\"/>",
                docx_file_styles(filename),
            )
        end
    end

    @testset "Fonts of the Table Style Take Precedence" begin
        # The default font is written to the document defaults, whereas the font selected by
        # the table style is written to the text runs.
        document = pretty_table(
            W.Document,
            matrix;
            default_font = "Arial",
            style = DocxTableStyle(; data_cell = ["font" => "Courier New"]),
        )

        table = only(only(document.body.sections).children)
        fonts = only(docx_runs(docx_cell(table, 2, 1))).properties.fonts

        @test fonts.ascii == "Courier New"
        @test document.styles.doc_defaults.run.fonts.ascii == "Arial"

        # The column labels do not select a font. Hence, they use the default font.
        @test isnothing(only(docx_runs(docx_cell(table, 1, 1))).properties.fonts)
    end

    @testset "Errors" begin
        # The default font of a returned table is defined by the document that contains it.
        @test_throws ArgumentError pretty_table(W.Table, matrix; default_font = "Arial")
        @test_throws "only applied to the documents created by the Word back end" pretty_table(
            matrix; backend = :docx, default_font = "Arial"
        )

        @test_throws "must not be an empty string" pretty_table(
            W.Document, matrix; default_font = ""
        )

        mktempdir() do dir
            filename = joinpath(dir, "table.docx")

            @test_throws "must not be an empty string" pretty_table(
                matrix; backend = :docx, default_font = "", filename
            )

            @test !isfile(filename)
        end
    end
end
