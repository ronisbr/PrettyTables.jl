## Description #############################################################################
#
# Excel Back End: Test formats (table borders).
#
############################################################################################

@testset "ExcelTableFormat" verbose = true begin
    matrix = [
        1 2 3
        4 5 6
        7 8 9
    ]

    # == Default Formats ===================================================================

    @testset "Default Formats" verbose = true begin
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
        )

        r = result[1]

        f = XLSX.getBorder(r, "A1").border

        @test f["top"] === nothing
        @test f["left"] === nothing
        @test f["right"] === nothing
        @test f["bottom"] === nothing

        @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
        @test XLSX.getBorder(r, "A3").border["top"] ==
            Dict("style" => "thick", "rgb" => "FF000000")
        @test XLSX.getBorder(r, "A3").border["bottom"] ==
            Dict("style" => "medium", "rgb" => "FF000000")

        f = XLSX.getBorder(r, "A4").border
        @test f["bottom"] === nothing
        @test f["right"] == Dict("rgb" => "FF000000", "style" => "thin")

        f = XLSX.getBorder(r, "B4").border
        @test f["bottom"] === nothing
        @test f["right"] == Dict("rgb" => "FF000000", "style" => "thin")

        f = XLSX.getBorder(r, "D4").border
        @test f["bottom"] === nothing
        @test f["right"] == Dict("rgb" => "FF000000", "style" => "thin")

        # The line before the row group label is its top border, since the label does not
        # end the data section.
        f = XLSX.getBorder(r, "A5").border
        @test f["bottom"] === nothing

        f = XLSX.getBorder(r, "A6").border
        @test f["top"] == Dict("style" => "thin", "rgb" => "FF000000")
        @test f["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")

        @test XLSX.getBorder(r, "A7").border["bottom"] ==
            Dict("style" => "thin", "rgb" => "FF000000")
        @test XLSX.getBorder(r, "A8").border["bottom"] ==
            Dict("style" => "thick", "rgb" => "FF000000")
        @test XLSX.getBorder(r, "A9").border["bottom"] === nothing
        @test XLSX.getBorder(r, "A10").border["bottom"] === nothing
        @test XLSX.getBorder(r, "A11").border["bottom"] === nothing

        # The outer lines must not extend over the footnotes and the source notes.
        border_side(cell, side) = begin
            b = XLSX.getBorder(r, cell)
            isnothing(b) ? nothing : b.border[side]
        end

        for row in 9:12
            @test border_side("A$row", "left") === nothing
            @test border_side("A$row", "bottom") === nothing
            @test border_side("E$row", "right") === nothing
        end

        @test XLSX.getBorder(r, "A8").border["left"] ==
            Dict("style" => "thick", "rgb" => "FF000000")
        @test XLSX.getBorder(r, "E8").border["right"] ==
            Dict("style" => "thick", "rgb" => "FF000000")
    end

    # == No Vertical Lines with Row Group Borders =============================================

    @testset "No Vertical Lines with Row Group Borders" verbose = true begin
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
            table_format = ExcelTableFormat(;
                horizontal_line_before_row_group_label = true,
                horizontal_line_after_row_group_label = true,
                vertical_line_after_row_number_column = false,
                vertical_line_after_row_label_column = false,
                vertical_lines_at_data_columns = :none,
                borders = ExcelTableBorders(;
                    header_line = ["style" => "double", "color" => "red"]
                ),
            ),
        )

        r = result[1]

        f = XLSX.getBorder(r, "A1").border
        f["top"] == Dict("style" => "thick", "rgb" => "FF000000")
        f["left"] == Dict("style" => "thick", "rgb" => "FF000000")
        f["right"] == Dict("style" => "thick", "rgb" => "FF000000")
        f["bottom"] === nothing

        @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
        @test XLSX.getBorder(r, "A3").border["top"] ==
            Dict("style" => "thick", "rgb" => "FF000000")
        @test XLSX.getBorder(r, "A3").border["bottom"] ==
            Dict("rgb" => "FFFF0000", "style" => "double")

        f = XLSX.getBorder(r, "A4").border
        @test f["bottom"] === nothing
        @test f["right"] === nothing

        f = XLSX.getBorder(r, "B4").border
        @test f["bottom"] === nothing
        @test f["right"] === nothing

        f = XLSX.getBorder(r, "D4").border
        @test f["bottom"] === nothing
        @test f["right"] === nothing

        f = XLSX.getBorder(r, "A5").border
        @test f["bottom"] === nothing

        f = XLSX.getBorder(r, "A6").border
        @test f["top"] == Dict("rgb" => "FF000000", "style" => "thin")
        @test f["bottom"] == Dict("rgb" => "FF000000", "style" => "thin")

        @test XLSX.getBorder(r, "D6").border["top"] ==
            Dict("style" => "thin", "rgb" => "FF000000")
        @test XLSX.getBorder(r, "A7").border["bottom"] ==
            Dict("rgb" => "FF000000", "style" => "thin")
        @test XLSX.getBorder(r, "A8").border["bottom"] ==
            Dict("style" => "thick", "rgb" => "FF000000")
        @test XLSX.getBorder(r, "A9").border["bottom"] === nothing
        @test XLSX.getBorder(r, "A10").border["bottom"] === nothing
        @test XLSX.getBorder(r, "A11").border["bottom"] === nothing
    end

    # == Row Group Label Lines =============================================================

    @testset "Row Group Label Lines" verbose = true begin
        # A row group label does not end the data section. Hence, disabling the lines around
        # it must remove every line between the data rows and the label.
        result = pretty_table(
            XLSX.XLSXFile,
            [1 2; 3 4; 5 6];
            row_group_labels = [2 => "Group"],
            table_format = ExcelTableFormat(;
                horizontal_line_before_row_group_label = false,
                horizontal_line_after_row_group_label = false,
            ),
        )

        r = result[1]

        border_side(cell, side) = begin
            b = XLSX.getBorder(r, cell)
            isnothing(b) ? nothing : b.border[side]
        end

        @test border_side("A2", "bottom") === nothing
        @test border_side("A3", "top") === nothing
        @test border_side("A3", "bottom") === nothing

        # The lines after the selected data rows are still drawn.
        result = pretty_table(
            XLSX.XLSXFile,
            [1 2; 3 4; 5 6];
            row_group_labels = [2 => "Group"],
            table_format = ExcelTableFormat(;
                horizontal_lines_at_data_rows = [1],
                horizontal_line_before_row_group_label = false,
            ),
        )

        @test XLSX.getBorder(result[1], "A2").border["bottom"] ==
            Dict("style" => "thin", "rgb" => "FF000000")
    end

    # == Horizontal Lines at Data Rows ========================================================

    @testset "Horizontal Lines at Data Rows" verbose = true begin
        @testset "Vector of Rows" verbose = true begin
            result = pretty_table(
                XLSX.XLSXFile,
                [1 2 3; 4 5 6; 7 8 9; 10 11 12];
                table_format = ExcelTableFormat(; horizontal_lines_at_data_rows = [1, 3]),
            )

            r = result[1]

            @test XLSX.getBorder(r, "A1").border["top"] ==
                Dict("style" => "thick", "rgb" => "FF000000")
            @test XLSX.getBorder(r, "A1").border["bottom"] ==
                Dict("style" => "medium", "rgb" => "FF000000")
            @test XLSX.getBorder(r, "A2").border["bottom"] ==
                Dict("style" => "thin", "rgb" => "FF000000")
            @test XLSX.getBorder(r, "A3").border["bottom"] === nothing
            @test XLSX.getBorder(r, "A4").border["bottom"] ==
                Dict("style" => "thin", "rgb" => "FF000000")
            @test XLSX.getBorder(r, "A5").border["bottom"] ==
                Dict("style" => "thick", "rgb" => "FF000000")
        end

        @testset "None" verbose = true begin
            result = pretty_table(
                XLSX.XLSXFile,
                [1 2 3; 4 5 6; 7 8 9];
                table_format = ExcelTableFormat(; horizontal_lines_at_data_rows = :none),
            )

            r = result[1]

            @test XLSX.getBorder(r, "A2").border["bottom"] === nothing
            @test XLSX.getBorder(r, "A3").border["bottom"] === nothing
            @test XLSX.getBorder(r, "A4").border["bottom"] ==
                Dict("style" => "thick", "rgb" => "FF000000")
        end
    end

    # == Vertical Lines at Data Columns ====================================================

    @testset "Vertical Lines at Data Columns" verbose = true begin
        @testset "Vector of Columns" verbose = true begin
            result = pretty_table(
                XLSX.XLSXFile,
                [1 2 3 4; 5 6 7 8];
                table_format = ExcelTableFormat(; vertical_lines_at_data_columns = [1, 3]),
            )

            r = result[1]

            @test XLSX.getBorder(r, "A1").border["right"] ==
                Dict("style" => "thin", "rgb" => "FF000000")
            @test XLSX.getBorder(r, "B1").border["right"] === nothing
            @test XLSX.getBorder(r, "C1").border["right"] ==
                Dict("style" => "thin", "rgb" => "FF000000")
            @test XLSX.getBorder(r, "D1").border["right"] ==
                Dict("style" => "thick", "rgb" => "FF000000")
        end

        @testset "None" verbose = true begin
            result = pretty_table(
                XLSX.XLSXFile,
                [1 2 3; 4 5 6];
                table_format = ExcelTableFormat(; vertical_lines_at_data_columns = :none),
            )

            r = result[1]

            @test XLSX.getBorder(r, "A1").border["right"] === nothing
            @test XLSX.getBorder(r, "B1").border["right"] === nothing
        end
    end
end
