## Description #############################################################################
#
# Excel Back End: Test excel_formatters
#
############################################################################################

@testset "Excel formatters" verbose=true begin
    matrix = [
        π π π π
        π π π π
    ]

    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        excel_formatters = [
            ExcelFormatter((v, i, j) -> (i==4), ["format" => "0.00000"])
            ExcelFormatter((v, i, j) -> (j==1), ["format" => "#,##0_0_0"])
            ExcelFormatter((v, i, j) -> (j==2), ["format" => "#,##0.??_0_0"])
            ExcelFormatter((v, i, j) -> (j==3), ["format" => "#,##0.???"])
            ExcelFormatter((v, i, j) -> (j==4), ["format" => "0_0_0_0"])
        ],
        summary_row_labels = ["Row Summary Label"],
        summary_rows = [(data, i) -> maximum(@views data[ 1:2, i])],
        )

    @test XLSX.getFormat(result[1], "B2").format["numFmt"]["formatCode"] == "#,##0_0_0"
    @test XLSX.getFormat(result[1], "C2").format["numFmt"]["formatCode"] == "#,##0.??_0_0"
    @test XLSX.getFormat(result[1], "D2").format["numFmt"]["formatCode"] == "#,##0.???"
    @test XLSX.getFormat(result[1], "E2").format["numFmt"]["formatCode"] == "0_0_0_0"
    @test XLSX.getFormat(result[1], "D4").format["numFmt"]["formatCode"] == "0.00000"

    now = Dates.now()
    matrix = [
        now now now now 
        now now now now 
    ]

    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        excel_formatters = [
            ExcelFormatter((v, i, j) -> (j==1), ["format" => "ShortDate"])
            ExcelFormatter((v, i, j) -> (j==2), ["format" => "d mmmm yyyy"])
            ExcelFormatter((v, i, j) -> (j==3), ["format" => "hh:mm"])
            ExcelFormatter((v, i, j) -> (j==4), ["format" => "yyyy-mm-dd\"T\"hh:mm:ss"])
        ],
        data_column_widths = [12.0, 16.0, 8.0, 20.0],
    )

    @test XLSX.getFormat(result[1], "A2").format["numFmt"]["formatCode"] == "m/d/yyyy"
    @test XLSX.getFormat(result[1], "B2").format["numFmt"]["formatCode"] == "d mmmm yyyy"
    @test XLSX.getFormat(result[1], "C2").format["numFmt"]["formatCode"] == "hh:mm"
    @test XLSX.getFormat(result[1], "D2").format["numFmt"]["formatCode"] == "yyyy-mm-dd\"T\"hh:mm:ss"

end

@testset "fmt__excel_stringify" verbose=true begin

    matrix = ["hello" 3.1415926 (1, 4)]
    f=pretty_table(matrix; backend=:excel, formatters = [fmt__excel_stringify()])
    @test f["prettytable"]["A2"] == "hello"
    @test f["prettytable"]["B2"] == 3.1415926
    @test f["prettytable"]["C2"] == "(1, 4)"
    f=pretty_table(matrix; backend=:excel, formatters = [fmt__excel_stringify(3)])
    @test f["prettytable"]["A2"] == "hello"
    @test f["prettytable"]["B2"] == 3.1415926
    @test f["prettytable"]["C2"] == "(1, 4)"
    f=pretty_table(matrix; backend=:excel, formatters = [fmt__excel_stringify(1:3)])
    @test f["prettytable"]["A2"] == "hello"
    @test f["prettytable"]["B2"] == 3.1415926
    @test f["prettytable"]["C2"] == "(1, 4)"
    f=pretty_table(matrix; backend=:excel, formatters = [fmt__excel_stringify(1:2:3)])
    @test f["prettytable"]["A2"] == "hello"
    @test f["prettytable"]["B2"] == 3.1415926
    @test f["prettytable"]["C2"] == "(1, 4)"
    f=pretty_table(matrix; backend=:excel, formatters = [fmt__excel_stringify([1, 2, 3])])
    @test f["prettytable"]["A2"] == "hello"
    @test f["prettytable"]["B2"] == 3.1415926
    @test f["prettytable"]["C2"] == "(1, 4)"

end

