## Description #############################################################################
#
# Excel Back End: Test use of files and sheets.
#
############################################################################################

@testset "Files and Sheets" verbose = true begin

    # == Creating and Reading Tables =======================================================

    @testset "Creating and Reading Tables" verbose = true begin
        data = [1 2; 3 4]

        f = pretty_table(data; backend = :excel)
        @test f isa XLSX.XLSXFile
        @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
        @test f["prettytable"]["A2:B3"] == data

        f = pretty_table(data; backend = :excel, filename = "test.xlsx")
        @test f == "test.xlsx"
        @test isfile(f) === true

        xlsx = XLSX.readxlsx("test.xlsx")
        @test xlsx["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
        @test xlsx["prettytable"]["A2:B3"] == data
    end

    # == File Modes ========================================================================

    @testset "File Modes" verbose = true begin
        data = [1 2; 3 4]

        @test_throws ErrorException pretty_table(
            data; backend = :excel, filename = "test.xlsx", mode = "w"
        )

        @test_throws ArgumentError pretty_table(
            data; backend = :excel, filename = "test.xlsx", mode = "r"
        )

        data2 = [7 8; 9 0]
        f = pretty_table(
            data2; backend = :excel, filename = "test.xlsx", mode = "w", overwrite = true
        )
        @test f == "test.xlsx"

        data3 = [5 6; 7 8]
        f = pretty_table(data3; backend = :excel, filename = "test.xlsx", mode = "rw")
        @test f isa XLSX.XLSXFile
        @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
        @test f["prettytable"]["A2:B3"] == data3

        writexlsx("test.xlsx", f; overwrite = true)
    end

    # == Anchor Cells ======================================================================

    @testset "Anchor Cells" verbose = true begin
        data = [1 2; 3 4]
        data3 = [5 6; 7 8]

        f = pretty_table(
            data; backend = :excel, filename = "test.xlsx", mode = "rw", anchor_cell = "D1"
        )
        @test f isa XLSX.XLSXFile
        @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
        @test f["prettytable"]["A2:B3"] == data3
        @test f["prettytable"]["D1:E1"] == Any["Col. 1" "Col. 2"]
        @test f["prettytable"]["D2:E3"] == data
    end

    # == XLSX Worksheets ===================================================================

    @testset "XLSX Worksheets" verbose = true begin
        data = [1 2; 3 4]
        data3 = [5 6; 7 8]

        f = openxlsx("test.xlsx"; mode = "rw")
        newf = pretty_table(
            data; backend = :excel, sheet = XLSX.addsheet!(f, "newsheet"), mode = "rw"
        )
        @test isnothing(newf) === true
        @test XLSX.hassheet(f, "prettytable")
        @test XLSX.hassheet(f, "newsheet")
        @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
        @test f["prettytable"]["A2:B3"] == data3
        @test f["newsheet"]["A1:B1"] == Any["Col. 1" "Col. 2"]
        @test f["newsheet"]["A2:B3"] == data

        @test_throws ArgumentError pretty_table(
            data;
            backend = :excel,
            filename = "test.xlsx",
            sheet = f["newsheet"],
            mode = "rw",
        )
    end

    # == Cleanup ===========================================================================

    isfile("test.xlsx") && rm("test.xlsx"; force = true)
end
