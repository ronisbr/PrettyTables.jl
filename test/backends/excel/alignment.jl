## Description #############################################################################
#
# Excel Back End: Test alignment of cells in the table.
#
############################################################################################

@testset "Alignment" verbose=true begin
    data = [1 2 3; 4 5 6; 7 8 9]
    f=pretty_table(data;
        title_alignment = :l,
        title = "This is a title",
        subtitle_alignment = :c,
        subtitle = "This is a subtitle",
        stubhead_label = "stubhead label",
        column_labels = ["Column 1", "Column 2", "Column 3"],
        row_labels = ["Row 1", "Row 2", "Row 3"],
        row_label_column_alignment = :c,
        alignment = [:l, :r, :c],
        summary_rows = [
            (data, j) -> maximum(@views data[:, j]),
            (data, j) -> minimum(@views data[:, j]),
        ],
        summary_row_labels = [
            "Min Value",
            "Max Value",
        ],
        footnotes = [
            (:subtitle, 1, 1) => "Vehicle 1: Ford Escort, Vehicle 2: VW Golf"
            (:column_label, 1, 3) => "Estimated data based on the acceleration measurement."
        ],
        footnote_alignment = :r,
        source_notes = "Source: Test procedure conducted on 2024-01-15.\nNote: Data is for demonstration purposes only.",
        source_note_alignment = :c,
        backend = :excel,
    )

    @test XLSX.getAlignment(f[1], "A4").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "B4").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "C4").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "D4").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "A5").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "A6").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "A7").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "A8").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "B8").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "C8").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "D8").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "A9").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "B9").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "C9").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "D9").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "A10").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "1", "vertical" => "center")
    @test XLSX.getAlignment(f[1], "A11").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "1", "vertical" => "center")
    @test XLSX.getAlignment(f[1], "A12").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "center")
    
    f=pretty_table(data;
        title_alignment = :l,
        title = "This is a title",
        subtitle_alignment = :c,
        subtitle = "This is a subtitle",
        column_label_alignment = [:r, :c, :l],
        column_labels = ["Column 1", "Column 2", "Column 3"],
        row_label_column_alignment = :c,
        alignment = [:r, :c, :l],
        backend = :excel,
    )

    @test XLSX.getAlignment(f[1], "A1").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "A2").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "A4").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "B4").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "C4").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "1", "vertical" => "bottom")
    @test XLSX.getAlignment(f[1], "A5").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "B6").alignment["alignment"] == Dict("horizontal" => "center", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "C7").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")

    f=pretty_table(data;
        title_alignment = :l,
        title = "This is a title",
        subtitle_alignment = :c,
        subtitle = "This is a subtitle",
        column_label_alignment = [:r, :c, :l],
        column_labels = ["Column 1", "Column 2", "Column 3"],
        row_label_column_alignment = :c,
        alignment = :c,
        cell_alignment = [(data, i, j) -> isodd(j) ? :l : :r],
        backend = :excel,
    )

    @test XLSX.getAlignment(f[1], "A5").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "B5").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "C5").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "A6").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "B6").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "C6").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "A7").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "B7").alignment["alignment"] == Dict("horizontal" => "right", "wrapText" => "0", "vertical" => "top")
    @test XLSX.getAlignment(f[1], "C7").alignment["alignment"] == Dict("horizontal" => "left", "wrapText" => "0", "vertical" => "top")

end