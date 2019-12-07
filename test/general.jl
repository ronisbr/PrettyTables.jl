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
    (path, io) = mktemp()

    open(path,"w") do f
        write(f,"""
              This is one line.

              This is another line.

              <PrettyTables Table 1> This should be deleted.
              This should be deleted.
              This should be deleted.
              This should be deleted.
              This should be deleted.


              </PrettyTables>

              <PrettyTables Table 2></PrettyTables>

              <PrettyTables Table 3>This should not be deleted.
              This should not be deleted.
              This should not be deleted.
              This should not be deleted.""")
    end

    data_table_1 = [1 2 3
                    4 5 6]

    data_table_2 = [7 8 9
                    1 2 3]

    include_pt_in_file(path, "Table 2", data_table_2, tf = mysql, hlines = [1])
    include_pt_in_file(path, "Table 1", data_table_1, alignment = :c,
                       show_row_number = true)
    include_pt_in_file(path, "Table 3", data_table_2, alignment = :c,
                       show_row_number = true)

    result = read(path, String)

    expected = """
    This is one line.

    This is another line.

    <PrettyTables Table 1>
    ┌─────┬────────┬────────┬────────┐
    │ Row │ Col. 1 │ Col. 2 │ Col. 3 │
    ├─────┼────────┼────────┼────────┤
    │   1 │   1    │   2    │   3    │
    │   2 │   4    │   5    │   6    │
    └─────┴────────┴────────┴────────┘
    </PrettyTables>

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

    @test result == expected
end
