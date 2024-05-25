## Description #############################################################################
#
# Tests of default tables with Markdown.
#
############################################################################################

@testset "Markdown" begin
    data_md = [1 md"**bold**"
               2 md"""# Title

                      Paragraph

                          code
                   """]

    if VERSION < v"1.10.0-DEV"
        expected = """
┌────────┬────────────────────────────────────────────────┐
│ Col. 1 │                                         Col. 2 │
├────────┼────────────────────────────────────────────────┤
│      1 │   bold                                         │
│      2 │   Title\\n  ≡≡≡≡≡≡≡\\n\\n  Paragraph\\n\\n     code │
└────────┴────────────────────────────────────────────────┘
"""
    else
        expected = """
┌────────┬──────────────────────────────────────────────┐
│ Col. 1 │                                       Col. 2 │
├────────┼──────────────────────────────────────────────┤
│      1 │   bold                                       │
│      2 │   Title\\n  ≡≡≡≡≡\\n\\n  Paragraph\\n\\n     code │
└────────┴──────────────────────────────────────────────┘
"""
    end

    result = pretty_table(String, data_md)
    @test result == expected

    if VERSION < v"1.10.0-DEV"
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
    else
        expected = """
┌────────┬─────────────┐
│ Col. 1 │      Col. 2 │
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
    end

    result = pretty_table(String, data_md, linebreaks = true)
    @test result == expected
end
