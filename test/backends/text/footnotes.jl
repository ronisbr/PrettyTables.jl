## Description #############################################################################
#
# Text Back End: Test footnotes.
#
############################################################################################

@testset "Footnotes at Summary Row Labels" begin
    expected = """
┌──────┬────────┬────────┐
│      │ Col. 1 │ Col. 2 │
├──────┼────────┼────────┤
│      │      1 │      2 │
│      │      3 │      4 │
├──────┼────────┼────────┤
│  Sum │      4 │      6 │
│ Max¹ │      3 │      4 │
└──────┴────────┴────────┘
¹: Footnote in summary row label
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
        footnotes = [(:summary_row_label, 2, 0) => "Footnote in summary row label"],
        summary_rows = [(data, i) -> sum(data[:, i]), (data, i) -> maximum(data[:, i])],
        summary_row_labels = ["Sum", "Max"],
    )

    @test result == expected
end

@testset "Footnotes in the Title, Subtitle, and Row Numbers" begin
    expected = """
           T¹
           S²
┌─────┬────────┬────────┐
│ Row │ Col. 1 │ Col. 2 │
├─────┼────────┼────────┤
│   1 │     1⁴ │      2 │
│  2³ │      3 │      4 │
└─────┴────────┴────────┘
¹: a
²: b
³: c
⁴: d
"""

    result = pretty_table(
        String,
        [1 2; 3 4];
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
