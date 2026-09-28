## Description #############################################################################
#
# HTML Back End: Tests related with the cell titles.
#
############################################################################################

@testset "Cell Titles" verbose = true begin
    @testset "Column Label Titles" begin
        matrix              = [(i, j) for i in 1:2, j in 1:4]
        column_labels       = [[(i, j) for j in 1:4] for i in 1:3]
        column_label_titles = [[1, 2, 3, 4], nothing, ["5", "6", "7", "8"]]

        expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th title = "1" style = "font-weight: bold; text-align: right;">(1, 1)</th>
      <th title = "2" style = "font-weight: bold; text-align: right;">(1, 2)</th>
      <th title = "3" style = "font-weight: bold; text-align: right;">(1, 3)</th>
      <th title = "4" style = "font-weight: bold; text-align: right;">(1, 4)</th>
    </tr>
    <tr class = "columnLabelRow">
      <th style = "text-align: right;">(2, 1)</th>
      <th style = "text-align: right;">(2, 2)</th>
      <th style = "text-align: right;">(2, 3)</th>
      <th style = "text-align: right;">(2, 4)</th>
    </tr>
    <tr class = "columnLabelRow">
      <th title = "5" style = "text-align: right;">(3, 1)</th>
      <th title = "6" style = "text-align: right;">(3, 2)</th>
      <th title = "7" style = "text-align: right;">(3, 3)</th>
      <th title = "8" style = "text-align: right;">(3, 4)</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">(1, 1)</td>
      <td style = "text-align: right;">(1, 2)</td>
      <td style = "text-align: right;">(1, 3)</td>
      <td style = "text-align: right;">(1, 4)</td>
    </tr>
    <tr class = "dataRow">
      <td style = "text-align: right;">(2, 1)</td>
      <td style = "text-align: right;">(2, 2)</td>
      <td style = "text-align: right;">(2, 3)</td>
      <td style = "text-align: right;">(2, 4)</td>
    </tr>
  </tbody>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend             = :html,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )

        @test result == expected
    end

    @testset "Escaping of the Titles" begin
        # The titles are attribute values. Hence, only the HTML characters must be escaped,
        # keeping the backslashes. The line breaks become character references.
        output = pretty_table(
            String,
            [1;;];
            backend             = :html,
            column_label_titles = [["C:\\dir \"x\" <a> & 'b'\nnext"]],
        )

        @test occursin(
            "<th title = \"C:\\dir &quot;x&quot; &lt;a&gt; &amp; &apos;b&apos;&#10;next\" style",
            output,
        )
    end

    @testset "Errors" verbose = true begin
        matrix        = [(i, j) for i in 1:2, j in 1:4]
        column_labels = [[(i, j) for j in 1:4] for i in 1:3]

        column_label_titles = [[1, 2, 3, 4], ["5", "6", "7", "8"]]
        @test_throws ArgumentError(
            "The length of `column_label_titles` (2) must be equal to or greater than the number of column label rows (3).",
        ) pretty_table(
            matrix;
            backend             = :html,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )

        column_label_titles = [[1, 2, 3, 4], nothing, ["5", "6", "7", "8", "9"]]
        @test_throws ArgumentError(
            "The length of the row 3 of `column_label_titles` (5) must be equal to the number of columns (4).",
        ) pretty_table(
            matrix;
            backend             = :html,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )

        column_label_titles = [[1, 2, 3], nothing, ["5", "6", "7", "8"]]
        @test_throws ArgumentError(
            "The length of the row 1 of `column_label_titles` (3) must be equal to the number of columns (4).",
        ) pretty_table(
            matrix;
            backend             = :html,
            column_labels       = column_labels,
            column_label_titles = column_label_titles,
        )
    end
end
