## Description #############################################################################
#
# HTML Back End: Test highlighters.
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

    md_bold        = MarkdownStyle(bold = true)
    md_code        = MarkdownStyle(code = true)
    md_bold_italic = MarkdownStyle(bold = true, italic = true)

    result = pretty_table(
        String,
        matrix;
        backend = :markdown,
        highlighters = [
            MarkdownHighlighter((data, i, j) -> data[i, j] % 2 == 0, md_code)
            MarkdownHighlighter((data, i, j) -> data[i, j] % 2 == 0, md_bold)
            MarkdownHighlighter((data, i, j) -> data[i, j] % 2 != 0, md_bold_italic)
        ]
    )

    @test result == expected
end
