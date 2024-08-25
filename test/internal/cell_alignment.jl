## Description #############################################################################
#
# Tests related to the internal functions that return the cell alignment.
#
############################################################################################

@testset "Cell Alignment" verbose = true  begin
    @testset "Default" begin
        # == Create the Table Data =========================================================

        td = PrettyTables.TableData(
            ;
            data                           = rand(6, 4),
            title                          = "Table Title",
            subtitle                       = "Table Subtitle",
            column_labels                  = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
            stubhead_label                 = "Stubhead Label",
            show_row_number_column         = true,
            row_number_column_label        = "Row Number",
            row_labels                     = ["Row 1", "Row 2", "Row 3"],
            summary_columns                = [(data, i) -> 3i, (data, j) -> 4j],
            summary_column_labels          = ["Sum. Col. 1", "Sum. Col. 2"],
            summary_rows                   = [(data, i) -> i, (data, i) -> 2i],
            summary_row_labels             = ["Summary 1", "Summary 2"],
            footnotes                      = [(:data, 1, 1) => "Footnote", (:data, 2, 2) => "Footnote"],
            source_notes                   = "Source Notes",
            title_alignment                = :r,
            subtitle_alignment             = :l,
            cell_alignment                 = [(data, i, j) -> (i == 2 && j == 3) ? :c : nothing],
            data_alignment                 = [:l, :c, :r, :l],
            column_label_alignment         = [:r, :r, :l, :c],
            row_label_alignment            = :r,
            row_number_column_alignment    = :c,
            summary_column_alignment       = [:l, :c],
            summary_column_label_alignment = [:c, :r],
            footnote_alignment             = :c,
            source_note_alignment          = :r,
            num_rows                       = 6,
            num_columns                    = 4,
            maximum_number_of_rows         = 3,
            vertical_crop_mode             = :bottom,
        )

        # == Iterate the Printing Table State ==============================================

        ps = PrettyTables.PrintingTableState()

        # -- Table Header ------------------------------------------------------------------

        # .. Table Title ...................................................................

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :r

        action, rs, ps = PrettyTables._next(ps, td)

        # .. Table Subtitle ................................................................

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :l

        action, rs, ps = PrettyTables._next(ps, td)

        # -- Column Labels -----------------------------------------------------------------

        for _ in 1:2
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Table Data --------------------------------------------------------------------

        for i in 1:3
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == ((i != 2) ? :r : :c)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Continuation Row --------------------------------------------------------------

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :r

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :l

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :r

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :l

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :l

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)

        # -- Table Summary -----------------------------------------------------------------

        for _ in 1:2
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            # Empty cells.
            action, rs, ps = PrettyTables._next(ps, td)
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Footnotes ---------------------------------------------------------------------

        for _ in 1:2
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Source Notes ------------------------------------------------------------------

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :r

        action, rs, ps = PrettyTables._next(ps, td)
    end

    @testset "Continuation Row Override" begin
        # == Create the Table Data =========================================================

        td = PrettyTables.TableData(
            ;
            data                           = rand(6, 4),
            title                          = "Table Title",
            subtitle                       = "Table Subtitle",
            column_labels                  = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
            stubhead_label                 = "Stubhead Label",
            show_row_number_column         = true,
            row_number_column_label        = "Row Number",
            row_labels                     = ["Row 1", "Row 2", "Row 3"],
            summary_columns                = [(data, i) -> 3i, (data, j) -> 4j],
            summary_column_labels          = ["Sum. Col. 1", "Sum. Col. 2"],
            summary_rows                   = [(data, i) -> i, (data, i) -> 2i],
            summary_row_labels             = ["Summary 1", "Summary 2"],
            footnotes                      = [(:data, 1, 1) => "Footnote", (:data, 2, 2) => "Footnote"],
            source_notes                   = "Source Notes",
            title_alignment                = :r,
            subtitle_alignment             = :l,
            cell_alignment                 = [(data, i, j) -> (i == 2 && j == 3) ? :c : nothing],
            data_alignment                 = [:l, :c, :r, :l],
            column_label_alignment         = [:r, :r, :l, :c],
            continuation_row_alignment     = :c,
            row_label_alignment            = :r,
            row_number_column_alignment    = :c,
            summary_column_alignment       = [:l, :c],
            summary_column_label_alignment = [:c, :r],
            footnote_alignment             = :c,
            source_note_alignment          = :r,
            num_rows                       = 6,
            num_columns                    = 4,
            maximum_number_of_rows         = 3,
            vertical_crop_mode             = :bottom,
        )

        # == Iterate the Printing Table State ==============================================

        ps = PrettyTables.PrintingTableState()

        # -- Table Header ------------------------------------------------------------------

        # .. Table Title ...................................................................

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :r

        action, rs, ps = PrettyTables._next(ps, td)

        # .. Table Subtitle ................................................................

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :l

        action, rs, ps = PrettyTables._next(ps, td)

        # -- Column Labels -----------------------------------------------------------------

        for _ in 1:2
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Table Data --------------------------------------------------------------------

        for i in 1:3
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == ((i != 2) ? :r : :c)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Continuation Row --------------------------------------------------------------

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :c

        action, rs, ps = PrettyTables._next(ps, td)

        # -- Table Summary -----------------------------------------------------------------

        for _ in 1:2
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :r

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :l

            # Empty cells.
            action, rs, ps = PrettyTables._next(ps, td)
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Footnotes ---------------------------------------------------------------------

        for _ in 1:2
            action, rs, ps = PrettyTables._next(ps, td)

            action, rs, ps = PrettyTables._next(ps, td)
            alignment = PrettyTables._current_cell_alignment(action, ps, td)
            @test alignment == :c

            action, rs, ps = PrettyTables._next(ps, td)
        end

        # -- Source Notes ------------------------------------------------------------------

        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        alignment = PrettyTables._current_cell_alignment(action, ps, td)
        @test alignment == :r

        action, rs, ps = PrettyTables._next(ps, td)
    end
end
