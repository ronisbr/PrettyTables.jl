## Description #############################################################################
#
# Markdown Back End: Test footnotes.
#
############################################################################################

@testset "Footnotes at Summary Row Labels" begin
    expected = """
|             | **Col. 1** | **Col. 2** |
|------------:|-----------:|-----------:|
|             |          1 |          2 |
|             |          3 |          4 |
| ─────────── | ────────── | ────────── |
|     **Sum** |          4 |          6 |
| **Max[^1]** |          3 |          4 |

[^1]: Footnote in summary row label
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
        backend = :markdown,
        footnotes = [(:summary_row_label, 2, 0) => "Footnote in summary row label"],
        summary_rows = [(data, i) -> sum(data[:, i]), (data, i) -> maximum(data[:, i])],
        summary_row_labels = ["Sum", "Max"],
    )

    @test result == expected
end

@testset "Footnotes in the Title, Subtitle, and Row Numbers" begin
    expected = """
# T[^1]

## S[^2]

|   **Row** | **Col. 1** | **Col. 2** |
|----------:|-----------:|-----------:|
|     **1** |      1[^4] |          2 |
| **2**[^3] |          3 |          4 |

[^1]: a
[^2]: b
[^3]: c
[^4]: d
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
        backend = :markdown,
        title = "T",
        subtitle = "S",
        show_row_number_column = true,
        footnotes = [
            (:title, 1, 1) => "a",
            (:subtitle, 1, 1) => "b",
            (:row_number, 2, 1) => "c",
            (:data, 1, 1) => "d",
        ],
    )

    @test result == expected
end
