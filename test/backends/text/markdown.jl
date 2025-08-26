## Description #############################################################################
#
# Text Back End: Test Markdown rendering.
#
############################################################################################

@testset "Markdown" begin
    data_md = [
        1 md"**bold**"
        2 md"""# Title

               Paragraph

                   code
            """
    ]

        expected = """
┌────────┬──────────────────────────────────────────────┐
│ Col. 1 │ Col. 2                                       │
├────────┼──────────────────────────────────────────────┤
│      1 │   bold                                       │
│      2 │   Title\\n  ≡≡≡≡≡\\n\\n  Paragraph\\n\\n     code │
└────────┴──────────────────────────────────────────────┘
"""

    result = pretty_table(String, data_md; alignment = [:r, :l])
    @test result == expected

        expected = """
┌────────┬─────────────┐
│ Col. 1 │ Col. 2      │
├────────┼─────────────┤
│      1 │   bold      │
│      2 │   Title     │
│        │   ≡≡≡≡≡     │
│        │             │
│        │   Paragraph │
│        │             │
│        │      code   │
└────────┴─────────────┘
"""

    result = pretty_table(String, data_md; alignment = [:r, :l], line_breaks = true)
    @test result == expected
end
