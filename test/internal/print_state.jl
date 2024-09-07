## Description #############################################################################
#
# Tests related to the internal functions that manage the printing state.
#
############################################################################################

@testset "Print State" verbose = true begin
    @testset "Default" begin
        # == Create the Table Data =========================================================

        td = PrettyTables.TableData(
            ;
            data                    = rand(3, 4),
            title                   = "Table Title",
            subtitle                = "Table Subtitle",
            column_labels           = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
            stubhead_label          = "Stubhead Label",
            show_row_number_column  = true,
            row_number_column_label = "Row Number",
            row_labels              = ["Row 1", "Row 2", "Row 3"],
            row_group_labels        = [2 => "Row Group"],
            summary_rows            = [(data, j) ->  j, (data, j) -> 2j],
            summary_row_labels      = ["Summary 1", "Summary 2"],
            footnotes               = [(:data, 1, 1) => "Footnote", (:data, 2, 2) => "Footnote"],
            source_notes            = "Source Notes",
            num_rows                = 3,
            num_columns             = 4,
            first_row_index         = 1,
            first_column_index      = 1,
        )

        # == Iterate the Printing Table State ==============================================

        ps = PrettyTables.PrintingTableState()

        # -- Table Header ------------------------------------------------------------------

        for a in (:title, :subtitle)
            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :table_header

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == a
            @test rs     == :table_header

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :table_header
        end

        # -- Column Labels -----------------------------------------------------------------

        for i in 1:2
            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :column_labels

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :row_number_label
            @test rs     == :column_labels
            @test ps.i   == i

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :stubhead_label
            @test rs     == :column_labels
            @test ps.i   == i

            for j in 1:4
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :column_label
                @test rs     == :column_labels
                @test ps.i   == i
                @test ps.j   == j
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :column_labels
        end

        # -- Table Data --------------------------------------------------------------------

        for i in 1:3

            if i == 2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_group_label
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :data
                @test ps.i   == i
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :data
            @test ps.i   == i

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :row_number
            @test rs     == :data
            @test ps.i   == i

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :row_label
            @test rs     == :data
            @test ps.i   == i

            for j in 1:4
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :data
                @test rs     == :data
                @test ps.i   == i
                @test ps.j   == j
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :data
        end

        # -- Table Summary -----------------------------------------------------------------

        for i in 1:2
            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :summary_row
            @test ps.i   == i

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :summary_row_number
            @test rs     == :summary_row
            @test ps.i   == i

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :summary_row_label
            @test rs     == :summary_row
            @test ps.i   == i

            for j in 1:4
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :summary_row_cell
                @test rs     == :summary_row
                @test ps.i   == i
                @test ps.j   == j
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :summary_row
        end

        # -- Table Footer ------------------------------------------------------------------

        for i in 1:2
            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :footnote
            @test ps.i   == i
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :table_footer
        end

        action, rs, ps = PrettyTables._next(ps, td)
        @test action == :new_row
        @test rs     == :table_footer

        action, rs, ps = PrettyTables._next(ps, td)
        @test action == :source_notes
        @test rs     == :table_footer

        action, rs, ps = PrettyTables._next(ps, td)
        @test action == :end_row
        @test rs     == :table_footer

        # -- End Printing ------------------------------------------------------------------

        action, rs, ps = PrettyTables._next(ps, td)
        @test action == :end_printing

        action, rs, ps = PrettyTables._next(ps, td)
        @test action == :end_printing
    end

    @testset "Without Optional Fields" begin
        # == Create the Table Data =========================================================

        td = PrettyTables.TableData(
            ;
            data               = rand(3, 4),
            column_labels      = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
            num_rows           = 3,
            num_columns        = 4,
            first_row_index    = 1,
            first_column_index = 1,
        )

        # == Iterate the Printing Table State ==============================================

        ps = PrettyTables.PrintingTableState()

        # -- Column Labels -----------------------------------------------------------------

        for i in 1:2
            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :column_labels

            for j in 1:4
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :column_label
                @test rs     == :column_labels
                @test ps.i   == i
                @test ps.j   == j
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :column_labels
        end

        # -- Table Data --------------------------------------------------------------------

        for i in 1:3

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :data
            @test ps.i   == i

            for j in 1:4
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :data
                @test rs     == :data
                @test ps.i   == i
                @test ps.j   == j
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :data
        end

        # -- End Printing ------------------------------------------------------------------

        action, rs, ps = PrettyTables._next(ps, td)
        @test action == :end_printing

        action, rs, ps = PrettyTables._next(ps, td)
        @test action == :end_printing
    end

    @testset "With Cropping" verbose = true begin
        @testset "Bottom Vertical Cropping" begin
            # == Create the Table Data =====================================================

            td = PrettyTables.TableData(
                ;
                data                      = rand(6, 4),
                title                     = "Table Title",
                subtitle                  = "Table Subtitle",
                column_labels             = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
                stubhead_label            = "Stubhead Label",
                show_row_number_column    = true,
                row_number_column_label   = "Row Number",
                row_labels                = ["Row 1", "Row 2", "Row 3"],
                row_group_labels          = [2 => "Row Group 1", 4 => "Row Group 1"],
                summary_rows              = [(data, i) -> i, (data, i) -> 2i],
                summary_row_labels        = PrettyTables.SummaryLabelIterator(2),
                footnotes                 = [(:data, 1, 1) => "Footnote", (:data, 2, 2) => "Footnote"],
                source_notes              = "Source Notes",
                num_rows                  = 6,
                num_columns               = 4,
                first_row_index           = 1,
                first_column_index        = 1,
                maximum_number_of_columns = 2,
                maximum_number_of_rows    = 3,
                vertical_crop_mode        = :bottom,
            )

            # == Iterate the Printing Table State ==========================================

            ps = PrettyTables.PrintingTableState()

            # -- Table Header --------------------------------------------------------------

            for a in (:title, :subtitle)
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :table_header

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == a
                @test rs     == :table_header

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :table_header
            end

            # -- Column Labels -------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :column_labels

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_number_label
                @test rs     == :column_labels
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :stubhead_label
                @test rs     == :column_labels
                @test ps.i   == i

                for j in 1:2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :column_label
                    @test rs     == :column_labels
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :horizontal_continuation_cell
                @test rs     == :column_labels

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :column_labels
            end

            # -- Table Data ----------------------------------------------------------------

            for i in 1:3
                if i == 2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :new_row
                    @test rs     == :data
                    @test ps.i   == i

                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :row_group_label
                    @test rs     == :data
                    @test ps.i   == i

                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :end_row
                    @test rs     == :data
                    @test ps.i   == i
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_number
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_label
                @test rs     == :data
                @test ps.i   == i

                for j in 1:2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :data
                    @test rs     == :data
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :horizontal_continuation_cell
                @test rs     == :data

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :data
            end

            # -- Continuation Row ----------------------------------------------------------

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :continuation_row

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :row_number_vertical_continuation_cell
            @test rs     == :continuation_row

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :row_label_vertical_continuation_cell
            @test rs     == :continuation_row

            for j in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :vertical_continuation_cell
                @test rs     == :continuation_row
                @test ps.j   == j
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :diagonal_continuation_cell
            @test rs     == :continuation_row

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :continuation_row

            # -- Table Summary -------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :summary_row
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :summary_row_number
                @test rs     == :summary_row
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :summary_row_label
                @test rs     == :summary_row
                @test ps.i   == i

                for j in 1:2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :summary_row_cell
                    @test rs     == :summary_row
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :horizontal_continuation_cell
                @test rs     == :summary_row

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :summary_row
            end

            # -- Table Footer --------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :table_footer

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :footnote
                @test ps.i   == i
                @test rs     == :table_footer

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :table_footer
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :source_notes
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :table_footer

            # -- End Printing --------------------------------------------------------------

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_printing

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_printing
        end

        @testset "Middle Vertical Cropping" begin
            # == Create the Table Data =====================================================

            td = PrettyTables.TableData(
                ;
                data                      = rand(6, 4),
                title                     = "Table Title",
                subtitle                  = "Table Subtitle",
                column_labels             = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
                stubhead_label            = "Stubhead Label",
                show_row_number_column    = true,
                row_number_column_label   = "Row Number",
                row_labels                = ["Row 1", "Row 2", "Row 3"],
                row_group_labels          = [2 => "Row Group 1", 6 => "Row Group 2"],
                summary_rows              = [(data, i) -> i, (data, i) -> 2i],
                summary_row_labels        = PrettyTables.SummaryLabelIterator(2),
                footnotes                 = [(:data, 1, 1) => "Footnote", (:data, 2, 2) => "Footnote"],
                source_notes              = "Source Notes",
                num_rows                  = 6,
                num_columns               = 4,
                first_row_index           = 1,
                first_column_index        = 1,
                maximum_number_of_columns = 2,
                maximum_number_of_rows    = 3,
                vertical_crop_mode        = :middle,
            )

            # == Iterate the Printing Table State ==========================================

            ps = PrettyTables.PrintingTableState()

            # -- Table Header --------------------------------------------------------------

            for a in (:title, :subtitle)
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :table_header

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == a
                @test rs     == :table_header

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :table_header
            end

            # -- Column Labels -------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :column_labels

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_number_label
                @test rs     == :column_labels
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :stubhead_label
                @test rs     == :column_labels
                @test ps.i   == i

                for j in 1:2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :column_label
                    @test rs     == :column_labels
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :horizontal_continuation_cell
                @test rs     == :column_labels

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :column_labels
            end

            # -- Table Data ----------------------------------------------------------------

            for i in 1:2
                if i == 2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :new_row
                    @test rs     == :data
                    @test ps.i   == i

                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :row_group_label
                    @test rs     == :data
                    @test ps.i   == i

                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :end_row
                    @test rs     == :data
                    @test ps.i   == i
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_number
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_label
                @test rs     == :data
                @test ps.i   == i

                for j in 1:2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :data
                    @test rs     == :data
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :horizontal_continuation_cell
                @test rs     == :data

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :data
            end

            # -- Continuation Row ----------------------------------------------------------

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :continuation_row

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :row_number_vertical_continuation_cell
            @test rs     == :continuation_row

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :row_label_vertical_continuation_cell
            @test rs     == :continuation_row

            for j in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :vertical_continuation_cell
                @test rs     == :continuation_row
                @test ps.j   == j
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :diagonal_continuation_cell
            @test rs     == :continuation_row

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :continuation_row

            # -- Table Data (Remaining Rows) -----------------------------------------------

            let i = 6
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_group_label
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_number
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_label
                @test rs     == :data
                @test ps.i   == i

                for j in 1:2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :data
                    @test rs     == :data
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :horizontal_continuation_cell
                @test rs     == :data

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :data
            end

            # -- Table Summary -------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :summary_row
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :summary_row_number
                @test rs     == :summary_row
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :summary_row_label
                @test rs     == :summary_row
                @test ps.i   == i

                for j in 1:2
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :summary_row_cell
                    @test rs     == :summary_row
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :horizontal_continuation_cell
                @test rs     == :summary_row

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :summary_row
            end

            # -- Table Footer --------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :table_footer

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :footnote
                @test ps.i   == i
                @test rs     == :table_footer

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :table_footer
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :source_notes
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :table_footer

            # -- End Printing --------------------------------------------------------------

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_printing

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_printing
        end

        @testset "Corner Cases of Vertical Cropping" begin
            # If the maximum number of rows / columns is equal to the number of rows /
            # columns, we should not print the continuation row.

            # == Create the Table Data =====================================================

            td = PrettyTables.TableData(
                ;
                data                      = rand(3, 4),
                title                     = "Table Title",
                subtitle                  = "Table Subtitle",
                column_labels             = [["1", "2", "3", "4"], ["1", "2", "3", "4"]],
                stubhead_label            = "Stubhead Label",
                show_row_number_column    = true,
                row_number_column_label   = "Row Number",
                row_labels                = ["Row 1", "Row 2", "Row 3"],
                summary_rows              = [(data, i) -> i, (data, i) -> 2i],
                summary_row_labels        = ["Summary 1", "Summary 2"],
                footnotes                 = [(:data, 1, 1) => "Footnote", (:data, 2, 2) => "Footnote"],
                source_notes              = "Source Notes",
                num_rows                  = 3,
                num_columns               = 4,
                first_row_index           = 1,
                first_column_index        = 1,
                maximum_number_of_rows    = 3,
                maximum_number_of_columns = 4,
            )

            # == Iterate the Printing Table State ==========================================

            ps = PrettyTables.PrintingTableState()

            # -- Table Header --------------------------------------------------------------

            for a in (:title, :subtitle)
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :table_header

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == a
                @test rs     == :table_header

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :table_header
            end

            # -- Column Labels -------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :column_labels

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_number_label
                @test rs     == :column_labels
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :stubhead_label
                @test rs     == :column_labels
                @test ps.i   == i

                for j in 1:4
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :column_label
                    @test rs     == :column_labels
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :column_labels
            end

            # -- Table Data ----------------------------------------------------------------

            for i in 1:3
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_number
                @test rs     == :data
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :row_label
                @test rs     == :data
                @test ps.i   == i

                for j in 1:4
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :data
                    @test rs     == :data
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :data
            end

            # -- Table Summary -------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :summary_row
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :summary_row_number
                @test rs     == :summary_row
                @test ps.i   == i

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :summary_row_label
                @test rs     == :summary_row
                @test ps.i   == i

                for j in 1:4
                    action, rs, ps = PrettyTables._next(ps, td)
                    @test action == :summary_row_cell
                    @test rs     == :summary_row
                    @test ps.i   == i
                    @test ps.j   == j
                end

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :summary_row
            end

            # -- Table Footer --------------------------------------------------------------

            for i in 1:2
                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :new_row
                @test rs     == :table_footer

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :footnote
                @test ps.i   == i
                @test rs     == :table_footer

                action, rs, ps = PrettyTables._next(ps, td)
                @test action == :end_row
                @test rs     == :table_footer
            end

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :new_row
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :source_notes
            @test rs     == :table_footer

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_row
            @test rs     == :table_footer

            # -- End Printing --------------------------------------------------------------

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_printing

            action, rs, ps = PrettyTables._next(ps, td)
            @test action == :end_printing
        end
    end
end
