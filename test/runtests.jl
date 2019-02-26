using Test
using PrettyTables

data = Any[1    false      1.0     0x01 ;
           2     true      2.0     0x02 ;
           3    false      3.0     0x03 ;
           4     true      4.0     0x04 ;
           5    false      5.0     0x05 ;
           6     true      6.0     0x06 ;]

# Default
# ==============================================================================

@testset "Default" begin

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = sprint(pretty_table, data)
    @test result == expected
end

# Alignments
# ==============================================================================

@testset "Alignments" begin
    # Left
    # ==========================================================================
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ 1      │ false  │ 1.0    │ 1      │
│ 2      │ true   │ 2.0    │ 2      │
│ 3      │ false  │ 3.0    │ 3      │
│ 4      │ true   │ 4.0    │ 4      │
│ 5      │ false  │ 5.0    │ 5      │
│ 6      │ true   │ 6.0    │ 6      │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io, data)->pretty_table(io, data; alignment = :l), data)
    @test result == expected

    # Center
    # ==========================================================================
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│   1    │ false  │  1.0   │   1    │
│   2    │  true  │  2.0   │   2    │
│   3    │ false  │  3.0   │   3    │
│   4    │  true  │  4.0   │   4    │
│   5    │ false  │  5.0   │   5    │
│   6    │  true  │  6.0   │   6    │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io, data)->pretty_table(io, data; alignment = :c), data)
    @test result == expected

    # Per column configuration
    # ==========================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ 1      │  false │  1.0   │      1 │
│ 2      │   true │  2.0   │      2 │
│ 3      │  false │  3.0   │      3 │
│ 4      │   true │  4.0   │      4 │
│ 5      │  false │  5.0   │      5 │
│ 6      │   true │  6.0   │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io, data)->pretty_table(io, data; 
                                             alignment = [:l,:r,:c,:r]),
                    data)
    @test result == expected
end

# Formatter
# ==============================================================================

@testset "Formatter" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │      1 │      1 │
│      0 │   true │      0 │      0 │
│      3 │  false │      3 │      3 │
│      0 │   true │      0 │      0 │
│      5 │  false │      5 │      5 │
│      0 │   true │      0 │      0 │
└────────┴────────┴────────┴────────┘
"""
    formatter = Dict(0 => (v,i) -> isodd(i) ? i : 0,
                     2 => (v,i) -> v)
    result = sprint((io, data)->pretty_table(io, data; 
                                             formatter = formatter), data)
    @test result == expected
end

# Show row number
# ==============================================================================

@testset "Show row number" begin
    expected = """
┌─────┬────────┬────────┬────────┬────────┐
│ Row │ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├─────┼────────┼────────┼────────┼────────┤
│   1 │ 1      │  false │  1.0   │      1 │
│   2 │ 2      │   true │  2.0   │      2 │
│   3 │ 3      │  false │  3.0   │      3 │
│   4 │ 4      │   true │  4.0   │      4 │
│   5 │ 5      │  false │  5.0   │      5 │
│   6 │ 6      │   true │  6.0   │      6 │
└─────┴────────┴────────┴────────┴────────┘
"""
    result = sprint((io, data)->pretty_table(io, data; 
                                             alignment       = [:l,:r,:c,:r],
                                             show_row_number = true),
                    data)
    @test result == expected
end

# Pre-defined formats
# ==============================================================================

@testset "Pre-defined formats" begin

    # ascii_dots
    # ==========================================================================
    expected = """
.....................................
: Col. 1 : Col. 2 : Col. 3 : Col. 4 :
:........:........:........:........:
:      1 :  false :    1.0 :      1 :
:      2 :   true :    2.0 :      2 :
:      3 :  false :    3.0 :      3 :
:      4 :   true :    4.0 :      4 :
:      5 :  false :    5.0 :      5 :
:      6 :   true :    6.0 :      6 :
:........:........:........:........:
"""
    result = sprint(pretty_table, data, ascii_dots)
    @test result == expected

    # ascii_rounded
    # ==========================================================================
    expected = """
.--------.--------.--------.--------.
| Col. 1 | Col. 2 | Col. 3 | Col. 4 |
:--------+--------+--------+--------:
|      1 |  false |    1.0 |      1 |
|      2 |   true |    2.0 |      2 |
|      3 |  false |    3.0 |      3 |
|      4 |   true |    4.0 |      4 |
|      5 |  false |    5.0 |      5 |
|      6 |   true |    6.0 |      6 |
'--------'--------'--------'--------'
"""
    result = sprint(pretty_table, data, ascii_rounded)
    @test result == expected

    # borderless
    # ==========================================================================
    expected = """
  Col. 1   Col. 2   Col. 3   Col. 4  
                                     
       1    false      1.0        1  
       2     true      2.0        2  
       3    false      3.0        3  
       4     true      4.0        4  
       5    false      5.0        5  
       6     true      6.0        6  
"""
    result = sprint(pretty_table, data, borderless)
    @test result == expected

    # compact
    # ==========================================================================
    expected = """
 -------- -------- -------- -------- 
  Col. 1   Col. 2   Col. 3   Col. 4  
 -------- -------- -------- -------- 
       1    false      1.0        1  
       2     true      2.0        2  
       3    false      3.0        3  
       4     true      4.0        4  
       5    false      5.0        5  
       6     true      6.0        6  
 -------- -------- -------- -------- 
"""
    result = sprint(pretty_table, data, compact)
    @test result == expected

    # markdown
    # ==========================================================================
    expected = """
| Col. 1 | Col. 2 | Col. 3 | Col. 4 |
|--------|--------|--------|--------|
|      1 |  false |    1.0 |      1 |
|      2 |   true |    2.0 |      2 |
|      3 |  false |    3.0 |      3 |
|      4 |   true |    4.0 |      4 |
|      5 |  false |    5.0 |      5 |
|      6 |   true |    6.0 |      6 |
"""
    result = sprint(pretty_table, data, markdown)
    @test result == expected

    # mysql
    # ==========================================================================
    expected = """
+--------+--------+--------+--------+
| Col. 1 | Col. 2 | Col. 3 | Col. 4 |
+--------+--------+--------+--------+
|      1 |  false |    1.0 |      1 |
|      2 |   true |    2.0 |      2 |
|      3 |  false |    3.0 |      3 |
|      4 |   true |    4.0 |      4 |
|      5 |  false |    5.0 |      5 |
|      6 |   true |    6.0 |      6 |
+--------+--------+--------+--------+
"""
    result = sprint(pretty_table, data, mysql)
    @test result == expected

    # simple
    # ==========================================================================
    expected = """
========= ======== ======== =========
  Col. 1   Col. 2   Col. 3   Col. 4  
========= ======== ======== =========
       1    false      1.0        1  
       2     true      2.0        2  
       3    false      3.0        3  
       4     true      4.0        4  
       5    false      5.0        5  
       6     true      6.0        6  
========= ======== ======== =========
"""
    result = sprint(pretty_table, data, simple)
    @test result == expected

    # unicode_rounded
    # ==========================================================================
    expected = """
╭────────┬────────┬────────┬────────╮
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
╰────────┴────────┴────────┴────────╯
"""
    result = sprint(pretty_table, data, unicode_rounded)
    @test result == expected
end

# Pre-defined formatters
# ==============================================================================

@testset "Pre-defined formatters" begin

    # ft_round
    # ==========================================================================
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│    1.0 │    0.0 │    1.0 │    1.0 │
│    2.0 │    1.0 │    2.0 │    2.0 │
│    3.0 │    0.0 │    3.0 │    3.0 │
│    4.0 │    1.0 │    4.0 │    4.0 │
│    5.0 │    0.0 │    5.0 │    5.0 │
│    6.0 │    1.0 │    6.0 │    6.0 │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io,data)->pretty_table(io,data;
                                            formatter = ft_round(1)),
                    data)
    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│    1.0 │  false │    1.0 │      1 │
│    2.0 │   true │    2.0 │      2 │
│    3.0 │  false │    3.0 │      3 │
│    4.0 │   true │    4.0 │      4 │
│    5.0 │  false │    5.0 │      5 │
│    6.0 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io,data)->pretty_table(io,data;
                                            formatter = ft_round(1,[3,1])),
                    data)
    @test result == expected

    # ft_printf
    # ==========================================================================

    expected = """
┌──────────┬──────────┬──────────┬──────────┐
│   Col. 1 │   Col. 2 │   Col. 3 │   Col. 4 │
├──────────┼──────────┼──────────┼──────────┤
│    1.000 │    0.000 │    1.000 │    1.000 │
│    2.000 │    1.000 │    2.000 │    2.000 │
│    3.000 │    0.000 │    3.000 │    3.000 │
│    4.000 │    1.000 │    4.000 │    4.000 │
│    5.000 │    0.000 │    5.000 │    5.000 │
│    6.000 │    1.000 │    6.000 │    6.000 │
└──────────┴──────────┴──────────┴──────────┘
"""
    result = sprint((io,data)->pretty_table(io,data;
                                            formatter = ft_printf("%8.3f")),
                    data)
    @test result == expected

    expected = """
┌──────────┬────────┬────────┬──────────┐
│   Col. 1 │ Col. 2 │ Col. 3 │   Col. 4 │
├──────────┼────────┼────────┼──────────┤
│    1.000 │  false │    1.0 │    1.000 │
│    2.000 │   true │    2.0 │    2.000 │
│    3.000 │  false │    3.0 │    3.000 │
│    4.000 │   true │    4.0 │    4.000 │
│    5.000 │  false │    5.0 │    5.000 │
│    6.000 │   true │    6.0 │    6.000 │
└──────────┴────────┴────────┴──────────┘
"""
    result = sprint((io,data)->
                    pretty_table(io,data; formatter = ft_printf("%8.3f",[1,4])),
                    data)
    @test result == expected

    expected = """
┌──────────┬────────┬────────┬──────────┐
│   Col. 1 │ Col. 2 │ Col. 3 │   Col. 4 │
├──────────┼────────┼────────┼──────────┤
│     1.00 │  false │    1.0 │   1.0000 │
│     2.00 │   true │    2.0 │   2.0000 │
│     3.00 │  false │    3.0 │   3.0000 │
│     4.00 │   true │    4.0 │   4.0000 │
│     5.00 │  false │    5.0 │   5.0000 │
│     6.00 │   true │    6.0 │   6.0000 │
└──────────┴────────┴────────┴──────────┘
"""
    result = sprint((io,data)->
                    pretty_table(io,data;
                                 formatter = ft_printf(["%8.2f","%8.4f"],[1,4])),
                    data)
    @test result == expected
end

# Sub-headers
# ==============================================================================

@testset "Sub-headers" begin
    expected = """
┌───┬───────┬─────┬───┐
│ 1 │     2 │   3 │ 4 │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""
    result = sprint(pretty_table, data, [1;2;3;4])
    @test result == expected

    result = sprint(pretty_table, data, [1 2 3 4])
    @test result == expected

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │     2 │   3 │ 4 │
│ 5 │     6 │   7 │ 8 │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""
    result = sprint(pretty_table, data, [1 2 3 4; 5 6 7 8])
    @test result == expected
end

# Horizontal lines
# ==============================================================================

@testset "Horizontal lines" begin
    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
├────────┼────────┼────────┼────────┤
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
├────────┼────────┼────────┼────────┤
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io,data)->
                    pretty_table(io,data; hlines = findall(x->x == true, data[:,2])),
                    data)
    @test result == expected
end

# Line breaks inside cells
# ==============================================================================

@testset "Line breaks inside cells" begin
    data = ["This line contains\nthe velocity [m/s]" 10.0;
            "This line contains\nthe acceleration [m/s^2]" 1.0;
            "This line contains\nthe time from the\nbeginning of the simulation" 10;]

    header = ["Information", "Value"]

    expected = """
┌─────────────────────────────┬───────┐
│                 Information │ Value │
├─────────────────────────────┼───────┤
│          This line contains │  10.0 │
│          the velocity [m/s] │       │
│          This line contains │   1.0 │
│    the acceleration [m/s^2] │       │
│          This line contains │    10 │
│           the time from the │       │
│ beginning of the simulation │       │
└─────────────────────────────┴───────┘
"""

    result = sprint((io,data)->pretty_table(io,data,header; linebreaks = true),
                    data)
    @test result == expected

    expected = """
┌─────────────────────────────┬───────┐
│         Information         │ Value │
├─────────────────────────────┼───────┤
│     This line contains      │ 10.0  │
│     the velocity [m/s]      │       │
│     This line contains      │  1.0  │
│  the acceleration [m/s^2]   │       │
│     This line contains      │  10   │
│      the time from the      │       │
│ beginning of the simulation │       │
└─────────────────────────────┴───────┘
"""

    result = sprint((io,data)->pretty_table(io,data,header;
                                            alignment = :c,
                                            linebreaks = true),
                    data)
    @test result == expected

    expected = """
┌─────────────────────────────┬───────┐
│ Information                 │ Value │
├─────────────────────────────┼───────┤
│ This line contains          │ 10.0  │
│ the velocity [m/s]          │       │
│ This line contains          │ 1.0   │
│ the acceleration [m/s^2]    │       │
│ This line contains          │ 10    │
│ the time from the           │       │
│ beginning of the simulation │       │
└─────────────────────────────┴───────┘
"""

    result = sprint((io,data)->pretty_table(io,data,header;
                                            alignment = :l,
                                            linebreaks = true),
                    data)
    @test result == expected

    expected = """
┌────────────────────────────────────────────────────────────────────┬───────┐
│                                                        Information │ Value │
├────────────────────────────────────────────────────────────────────┼───────┤
│                             This line contains\\nthe velocity [m/s] │  10.0 │
│                       This line contains\\nthe acceleration [m/s^2] │   1.0 │
│ This line contains\\nthe time from the\\nbeginning of the simulation │    10 │
└────────────────────────────────────────────────────────────────────┴───────┘
"""

    result = sprint(pretty_table, data, header)
    @test result == expected
end

# Line breaks inside cells
# ==============================================================================

@testset "Hide header" begin

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    result = sprint((io, data)->pretty_table(io, data; noheader = true), data)
    @test result == expected

    result = sprint((io, data)->pretty_table(io, data, [1 2]; noheader = true),
                    data)
    @test result == expected

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │ false │ 1.0 │ 1 │
│ 2 │ true  │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │ true  │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │ true  │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""
    result = sprint((io, data)->pretty_table(io, data, [1 2]; alignment = :l,
                                             noheader = true), data)
    @test result == expected
end

# Print vectors
# ==============================================================================

@testset "Print vectors" begin

    vec = 0:1:10

    expected = """
┌────────┐
│ Col. 1 │
├────────┤
│      0 │
│      1 │
│      2 │
│      3 │
│      4 │
│      5 │
│      6 │
│      7 │
│      8 │
│      9 │
│     10 │
└────────┘
"""

    result = sprint(pretty_table, vec)
    @test result == expected

    expected = """
┌─────┬────────┐
│ Row │ Col. 1 │
├─────┼────────┤
│   1 │   0    │
│   2 │   1    │
│   3 │   2    │
│   4 │   3    │
│   5 │   4    │
│   6 │   5    │
│   7 │   6    │
│   8 │   7    │
│   9 │   8    │
│  10 │   9    │
│  11 │   10   │
└─────┴────────┘
"""

    result = sprint((io, vec)->pretty_table(io, vec; alignment = :c,
                                            show_row_number = true), vec)
    @test result == expected

    expected = """
┌────────────┐
│     Header │
│ Sub-header │
├────────────┤
│          0 │
│          1 │
│          2 │
│          3 │
│          4 │
│          5 │
│          6 │
│          7 │
│          8 │
│          9 │
│         10 │
└────────────┘
"""

    result = sprint((io, vec)->pretty_table(io, vec, ["Header", "Sub-header"]),
                    vec)
    @test result == expected

    @test_throws Exception pretty_table(vec, ["1" "1"])
end

# Issue #4
# ==============================================================================

@testset "Issue #4 - Header with escape sequences" begin

    expected = """
┌───┬───────┬─────┬───┐
│ 1 │   2\\n │   3 │ 4 │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    result = sprint(pretty_table, data, ["1" "2\n" "3" "4"])
    @test result == expected
end
