## Description #############################################################################
#
# Tests related with cropping.
#
############################################################################################

@testset "Cropping" begin
    matrix = [(i, j) for i in 1:7, j in 1:7]
    header = (
        ["Column $i" for i in 1:7],
        ["C$i" for i in 1:7]
    )

    expected = """
\\begin{tabular}{rrrc}
  \\hline
  \\textbf{Column 1} & \\textbf{Column 2} & \\textbf{Column 3} & \$\\cdots\$ \\\\
  \\texttt{C1} & \\texttt{C2} & \\texttt{C3} & \$\\cdots\$ \\\\\\hline
  (1, 1) & (1, 2) & (1, 3) & \$\\cdots\$ \\\\
  (2, 1) & (2, 2) & (2, 3) & \$\\cdots\$ \\\\
  (3, 1) & (3, 2) & (3, 3) & \$\\cdots\$ \\\\
  \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\ddots\$ \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:latex),
        header  = header,
        max_num_of_rows = 3,
        max_num_of_columns = 3
    )
    @test result == expected

    expected = """
\\begin{tabular}{rrrrrrr}
  \\hline
  \\textbf{Column 1} & \\textbf{Column 2} & \\textbf{Column 3} & \\textbf{Column 4} & \\textbf{Column 5} & \\textbf{Column 6} & \\textbf{Column 7} \\\\
  \\texttt{C1} & \\texttt{C2} & \\texttt{C3} & \\texttt{C4} & \\texttt{C5} & \\texttt{C6} & \\texttt{C7} \\\\\\hline
  (1, 1) & (1, 2) & (1, 3) & (1, 4) & (1, 5) & (1, 6) & (1, 7) \\\\
  (2, 1) & (2, 2) & (2, 3) & (2, 4) & (2, 5) & (2, 6) & (2, 7) \\\\
  (3, 1) & (3, 2) & (3, 3) & (3, 4) & (3, 5) & (3, 6) & (3, 7) \\\\
  \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:latex),
        header  = header,
        max_num_of_rows = 3
    )
    @test result == expected

    expected = """
\\begin{tabular}{rrrc}
  \\hline
  \\textbf{Column 1} & \\textbf{Column 2} & \\textbf{Column 3} & \$\\cdots\$ \\\\
  \\texttt{C1} & \\texttt{C2} & \\texttt{C3} & \$\\cdots\$ \\\\\\hline
  (1, 1) & (1, 2) & (1, 3) & \$\\cdots\$ \\\\
  (2, 1) & (2, 2) & (2, 3) & \$\\cdots\$ \\\\
  (3, 1) & (3, 2) & (3, 3) & \$\\cdots\$ \\\\
  (4, 1) & (4, 2) & (4, 3) & \$\\cdots\$ \\\\
  (5, 1) & (5, 2) & (5, 3) & \$\\cdots\$ \\\\
  (6, 1) & (6, 2) & (6, 3) & \$\\cdots\$ \\\\
  (7, 1) & (7, 2) & (7, 3) & \$\\cdots\$ \\\\\\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:latex),
        header  = header,
        max_num_of_columns = 3
    )
    @test result == expected
end
