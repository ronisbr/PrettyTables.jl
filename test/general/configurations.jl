## Description #############################################################################
#
# Tests of the configuration framework.
#
############################################################################################

@testset "Configurations" begin
    data = [1 2 3
            4 5 6]

    conf1 = set_pt_conf(tf = tf_markdown)
    conf2 = set_pt_conf(tf = tf_ascii_dots, formatters = ft_printf("%5.3d"))
    set_pt_conf!(conf2, hlinetf_s = :none)

    expected = """
| Col. 1 | Col. 2 | Col. 3 |
|--------|--------|--------|
|      1 |      2 |      3 |
|      4 |      5 |      6 |
"""

    result = pretty_table_with_conf(conf1, String, data)
    @test result == expected

    expected = """
: Col. 1 : Col. 2 : Col. 3 :
:    001 :    002 :    003 :
:    004 :    005 :    006 :
"""

    clear_pt_conf!(conf2)
    expected = pretty_table(String, data)
    result = pretty_table_with_conf(conf2, String, data)

    @test result == expected
end

@testset "@pt" begin
    # To get the output of the macro @pt, we must redirect the stdout.
    old_stdout = stdout
    in, out    = redirect_stdout()

    # The configurations must not interfere with the printings of any type
    # except for the `Dict`.
    @ptconf sortkeys = true

    # == Test 1 ============================================================================

    expected = """
.......................
: 1 :     2 :   3 : 4 :
:...:.......:.....:...:
: 1 : false : 1.0 : 1 :
: 2 :  true : 2.0 : 2 :
: 3 : false : 3.0 : 3 :
: 4 :  true : 4.0 : 4 :
: 5 : false : 5.0 : 5 :
: 6 :  true : 6.0 : 6 :
:...:.......:.....:...:
"""

    @ptconf tf = tf_ascii_dots
    @pt :header = ["1", "2", "3", "4"] data

    result = String(readavailable(in))
    @test result == expected

    # == Test 2 ============================================================================

    expected = """
╭────────┬────────┬────────┬────────╮
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│   1    │ false  │  1.0   │   1    │
│   2    │  true  │  2.0   │   2    │
│   3    │ false  │  3.0   │   3    │
│   4    │  true  │  4.0   │   4    │
│   5    │ false  │  5.0   │   5    │
│   6    │  true  │  6.0   │   6    │
╰────────┴────────┴────────┴────────╯
"""

    @ptconf tf = tf_unicode_rounded
    @ptconf alignment = :c
    @pt data

    result = String(readavailable(in))
    @test result == expected

    # == Test 3 ============================================================================

    expected = """
.----------.----------.
| Column 1 | Column 2 |
|   Sub. 1 |   Sub. 2 |
:----------+----------:
|        1 |        2 |
|        3 |        4 |
|        5 |        6 |
'----------'----------'
"""

header = (["Column 1", "Column 2"], ["Sub. 1", "Sub. 2"])

    @ptconfclean
    @ptconf tf = tf_ascii_rounded
    @pt :header = header [1 2; 3 4; 5 6]

    result = String(readavailable(in))
    @test result == expected

    # == Test 4 ============================================================================

    expected = """
.-------.---------------------.
| Keys  | Values              |
| Int64 | String              |
:-------+---------------------:
| 1     | São José dos Campos |
| 2     | SP                  |
| 3     | Brasil              |
'-------'---------------------'
"""

    @ptconf sortkeys = true
    @ptconf alignment = :l
    @pt d = Dict(
        Int64(1) => "São José dos Campos",
        Int64(2) => "SP",
        Int64(3) => "Brasil"
    )

    result = String(readavailable(in))
    @test result == expected

    # Restore the original stdout.
    close(in)
    close(out)
    redirect_stdout(old_stdout)

    # The expression after `@pt` must be evaluated. Hence, `d` must be a dict with the
    # defined elements.
    @test d isa Dict
    @test d[1] == "São José dos Campos"
    @test d[2] == "SP"
    @test d[3] == "Brasil"

    # Clean configurations to avoid test failures if this is run in the same section.
    @ptconfclean
end

@testset "Issue #107" begin
    # To get the output of the macro @pt, we must redirect the stdout.
    old_stdout = stdout
    in, out    = redirect_stdout()

    tf_compact2 = TextFormat(
        up_right_corner = '─',
        up_left_corner      = '─',
        bottom_left_corner  = '─',
        bottom_right_corner = '─',
        up_intersection     = '─',
        left_intersection   = '─',
        right_intersection  = '─',
        middle_intersection = '─',
        bottom_intersection = '─',
        column              = ' ',
        row                 = '─',
        hlines              = [:begin, :header, :end],
        vlines              = :all
    );

    expected = """
─────────────────────────────────────
  Col. 1   Col. 2   Col. 3   Col. 4
─────────────────────────────────────
       1    false      1.0        1
       2     true      2.0        2
       3    false      3.0        3
       4     true      4.0        4
       5    false      5.0        5
       6     true      6.0        6
─────────────────────────────────────
"""

    @ptconf tf = tf_compact2
    @pt data

    result = String(readavailable(in))
    @test result == expected

    # Restore the original stdout.
    close(in)
    close(out)
    redirect_stdout(old_stdout)

    @ptconfclean
end
