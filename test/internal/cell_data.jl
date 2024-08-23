## Description #############################################################################
#
# Tests related to the internal functions that return the cell data.
#
############################################################################################

@testset "Cell Data" begin
    # == Create the Table Data =============================================================

    data = [
        1  2  3  4
        5  6  7  8
        9 10 11 12
    ]

    td = PrettyTables.TableData(
        ;
        data,
        title                       = "Table Title",
        subtitle                    = "Table Subtitle",
        column_labels               = [["1-1", "1-2", "1-3", "1-4"], ["2-1", "2-2", "2-3", "2-4"]],
        stubhead_label              = "Stubhead Label",
        show_row_number_column      = true,
        row_number_column_label     = "Row Number",
        row_labels                  = ["Row 1", "Row 2", "Row 3"],
        summary_rows                = [(data, j) -> 20j, (data, j) -> 30j],
        summary_row_labels          = PrettyTables.SummaryRowLabelIterator(2),
        footnotes                   = [(:data, 1, 1) => "Footnote 1", (:data, 2, 2) => "Footnote 2"],
        source_notes                = "Source Notes",
        data_alignment              = [:l, :c, :r, :l],
        column_label_alignment      = [:r, :r, :l, :c],
        row_label_alignment         = :r,
        row_number_column_alignment = :c,
        num_rows                    = 3,
        num_columns                 = 4,
        formatters                  = [(v, i, j) -> i == 2 ? v + 10 : v,],
    )

    # == Iterate the Printing Table ps ==================================================

    ps = PrettyTables.PrintingTableState()

    # -- Table Header ----------------------------------------------------------------------

    # .. Table Title .......................................................................

    action, rs, ps = PrettyTables._next(ps, td)

    action, rs, ps = PrettyTables._next(ps, td)
    cell = PrettyTables._current_cell(action, ps, td)
    @test cell == "Table Title"

    action, rs, ps = PrettyTables._next(ps, td)

    # .. Table Subtitle ....................................................................

    action, rs, ps = PrettyTables._next(ps, td)

    action, rs, ps = PrettyTables._next(ps, td)
    cell = PrettyTables._current_cell(action, ps, td)
    @test cell == "Table Subtitle"

    action, rs, ps = PrettyTables._next(ps, td)

    # -- Column Labels ---------------------------------------------------------------------

    for i in 1:2
        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == (i == 1 ? "Row Number" : "")

        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == (i == 1 ? "Stubhead Label" : "")

        for j in 1:4
            action, rs, ps = PrettyTables._next(ps, td)
            cell = PrettyTables._current_cell(action, ps, td)
            @test cell == "$i-$j"
        end

        action, rs, ps = PrettyTables._next(ps, td)
    end

    # -- Table Data ------------------------------------------------------------------------

    for i in 1:3
        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == i

        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == "Row $i"

        for j in 1:4
            action, rs, ps = PrettyTables._next(ps, td)
            cell = PrettyTables._current_cell(action, ps, td)
            # Notice that we have a formatter that changes the second line.
            @test cell == (i - 1) * 4 + j + ((i == 2) ? 10 : 0)
        end

        action, rs, ps = PrettyTables._next(ps, td)
    end

    # -- Table Summary ---------------------------------------------------------------------

    for i in 1:2
        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == ""

        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == "Summary $i"

        for j in 1:4
            action, rs, ps = PrettyTables._next(ps, td)
            cell = PrettyTables._current_cell(action, ps, td)
            @test cell == (10i  + 10) * j
        end

        action, rs, ps = PrettyTables._next(ps, td)
    end

    # -- Footnotes -------------------------------------------------------------------------

    for i in 1:2
        action, rs, ps = PrettyTables._next(ps, td)

        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == "Footnote $i"

        action, rs, ps = PrettyTables._next(ps, td)
    end

    # -- Source Notes ----------------------------------------------------------------------

    action, rs, ps = PrettyTables._next(ps, td)

    action, rs, ps = PrettyTables._next(ps, td)
    cell = PrettyTables._current_cell(action, ps, td)
    @test cell == "Source Notes"

    action, rs, ps = PrettyTables._next(ps, td)
end
