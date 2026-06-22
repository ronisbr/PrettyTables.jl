## Description #############################################################################
#
# Excel Back End: Test excel_formatters
#
############################################################################################

@testset "Excel Formatters" verbose = true begin

    # == Numeric and Date Formatters =======================================================

    @testset "Numeric Formatters" verbose = true begin
        matrix = [
            π π π π
            π π π π
        ]

        # The Excel rows are laid out as follows:
        #
        #   Row 1: column labels
        #   Row 2: data row 1     (data row index 1)
        #   Row 3: data row 2     (data row index 2)
        #   Row 4: summary row 1  (summary row index 1)
        #   Row 5: summary row 2  (summary row index 2)
        #
        # A `:data` formatter (the default) matches the data row index (`i ∈ {1, 2}`),
        # whereas a `:summary_row` formatter matches the summary row index (`i ∈ {1, 2}`),
        # NOT the Excel row index. Using two summary rows ensures we are indexing by the
        # summary row, not by the absolute Excel row (which would be 4 and 5).
        result = pretty_table(
            XLSX.XLSXFile,
            matrix;
            excel_formatters = [
                # `:data` region matching a specific data row index.
                ExcelFormatter((v, i, j) -> (i == 2), ["format" => "0.00"])
                # `:summary_row` region matching the summary row index.
                ExcelFormatter(
                    (v, i, j) -> (i == 1),
                    ["format" => "0.00000"];
                    region = :summary_row
                )
                ExcelFormatter(
                    (v, i, j) -> (i == 2),
                    ["format" => "0.000"];
                    region = :summary_row
                )
                # `:data` region matching by column.
                ExcelFormatter((v, i, j) -> (j == 1), ["format" => "#,##0_0_0"])
                ExcelFormatter((v, i, j) -> (j == 2), ["format" => "#,##0.??_0_0"])
                ExcelFormatter((v, i, j) -> (j == 3), ["format" => "#,##0.???"])
                ExcelFormatter((v, i, j) -> (j == 4), ["format" => "0_0_0_0"])
            ],
            summary_row_labels = ["Maximum", "Minimum"],
            summary_rows = [
                (data, i) -> maximum(@views data[1:2, i]),
                (data, i) -> minimum(@views data[1:2, i]),
            ],
        )

        # Data row 1 (Excel row 2): matched by the column formatters.
        @test XLSX.getFormat(result[1], "B2").format["numFmt"]["formatCode"] == "#,##0_0_0"
        @test XLSX.getFormat(result[1], "C2").format["numFmt"]["formatCode"] ==
            "#,##0.??_0_0"
        @test XLSX.getFormat(result[1], "D2").format["numFmt"]["formatCode"] == "#,##0.???"
        @test XLSX.getFormat(result[1], "E2").format["numFmt"]["formatCode"] == "0_0_0_0"

        # Data row 2 (Excel row 3): matched by the `:data` formatter `i == 2`, which takes
        # precedence over the column formatters because it appears first.
        @test XLSX.getFormat(result[1], "B3").format["numFmt"]["formatCode"] == "0.00"
        @test XLSX.getFormat(result[1], "E3").format["numFmt"]["formatCode"] == "0.00"

        # Summary row 1 (Excel row 4): matched by the `:summary_row` formatter `i == 1`. The
        # `:data` column formatters must NOT leak into the summary rows.
        @test XLSX.getFormat(result[1], "B4").format["numFmt"]["formatCode"] == "0.00000"
        @test XLSX.getFormat(result[1], "D4").format["numFmt"]["formatCode"] == "0.00000"

        # Summary row 2 (Excel row 5): matched by the `:summary_row` formatter `i == 2`,
        # confirming the index is the summary row index and not the Excel row index.
        @test XLSX.getFormat(result[1], "B5").format["numFmt"]["formatCode"] == "0.000"
        @test XLSX.getFormat(result[1], "D5").format["numFmt"]["formatCode"] == "0.000"
    end

    # == Region Field and Constructors =====================================================

    @testset "Region Field and Constructors" verbose = true begin
        # The default region must be `:data`.
        f = ExcelFormatter((v, i, j) -> true, ["format" => "0.00"])
        @test f.region === :data

        # The region can be set explicitly.
        f = ExcelFormatter((v, i, j) -> true, ["format" => "0.00"]; region = :summary_row)
        @test f.region === :summary_row

        # An invalid region must throw.
        @test_throws ArgumentError ExcelFormatter(
            (v, i, j) -> true, ["format" => "0.00"]; region = :invalid
        )
    end

    # == Date Formatters ===================================================================

    @testset "Date Formatters" verbose = true begin
        now = Dates.now()
        matrix = [
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
            data_column_widths = [12.0, 16.0, 8.0, 20.0],
        )

        @test XLSX.getFormat(result[1], "A2").format["numFmt"]["formatCode"] == "m/d/yyyy"
        @test XLSX.getFormat(result[1], "B2").format["numFmt"]["formatCode"] ==
            "d mmmm yyyy"
        @test XLSX.getFormat(result[1], "C2").format["numFmt"]["formatCode"] == "hh:mm"
        @test XLSX.getFormat(result[1], "D2").format["numFmt"]["formatCode"] ==
            "yyyy-mm-dd\"T\"hh:mm:ss"
    end
end

@testset "fmt__excel_stringify" verbose = true begin

    # == Different Selectors ===============================================================

    @testset "Different Selectors" verbose = true begin
        matrix = ["hello" 3.1415926 (1, 4)]

        f = pretty_table(matrix; backend = :excel, formatters = [fmt__excel_stringify()])
        @test f["prettytable"]["A2"] == "hello"
        @test f["prettytable"]["B2"] == 3.1415926
        @test f["prettytable"]["C2"] == "(1, 4)"

        f = pretty_table(matrix; backend = :excel, formatters = [fmt__excel_stringify(3)])
        @test f["prettytable"]["A2"] == "hello"
        @test f["prettytable"]["B2"] == 3.1415926
        @test f["prettytable"]["C2"] == "(1, 4)"

        f = pretty_table(matrix; backend = :excel, formatters = [fmt__excel_stringify(1:3)])
        @test f["prettytable"]["A2"] == "hello"
        @test f["prettytable"]["B2"] == 3.1415926
        @test f["prettytable"]["C2"] == "(1, 4)"

        f = pretty_table(
            matrix; backend = :excel, formatters = [fmt__excel_stringify(1:2:3)]
        )
        @test f["prettytable"]["A2"] == "hello"
        @test f["prettytable"]["B2"] == 3.1415926
        @test f["prettytable"]["C2"] == "(1, 4)"

        f = pretty_table(
            matrix; backend = :excel, formatters = [fmt__excel_stringify([1, 2, 3])]
        )
        @test f["prettytable"]["A2"] == "hello"
        @test f["prettytable"]["B2"] == 3.1415926
        @test f["prettytable"]["C2"] == "(1, 4)"
    end
end
