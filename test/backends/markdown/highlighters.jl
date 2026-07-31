## Description #############################################################################
#
# Markdown Back End: Test highlighters.
#
############################################################################################

@testset "Highlighters" begin
    matrix = [
        1 2 3
        4 5 6
    ]

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** |
|-----------:|-----------:|-----------:|
|    ***1*** |        `2` |    ***3*** |
|        `4` |    ***5*** |        `6` |
"""

    md_bold        = MarkdownStyle(; bold = true)
    md_code        = MarkdownStyle(; code = true)
    md_bold_italic = MarkdownStyle(; bold = true, italic = true)

    result = pretty_table(
        String,
        matrix;
        backend = :markdown,
        highlighters = [
            MarkdownHighlighter(
                (data, i, j) -> data[i, j] % 2 == 0, (_, _, _, _) -> md_code
            )
            MarkdownHighlighter((data, i, j) -> data[i, j] % 2 == 0, md_bold)
            MarkdownHighlighter((data, i, j) -> data[i, j] % 2 != 0, md_bold_italic)
        ],
    )

    @test result == expected

    @testset "First Match Wins" begin
        # The applied style must be the one of the **first** matching highlighter.
        h1 = MarkdownHighlighter((d, i, j) -> true, MarkdownStyle(; bold = true))
        h2 = MarkdownHighlighter((d, i, j) -> true, MarkdownStyle(; strikethrough = true))

        result = pretty_table(String, [1]; backend = :markdown, highlighters = [h1, h2])

        @test occursin("**1**", result)
        @test !occursin("~~", result)
    end

    @testset "Highlighter Receives the Original Data" begin
        # The highlighter callbacks must see the object the user passed to `pretty_table`,
        # not the internal table wrapper, so that they are portable across back ends.
        data = (a = [1, 2],)
        seen = []

        h = MarkdownHighlighter(
            (d, i, j) -> (push!(seen, typeof(d)); false),
            MarkdownStyle(; bold = true),
        )

        pretty_table(String, data; backend = :markdown, highlighters = [h])

        @test !isempty(seen)
        @test all(==(typeof(data)), seen)
    end
end
