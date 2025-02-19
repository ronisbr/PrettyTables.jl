## Description #############################################################################
#
# LaTeX Back End: Tests related with the cell alignment.
#
############################################################################################

@testset "Alignment" verbose = true begin
    matrix = [(i, j) for i in 1:5, j in 1:5]

    @testset "Alignment as a Symbol" verbose = true  begin
        expected = """
\\begin{tabular}{|c|c|c|c|c|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} \\\\
  \\hline
  (1, 1) & (1, 2) & (1, 3) & (1, 4) & (1, 5) \\\\
  (2, 1) & (2, 2) & \\multicolumn{1}{|r|}{(2, 3)} & (2, 4) & (2, 5) \\\\
  (3, 1) & (3, 2) & (3, 3) & (3, 4) & (3, 5) \\\\
  (4, 1) & (4, 2) & (4, 3) & (4, 4) & \\multicolumn{1}{|l|}{(4, 5)} \\\\
  (5, 1) & (5, 2) & (5, 3) & (5, 4) & (5, 5) \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            alignment = :c,
            backend = :latex,
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected

        expected = """
\\begin{tabular}{|c|cc|c|c}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} \\\\
  \\hline
  (1, 1) & (1, 2) & (1, 3) & (1, 4) & (1, 5) \\\\
  (2, 1) & (2, 2) & \\multicolumn{1}{r|}{(2, 3)} & (2, 4) & (2, 5) \\\\
  (3, 1) & (3, 2) & (3, 3) & (3, 4) & (3, 5) \\\\
  (4, 1) & (4, 2) & (4, 3) & (4, 4) & \\multicolumn{1}{|l}{(4, 5)} \\\\
  (5, 1) & (5, 2) & (5, 3) & (5, 4) & (5, 5) \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            alignment = :c,
            backend = :latex,
            cell_alignment = [(2, 3) => :r, (4, 5) => :l],
            table_format = LatexTableFormat(
                ;
                right_vertical_lines_at_data_columns = [1, 3, 4],
                vertical_line_after_data_columns = false
            )
        )
    end

    @testset "Alignment as a Vector" verbose = true  begin
        expected = """
\\begin{tabular}{|l|c|r|l|c|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} \\\\
  \\hline
  (1, 1) & (1, 2) & (1, 3) & (1, 4) & (1, 5) \\\\
  (2, 1) & (2, 2) & (2, 3) & (2, 4) & (2, 5) \\\\
  (3, 1) & (3, 2) & (3, 3) & (3, 4) & (3, 5) \\\\
  (4, 1) & (4, 2) & (4, 3) & (4, 4) & \\multicolumn{1}{|l|}{(4, 5)} \\\\
  (5, 1) & (5, 2) & (5, 3) & (5, 4) & (5, 5) \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            alignment = [:l, :c, :r, :l, :c],
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected

        expected = """
\\begin{tabular}{|l|cr|l|c}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} \\\\
  \\hline
  (1, 1) & (1, 2) & (1, 3) & (1, 4) & (1, 5) \\\\
  (2, 1) & (2, 2) & (2, 3) & (2, 4) & (2, 5) \\\\
  (3, 1) & (3, 2) & (3, 3) & (3, 4) & (3, 5) \\\\
  (4, 1) & (4, 2) & (4, 3) & (4, 4) & \\multicolumn{1}{|l}{(4, 5)} \\\\
  (5, 1) & (5, 2) & (5, 3) & (5, 4) & (5, 5) \\\\
  \\hline
\\end{tabular}
"""

        result = pretty_table(
            String,
            matrix;
            backend = :latex,
            alignment = [:l, :c, :r, :l, :c],
            cell_alignment = [(2, 3) => :r, (4, 5) => :l],
            table_format = LatexTableFormat(
                ;
                right_vertical_lines_at_data_columns = [1, 3, 4],
                vertical_line_after_data_columns = false
            )
        )

        @test result == expected
    end
end

