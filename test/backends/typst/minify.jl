## Description #############################################################################
#
# Typst Back End: Test with minify option.
#
############################################################################################

@testset "Minify" verbose = true begin
    matrix  = [(i, j) for i in 1:200, j in 1:200]
    backend = :typst

    expected = """"
#{
  table(
    align: (right, right, right, right, center,),
    columns: (auto, auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Row]], [], [#text(weight: "bold",)[Col. 1]], [#text(weight: "bold",)[Col. 2]], [⋯],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold",)[1]], [#text(weight: "bold",)[Row 1]#super[1]], [(1, 1)], [(1, 2)], [⋯],
    // -- Data: Row 2 ----------------------------------------------------------------------
    [#text(weight: "bold",)[2]], [#text(weight: "bold",)[Row 2]], [(2, 1)], [(2, 2)], [⋯],
    // -- Continuation Row -----------------------------------------------------------------
    [⋮], [⋮], [⋮], [⋮], [⋱],
    // -- Summary Row: Row 1 ---------------------------------------------------------------
    [], [#text(weight: "bold",)[Summary 1]], [1], [2], [⋯],
    // -- Omitted Cell Summary -------------------------------------------------------------
    table.cell(align: right, colspan: 5, inset: (right: 0pt), stroke: none,)[#text(fill: gray, size: 0.9em, style: "italic",)[198 columns and 198 rows omitted]],
    // -- Table Footer: Footnote 1 ---------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[#super[1]#text(size: 0.9em,)[This is the row label column.]],
    // -- Table Footer: Source Notes -------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[#text(fill: gray, size: 0.9em, style: "italic",)[This is a source note.]],
  )
}
"""

    result = pretty_table(
        String,
        matrix;
        backend,
        footnotes = [(:row_label, 1, 1) => "This is the row label column."],
        maximum_number_of_columns = 2,
        maximum_number_of_rows = 2,
        minify = true,
        row_labels = ["Row $i" for i in 1:size(matrix, 1)],
        show_row_number_column = true,
        source_notes = "This is a source note.",
        summary_rows = [(data, i) -> i],
    )

    expected = """"
#{
  table(
    align: (right, right, right, right, center,),
    columns: (auto, auto, auto, auto, auto,),
    // == Table Header =====================================================================
    table.header(
      // -- Column Labels: Row 1 -----------------------------------------------------------
      [#text(weight: "bold",)[Row]], [], [#text(weight: "bold",)[Col. 1]], [#text(weight: "bold",)[Col. 2]], [⋯],
    ),
    // == Table Body =======================================================================
    // -- Data: Row 1 ----------------------------------------------------------------------
    [#text(weight: "bold",)[1]], [#text(weight: "bold",)[Row 1]#super[1]], [(1, 1)], [(1, 2)], [⋯],
    // -- Continuation Row -----------------------------------------------------------------
    [⋮], [⋮], [⋮], [⋮], [⋱],
    // -- Data: Row 200 --------------------------------------------------------------------
    [#text(weight: "bold",)[200]], [#text(weight: "bold",)[Row 200]], [(200, 1)], [(200, 2)], [⋯],
    // -- Summary Row: Row 1 ---------------------------------------------------------------
    [], [#text(weight: "bold",)[Summary 1]], [1], [2], [⋯],
    // -- Omitted Cell Summary -------------------------------------------------------------
    table.cell(align: right, colspan: 5, inset: (right: 0pt), stroke: none,)[#text(fill: gray, size: 0.9em, style: "italic",)[198 columns and 198 rows omitted]],
    // -- Table Footer: Footnote 1 ---------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[#super[1]#text(size: 0.9em,)[This is the row label column.]],
    // -- Table Footer: Source Notes -------------------------------------------------------
    table.cell(align: left, colspan: 5, inset: (left: 0pt), stroke: none,)[#text(fill: gray, size: 0.9em, style: "italic",)[This is a source note.]],
  )
}
"""

    result = pretty_table(
        String,
        matrix;
        backend,
        footnotes = [(:row_label, 1, 1) => "This is the row label column."],
        maximum_number_of_columns = 2,
        maximum_number_of_rows = 2,
        minify = true,
        row_labels = ["Row $i" for i in 1:size(matrix, 1)],
        show_row_number_column = true,
        source_notes = "This is a source note.",
        summary_rows = [(data, i) -> i],
        vertical_crop_mode = :middle,
    )
end