## Description #############################################################################
#
# Excel Back End: Test row height and column width determination.
#
############################################################################################

@testset "Heights and widths" verbose = true begin

    data = [
        1 2 3
    ]
    result = pretty_table(
        XLSX.XLSXFile,
        data;
        title = "Test Table",
        subtitle = "Subtitle_test",
        highlighters = [ExcelHighlighter((data, i, j) -> (i == 1),
            ["color" => "red", "bold" => "true", "size" => "32"])
        ],
        style = ExcelTableStyle(
            title = ["size" => "48", "bold" => "true"],
            subtitle = ["size" => "8", "italic" => "true"],
        )
    )
    # Style changes text size.
    @test XLSX.getRowHeight(result[1], 1, 1) ≈ 60.810937499999994
    @test XLSX.getRowHeight(result[1], 2, 1) ≈ 12.8109375

    # Highlighter changes text size.
    @test XLSX.getRowHeight(result[1], 5, 1) ≈ 41.6109375

    data = [
        "Quite long, long text" "S" "Hytsgt"
        1 1.12345623456789 1.0
    ]
    result = pretty_table(
        XLSX.XLSXFile,
        data;
        style = ExcelTableStyle(
            table_cell = ["size" => "48", "bold" => "true"],
        )
    )
    # Cells containing text affect calculated cell width; numbers don't.
    @test XLSX.getColumnWidth(result[1], 2, 1) ≈ 81.91093750000002
    @test XLSX.getColumnWidth(result[1], 2, 2) ≈ 8.368080357142858

    # Numbers do affect cell height calculation.
    @test XLSX.getRowHeight(result[1], 3, 1) ≈ 60.810937499999994


    now = Dates.now()
    matrix = [
        now now now now 
        now now now now 
        now now now now 
        now now now now 
    ]

    # numerical values don't affect column width.
    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        excel_formatters = [
            ExcelFormatter((v, i, j) -> (j==1), ["format" => "ShortDate"])
            ExcelFormatter((v, i, j) -> (j==2), ["format" => "d mmmm yyyy"])
            ExcelFormatter((v, i, j) -> (j==3), ["format" => "hh:mm"])
            ExcelFormatter((v, i, j) -> (j==4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"])
        ],
    )
    for j in 1:4
        @test XLSX.getColumnWidth(result[1], 1, j) ≈ 8.368080357142858
        @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
    end

    # Single fixed column width. Allow for padding.
    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        excel_formatters = [
            ExcelFormatter((v, i, j) -> (j==1), ["format" => "ShortDate"])
            ExcelFormatter((v, i, j) -> (j==2), ["format" => "d mmmm yyyy"])
            ExcelFormatter((v, i, j) -> (j==3), ["format" => "hh:mm"])
            ExcelFormatter((v, i, j) -> (j==4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"])
        ],
        table_format = ExcelTableFormat(data_column_width = 10.5)
    )
    for j in 1:4
        @test XLSX.getColumnWidth(result[1], 1, j) ≈ 11.2109375
        @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
    end

    # Vector of fixed column widths. Allow for padding.
    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        excel_formatters = [
            ExcelFormatter((v, i, j) -> (j==1), ["format" => "ShortDate"])
            ExcelFormatter((v, i, j) -> (j==2), ["format" => "d mmmm yyyy"])
            ExcelFormatter((v, i, j) -> (j==3), ["format" => "hh:mm"])
            ExcelFormatter((v, i, j) -> (j==4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"])
        ],
        table_format = ExcelTableFormat(data_column_width = [12.0, 16.0, 8.0, 20.0])
    )
    w=[12.7109375, 16.7109375, 8.7109375, 20.7109375]
    for j in 1:4
        @test XLSX.getColumnWidth(result[1], 1, j) ≈ w[j]
        @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
    end

    # Vector of max column widths.
    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        excel_formatters = [
            ExcelFormatter((v, i, j) -> (j==1), ["format" => "ShortDate"])
            ExcelFormatter((v, i, j) -> (j==2), ["format" => "d mmmm yyyy"])
            ExcelFormatter((v, i, j) -> (j==3), ["format" => "hh:mm"])
            ExcelFormatter((v, i, j) -> (j==4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"])
        ],
        table_format = ExcelTableFormat(max_data_column_width = [6.0, 100.0, 40.0, 5.0])
    )
    w=[6.7109375, 8.368080357142858, 8.368080357142858, 5.7109375]
    for j in 1:4
        @test XLSX.getColumnWidth(result[1], 1, j) ≈ w[j]
        @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
    end

    # Vector of min column widths.
    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        excel_formatters = [
            ExcelFormatter((v, i, j) -> (j==1), ["format" => "ShortDate"])
            ExcelFormatter((v, i, j) -> (j==2), ["format" => "d mmmm yyyy"])
            ExcelFormatter((v, i, j) -> (j==3), ["format" => "hh:mm"])
            ExcelFormatter((v, i, j) -> (j==4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"])
        ],
        table_format = ExcelTableFormat(min_data_column_width = [1.0, 12.0, 16.0, 1.0])
    )
    w=[8.368080357142858, 12.7109375, 16.7109375, 8.368080357142858]
    for j in 1:4
        @test XLSX.getColumnWidth(result[1], 1, j) ≈ w[j]
        @test XLSX.getRowHeight(result[1], j, 1) ≈ 17.6109375
    end
end