## Description #############################################################################
#
# Markdown Back End: Tests related to special cells.
#
############################################################################################

@testset "Special Cells" verbose = true begin
    @testset "Markdown Code Espaping" begin
        matrix = ["**Bold**", "~~Strike~~", "`Code`"]

        expected = """
|     **Col. 1** |
|---------------:|
|   \\*\\*Bold\\*\\* |
| \\~\\~Strike\\~\\~ |
|       \\`Code\\` |
"""

        result = pretty_table(String, matrix; backend = :markdown)

        @test result == expected

        result = pretty_table(String, matrix; backend = :markdown, renderer = :show)

        @test result == expected
    end

    @testset "Markdown Cells" begin
        matrix = ["**Bold**", "~~Strike~~", md"`Code`"]

        expected = """
|     **Col. 1** |
|---------------:|
|   \\*\\*Bold\\*\\* |
| \\~\\~Strike\\~\\~ |
|         `Code` |
"""

        result = pretty_table(String, matrix; backend = :markdown)

        @test result == expected

        result = pretty_table(String, matrix; backend = :markdown, renderer = :show)

        @test result == expected
    end

    @testset "Markdown Cells With Multiple Blocks" begin
        # A table cell cannot contain line breaks. Hence, they must become spaces, keeping
        # the words of different lines apart, or `<br>` if `line_breaks` is `true`.
        cell = md"""
            First **paragraph**.

            Second paragraph.
            """

        result = pretty_table(String, [cell;;]; backend = :markdown)
        @test occursin("| First **paragraph**. Second paragraph. |", result)

        result = pretty_table(String, [cell;;]; backend = :markdown, line_breaks = true)
        @test occursin("| First **paragraph**.<br><br>Second paragraph. |", result)
    end

    @testset "Allow Markdown in Cells" begin
        matrix = ["**Bold**", "~~Strike~~", md"`Code`"]

        expected = """
| **Col. 1** |
|-----------:|
|   **Bold** |
| ~~Strike~~ |
|     `Code` |
"""

        result = pretty_table(
            String, matrix; backend = :markdown, allow_markdown_in_cells = true
        )

        @test result == expected

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            allow_markdown_in_cells = true,
            renderer = :show,
        )

        @test result == expected
    end

    @testset "Line Breaks" begin
        matrix = ["First Line\nSecond Line" "Third Line\nFourth Line"]

        expected = """
|              **Col. 1** |              **Col. 2** |
|------------------------:|------------------------:|
| First Line\\nSecond Line | Third Line\\nFourth Line |
"""

        result = pretty_table(String, matrix; backend = :markdown)

        @test result == expected

        result = pretty_table(String, matrix; backend = :markdown, renderer = :show)

        @test result == expected

        expected = """
|                **Col. 1** |                **Col. 2** |
|--------------------------:|--------------------------:|
| First Line<br>Second Line | Third Line<br>Fourth Line |
"""

        result = pretty_table(String, matrix; backend = :markdown, line_breaks = true)

        @test result == expected

        result = pretty_table(
            String, matrix; backend = :markdown, line_breaks = true, renderer = :show
        )

        @test result == expected
    end

    @testset "Undefined Cells" begin
        v    = Vector{Any}(undef, 5)
        v[1] = undef
        v[2] = "String"
        v[5] = π

        expected = """
|         **Col. 1** |
|-------------------:|
| UndefInitializer() |
|             String |
|             #undef |
|             #undef |
|                  π |
"""

        result = pretty_table(String, v; backend = :markdown)

        @test result == expected

        result = pretty_table(String, v; backend = :markdown, renderer = :show)

        @test result == expected
    end

    @testset "Escaping of Markdown Metacharacters" begin
        # `\` must be escaped first. Otherwise, the backslash this function inserts for, say,
        # `*` would sit next to a user backslash, `\\` would render as a literal backslash,
        # and the `*` would start an emphasis span.
        #
        # `[` and `]` are critical because the back end itself emits `[^N]` footnote
        # references, so unescaped user data could collide with the generated markup. `<` and
        # `>` would otherwise be interpreted as raw HTML or as an autolink.
        matrix = ["a\\*b" "c[^1]d" "e<b>f" "g|h" "i*j" "k_l" "m~n" "o`p"]

        result = pretty_table(String, matrix; backend = :markdown)

        @test occursin("a\\\\\\*b", result)
        @test occursin("c\\[^1\\]d", result)
        @test occursin("e\\<b\\>f", result)
        @test occursin("g\\|h", result)
        @test occursin("i\\*j", result)
        @test occursin("k\\_l", result)
        @test occursin("m\\~n", result)
        @test occursin("o\\`p", result)
    end

    @testset "Sentinels Are Not Escaped" begin
        # `#` must not be escaped, otherwise the sentinels this package emits would be
        # corrupted.
        v    = Vector{Any}(undef, 1)
        result = pretty_table(String, v; backend = :markdown)

        @test occursin("#undef", result)
        @test !occursin("\\#undef", result)
    end

    @testset "Line Breaks Still Emit <br>" begin
        # The `<br>` the back end emits for line breaks is produced *after* the escaping,
        # hence escaping `<` and `>` at the source level must not affect it.
        result = pretty_table(String, ["a\nb"]; backend = :markdown, line_breaks = true)

        @test occursin("a<br>b", result)

        # Without `line_breaks`, the newline must be escaped instead.
        result = pretty_table(String, ["a\nb"]; backend = :markdown, line_breaks = false)

        @test occursin("a\\nb", result)
    end
end

@testset "Merged Column Labels With Special Cells" begin
    # The content of a merged column label must be rendered like any other cell.
    result = pretty_table(
        String,
        [1 2];
        backend = :markdown,
        column_labels = [[MultiColumn(2, md"*x*")]],
    )

    @test occursin("*x*", result)
    @test !occursin("\\*", result)
end

@testset "Escaping of the Row Group Labels" begin
    # The row group labels must always be escaped. Otherwise, a `|` would add a column.
    expected = """
|  **Col. 1** | **Col. 2** |
|------------:|-----------:|
|           1 |          2 |
| **G\\|H\\_1** | ────────── |
|           3 |          4 |
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
        allow_markdown_in_cells = true,
        backend = :markdown,
        row_group_labels = [2 => "G|H_1"],
    )

    @test result == expected
end

@testset "Escaping of the Stubhead and Row Number Labels" begin
    expected = """
| **R\\|N** | **S\\_T** | **Col. 1** | **Col. 2** |
|---------:|---------:|-----------:|-----------:|
|    **1** |    **a** |          1 |          2 |
"""

    result = pretty_table(
        String,
        [1 2];
        backend = :markdown,
        row_labels = ["a"],
        row_number_column_label = "R|N",
        show_row_number_column = true,
        stubhead_label = "S_T",
    )

    @test result == expected
end

@testset "Lower Column Label Rows Under Merged Cells" begin
    # Markdown does not support merged cells. Hence, only the lines hidden by a merged cell
    # must be filled, keeping the other lines of the column.
    expected = """
| **M**<br>`a` | ───<br>`b` | **C**<br>`c` |
|-------------:|-----------:|-------------:|
|            1 |          2 |            3 |
"""

    result = pretty_table(
        String,
        [1 2 3];
        backend = :markdown,
        column_labels = [[MultiColumn(2, "M"), "C"], ["a", "b", "c"]],
    )

    @test result == expected

    # If all the lines of a column are hidden, the entire cell is filled.
    expected = """
| **M**<br>`N` | ────── | **C**<br>`c` |
|-------------:|-------:|-------------:|
|            1 |      2 |            3 |
"""

    result = pretty_table(
        String,
        [1 2 3];
        backend = :markdown,
        column_labels = [[MultiColumn(2, "M"), "C"], [MultiColumn(2, "N"), "c"]],
    )

    @test result == expected
end

@testset "Code Spans" begin
    # A code span renders its content verbatim. Hence, the Markdown characters must not be
    # escaped inside it, except the pipe, and the delimiter must be longer than any
    # sequence of backticks in the content.
    expected = """
| **A**<br>`x_1*`[^1] | **B**<br>`a\\|b` | **C**<br>```c`d``e``` | **D**<br>`` `x\\\\ `` |
|--------------------:|----------------:|----------------------:|--------------------:|
|                   1 |               2 |                     3 |                   4 |

[^1]: F
"""

    result = pretty_table(
        String,
        [1 2 3 4];
        backend = :markdown,
        column_labels = [["A", "B", "C", "D"], ["x_1*", "a|b", "c`d``e", "`x\\\\"]],
        footnotes = [(:column_label, 2, 1) => "F"],
    )

    @test result == expected
end
