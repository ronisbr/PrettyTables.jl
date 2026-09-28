## Description #############################################################################
#
# Word Back End: Test the table format.
#
############################################################################################

@testset "DocxTableFormat" verbose = true begin
    matrix = [1 2; 3 4]

    @testset "Default Borders" verbose = true begin
        table = pretty_table(W.Table, matrix)

        # The column labels are enclosed by the top line and the header line, and the outer
        # vertical lines are thicker than the ones between the data columns.
        @test docx_border_size(docx_cell(table, 1, 1), :top) == 16
        @test docx_border_size(docx_cell(table, 1, 1), :bottom) == 8
        @test docx_border_size(docx_cell(table, 1, 1), :start) == 16
        @test docx_border_size(docx_cell(table, 1, 1), :stop) == 4
        @test docx_border_size(docx_cell(table, 1, 2), :stop) == 16

        @test docx_border(docx_cell(table, 2, 1), :bottom) === nothing
        @test docx_border_size(docx_cell(table, 3, 1), :bottom) == 16

        @test docx_border(docx_cell(table, 1, 1), :top).style == W.BorderStyle.single
        @test docx_hex(docx_border(docx_cell(table, 1, 1), :top).color) == "000000"
    end

    @testset "No Lines" verbose = true begin
        table = pretty_table(
            W.Table,
            matrix;
            table_format = DocxTableFormat(;
                @docx__no_horizontal_lines, @docx__no_vertical_lines
            ),
        )

        for row in 1:3, cell in docx_cells(table, row)
            @test cell.properties.borders === nothing
        end
    end

    @testset "All Lines" verbose = true begin
        table = pretty_table(
            W.Table,
            matrix;
            table_format = DocxTableFormat(;
                @docx__all_horizontal_lines, @docx__all_vertical_lines
            ),
        )

        @test docx_border_size(docx_cell(table, 2, 1), :bottom) == 4
        @test docx_border_size(docx_cell(table, 2, 1), :stop) == 4
    end

    @testset "Custom Borders" verbose = true begin
        table = pretty_table(
            W.Table,
            matrix;
            table_format = DocxTableFormat(;
                borders = DocxTableBorders(;
                    top_line = ["style" => "double", "size" => "12", "color" => "FF0000"]
                ),
            ),
        )

        border = docx_border(docx_cell(table, 1, 1), :top)
        @test border.style == W.BorderStyle.double
        @test convert(W.EighthPoint, border.size).value == 12
        @test docx_hex(border.color) == "FF0000"
    end

    @testset "Cell Margins" verbose = true begin
        table = pretty_table(W.Table, matrix)
        margins = table.properties.margins

        @test convert(W.Point, margins.top).value == 2
        @test convert(W.Point, margins.start).value == 5

        table = pretty_table(
            W.Table,
            matrix;
            table_format = DocxTableFormat(; cell_margins = (0.0, 1.0, 0.0, 1.0)),
        )

        @test convert(W.Point, table.properties.margins.stop).value == 1
    end

    @testset "Header Rows" verbose = true begin
        table = pretty_table(
            W.Table,
            matrix;
            table_format = DocxTableFormat(; repeat_header_rows_at_page_breaks = false),
        )

        @test all(r -> isnothing(r.properties.header), table.rows)
    end
end

@testset "Borders of the Table Sections" verbose = true begin
    matrix = [1 2 3; 4 5 6; 7 8 9]

    kwargs = (;
        title = "Title",
        subtitle = "Subtitle",
        stubhead_label = "Stub",
        row_labels = ["R1", "R2", "R3"],
        row_group_labels = [3 => "Group"],
        summary_rows = [(data, j) -> sum(data[:, j])],
        summary_row_labels = ["Total"],
        footnotes = [(:data, 1, 1) => "Footnote"],
        source_notes = "Source",
    )

    # Rows: 1 title, 2 subtitle, 3 column labels, 4-5 data, 6 row group label, 7 data,
    # 8 summary row, 9 footnote, and 10 source notes. Each border field has a distinct size
    # so that we can check where it is used.
    table = pretty_table(
        W.Table,
        matrix;
        kwargs...,
        table_format = DocxTableFormat(;
            borders = DocxTableBorders(;
                top_line    = ["size" => "2"],
                header_line = ["size" => "3"],
                middle_line = ["size" => "6"],
                bottom_line = ["size" => "7"],
                left_line   = ["size" => "9"],
                center_line = ["size" => "10"],
                right_line  = ["size" => "11"],
            ),
        ),
    )

    @test length(table.rows) == 10

    # The title, the subtitle, the footnotes, and the source notes have no borders.
    for row in (1, 2, 9, 10)
        @test docx_cell(table, row, 1).properties.borders === nothing
    end

    # Column labels.
    @test all(c -> docx_border_size(c, :top) == 2, docx_cells(table, 3))
    @test all(c -> docx_border_size(c, :bottom) == 3, docx_cells(table, 3))

    # Vertical lines in every content row that is not a row group label.
    for row in (3, 4, 5, 7, 8)
        @test docx_border_size(docx_cell(table, row, 1), :start) == 9
        @test docx_border_size(docx_cell(table, row, 1), :stop) == 10
        @test docx_border_size(docx_cell(table, row, 2), :stop) == 6
        @test docx_border_size(docx_cell(table, row, 3), :stop) == 6
        @test docx_border_size(docx_cell(table, row, 4), :stop) == 11
    end

    # Data rows.
    @test docx_border(docx_cell(table, 4, 1), :bottom) === nothing
    @test docx_border(docx_cell(table, 5, 1), :bottom) === nothing
    @test docx_border_size(docx_cell(table, 7, 1), :bottom) == 6

    # Row group label.
    group = docx_cell(table, 6, 1)
    @test docx_gridspans(table, 6) == [4]
    @test docx_border_size(group, :top) == 6
    @test docx_border_size(group, :bottom) == 6
    @test docx_border_size(group, :start) == 9
    @test docx_border_size(group, :stop) == 11

    # Summary row.
    @test docx_border_size(docx_cell(table, 8, 1), :bottom) == 7

    @testset "Line Flags" verbose = true begin
        # The line at the end of the table is independent of the line at the beginning.
        table = pretty_table(
            W.Table,
            matrix;
            kwargs...,
            table_format = DocxTableFormat(; horizontal_line_at_beginning = false),
        )

        @test docx_border(docx_cell(table, 3, 1), :top) === nothing
        @test docx_border_size(docx_cell(table, 8, 1), :bottom) == 16

        table = pretty_table(
            W.Table,
            matrix;
            kwargs...,
            table_format = DocxTableFormat(;
                horizontal_line_after_column_labels = false,
                horizontal_line_before_summary_rows = false,
                horizontal_line_after_data_rows = false,
                horizontal_line_after_summary_rows = false,
            ),
        )

        @test docx_border(docx_cell(table, 3, 1), :bottom) === nothing
        @test docx_border(docx_cell(table, 7, 1), :bottom) === nothing
        @test docx_border(docx_cell(table, 8, 1), :bottom) === nothing

        # The line before the summary rows does not depend on the line after the data rows.
        table = pretty_table(
            W.Table,
            matrix;
            kwargs...,
            table_format = DocxTableFormat(; horizontal_line_after_data_rows = false),
        )

        @test docx_border_size(docx_cell(table, 7, 1), :bottom) == 4

        # Without summary rows, the line at the end of the table follows the line after the
        # data rows.
        for (flag, expected) in ((true, 16), (false, nothing))
            table = pretty_table(
                W.Table,
                matrix;
                table_format = DocxTableFormat(; horizontal_line_after_data_rows = flag),
            )

            border = docx_border(docx_cell(table, 4, 1), :bottom)
            @test isnothing(border) ? isnothing(expected) : (border.size.value == expected)
        end

        table = pretty_table(
            W.Table,
            matrix;
            kwargs...,
            table_format = DocxTableFormat(;
                vertical_line_at_beginning = false,
                vertical_line_after_row_label_column = false,
                vertical_line_after_data_columns = false,
            ),
        )

        for row in (3, 4, 6, 8)
            @test docx_border(docx_cell(table, row, 1), :start) === nothing
            @test docx_border(last(docx_cells(table, row)), :stop) === nothing
        end

        @test docx_border(docx_cell(table, 4, 1), :stop) === nothing
    end

    @testset "Selected Data Rows and Columns" verbose = true begin
        table = pretty_table(
            W.Table,
            matrix;
            show_row_number_column = true,
            table_format = DocxTableFormat(;
                horizontal_lines_at_data_rows = [1],
                vertical_lines_at_data_columns = [2],
                vertical_line_after_row_number_column = false,
            ),
        )

        @test docx_border_size(docx_cell(table, 2, 1), :bottom) == 4
        @test docx_border(docx_cell(table, 3, 1), :bottom) === nothing

        for row in 1:4
            @test docx_border(docx_cell(table, row, 1), :stop) === nothing
            @test docx_border(docx_cell(table, row, 2), :stop) === nothing
            @test docx_border_size(docx_cell(table, row, 3), :stop) == 4
            @test docx_border_size(docx_cell(table, row, 4), :stop) == 16
        end
    end
end

@testset "Row Group Label Lines" verbose = true begin
    matrix = [1 2; 3 4; 5 6]

    # The lines around the row group label are drawn by the label row.
    table = pretty_table(W.Table, matrix; row_group_labels = [2 => "Group"])

    @test docx_row_text(table, 3) == ["Group"]
    @test docx_border_size(docx_cell(table, 3, 1), :top) == 4
    @test docx_border_size(docx_cell(table, 3, 1), :bottom) == 4

    # A row group label does not end the data section. Hence, disabling the lines around it
    # must remove every line between the data rows and the label.
    table = pretty_table(
        W.Table,
        matrix;
        row_group_labels = [2 => "Group"],
        table_format = DocxTableFormat(;
            horizontal_line_before_row_group_label = false,
            horizontal_line_after_row_group_label = false,
        ),
    )

    @test docx_border(docx_cell(table, 2, 1), :bottom) === nothing
    @test docx_border(docx_cell(table, 3, 1), :top) === nothing
    @test docx_border(docx_cell(table, 3, 1), :bottom) === nothing

    # The lines after the data rows are still drawn before the row group label.
    table = pretty_table(
        W.Table,
        matrix;
        row_group_labels = [2 => "Group"],
        table_format = DocxTableFormat(;
            horizontal_lines_at_data_rows = [1],
            horizontal_line_before_row_group_label = false,
        ),
    )

    @test docx_border_size(docx_cell(table, 2, 1), :bottom) == 4
end

@testset "Backend-Agnostic Table Format" verbose = true begin
    matrix = [1 2; 3 4]

    table = pretty_table(
        W.Table,
        matrix;
        table_format = TableFormat(;
            horizontal_lines_at_data_rows = :all,
            vertical_lines_at_data_columns = :none,
            top_line = LineStyle(; style = :dashed, width = :medium, color = "#00ff00"),
        ),
    )

    @test docx_border_size(docx_cell(table, 2, 1), :bottom) == 4
    @test docx_border(docx_cell(table, 2, 1), :stop) === nothing

    border = docx_border(docx_cell(table, 1, 1), :top)
    @test border.style == W.BorderStyle.dashed
    @test convert(W.EighthPoint, border.size).value == 8
    @test docx_hex(border.color) == "00FF00"

    # A native table format selects the Word back end when `backend = :auto`.
    @test pretty_table(matrix; table_format = DocxTableFormat()) isa W.Table
    @test pretty_table(matrix; style = DocxTableStyle()) isa W.Table

    @test_throws "does not support a table format of type" pretty_table(
        matrix; backend = :docx, table_format = TypstTableFormat()
    )

    @test_throws "does not support a style of type" pretty_table(
        matrix; backend = :docx, style = TypstTableStyle()
    )
end
