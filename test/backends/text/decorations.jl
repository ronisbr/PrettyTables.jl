## Description #############################################################################
#
# Text Back End: Tests related with decorations.
#
############################################################################################

@testset "Decorations" verbose = true begin
    @testset "Decoration of Column Labels" begin
        matrix = ones(3, 3)

        expected = """
┌────────┬────────┬────────┐
│\e[33;1m Col. 1 \e[0m│\e[33;1m Col. 2 \e[0m│\e[33;1m Col. 3 \e[0m│
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
└────────┴────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            color = true,
            style = TextTableStyle(; first_line_column_label = crayon"bold yellow")
        )

        @test result == expected

        expected = """
┌────────┬────────┬────────┐
│\e[33;1m Col. 1 \e[0m│\e[34;1m Col. 2 \e[0m│\e[31;1m Col. 3 \e[0m│
├────────┼────────┼────────┤
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
│    1.0 │    1.0 │    1.0 │
└────────┴────────┴────────┘
"""

        result = pretty_table(
            String,
            matrix;
            color = true,
            style = TextTableStyle(; first_line_column_label = [
                crayon"bold yellow"
                crayon"bold blue"
                crayon"bold red"
            ])
        )

        @test result == expected
    end
end
