## Description #############################################################################
#
# Excel Back End: Test formats (table borders).
#
############################################################################################

@testset "ExcelTableFormat" verbose=true begin
    matrix = [
        1 2 3
        4 5 6
        7 8 9
    ]

    # Test default formats
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
    )

    r = result[1]

    f =  XLSX.getBorder(r, "A1").border
    f["top"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["left"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["right"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["bottom"] === nothing
    @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A3") === nothing
    @test XLSX.getBorder(r, "A4").border["top"]    == Dict("style" => "thick", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A4").border["bottom"] == Dict("style" => "thin",  "rgb" => "FF000000")
    f = XLSX.getBorder(r, "A5").border
    @test f["bottom"] == Dict("rgb" => "FF000000", "style" => "dotted")
    @test f["right"] == Dict("rgb" => "FF000000", "style" => "thin")
    f = XLSX.getBorder(r, "B5").border
    @test f["bottom"] ==  Dict("rgb" => "FF000000", "style" => "dotted")
    @test f["right"] ==  Dict("rgb" => "FF000000", "style" => "thin")
    f = XLSX.getBorder(r, "D5").border
    @test f["bottom"] == Dict("rgb" => "FF000000", "style" => "dotted")
    @test f["right"]  == Dict("rgb" => "FF000000", "style" => "dotted")
    @test XLSX.getBorder(r, "A6").border["bottom"] == Dict("rgb" => "FF000000", "style" => "dotted")
    f = XLSX.getBorder(r, "A7").border
    @test f["top"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test f["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A8").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A9").border["bottom"] == Dict("style" => "thick", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A10").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A11").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A12").border["bottom"] === nothing

    # Test combining predefined formats via merge()
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
        table_format = ExcelTableFormat(;
            merge(
                EXCEL_FORMAT_SECTION_LINES,
                EXCEL_FORMAT_NO_VLINES,
                (
                    horizontal_line_before_row_group_label = true,
                    horizontal_line_after_row_group_label  = true,
                ),
            )...,
            borders = ExcelTableBorders(header_line = ["style" => "double", "color" => "red"]),
        ),
    )

    r = result[1]

    f =  XLSX.getBorder(r, "A1").border
    f["top"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["left"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["right"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["bottom"] === nothing
    @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A3") === nothing
    @test XLSX.getBorder(r, "A4").border["top"]    == Dict("style" => "thick",  "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A4").border["bottom"] == Dict("rgb" => "FFFF0000", "style" => "double")
    f = XLSX.getBorder(r, "A5").border
    @test f["bottom"] === nothing
    @test f["right"] === nothing
    f = XLSX.getBorder(r, "B5").border
    @test f["bottom"] === nothing
    @test f["right"] === nothing
    f = XLSX.getBorder(r, "D5").border
    @test f["bottom"] === nothing
    @test f["right"] === nothing
    @test XLSX.getBorder(r, "A6").border["bottom"] === nothing
    f = XLSX.getBorder(r, "A7").border
    @test f["top"] == Dict("rgb" => "FFFF0000", "style" => "double")
    @test f["bottom"] == Dict("rgb" => "FFFF0000", "style" => "double")
    @test XLSX.getBorder(r, "D7").border["top"] == Dict("style" => "double", "rgb" => "FFFF0000")
    @test XLSX.getBorder(r, "A8").border["bottom"] == Dict("rgb" => "FFFF0000", "style" => "double")
    @test XLSX.getBorder(r, "A9").border["bottom"] == Dict("style" => "thick",  "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A10").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A11").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A12").border["bottom"] === nothing

    # Test :none and Vector{Int} for horizontal_lines_at_data_rows
    result = pretty_table(
        XLSX.XLSXFile,
        [1 2 3; 4 5 6; 7 8 9; 10 11 12];
        table_format = ExcelTableFormat(horizontal_lines_at_data_rows = [1, 3]),
    )

    r = result[1]

    # Row 1: column labels — thick top, thin bottom.
    @test XLSX.getBorder(r, "A1").border["top"]    == Dict("style" => "thick",  "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A1").border["bottom"] == Dict("style" => "thin",   "rgb" => "FF000000")
    # Data row 1 (ps.i=1): in [1, 3] → dotted underline.
    @test XLSX.getBorder(r, "A2").border["bottom"] == Dict("style" => "dotted", "rgb" => "FF000000")
    # Data row 2 (ps.i=2): not in [1, 3] → no underline.
    @test XLSX.getBorder(r, "A3").border["bottom"] === nothing
    # Data row 3 (ps.i=3): in [1, 3] → dotted underline.
    @test XLSX.getBorder(r, "A4").border["bottom"] == Dict("style" => "dotted", "rgb" => "FF000000")
    # Data row 4 (ps.i=4): last row → thick bottom_line from outer border (overrides thin
    # horizontal_line_after_data_rows).
    @test XLSX.getBorder(r, "A5").border["bottom"] == Dict("style" => "thick",  "rgb" => "FF000000")

    # :none → no dotted underlines on any data row.
    result = pretty_table(
        XLSX.XLSXFile,
        [1 2 3; 4 5 6; 7 8 9];
        table_format = ExcelTableFormat(horizontal_lines_at_data_rows = :none),
    )

    r = result[1]

    @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A3").border["bottom"] === nothing
    # Last row: only thick outer bottom, no dotted.
    @test XLSX.getBorder(r, "A4").border["bottom"] == Dict("style" => "thick", "rgb" => "FF000000")

end

