## Description #############################################################################
#
# HTML Back End: Test the table format options related with the table borders.
#
############################################################################################

@testset "No Border Decoration by Default" begin
    matrix = [1 2; 3 4]

    output = pretty_table(String, matrix; backend = :html)

    # The default HTML table format must not draw any line, so the emitted code has no
    # border decoration and the table appearance can be fully customized with CSS.
    @test occursin("<table>", output)
    @test !occursin("border", output)
    @test !occursin("<colgroup>", output)
end

@testset "Helper Macros" begin
    matrix = [1 2; 3 4]

    expected = """
<table style = "border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black;">
      <th class = "rowNumberLabel" style = "font-weight: bold; text-align: right;">Row</th>
      <th class = "stubheadLabel" style = "font-weight: bold; text-align: right;"></th>
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">1</td>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">a</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr class = "dataRow" style = "border-bottom: 2px solid black;">
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">2</td>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">b</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        show_row_number_column = true,
        row_labels = ["a", "b"],
        table_format = HtmlTableFormat(;
            @html__all_horizontal_lines, @html__all_vertical_lines
        ),
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "columnLabelRow">
      <th class = "rowNumberLabel" style = "font-weight: bold; text-align: right;">Row</th>
      <th class = "stubheadLabel" style = "font-weight: bold; text-align: right;"></th>
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">1</td>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">a</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr class = "dataRow">
      <td class = "rowNumber" style = "font-weight: bold; text-align: right;">2</td>
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;">b</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        show_row_number_column = true,
        row_labels = ["a", "b"],
        table_format = HtmlTableFormat(;
            @html__no_horizontal_lines, @html__no_vertical_lines
        ),
    )

    @test result == expected
end

@testset "Line Presence Options" verbose = true begin
    matrix = [i + j / 10 for i in 1:3, j in 1:2]

    # Render the table with one modified table format keyword and return the rendered
    # lines related to the table section identified by `needle`. The first line is the
    # `<tr>` element, which carries the horizontal lines of the row.
    function _render_lines(needle::String; kwargs...)
        output = pretty_table(
            String,
            matrix;
            backend = :html,
            title = "Title",
            subtitle = "Subtitle",
            row_group_labels = [2 => "Group"],
            summary_rows = [(data, i) -> sum(data[:, i])],
            footnotes = [(:data, 1, 1) => "Footnote"],
            source_notes = "Source note",
            table_format = HtmlTableFormat(; kwargs...),
        )

        lines = split(output, '\n')
        i = findfirst(l -> occursin(needle, l), lines)
        isnothing(i) && return String[]

        j = findnext(l -> occursin("</tr>", l), lines, i)
        return String.(lines[i:something(j, length(lines))])
    end

    @testset "Horizontal Line at Beginning" begin
        on  = _render_lines("<table"; horizontal_line_at_beginning = true)
        off = _render_lines("<table")
        @test occursin("border-top: 2px solid black", first(on))
        @test !occursin("border-top", first(off))
    end

    @testset "Horizontal Line at End" begin
        # The line at the end of the table is drawn at the bottom of the last summary row,
        # before the footnotes and source notes, and never in the `<table>` element.
        on  = _render_lines("summaryRow"; horizontal_line_at_end = true)
        off = _render_lines("summaryRow")
        @test occursin("border-bottom: 2px solid black", first(on))
        @test !occursin("border-bottom", first(off))

        on = _render_lines("<table"; horizontal_line_at_end = true)
        @test !occursin("border-bottom", first(on))

        for needle in ("footnote", "sourceNotes")
            on = _render_lines(needle; horizontal_line_at_end = true)
            @test !occursin("border-bottom", first(on))
        end

        # It has precedence over the middle line drawn after the summary rows.
        on = _render_lines(
            "summaryRow";
            horizontal_line_at_end             = true,
            horizontal_line_after_summary_rows = true,
        )
        @test occursin("border-bottom: 2px solid black", first(on))
        @test !occursin("border-bottom: 1px solid black", first(on))
    end

    @testset "Horizontal Line Before Column Labels" begin
        on  = _render_lines("columnLabelRow"; horizontal_line_before_column_labels = true)
        off = _render_lines("columnLabelRow")
        @test occursin("border-top: 1px solid black", first(on))
        @test all(l -> !occursin("border-top", l), off)
    end

    @testset "Horizontal Line After Column Labels" begin
        on  = _render_lines("columnLabelRow"; horizontal_line_after_column_labels = true)
        off = _render_lines("columnLabelRow")
        @test occursin("border-bottom: 1px solid black", first(on))
        @test all(l -> !occursin("border-bottom", l), off)
    end

    @testset "Horizontal Lines at Data Rows" begin
        on  = _render_lines("dataRow"; horizontal_lines_at_data_rows = [1])
        off = _render_lines("dataRow")
        @test occursin("border-bottom: 1px solid black", first(on))
        @test all(l -> !occursin("border-bottom", l), off)

        # The cells never carry the horizontal lines of the row.
        @test all(l -> !occursin("border-", l), on[2:(end - 1)])
    end

    @testset "Horizontal Lines Around the Row Group Label" begin
        on  = _render_lines("rowGroupLabel"; horizontal_line_before_row_group_label = true, horizontal_line_after_row_group_label  = true)
        off = _render_lines("rowGroupLabel")
        @test occursin("border-top: 1px solid black", first(on))
        @test occursin("border-bottom: 1px solid black", first(on))
        @test !occursin("border-top", first(off))
        @test !occursin("border-bottom", first(off))
    end

    @testset "Horizontal Lines Around the Summary Rows" begin
        on  = _render_lines("summaryRow"; horizontal_line_before_summary_rows = true, horizontal_line_after_summary_rows  = true)
        off = _render_lines("summaryRow")
        @test occursin("border-top: 1px solid black", first(on))
        @test occursin("border-bottom: 1px solid black", first(on))
        @test !occursin("border-top", first(off))
        @test !occursin("border-bottom", first(off))
    end

    @testset "Horizontal Line After Footnotes" begin
        on  = _render_lines("footnote"; horizontal_line_after_footnotes = true)
        off = _render_lines("footnote")
        @test occursin("border-bottom: 1px solid black", first(on))
        @test !occursin("border-bottom", first(off))
    end

    @testset "Vertical Lines" begin
        output = pretty_table(
            String,
            matrix;
            backend = :html,
            show_row_number_column = true,
            row_labels = ["a", "b", "c"],
            table_format = HtmlTableFormat(;
                vertical_line_at_beginning            = true,
                vertical_line_after_row_number_column = true,
                vertical_line_after_row_label_column  = true,
                vertical_lines_at_data_columns        = [1],
                vertical_line_after_data_columns      = true,
            ),
        )

        # The vertical lines are the borders of the `<col>` elements: row number column,
        # row label column, and the two data columns. The first one also carries the line
        # at the beginning of the table, and the last one the line at the end.
        cols = filter(l -> occursin("<col ", l), split(output, '\n'))

        @test length(cols) == 4
        @test occursin("border-left: 2px solid black; border-right: 1px solid black;", cols[1])
        @test occursin("style = \"border-right: 1px solid black;\"", cols[2])
        @test occursin("style = \"border-right: 1px solid black;\"", cols[3])
        @test occursin("style = \"border-right: 2px solid black;\"", cols[4])

        # The cells never carry the vertical lines.
        for l in split(output, '\n')
            (occursin("<td", l) || occursin("<th", l)) && @test !occursin("border-", l)
        end

        # Without vertical lines, the column group is not emitted.
        output = pretty_table(
            String,
            matrix;
            backend = :html,
            table_format = HtmlTableFormat(; @html__no_vertical_lines),
        )

        @test !occursin("<colgroup>", output)
    end
end

@testset "Custom Borders" begin
    matrix = [1 2; 3 4]

    output = pretty_table(
        String,
        matrix;
        backend = :html,
        table_format = HtmlTableFormat(;
            borders = HtmlTableBorders(;
                top_line    = "4px double red",
                header_line = "2px dotted #00ff00",
                middle_line = "1px dashed blue",
                bottom_line = "4px double red",
            ),
            horizontal_line_at_beginning        = true,
            horizontal_line_after_column_labels = true,
            horizontal_lines_at_data_rows       = [1],
            horizontal_line_at_end              = true,
        ),
    )

    lines = split(output, '\n')

    @test occursin("border-top: 4px double red", lines[1])
    @test !occursin("border-bottom", lines[1])
    @test occursin("border-bottom: 2px dotted #00ff00", output)
    @test occursin("border-bottom: 1px dashed blue", output)

    # The bottom line is drawn at the last data row.
    i = findlast(l -> occursin("dataRow", l), lines)
    @test occursin("border-bottom: 4px double red", lines[i])
end

@testset "Border Override Precedence" begin
    matrix = [1 2; 3 4]

    # A highlighter must override the borders since it is applied later.
    output = pretty_table(
        String,
        matrix;
        backend = :html,
        highlighters = [
            HtmlHighlighter((data, i, j) -> i == 2, ["border-bottom" => "3px solid red"])
        ],
        table_format = HtmlTableFormat(; horizontal_line_after_data_rows = true),
    )

    # The line after the data rows is a border of the `<tr>` element, whereas the border
    # of the highlighter is a border of the cell, which has precedence when the table
    # borders are collapsed.
    @test occursin("<tr class = \"dataRow\" style = \"border-bottom: 1px solid black;\">", output)
    @test occursin("<td style = \"border-bottom: 3px solid red; text-align: right;\">3</td>", output)

    # The user table style must override the borders of the `<table>` element.
    output = pretty_table(
        String,
        matrix;
        backend = :html,
        style = HtmlTableStyle(; table = ["border-top" => "5px solid blue"]),
        table_format = HtmlTableFormat(; horizontal_line_at_beginning = true),
    )

    @test occursin(
        "border-top: 2px solid black; border-top: 5px solid blue;", split(output, '\n')[1]
    )
end

@testset "Tables Without Column Labels" begin
    matrix = [1 2; 3 4]

    expected = """
<table style = "border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr class = "dataRow" style = "border-bottom: 2px solid black;">
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        matrix;
        backend = :html,
        show_column_labels = false,
        table_format = HtmlTableFormat(;
            horizontal_line_at_beginning        = true,
            horizontal_line_after_column_labels = true,
            horizontal_line_after_data_rows     = true,
            horizontal_line_at_end              = true,
            vertical_line_at_beginning          = true,
            vertical_lines_at_data_columns      = :all,
            vertical_line_after_data_columns    = true,
        ),
    )

    @test result == expected
end

@testset "Table Footer Outside the Ruled Area" verbose = true begin
    matrix = [1 2; 3 4]

    # The line at the end of the table must be drawn after the table body, before the
    # footnotes and source notes, and the vertical lines at the edges of the table must be
    # hidden in the footer cells, mirroring the text back end, which prints the footer
    # outside the table box.
    @testset "Summary Rows" begin
        expected = """
<table style = "border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <thead>
    <tr class = "title">
      <td colspan = "3" style = "font-size: x-large; font-weight: bold; text-align: center;">Title</td>
    </tr>
    <tr class = "columnLabelRow" style = "border-bottom: 1px solid black; border-top: 1px solid black;">
      <th class = "stubheadLabel" style = "font-weight: bold; text-align: right;"></th>
      <th style = "font-weight: bold; text-align: right;">Col. 1</th>
      <th style = "font-weight: bold; text-align: right;">Col. 2</th>
    </tr>
  </thead>
  <tbody>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;"></td>
      <td style = "text-align: right;">1<sup>1</sup></td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td class = "rowLabel" style = "font-weight: bold; text-align: right;"></td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
    <tr class = "summaryRow" style = "border-bottom: 2px solid black; border-top: 1px solid black;">
      <td class = "summaryRowLabel" style = "font-weight: bold; text-align: right;">Summary 1</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">6</td>
    </tr>
  </tbody>
  <tfoot>
    <tr class = "footnote" style = "border-bottom: 1px solid black;">
      <td colspan = "3" style = "border-left: hidden; border-right: hidden; font-size: small; text-align: left;"><sup>1</sup> Footnote</td>
    </tr>
    <tr class = "sourceNotes">
      <td colspan = "3" style = "border-left: hidden; border-right: hidden; color: gray; font-size: small; font-style: italic; text-align: left;">Source note</td>
    </tr>
  </tfoot>
</table>
"""

        result = pretty_table(
            String,
            matrix;
            backend = :html,
            title = "Title",
            summary_rows = [(data, i) -> sum(data[:, i])],
            footnotes = [(:data, 1, 1) => "Footnote"],
            source_notes = "Source note",
            table_format = HtmlTableFormat(;
                @html__all_horizontal_lines, @html__all_vertical_lines
            ),
        )

        @test result == expected
    end

    @testset "Data Rows" begin
        # Without summary rows, the line at the end of the table is drawn at the last data
        # row, before the footnotes.
        output = pretty_table(
            String,
            matrix;
            backend = :html,
            footnotes = [(:data, 1, 1) => "Footnote"],
            table_format = HtmlTableFormat(; horizontal_line_at_end = true),
        )

        @test occursin(
            "<tr class = \"dataRow\" style = \"border-bottom: 2px solid black;\">\n      <td style = \"text-align: right;\">3</td>",
            output
        )
        @test !occursin("border-bottom", first(split(output, '\n')))
        @test !occursin("<tr class = \"footnote\" style", output)
    end

    @testset "Cropped Tables" begin
        # If the table is bottom cropped, the continuation row is the last row of the
        # ruled area.
        output = pretty_table(
            String,
            [i for i in 1:10, j in 1:2];
            backend = :html,
            maximum_number_of_rows = 3,
            source_notes = "Source note",
            table_format = HtmlTableFormat(; horizontal_line_at_end = true),
        )

        @test occursin(
            "<tr style = \"border-bottom: 2px solid black;\">\n      <td style = \"text-align: right;\">&vellip;</td>",
            output
        )
        @test count("border-bottom", output) == 1

        # If the table is middle cropped, the last data row is printed after the
        # continuation row.
        output = pretty_table(
            String,
            [i for i in 1:10, j in 1:2];
            backend = :html,
            maximum_number_of_rows = 3,
            vertical_crop_mode = :middle,
            table_format = HtmlTableFormat(; horizontal_line_at_end = true),
        )

        @test occursin(
            "<tr class = \"dataRow\" style = \"border-bottom: 2px solid black;\">\n      <td style = \"text-align: right;\">10</td>",
            output
        )
        @test count("border-bottom", output) == 1
    end

    @testset "Empty Tables" begin
        # If the table has neither data nor summary rows, the column labels are the last
        # row of the ruled area.
        output = pretty_table(
            String,
            Matrix{Int}(undef, 0, 2);
            backend = :html,
            table_format = HtmlTableFormat(; horizontal_line_at_end = true),
        )

        @test occursin(
            "<tr class = \"columnLabelRow\" style = \"border-bottom: 2px solid black;\">",
            output
        )
        @test count("border-bottom", output) == 1
    end

    @testset "Footer Cells Without Vertical Lines" begin
        # The hidden borders are only emitted when the table has vertical lines at its
        # edges.
        output = pretty_table(
            String,
            matrix;
            backend = :html,
            footnotes = [(:data, 1, 1) => "Footnote"],
            source_notes = "Source note",
            table_format = HtmlTableFormat(; vertical_lines_at_data_columns = [1]),
        )

        @test !occursin("hidden", output)

        output = pretty_table(
            String,
            matrix;
            backend = :html,
            footnotes = [(:data, 1, 1) => "Footnote"],
            table_format = HtmlTableFormat(; vertical_line_at_beginning = true),
        )

        @test occursin(
            "<td colspan = \"2\" style = \"border-left: hidden; font-size: small; text-align: left;\">",
            output
        )
        @test !occursin("border-right: hidden", output)

        # The continuation column is the last column of a horizontally cropped table.
        output = pretty_table(
            String,
            [i + j for i in 1:2, j in 1:10];
            backend = :html,
            maximum_number_of_columns = 3,
            source_notes = "Source note",
            table_format = HtmlTableFormat(; vertical_line_after_continuation_column = true),
        )

        @test occursin(
            "<td colspan = \"4\" style = \"border-right: hidden; color: gray; font-size: small; font-style: italic; text-align: left;\">",
            output
        )
        @test !occursin("border-left: hidden", output)
    end
end

@testset "Line Fields Without Lines Emit No Border Decoration" begin
    # Empty vectors in the fields that accept a list of indices select no lines, so the
    # table must be emitted without `border-collapse`.
    output = pretty_table(
        String,
        [1 2; 3 4];
        backend = :html,
        table_format = HtmlTableFormat(;
            horizontal_lines_at_data_rows  = Int[],
            vertical_lines_at_data_columns = Int[],
        ),
    )

    @test occursin("<table>", output)
    @test !occursin("border", output)
end
