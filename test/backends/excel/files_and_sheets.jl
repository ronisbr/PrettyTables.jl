## Description #############################################################################
#
# Excel Back End: Test use of files and sheets.
#
############################################################################################

@testset "Files and sheets" verbose = true begin

    # Create a new table with default settings.
    data = [1 2; 3 4]
    f = pretty_table(data; backend = :excel) # default returns an XLSXFile object.
    @test  f isa XLSX.XLSXFile
    @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
    @test f["prettytable"]["A2:B3"] == data
    
    # Write another table to a new file.
    f = pretty_table(data; backend = :excel, filename="test.xlsx")
    @test f == "test.xlsx"
    @test isfile(f) === true 
    
    # Read back the data from saved XLSX file and check if they are correct.
    xlsx = XLSX.readxlsx("test.xlsx")
    @test xlsx["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
    @test xlsx["prettytable"]["A2:B3"] == data

    # File already exists.
    @test_throws ErrorException pretty_table(data; backend = :excel, filename="test.xlsx", mode="w")

    # Invalid mode.
    @test_throws ArgumentError pretty_table(data; backend = :excel, filename="test.xlsx", mode="r")

    # Overwrite previous table cells in "w" mode.
    data2 = [7 8; 9 0]
    f = pretty_table(data2; backend = :excel, filename="test.xlsx", mode="w", overwrite=true)
    @test f == "test.xlsx"

    # Overwrite previous table cells in "rw" mode.
    data3 = [5 6; 7 8]
    f = pretty_table(data3; backend = :excel, filename="test.xlsx", mode = "rw")
    @test  f isa XLSX.XLSXFile
    @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
    @test f["prettytable"]["A2:B3"] == data3

    writexlsx("test.xlsx", f, overwrite=true) # Save the changes to the file.

    # Write to an existing sheet in an existing file using an offset
    f = pretty_table(data; backend = :excel, filename = "test.xlsx", mode = "rw", anchor_cell = "D1")
    @test  f isa XLSX.XLSXFile
    @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
    @test f["prettytable"]["A2:B3"] == data3
    @test f["prettytable"]["D1:E1"] == Any["Col. 1" "Col. 2"]
    @test f["prettytable"]["D2:E3"] == data

    # Write to an XLSX.Worksheet in place.
    f = openxlsx("test.xlsx"; mode="rw")
    newf = pretty_table(data; backend = :excel, sheet = XLSX.addsheet!(f, "newsheet"), mode = "rw")
    @test isnothing(newf) === true
    @test XLSX.hassheet(f, "prettytable")
    @test XLSX.hassheet(f, "newsheet")
    @test f["prettytable"]["A1:B1"] == Any["Col. 1" "Col. 2"]
    @test f["prettytable"]["A2:B3"] == data3
    @test f["newsheet"]["A1:B1"] == Any["Col. 1" "Col. 2"]
    @test f["newsheet"]["A2:B3"] == data

    # Can't specify both a file name and an XLSX.Worksheet.
    @test_throws ArgumentError pretty_table(data; backend = :excel, filename = "test.xlsx", sheet = f["newsheet"], mode = "rw")

    # Clean up
    isfile("test.xlsx") && rm("test.xlsx", force = true)
end