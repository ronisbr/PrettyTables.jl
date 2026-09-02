## Description #############################################################################
#
# HTML Back End: Test the table format options related with the table borders.
#
############################################################################################

@testset "Helper Macros" begin
    matrix = [1 2; 3 4]

    expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
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
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
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
<table style = "border-collapse: collapse;">
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
        on  = _render_lines("<table")
        off = _render_lines("<table"; horizontal_line_at_beginning = false)
        @test occursin("border-top: 2px solid black", first(on))
        @test !occursin("border-top", first(off))
    end

    @testset "Horizontal Line at End" begin
        on  = _render_lines("<table")
        off = _render_lines("<table"; horizontal_line_at_end = false)
        @test occursin("border-bottom: 2px solid black", first(on))
        @test !occursin("border-bottom", first(off))
    end

    @testset "Horizontal Line Before Column Labels" begin
        on  = _render_lines("columnLabelRow")
        off = _render_lines("columnLabelRow"; horizontal_line_before_column_labels = false)
        @test occursin("border-top: 1px solid black", first(on))
        @test all(l -> !occursin("border-top", l), off)
    end

    @testset "Horizontal Line After Column Labels" begin
        on  = _render_lines("columnLabelRow")
        off = _render_lines("columnLabelRow"; horizontal_line_after_column_labels = false)
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
        on  = _render_lines("rowGroupLabel")
        off = _render_lines("rowGroupLabel"; horizontal_line_before_row_group_label = false, horizontal_line_after_row_group_label  = false)
        @test occursin("border-top: 1px solid black", first(on))
        @test occursin("border-bottom: 1px solid black", first(on))
        @test !occursin("border-top", first(off))
        @test !occursin("border-bottom", first(off))
    end

    @testset "Horizontal Lines Around the Summary Rows" begin
        on  = _render_lines("summaryRow")
        off = _render_lines("summaryRow"; horizontal_line_before_summary_rows = false, horizontal_line_after_summary_rows  = false)
        @test occursin("border-top: 1px solid black", first(on))
        @test occursin("border-bottom: 1px solid black", first(on))
        @test !occursin("border-top", first(off))
        @test !occursin("border-bottom", first(off))
    end

    @testset "Horizontal Line After Footnotes" begin
        on  = _render_lines("footnote")
        off = _render_lines("footnote"; horizontal_line_after_footnotes = false)
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
            horizontal_lines_at_data_rows = [1],
        ),
    )

    @test occursin("border-top: 4px double red", split(output, '\n')[1])
    @test occursin("border-bottom: 4px double red", split(output, '\n')[1])
    @test occursin("border-bottom: 2px dotted #00ff00", output)
    @test occursin("border-bottom: 1px dashed blue", output)
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
    )

    @test occursin(
        "border-top: 2px solid black; border-top: 5px solid blue;", split(output, '\n')[1]
    )
end

@testset "Tables Without Column Labels" begin
    matrix = [1 2; 3 4]

    expected = """
<table style = "border-bottom: 2px solid black; border-collapse: collapse; border-top: 2px solid black;">
  <colgroup>
    <col style = "border-left: 2px solid black; border-right: 1px solid black;">
    <col style = "border-right: 2px solid black;">
  </colgroup>
  <tbody>
    <tr class = "dataRow">
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">2</td>
    </tr>
    <tr class = "dataRow" style = "border-bottom: 1px solid black;">
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">4</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(String, matrix; backend = :html, show_column_labels = false)

    @test result == expected
end
