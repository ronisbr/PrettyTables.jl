## Description #############################################################################
#
# LaTeX Back End: Test showing all the available fields.
#
############################################################################################


@testset "All Available Fields" verbose = true begin
    matrix = [(i, j) for i in 1:3, j in 1:3]

    expected = """
\\begin{tabular}{|r|r|r|r|r|}
  \\multicolumn{5}{@{}c@{}}{\\textbf{\\large{Table Title}}} \\\\
  \\multicolumn{5}{@{}c@{}}{\\textit{Table Subtitle}} \\\\
  \\hline
  \\textbf{Row} & \\textbf{Rows} & \\textbf{Col. 1} & \\multicolumn{2}{@{}c|@{}}{\\textbf{Merged Column}\$^{1}\$} \\\\
  \\cline{4-5}
   &  & \\textit{1} & \\textit{2} & \\textit{3} \\\\
  \\hline
  1 & \\textbf{Row 1} & (1, 1) & (1, 2) & (1, 3) \\\\
  \\hline
  \\multicolumn{5}{|l|}{\\textbf{Row Group}} \\\\
  \\hline
  2 & \\textbf{Row 2} & (2, 1) & (2, 2)\$^{2}\$ & (2, 3) \\\\
  3 & \\textbf{Row 3} & (3, 1) & (3, 2) & (3, 3) \\\\
  \\hline
   & \\textbf{Summary 1} & 10 & 20 & 30 \\\\
   & \\textbf{Summary 2} & 20 & 40 & 60 \\\\
  \\hline
  \\multicolumn{5}{@{}l@{}}{\\small{\$^{1}\$Footnote in column label}} \\\\
  \\multicolumn{5}{@{}l@{}}{\\small{\$^{2}\$Footnote in data}} \\\\
  \\multicolumn{5}{@{}l@{}}{\\textit{\\small{Source Notes}}} \\\\
\\end{tabular}
"""

    result = pretty_table(
        String,
        matrix;
        backend = :latex,
        column_labels = [["Col. $i" for i in 1:3], ["$i" for i in 1:3]],
        footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
        merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
        row_group_labels = [2 => "Row Group"],
        row_labels = ["Row $i" for i in 1:5],
        show_row_number_column = true,
        source_notes = "Source Notes",
        stubhead_label = "Rows",
        subtitle = "Table Subtitle",
        summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
        title = "Table Title",
    )

    @test result == expected
end
