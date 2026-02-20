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

    # vector of attributes for fill in each column
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
            first_line_column_label = [
                ["pattern" => "solid", "fgColor" => "seagreen"],
                ["pattern" => "solid", "fgColor" => "blue"],
                ["pattern" => "solid", "fgColor" => "red"],
            ],
            column_label = [
                ["pattern" => "solid", "fgColor" => "red"],
                ["pattern" => "solid", "fgColor" => "seagreen"],
                ["pattern" => "solid", "fgColor" => "blue"],
            ],
            merged_column_label = ["pattern" => "solid", "fgColor" => "seagreen"],
            table_cell = [
                ["pattern" => "solid", "fgColor" => "steelblue4"],
                ["pattern" => "solid", "fgColor" => "green"],
                ["pattern" => "solid", "fgColor" => "red"],
            ],
            summary_row_label = ["pattern" => "solid", "fgColor" => "violetred3"],
            summary_row_cell = [
                ["pattern" => "solid", "fgColor" => "violetred3"],
                ["pattern" => "solid", "fgColor" => "green"],
                ["pattern" => "solid", "fgColor" => "red"],
            ],
            footnote = ["pattern" => "solid", "fgColor" => "grey80"],
            source_note = ["pattern" => "solid", "fgColor" => "grey80"],  
        )
    )

    r = result[1]


    # Title and subtitle
    @test XLSX.getFill(r, "B2").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF000000")
    @test XLSX.getFill(r, "B3").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF7F7F7F")

    # Headings
    @test XLSX.getFill(r, "B5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "C5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "D5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "E5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF0000FF")
    @test XLSX.getFill(r, "F5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFF0000")
    @test XLSX.getFill(r, "D6").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFF0000")
    @test XLSX.getFill(r, "E6").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "D7").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "F7").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF0000FF")

    # Row groups
    @test XLSX.getFill(r, "B10").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFFC125")
    @test XLSX.getFill(r, "B13").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFFC125")

    # Data rows
    @test XLSX.getFill(r, "B8").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "B11").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "B15").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "C9").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "C12").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "C14").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "D8").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "E12").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF008000")
    @test XLSX.getFill(r, "F15").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFF0000")

    # Summary rows
    @test XLSX.getFill(r, "C16").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCD3278")
    @test XLSX.getFill(r, "D16").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCD3278")
    @test XLSX.getFill(r, "E17").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF008000")
    @test XLSX.getFill(r, "F16").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFF0000")

    # Footnote and sourcenotes
    @test XLSX.getFill(r, "B18").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCCCCCC")
    @test XLSX.getFill(r, "B19").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCCCCCC")


    # single attributes for fill in all columns
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


    # Title and subtitle
    @test XLSX.getFill(r, "B2").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF000000")
    @test XLSX.getFill(r, "B3").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF7F7F7F")

    # Headings
    @test XLSX.getFill(r, "B5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "C5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "D5").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "E6").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")
    @test XLSX.getFill(r, "F7").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF2E8B57")

    # Row groups
    @test XLSX.getFill(r, "B10").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFFC125")
    @test XLSX.getFill(r, "B13").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFFFC125")

    # Data rows
    @test XLSX.getFill(r, "B8").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "B11").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "B15").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "C9").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "C12").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "C14").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "D8").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "E12").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")
    @test XLSX.getFill(r, "F15").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FF36648B")

    # Summary rows
    @test XLSX.getFill(r, "C16").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCD3278")
    @test XLSX.getFill(r, "D16").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCD3278")
    @test XLSX.getFill(r, "E17").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCD3278")
    @test XLSX.getFill(r, "F16").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCD3278")

    # Footnote and sourcenotes
    @test XLSX.getFill(r, "B18").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCCCCCC")
    @test XLSX.getFill(r, "B19").fill["patternFill"] == Dict("patternType" => "solid", "fgrgb" => "FFCCCCCC")

end

