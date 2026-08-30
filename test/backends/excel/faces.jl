## Description #############################################################################
#
# Excel Back End: Tests related with faces.
#
############################################################################################

@testset "Faces" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Table Style" begin
        native_style = ExcelTableStyle(;
            title            = ["bold" => "true", "color" => "FFA51C2C"],
            row_number_label = ["italic" => "true"],
            column_label     = ["cell_fill_pattern" => "solid", "cell_fill_fgColor" => "FF0000FF"],
        )

        face_style = ExcelTableStyle(;
            title            = Face(; weight = :bold, foreground = :red),
            row_number_label = Face(; slant = :italic),
            column_label     = Face(; background = 0x0000ff),
        )

        for field in fieldnames(ExcelTableStyle)
            @test getfield(native_style, field) == getfield(face_style, field)
        end

        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            style = face_style,
            title = "Title",
            column_labels = [["A", "B"], ["C", "D"]],
            show_row_number_column = true,
        )

        sheet = result[1]

        # Title at A1, row number label at A2, second column label row at B3.
        @test XLSX.getFont(sheet, "A1").font["color"] == Dict("rgb" => "FFA51C2C")
        @test haskey(XLSX.getFont(sheet, "A1").font, "b")
        @test haskey(XLSX.getFont(sheet, "A2").font, "i")
        @test XLSX.getFill(sheet, "B3").fill["patternFill"] ==
            Dict("patternType" => "solid", "fgrgb" => "FF0000FF")
    end

    @testset "Column Label Style Vectors" begin
        style = ExcelTableStyle(;
            first_line_column_label = [Face(; foreground = "#ff0000"), ["color" => "blue"]],
            column_label            = [Face(; weight = :bold), Face(; slant = :italic)],
        )

        @test style.first_line_column_label ==
            [["color" => "FFFF0000"], ["color" => "blue"]]
        @test style.column_label == [["bold" => "true"], ["italic" => "true"]]

        result = pretty_table(
            XLSX.XLSXFile, matrix; style = style, column_labels = [["A", "B"], ["C", "D"]]
        )

        sheet = result[1]

        @test XLSX.getFont(sheet, "A1").font["color"] == Dict("rgb" => "FFFF0000")
        @test XLSX.getFont(sheet, "B1").font["color"] == Dict("rgb" => "FF0000FF")
        @test haskey(XLSX.getFont(sheet, "A2").font, "b")
        @test haskey(XLSX.getFont(sheet, "B2").font, "i")
    end
end
