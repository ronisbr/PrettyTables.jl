## Description #############################################################################
#
# Test pre-defined formatters.
#
############################################################################################

data = Any[
    1    false      1.0     0x01
    2     true      2.0     0x02
    3    false      3.0     0x03
    4     true      4.0     0x04
    5    false      5.0     0x05
    6     true      6.0     0x06
]

@testset "fmt__printf" begin
    expected = """
        ┌──────────┬──────────┬──────────┬──────────┐
        │   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │
        ├──────────┼──────────┼──────────┼──────────┤
        │    1.000 │    0.000 │    1.000 │    1.000 │
        │    2.000 │    1.000 │    2.000 │    2.000 │
        │    3.000 │    0.000 │    3.000 │    3.000 │
        │    4.000 │    1.000 │    4.000 │    4.000 │
        │    5.000 │    0.000 │    5.000 │    5.000 │
        │    6.000 │    1.000 │    6.000 │    6.000 │
        └──────────┴──────────┴──────────┴──────────┘
        """

    result = pretty_table(
        String,
        data;
        formatters = [fmt__printf("%8.3f")]
    )
    @test result == expected

    expected = """
        ┌──────────┬────────┬────────┬──────────┐
        │   Col. 1 │ Col. 2 │ Col. 3 │   Col. 4 │
        ├──────────┼────────┼────────┼──────────┤
        │    1.000 │  false │    1.0 │    1.000 │
        │    2.000 │   true │    2.0 │    2.000 │
        │    3.000 │  false │    3.0 │    3.000 │
        │    4.000 │   true │    4.0 │    4.000 │
        │    5.000 │  false │    5.0 │    5.000 │
        │    6.000 │   true │    6.0 │    6.000 │
        └──────────┴────────┴────────┴──────────┘
        """

    result = pretty_table(
        String,
        data;
        formatters = [fmt__printf("%8.3f",[1, 4])]
    )
    @test result == expected

    expected = """
        ┌──────────┬────────┬────────┬──────────┐
        │   Col. 1 │ Col. 2 │ Col. 3 │   Col. 4 │
        ├──────────┼────────┼────────┼──────────┤
        │     1.00 │  false │    1.0 │   1.0000 │
        │     2.00 │   true │    2.0 │   2.0000 │
        │     3.00 │  false │    3.0 │   3.0000 │
        │     4.00 │   true │    4.0 │   4.0000 │
        │     5.00 │  false │    5.0 │   5.0000 │
        │     6.00 │   true │    6.0 │   6.0000 │
        └──────────┴────────┴────────┴──────────┘
        """
    result = pretty_table(
        String,
        data;
        formatters = [
            fmt__printf("%8.2f", [1]),
            fmt__printf("%8.4f", [4])
        ]
    )
    @test result == expected
end

@testset "fmt__round" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│    1.0 │    0.0 │    1.0 │    1.0 │
│    2.0 │    1.0 │    2.0 │    2.0 │
│    3.0 │    0.0 │    3.0 │    3.0 │
│    4.0 │    1.0 │    4.0 │    4.0 │
│    5.0 │    0.0 │    5.0 │    5.0 │
│    6.0 │    1.0 │    6.0 │    6.0 │
└────────┴────────┴────────┴────────┘
"""

    result = pretty_table(
        String,
        data;
        formatters = [fmt__round(1)]
    )
    @test result == expected

    expected = """
        ┌────────┬────────┬────────┬────────┐
        │ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
        ├────────┼────────┼────────┼────────┤
        │    1.0 │  false │    1.0 │      1 │
        │    2.0 │   true │    2.0 │      2 │
        │    3.0 │  false │    3.0 │      3 │
        │    4.0 │   true │    4.0 │      4 │
        │    5.0 │  false │    5.0 │      5 │
        │    6.0 │   true │    6.0 │      6 │
        └────────┴────────┴────────┴────────┘
        """

    result = pretty_table(
        String,
        data;
        formatters = [fmt__round(1, [3, 1])]
    )
    @test result == expected

    # Check if `fmt__round` correctly avoid unsupported types.

    v = ["Test", :symbol, 'a', π, exp(1), log(19)]

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│   Test │
│ symbol │
│      a │
│   3.14 │
│   2.72 │
│   2.94 │
└────────┘
"""

    result = pretty_table(
        String,
        v;
        formatters = [fmt__round(2)]
    )
    @test result == expected

    expected = """
┌─────────┐
│  Col. 1 │
├─────────┤
│    Test │
│ :symbol │
│     'a' │
│    3.14 │
│    2.72 │
│    2.94 │
└─────────┘
"""

    result = pretty_table(
        String,
        v;
        formatters = [fmt__round(2)],
        renderer = :show
    )
    @test result == expected
end

@testset "fmt__latex_sn" begin
    matrix = hcat(
        1:1:11,
        1:1.0:11,
        [10^i for i in -5:1.:5],
        [ i == 5 ? nothing : "Teste" for i in 1:11]
    )

    expected = """
\\begin{tabular}{|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\
  \\hline
  1 & 1 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2 & 0.0001 & Teste \\\\
  3 & 3 & 0.001 & Teste \\\\
  4 & 4 & 0.01 & Teste \\\\
  5 & 5 & 0.1 & nothing \\\\
  6 & 6 & 1 & Teste \\\\
  7 & 7 & \$1 \\cdot 10^{1}\$ & Teste \\\\
  8 & 8 & \$1 \\cdot 10^{2}\$ & Teste \\\\
  9 & 9 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{4}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{5}\$ & Teste \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        formatters = [fmt__latex_sn(1)]
    )
    @test result == expected

    expected = """
\\begin{tabular}{|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\
  \\hline
  1 & 1 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2 & 0.0001 & Teste \\\\
  3 & 3 & 0.001 & Teste \\\\
  4 & 4 & 0.01 & Teste \\\\
  5 & 5 & 0.1 & nothing \\\\
  6 & 6 & 1 & Teste \\\\
  7 & 7 & 10 & Teste \\\\
  8 & 8 & \$1 \\cdot 10^{2}\$ & Teste \\\\
  9 & 9 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  10 & 10 & \$1 \\cdot 10^{4}\$ & Teste \\\\
  11 & 11 & \$1 \\cdot 10^{5}\$ & Teste \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        formatters = [fmt__latex_sn(2)]
    )
    @test result == expected

    expected = """
\\begin{tabular}{|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\
  \\hline
  1 & 1.0 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2.0 & 0.0001 & Teste \\\\
  3 & 3.0 & 0.001 & Teste \\\\
  4 & 4.0 & 0.01 & Teste \\\\
  5 & 5.0 & 0.1 & nothing \\\\
  6 & 6.0 & 1 & Teste \\\\
  7 & 7.0 & \$1 \\cdot 10^{1}\$ & Teste \\\\
  8 & 8.0 & \$1 \\cdot 10^{2}\$ & Teste \\\\
  9 & 9.0 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 10.0 & \$1 \\cdot 10^{4}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 11.0 & \$1 \\cdot 10^{5}\$ & Teste \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        formatters = [fmt__latex_sn(1, [1, 3])]
    )
    @test result == expected

    expected = """
\\begin{tabular}{|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} \\\\
  \\hline
  1 & 1.0 & \$1 \\cdot 10^{-5}\$ & Teste \\\\
  2 & 2.0 & 0.0001 & Teste \\\\
  3 & 3.0 & 0.001 & Teste \\\\
  4 & 4.0 & 0.01 & Teste \\\\
  5 & 5.0 & 0.1 & nothing \\\\
  6 & 6.0 & 1 & Teste \\\\
  7 & 7.0 & 10 & Teste \\\\
  8 & 8.0 & 100 & Teste \\\\
  9 & 9.0 & \$1 \\cdot 10^{3}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 10.0 & \$1 \\cdot 10^{4}\$ & Teste \\\\
  \$1 \\cdot 10^{1}\$ & 11.0 & \$1 \\cdot 10^{5}\$ & Teste \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        formatters = [fmt__latex_sn(1, [1]), fmt__latex_sn(3, [3])]
    )
    @test result == expected
end
