## Description #############################################################################
#
# Excel Back End: Test style.
#
############################################################################################

@testset "ExcelTableStyle" verbose = true begin
    matrix = [
        1 2 3
        4 5 6
        7 8 9
    ]

    # == Styles with Vectors of Column Properties ==========================================

    @testset "Styles with Vectors of Column Properties" verbose = true begin
        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            title = "This is a title.",
            subtitle = "This is a subtitle.",
            stubhead_label = "This is a stubhead label.",
            show_row_number_column = true,
            row_number_column_label = "Row Number",
            row_labels = ["Row 1", "Row 2", "Row 3"],
            row_group_labels = [3 => "Group 1"],
            summary_row_labels = ["Total"],
            summary_rows = [(data, i) -> sum(data[:, i])],
            footnotes = [
                (:subtitle, 1, 1) => "Subtitle footnote"
                (:column_label, 1, 3) => "Third column footnote."
                (:data, 2, 2) => "Midddle data footnote."
            ],
            source_notes = "This is a source note.",
            style = ExcelTableStyle(;
                title = [
                    "bold" => "true",
                    "color" => "orange",
                    "size" => "18",
                    "under" => "single",
                ],
                subtitle = ["italic" => "true", "name" => "Palatino"],
                row_number_label = ["under" => "double"],
                row_number = ["strike" => "true"],
                stubhead_label = ["bold" => "true", "color" => "red", "size" => "24"],
                row_label = ["color" => "orange"],
                row_group_label = ["bold" => "true", "color" => "magenta"],
                first_line_column_label = [
                    ["bold" => "true"], ["color" => "red"], ["size" => "24"]
                ],
                data_cell = ["bold" => "true"],
                summary_row_label = ["bold" => "true", "color" => "red", "size" => "24"],
                summary_row_cell = ["italic" => "true"],
                footnote = ["bold" => "true", "color" => "magenta"],
                source_note = ["italic" => "true", "color" => "cyan"],
            ),
        )

        r = result[1]

        f = XLSX.getFont(r, "A1").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFFA500")
        @test f["sz"] == Dict("val" => "18")
        @test haskey(f, "u") == true

        f = XLSX.getFont(r, "A2").font
        @test haskey(f, "i") == true
        @test f["name"] == Dict("val" => "Palatino")

        @test XLSX.getFont(r, "A3").font["u"] == Dict("val" => "double")
        @test haskey(XLSX.getFont(r, "A5").font, "strike") == true

        f = XLSX.getFont(r, "B3").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")

        @test XLSX.getFont(r, "B4").font["color"] == Dict("rgb" => "FFFFA500")

        f = XLSX.getFont(r, "A6").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF00FF")

        @test haskey(XLSX.getFont(r, "C3").font, "b") == true
        @test XLSX.getFont(r, "D3").font["color"] == Dict("rgb" => "FFFF0000")
        @test XLSX.getFont(r, "E3").font["sz"] == Dict("val" => "24")

        @test haskey(XLSX.getFont(r, "C4").font, "b") == true
        @test haskey(XLSX.getFont(r, "D4").font, "b") == true
        @test haskey(XLSX.getFont(r, "E4").font, "b") == true

        f = XLSX.getFont(r, "B8").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")

        @test haskey(XLSX.getFont(r, "C8").font, "i") == true
        @test haskey(XLSX.getFont(r, "D8").font, "i") == true
        @test haskey(XLSX.getFont(r, "E8").font, "i") == true

        f = XLSX.getFont(r, "A9").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF00FF")

        f = XLSX.getFont(r, "A12").font
        @test haskey(f, "i") == true
        @test f["color"] == Dict("rgb" => "FF00FFFF")
    end

    # == Styles with Constant Properties ===================================================

    @testset "Styles with Constant Properties for All Columns" verbose = true begin
        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            title = "This is a title.",
            subtitle = "This is a subtitle.",
            stubhead_label = "This is a stubhead label.",
            show_row_number_column = true,
            row_number_column_label = "Row Number",
            row_labels = ["Row 1", "Row 2", "Row 3"],
            row_group_labels = [3 => "Group 1"],
            summary_row_labels = ["Total"],
            summary_rows = [(data, i) -> sum(data[:, i])],
            footnotes = [
                (:subtitle, 1, 1) => "Subtitle footnote"
                (:column_label, 1, 3) => "Third column footnote."
                (:data, 2, 2) => "Middle data footnote."
            ],
            source_notes = "This is a source note.",
            style = ExcelTableStyle(;
                title = [
                    "bold" => "true",
                    "color" => "orange",
                    "size" => "18",
                    "under" => "single",
                ],
                subtitle = ["italic" => "true", "name" => "Palatino"],
                row_number_label = ["under" => "double"],
                row_number = ["strike" => "true"],
                stubhead_label = ["bold" => "true", "color" => "red", "size" => "24"],
                row_label = ["color" => "orange"],
                row_group_label = ["bold" => "true", "color" => "magenta"],
                first_line_column_label = [
                    "bold" => "true", "color" => "red", "size" => "24"
                ],
                data_cell = ["bold" => "true", "color" => "red", "size" => "24"],
                summary_row_label = ["bold" => "true", "color" => "red", "size" => "24"],
                summary_row_cell = ["italic" => "true", "color" => "green", "size" => "14"],
                footnote = ["bold" => "true", "color" => "magenta"],
                source_note = ["italic" => "true", "color" => "cyan"],
            ),
        )

        r = result[1]

        f = XLSX.getFont(r, "A1").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFFA500")
        @test f["sz"] == Dict("val" => "18")
        @test haskey(f, "u") == true

        f = XLSX.getFont(r, "A2").font
        @test haskey(f, "i") == true
        @test f["name"] == Dict("val" => "Palatino")

        @test XLSX.getFont(r, "A3").font["u"] == Dict("val" => "double")
        @test haskey(XLSX.getFont(r, "A5").font, "strike") == true

        f = XLSX.getFont(r, "B3").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")

        @test XLSX.getFont(r, "B4").font["color"] == Dict("rgb" => "FFFFA500")

        f = XLSX.getFont(r, "A6").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF00FF")

        f = XLSX.getFont(r, "C3").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")
        f = XLSX.getFont(r, "D3").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")
        f = XLSX.getFont(r, "E3").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")

        f = XLSX.getFont(r, "C4").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")
        f = XLSX.getFont(r, "D4").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")
        f = XLSX.getFont(r, "E4").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")

        f = XLSX.getFont(r, "B8").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF0000")
        @test f["sz"] == Dict("val" => "24")

        f = XLSX.getFont(r, "C8").font
        @test haskey(f, "i") == true
        @test f["color"] == Dict("rgb" => "FF008000")
        @test f["sz"] == Dict("val" => "14")
        f = XLSX.getFont(r, "D8").font
        @test haskey(f, "i") == true
        @test f["color"] == Dict("rgb" => "FF008000")
        @test f["sz"] == Dict("val" => "14")
        f = XLSX.getFont(r, "E8").font
        @test haskey(f, "i") == true
        @test f["color"] == Dict("rgb" => "FF008000")
        @test f["sz"] == Dict("val" => "14")

        f = XLSX.getFont(r, "A9").font
        @test haskey(f, "b") == true
        @test f["color"] == Dict("rgb" => "FFFF00FF")

        f = XLSX.getFont(r, "A12").font
        @test haskey(f, "i") == true
        @test f["color"] == Dict("rgb" => "FF00FFFF")
    end
end
