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

    @testset "General Highlighter" begin
        f = (data, i, j) -> i == 1

        h = Highlighter(f, Face(; weight = :bold, foreground = "#ff0000"))

        result = pretty_table(XLSX.XLSXFile, matrix; highlighters = [h])
        sheet  = result[1]

        # The data starts at the second row because of the column labels.
        @test XLSX.getFont(sheet, "A2").font["color"] == Dict("rgb" => "FFFF0000")
        @test haskey(XLSX.getFont(sheet, "A2").font, "b")
        @test XLSX.getFont(sheet, "B2").font["color"] == Dict("rgb" => "FFFF0000")
        @test XLSX.getFont(sheet, "A3").font["color"] != Dict("rgb" => "FFFF0000")
        @test PrettyTables._excel__native_highlighter(h)._decoration == ["bold" => "true", "color" => "FFFF0000"]

        # A background is a fill.
        h = Highlighter(f, Face(; background = "#00ff00"))
        result = pretty_table(XLSX.XLSXFile, matrix; highlighters = [h])
        @test XLSX.getFill(result[1], "A2").fill["patternFill"] ==
            Dict("patternType" => "solid", "fgrgb" => "FF00FF00")

        # The function `fd` can return a face or the native decoration.
        h = Highlighter(f, (h, data, i, j) -> Face(; foreground = "#ff0000"))
        result = pretty_table(XLSX.XLSXFile, matrix; highlighters = [h])
        @test XLSX.getFont(result[1], "A2").font["color"] == Dict("rgb" => "FFFF0000")

        h = Highlighter(f, (h, data, i, j) -> ["color" => "FFFF0000"])
        result = pretty_table(XLSX.XLSXFile, matrix; highlighters = [h])
        @test XLSX.getFont(result[1], "A2").font["color"] == Dict("rgb" => "FFFF0000")

        # Highlighters of different types can be mixed, and the first match wins.
        hs = AbstractHighlighter[
            ExcelHighlighter((data, i, j) -> false, ["color" => "blue"]),
            Highlighter(f, Face(; foreground = "#ff0000")),
            ExcelHighlighter(f, ["color" => "blue"]),
        ]
        result = pretty_table(XLSX.XLSXFile, matrix; highlighters = hs)
        @test XLSX.getFont(result[1], "A2").font["color"] == Dict("rgb" => "FFFF0000")

        # Highlighters of other back ends are not accepted.
        @test_throws ArgumentError pretty_table(
            XLSX.XLSXFile, matrix; highlighters = [TextHighlighter(f, crayon"red")]
        )
    end

    @static if VERSION >= v"1.11"
        @testset "Styled Strings" begin
            matrix = [styled"{yellow,bold:Yellow, Bold}" styled"{blue:Blue} & <x>"]
            result = pretty_table(XLSX.XLSXFile, matrix; column_labels = [styled"{red:A}", "B"])
            sheet  = result[1]

            # A cell with multiple face regions is written as rich text, keeping the plain
            # text as the cell value.
            rts = XLSX.getRichTextString(sheet, "B2")
            @test rts isa XLSX.RichTextString
            @test length(rts.runs) == 2
            @test rts.runs[1].text == "Blue"
            @test rts.runs[1].atts == Dict{Symbol, Any}(:color => "FF195EB3")
            @test rts.runs[2].text == " & <x>"
            @test isnothing(rts.runs[2].atts)
            @test sheet["B2"] == "Blue & <x>"

            # A uniformly styled cell yields a single run, which XLSX.jl writes as plain
            # text with a cell-level font.
            @test sheet["A2"] == "Yellow, Bold"
            @test isnothing(XLSX.getRichTextString(sheet, "A2"))
            font = XLSX.getFont(sheet, "A2").font
            @test haskey(font, "b")
            @test font["color"] == Dict("rgb" => "FFE5A509")

            # The same applies to a uniformly styled column label.
            @test sheet["A1"] == "A"
            @test isnothing(XLSX.getRichTextString(sheet, "A1"))
            @test XLSX.getFont(sheet, "A1").font["color"] == Dict("rgb" => "FFA51C2C")

            # Underline and strikethrough are converted to boolean run attributes.
            result = pretty_table(
                XLSX.XLSXFile,
                [styled"{underline:under} {strikethrough:struck}" 1],
            )
            rts = XLSX.getRichTextString(result[1], "A2")
            @test length(rts.runs) == 3
            @test rts.runs[1].atts == Dict{Symbol, Any}(:under => true)
            @test rts.runs[3].atts == Dict{Symbol, Any}(:strike => true)

            # Footnote superscripts are appended as an additional unstyled run.
            result = pretty_table(
                XLSX.XLSXFile,
                [styled"{blue:Blue} tail" 2];
                footnotes = [(:data, 1, 1) => "Footnote"],
            )
            sheet = result[1]
            rts   = XLSX.getRichTextString(sheet, "A2")
            @test sheet["A2"] == "Blue tail¹"
            @test length(rts.runs) == 3
            @test rts.runs[3].text == "¹"
            @test isnothing(rts.runs[3].atts)

            # An annotated string without face annotations is written as plain text.
            result = pretty_table(XLSX.XLSXFile, [Base.AnnotatedString("Plain") 1])
            @test result[1]["A2"] == "Plain"
            @test result[1]["A2"] isa String
            @test isnothing(XLSX.getRichTextString(result[1], "A2"))
        end
    end
end
