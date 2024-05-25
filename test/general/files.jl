## Description #############################################################################
#
# Tests related to including a table in a file.
#
############################################################################################

@testset "Include Pretty Table to File" begin

    # == Text ==============================================================================

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

    data_table_1 = [
        1 2 3
        4 5 6
    ]

    data_table_2 = [
        7 8 9
        1 2 3
    ]

    include_pt_in_file(
        path,
        "Table 2",
        data_table_2;
        tf = tf_mysql,
        body_hlines = [1]
    )

    include_pt_in_file(
        path,
        "Table 1",
        data_table_1;
        alignment = :c,
        show_row_number = true,
        backup_file = false
    )

    include_pt_in_file(
        path,
        "Table 3",
        data_table_2;
        alignment = :c,
        show_row_number = true,
        backup_file = false
    )

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

    # == HTML (`tag_append` option) ========================================================

    data_table_1 = [
        1 2 3
        4 5 6
    ]

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

    data_table_1 = [
        1 2 3
        4 5 6
    ]

    include_pt_in_file(
        path,
        "Table 1",
        data_table_1;
        backend = Val(:html),
        standalone = false,
        tag_append = " -->"
    )

    result = read(path, String)
    backup = read(path * "_backup", String)

    expected = """
    <html>
    <body>

    <p>This is a table:</p>

    <!-- <PrettyTables Table 1> -->
    <table>
      <thead>
        <tr class = "header headerLastRow">
          <th style = "text-align: right;">Col. 1</th>
          <th style = "text-align: right;">Col. 2</th>
          <th style = "text-align: right;">Col. 3</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td style = "text-align: right;">1</td>
          <td style = "text-align: right;">2</td>
          <td style = "text-align: right;">3</td>
        </tr>
        <tr>
          <td style = "text-align: right;">4</td>
          <td style = "text-align: right;">5</td>
          <td style = "text-align: right;">6</td>
        </tr>
      </tbody>
    </table>
    <!-- </PrettyTables> -->

    </body>
    </html>
    """

    @test backup == orig
    @test result == expected

    # == Markdown (`remove_tags` option) ===================================================

    data_table_1 = [
        1 2 3
        4 5 6
    ]

    path = "test.md"

    orig = """
    # Markdown

    This is a markdown table.

    <PrettyTables Table 1> This should be removed.
    This should be removed.
    This should be removed.
    This should be removed.
    This should be removed.
    </PrettyTables>
    """

    open(path,"w") do f
        write(f, orig)
    end

    data_table_1 = [
        1 2 3
        4 5 6
    ]

    include_pt_in_file(
        path,
        "Table 1",
        data_table_1;
        tf = tf_markdown,
        remove_tags = true
    )

    result = read(path, String)
    backup = read(path * "_backup", String)

    expected = """
    # Markdown

    This is a markdown table.

    | Col. 1 | Col. 2 | Col. 3 |
    |--------|--------|--------|
    |      1 |      2 |      3 |
    |      4 |      5 |      6 |

    """

    @test backup == orig
    @test result == expected
end
