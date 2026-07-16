## Description #############################################################################
#
# Text Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
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

    @testset "Undefined Cells" begin
        v    = Vector{Any}(undef, 5)
        v[1] = undef
        v[2] = "String"
        v[5] = π

        expected = """
┌────────────────────┐
│             Col. 1 │
├────────────────────┤
│ UndefInitializer() │
│             String │
│             #undef │
│             #undef │
│                  π │
└────────────────────┘
"""

        result = pretty_table(String, v)

        @test result == expected

        result = pretty_table(String, v; renderer = :show)

        @test result == expected
    end

    @static if VERSION >= v"1.11"
        @testset "StyledStrings" begin
            matrix = [
                styled"{yellow, bold:Yellow, Bold}" styled"{blue:Blue}"
                styled"{red: Red}"                  styled"{(fg = green),(bg = blue):Green}"
            ]

            expected = """
┌──────────────┬────────┐
│\e[1m    Col. 1    \e[0m│\e[1m Col. 2 \e[0m│
├──────────────┼────────┤
│ \e[33m\e[1mYellow, Bold\e[39m\e[22m │ \e[34mBlue\e[39m   │
│     \e[31m Red\e[39m     │ \e[32m\e[44mGreen\e[39m\e[49m  │
└──────────────┴────────┘
"""

            result = pretty_table(String, matrix; alignment = [:c, :l], color = true)

            @test result == expected
        end
    end
end
