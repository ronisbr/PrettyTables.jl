## Description #############################################################################
#
# Markdown Back End: Tests related with decorations.
#
############################################################################################

@testset "Decorations" verbose = true begin
    @testset "Decoration of Column Labels" begin
        matrix = ones(3, 3)

        expected = """
| *Col. 1* | *Col. 2* | *Col. 3* |
|---------:|---------:|---------:|
|      1.0 |      1.0 |      1.0 |
|      1.0 |      1.0 |      1.0 |
|      1.0 |      1.0 |      1.0 |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            style = MarkdownTableStyle(; first_line_column_label = MarkdownStyle(italic = true))
        )

        @test result == expected

        expected = """
| *Col. 1* | **Col. 2** | `Col. 3` |
|---------:|-----------:|---------:|
|      1.0 |        1.0 |      1.0 |
|      1.0 |        1.0 |      1.0 |
|      1.0 |        1.0 |      1.0 |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            style = MarkdownTableStyle(; first_line_column_label = [
                MarkdownStyle(italic = true),
                MarkdownStyle(bold   = true),
                MarkdownStyle(code   = true)
            ])
        )

        @test result == expected
    end
end


