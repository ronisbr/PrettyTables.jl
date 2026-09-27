## Description #############################################################################
#
# Excel Back End: Test row height and column width determination.
#
############################################################################################

@testset "Heights and Widths" verbose = true begin

    # == Style and Highlighter Size Effects ================================================

    @testset "Style and Highlighter Size Effects" verbose = true begin
        data = [1 2 3]

        result = pretty_table(
            XLSX.XLSXFile,
            data;
            title = "Test Table",
            subtitle = "Subtitle_test",
            highlighters = [
                ExcelHighlighter(
                    (data, i, j) -> (i == 1),
                    ["color" => "red", "bold" => "true", "size" => "32"],
                ),
            ],
            style = ExcelTableStyle(;
                title = ["size" => "48", "bold" => "true"],
                subtitle = ["size" => "8", "italic" => "true"],
            ),
        )

        @test XLSX.getRowHeight(result[1], 1, 1) ≈ 60.810937499999994
        @test XLSX.getRowHeight(result[1], 2, 1) ≈ 12.8109375
        @test XLSX.getRowHeight(result[1], 4, 1) ≈ 41.6109375
    end

    # == Text vs Numbers Affecting Width/Height ============================================

    @testset "Text vs Numbers Affecting Width/Height" verbose = true begin
        data = [
            "Quite long, long text" "S" "Hytsgt"
            1 1.12345623456789 1.0
        ]

        result = pretty_table(
            XLSX.XLSXFile,
            data;
            style = ExcelTableStyle(; data_cell = ["size" => "48", "bold" => "true"]),
        )

        @test XLSX.getColumnWidth(result[1], 2, 1) ≈ 81.91093750000002
        @test XLSX.getColumnWidth(result[1], 2, 2) ≈ 8.368080357142858
        @test XLSX.getRowHeight(result[1], 3, 1) ≈ 60.810937499999994
    end

    # == Formatted Dates Column Widths =====================================================

    @testset "Formatted Dates Column Widths" verbose = true begin
        now = Dates.now()
        matrix = [
            now now now now
            now now now now
            now now now now
            now now now now
        ]

        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            excel_formatters = [
                ExcelFormatter((v, i, j) -> (j == 1), ["format" => "ShortDate"])
                ExcelFormatter((v, i, j) -> (j == 2), ["format" => "d mmmm yyyy"])
                ExcelFormatter((v, i, j) -> (j == 3), ["format" => "hh:mm"])
                ExcelFormatter(
                    (v, i, j) -> (j == 4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"]
                )
            ],
        )

        for j in 1:4
            @test XLSX.getColumnWidth(result[1], 1, j) ≈ 8.368080357142858
            @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
        end
    end

    # == Fixed Column Widths ===============================================================

    @testset "Fixed Column Widths" verbose = true begin
        now = Dates.now()
        matrix = [
            now now now now
            now now now now
            now now now now
            now now now now
        ]

        @testset "Single Fixed Width" verbose = true begin
            result = pretty_table(
                XLSX.XLSXFile,
                matrix;
                excel_formatters = [
                    ExcelFormatter((v, i, j) -> (j == 1), ["format" => "ShortDate"])
                    ExcelFormatter((v, i, j) -> (j == 2), ["format" => "d mmmm yyyy"])
                    ExcelFormatter((v, i, j) -> (j == 3), ["format" => "hh:mm"])
                    ExcelFormatter(
                        (v, i, j) -> (j == 4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"]
                    )
                ],
                data_column_widths = 10.5,
            )

            for j in 1:4
                @test XLSX.getColumnWidth(result[1], 1, j) ≈ 11.2109375
                @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
            end
        end

        @testset "Vector of Fixed Widths" verbose = true begin
            result = pretty_table(
                XLSX.XLSXFile,
                matrix;
                excel_formatters = [
                    ExcelFormatter((v, i, j) -> (j == 1), ["format" => "ShortDate"])
                    ExcelFormatter((v, i, j) -> (j == 2), ["format" => "d mmmm yyyy"])
                    ExcelFormatter((v, i, j) -> (j == 3), ["format" => "hh:mm"])
                    ExcelFormatter(
                        (v, i, j) -> (j == 4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"]
                    )
                ],
                data_column_widths = [12.0, 16.0, 8.0, 20.0],
            )

            w = [12.7109375, 16.7109375, 8.7109375, 20.7109375]
            for j in 1:4
                @test XLSX.getColumnWidth(result[1], 1, j) ≈ w[j]
                @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
            end
        end
    end

    # == Maximum Column Widths =============================================================

    @testset "Maximum Column Widths" verbose = true begin
        now = Dates.now()
        matrix = [
            now now now now
            now now now now
            now now now now
            now now now now
        ]

        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            excel_formatters = [
                ExcelFormatter((v, i, j) -> (j == 1), ["format" => "ShortDate"])
                ExcelFormatter((v, i, j) -> (j == 2), ["format" => "d mmmm yyyy"])
                ExcelFormatter((v, i, j) -> (j == 3), ["format" => "hh:mm"])
                ExcelFormatter(
                    (v, i, j) -> (j == 4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"]
                )
            ],
            maximum_data_column_widths = [6.0, 100.0, 40.0, 5.0],
        )

        w = [6.7109375, 8.368080357142858, 8.368080357142858, 5.7109375]
        for j in 1:4
            @test XLSX.getColumnWidth(result[1], 1, j) ≈ w[j]
            @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
        end
    end

    # == Minimum Column Widths =============================================================

    @testset "Minimum Column Widths" verbose = true begin
        now = Dates.now()
        matrix = [
            now now now now
            now now now now
            now now now now
            now now now now
        ]

        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            excel_formatters = [
                ExcelFormatter((v, i, j) -> (j == 1), ["format" => "ShortDate"])
                ExcelFormatter((v, i, j) -> (j == 2), ["format" => "d mmmm yyyy"])
                ExcelFormatter((v, i, j) -> (j == 3), ["format" => "hh:mm"])
                ExcelFormatter(
                    (v, i, j) -> (j == 4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"]
                )
            ],
            minimum_data_column_widths = [1.0, 12.0, 16.0, 1.0],
        )

        w = [8.368080357142858, 12.7109375, 16.7109375, 8.368080357142858]
        for j in 1:4
            @test XLSX.getColumnWidth(result[1], 1, j) ≈ w[j]
            @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
        end
    end

    # == Continuation Column Width =========================================================

    @testset "Continuation Column Width" verbose = true begin
        # The continuation column must keep its estimated width instead of using the width
        # configured for the first hidden data column.
        matrix = [1 2 3 4]

        estimated = pretty_table(XLSX.XLSXFile, matrix; maximum_number_of_columns = 2)

        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            maximum_number_of_columns = 2,
            data_column_widths = [10.0, 11.0, 30.0, 40.0],
            minimum_data_column_widths = 25.0,
        )

        @test XLSX.getColumnWidth(result[1], 1, 1) ≈ 10.7109375
        @test XLSX.getColumnWidth(result[1], 1, 2) ≈ 11.7109375
        @test XLSX.getColumnWidth(result[1], 1, 3) ≈ XLSX.getColumnWidth(estimated[1], 1, 3)
    end

    # == Integer Column Widths =============================================================

    @testset "Integer Column Widths" verbose = true begin
        # The width keywords accept any real number.
        for kwargs in (
            (; data_column_widths = 10),
            (; data_column_widths = [10, 10]),
            (; minimum_data_column_widths = 10, maximum_data_column_widths = [10, 10.0]),
        )
            result = pretty_table(XLSX.XLSXFile, [1 2]; kwargs...)
            @test XLSX.getColumnWidth(result[1], 1, 1) ≈ 10.7109375
            @test XLSX.getColumnWidth(result[1], 1, 2) ≈ 10.7109375
        end
    end
end
