## Description #############################################################################
#
# LaTeX Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    # == Line Presence =====================================================================

    expected = pretty_table(
        String,
        matrix;
        backend = :latex,
        table_format = LatexTableFormat(;
            horizontal_lines_at_data_rows = :all,
            vertical_line_at_beginning    = false,
        )
    )

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        table_format = TableFormat(;
            horizontal_lines_at_data_rows = :all,
            vertical_line_at_beginning    = false,
        )
    )

    @test result == expected

    # == Line Design =======================================================================

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        table_format = TableFormat(;
            header_line = LineStyle(; style = :dashed),
            bottom_line = LineStyle(; style = :double),
        )
    )

    @test occursin("\\hdashline", result)
    @test occursin("\\hline\\hline", result)

    # == Generic Table Style ===============================================================

    face = Face(; slant = :italic)

    @test pretty_table(
        String,
        matrix;
        backend = :latex,
        style = TableStyle(; first_line_column_label = face)
    ) == pretty_table(
        String,
        matrix;
        backend = :latex,
        style = LatexTableStyle(; first_line_column_label = face)
    )

    # == Empty Generic Table Format and Style ==============================================

    @test pretty_table(
        String,
        matrix;
        backend = :latex,
        style = TableStyle(),
        table_format = TableFormat()
    ) == pretty_table(String, matrix; backend = :latex)
end
