## Description #############################################################################
#
# Markdown Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
    @testset "Markdown Code Espaping" begin
        matrix = ["**Bold**", "~~Strike~~", "`Code`"]

        expected = """
|     **Col. 1** |
|---------------:|
|   \\*\\*Bold\\*\\* |
| \\~\\~Strike\\~\\~ |
|       \\`Code\\` |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown
        )

        @test result == expected
    end

    @testset "Markdown Cells" begin
        matrix = ["**Bold**", "~~Strike~~", md"`Code`"]

        expected = """
|     **Col. 1** |
|---------------:|
|   \\*\\*Bold\\*\\* |
| \\~\\~Strike\\~\\~ |
|         `Code` |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown
        )

        @test result == expected
    end

    @testset "Allow Markdown in Cells" begin
        matrix = ["**Bold**", "~~Strike~~", md"`Code`"]

        expected = """
| **Col. 1** |
|-----------:|
|   **Bold** |
| ~~Strike~~ |
|     `Code` |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            allow_markdown_in_cells = true
        )

        @test result == expected
    end

    @testset "Line Breaks" begin
        matrix = ["First Line\nSecond Line" "Third Line\nFourth Line"]

        expected = """
|              **Col. 1** |              **Col. 2** |
|------------------------:|------------------------:|
| First Line\\nSecond Line | Third Line\\nFourth Line |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown
        )

        @test result == expected

        expected = """
|                **Col. 1** |                **Col. 2** |
|--------------------------:|--------------------------:|
| First Line<br>Second Line | Third Line<br>Fourth Line |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            line_breaks = true
        )

        @test result == expected
    end

    @testset "Undefined Cells" begin
        v    = Vector{Any}(undef, 5)
        v[1] = undef
        v[2] = "String"
        v[5] = π

        expected = """
|         **Col. 1** |
|-------------------:|
| UndefInitializer() |
|             String |
|             #undef |
|             #undef |
|                  π |
"""

        result = pretty_table(
            String,
            v;
            backend = :markdown
        )

        @test result == expected
    end
end

