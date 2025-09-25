## Description #############################################################################
#
# Test line breaks.
#
############################################################################################

@testset "Line Breaks Inside Cells" begin
    data = [
        "This line contains\nthe velocity [m/s]" 10.0
        "This line contains\nthe acceleration [m/s^2]" 1.0
        "This line contains\nthe time from the\nbeginning of the simulation" 10
    ]

    column_labels = ["Information", "Value"]

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

    result = pretty_table(
        String,
        data;
        column_labels,
        line_breaks = true
    )
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
        alignment = :c,
        column_labels,
        line_breaks = true
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
        alignment = :l,
        column_labels,
        line_breaks = true
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

    result = pretty_table(
        String,
        data;
        column_labels
    )
    @test result == expected
end

@testset "Auto wrapping" begin
    table = [
        1 """Ouviram do Ipiranga as margens plácidas
             De um povo heróico o brado retumbante,
             E o sol da Liberdade, em raios fúlgidos,
             Brilhou no céu da Pátria nesse instante."""
        2 """Se o penhor dessa igualdade
             Conseguimos conquistar com braço forte,
             Em teu seio, ó Liberdade,
             Desafia o nosso peito a própria morte!"""
        3 """Ó Pátria amada, Idolatrada, Salve! Salve!
             Brasil, um sonho intenso, um raio vívido
             De amor e de esperança à terra desce,
             Se em teu formoso céu, risonho e límpido,"""
    ]

    column_labels = ["Verse Number", "Verse"]

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse Number │                          Verse │
├──────────────┼────────────────────────────────┤
│            1 │ Ouviram do Ipiranga as margens │
│              │                       plácidas │
│              │     De um povo heróico o brado │
│              │                    retumbante, │
│              │ E o sol da Liberdade, em raios │
│              │                      fúlgidos, │
│              │ Brilhou no céu da Pátria nesse │
│              │                      instante. │
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
│              │ De amor e de esperança à terra │
│              │                         desce, │
│              │ Se em teu formoso céu, risonho │
│              │                     e límpido, │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String,
        table;
        auto_wrap                = true,
        column_labels            = column_labels,
        fixed_data_column_widths = [0, 30],
        line_breaks              = true,
        table_format             = TextTableFormat(; @text__all_horizontal_lines)
    )

    @test result == expected

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse Number │             Verse              │
├──────────────┼────────────────────────────────┤
│      1       │ Ouviram do Ipiranga as margens │
│              │            plácidas            │
│              │   De um povo heróico o brado   │
│              │          retumbante,           │
│              │ E o sol da Liberdade, em raios │
│              │           fúlgidos,            │
│              │ Brilhou no céu da Pátria nesse │
│              │           instante.            │
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
│              │ De amor e de esperança à terra │
│              │             desce,             │
│              │ Se em teu formoso céu, risonho │
│              │           e límpido,           │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String,
        table;
        alignment                = :c,
        auto_wrap                = true,
        column_labels            = column_labels,
        fixed_data_column_widths = [-1, 30],
        line_breaks              = true,
        table_format             = TextTableFormat(; @text__all_horizontal_lines)
    )

    @test result == expected

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse Number │                          Verse │
├──────────────┼────────────────────────────────┤
│            1 │ Ouviram do Ipiranga as margens │
│              │                       plácidas │
│              │     De um povo heróico o brado │
│              │                    retumbante, │
│              │ E o sol da Liberdade, em raios │
│              │                      fúlgidos, │
│              │ Brilhou no céu da Pátria nesse │
│              │                      instante. │
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
│              │ De amor e de esperança à terra │
│              │                         desce, │
│              │ Se em teu formoso céu, risonho │
│              │                     e límpido, │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String,
        table;
        alignment                = :r,
        auto_wrap                = true,
        column_labels            = column_labels,
        fixed_data_column_widths = [-1, 30],
        line_breaks              = true,
        table_format             = TextTableFormat(; @text__all_horizontal_lines)
    )

    @test result == expected

    # -- Test with additional rows ---------------------------------------------------------

    expected = """
┌─────┬──────────┬──────────────┬────────────────────────────────┐
│ Row │    Verso │ Verse Number │ Verse                          │
├─────┼──────────┼──────────────┼────────────────────────────────┤
│   1 │ Primeiro │ 1            │ Ouviram do Ipiranga as margens │
│     │          │              │ plácidas                       │
│     │          │              │ De um povo heróico o brado     │
│     │          │              │ retumbante,                    │
│     │          │              │ E o sol da Liberdade, em raios │
│     │          │              │ fúlgidos,                      │
│     │          │              │ Brilhou no céu da Pátria nesse │
│     │          │              │ instante.                      │
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
│     │          │              │ De amor e de esperança à terra │
│     │          │              │ desce,                         │
│     │          │              │ Se em teu formoso céu, risonho │
│     │          │              │ e límpido,                     │
└─────┴──────────┴──────────────┴────────────────────────────────┘
"""

    result = pretty_table(
        String, table;
        alignment                = :l,
        auto_wrap                = true,
        column_labels            = column_labels,
        fixed_data_column_widths = [-1, 30],
        line_breaks              = true,
        row_labels               = ["Primeiro", "Segundo", "Terceiro"],
        show_row_number_column   = true,
        stubhead_label           = "Verso",
        table_format             = TextTableFormat(; @text__all_horizontal_lines),
    )

    @test result == expected
end

