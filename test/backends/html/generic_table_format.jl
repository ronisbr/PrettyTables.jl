## Description #############################################################################
#
# HTML Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    # The generic table format must be converted to the native HTML table format.
    @test pretty_table(
        String,
        matrix;
        backend = :html,
        table_format = TableFormat(;
            horizontal_lines_at_data_rows = :all,
            middle_line                   = LineStyle(; style = :dashed),
        ),
    ) == pretty_table(
        String,
        matrix;
        backend = :html,
        table_format = HtmlTableFormat(;
            horizontal_lines_at_data_rows = :all,
            borders = HtmlTableBorders(; middle_line = "1px dashed black"),
        ),
    )

    # `pretty_table(HTML, ...)` must resolve to the HTML back end when the table format is
    # the backend-agnostic object.
    result = pretty_table(HTML, matrix; table_format = TableFormat())
    @test result isa HTML
    @test occursin("<table", result.content)

    # == Line Style Conversion =============================================================

    @test html_line_style(LineStyle()) == "1px solid black"
    @test html_line_style(LineStyle(; width = :thin)) == "1px solid black"
    @test html_line_style(LineStyle(; width = :medium)) == "2px solid black"
    @test html_line_style(LineStyle(; width = :thick)) == "3px solid black"
    @test html_line_style(LineStyle(; style = :dashed)) == "1px dashed black"
    @test html_line_style(LineStyle(; style = :dotted)) == "1px dotted black"
    @test html_line_style(LineStyle(; style = :double)) == "1px double black"
    @test html_line_style(LineStyle(; color = 0xff0000)) == "1px solid #ff0000"
    @test html_line_style(
        LineStyle(; width = :thick, style = :double, color = (0, 0, 255))
    ) == "3px double #0000ff"

    # == Generic Table Style ===============================================================

    face = Face(; slant = :italic, foreground = :blue)

    @test pretty_table(
        String,
        matrix;
        backend = :html,
        style = TableStyle(; first_line_column_label = face),
    ) == pretty_table(
        String,
        matrix;
        backend = :html,
        style = HtmlTableStyle(; first_line_column_label = face),
    )
end
