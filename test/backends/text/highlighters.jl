## Description #############################################################################
#
# Text Back End: Test highlighters.
#
############################################################################################

@testset "Highlighters" begin
    matrix = [
        1 2 3
        4 5 6
    ]

    expected = """
┌────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│
├────────┼────────┼────────┤
│\e[1;3m      1 \e[0m│\e[36;1m      2 \e[0m│\e[1;3m      3 \e[0m│
│\e[36;1m      4 \e[0m│\e[1;3m      5 \e[0m│\e[36;1m      6 \e[0m│
└────────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        matrix;
        color = true,
        highlighters = [
            TextHighlighter((data, i, j) -> data[i, j] % 2 == 0, crayon"bold fg:cyan")
            TextHighlighter((data, i, j) -> data[i, j] % 2 == 0; bold = true)
            TextHighlighter((data, i, j) -> data[i, j] % 2 != 0, crayon"bold italics")
        ]
    )

    @test result == expected
end

