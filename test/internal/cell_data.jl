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
        summary_cell                = (data, j) -> 20j,
        summary_row_label           = "Summary",
        footnotes                   = [(1, 1) => "Footnote", (2, 2) => "Footnote"],
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

    action, rs, ps = PrettyTables._next(ps, td)
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

    action, rs, ps = PrettyTables._next(ps, td)

    action, rs, ps = PrettyTables._next(ps, td)
    cell = PrettyTables._current_cell(action, ps, td)
    @test cell == 4

    action, rs, ps = PrettyTables._next(ps, td)
    cell = PrettyTables._current_cell(action, ps, td)
    @test cell == "Summary"

    for j in 1:4
        action, rs, ps = PrettyTables._next(ps, td)
        cell = PrettyTables._current_cell(action, ps, td)
        @test cell == 20j
    end
end
