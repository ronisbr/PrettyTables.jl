## Description #############################################################################
#
# Excel Back End: Test column headers.
#
############################################################################################

@testset "Column Headers" verbose = true begin
    data = [1 2 3 4]
    merge_column_label_cells = :auto

    # == Merged Columns in Top Row =========================================================

    @testset "Merged Columns in Top Row" verbose = true begin
        column_labels = [
            [EmptyCells(2), MultiColumn(2, "Estimated Data")],
            [
                styled"{(foreground=gray):[s]}",
                styled"{(foreground=gray):[m / s²]}",
                styled"{(foreground=gray):[m / s]}",
                styled"{(foreground=gray):[m]}",
            ],
            ["Time (s)", "Acceleration", "Velocity", "Position"],
        ]

        f = pretty_table(data; column_labels, merge_column_label_cells, backend = :excel)

        @test XLSX.getBorder(f[1], "C1").border["bottom"] ==
            Dict("style" => "thin", "rgb" => "FF000000")
        @test XLSX.isMergedCell(f[1], "D1") == true
    end

    # == Merged Columns in Middle Row ======================================================

    @testset "Merged Columns in Middle Row" verbose = true begin
        column_labels = [
            [
                styled"{(foreground=gray):[s]}",
                styled"{(foreground=gray):[m / s²]}",
                styled"{(foreground=gray):[m / s]}",
                styled"{(foreground=gray):[m]}",
            ],
            [EmptyCells(2), MultiColumn(2, "Estimated Data")],
            ["Time (s)", "Acceleration", "Velocity", "Position"],
        ]

        f = pretty_table(data; column_labels, merge_column_label_cells, backend = :excel)

        @test XLSX.getBorder(f[1], "C2").border["bottom"] ==
            Dict("style" => "thin", "rgb" => "FF000000")
        @test XLSX.isMergedCell(f[1], "D2") == true
    end

    # == Merged Columns in Bottom Row ======================================================

    @testset "Merged Columns in Bottom Row" verbose = true begin
        column_labels = [
            [
                styled"{(foreground=gray):[s]}",
                styled"{(foreground=gray):[m / s²]}",
                styled"{(foreground=gray):[m / s]}",
                styled"{(foreground=gray):[m]}",
            ],
            ["Time (s)", "Acceleration", "Velocity", "Position"],
            [EmptyCells(2), MultiColumn(2, "Estimated Data")],
        ]

        f = pretty_table(data; column_labels, merge_column_label_cells, backend = :excel)

        @test XLSX.getBorder(f[1], "C3").border["bottom"] ==
            Dict("style" => "medium", "rgb" => "FF000000")
        @test XLSX.isMergedCell(f[1], "D3") == true
    end

    # == Merged Columns in Middle Two Columns ==============================================

    @testset "Merged Columns in Middle Two Columns" verbose = true begin
        column_labels = [
            [
                styled"{(foreground=gray):[s]}",
                styled"{(foreground=gray):[m / s²]}",
                styled"{(foreground=gray):[m / s]}",
                styled"{(foreground=gray):[m]}",
            ],
            [EmptyCells(1), MultiColumn(2, "Estimated Data"), EmptyCells(1)],
            ["Time (s)", "Acceleration", "Velocity", "Position"],
        ]

        f = pretty_table(data; column_labels, merge_column_label_cells, backend = :excel)

        @test XLSX.getBorder(f[1], "B2").border["bottom"] ==
            Dict("style" => "thin", "rgb" => "FF000000")
        @test XLSX.isMergedCell(f[1], "C2") == true
    end

    # == Default Height and Width ==========================================================

    @testset "Default Height and Width" verbose = true begin
        column_labels = [
            [
                styled"{(foreground=gray):[s]}",
                styled"{(foreground=gray):[m / s²]}",
                styled"{(foreground=gray):[m / s]}",
                styled"{(foreground=gray):[m]}",
            ],
            [EmptyCells(1), MultiColumn(2, "Estimated Data"), EmptyCells(1)],
            ["Time (s)", "Acceleration", "Velocity", "Position"],
        ]

        f = pretty_table(data; column_labels, merge_column_label_cells, backend = :excel)

        @test XLSX.getRowHeight(f[1], "C3") ≈ 17.6109375
        @test XLSX.getColumnWidth(f[1], "C3") ≈ 10.253794642857144
    end

    # == Between-Header Borders on Row-Number and Stubhead Columns ========================

    @testset "Between-header borders on row-number and stubhead columns" verbose = true begin
        # When `horizontal_line_between_column_labels` is enabled and the header spans
        # three or more rows, the row-number column (shown here) and the row-label column
        # (a stubhead when row labels are also requested) must each receive a \"thin\" bottom
        # border on every row except the last header row, mirroring the behaviour of the
        # column-label cells.
        column_labels = [
            ["A", "B", "C", "D"],
            ["a", "b", "c", "d"],
            ["x", "y", "z", "w"],
        ]

        # With `show_row_number_column = true`, column A holds the row-number-label cells.

        f = pretty_table(
            data;
            column_labels,
            backend = :excel,
            show_row_number_column = true,
            table_format = ExcelTableFormat(;
                horizontal_line_between_column_labels = true,
            ),
        )

        # A1 (first header row) and A2 (middle header row) must both carry a thin border
        # underneath; A3 (last header row) gets the medium header-line border instead.
        for cell in ("A1", "A2")
            border = XLSX.getBorder(f[1], cell).border
            @test get(border, "bottom", nothing) ==
                Dict("style" => "thin", "rgb" => "FF000000")
        end
        @test XLSX.getBorder(f[1], "A3").border["bottom"] ==
            Dict("style" => "medium", "rgb" => "FF000000")
        # Sanity check: the column-label cells on A2's row are bordered too, so we are
        # not silently drawing the divider for the row-number column only.
        for cell in ("B2", "C2")
            @test XLSX.getBorder(f[1], cell).border["bottom"] ==
                Dict("style" => "thin", "rgb" => "FF000000")
        end

        # With row labels, column A holds the stubhead-label cells instead. Same expectation.
        g = pretty_table(
            data;
            column_labels,
            backend = :excel,
            row_labels = ["r1", "r2", "r3", "r4"],
            table_format = ExcelTableFormat(;
                horizontal_line_between_column_labels = true,
            ),
        )
        for cell in ("A1", "A2")
            border = XLSX.getBorder(g[1], cell).border
            @test get(border, "bottom", nothing) ==
                Dict("style" => "thin", "rgb" => "FF000000")
        end
        @test XLSX.getBorder(g[1], "A3").border["bottom"] ==
            Dict("style" => "medium", "rgb" => "FF000000")
    end

    # == Formatted Merged Column Labels ====================================================

    @testset "Formatted Merged Column Labels" verbose = true begin
        column_labels = [
            [
                styled"{(foreground=gray):[s]}",
                styled"{(foreground=gray):[m / s²]}",
                styled"{(foreground=gray):[m / s]}",
                styled"{(foreground=gray):[m]}",
            ],
            [EmptyCells(1), MultiColumn(2, "Estimated Data"), EmptyCells(1)],
            ["Time (s)", "Acceleration", "Velocity", "Position"],
        ]

        f = pretty_table(
            data;
            column_labels,
            merge_column_label_cells,
            table_format = ExcelTableFormat(;
                borders = ExcelTableBorders(;
                    merged_header_cell_line = ["style" => "thick", "color" => "red"]
                ),
            ),
            style = ExcelTableStyle(;
                merged_column_label = ["color" => "red", "size" => "32"]
            ),
            backend = :excel,
        )

        @test XLSX.getRowHeight(f[1], "C2") ≈ 41.6109375
        @test XLSX.getColumnWidth(f[1], "C3") ≈ 10.253794642857144
        @test XLSX.getColumnWidth(f[1], "D3") ≈ 10.253794642857144
        @test XLSX.getBorder(f[1], "C2").border["bottom"] ==
            Dict("style" => "thick", "rgb" => "FFFF0000")
    end
end
