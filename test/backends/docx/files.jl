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
            matrix;
            backend = :docx,
            filename = joinpath(dir, "table.txt")
        )

        # An existing file is only replaced if `overwrite = true`.
        write(filename, "Not a Word document")

        @test_throws "already exists and `overwrite = false`" pretty_table(
            matrix;
            backend = :docx,
            filename
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
