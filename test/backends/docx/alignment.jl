## Description #############################################################################
#
# Word Back End: Test alignment of cells in the table.
#
############################################################################################

docx_justification(table::W.Table, row::Int, col::Int) =
    docx_paragraph(docx_cell(table, row, col)).properties.justification

docx_valign(table::W.Table, row::Int, col::Int) =
    docx_cell(table, row, col).properties.valign

@testset "Alignment" verbose = true begin
    data = [1 2 3; 4 5 6; 7 8 9]

    J = W.Justification
    V = W.VerticalAlign

    # == With Headers, Footers and Summaries ===============================================

    @testset "With Headers, Footers and Summaries" verbose = true begin
        table = pretty_table(
            W.Table,
            data;
            title_alignment = :l,
            title = "This is a title",
            subtitle_alignment = :c,
            subtitle = "This is a subtitle",
            stubhead_label = "stubhead label",
            column_labels = ["Column 1", "Column 2", "Column 3"],
            row_labels = ["Row 1", "Row 2", "Row 3"],
            row_label_column_alignment = :c,
            alignment = [:l, :r, :c],
            summary_rows = [
                (data, j) -> maximum(@views data[:, j]),
                (data, j) -> minimum(@views data[:, j]),
            ],
            summary_row_labels = ["Min Value", "Max Value"],
            footnotes = [
                (:subtitle, 1, 1) => "Vehicle 1: Ford Escort, Vehicle 2: VW Golf"
                (:column_label, 1, 3) => "Estimated data based on the acceleration measurement."
            ],
            footnote_alignment = :r,
            source_notes = "Source: Test procedure conducted on 2024-01-15.\nNote: Data is for demonstration purposes only.",
            source_note_alignment = :c,
        )

        # Title and subtitle.
        @test docx_justification(table, 1, 1) == J.start
        @test docx_valign(table, 1, 1) == V.bottom
        @test docx_justification(table, 2, 1) == J.center
        @test docx_valign(table, 2, 1) == V.bottom

        # Column labels.
        for (col, j) in enumerate((J.center, J.start, J.stop, J.center))
            @test docx_justification(table, 3, col) == j
            @test docx_valign(table, 3, col) == V.bottom
        end

        # Data and summary rows.
        for row in 4:8, (col, j) in enumerate((J.center, J.start, J.stop, J.center))
            @test docx_justification(table, row, col) == j
            @test docx_valign(table, row, col) == V.top
        end

        # Footnotes and source notes.
        for row in 9:10
            @test docx_justification(table, row, 1) == J.stop
            @test docx_valign(table, row, 1) == V.center
        end

        @test docx_justification(table, 11, 1) == J.center
        @test docx_valign(table, 11, 1) == V.center
    end

    # == Column Label Alignment ============================================================

    @testset "Column Label Alignment" verbose = true begin
        table = pretty_table(
            W.Table,
            data;
            title_alignment = :l,
            title = "This is a title",
            subtitle_alignment = :c,
            subtitle = "This is a subtitle",
            column_label_alignment = [:r, :c, :l],
            column_labels = ["Column 1", "Column 2", "Column 3"],
            row_label_column_alignment = :c,
            alignment = [:r, :c, :l],
        )

        @test docx_justification(table, 1, 1) == J.start
        @test docx_justification(table, 2, 1) == J.center
        @test docx_justification(table, 3, 1) == J.stop
        @test docx_justification(table, 3, 2) == J.center
        @test docx_justification(table, 3, 3) == J.start
        @test docx_justification(table, 4, 1) == J.stop
        @test docx_justification(table, 5, 2) == J.center
        @test docx_justification(table, 6, 3) == J.start
    end

    # == Cell-Level Dynamic Alignment ======================================================

    @testset "Cell-Level Dynamic Alignment" verbose = true begin
        table = pretty_table(
            W.Table,
            data;
            column_label_alignment = [:r, :c, :l],
            column_labels = ["Column 1", "Column 2", "Column 3"],
            alignment = :c,
            cell_alignment = [(data, i, j) -> isodd(j) ? :l : :r],
        )

        # The cell alignment does not affect the column labels.
        @test docx_justification(table, 1, 1) == J.stop
        @test docx_justification(table, 1, 2) == J.center
        @test docx_justification(table, 1, 3) == J.start

        for row in 2:4, (col, j) in enumerate((J.start, J.stop, J.start))
            @test docx_justification(table, row, col) == j
        end
    end

    # == Merged Column Labels ==============================================================

    @testset "Merged Column Labels" verbose = true begin
        table = pretty_table(
            W.Table,
            data;
            column_labels = [[MultiColumn(2, "Merged", :r), "C"], ["A", "B", "C"]],
        )

        # The merged cells use their own alignment.
        @test docx_justification(table, 1, 1) == J.stop
        @test docx_valign(table, 1, 1) == V.bottom
    end
end
