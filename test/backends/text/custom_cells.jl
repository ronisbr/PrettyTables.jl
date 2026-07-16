## Description #############################################################################
#
# Text Back End: Tests related to custom cells.
#
############################################################################################

@testset "Custom Cells" verbose = true begin
    @testset "AnsiTextCell" begin
        b = crayon"blue bold"
        y = crayon"yellow bold"
        g = crayon"green bold"
        r = crayon"reset"

        # == From Strings ==================================================================

        ansi_table = [
            AnsiTextCell("$(g)This $(y)is $(b)awesome!")
            AnsiTextCell("$(g)😃😃 $(y)is $(b)awesome!")
            AnsiTextCell("$(g)σ𝛕θ⍺ $(y)is $(b)awesome!")
        ]

        # -- No Crop -----------------------------------------------------------------------

        expected = """
┌──────────────────┐
│           Col. 1 │
├──────────────────┤
│ \e[32;1mThis \e[33;1mis \e[34;1mawesome!\e[0m │
│ \e[32;1m😃😃 \e[33;1mis \e[34;1mawesome!\e[0m │
│ \e[32;1mσ𝛕θ⍺ \e[33;1mis \e[34;1mawesome!\e[0m │
└──────────────────┘
"""

        result = pretty_table(String, ansi_table)

        @test result == expected

        # -- Cropping ----------------------------------------------------------------------

        expected = """
┌──────────┐
│   Col. 1 │
├──────────┤
│ \e[32;1mThis \e[33;1mis\e[34;1m\e[0m… │
│ \e[32;1m😃😃 \e[33;1mis\e[34;1m\e[0m… │
│ \e[32;1mσ𝛕θ⍺ \e[33;1mis\e[34;1m\e[0m… │
└──────────┘
"""

        result = pretty_table(String, ansi_table; maximum_data_column_widths = 8)
        @test result == expected

        expected = """
┌─────────
│        ⋯
├─────────
│ \e[32;1mThis \e[33;1mi\e[0m ⋯
│ \e[32;1m😃😃 \e[33;1mi\e[0m ⋯
│ \e[32;1mσ𝛕θ⍺ \e[33;1mi\e[0m ⋯
└─────────
1 column omitted
"""

        result = pretty_table(String, ansi_table; display_size = (-1, 10))
        @test result == expected

        # == From Functions ================================================================

        function f(io)
            b = crayon"blue bold"
            y = crayon"yellow bold"
            g = crayon"green bold"
            print(io, "$(g)This $(y)is $(b)awesome!")
            return nothing
        end

        ansi_table = [
            AnsiTextCell(f; context = (:color => true,))
            AnsiTextCell(f; context = (:color => true,))
            AnsiTextCell(f; context = (:color => true,))
        ]

        # -- No Crop -----------------------------------------------------------------------

        expected = """
┌──────────────────┐
│           Col. 1 │
├──────────────────┤
│ \e[32;1mThis \e[33;1mis \e[34;1mawesome!\e[0m │
│ \e[32;1mThis \e[33;1mis \e[34;1mawesome!\e[0m │
│ \e[32;1mThis \e[33;1mis \e[34;1mawesome!\e[0m │
└──────────────────┘
"""

        result = pretty_table(String, ansi_table)

        @test result == expected

        # -- Cropping ----------------------------------------------------------------------

        expected = """
┌──────────┐
│   Col. 1 │
├──────────┤
│ \e[32;1mThis \e[33;1mis\e[34;1m\e[0m… │
│ \e[32;1mThis \e[33;1mis\e[34;1m\e[0m… │
│ \e[32;1mThis \e[33;1mis\e[34;1m\e[0m… │
└──────────┘
"""

        result = pretty_table(String, ansi_table; maximum_data_column_widths = 8)
        @test result == expected

        expected = """
┌─────────
│        ⋯
├─────────
│ \e[32;1mThis \e[33;1mi\e[0m ⋯
│ \e[32;1mThis \e[33;1mi\e[0m ⋯
│ \e[32;1mThis \e[33;1mi\e[0m ⋯
└─────────
1 column omitted
"""

        result = pretty_table(String, ansi_table; display_size = (-1, 10))
        @test result == expected

        # -- Newlines ----------------------------------------------------------------------

        ansi_table = [
            AnsiTextCell("$(g)This$(r)\n$(y)is\n$(b)awesome!")
            AnsiTextCell("$(g)😃😃\n$(y)is\n$(b)awesome!")
            AnsiTextCell("$(g)σ𝛕θ⍺\n$(y)is\n$(b)awesome!")
        ]

        expected = """
┌──────────┐
│   Col. 1 │
├──────────┤
│     \e[32;1mThis\e[0m\e[0m │
│       \e[33;1mis\e[0m │
│ \e[33m\e[1m\e[34;1mawesome!\e[0m │
│     \e[32;1m😃😃\e[0m │
│ \e[32m\e[1m      \e[33;1mis\e[0m │
│ \e[33m\e[1m\e[34;1mawesome!\e[0m │
│     \e[32;1mσ𝛕θ⍺\e[0m │
│ \e[32m\e[1m      \e[33;1mis\e[0m │
│ \e[33m\e[1m\e[34;1mawesome!\e[0m │
└──────────┘
"""

        result = pretty_table(String, ansi_table; line_breaks = true)
        @test result == expected
    end

    @testset "UrlTextCell" begin
        table = [
            1 "Ronan Arraes Jardim Chagas" UrlTextCell("Ronan Arraes Jardim Chagas", "https://ronanarraes.com")
            2 "Google" UrlTextCell("Google", "https://google.com")
            3 "Apple" UrlTextCell("Apple", "https://apple.com")
            4 "Emojis!" UrlTextCell("😃"^20, "https://emojipedia.org/github/")
        ]

        # == Default =======================================================================

        expected = """
┌────────┬────────────────────────────┬──────────────────────────────────────────┐
│ Col. 1 │                     Col. 2 │                                   Col. 3 │
├────────┼────────────────────────────┼──────────────────────────────────────────┤
│      1 │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\              Ronan Arraes Jardim Chagas\e]8;;\e\\ │
│      2 │                     Google │ \e]8;;https://google.com\e\\                                  Google\e]8;;\e\\ │
│      3 │                      Apple │ \e]8;;https://apple.com\e\\                                   Apple\e]8;;\e\\ │
│      4 │                    Emojis! │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\ │
└────────┴────────────────────────────┴──────────────────────────────────────────┘
"""

        result = pretty_table(String, table)
        @test result == expected

        # == Alignment =====================================================================

        expected = """
┌────────┬────────────────────────────┬──────────────────────────────────────────────────────────────┐
│ Col. 1 │           Col. 2           │                            Col. 3                            │
├────────┼────────────────────────────┼──────────────────────────────────────────────────────────────┤
│   1    │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\                 Ronan Arraes Jardim Chagas                 \e]8;;\e\\ │
│   2    │           Google           │ \e]8;;https://google.com\e\\                           Google                           \e]8;;\e\\ │
│   3    │           Apple            │ \e]8;;https://apple.com\e\\                            Apple                           \e]8;;\e\\ │
│   4    │          Emojis!           │ \e]8;;https://emojipedia.org/github/\e\\          😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃          \e]8;;\e\\ │
└────────┴────────────────────────────┴──────────────────────────────────────────────────────────────┘
"""

        result = pretty_table(
            String, table; alignment = :c, fixed_data_column_widths = [-1, -1, 60]
        )
        @test result == expected

        expected = """
┌────────┬────────────────────────────┬──────────────────────────────────────────┐
│ Col. 1 │ Col. 2                     │ Col. 3                                   │
├────────┼────────────────────────────┼──────────────────────────────────────────┤
│ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardim Chagas              \e]8;;\e\\ │
│ 2      │ Google                     │ \e]8;;https://google.com\e\\Google                                  \e]8;;\e\\ │
│ 3      │ Apple                      │ \e]8;;https://apple.com\e\\Apple                                   \e]8;;\e\\ │
│ 4      │ Emojis!                    │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\ │
└────────┴────────────────────────────┴──────────────────────────────────────────┘
"""

        result = pretty_table(String, table; alignment = :l)
        @test result == expected

        # == Highlighters ==================================================================

        expected = """
┌────────┬────────────────────────────┬──────────────────────────────────────────┐
│\e[1m Col. 1 \e[0m│\e[1m                     Col. 2 \e[0m│\e[1m                                   Col. 3 \e[0m│
├────────┼────────────────────────────┼──────────────────────────────────────────┤
│      1 │ Ronan Arraes Jardim Chagas │\e[33;1m \e]8;;https://ronanarraes.com\e\\              Ronan Arraes Jardim Chagas\e]8;;\e\\ \e[0m│
│      2 │                     Google │\e[33;1m \e]8;;https://google.com\e\\                                  Google\e]8;;\e\\ \e[0m│
│      3 │                      Apple │\e[33;1m \e]8;;https://apple.com\e\\                                   Apple\e]8;;\e\\ \e[0m│
│      4 │                    Emojis! │\e[33;1m \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\ \e[0m│
└────────┴────────────────────────────┴──────────────────────────────────────────┘
"""

        hl = TextHighlighter((data, i, j) -> j == 3, crayon"yellow bold")

        result = pretty_table(String, table; color = true, highlighters = [hl])
        @test result == expected

        # == Cropping ======================================================================

        # -- Column Cropping ---------------------------------------------------------------

        expected = """
┌────────┬───────────────┬────────────────────┐
│ Col. 1 │        Col. 2 │             Col. 3 │
├────────┼───────────────┼────────────────────┤
│      1 │ Ronan Arraes… │ \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jard…\e]8;;\e\\ │
│      2 │        Google │ \e]8;;https://google.com\e\\            Google\e]8;;\e\\ │
│      3 │         Apple │ \e]8;;https://apple.com\e\\             Apple\e]8;;\e\\ │
│      4 │       Emojis! │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃 …\e]8;;\e\\ │
└────────┴───────────────┴────────────────────┘
"""

        result = pretty_table(String, table; fixed_data_column_widths = [-1, 13, 18])
        @test result == expected

        # -- Cell Reuse --------------------------------------------------------------------

        url_cell = UrlTextCell("PrettyTables", "https://prettytables.jl")

        expected = """
┌────────┐
│ Col. 1 │
├────────┤
│ \e]8;;https://prettytables.jl\e\\Prett…\e]8;;\e\\ │
└────────┘
"""

        result = pretty_table(String, [url_cell]; fixed_data_column_widths = [6])
        @test result == expected

        expected = """
┌──────────────┐
│       Col. 1 │
├──────────────┤
│ \e]8;;https://prettytables.jl\e\\PrettyTables\e]8;;\e\\ │
└──────────────┘
"""

        result = pretty_table(String, [url_cell])
        @test result == expected

        # -- Display Cropping --------------------------------------------------------------

        expected = """
┌────────┬────────────────────────────┬───────────
│ Col. 1 │                     Col. 2 │          ⋯
├────────┼────────────────────────────┼───────────
│      1 │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\        \e]8;;\e\\ ⋯
│      2 │                     Google │ \e]8;;https://google.com\e\\        \e]8;;\e\\ ⋯
│      3 │                      Apple │ \e]8;;https://apple.com\e\\        \e]8;;\e\\ ⋯
│      4 │                    Emojis! │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃\e]8;;\e\\ ⋯
└────────┴────────────────────────────┴───────────
                                  1 column omitted
"""

        result = pretty_table(String, table; display_size = (-1, 50))
        @test result == expected

        expected = """
┌────────┬────────────────────────────┬───────────
│ Col. 1 │ Col. 2                     │ Col. 3   ⋯
├────────┼────────────────────────────┼───────────
│ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\Ronan Ar\e]8;;\e\\ ⋯
│ 2      │ Google                     │ \e]8;;https://google.com\e\\Google  \e]8;;\e\\ ⋯
│ 3      │ Apple                      │ \e]8;;https://apple.com\e\\Apple   \e]8;;\e\\ ⋯
│ 4      │ Emojis!                    │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃\e]8;;\e\\ ⋯
└────────┴────────────────────────────┴───────────
                                  1 column omitted
"""

        result = pretty_table(String, table; alignment = :l, display_size = (-1, 50))
        @test result == expected

        expected = """
┌────────┬────────────────────────────┬───
│ Col. 1 │ Col. 2                     │  ⋯
├────────┼────────────────────────────┼───
│ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;\e\\ ⋯
│ 2      │ Google                     │ \e]8;;\e\\ ⋯
│ 3      │ Apple                      │ \e]8;;\e\\ ⋯
│ 4      │ Emojis!                    │ \e]8;;\e\\ ⋯
└────────┴────────────────────────────┴───
                          1 column omitted
"""
        result = pretty_table(String, table; alignment = :l, display_size = (-1, 42))
        @test result == expected

        expected = """
┌────────┬────────────────────────────┬─────────
│ Col. 1 │ Col. 2                     │ Col. 3 ⋯
├────────┼────────────────────────────┼─────────
│ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\Ronan \e]8;;\e\\ ⋯
│ 2      │ Google                     │ \e]8;;https://google.com\e\\Google\e]8;;\e\\ ⋯
│ 3      │ Apple                      │ \e]8;;https://apple.com\e\\Apple \e]8;;\e\\ ⋯
│ 4      │ Emojis!                    │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃\e]8;;\e\\ ⋯
└────────┴────────────────────────────┴─────────
                                1 column omitted
"""
        result = pretty_table(String, table; alignment = :l, display_size = (-1, 48))
        @test result == expected

        # == Multi-line Cells ==============================================================

        table = [
            1 "Website\nRonan Arraes Jardim Chagas" UrlTextCell("Ronan Arraes Jardim Chagas", "https://ronanarraes.com")
            2 "Website\nGoogle" UrlTextCell("Google", "https://google.com")
            3 "Website\nApple" UrlTextCell("Apple", "https://apple.com")
            4 "Website\nEmojis!" UrlTextCell("😃"^20, "https://emojipedia.org/github/")
        ]

        expected = """
┌────────┬────────────────────────────┬──────────────────────────────────────────┐
│ Col. 1 │                     Col. 2 │                                   Col. 3 │
├────────┼────────────────────────────┼──────────────────────────────────────────┤
│      1 │                    Website │ \e]8;;https://ronanarraes.com\e\\              Ronan Arraes Jardim Chagas\e]8;;\e\\ │
│        │ Ronan Arraes Jardim Chagas │                                          │
│      2 │                    Website │ \e]8;;https://google.com\e\\                                  Google\e]8;;\e\\ │
│        │                     Google │                                          │
│      3 │                    Website │ \e]8;;https://apple.com\e\\                                   Apple\e]8;;\e\\ │
│        │                      Apple │                                          │
│      4 │                    Website │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\ │
│        │                    Emojis! │                                          │
└────────┴────────────────────────────┴──────────────────────────────────────────┘
"""

        result = pretty_table(String, table; line_breaks = true)
        @test result == expected
    end
end
