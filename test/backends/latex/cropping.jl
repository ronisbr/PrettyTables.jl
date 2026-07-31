## Description #############################################################################
#
# LaTeX Back End: Tests related to table cropping.
#
############################################################################################

@testset "Table Cropping" verbose = true begin
    matrix = [(i, j) for i in 1:100, j in 1:100]

    @testset "Bottom Cropping" begin
        expected = """
\\begin{tabular}{|r|r|r|c|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \$\\cdots\$ \\\\
  \\hline
  (1, 1) & (1, 2) & (1, 3) & \$\\cdots\$ \\\\
  (2, 1) & (2, 2) & (2, 3) & \$\\cdots\$ \\\\
  \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\ddots\$ \\\\
  \\hline
  \\multicolumn{4}{r@{}}{\\textit{\\small{97 columns and 98 rows omitted}}}
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
        )

        @test result == expected
    end

    @testset "Middle Cropping" begin
        expected = """
\\begin{tabular}{|r|r|r|c|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \$\\cdots\$ \\\\
  \\hline
  (1, 1) & (1, 2) & (1, 3) & \$\\cdots\$ \\\\
  \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\ddots\$ \\\\
  (100, 1) & (100, 2) & (100, 3) & \$\\cdots\$ \\\\
  \\hline
  \\multicolumn{4}{r@{}}{\\textit{\\small{97 columns and 98 rows omitted}}}
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            vertical_crop_mode = :middle,
        )

        @test result == expected
    end

    @testset "Omitted Cell Summary" begin
        expected = """
\\begin{tabular}{|r|r|r|c|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \$\\cdots\$ \\\\
  \\hline
  (1, 1) & (1, 2) & (1, 3) & \$\\cdots\$ \\\\
  (2, 1) & (2, 2) & (2, 3) & \$\\cdots\$ \\\\
  \$\\vdots\$ & \$\\vdots\$ & \$\\vdots\$ & \$\\ddots\$ \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            show_omitted_cell_summary = false,
        )

        @test result == expected
    end

    @testset "Omitted Cell Summary With Table Footer" begin
        # The omitted cell summary row must be terminated with `\\\\` when the table footer
        # is printed afterward. Otherwise, the footer cells would be rendered in the same
        # tabular row, leading to an invalid LaTeX document.
        expected = """
\\begin{tabular}{|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} \\\\
  \\hline
  1\$^{1}\$ & 2 \\\\
  \$\\vdots\$ & \$\\vdots\$ \\\\
  \\hline
  \\multicolumn{2}{r@{}}{\\textit{\\small{2 rows omitted}}} \\\\
  \\multicolumn{2}{@{}l@{}}{\\small{\$^{1}\$Note}} \\\\
\\end{tabular}
"""

        result = pretty_table(
            String,
            [1 2; 3 4; 5 6];
            backend = :latex,
            footnotes = [(:data, 1, 1) => "Note"],
            maximum_number_of_rows = 1,
        )

        @test result == expected
    end
end
