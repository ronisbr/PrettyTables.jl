## Description #############################################################################
#
# Test showing all the available fields.
#
############################################################################################

@testset "All Available Fields" verbose = true begin
    matrix = [(i, j) for i in 1:3, j in 1:3]

    @testset "Without Cropping" begin
        expected = """
<table>
  <thead>
    <tr class = "title">
      <td colspan = "5" style = "text-align: center; font-size: x-large; font-weight: bold;">Table Title</td>
    </tr>
    <tr class = "subtitle">
      <td colspan = "5" style = "text-align: center; font-size: large; font-style: italic;">Table Subtitle</td>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "text-align: right; font-weight: bold;">Row</th>
      <th class = "stubheadLabel" style = "text-align: right; font-weight: bold;">Rows</th>
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th colspan = "2" style = "border-bottom: 1px solid black; text-align: center; font-weight: bold;">Merged Column<sup>1</sup></th>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "text-align: right; font-weight: bold;"></th>
      <th class = "stubheadLabel" style = "text-align: right; font-weight: bold;"></th>
      <th style = "text-align: right;">1</th>
      <th style = "text-align: right;">2</th>
      <th style = "text-align: right;">3</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">1</td>
      <td class = "rowLabel" style = "text-align: right; font-weight: bold;">Row 1</td>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
    </tr>
    <tr class = "dataRow">
      <td colspan = "5" style = "text-align: left; font-weight: bold;">Row Group</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">2</td>
      <td class = "rowLabel" style = "text-align: right; font-weight: bold;">Row 2</td>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)<sup>2</sup></td>
      <td style = "text-align: right;">(2, 3)</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">3</td>
      <td class = "rowLabel" style = "text-align: right; font-weight: bold;">Row 3</td>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td style = "text-align: right;">(3, 3)</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "text-align: right; font-weight: bold;"></td>
      <td class = "summaryRowLabel" style = "text-align: right; font-weight: bold;">Summary 1</td>
      <td style = "text-align: right;">10</td>
      <td style = "text-align: right;">20</td>
      <td style = "text-align: right;">30</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "text-align: right; font-weight: bold;"></td>
      <td class = "summaryRowLabel" style = "text-align: right; font-weight: bold;">Summary 2</td>
      <td style = "text-align: right;">20</td>
      <td style = "text-align: right;">40</td>
      <td style = "text-align: right;">60</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote">
      <td colspan = "5" style = "text-align: left; font-size: small;"><sup>1</sup> Footnote in column label</td>
    </tr>
    <tr class = "footnote">
      <td colspan = "5" style = "text-align: left; font-size: small;"><sup>2</sup> Footnote in data</td>
    </tr>
    <tr class = "sourceNotes">
      <td colspan = "5" style = "text-align: left; color: gray; font-size: small; font-style: italic;">Source Notes</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            column_labels = [["Col. $i" for i in 1:3], ["$i" for i in 1:3]],
            footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
            merge_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
        )
    end

    @testset "With Bottom Cropping" begin
        expected = """
<div>
  <div style = "font-style: italic; float: right;">
    <span>1 column and 1 row omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table>
  <thead>
    <tr class = "title">
      <td colspan = "5" style = "text-align: center; font-size: x-large; font-weight: bold;">Table Title</td>
    </tr>
    <tr class = "subtitle">
      <td colspan = "5" style = "text-align: center; font-size: large; font-style: italic;">Table Subtitle</td>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "text-align: right; font-weight: bold;">Row</th>
      <th class = "stubheadLabel" style = "text-align: right; font-weight: bold;">Rows</th>
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th colspan = "1" style = "border-bottom: 1px solid black; text-align: center; font-weight: bold;">Merged Column<sup>1</sup></th>
      <td>&ctdot;</td>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">1</td>
      <td class = "rowLabel" style = "text-align: right; font-weight: bold;">Row 1</td>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td>&ctdot;</td>
    </tr>
    <tr class = "dataRow">
      <td colspan = "5" style = "text-align: left; font-weight: bold;">Row Group</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">2</td>
      <td class = "rowLabel" style = "text-align: right; font-weight: bold;">Row 2</td>
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)<sup>2</sup></td>
      <td>&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "text-align: right; font-weight: bold;"></td>
      <td class = "summaryRowLabel" style = "text-align: right; font-weight: bold;">Summary 1</td>
      <td style = "text-align: right;">10</td>
      <td style = "text-align: right;">20</td>
      <td>&ctdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "text-align: right; font-weight: bold;"></td>
      <td class = "summaryRowLabel" style = "text-align: right; font-weight: bold;">Summary 2</td>
      <td style = "text-align: right;">20</td>
      <td style = "text-align: right;">40</td>
      <td>&ctdot;</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote">
      <td colspan = "5" style = "text-align: left; font-size: small;"><sup>1</sup> Footnote in column label</td>
    </tr>
    <tr class = "footnote">
      <td colspan = "5" style = "text-align: left; font-size: small;"><sup>2</sup> Footnote in data</td>
    </tr>
    <tr class = "sourceNotes">
      <td colspan = "5" style = "text-align: left; color: gray; font-size: small; font-style: italic;">Source Notes</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            merge_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
        )
    end

    @testset "With Middle Cropping" begin
        expected = """
<div>
  <div style = "font-style: italic; float: right;">
    <span>1 column and 1 row omitted</span>
  </div>
  <div style = "clear: both;"></div>
</div>
<table>
  <thead>
    <tr class = "title">
      <td colspan = "5" style = "text-align: center; font-size: x-large; font-weight: bold;">Table Title</td>
    </tr>
    <tr class = "subtitle">
      <td colspan = "5" style = "text-align: center; font-size: large; font-style: italic;">Table Subtitle</td>
    </tr>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "text-align: right; font-weight: bold;">Row</th>
      <th class = "stubheadLabel" style = "text-align: right; font-weight: bold;">Rows</th>
      <th style = "text-align: right; font-weight: bold;">Col. 1</th>
      <th colspan = "1" style = "border-bottom: 1px solid black; text-align: center; font-weight: bold;">Merged Column<sup>1</sup></th>
      <td>&ctdot;</td>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">1</td>
      <td class = "rowLabel" style = "text-align: right; font-weight: bold;">Row 1</td>
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td>&ctdot;</td>
    </tr>
    <tr>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&vellip;</td>
      <td style = "text-align: right;">&dtdot;</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "text-align: right; font-weight: bold;">3</td>
      <td class = "rowLabel" style = "text-align: right; font-weight: bold;">Row 3</td>
      <td style = "text-align: right;">(3, 1)</td>
      <td style = "text-align: right;">(3, 2)</td>
      <td>&ctdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "text-align: right; font-weight: bold;"></td>
      <td class = "summaryRowLabel" style = "text-align: right; font-weight: bold;">Summary 1</td>
      <td style = "text-align: right;">10</td>
      <td style = "text-align: right;">20</td>
      <td>&ctdot;</td>
    </tr>
    <tr class = "summaryRow">
      <td class = "summaryRowNumber" style = "text-align: right; font-weight: bold;"></td>
      <td class = "summaryRowLabel" style = "text-align: right; font-weight: bold;">Summary 2</td>
      <td style = "text-align: right;">20</td>
      <td style = "text-align: right;">40</td>
      <td>&ctdot;</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote">
      <td colspan = "5" style = "text-align: left; font-size: small;"><sup>1</sup> Footnote in column label</td>
    </tr>
    <tr class = "footnote">
      <td colspan = "5" style = "text-align: left; font-size: small;"><sup>2</sup> Footnote in data</td>
    </tr>
    <tr class = "sourceNotes">
      <td colspan = "5" style = "text-align: left; color: gray; font-size: small; font-style: italic;">Source Notes</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            footnotes = [(:column_label, 1, 2) => "Footnote in column label", (:data, 2, 2) => "Footnote in data"],
            maximum_number_of_columns = 2,
            maximum_number_of_rows = 2,
            merge_cells = [MergeCells(1, 2, 2, "Merged Column", :c)],
            row_group_labels = [2 => "Row Group"],
            row_labels = ["Row $i" for i in 1:5],
            show_row_number_column = true,
            source_notes = "Source Notes",
            stubhead_label = "Rows",
            subtitle = "Table Subtitle",
            summary_rows = [(data, i) -> 10i, (data, i) -> 20i],
            title = "Table Title",
            vertical_crop_mode = :middle
        )

        @test result == expected
    end
end
