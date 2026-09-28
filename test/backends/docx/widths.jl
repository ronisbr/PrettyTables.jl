## Description #############################################################################
#
# Word Back End: Test the column widths.
#
############################################################################################

docx_grid(table::W.Table) = map(w -> convert(W.Point, w).value, table.grid)

docx_cell_width(cell::W.TableCell) = convert(W.Point, cell.properties.width.value).value

@testset "Column Widths" verbose = true begin
    # Notice that, with the default cell margins, each column has 10 pt of horizontal
    # padding, and each character has an estimated width of 0.55 times the font size, which
    # is 10 pt by default.

    @testset "Estimated Widths" verbose = true begin
        table = pretty_table(W.Table, ["Quite long text" "S"; 1 2])

        # The grid is always written, but Word adjusts the columns to the content.
        @test docx_grid(table) ≈ [0.55 * 15 * 10 + 10, 0.55 * 6 * 10 + 10]
        @test table.properties.layout === nothing
        @test table.properties.width === nothing
        @test docx_cell(table, 1, 1).properties.width === nothing

        # The widest line of a cell with line breaks defines its width.
        table = pretty_table(W.Table, ["ab\nabcd";;]; column_labels = ["A"])
        @test docx_grid(table) ≈ [0.55 * 4 * 10 + 10]

        # The horizontal cell margins are part of the width.
        table = pretty_table(
            W.Table,
            ["abcd";;];
            column_labels = ["A"],
            table_format = DocxTableFormat(; cell_margins = (0.0, 1.0, 0.0, 2.0)),
        )
        @test docx_grid(table) ≈ [0.55 * 4 * 10 + 3]

        # A table without columns has no grid.
        @test isempty(pretty_table(W.Table, Matrix{Int}(undef, 0, 0); title = "T").grid)
    end

    @testset "Style and Highlighter Size Effects" verbose = true begin
        table = pretty_table(
            W.Table,
            ["abcdefgh" "abcdefgh"];
            column_labels = ["A", "B"],
            highlighters = [DocxHighlighter((data, i, j) -> j == 1, ["size" => "20"])],
        )

        @test docx_grid(table) ≈ [0.55 * 8 * 20 + 10, 0.55 * 8 * 10 + 10]

        table = pretty_table(
            W.Table,
            ["abcdefgh";;];
            column_labels = ["A"],
            style = DocxTableStyle(; data_cell = ["size" => "12"]),
        )

        @test docx_grid(table) ≈ [0.55 * 8 * 12 + 10]

        # The title and the other cells that span the entire table are not considered.
        table = pretty_table(
            W.Table, ["a";;]; column_labels = ["A"], title = "A very long title"
        )
        @test docx_grid(table) ≈ [0.55 * 10 + 10]
    end

    @testset "Fixed Column Widths" verbose = true begin
        matrix = [1 2 3; 4 5 6]

        table = pretty_table(W.Table, matrix; data_column_widths = 72.0)

        # Word must lay out the columns exactly at the computed widths.
        @test docx_grid(table) ≈ [72, 72, 72]
        @test table.properties.layout == W.TableLayout.fixed
        @test convert(W.Point, table.properties.width.value).value ≈ 216
        @test all(c -> docx_cell_width(c) ≈ 72, docx_cells(table, 2))

        table = pretty_table(W.Table, matrix; data_column_widths = [36.0, 0.0, 108.0])
        @test docx_grid(table) ≈ [36, 0.55 * 6 * 10 + 10, 108]
        @test table.properties.layout == W.TableLayout.fixed
    end

    @testset "Maximum and Minimum Column Widths" verbose = true begin
        matrix = ["Quite long text" "S" "abcd"]

        table = pretty_table(
            W.Table,
            matrix;
            column_labels = ["A", "B", "C"],
            maximum_data_column_widths = [50.0, 100.0, 0.0],
        )

        @test docx_grid(table) ≈ [50, 0.55 * 10 + 10, 0.55 * 4 * 10 + 10]
        @test table.properties.layout == W.TableLayout.fixed

        table = pretty_table(
            W.Table,
            matrix;
            column_labels = ["A", "B", "C"],
            minimum_data_column_widths = [1.0, 40.0, 0.0],
        )

        @test docx_grid(table) ≈ [0.55 * 15 * 10 + 10, 40, 0.55 * 4 * 10 + 10]

        # An explicit width takes precedence over the minimum and the maximum.
        table = pretty_table(
            W.Table,
            matrix;
            column_labels = ["A", "B", "C"],
            data_column_widths = [0.0, 80.0, 0.0],
            minimum_data_column_widths = 60.0,
            maximum_data_column_widths = 70.0,
        )

        @test docx_grid(table) ≈ [70, 80, 60]
    end

    @testset "Columns That Are Not Data Columns" verbose = true begin
        table = pretty_table(
            W.Table,
            [1 2; 3 4];
            show_row_number_column = true,
            row_labels = ["A long row label", "B"],
            stubhead_label = "Stub",
            maximum_number_of_columns = 1,
            data_column_widths = [30.0, 80.0],
            maximum_data_column_widths = 1.0,
        )

        # The row number, row label, and continuation columns are not limited by the data
        # column widths. Notice that the continuation column must not use the width of the
        # first hidden data column.
        @test docx_grid(table) ≈
            [0.55 * 3 * 10 + 10, 0.55 * 16 * 10 + 10, 30, 0.55 * 10 + 10]
    end

    @testset "Merged Cells" verbose = true begin
        table = pretty_table(
            W.Table,
            [1 2 3];
            column_labels = [[MultiColumn(2, "Merged"), "C"], ["A", "B", "C"]],
            data_column_widths = [20.0, 30.0, 40.0],
            title = "Title",
        )

        @test docx_cell_width(docx_cell(table, 1, 1)) ≈ 90
        @test docx_cell_width(docx_cell(table, 2, 1)) ≈ 50
        @test docx_cell_width(docx_cell(table, 2, 2)) ≈ 40
    end

    @testset "Integer Column Widths" verbose = true begin
        # The width keywords accept any real number.
        for kwargs in (
            (; data_column_widths = 72),
            (; data_column_widths = [72, 72]),
            (; minimum_data_column_widths = 72, maximum_data_column_widths = [72, 72.0]),
        )
            table = pretty_table(W.Table, [1 2]; kwargs...)
            @test docx_grid(table) ≈ [72, 72]
            @test table.properties.layout == W.TableLayout.fixed
        end
    end

    @testset "Errors" verbose = true begin
        for kw in
            (:data_column_widths, :minimum_data_column_widths, :maximum_data_column_widths)
            @test_throws "The length of `$kw` (1) must be equal to the number of columns (2)." pretty_table(
                W.Table, [1 2]; (kw => [1.0],)...
            )
        end
    end
end
