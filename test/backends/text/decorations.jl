## Description #############################################################################
#
# Text Back End: Tests related with decorations.
#
############################################################################################

@testset "Decorations" verbose = true begin
    @testset "Styled Print" begin
        crayon = crayon"bold red"
        display = PrettyTables.Display(; has_color = true)

        @test PrettyTables._text__styled_print(display, "abc", crayon) === nothing
        @test take!(display.buf_line) == collect(codeunits("\e[31;1mabc\e[0m"))
        @test display.column == 3

        display = PrettyTables.Display(; size = (-1, 2), column = 2, has_color = true)

        @test PrettyTables._text__styled_print(display, "ab", crayon) === nothing
        @test take!(display.buf_line) == collect(codeunits("\e[31;1mab\e[0m"))
        @test display.column == 4

        display = PrettyTables.Display(; size = (-1, 2), column = 3, has_color = true)

        @test PrettyTables._text__styled_print(display, "ab", crayon) === nothing
        @test isempty(take!(display.buf_line))
        @test display.column == 3
    end

    @testset "Aligned Print" begin
        render = function (
            str,
            cell_width,
            alignment;
            fill = true,
            crayon = crayon"default",
            has_color = false,
            column = 0,
            size = (-1, -1),
        )
            display = PrettyTables.Display(; has_color, column, size)
            result = PrettyTables._text__print_aligned(
                display, str, cell_width, alignment, crayon, fill
            )
            return result, String(take!(display.buf_line)), display.column
        end

        @test render("x", 4, :l) == (nothing, "x   ", 4)
        @test render("x", 4, :c) == (nothing, " x  ", 4)
        @test render("x", 4, :r) == (nothing, "   x", 4)
        @test render("x", 4, :c; fill = false) == (nothing, " x", 2)
        @test render("x", 4, :r; fill = false) == (nothing, "   x", 4)

        @test render("", 4, :c) == (nothing, "    ", 4)
        @test render("abcd", 4, :r) == (nothing, "abcd", 4)
        @test render("abcde", 4, :r) == (nothing, "abcde", 5)
        @test render("界", 4, :c) == (nothing, " 界 ", 4)

        ansi_str = "\e[31mx\e[0m"
        @test render(ansi_str, 3, :l) == (nothing, ansi_str * "  ", 3)
        @test render("x", 4, :unknown) == (nothing, "x", 1)

        @test render("x", 4, :c; has_color = true) == (nothing, " x  ", 4)
        @test render("x", 4, :c; crayon = crayon"", has_color = true) ==
            (nothing, " x  ", 4)

        colored = "\e[31;1m x  \e[0m"
        @test render("x", 4, :c; crayon = crayon"bold red", has_color = true) ==
            (nothing, colored, 4)
        @test count("\e[31;1m", colored) == 1
        @test count("\e[0m", colored) == 1

        @test render("x", 4, :c; column = 7) == (nothing, " x  ", 11)
        @test render("x", 4, :c; column = 3, size = (-1, 2)) == (nothing, "", 3)
    end

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
            style = TextTableStyle(; first_line_column_label = crayon"bold yellow"),
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
            style = TextTableStyle(;
                first_line_column_label = [
                    crayon"bold yellow"
                    crayon"bold blue"
                    crayon"bold red"
                ],
            ),
        )

        @test result == expected
    end
end
