## Description #############################################################################
#
# Word Back End: Test the structure of the rendered table.
#
############################################################################################

@testset "Table Sections" verbose = true begin
    matrix = [1 2 3; 4 5 6; 7 8 9]

    table = pretty_table(
        W.Table,
        matrix;
        title = "Title",
        subtitle = "Subtitle",
        stubhead_label = "Stub",
        show_row_number_column = true,
        row_labels = ["R1", "R2", "R3"],
        row_group_labels = [2 => "Group"],
        column_labels = [["A", "B", "C"], ["a", MultiColumn(2, "Merged")]],
        summary_row_labels = ["Total"],
        summary_rows = [(data, i) -> sum(data[:, i])],
        footnotes = [(:data, 1, 1) => "Footnote"],
        source_notes = "Source note",
    )

    @test length(table.rows) == 11

    @test docx_row_text(table, 1) == ["Title"]
    @test docx_row_text(table, 2) == ["Subtitle"]
    @test docx_row_text(table, 3) == ["Row", "Stub", "A", "B", "C"]
    @test docx_row_text(table, 4) == ["", "", "a", "Merged"]
    @test docx_row_text(table, 5) == ["1", "R1", "11", "2", "3"]
    @test docx_row_text(table, 6) == ["Group"]
    @test docx_row_text(table, 7) == ["2", "R2", "4", "5", "6"]
    @test docx_row_text(table, 8) == ["3", "R3", "7", "8", "9"]
    @test docx_row_text(table, 9) == ["", "Total", "12", "15", "18"]
    @test docx_row_text(table, 10) == ["1Footnote"]
    @test docx_row_text(table, 11) == ["Source note"]

    @test docx_gridspans(table, 1) == [5]
    @test docx_gridspans(table, 4) == [1, 1, 1, 2]
    @test docx_gridspans(table, 5) == [1, 1, 1, 1, 1]
    @test docx_gridspans(table, 6) == [5]
    @test docx_gridspans(table, 10) == [5]

    # The rows above the data are repeated after every page break.
    @test map(r -> r.properties.header, table.rows) == [
        true, true, true, true, nothing, nothing, nothing, nothing, nothing, nothing,
        nothing,
    ]

    @testset "Footnote Markers" verbose = true begin
        # The marker of the cell that has the footnote and the index of the footnote itself
        # are superscript runs.
        data_runs = docx_runs(docx_cell(table, 5, 3))
        @test length(data_runs) == 2
        @test data_runs[1].properties.valign === nothing
        @test data_runs[2].properties.valign == W.VerticalAlignment.superscript

        footnote_runs = docx_runs(docx_cell(table, 10, 1))
        @test footnote_runs[1].properties.valign == W.VerticalAlignment.superscript
    end

    @testset "Alignment" verbose = true begin
        @test docx_paragraph(docx_cell(table, 1, 1)).properties.justification ==
            W.Justification.center
        @test docx_paragraph(docx_cell(table, 5, 5)).properties.justification ==
            W.Justification.stop
        @test docx_paragraph(docx_cell(table, 6, 1)).properties.justification ==
            W.Justification.start
        @test docx_cell(table, 1, 1).properties.valign == W.VerticalAlign.bottom
        @test docx_cell(table, 5, 1).properties.valign == W.VerticalAlign.top
    end
end

@testset "Cell Content" verbose = true begin
    @testset "Line Breaks" verbose = true begin
        table = pretty_table(W.Table, ["First\nSecond";;])
        runs  = docx_runs(docx_cell(table, 2, 1))

        @test length(runs) == 1
        @test map(typeof, only(runs).children) == [W.Text, W.Break, W.Text]
        @test docx_text(docx_cell(table, 2, 1)) == "First\nSecond"
    end

    @testset "Renderers" verbose = true begin
        @test docx_text(docx_cell(pretty_table(W.Table, ["str";;]), 2, 1)) == "str"

        table = pretty_table(W.Table, ["str";;]; renderer = :show)
        @test docx_text(docx_cell(table, 2, 1)) == "\"str\""
    end

    @testset "Cropping" verbose = true begin
        table = pretty_table(
            W.Table,
            [(i, j) for i in 1:4, j in 1:4];
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 2,
        )

        @test docx_row_text(table, 1) == ["Col. 1", "Col. 2", "⋯"]
        @test docx_row_text(table, 2) == ["(1, 1)", "(1, 2)", "⋯"]
        @test docx_row_text(table, 4) == ["⋮", "⋮", "⋱"]
    end

    @static if VERSION >= v"1.11"
        @testset "Styled Strings" verbose = true begin
            table = pretty_table(
                W.Table,
                [styled"{bold:Bold} and {(foreground=red):red}";;]
            )

            runs = docx_runs(docx_cell(table, 2, 1))

            @test length(runs) == 3
            @test runs[1].properties.bold == true
            @test runs[2].properties.bold === nothing
            @test docx_hex(runs[3].properties.color) == "A51C2C"
        end
    end
end

@testset "Empty Tables" verbose = true begin
    @test length(pretty_table(W.Table, Matrix{Int}(undef, 0, 3)).rows) == 1
    @test length(pretty_table(W.Table, [1 2; 3 4]; show_column_labels = false).rows) == 2

    # A table without columns has no content row, hence no outer borders.
    table = pretty_table(W.Table, Matrix{Int}(undef, 0, 0); title = "Title")
    @test docx_row_text(table, 1) == ["Title"]
    @test docx_cell(table, 1, 1).properties.borders === nothing
end
