## Description #############################################################################
#
# Excel Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    # == Line Design =======================================================================

    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        table_format = TableFormat(;
            header_line = LineStyle(; style = :dashed, color = 0xff0000),
        )
    )

    sheet = result[1]

    # The header line is the bottom border of the column label row.
    @test XLSX.getBorder(sheet, "A1").border["bottom"] ==
        Dict("style" => "dashed", "rgb" => "FFFF0000")

    # The other borders must keep their defaults.
    @test XLSX.getBorder(sheet, "A1").border["top"] ==
        Dict("style" => "thick", "rgb" => "FF000000")

    # == Line Presence =====================================================================

    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        table_format = TableFormat(; horizontal_line_at_beginning = false)
    )

    @test XLSX.getBorder(result[1], "A1").border["top"] === nothing

    # == Native Format Still Works =========================================================

    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        table_format = ExcelTableFormat(; horizontal_line_at_beginning = false)
    )

    @test XLSX.getBorder(result[1], "A1").border["top"] === nothing

    # == Generic Table Style ===============================================================

    result = pretty_table(
        XLSX.XLSXFile,
        matrix;
        style = TableStyle(;
            first_line_column_label = Face(; slant = :italic, foreground = 0xff0000),
        )
    )

    font = XLSX.getFont(result[1], "A1").font
    @test haskey(font, "i")
    @test font["color"] == Dict("rgb" => "FFFF0000")
end
