## Description #############################################################################
#
# LaTeX Back End: Test of vertical lines.
#
############################################################################################

@testset "Line After the Last Printed Data Column" begin
    # The line after the last printed data column is only controlled by
    # `vertical_line_after_data_columns`, even if this column is in
    # `vertical_lines_at_data_columns` and even if the table is horizontally cropped.
    expected = """
\\begin{tabular}{|r|r|r}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} \\\\
  \\hline
  1 & 2 & 3 \\\\
  4 & 5 & 6 \\\\
  \\hline
\\end{tabular}
"""

    result = pretty_table(
        String,
        [1 2 3; 4 5 6];
        backend = :latex,
        table_format = LatexTableFormat(;
            vertical_lines_at_data_columns = :all, vertical_line_after_data_columns = false
        ),
    )

    @test result == expected

    expected = """
\\begin{tabular}{|r|rc|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \$\\cdots\$ \\\\
  \\hline
  1 & 2 & \$\\cdots\$ \\\\
  4 & 5 & \$\\cdots\$ \\\\
  \\hline
  \\multicolumn{3}{r@{}}{\\textit{\\small{1 column omitted}}}
\\end{tabular}
"""

    result = pretty_table(
        String,
        [1 2 3; 4 5 6];
        backend = :latex,
        maximum_number_of_columns = 2,
        table_format = LatexTableFormat(;
            vertical_lines_at_data_columns = :all, vertical_line_after_data_columns = false
        ),
    )

    @test result == expected
end
