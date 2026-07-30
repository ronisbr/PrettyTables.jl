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
