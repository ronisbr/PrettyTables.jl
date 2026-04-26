## Description #############################################################################
#
# Excel Back End: Test column headers.
#
############################################################################################

@testset "Column headers" verbose=true begin

    data = [1 2 3 4]


    merge_column_label_cells = :auto

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

    f=pretty_table(data;
        column_labels,
        merge_column_label_cells,
        backend = :excel,
    )
    
    # merged columns in top row
    @test XLSX.getBorder(f[1], "C1").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.isMergedCell(f[1], "D1") == true

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

    f=pretty_table(data;
        column_labels,
        merge_column_label_cells,
        backend = :excel,
    )
    
    # merged columns in middle row
    @test XLSX.getBorder(f[1], "C2").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.isMergedCell(f[1], "D2") == true

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

    f=pretty_table(data;
        column_labels,
        merge_column_label_cells,
        backend = :excel,
    )

    # merged columns in bottom row
    @test XLSX.getBorder(f[1], "C3").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.isMergedCell(f[1], "D3") == true

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

    f=pretty_table(data;
        column_labels,
        merge_column_label_cells,
        backend = :excel,
    )

    # merged columns middle two columns
    @test XLSX.getBorder(f[1], "B2").border["bottom"] == Dict("style" => "thin", "rgb" => "FF000000")
    @test XLSX.isMergedCell(f[1], "C2") == true

    # Default height and width.
    @test XLSX.getRowHeight(f[1], "C3") ≈ 17.6109375
    @test XLSX.getColumnWidth(f[1], "C3") ≈ 10.253794642857144

    f=pretty_table(data;
        column_labels,
        merge_column_label_cells,
        table_format = ExcelTableFormat(borders = ExcelTableBorders(merged_header_cell_line = ["style" => "thick", "color" => "red"])),
        style = ExcelTableStyle(merged_column_label = ["color"=>"red", "size"=>"32"]),
        backend = :excel,
    )

    # Merged comumn label doesn't affect column width.
    @test XLSX.getRowHeight(f[1], "C2") ≈ 41.6109375
    @test XLSX.getColumnWidth(f[1], "C3") ≈ 10.253794642857144
    @test XLSX.getColumnWidth(f[1], "D3") ≈ 10.253794642857144

    # Merged column label has changed border
    @test XLSX.getBorder(f[1], "C2").border["bottom"] == Dict("style" => "thick", "rgb" => "FFFF0000")

end