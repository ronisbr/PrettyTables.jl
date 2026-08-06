## Description #############################################################################
#
# Markdown Back End: Test with default options.
#
############################################################################################

@testset "Default Options" begin
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** | **Col. 5** | **Col. 6** |
|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|
|          1 |        1.0 |          1 |          a |        abc |    missing |
|          2 |        2.0 |          2 |          b |        def |    nothing |
|          3 |        3.0 |          3 |          c |        ghi |     symbol |
"""

    result = pretty_table(String, matrix; backend = :markdown)
    @test result == expected

    result = pretty_table(String, matrix; table_format = MarkdownTableFormat())
    @test result == expected

    result = pretty_table_markdown_backend(String, matrix)
    @test result == expected
end

@testset "Title and Subtitle" begin
    # The title and subtitle must be escaped, and a heading level lower than 1 must print
    # them as plain text.
    expected = """
# My \\*Title\\*

Subtitle

| **Col. 1** | **Col. 2** |
|-----------:|-----------:|
|          1 |          2 |
"""

    result = pretty_table(
        String,
        [1 2];
        backend = :markdown,
        subtitle = "Subtitle",
        table_format = MarkdownTableFormat(; subtitle_heading_level = 0),
        title = "My *Title*",
    )

    @test result == expected
end

@testset "Summary Rows in Tables Without Columns" begin
    # A table with rows but no columns has no printed cells. Hence, requesting summary rows
    # must keep printing nothing instead of accessing undefined label references.
    result = pretty_table(
        String,
        Matrix{Float64}(undef, 4, 0);
        backend = :markdown,
        summary_rows = [sum],
    )

    @test result == ""
end
