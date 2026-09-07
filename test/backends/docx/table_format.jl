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
                @docx__no_horizontal_lines,
                @docx__no_vertical_lines
            )
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
                @docx__all_horizontal_lines,
                @docx__all_vertical_lines
            )
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
                )
            )
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
            table_format = DocxTableFormat(; cell_margins = (0.0, 1.0, 0.0, 1.0))
        )

        @test convert(W.Point, table.properties.margins.stop).value == 1
    end

    @testset "Header Rows" verbose = true begin
        table = pretty_table(
            W.Table,
            matrix;
            table_format = DocxTableFormat(; repeat_header_rows_at_page_breaks = false)
        )

        @test all(r -> isnothing(r.properties.header), table.rows)
    end
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
        )
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
        matrix;
        backend = :docx,
        table_format = TypstTableFormat()
    )

    @test_throws "does not support a style of type" pretty_table(
        matrix;
        backend = :docx,
        style = TypstTableStyle()
    )
end
