# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#    Tests of row name column.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Show row names" begin
    expected = """
\\begin{table}
  \\begin{tabular}{rrrrr}
    \\hline\\hline
     & \\textbf{C1} & \\textbf{C2} & \\textbf{C3} & \\textbf{C4} \\\\
     & \\texttt{Int} & \\texttt{Bool} & \\texttt{Float} & \\texttt{Hex} \\\\\\hline
    Row 1 & 1 & false & 1.0 & 1 \\\\
    Row 2 & 2 & true & 2.0 & 2 \\\\
    Row 3 & 3 & false & 3.0 & 3 \\\\
    Row 4 & 4 & true & 4.0 & 4 \\\\
    Row 5 & 5 & false & 5.0 & 5 \\\\
    Row 6 & 6 & true & 6.0 & 6 \\\\\\hline\\hline
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:latex),
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        row_names = ["Row $i" for i in 1:6]
    )

    @test result == expected

    expected = """
\\begin{table}
  \\begin{tabular}{rrrrr}
    \\hline\\hline
    \\textbf{Row names} & \\textbf{C1} & \\textbf{C2} & \\textbf{C3} & \\textbf{C4} \\\\
     & \\texttt{Int} & \\texttt{Bool} & \\texttt{Float} & \\texttt{Hex} \\\\\\hline
    Row 1 & 1 & false & 1.0 & 1 \\\\
    Row 2 & 2 & true & 2.0 & 2 \\\\
    Row 3 & 3 & false & 3.0 & 3 \\\\
    Row 4 & 4 & true & 4.0 & 4 \\\\
    Row 5 & 5 & false & 5.0 & 5 \\\\
    Row 6 & 6 & true & 6.0 & 6 \\\\\\hline\\hline
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:latex),
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row names"
    )

    @test result == expected

    expected = """
\\begin{table}
  \\begin{tabular}{rcrrrr}
    \\hline\\hline
    \\textbf{Row} & \\textbf{Row names} & \\textbf{C1} & \\textbf{C2} & \\textbf{C3} & \\textbf{C4} \\\\
     &  & \\texttt{Int} & \\texttt{Bool} & \\texttt{Float} & \\texttt{Hex} \\\\\\hline
    1 & Row 1 & 1 & false & 1.0 & 1 \\\\
    2 & Row 2 & 2 & true & 2.0 & 2 \\\\
    3 & Row 3 & 3 & false & 3.0 & 3 \\\\
    4 & Row 4 & 4 & true & 4.0 & 4 \\\\
    5 & Row 5 & 5 & false & 5.0 & 5 \\\\
    6 & Row 6 & 6 & true & 6.0 & 6 \\\\\\hline\\hline
  \\end{tabular}
\\end{table}
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:latex),
        header = (
            ["C1",  "C2",   "C3",    "C4"],
            ["Int", "Bool", "Float", "Hex"]
        ),
        row_names = ["Row $i" for i in 1:6],
        row_name_column_title = "Row names",
        row_name_alignment = :c,
        show_row_number = true
    )

    @test result == expected
end
