# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to general functions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Include table in file
# ==============================================================================

@testset "Include Pretty Table to file" begin

    # Text
    # ==========================================================================

    path = "test.txt"

    orig = """
    This is one line.

    This is "another" line.

    % <PrettyTables Table 1> This should be deleted.
    This should be deleted.
    This should be deleted.
    This should be deleted.
    This should be deleted.


    % </PrettyTables>

    <PrettyTables Table 2></PrettyTables>

    <PrettyTables Table 3>This should not be deleted.
    This should not be deleted.
    This should not be deleted.
    This should not be deleted."""

    open(path,"w") do f
        write(f, orig)
    end

    data_table_1 = [1 2 3
                    4 5 6]

    data_table_2 = [7 8 9
                    1 2 3]

    include_pt_in_file(path, "Table 2", data_table_2, tf = mysql, hlines = [1])
    include_pt_in_file(path, "Table 1", data_table_1, alignment = :c,
                       show_row_number = true, backup_file = false)
    include_pt_in_file(path, "Table 3", data_table_2, alignment = :c,
                       show_row_number = true, backup_file = false)

    result = read(path, String)
    backup = read(path * "_backup", String)

    expected = """
    This is one line.

    This is "another" line.

    % <PrettyTables Table 1>
    ┌─────┬────────┬────────┬────────┐
    │ Row │ Col. 1 │ Col. 2 │ Col. 3 │
    ├─────┼────────┼────────┼────────┤
    │   1 │   1    │   2    │   3    │
    │   2 │   4    │   5    │   6    │
    └─────┴────────┴────────┴────────┘
    % </PrettyTables>

    <PrettyTables Table 2>
    +--------+--------+--------+
    | Col. 1 | Col. 2 | Col. 3 |
    +--------+--------+--------+
    |      7 |      8 |      9 |
    +--------+--------+--------+
    |      1 |      2 |      3 |
    +--------+--------+--------+
    </PrettyTables>

    <PrettyTables Table 3>This should not be deleted.
    This should not be deleted.
    This should not be deleted.
    This should not be deleted."""

    @test backup == orig
    @test result == expected

    # HTML
    # ==========================================================================

    data_table_1 = [1 2 3
                    4 5 6]

    path = "test.html"

    orig = """
    <html>
    <body>

    <p>This is a table:</p>

    <!-- <PrettyTables Table 1> -->
    <!-- </PrettyTables> -->

    </body>
    </html>
    """

    open(path,"w") do f
        write(f, orig)
    end

    data_table_1 = [1 2 3
                    4 5 6]

    include_pt_in_file(path, "Table 1", data_table_1, backend = :html,
                       minimal = true, tag_append = " -->")

    result = read(path, String)
    backup = read(path * "_backup", String)

    expected = """
    <html>
    <body>

    <p>This is a table:</p>

    <!-- <PrettyTables Table 1> -->
    <table>
    <tr class = "header headerLastRow">
    <th style = "text-align: right; ">Col. 1</th>
    <th style = "text-align: right; ">Col. 2</th>
    <th style = "text-align: right; ">Col. 3</th>
    </tr>
    <tr>
    <td style = "text-align: right; ">1</td>
    <td style = "text-align: right; ">2</td>
    <td style = "text-align: right; ">3</td>
    </tr>
    <tr>
    <td style = "text-align: right; ">4</td>
    <td style = "text-align: right; ">5</td>
    <td style = "text-align: right; ">6</td>
    </tr>
    </table>
    <!-- </PrettyTables> -->

    </body>
    </html>
    """

    @test backup == orig
    @test result == expected
end
