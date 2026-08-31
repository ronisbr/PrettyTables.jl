## Description #############################################################################
#
# Markdown Back End: Tests related with the backend-agnostic table format.
#
############################################################################################

@testset "Generic Table Format" begin
    matrix = [1 2; 3 4]

    kwargs = (
        backend      = :markdown,
        summary_rows = [(data, j) -> sum(data[:, j])],
    )

    expected = pretty_table(
        String,
        matrix;
        kwargs...,
        table_format = MarkdownTableFormat(; line_before_summary_rows = false)
    )

    result = pretty_table(
        String,
        matrix;
        kwargs...,
        table_format = TableFormat(; horizontal_line_before_summary_rows = false)
    )

    @test result == expected
    @test result != pretty_table(String, matrix; kwargs...)

    # Fields that Markdown cannot express must be ignored.
    @test pretty_table(
        String,
        matrix;
        kwargs...,
        table_format = TableFormat(;
            horizontal_lines_at_data_rows = :all,
            top_line                      = LineStyle(; style = :double),
        )
    ) == pretty_table(String, matrix; kwargs...)

    # == Generic Table Style ===============================================================

    face = Face(; slant = :italic)

    @test pretty_table(
        String,
        matrix;
        kwargs...,
        style = TableStyle(; row_label = face, title = Face(; weight = :bold))
    ) == pretty_table(
        String,
        matrix;
        kwargs...,
        style = MarkdownTableStyle(; row_label = face)
    )
end
