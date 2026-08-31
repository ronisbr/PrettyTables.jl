## Description #############################################################################
#
# Typst Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    # == Line Presence =====================================================================

    expected = pretty_table(
        String,
        matrix;
        backend = :typst,
        table_format = TypstTableFormat(;
            horizontal_lines_at_data_rows  = :all,
            vertical_lines_at_data_columns = :none,
        )
    )

    result = pretty_table(
        String,
        matrix;
        backend = :typst,
        table_format = TableFormat(;
            horizontal_lines_at_data_rows  = :all,
            vertical_lines_at_data_columns = :none,
        )
    )

    @test result == expected

    # == Line Design =======================================================================

    result = pretty_table(
        String,
        matrix;
        backend = :typst,
        table_format = TableFormat(;
            header_line = LineStyle(; style = :dashed, width = :thick, color = :red),
        )
    )

    @test occursin("(thickness: 1.5pt, paint: rgb(\"#a51c2c\"), dash: \"dashed\")", result)

    # == Generic Table Style ===============================================================

    style = TableStyle(; first_line_column_label = Face(; slant = :italic))

    @test pretty_table(String, matrix; backend = :typst, style = style) == pretty_table(
        String,
        matrix;
        backend = :typst,
        style = TypstTableStyle(; first_line_column_label = Face(; slant = :italic))
    )

    # == Empty Generic Table Format and Style ==============================================

    @test pretty_table(
        String,
        matrix;
        backend = :typst,
        style = TableStyle(),
        table_format = TableFormat()
    ) == pretty_table(String, matrix; backend = :typst)
end
