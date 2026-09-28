## Description #############################################################################
#
# Word Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    # == Line Design =======================================================================

    table = pretty_table(
        W.Table,
        matrix;
        table_format = TableFormat(;
            header_line = LineStyle(; style = :dashed, color = 0xff0000)
        ),
    )

    # The header line is the bottom border of the column label row. The unset width keeps
    # the default header border size (1 pt).
    border = docx_border(docx_cell(table, 1, 1), :bottom)
    @test border.style == W.BorderStyle.dashed
    @test convert(W.EighthPoint, border.size).value == 8
    @test docx_hex(border.color) == "FF0000"

    # The other borders must keep their defaults.
    border = docx_border(docx_cell(table, 1, 1), :top)
    @test border.style == W.BorderStyle.single
    @test convert(W.EighthPoint, border.size).value == 16
    @test docx_hex(border.color) == "000000"

    # == Double Lines ======================================================================

    table = pretty_table(
        W.Table,
        matrix;
        table_format = TableFormat(; bottom_line = LineStyle(; style = :double)),
    )

    border = docx_border(docx_cell(table, 3, 1), :bottom)
    @test border.style == W.BorderStyle.double
    @test convert(W.EighthPoint, border.size).value == 16

    # == Line Presence =====================================================================

    table = pretty_table(
        W.Table, matrix; table_format = TableFormat(; horizontal_line_at_beginning = false)
    )

    @test docx_border(docx_cell(table, 1, 1), :top) === nothing

    # == Native Format Still Works =========================================================

    table = pretty_table(
        W.Table,
        matrix;
        table_format = DocxTableFormat(; horizontal_line_at_beginning = false),
    )

    @test docx_border(docx_cell(table, 1, 1), :top) === nothing

    # == Generic Table Style ===============================================================

    table = pretty_table(
        W.Table,
        matrix;
        style = TableStyle(;
            first_line_column_label = Face(; slant = :italic, foreground = 0xff0000)
        ),
    )

    properties = only(docx_runs(docx_cell(table, 1, 1))).properties
    @test properties.italic == true
    @test docx_hex(properties.color) == "FF0000"
end
