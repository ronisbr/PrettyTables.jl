## Description #############################################################################
#
# HTML Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    # The HTML back end currently ignores the generic table format.
    @test pretty_table(
        String,
        matrix;
        backend = :html,
        table_format = TableFormat(;
            horizontal_lines_at_data_rows = :all,
            middle_line                   = LineStyle(; style = :dashed),
        )
    ) == pretty_table(String, matrix; backend = :html)

    # `pretty_table(HTML, ...)` must resolve to the HTML back end when the table format is
    # the backend-agnostic object.
    result = pretty_table(HTML, matrix; table_format = TableFormat())
    @test result isa HTML
    @test occursin("<table", result.content)

    # == Generic Table Style ===============================================================

    face = Face(; slant = :italic, foreground = :blue)

    @test pretty_table(
        String,
        matrix;
        backend = :html,
        style = TableStyle(; first_line_column_label = face)
    ) == pretty_table(
        String,
        matrix;
        backend = :html,
        style = HtmlTableStyle(; first_line_column_label = face)
    )
end
