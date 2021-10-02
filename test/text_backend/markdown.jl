# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of default tables with Markdown.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Markdown" begin
    data_md = [1 md"**bold**"
               2 md"""# Title

                      Paragraph

                          code
                   """]

    expected = """
┌────────┬────────────────────────────────────────────────┐
│ Col. 1 │                                         Col. 2 │
├────────┼────────────────────────────────────────────────┤
│      1 │   bold                                         │
│      2 │   Title\\n  ≡≡≡≡≡≡≡\\n\\n  Paragraph\\n\\n     code │
└────────┴────────────────────────────────────────────────┘
"""

    result = pretty_table(String, data_md)
    @test result == expected

    expected = """
┌────────┬─────────────┐
│ Col. 1 │      Col. 2 │
├────────┼─────────────┤
│      1 │   bold      │
│      2 │   Title     │
│        │   ≡≡≡≡≡≡≡   │
│        │             │
│        │   Paragraph │
│        │             │
│        │      code   │
└────────┴─────────────┘
"""

    result = pretty_table(String, data_md, linebreaks = true)
    @test result == expected
end
