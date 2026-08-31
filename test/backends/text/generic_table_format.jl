## Description #############################################################################
#
# Text Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    expected = pretty_table(
        String,
        matrix;
        table_format = TextTableFormat(;
            horizontal_lines_at_data_rows  = :all,
            vertical_lines_at_data_columns = :none,
        )
    )

    result = pretty_table(
        String,
        matrix;
        table_format = TableFormat(;
            horizontal_lines_at_data_rows  = :all,
            vertical_lines_at_data_columns = :none,
        )
    )

    @test result == expected

    # The line designs must be converted to the equivalent native line characters, and the
    # line design colors must be converted to the equivalent line faces of the style.
    expected = pretty_table(
        String,
        matrix;
        color = true,
        table_format = TextTableFormat(;
            horizontal_lines_at_data_rows  = :all,
            vertical_lines_at_data_columns = :none,
            top_line                       = TextLineBorders(;
                up_left_corner  = '╒',
                up_right_corner = '╕',
                up_intersection = '╤',
                row             = '═',
            ),
            middle_line                    = TextLineBorders(; row = '╌'),
        ),
        style = TextTableStyle(; top_line = Face(; foreground = :red))
    )

    result = pretty_table(
        String,
        matrix;
        color = true,
        table_format = TableFormat(;
            horizontal_lines_at_data_rows  = :all,
            vertical_lines_at_data_columns = :none,
            top_line                       = LineStyle(; style = :double, color = :red),
            middle_line                    = LineStyle(; style = :dashed),
        )
    )

    @test result == expected

    # An empty generic table format must reproduce the default output.
    @test pretty_table(String, matrix; table_format = TableFormat()) ==
        pretty_table(String, matrix)

    # == Generic Table Style ===============================================================

    face = Face(; slant = :italic, foreground = :blue)

    @test pretty_table(
        String,
        matrix;
        color = true,
        style = TableStyle(; first_line_column_label = face)
    ) == pretty_table(
        String,
        matrix;
        color = true,
        style = TextTableStyle(; first_line_column_label = face)
    )

    @test pretty_table(String, matrix; color = true, style = TableStyle()) ==
        pretty_table(String, matrix; color = true)
end
