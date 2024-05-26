## Description #############################################################################
#
# Tests of colors.
#
############################################################################################

@testset "Default Color" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint(
        (io)->pretty_table(io, data),
        context = :color => true
    )

    @test result == expected

    header = ([1, 2, 3, 4],
              [5, 6, 7, 8])

    expected = """
┌───┬───────┬─────┬───┐
│\e[1m 1 \e[0m│\e[1m     2 \e[0m│\e[1m   3 \e[0m│\e[1m 4 \e[0m│
│\e[90m 5 \e[0m│\e[90m     6 \e[0m│\e[90m   7 \e[0m│\e[90m 8 \e[0m│
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    result = sprint(
        (io)->pretty_table(io, data; header = header),
        context = :color => true
    )

    @test result == expected
end

@testset "Row Number" begin
    expected = """
┌─────┬────────┬────────┬────────┬────────┐
│\e[1m Row \e[0m│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├─────┼────────┼────────┼────────┼────────┤
│   1 │      1 │  false │    1.0 │      1 │
│   2 │      2 │   true │    2.0 │      2 │
│   3 │      3 │  false │    3.0 │      3 │
│   4 │      4 │   true │    4.0 │      4 │
│   5 │      5 │  false │    5.0 │      5 │
│   6 │      6 │   true │    6.0 │      6 │
└─────┴────────┴────────┴────────┴────────┘
"""

    result = sprint(
        (io)->pretty_table(io, data, show_row_number = true),
        context = :color => true
    )

    @test result == expected
end

@testset "Row Label" begin
    expected = """
┌───────┬────────┬────────┬────────┬────────┐
│\e[1m Label \e[0m│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├───────┼────────┼────────┼────────┼────────┤
│\e[1m     A \e[0m│      1 │  false │    1.0 │      1 │
│\e[1m     B \e[0m│      2 │   true │    2.0 │      2 │
│\e[1m     C \e[0m│      3 │  false │    3.0 │      3 │
│\e[1m     D \e[0m│      4 │   true │    4.0 │      4 │
│\e[1m     E \e[0m│      5 │  false │    5.0 │      5 │
│\e[1m     F \e[0m│      6 │   true │    6.0 │      6 │
└───────┴────────┴────────┴────────┴────────┘
"""

    row_labels = ['A'+i for i = 0:5]
    result = sprint((io)->pretty_table(
        io,
        data,
        row_labels = row_labels,
        row_label_column_title = "Label"
    ), context = :color => true)

    @test result == expected
end

@testset "Border Color" begin
   expected = """
\e[33m┌\e[0m\e[33m────────\e[0m\e[33m┬\e[0m\e[33m────────\e[0m\e[33m┬\e[0m\e[33m────────\e[0m\e[33m┬\e[0m\e[33m────────\e[0m\e[33m┐\e[0m
\e[33m│\e[0m\e[1m Col. 1 \e[0m\e[33m│\e[0m\e[1m Col. 2 \e[0m\e[33m│\e[0m\e[1m Col. 3 \e[0m\e[33m│\e[0m\e[1m Col. 4 \e[0m\e[33m│\e[0m
\e[33m├\e[0m\e[33m────────\e[0m\e[33m┼\e[0m\e[33m────────\e[0m\e[33m┼\e[0m\e[33m────────\e[0m\e[33m┼\e[0m\e[33m────────\e[0m\e[33m┤\e[0m
\e[33m│\e[0m      1 \e[33m│\e[0m  false \e[33m│\e[0m    1.0 \e[33m│\e[0m      1 \e[33m│\e[0m
\e[33m│\e[0m      2 \e[33m│\e[0m   true \e[33m│\e[0m    2.0 \e[33m│\e[0m      2 \e[33m│\e[0m
\e[33m│\e[0m      3 \e[33m│\e[0m  false \e[33m│\e[0m    3.0 \e[33m│\e[0m      3 \e[33m│\e[0m
\e[33m│\e[0m      4 \e[33m│\e[0m   true \e[33m│\e[0m    4.0 \e[33m│\e[0m      4 \e[33m│\e[0m
\e[33m│\e[0m      5 \e[33m│\e[0m  false \e[33m│\e[0m    5.0 \e[33m│\e[0m      5 \e[33m│\e[0m
\e[33m│\e[0m      6 \e[33m│\e[0m   true \e[33m│\e[0m    6.0 \e[33m│\e[0m      6 \e[33m│\e[0m
\e[33m└\e[0m\e[33m────────\e[0m\e[33m┴\e[0m\e[33m────────\e[0m\e[33m┴\e[0m\e[33m────────\e[0m\e[33m┴\e[0m\e[33m────────\e[0m\e[33m┘\e[0m
"""

    result = sprint(
        (io)->pretty_table(io, data, border_crayon = crayon"yellow"),
        context = :color => true
    )

    @test result == expected
end

@testset "Highlighters" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │\e[33;1m    3.0 \e[0m│      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    hl = Highlighter(
        (data, i, j)-> i == 3 && j == 3;
        bold = true,
        foreground = :yellow
    )

    result = sprint(
        (io)->pretty_table(io, data, highlighters = hl),
        context = :color => true
    )

    @test result == expected

    hl = Highlighter((data, i, j)-> i == 3 && j == 3, crayon"yellow bold")

    result = sprint(
        (io)->pretty_table(io, data, highlighters = hl),
        context = :color => true
    )

    @test result == expected

    hl2 = Highlighter((data, i, j)-> i == 3 && j == 2, crayon"blue bold")

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │\e[34;1m  false \e[0m│\e[33;1m    3.0 \e[0m│      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint(
        (io)->pretty_table(io, data, highlighters = (hl, hl2)),
        context = :color => true
    )

    @test result == expected

    hl3 = Highlighter(
        (data, i, j)-> data[i,j] isa AbstractFloat && data[i,j] == 3,
        (h, data, i, j)->crayon"yellow bold"
    )

    result = sprint(
        (io)->pretty_table(io, data, highlighters = (hl3, hl2)),
        context = :color => true
    )

    @test result == expected
end

@testset "Highlighters with Table Cropping" begin
    matrix = [1:1:100 1:1:100 1:1:100]

    hl = Highlighter((data, i, j)-> i == 100 && j == 2, crayon"yellow")

    expected = """
┌────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│
├────────┼────────┼────────┤
│      1 │      1 │      1 │
│      2 │      2 │      2 │
│      3 │      3 │      3 │
│      4 │      4 │      4 │
│   ⋮    │   ⋮    │   ⋮    │
│     98 │     98 │     98 │
│     99 │     99 │     99 │
│    100 │\e[33m    100 \e[0m│    100 │
└────────┴────────┴────────┘
\e[36m             93 rows omitted\e[0m
"""

    result = sprint((io)->pretty_table(
        io,
        matrix,
        crop = :both,
        display_size = (15, -1),
        highlighters = (hl,),
        vcrop_mode = :middle
    ), context = :color => true)

    @test result == expected
end

@testset "Pre-defined Highlighters" begin

    # == hl_cell ===========================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │\e[33m    3.0 \e[0m│      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_cell(3, 3, crayon"yellow")
    ), context = :color => true)

    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │\e[33m    2.0 \e[0m│      2 │
│      3 │  false │\e[33m    3.0 \e[0m│      3 │
│      4 │   true │    4.0 │\e[33m      4 \e[0m│
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_cell([(2, 3), (3, 3), (4, 4)], crayon"yellow")
    ), context = :color => true)

    @test result == expected

    # == hl_col ============================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │\e[33m  false \e[0m│    1.0 │      1 │
│      2 │\e[33m   true \e[0m│    2.0 │      2 │
│      3 │\e[33m  false \e[0m│    3.0 │      3 │
│      4 │\e[33m   true \e[0m│    4.0 │      4 │
│      5 │\e[33m  false \e[0m│    5.0 │      5 │
│      6 │\e[33m   true \e[0m│    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_col(2, crayon"yellow")
    ), context = :color => true)

    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │\e[33m  false \e[0m│    1.0 │\e[33m      1 \e[0m│
│      2 │\e[33m   true \e[0m│    2.0 │\e[33m      2 \e[0m│
│      3 │\e[33m  false \e[0m│    3.0 │\e[33m      3 \e[0m│
│      4 │\e[33m   true \e[0m│    4.0 │\e[33m      4 \e[0m│
│      5 │\e[33m  false \e[0m│    5.0 │\e[33m      5 \e[0m│
│      6 │\e[33m   true \e[0m│    6.0 │\e[33m      6 \e[0m│
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_col([2,4], crayon"yellow")
    ), context = :color => true)

    @test result == expected

    # == hl_row ============================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│\e[33m      2 \e[0m│\e[33m   true \e[0m│\e[33m    2.0 \e[0m│\e[33m      2 \e[0m│
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_row(2, crayon"yellow")
    ), context = :color => true)

    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│\e[33m      2 \e[0m│\e[33m   true \e[0m│\e[33m    2.0 \e[0m│\e[33m      2 \e[0m│
│      3 │  false │    3.0 │      3 │
│\e[33m      4 \e[0m│\e[33m   true \e[0m│\e[33m    4.0 \e[0m│\e[33m      4 \e[0m│
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_row([2, 4], crayon"yellow")
    ), context = :color => true)

    @test result == expected

    # == hl_lt =============================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│\e[31;1m      1 \e[0m│\e[31;1m  false \e[0m│\e[31;1m    1.0 \e[0m│\e[31;1m      1 \e[0m│
│\e[31;1m      2 \e[0m│\e[31;1m   true \e[0m│\e[31;1m    2.0 \e[0m│\e[31;1m      2 \e[0m│
│      3 │\e[31;1m  false \e[0m│    3.0 │      3 │
│      4 │\e[31;1m   true \e[0m│    4.0 │      4 │
│      5 │\e[31;1m  false \e[0m│    5.0 │      5 │
│      6 │\e[31;1m   true \e[0m│    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_lt(3)
    ), context = :color => true)

    @test result == expected

    # == hl_leq ============================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│\e[31;1m      1 \e[0m│\e[31;1m  false \e[0m│\e[31;1m    1.0 \e[0m│\e[31;1m      1 \e[0m│
│\e[31;1m      2 \e[0m│\e[31;1m   true \e[0m│\e[31;1m    2.0 \e[0m│\e[31;1m      2 \e[0m│
│\e[31;1m      3 \e[0m│\e[31;1m  false \e[0m│\e[31;1m    3.0 \e[0m│\e[31;1m      3 \e[0m│
│      4 │\e[31;1m   true \e[0m│    4.0 │      4 │
│      5 │\e[31;1m  false \e[0m│    5.0 │      5 │
│      6 │\e[31;1m   true \e[0m│    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_leq(3)
    ), context = :color => true)

    @test result == expected

    # == hl_gt =============================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│\e[34;1m      4 \e[0m│   true │\e[34;1m    4.0 \e[0m│\e[34;1m      4 \e[0m│
│\e[34;1m      5 \e[0m│  false │\e[34;1m    5.0 \e[0m│\e[34;1m      5 \e[0m│
│\e[34;1m      6 \e[0m│   true │\e[34;1m    6.0 \e[0m│\e[34;1m      6 \e[0m│
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_gt(3)
    ), context = :color => true)

    @test result == expected

    # == hl_geq ============================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│\e[34;1m      3 \e[0m│  false │\e[34;1m    3.0 \e[0m│\e[34;1m      3 \e[0m│
│\e[34;1m      4 \e[0m│   true │\e[34;1m    4.0 \e[0m│\e[34;1m      4 \e[0m│
│\e[34;1m      5 \e[0m│  false │\e[34;1m    5.0 \e[0m│\e[34;1m      5 \e[0m│
│\e[34;1m      6 \e[0m│   true │\e[34;1m    6.0 \e[0m│\e[34;1m      6 \e[0m│
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        highlighters = hl_geq(3)
    ), context = :color => true)

    @test result == expected

    # == hl_value ==========================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│\e[33;1m      3 \e[0m│  false │\e[33;1m    3.0 \e[0m│\e[33;1m      3 \e[0m│
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data; highlighters = hl_value(3)
    ), context = :color => true)

    @test result == expected
end

@testset "Markdown" begin
    # == With Linebreaks ===================================================================

    a = md"""
       # Header

       This is a paragraph.

       ```julia
       function test()
           return 1
       end
       ```
       """;

    data = [1 a
            2 a]

    if VERSION < v"1.10.0-DEV"
        expected = """
┌────────┬────────────────────────┐
│\e[1m Col. 1 \e[0m│\e[1m                 Col. 2 \e[0m│
├────────┼────────────────────────┤
│      1 │ \e[1m  Header\e[22m\e[0m               │
│        │ \e[1m  ≡≡≡≡≡≡≡≡\e[22m\e[0m             │
│        │ \e[0m                       │
│        │   This is a paragraph.\e[0m │
│        │ \e[0m                       │
│        │ \e[36m  function test()\e[39m\e[0m      │
│        │ \e[36m      return 1\e[39m\e[0m         │
│        │ \e[36m  end\e[39m\e[0m                  │
├────────┼────────────────────────┤
│      2 │ \e[1m  Header\e[22m\e[0m               │
│        │ \e[1m  ≡≡≡≡≡≡≡≡\e[22m\e[0m             │
│        │ \e[0m                       │
│        │   This is a paragraph.\e[0m │
│        │ \e[0m                       │
│        │ \e[36m  function test()\e[39m\e[0m      │
│        │ \e[36m      return 1\e[39m\e[0m         │
│        │ \e[36m  end\e[39m\e[0m                  │
└────────┴────────────────────────┘
"""
    elseif VERSION < v"1.11.0-DEV"
        expected = """
┌────────┬────────────────────────┐
│\e[1m Col. 1 \e[0m│\e[1m                 Col. 2 \e[0m│
├────────┼────────────────────────┤
│      1 │ \e[1m  Header\e[22m\e[0m               │
│        │ \e[1m  ≡≡≡≡≡≡\e[22m\e[0m               │
│        │ \e[0m                       │
│        │   This is a paragraph.\e[0m │
│        │ \e[0m                       │
│        │ \e[36m  function test()\e[39m\e[0m      │
│        │ \e[36m      return 1\e[39m\e[0m         │
│        │ \e[36m  end\e[39m\e[0m                  │
├────────┼────────────────────────┤
│      2 │ \e[1m  Header\e[22m\e[0m               │
│        │ \e[1m  ≡≡≡≡≡≡\e[22m\e[0m               │
│        │ \e[0m                       │
│        │   This is a paragraph.\e[0m │
│        │ \e[0m                       │
│        │ \e[36m  function test()\e[39m\e[0m      │
│        │ \e[36m      return 1\e[39m\e[0m         │
│        │ \e[36m  end\e[39m\e[0m                  │
└────────┴────────────────────────┘
"""
    else
        expected = """
┌────────┬────────────────────────┐
│\e[1m Col. 1 \e[0m│\e[1m                 Col. 2 \e[0m│
├────────┼────────────────────────┤
│      1 │ \e[1m  Header\e[22m\e[0m               │
│        │   \e[1m≡≡≡≡≡≡\e[22m\e[0m               │
│        │ \e[0m                       │
│        │   This is a paragraph.\e[0m │
│        │ \e[0m                       │
│        │   \e[31mfunction\e[39m \e[36mtest\e[92m()\e[39m\e[0m      │
│        │       \e[31mreturn\e[39m \e[91m1\e[39m\e[0m         │
│        │   \e[31mend\e[39m\e[0m                  │
├────────┼────────────────────────┤
│      2 │ \e[1m  Header\e[22m\e[0m               │
│        │   \e[1m≡≡≡≡≡≡\e[22m\e[0m               │
│        │ \e[0m                       │
│        │   This is a paragraph.\e[0m │
│        │ \e[0m                       │
│        │   \e[31mfunction\e[39m \e[36mtest\e[92m()\e[39m\e[0m      │
│        │       \e[31mreturn\e[39m \e[91m1\e[39m\e[0m         │
│        │   \e[31mend\e[39m\e[0m                  │
└────────┴────────────────────────┘
"""
    end

    result = sprint((io)->pretty_table(
        io,
        data,
        hlines = :all,
        linebreaks = true
    ), context = :color => true)

    @test result == expected

    # == Without Linebreaks ================================================================

    a = md"""
    **bold**
    *italics*
    """

    data = [1 a]

    expected = """
┌────────┬────────────────┐
│\e[1m Col. 1 \e[0m│\e[1m         Col. 2 \e[0m│
├────────┼────────────────┤
│      1 │   \e[1mbold\e[22m \e[4mitalics\e[24m │
└────────┴────────────────┘
"""

    result = sprint((io)->pretty_table(
        io,
        data;
        hlines = :all,
        linebreaks = false
    ), context = :color => true)

    @test result == expected
end
