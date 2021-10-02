# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of line breaks.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Line breaks inside cells" begin
    data = ["This line contains\nthe velocity [m/s]" 10.0;
            "This line contains\nthe acceleration [m/s^2]" 1.0;
            "This line contains\nthe time from the\nbeginning of the simulation" 10;]

    header = ["Information", "Value"]

    expected = """
┌─────────────────────────────┬───────┐
│                 Information │ Value │
├─────────────────────────────┼───────┤
│          This line contains │  10.0 │
│          the velocity [m/s] │       │
│          This line contains │   1.0 │
│    the acceleration [m/s^2] │       │
│          This line contains │    10 │
│           the time from the │       │
│ beginning of the simulation │       │
└─────────────────────────────┴───────┘
"""

    result = pretty_table(String, data; header = header, linebreaks = true)
    @test result == expected

    expected = """
┌─────────────────────────────┬───────┐
│         Information         │ Value │
├─────────────────────────────┼───────┤
│     This line contains      │ 10.0  │
│     the velocity [m/s]      │       │
│     This line contains      │  1.0  │
│  the acceleration [m/s^2]   │       │
│     This line contains      │  10   │
│      the time from the      │       │
│ beginning of the simulation │       │
└─────────────────────────────┴───────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        alignment = :c,
        linebreaks = true
    )
    @test result == expected

    expected = """
┌─────────────────────────────┬───────┐
│ Information                 │ Value │
├─────────────────────────────┼───────┤
│ This line contains          │ 10.0  │
│ the velocity [m/s]          │       │
│ This line contains          │ 1.0   │
│ the acceleration [m/s^2]    │       │
│ This line contains          │ 10    │
│ the time from the           │       │
│ beginning of the simulation │       │
└─────────────────────────────┴───────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        alignment = :l,
        linebreaks = true
    )
    @test result == expected

    expected = """
┌────────────────────────────────────────────────────────────────────┬───────┐
│                                                        Information │ Value │
├────────────────────────────────────────────────────────────────────┼───────┤
│                             This line contains\\nthe velocity [m/s] │  10.0 │
│                       This line contains\\nthe acceleration [m/s^2] │   1.0 │
│ This line contains\\nthe time from the\\nbeginning of the simulation │    10 │
└────────────────────────────────────────────────────────────────────┴───────┘
"""

    result = pretty_table(String, data; header = header)
    @test result == expected

    # Show only the first line
    # --------------------------------------------------------------------------

    expected = """
┌────────────────────┬───────┐
│        Information │ Value │
├────────────────────┼───────┤
│ This line contains │  10.0 │
│ This line contains │   1.0 │
│ This line contains │    10 │
└────────────────────┴───────┘
"""

    result = pretty_table(
        String,
        data;
        header = header,
        cell_first_line_only = true
    )
    @test result == expected
end

@testset "Auto wrapping" begin
    table = [1 """Ouviram do Ipiranga as margens plácidas
                  De um povo heróico o brado retumbante,
                  E o sol da Liberdade, em raios fúlgidos,
                  Brilhou no céu da Pátria nesse instante.""";
             2 """Se o penhor dessa igualdade
                  Conseguimos conquistar com braço forte,
                  Em teu seio, ó Liberdade,
                  Desafia o nosso peito a própria morte!""";
             3 """Ó Pátria amada, Idolatrada, Salve! Salve!
                  Brasil, um sonho intenso, um raio vívido
                  De amor e de esperança à terra desce,
                  Se em teu formoso céu, risonho e límpido,"""]

    header = ["Verse number", "Verse"]

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse number │                          Verse │
├──────────────┼────────────────────────────────┤
│            1 │         Ouviram do Ipiranga as │
│              │               margens plácidas │
│              │     De um povo heróico o brado │
│              │                    retumbante, │
│              │       E o sol da Liberdade, em │
│              │                raios fúlgidos, │
│              │       Brilhou no céu da Pátria │
│              │                nesse instante. │
├──────────────┼────────────────────────────────┤
│            2 │    Se o penhor dessa igualdade │
│              │     Conseguimos conquistar com │
│              │                   braço forte, │
│              │      Em teu seio, ó Liberdade, │
│              │        Desafia o nosso peito a │
│              │                 própria morte! │
├──────────────┼────────────────────────────────┤
│            3 │    Ó Pátria amada, Idolatrada, │
│              │                  Salve! Salve! │
│              │   Brasil, um sonho intenso, um │
│              │                    raio vívido │
│              │       De amor e de esperança à │
│              │                   terra desce, │
│              │         Se em teu formoso céu, │
│              │             risonho e límpido, │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String,
        table;
        header        = header,
        autowrap      = true,
        linebreaks    = true,
        body_hlines   = [1, 2],
        columns_width = [-1, 30]
    )

    @test result == expected

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse number │             Verse              │
├──────────────┼────────────────────────────────┤
│      1       │     Ouviram do Ipiranga as     │
│              │        margens plácidas        │
│              │   De um povo heróico o brado   │
│              │          retumbante,           │
│              │    E o sol da Liberdade, em    │
│              │        raios fúlgidos,         │
│              │    Brilhou no céu da Pátria    │
│              │        nesse instante.         │
├──────────────┼────────────────────────────────┤
│      2       │  Se o penhor dessa igualdade   │
│              │   Conseguimos conquistar com   │
│              │          braço forte,          │
│              │   Em teu seio, ó Liberdade,    │
│              │    Desafia o nosso peito a     │
│              │         própria morte!         │
├──────────────┼────────────────────────────────┤
│      3       │  Ó Pátria amada, Idolatrada,   │
│              │         Salve! Salve!          │
│              │  Brasil, um sonho intenso, um  │
│              │          raio vívido           │
│              │    De amor e de esperança à    │
│              │          terra desce,          │
│              │     Se em teu formoso céu,     │
│              │       risonho e límpido,       │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String,
        table;
        header        = header,
        alignment     = :c,
        autowrap      = true,
        linebreaks    = true,
        body_hlines   = [1, 2],
        columns_width = [-1, 30]
    )

    @test result == expected

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse number │ Verse                          │
├──────────────┼────────────────────────────────┤
│ 1            │ Ouviram do Ipiranga as         │
│              │ margens plácidas               │
│              │ De um povo heróico o brado     │
│              │ retumbante,                    │
│              │ E o sol da Liberdade, em       │
│              │ raios fúlgidos,                │
│              │ Brilhou no céu da Pátria       │
│              │ nesse instante.                │
├──────────────┼────────────────────────────────┤
│ 2            │ Se o penhor dessa igualdade    │
│              │ Conseguimos conquistar com     │
│              │ braço forte,                   │
│              │ Em teu seio, ó Liberdade,      │
│              │ Desafia o nosso peito a        │
│              │ própria morte!                 │
├──────────────┼────────────────────────────────┤
│ 3            │ Ó Pátria amada, Idolatrada,    │
│              │ Salve! Salve!                  │
│              │ Brasil, um sonho intenso, um   │
│              │ raio vívido                    │
│              │ De amor e de esperança à       │
│              │ terra desce,                   │
│              │ Se em teu formoso céu,         │
│              │ risonho e límpido,             │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String,
        table;
        header        = header,
        alignment     = :l,
        autowrap      = true,
        linebreaks    = true,
        body_hlines   = [1, 2],
        columns_width = [-1, 30]
    )

    @test result == expected

    # Test with additional rows
    # --------------------------------------------------------------------------

    expected = """
┌─────┬──────────┬──────────────┬────────────────────────────────┐
│ Row │    Verso │ Verse number │ Verse                          │
├─────┼──────────┼──────────────┼────────────────────────────────┤
│   1 │ Primeiro │ 1            │ Ouviram do Ipiranga as         │
│     │          │              │ margens plácidas               │
│     │          │              │ De um povo heróico o brado     │
│     │          │              │ retumbante,                    │
│     │          │              │ E o sol da Liberdade, em       │
│     │          │              │ raios fúlgidos,                │
│     │          │              │ Brilhou no céu da Pátria       │
│     │          │              │ nesse instante.                │
├─────┼──────────┼──────────────┼────────────────────────────────┤
│   2 │  Segundo │ 2            │ Se o penhor dessa igualdade    │
│     │          │              │ Conseguimos conquistar com     │
│     │          │              │ braço forte,                   │
│     │          │              │ Em teu seio, ó Liberdade,      │
│     │          │              │ Desafia o nosso peito a        │
│     │          │              │ própria morte!                 │
├─────┼──────────┼──────────────┼────────────────────────────────┤
│   3 │ Terceiro │ 3            │ Ó Pátria amada, Idolatrada,    │
│     │          │              │ Salve! Salve!                  │
│     │          │              │ Brasil, um sonho intenso, um   │
│     │          │              │ raio vívido                    │
│     │          │              │ De amor e de esperança à       │
│     │          │              │ terra desce,                   │
│     │          │              │ Se em teu formoso céu,         │
│     │          │              │ risonho e límpido,             │
└─────┴──────────┴──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String, table;
        header                = header,
        alignment             = :l,
        autowrap              = true,
        linebreaks            = true,
        body_hlines           = [1, 2],
        columns_width         = [-1, 30],
        show_row_number       = true,
        row_names             = ["Primeiro", "Segundo", "Terceiro"],
        row_name_column_title = "Verso"
    )

    @test result == expected
end
