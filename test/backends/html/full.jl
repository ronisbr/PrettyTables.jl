## Description #############################################################################
#
# HTML Back End: Test showing all the available fields.
#
############################################################################################

@testset "All Available Fields" verbose = true begin
    matrix = [(i, j) for i in 1:4, j in 1:4]

    @testset "Without Cropping" begin
        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "title">
      <td colspan = "6" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: x-large; font-weight: bold; text-align: center;">Table Title</td>
    </tr>
    <tr class = "subtitle">
      <td colspan = "6" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: large; font-style: italic; text-align: center;">Table Subtitle</td>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "border-left: 2px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Row</th>
      <th class = "stubheadLabel" style = "border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Rows</th>
      <th style = "border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th colspan = "2" style = "border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: center;">Merged Column<sup>1</sup></th>
      <th style = "border-right: 2px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Col. 4</th>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></th>
      <th class = "stubheadLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">1</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">2</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">3</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">4</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">1</td>
      <td class = "rowLabel" style = "border-right: 1px solid black; font-weight: bold; text-align: right;">Row 1</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 2)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 3)</td>
      <td style = "border-right: 2px solid black; text-align: right;">(1, 4)</td>
    </tr>
    <tr class = "rowGroupLabel">
      <td colspan = "6" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; border-top: 1px solid black; font-weight: bold; text-align: left;">Row Group</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">2</td>
      <td class = "rowLabel" style = "border-right: 1px solid black; font-weight: bold; text-align: right;">Row 2</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 2)<sup>2</sup></td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 3)</td>
      <td style = "border-right: 2px solid black; text-align: right;">(2, 4)</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">3</td>
      <td class = "rowLabel" style = "border-right: 1px solid black; font-weight: bold; text-align: right;">Row 3</td>
      <td style = "border-right: 1px solid black; text-align: right;">(3, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(3, 2)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(3, 3)</td>
      <td style = "border-right: 2px solid black; text-align: right;">(3, 4)</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">4</td>
      <td class = "rowLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Row 4</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">(4, 1)</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">(4, 2)</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">(4, 3)</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">(4, 4)</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td class = "summaryRowLabel" style = "border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Summary 1</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">10</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">20</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">30</td>
      <td style = "border-right: 2px solid black; border-top: 1px solid black; text-align: right;">40</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td class = "summaryRowLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Summary 2</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">20</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">40</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">60</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">80</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote">
      <td colspan = "6" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: small; text-align: left;"><sup>1</sup> Footnote in column label</td>
    </tr>
    <tr class = "footnote">
      <td colspan = "6" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-size: small; text-align: left;"><sup>2</sup> Footnote in data</td>
    </tr>
    <tr class = "sourceNotes">
      <td colspan = "6" style = "border-left: 2px solid black; border-right: 2px solid black; color: gray; font-size: small; font-style: italic; text-align: left;">Source Notes</td>
    </tr>
  </tfoot>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            column_labels = [["Col. $i" for i in 1:4], ["$i" for i in 1:4]],
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
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

    @testset "With Bottom Cropping" begin
        expected = """
<div>
  <div style = "float: right; font-style: italic;">
    <span>2 columns and 2 rows omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "title">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: x-large; font-weight: bold; text-align: center;">Table Title</td>
    </tr>
    <tr class = "subtitle">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: large; font-style: italic; text-align: center;">Table Subtitle</td>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Row</th>
      <th class = "stubheadLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Rows</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th colspan = "1" style = "border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: center;">Merged Column<sup>1</sup></th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; border-top: 1px solid black;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">1</td>
      <td class = "rowLabel" style = "border-right: 1px solid black; font-weight: bold; text-align: right;">Row 1</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 2)</td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr class = "rowGroupLabel">
      <td colspan = "5" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; border-top: 1px solid black; font-weight: bold; text-align: left;">Row Group</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">2</td>
      <td class = "rowLabel" style = "border-right: 1px solid black; font-weight: bold; text-align: right;">Row 2</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(2, 2)<sup>2</sup></td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black;">&dtdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td class = "summaryRowLabel" style = "border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Summary 1</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">10</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">20</td>
      <td style = "border-right: 2px solid black; border-top: 1px solid black;">&ctdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td class = "summaryRowLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Summary 2</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">20</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">40</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black;">&ctdot;</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: small; text-align: left;"><sup>1</sup> Footnote in column label</td>
    </tr>
    <tr class = "footnote">
      <td colspan = "5" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-size: small; text-align: left;"><sup>2</sup> Footnote in data</td>
    </tr>
    <tr class = "sourceNotes">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; color: gray; font-size: small; font-style: italic; text-align: left;">Source Notes</td>
    </tr>
  </tfoot>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
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

    @testset "With Middle Cropping" begin
        expected = """
<div>
  <div style = "float: right; font-style: italic;">
    <span>2 columns and 2 rows omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "title">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: x-large; font-weight: bold; text-align: center;">Table Title</td>
    </tr>
    <tr class = "subtitle">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: large; font-style: italic; text-align: center;">Table Subtitle</td>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Row</th>
      <th class = "stubheadLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Rows</th>
      <th style = "border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th colspan = "1" style = "border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: center;">Merged Column<sup>1</sup></th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; border-top: 1px solid black;">&ctdot;</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">1</td>
      <td class = "rowLabel" style = "border-right: 1px solid black; font-weight: bold; text-align: right;">Row 1</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 1)</td>
      <td style = "border-right: 1px solid black; text-align: right;">(1, 2)</td>
      <td style = "border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr>
      <td style = "border-left: 2px solid black; border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-right: 1px solid black; text-align: right;">&vellip;</td>
      <td style = "border-right: 2px solid black;">&dtdot;</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">4</td>
      <td class = "rowLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Row 4</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">(4, 1)</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">(4, 2)</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black;">&ctdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "border-left: 2px solid black; border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td class = "summaryRowLabel" style = "border-right: 1px solid black; border-top: 1px solid black; font-weight: bold; text-align: right;">Summary 1</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">10</td>
      <td style = "border-right: 1px solid black; border-top: 1px solid black; text-align: right;">20</td>
      <td style = "border-right: 2px solid black; border-top: 1px solid black;">&ctdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;"></td>
      <td class = "summaryRowLabel" style = "border-bottom: 1px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Summary 2</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">20</td>
      <td style = "border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;">40</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black;">&ctdot;</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; font-size: small; text-align: left;"><sup>1</sup> Footnote in column label</td>
    </tr>
    <tr class = "footnote">
      <td colspan = "5" style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 2px solid black; font-size: small; text-align: left;"><sup>2</sup> Footnote in data</td>
    </tr>
    <tr class = "sourceNotes">
      <td colspan = "5" style = "border-left: 2px solid black; border-right: 2px solid black; color: gray; font-size: small; font-style: italic; text-align: left;">Source Notes</td>
    </tr>
  </tfoot>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            footnotes = [
                (:column_label, 1, 2) => "Footnote in column label",
                (:data, 2, 2) => "Footnote in data",
            ],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            merge_column_label_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
            vertical_crop_mode = :middle,
        )

        @test result == expected
    end
    @testset "Source Notes Without Footnotes" begin
        # When the table has source notes but no footnotes, the source note rows must still
        # be tagged with the `sourceNotes` class. Otherwise, the default CSS rule
        # `tr.sourceNotes td` would never fire.
        result = pretty_table(String, [1 2]; backend = :html, source_notes = "src")

        expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <thead>
    <tr class = "columnLabelRow">
      <th style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "border-bottom: 1px solid black; border-right: 2px solid black; font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "border-bottom: 1px solid black; border-left: 2px solid black; border-right: 1px solid black; text-align: right;">1</td>
      <td style = "border-bottom: 1px solid black; border-right: 2px solid black; text-align: right;">2</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "sourceNotes">
      <td colspan = "2" style = "border-left: 2px solid black; border-right: 2px solid black; color: gray; font-size: small; font-style: italic; text-align: left;">src</td>
    </tr>
  </tfoot>
</table>
"""

        @test result == expected
    end

    @testset "Table Footer Is Closed With </tfoot>" begin
        # The `<tfoot>` section must be closed with `</tfoot>`, and `</tbody>` must be
        # emitted exactly once.
        result = pretty_table(
            String,
            [1 2];
            backend = :html,
            footnotes = [(:column_label, 1, 1) => "note A"],
        )

        @test occursin("</tfoot>", result)
        @test count("</tbody>", result) == 1
        @test count("</tfoot>", result) == 1
    end
end
