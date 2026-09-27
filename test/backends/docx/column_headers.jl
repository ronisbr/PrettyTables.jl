## Description #############################################################################
#
# Word Back End: Test column headers.
#
############################################################################################

@testset "Column Headers" verbose = true begin
    data = [1 2 3 4]
    names = ["Time (s)", "Acceleration", "Velocity", "Position"]
    units = ["[s]", "[m / s²]", "[m / s]", "[m]"]

    # == Merged Columns in Top Row =========================================================

    @testset "Merged Columns in Top Row" verbose = true begin
        column_labels = [[EmptyCells(2), MultiColumn(2, "Estimated Data")], units, names]

        table = pretty_table(W.Table, data; column_labels)

        @test docx_row_text(table, 1) == ["", "", "Estimated Data"]
        @test docx_gridspans(table, 1) == [1, 1, 2]

        # Only the merged cell has the merged header cell line.
        @test docx_border_size(docx_cell(table, 1, 3), :bottom) == 4
        @test docx_border(docx_cell(table, 1, 2), :bottom) === nothing

        # The first line of the merged cells is bold by default.
        @test only(docx_runs(docx_cell(table, 1, 3))).properties.bold == true
    end

    # == Merged Columns in Middle Row ======================================================

    @testset "Merged Columns in Middle Row" verbose = true begin
        column_labels = [units, [EmptyCells(2), MultiColumn(2, "Estimated Data")], names]

        table = pretty_table(W.Table, data; column_labels)

        @test docx_gridspans(table, 2) == [1, 1, 2]
        @test docx_border_size(docx_cell(table, 2, 3), :bottom) == 4

        # The merged cells in the other lines have no decoration by default.
        @test only(docx_runs(docx_cell(table, 2, 3))).properties.bold === nothing
    end

    # == Merged Columns in Bottom Row ======================================================

    @testset "Merged Columns in Bottom Row" verbose = true begin
        column_labels = [units, names, [EmptyCells(2), MultiColumn(2, "Estimated Data")]]

        table = pretty_table(W.Table, data; column_labels)

        # The line after the column labels overrides the merged header cell line.
        @test docx_gridspans(table, 3) == [1, 1, 2]
        @test docx_border_size(docx_cell(table, 3, 3), :bottom) == 8
    end

    # == Merged Columns in Middle Two Columns ==============================================

    @testset "Merged Columns in Middle Two Columns" verbose = true begin
        column_labels = [
            units,
            [EmptyCells(1), MultiColumn(2, "Estimated Data"), EmptyCells(1)],
            names,
        ]

        table = pretty_table(W.Table, data; column_labels)

        @test docx_gridspans(table, 2) == [1, 2, 1]
        @test docx_border_size(docx_cell(table, 2, 2), :bottom) == 4

        # The vertical line after the merged cell is drawn after its last column.
        @test docx_border_size(docx_cell(table, 2, 1), :stop) == 4
        @test docx_border_size(docx_cell(table, 2, 2), :stop) == 4
        @test docx_border_size(docx_cell(table, 2, 3), :stop) == 16

        table = pretty_table(
            W.Table,
            data;
            column_labels,
            table_format = DocxTableFormat(; vertical_lines_at_data_columns = [2]),
        )

        @test docx_border(docx_cell(table, 2, 1), :stop) === nothing
        @test docx_border(docx_cell(table, 2, 2), :stop) === nothing

        table = pretty_table(
            W.Table,
            data;
            column_labels,
            table_format = DocxTableFormat(; vertical_lines_at_data_columns = [3]),
        )

        @test docx_border_size(docx_cell(table, 2, 2), :stop) == 4
    end

    # == Merged Cells and Horizontal Cropping ==============================================

    @testset "Merged Cells and Horizontal Cropping" verbose = true begin
        column_labels = [[MultiColumn(3, "Merged"), "D"], names]

        table = pretty_table(W.Table, data; column_labels, maximum_number_of_columns = 2)

        # The span of the merged cell is limited to the printed columns, and the line after
        # the last printed data column is drawn because there is a continuation column.
        @test docx_row_text(table, 1) == ["Merged", "⋯"]
        @test docx_gridspans(table, 1) == [2, 1]
        @test docx_border_size(docx_cell(table, 1, 1), :stop) == 4
        @test docx_border_size(docx_cell(table, 1, 2), :stop) == 16
    end

    # == Line at Merged Column Labels ======================================================

    @testset "Line at Merged Column Labels" verbose = true begin
        column_labels = [[EmptyCells(2), MultiColumn(2, "Estimated Data")], names]

        table = pretty_table(
            W.Table,
            data;
            column_labels,
            table_format = DocxTableFormat(; horizontal_line_at_merged_column_labels = false),
        )

        @test docx_border(docx_cell(table, 1, 3), :bottom) === nothing
    end

    # == Between-Header Borders on Row-Number and Stubhead Columns ========================

    @testset "Between-Header Borders on Row-Number and Stubhead Columns" verbose = true begin
        # When `horizontal_line_between_column_labels` is enabled and the header spans three
        # or more rows, the row-number column and the row-label column (a stubhead when row
        # labels are also requested) must each receive a thin bottom border on every row
        # except the last header row, mirroring the behavior of the column-label cells.
        column_labels = [["A", "B", "C", "D"], ["a", "b", "c", "d"], ["x", "y", "z", "w"]]
        table_format  = DocxTableFormat(; horizontal_line_between_column_labels = true)

        table = pretty_table(
            W.Table, data; column_labels, show_row_number_column = true, table_format
        )

        for row in 1:2, col in 1:5
            @test docx_border_size(docx_cell(table, row, col), :bottom) == 4
        end

        @test docx_border_size(docx_cell(table, 3, 1), :bottom) == 8

        table = pretty_table(
            W.Table, data; column_labels, row_labels = ["r1"], table_format
        )

        for row in 1:2
            @test docx_border_size(docx_cell(table, row, 1), :bottom) == 4
        end

        @test docx_border_size(docx_cell(table, 3, 1), :bottom) == 8

        # By default, there is no line between the column labels.
        table = pretty_table(W.Table, data; column_labels, show_row_number_column = true)
        @test docx_border(docx_cell(table, 2, 1), :bottom) === nothing
        @test docx_border(docx_cell(table, 2, 2), :bottom) === nothing
    end

    # == Formatted Merged Column Labels ====================================================

    @testset "Formatted Merged Column Labels" verbose = true begin
        column_labels = [
            [MultiColumn(2, "First Line"), EmptyCells(2)],
            [EmptyCells(1), MultiColumn(2, "Estimated Data"), EmptyCells(1)],
            names,
        ]

        table = pretty_table(
            W.Table,
            data;
            column_labels,
            table_format = DocxTableFormat(;
                borders = DocxTableBorders(;
                    merged_header_cell_line = [
                        "style" => "double", "size" => "12", "color" => "FF0000"
                    ]
                ),
            ),
            style = DocxTableStyle(;
                first_line_merged_column_label = ["italic" => "true"],
                merged_column_label = ["color" => "FF0000", "size" => "16"],
            ),
        )

        first_line = only(docx_runs(docx_cell(table, 1, 1))).properties
        @test first_line.italic == true
        @test first_line.bold === nothing

        merged = only(docx_runs(docx_cell(table, 2, 2))).properties
        @test docx_hex(merged.color) == "FF0000"
        @test convert(W.Point, merged.size).value == 16

        border = docx_border(docx_cell(table, 2, 2), :bottom)
        @test border.style == W.BorderStyle.double
        @test convert(W.EighthPoint, border.size).value == 12
        @test docx_hex(border.color) == "FF0000"
    end
end
