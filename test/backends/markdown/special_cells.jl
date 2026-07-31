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

        result = pretty_table(String, matrix; backend = :markdown)

        @test result == expected

        result = pretty_table(String, matrix; backend = :markdown, renderer = :show)

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

        result = pretty_table(String, matrix; backend = :markdown)

        @test result == expected

        result = pretty_table(String, matrix; backend = :markdown, renderer = :show)

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
            String, matrix; backend = :markdown, allow_markdown_in_cells = true
        )

        @test result == expected

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            allow_markdown_in_cells = true,
            renderer = :show,
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

        result = pretty_table(String, matrix; backend = :markdown)

        @test result == expected

        result = pretty_table(String, matrix; backend = :markdown, renderer = :show)

        @test result == expected

        expected = """
|                **Col. 1** |                **Col. 2** |
|--------------------------:|--------------------------:|
| First Line<br>Second Line | Third Line<br>Fourth Line |
"""

        result = pretty_table(String, matrix; backend = :markdown, line_breaks = true)

        @test result == expected

        result = pretty_table(
            String, matrix; backend = :markdown, line_breaks = true, renderer = :show
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

        result = pretty_table(String, v; backend = :markdown)

        @test result == expected

        result = pretty_table(String, v; backend = :markdown, renderer = :show)

        @test result == expected
    end

    @testset "Escaping of Markdown Metacharacters" begin
        # `\` must be escaped first. Otherwise, the backslash this function inserts for, say,
        # `*` would sit next to a user backslash, `\\` would render as a literal backslash,
        # and the `*` would start an emphasis span.
        #
        # `[` and `]` are critical because the back end itself emits `[^N]` footnote
        # references, so unescaped user data could collide with the generated markup. `<` and
        # `>` would otherwise be interpreted as raw HTML or as an autolink.
        matrix = ["a\\*b" "c[^1]d" "e<b>f" "g|h" "i*j" "k_l" "m~n" "o`p"]

        result = pretty_table(String, matrix; backend = :markdown)

        @test occursin("a\\\\\\*b", result)
        @test occursin("c\\[^1\\]d", result)
        @test occursin("e\\<b\\>f", result)
        @test occursin("g\\|h", result)
        @test occursin("i\\*j", result)
        @test occursin("k\\_l", result)
        @test occursin("m\\~n", result)
        @test occursin("o\\`p", result)
    end

    @testset "Sentinels Are Not Escaped" begin
        # `#` must not be escaped, otherwise the sentinels this package emits would be
        # corrupted.
        v    = Vector{Any}(undef, 1)
        result = pretty_table(String, v; backend = :markdown)

        @test occursin("#undef", result)
        @test !occursin("\\#undef", result)
    end

    @testset "Line Breaks Still Emit <br>" begin
        # The `<br>` the back end emits for line breaks is produced *after* the escaping,
        # hence escaping `<` and `>` at the source level must not affect it.
        result = pretty_table(String, ["a\nb"]; backend = :markdown, line_breaks = true)

        @test occursin("a<br>b", result)

        # Without `line_breaks`, the newline must be escaped instead.
        result = pretty_table(String, ["a\nb"]; backend = :markdown, line_breaks = false)

        @test occursin("a\\nb", result)
    end
end
