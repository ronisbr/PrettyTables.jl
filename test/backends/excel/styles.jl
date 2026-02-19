## Description #############################################################################
#
# Excel Back End: Test style.
#
############################################################################################

@testset "ExcelTableStyle" verbose=true begin
    matrix = [
        1 2 3
        4 5 6
        7 8 9
    ]

    # Test styles with vectors of column properties
    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        title = "This is a title.",
        subtitle = "This is a subtitle.",
        stubhead_label  = "This is a stubhead label.",
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
        style = ExcelTableStyle(
            title = [
                "bold" => "true", 
                "color" => "orange", 
                "size" => "18", 
                "under" => "single"
            ],
            subtitle = [
                "italic" => "true", 
                "name" => "Palatino"
            ],
            row_number_label = ["under" => "double"],
            row_number = ["strike" => "true"],
            stubhead_label = [
                "bold" => "true", 
                "color" => "red", 
                "size" => "24"
            ],
            row_label = [
                "color" => "orange"
            ], 
            row_group_label = [
                "bold" => "true", 
                "color" => "magenta"
            ],
            first_line_column_label = [
                ["bold" => "true"], 
                ["color" => "red"], 
                ["size" => "24"]
            ],
            table_cell = [
                ["bold" => "true"], 
                ["color" => "red"], 
                ["size" => "24"]
            ],
            summary_row_label = [
                "bold" => "true", 
                "color" => "red", 
                "size" => "24"
            ],
            summary_row_cell = [
                ["italic" => "true"], 
                ["color" => "green"], 
                ["size" => "14"]
            ],
            footnote = [
                "bold" => "true", 
                "color" => "magenta"
            ],
            source_note = [
                "italic" => "true", 
                "color" => "cyan"
            ],
        )
    )

    r = result[1]

    # Title
    f = XLSX.getFont(r, "A1").font
    @test f["b"] === nothing 
    @test f["color"] == Dict("rgb" => "FFFFA500")
    @test f["sz"] == Dict("val" => "18")
    @test f["u"] === nothing

    # Subtitle
    f = XLSX.getFont(r, "A2").font
    @test f["i"] === nothing
    @test f["name"] == Dict("val" => "Palatino")

    # Row number label
    @test XLSX.getFont(r, "A4").font["u"] == Dict("val" => "double")

    # Row number
    @test XLSX.getFont(r, "A6").font["strike"] == nothing

    # Stubhead label
    f = XLSX.getFont(r, "B4").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")

    # Row label
    @test XLSX.getFont(r, "B5").font["color"] == Dict("rgb" => "FFFFA500")

    # Row group label
    f = XLSX.getFont(r, "A7").font
    @test f["b"] === nothing 
    @test f["color"] == Dict("rgb" => "FFFF00FF")

    # Column headers (vector)
    @test XLSX.getFont(r, "C4").font["b"] === nothing
    @test XLSX.getFont(r, "D4").font["color"] == Dict("rgb" => "FFFF0000")
    @test XLSX.getFont(r, "E4").font["sz"] == Dict("val" => "24")

    # Data row (vector)
    @test XLSX.getFont(r, "C5").font["b"] === nothing
    @test XLSX.getFont(r, "D5").font["color"] == Dict("rgb" => "FFFF0000")
    @test XLSX.getFont(r, "E5").font["sz"] == Dict("val" => "24")

    # summary row label
    f = XLSX.getFont(r, "B9").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")

    # summary row (vector)
    @test XLSX.getFont(r, "C9").font["i"] === nothing
    @test XLSX.getFont(r, "D9").font["color"] == Dict("rgb" => "FF008000")
    @test XLSX.getFont(r, "E9").font["sz"] == Dict("val" => "14")

    # Footnotes
    f = XLSX.getFont(r, "A10").font
    @test f["b"] === nothing 
    @test f["color"] == Dict("rgb" => "FFFF00FF")

    # Summary notes
    f = XLSX.getFont(r, "A13").font
    @test f["i"] === nothing 
    @test f["color"] == Dict("rgb" => "FF00FFFF")

    # Test styles with constant properties for all columns
    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        title = "This is a title.",
        subtitle = "This is a subtitle.",
        stubhead_label  = "This is a stubhead label.",
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
        style = ExcelTableStyle(
            title = [
                "bold" => "true", 
                "color" => "orange", 
                "size" => "18", 
                "under" => "single"
            ],
            subtitle = [
                "italic" => "true", 
                "name" => "Palatino"
            ],
            row_number_label = ["under" => "double"],
            row_number = ["strike" => "true"],
            stubhead_label = [
                "bold" => "true", 
                "color" => "red", 
                "size" => "24"
            ],
            row_label = [
                "color" => "orange"
            ], 
            row_group_label = [
                "bold" => "true", 
                "color" => "magenta"
            ],
            first_line_column_label = [
                "bold" => "true", 
                "color" => "red", 
                "size" => "24"
            ],
            table_cell = [
                "bold" => "true", 
                "color" => "red", 
                "size" => "24"
            ],
            summary_row_label = [
                "bold" => "true", 
                "color" => "red", 
                "size" => "24"
            ],
            summary_row_cell = [
                "italic" => "true", 
                "color" => "green", 
                "size" => "14"
            ],
            footnote = [
                "bold" => "true", 
                "color" => "magenta"
            ],
            source_note = [
                "italic" => "true", 
                "color" => "cyan"
            ],
        )
    )

    r = result[1]

    # Title
    f = XLSX.getFont(r, "A1").font
    @test f["b"] === nothing 
    @test f["color"] == Dict("rgb" => "FFFFA500")
    @test f["sz"] == Dict("val" => "18")
    @test f["u"] === nothing

    # Subtitle
    f = XLSX.getFont(r, "A2").font
    @test f["i"] === nothing
    @test f["name"] == Dict("val" => "Palatino")

    # Row number label
    @test XLSX.getFont(r, "A4").font["u"] == Dict("val" => "double")

    # Row number
    @test XLSX.getFont(r, "A6").font["strike"] == nothing

    # Stubhead label
    f = XLSX.getFont(r, "B4").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")

    # Row label
    @test XLSX.getFont(r, "B5").font["color"] == Dict("rgb" => "FFFFA500")

    # Row group label
    f = XLSX.getFont(r, "A7").font
    @test f["b"] === nothing 
    @test f["color"] == Dict("rgb" => "FFFF00FF")

    # Column headers (single)
    f = XLSX.getFont(r, "C4").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")
    f = XLSX.getFont(r, "D4").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")
    f = XLSX.getFont(r, "E4").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")

    # Data row (single)
    f = XLSX.getFont(r, "C5").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")
    f = XLSX.getFont(r, "D5").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")
    f = XLSX.getFont(r, "E5").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")

    # summary row label
    f = XLSX.getFont(r, "B9").font
    @test f["b"] === nothing
    @test f["color"] == Dict("rgb" => "FFFF0000")
    @test f["sz"] == Dict("val" => "24")

    # summary row (vector)
    f = XLSX.getFont(r, "C9").font
    @test f["i"] === nothing
    @test f["color"] == Dict("rgb" => "FF008000")
    @test f["sz"] == Dict("val" => "14")
    f = XLSX.getFont(r, "D9").font
    @test f["i"] === nothing
    @test f["color"] == Dict("rgb" => "FF008000")
    @test f["sz"] == Dict("val" => "14")
    f = XLSX.getFont(r, "E9").font
    @test f["i"] === nothing
    @test f["color"] == Dict("rgb" => "FF008000")
    @test f["sz"] == Dict("val" => "14")

    # Footnotes
    f = XLSX.getFont(r, "A10").font
    @test f["b"] === nothing 
    @test f["color"] == Dict("rgb" => "FFFF00FF")

    # Summary notes
    f = XLSX.getFont(r, "A13").font
    @test f["i"] === nothing 
    @test f["color"] == Dict("rgb" => "FF00FFFF")

end

