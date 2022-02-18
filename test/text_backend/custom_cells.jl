# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests related to custom cells.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Custom cells - URL text cell" begin
    table = [
        1 "Ronan Arraes Jardim Chagas" URLTextCell("Ronan Arraes Jardim Chagas", "https://ronanarraes.com")
        2 "Google" URLTextCell("Google", "https://google.com")
        3 "Apple" URLTextCell("Apple", "https://apple.com")
        4 "Emojis!" URLTextCell("😃"^20, "https://emojipedia.org/github/")
    ]

    # Default
    # ==========================================================================

    expected = """
        ┌────────┬────────────────────────────┬──────────────────────────────────────────┐
        │ Col. 1 │                     Col. 2 │                                   Col. 3 │
        ├────────┼────────────────────────────┼──────────────────────────────────────────┤
        │      1 │ Ronan Arraes Jardim Chagas │               \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardim Chagas\e]8;;\e\\ │
        │      2 │                     Google │                                   \e]8;;https://google.com\e\\Google\e]8;;\e\\ │
        │      3 │                      Apple │                                    \e]8;;https://apple.com\e\\Apple\e]8;;\e\\ │
        │      4 │                    Emojis! │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\ │
        └────────┴────────────────────────────┴──────────────────────────────────────────┘
        """

    result = pretty_table(String, table)
    @test expected == result

    # Alignment
    # ==========================================================================

    expected = """
        ┌────────┬────────────────────────────┬──────────────────────────────────────────────────────────────┐
        │ Col. 1 │           Col. 2           │                            Col. 3                            │
        ├────────┼────────────────────────────┼──────────────────────────────────────────────────────────────┤
        │   1    │ Ronan Arraes Jardim Chagas │                  \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardim Chagas\e]8;;\e\\                  │
        │   2    │           Google           │                            \e]8;;https://google.com\e\\Google\e]8;;\e\\                            │
        │   3    │           Apple            │                            \e]8;;https://apple.com\e\\Apple\e]8;;\e\\                             │
        │   4    │          Emojis!           │           \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\           │
        └────────┴────────────────────────────┴──────────────────────────────────────────────────────────────┘
        """

    result = pretty_table(
        String,
        table;
        alignment = :c,
        columns_width = [-1, -1, 60]
    )
    @test expected == result

    expected = """
        ┌────────┬────────────────────────────┬──────────────────────────────────────────┐
        │ Col. 1 │ Col. 2                     │ Col. 3                                   │
        ├────────┼────────────────────────────┼──────────────────────────────────────────┤
        │ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardim Chagas\e]8;;\e\\               │
        │ 2      │ Google                     │ \e]8;;https://google.com\e\\Google\e]8;;\e\\                                   │
        │ 3      │ Apple                      │ \e]8;;https://apple.com\e\\Apple\e]8;;\e\\                                    │
        │ 4      │ Emojis!                    │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\ │
        └────────┴────────────────────────────┴──────────────────────────────────────────┘
        """

    result = pretty_table(
        String,
        table;
        alignment = :l
    )
    @test expected == result

    # Filters
    # ==========================================================================

    expected = """
        ┌─────┬───┬────────┬────────────────────────────┐
        │ Row │   │ Col. 1 │                     Col. 3 │
        ├─────┼───┼────────┼────────────────────────────┤
        │   1 │ A │      1 │ \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardim Chagas\e]8;;\e\\ │
        │   3 │ C │      3 │                      \e]8;;https://apple.com\e\\Apple\e]8;;\e\\ │
        └─────┴───┴────────┴────────────────────────────┘
        """

    result = pretty_table(
        String,
        table,
        column_filters = ((data, j) -> j % 2 == 1,),
        row_names = ["A", "B", "C", "D"],
        row_filters = ((data, i)-> i % 2 == 1,),
        show_row_number = true,
    )
    @test expected == result

    # Highlighters
    # ==========================================================================

    expected = """
        ┌────────┬────────────────────────────┬──────────────────────────────────────────┐
        │\e[1m Col. 1 \e[0m│\e[1m                     Col. 2 \e[0m│\e[1m                                   Col. 3 \e[0m│
        ├────────┼────────────────────────────┼──────────────────────────────────────────┤
        │      1 │ Ronan Arraes Jardim Chagas │ \e[33;1m              \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardim Chagas\e]8;;\e\\\e[0m │
        │      2 │                     Google │ \e[33;1m                                  \e]8;;https://google.com\e\\Google\e]8;;\e\\\e[0m │
        │      3 │                      Apple │ \e[33;1m                                   \e]8;;https://apple.com\e\\Apple\e]8;;\e\\\e[0m │
        │      4 │                    Emojis! │ \e[33;1m\e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\\e[0m │
        └────────┴────────────────────────────┴──────────────────────────────────────────┘
        """

    buf = IOBuffer()
    io  = IOContext(buf, :color => true)
    pretty_table(io, table, highlighters = hl_col(3, crayon"yellow bold"))
    result = String(take!(buf))
    @test expected == result

    # Cropping
    # ==========================================================================

    # Column cropping
    # --------------------------------------------------------------------------

    expected = """
        ┌────────┬───────────────┬────────────────────┐
        │ Col. 1 │        Col. 2 │             Col. 3 │
        ├────────┼───────────────┼────────────────────┤
        │      1 │ Ronan Arraes… │ \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jard\e]8;;\e\\… │
        │      2 │        Google │             \e]8;;https://google.com\e\\Google\e]8;;\e\\ │
        │      3 │         Apple │              \e]8;;https://apple.com\e\\Apple\e]8;;\e\\ │
        │      4 │       Emojis! │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃 \e]8;;\e\\… │
        └────────┴───────────────┴────────────────────┘
        """

    result = pretty_table(String, table, columns_width = [-1, 13, 18])
    @test expected == result

    expected = """
        ┌────────┬───────────────┬─────────────────────┐
        │ Col. 1 │        Col. 2 │              Col. 3 │
        ├────────┼───────────────┼─────────────────────┤
        │      1 │ Ronan Arraes… │ \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardi\e]8;;\e\\… │
        │      2 │        Google │              \e]8;;https://google.com\e\\Google\e]8;;\e\\ │
        │      3 │         Apple │               \e]8;;https://apple.com\e\\Apple\e]8;;\e\\ │
        │      4 │       Emojis! │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃\e]8;;\e\\… │
        └────────┴───────────────┴─────────────────────┘
        """

    result = pretty_table(String, table, columns_width = [-1, 13, 19])
    @test expected == result

    # Display cropping
    # --------------------------------------------------------------------------

    expected = """
        ┌────────┬────────────────────────────┬───────────
        │ Col. 1 │                     Col. 2 │          ⋯
        ├────────┼────────────────────────────┼───────────
        │      1 │ Ronan Arraes Jardim Chagas │          ⋯
        │      2 │                     Google │          ⋯
        │      3 │                      Apple │          ⋯
        │      4 │                    Emojis! │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃\e]8;;\e\\ ⋯
        └────────┴────────────────────────────┴───────────
                                          1 column omitted
        """

    result = pretty_table(
        String,
        table;
        display_size = (-1, 50),
        crop = :both
    )
    @test expected == result

    expected = """
        ┌────────┬────────────────────────────┬───────────
        │ Col. 1 │ Col. 2                     │ Col. 3   ⋯
        ├────────┼────────────────────────────┼───────────
        │ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\Ronan Ar\e]8;;\e\\ ⋯
        │ 2      │ Google                     │ \e]8;;https://google.com\e\\Google\e]8;;\e\\   ⋯
        │ 3      │ Apple                      │ \e]8;;https://apple.com\e\\Apple\e]8;;\e\\    ⋯
        │ 4      │ Emojis!                    │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃\e]8;;\e\\ ⋯
        └────────┴────────────────────────────┴───────────
                                          1 column omitted
        """

    result = pretty_table(
        String,
        table;
        alignment = :l,
        display_size = (-1, 50),
        crop = :both
    )
    @test expected == result

    expected = """
        ┌────────┬────────────────────────────┬────────────
        │ Col. 1 │ Col. 2                     │ Col. 3    ⋯
        ├────────┼────────────────────────────┼────────────
        │ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\Ronan Arr\e]8;;\e\\ ⋯
        │ 2      │ Google                     │ \e]8;;https://google.com\e\\Google\e]8;;\e\\    ⋯
        │ 3      │ Apple                      │ \e]8;;https://apple.com\e\\Apple\e]8;;\e\\     ⋯
        │ 4      │ Emojis!                    │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃 \e]8;;\e\\ ⋯
        └────────┴────────────────────────────┴────────────
                                           1 column omitted
        """

    result = pretty_table(
        String,
        table;
        alignment = :l,
        display_size = (-1, 51),
        crop = :both
    )
    @test expected == result

    expected = """
        ┌────────┬────────────────────────────┬───
        │ Col. 1 │ Col. 2                     │  ⋯
        ├────────┼────────────────────────────┼───
        │ 1      │ Ronan Arraes Jardim Chagas │  ⋯
        │ 2      │ Google                     │  ⋯
        │ 3      │ Apple                      │  ⋯
        │ 4      │ Emojis!                    │  ⋯
        └────────┴────────────────────────────┴───
                                  1 column omitted
        """

    result = pretty_table(
        String,
        table;
        alignment = :l,
        display_size = (-1, 42),
        crop = :both
    )
    @test expected == result

    expected = """
        ┌────────┬────────────────────────────┬─────────
        │ Col. 1 │ Col. 2                     │ Col. 3 ⋯
        ├────────┼────────────────────────────┼─────────
        │ 1      │ Ronan Arraes Jardim Chagas │ \e]8;;https://ronanarraes.com\e\\Ronan \e]8;;\e\\ ⋯
        │ 2      │ Google                     │ \e]8;;https://google.com\e\\Google\e]8;;\e\\ ⋯
        │ 3      │ Apple                      │ \e]8;;https://apple.com\e\\Apple\e]8;;\e\\  ⋯
        │ 4      │ Emojis!                    │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃\e]8;;\e\\ ⋯
        └────────┴────────────────────────────┴─────────
                                        1 column omitted
        """

    result = pretty_table(
        String,
        table;
        alignment = :l,
        display_size = (-1, 48),
        crop = :both
    )
    @test expected == result

    # Multi-line cells
    # --------------------------------------------------------------------------

    table = [
        1 "Website\nRonan Arraes Jardim Chagas" URLTextCell("Ronan Arraes Jardim Chagas", "https://ronanarraes.com")
        2 "Website\nGoogle" URLTextCell("Google", "https://google.com")
        3 "Website\nApple" URLTextCell("Apple", "https://apple.com")
        4 "Website\nEmojis!" URLTextCell("😃"^20, "https://emojipedia.org/github/")
    ]

    expected = """
        ┌────────┬────────────────────────────┬──────────────────────────────────────────┐
        │ Col. 1 │                     Col. 2 │                                   Col. 3 │
        ├────────┼────────────────────────────┼──────────────────────────────────────────┤
        │      1 │                    Website │               \e]8;;https://ronanarraes.com\e\\Ronan Arraes Jardim Chagas\e]8;;\e\\ │
        │        │ Ronan Arraes Jardim Chagas │                                          │
        │      2 │                    Website │                                   \e]8;;https://google.com\e\\Google\e]8;;\e\\ │
        │        │                     Google │                                          │
        │      3 │                    Website │                                    \e]8;;https://apple.com\e\\Apple\e]8;;\e\\ │
        │        │                      Apple │                                          │
        │      4 │                    Website │ \e]8;;https://emojipedia.org/github/\e\\😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃😃\e]8;;\e\\ │
        │        │                    Emojis! │                                          │
        └────────┴────────────────────────────┴──────────────────────────────────────────┘
        """

    result = pretty_table(String, table, linebreaks = true)
    @test expected == result
end

@testset "Custom cells - AnsiTextCell" begin
    b = crayon"blue bold"
    y = crayon"yellow bold"
    g = crayon"green bold"

    # From strings
    # ==========================================================================

    ansi_table = [
        AnsiTextCell("$(g)This $(y)is $(b)awesome!")
        AnsiTextCell("$(g)😃😃 $(y)is $(b)awesome!")
        AnsiTextCell("$(g)σ𝛕θ⍺ $(y)is $(b)awesome!")
    ]

    # No crop
    # --------------------------------------------------------------------------

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

    # Cropping
    # --------------------------------------------------------------------------

    expected = """
    ┌──────────┐
    │   Col. 1 │
    ├──────────┤
    │ \e[32;1mThis \e[33;1mis\e[0m… │
    │ \e[32;1m😃😃 \e[33;1mis\e[0m… │
    │ \e[32;1mσ𝛕θ⍺ \e[33;1mis\e[0m… │
    └──────────┘
    """

    result = pretty_table(String, ansi_table, maximum_columns_width = 8)
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

    result = pretty_table(String, ansi_table, display_size = (-1, 10), crop = :both)
    @test result == expected

    # From functions
    # ==========================================================================

    function f(io)
        b = crayon"blue bold"
        y = crayon"yellow bold"
        g = crayon"green bold"
        print(io, "$(g)This $(y)is $(b)awesome!")
        return nothing
    end

    ansi_table = [
        AnsiTextCell(f, context = (:color => true,))
        AnsiTextCell(f, context = (:color => true,))
        AnsiTextCell(f, context = (:color => true,))
    ]

    # No crop
    # --------------------------------------------------------------------------

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

    # Cropping
    # --------------------------------------------------------------------------

    expected = """
    ┌──────────┐
    │   Col. 1 │
    ├──────────┤
    │ \e[32;1mThis \e[33;1mis\e[0m… │
    │ \e[32;1mThis \e[33;1mis\e[0m… │
    │ \e[32;1mThis \e[33;1mis\e[0m… │
    └──────────┘
    """

    result = pretty_table(String, ansi_table, maximum_columns_width = 8)
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

    result = pretty_table(String, ansi_table, display_size = (-1, 10), crop = :both)
    @test result == expected

    # Newlines
    # --------------------------------------------------------------------------

    ansi_table = [
        AnsiTextCell("$(g)This\n$(y)is\n$(b)awesome!")
        AnsiTextCell("$(g)😃😃\n$(y)is\n$(b)awesome!")
        AnsiTextCell("$(g)σ𝛕θ⍺\n$(y)is\n$(b)awesome!")
    ]

    expected = """
    ┌──────────┐
    │   Col. 1 │
    ├──────────┤
    │     \e[32;1mThis\e[0m │
    │       \e[33;1mis\e[0m │
    │ \e[34;1mawesome!\e[0m │
    │     \e[32;1m😃😃\e[0m │
    │       \e[33;1mis\e[0m │
    │ \e[34;1mawesome!\e[0m │
    │     \e[32;1mσ𝛕θ⍺\e[0m │
    │       \e[33;1mis\e[0m │
    │ \e[34;1mawesome!\e[0m │
    └──────────┘
    """

    result = pretty_table(String, ansi_table)
    @test result == expected
end

mutable struct MyCustomCell <: CustomTextCell
    str::String
end

@testset "Custom cells - Errors" begin
    mycell = MyCustomCell("Test")

    @test_throws ErrorException PrettyTables.append_suffix_to_line!(mycell, 1, "")
    @test_throws ErrorException PrettyTables.apply_line_padding!(mycell, 1, 10, 10)
    @test_throws ErrorException PrettyTables.crop_line!(mycell, 1, 10)
    @test_throws ErrorException PrettyTables.get_printable_cell_line(mycell, 1)
    @test_throws ErrorException PrettyTables.get_rendered_line(mycell, 1)
    @test_throws ErrorException PrettyTables.parse_cell_text(mycell; autowrap = true)
    @test PrettyTables.reset!(mycell) === nothing
end

