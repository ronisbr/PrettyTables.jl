## Description #############################################################################
#
# Excel Back End: Test fills.
#
############################################################################################

@testset "ExcelTableFill" verbose=true begin
    matrix = [
        "Data" "Data" "Data"
        "Data" "Data" "Data"
        "Data" "Data" "Data"
        "Data" "Data" "Data"
        "Data" "Data" "Data"
        "Data" "Data" "Data"
    ]

    result = pretty_table(
        XLSX.XLSXFile,
        matrix,
        anchor_cell = "B2";
        title = "Title",
        subtitle = "Subtitle",
        stubhead_label  = "Stubhead Label",
        column_labels = [
            ["Column Label", "Column Label", "Column Label"],
            ["Column Label", MultiColumn(2, "Merged Column Label")],
            [MultiColumn(2, "Merged Column Label"), "Column Label"],
        ],
        merge_column_label_cells = :auto,
        show_row_number_column = true,
        row_number_column_label = "Row Number",
        row_labels = fill("Row Label", 6),
        row_group_labels = [3 => "Row Group Label", 5 => "Row Group Label"],
        summary_row_labels = ["Row Summary Label", "Row Summary Label"],
        summary_rows = [(data, i) -> "Summary Cell", (data, i) -> "Summary Cell"],
        footnotes = [
            (:title, 1, 1) => "Footnotes"
        ],
        source_notes = "Source Notes",
        alignment = :c,
        row_label_column_alignment = :c,
        row_number_column_alignment = :c,
        table_format = ExcelTableFormat(
            outside_border = false,
            underline_title_type = ["style" => "thick", "color" => "white"],
            underline_headers_type = ["style" => "thick", "color" => "white"],
            underline_between_headers_type = ["style" => "thin", "color" => "white"],
            underline_merged_headers_type = ["style" => "thin", "color" => "white"],
            underline_data_rows_type = ["style" => "thin", "color" => "white"],
            underline_table_type = ["style" => "thick", "color" => "white"],
            overline_group_type = ["style" => "thick", "color" => "white"],
            underline_group_type = ["style" => "thick", "color" => "white"],
            underline_summary_rows_type = ["style" => "thin", "color" => "white"],
            underline_summary_type = ["style" => "thick", "color" => "white"],
            underline_footnotes_type = ["style" => "thin", "color" => "white"],
            vline_after_row_numbers_type = ["style" => "thin", "color" => "white"],
            vline_after_row_labels_type = ["style" => "thick", "color" => "white"],
            vline_between_data_columns_type = ["style" => "thin", "color" => "white"],
        ),
        style = ExcelTableStyle(
            title = ["color" => "white", "bold" => "true"],
            subtitle = ["color" => "white", "italic" => "true"],
            row_number_label = ["color" => "white", "bold" => "true"],
            row_number = ["color" => "white"],
            stubhead_label = ["color" => "white", "bold" => "true"],
            row_label = ["color" => "white", "bold" => "true"],
            row_group_label = ["color" => "white", "bold" => "true"],
            first_line_column_label = ["color" => "white", "bold" => "true"],
            column_label = ["color" => "white"],
            first_line_merged_column_label = ["color" => "white", "bold" => "true"],
            merged_column_label = ["color" => "white"],
            table_cell = ["color" => "white"],
            summary_row_label = ["color" => "white", "bold" => "true"],
            summary_row_cell = ["color" => "white"],
            source_note = ["color" => "black"],
        ),
        fill = ExcelTableFill(
            title = ["pattern" => "solid", "fgColor" => "black"],
            subtitle = ["pattern" => "solid", "fgColor" => "grey50"],
            row_number_label = ["pattern" => "solid", "fgColor" => "seagreen"],
            row_number = ["pattern" => "solid", "fgColor" => "steelblue4"],
            stubhead_label = ["pattern" => "solid", "fgColor" => "seagreen"],
            row_label = ["pattern" => "solid", "fgColor" => "steelblue4"],
            row_group_label = ["pattern" => "solid", "fgColor" => "goldenrod1"],
            first_line_column_label = ["pattern" => "solid", "fgColor" => "seagreen"],
            column_label = ["pattern" => "solid", "fgColor" => "seagreen"],
            first_line_merged_column_label = ["pattern" => "solid", "fgColor" => "seagreen"],
            merged_column_label = ["pattern" => "solid", "fgColor" => "seagreen"],
            table_cell = ["pattern" => "solid", "fgColor" => "steelblue4"],
            summary_row_label = ["pattern" => "solid", "fgColor" => "violetred3"],
            summary_row_cell = ["pattern" => "solid", "fgColor" => "violetred3"],
            footnote = ["pattern" => "solid", "fgColor" => "grey80"],
            source_note = ["pattern" => "solid", "fgColor" => "grey80"],  
        )
    )

    r = result[1]

#=
    f =  XLSX.getBorder(r, "A1").border
    f["top"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["left"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["right"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["bottom"] === nothing
    @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A3").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A4").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
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
    @test XLSX.getBorder(r, "A9").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A10").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A11").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A12").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    f =  XLSX.getBorder(r, "A13").border
    f["top"] === nothing
    f["bottom"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["left"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["right"] == Dict("style" => "thick", "rgb" => "FF000000")

    # Test merging of predefined formats
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
        table_format = ExcelTableFormat(
            EXCEL_FORMAT_SECTION_LINES,
            EXCEL_FORMAT_NO_VLINES;
            overline_group = true,
            underline_group = true,
            overline_group_type = ["style" => "double", "color" => "red"],
        ),
    )

    r = result[1]

    f =  XLSX.getBorder(r, "A1").border
    f["top"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["left"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["right"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["bottom"] === nothing
    @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A3").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A4").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
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
    @test f["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "D7").border["top"] == Dict("style" => "double", "rgb" => "FFFF0000")
    @test XLSX.getBorder(r, "A8").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A9").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.getBorder(r, "A10").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A11").border["bottom"] === nothing
    @test XLSX.getBorder(r, "A12").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    f =  XLSX.getBorder(r, "A13").border
    f["top"] === nothing
    f["bottom"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["left"] == Dict("style" => "thick", "rgb" => "FF000000")
    f["right"] == Dict("style" => "thick", "rgb" => "FF000000")
=#
end

