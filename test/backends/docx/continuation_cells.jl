## Description #############################################################################
#
# Word Back End: Test continuation cells (⋮, ⋯, ⋱).
#
############################################################################################

@testset "Continuation Cells" verbose = true begin
    data = reshape(1:9, 3, 3)

    # == Vertical Cropping =================================================================

    @testset "Vertical Cropping" verbose = true begin
        table = pretty_table(
            W.Table,
            data;
            maximum_number_of_rows = 1,
            show_row_number_column = true,
            row_labels = ["A", "B", "C"],
        )

        @test length(table.rows) == 3
        @test docx_row_text(table, 3) == ["⋮", "⋮", "⋮", "⋮", "⋮"]

        # The continuation cells use the data cell style, which is not bold by default,
        # instead of the styles of the row number and row label columns.
        for col in 1:5
            cell = docx_cell(table, 3, col)
            @test only(docx_runs(cell)).properties.bold === nothing
            @test docx_paragraph(cell).properties.justification == W.Justification.center
            @test cell.properties.valign == W.VerticalAlign.center
        end

        # The continuation row is the last content row. Hence, it has the bottom line, and
        # the vertical lines of the row number and row label columns are drawn.
        @test docx_border_size(docx_cell(table, 3, 1), :bottom) == 16
        @test docx_border_size(docx_cell(table, 3, 1), :stop) == 4
        @test docx_border_size(docx_cell(table, 3, 2), :stop) == 4
        @test docx_border(docx_cell(table, 2, 1), :bottom) === nothing
    end

    # == Horizontal Cropping ===============================================================

    @testset "Horizontal Cropping" verbose = true begin
        data  = reshape(1:16, 4, 4)
        table = pretty_table(
            W.Table, data; maximum_number_of_columns = 2, maximum_number_of_rows = 2
        )

        @test length(table.rows) == 4
        @test docx_row_text(table, 1) == ["Col. 1", "Col. 2", "⋯"]
        @test docx_row_text(table, 2) == ["1", "5", "⋯"]
        @test docx_row_text(table, 4) == ["⋮", "⋮", "⋱"]

        # The last data column has the middle line and the continuation column has the
        # right line of the table.
        for row in 1:4
            @test docx_border_size(docx_cell(table, row, 2), :stop) == 4
            @test docx_border_size(docx_cell(table, row, 3), :stop) == 16
        end

        table = pretty_table(
            W.Table,
            data;
            maximum_number_of_columns = 2,
            table_format = DocxTableFormat(;
                vertical_line_after_data_columns = false,
                vertical_line_after_continuation_column = false,
            ),
        )

        for row in 1:4
            @test docx_border(docx_cell(table, row, 2), :stop) === nothing
            @test docx_border(docx_cell(table, row, 3), :stop) === nothing
        end

        # Without horizontal cropping, the right line is controlled by
        # `vertical_line_after_data_columns`.
        table = pretty_table(
            W.Table,
            data;
            table_format = DocxTableFormat(; vertical_line_after_continuation_column = false),
        )

        @test docx_border_size(docx_cell(table, 2, 4), :stop) == 16
    end

    # == Style =============================================================================

    @testset "Style" verbose = true begin
        table = pretty_table(
            W.Table,
            reshape(1:16, 4, 4);
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            style = DocxTableStyle(; data_cell = ["color" => "FF0000"]),
        )

        for (row, col) in ((2, 3), (4, 1), (4, 3))
            @test docx_hex(only(docx_runs(docx_cell(table, row, col))).properties.color) ==
                "FF0000"
        end
    end
end
