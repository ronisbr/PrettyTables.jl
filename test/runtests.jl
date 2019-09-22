using Test
using PrettyTables
using DataFrames

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

    # Cell override
    # ==========================================================================

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│ 1      │  false │  1.0   │ 1      │
│ 2      │   true │  2.0   │      2 │
│      3 │ false  │  3.0   │   3    │
│ 4      │   true │  4.0   │   4    │
│ 5      │  false │  5.0   │      5 │
│ 6      │   true │  6.0   │ 6      │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io, data)->pretty_table(io, data;
                                             alignment = [:l,:r,:c,:r],
                                             cell_alignment =
                                                Dict( (3,1) => :r,
                                                      (3,2) => :l,
                                                      (1,4) => :l,
                                                      (3,4) => :c,
                                                      (4,4) => :c,
                                                      (6,4) => :l )),
                    data)
    @test result == expected
end

# Filters
# ==============================================================================

@testset "Filters" begin
    expected = """
┌─────┬────────┬────────┐
│ Row │ Col. 1 │ Col. 3 │
├─────┼────────┼────────┤
│   2 │      2 │    2.0 │
│   4 │      4 │    4.0 │
│   6 │      6 │    6.0 │
└─────┴────────┴────────┘
"""

    result = sprint((io,data)->pretty_table(io, data;
                                            filters_row = ( (data,i) -> i%2 == 0,),
                                            filters_col = ( (data,i) -> i%2 == 1,),
                                            formatter = ft_printf("%.3",[3]),
                                            show_row_number = true), data)
    @test result == expected

    expected = """
┌─────┬────────┬────────┐
│ Row │ Col. 1 │ Col. 3 │
├─────┼────────┼────────┤
│   2 │   2    │ 2.0    │
│   4 │   4    │ 4.0    │
│   6 │   6    │ 6.0    │
└─────┴────────┴────────┘
"""

    result = sprint((io,data)->pretty_table(io, data;
                                            filters_row = ( (data,i) -> i%2 == 0,),
                                            filters_col = ( (data,i) -> i%2 == 1,),
                                            formatter = ft_printf("%.3",[3]),
                                            show_row_number = true,
                                            alignment = [:c,:l,:l,:c]), data)
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
    result = sprint(pretty_table, data, PrettyTables.compact)
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

    # Custom formats
    # ==========================================================================

    expected = """
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
"""

    tf = PrettyTableFormat(unicode, top_line = false, bottom_line = false)
    result = sprint(pretty_table, data, tf)
    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""

    tf = PrettyTableFormat(unicode, header_line = false)
    result = sprint(pretty_table, data, tf)
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

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
├........+........+........+........┤
│      3 │  false │    3.0 │      3 │
│      4 │   true │    4.0 │      4 │
├........+........+........+........┤
│      5 │  false │    5.0 │      5 │
│      6 │   true │    6.0 │      6 │
└────────┴────────┴────────┴────────┘
"""
    result = sprint((io,data)->
                    pretty_table(io,data;
                                 hlines = findall(x->x == true, data[:,2]),
                                 hlines_format = ('├','+','┤','.')), data)
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

# Hiding header and sub-header
# ==============================================================================

@testset "Hide header and sub-header" begin

    # Header
    # --------------------------------------------------------------------------

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

    # Sub-header
    # --------------------------------------------------------------------------

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

    header = [1 2 3 4; "this is" "a very very" "big" "sub-header"]
    result = sprint((io, data)->pretty_table(io, data, header; nosubheader = true),
                    data)
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

# Cropping
# ==============================================================================

@testset "Cropping" begin
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

    result = sprint((io,data)->pretty_table(io, data, screen_size = (10,10), crop = :none),
                    data)
    @test result == expected

    result = sprint((io,data)->pretty_table(io, data, screen_size = (-1,-1), crop = :both),
                    data)
    @test result == expected

    expected = """
┌────────┬────────┬────────┬ ⋯
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼ ⋯
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│   ⋮    │   ⋮    │   ⋮    │ ⋯
└────────┴────────┴────────┴ ⋯
"""

    result = sprint((io,data)->pretty_table(io, data, screen_size = (10,30), crop = :both),
                    data)
    @test result == expected

    result = sprint((io,data)->pretty_table(io, data, screen_size = (10,30)), data)
    @test result == expected

    expected = """
┌────────┬────────┬────────┬ ⋯
│ Col. 1 │ Col. 2 │ Col. 3 │ ⋯
├────────┼────────┼────────┼ ⋯
│      1 │  false │    1.0 │ ⋯
│      2 │   true │    2.0 │ ⋯
│      3 │  false │    3.0 │ ⋯
│      4 │   true │    4.0 │ ⋯
│      5 │  false │    5.0 │ ⋯
│      6 │   true │    6.0 │ ⋯
└────────┴────────┴────────┴ ⋯
"""

    result = sprint((io,data)->pretty_table(io, data, screen_size = (10,30), crop = :horizontal),
                    data)
    @test result == expected

    result = sprint((io,data)->pretty_table(io, data, screen_size = (-1,30), crop = :both),
                    data)
    @test result == expected

    expected = """
┌────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │
├────────┼────────┼────────┼────────┤
│      1 │  false │    1.0 │      1 │
│      2 │   true │    2.0 │      2 │
│   ⋮    │   ⋮    │   ⋮    │   ⋮    │
└────────┴────────┴────────┴────────┘
"""

    result = sprint((io,data)->pretty_table(io, data, screen_size = (10,30), crop = :vertical),
                    data)
    @test result == expected

    result = sprint((io,data)->pretty_table(io, data, screen_size = (10,-1), crop = :both),
                    data)
    @test result == expected
end

# Dictionaries
# ==============================================================================

@testset "Dictionaries" begin
    dict = Dict{Int64,String}(1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr",
                              5 => "May", 6 => "Jun")

    expected = """
┌───────┬────────┐
│  Keys │ Values │
│ Int64 │ String │
├───────┼────────┤
│     1 │    Jan │
│     2 │    Feb │
│     3 │    Mar │
│     4 │    Apr │
│     5 │    May │
│     6 │    Jun │
└───────┴────────┘
"""

    result = sprint((io,dict)->pretty_table(io, dict, sortkeys = true), dict)
    @test result == expected
end

# Test if we can print `missing` and `nothing`
# ==============================================================================

@testset "Print missing and nothing" begin
    matrix = [missing missing; nothing nothing; missing nothing]

    expected = """
┌─────────┬─────────┐
│  Col. 1 │  Col. 2 │
├─────────┼─────────┤
│ missing │ missing │
│ nothing │ nothing │
│ missing │ nothing │
└─────────┴─────────┘
"""

    result = sprint(pretty_table, matrix)
    @test result == expected
end

# Helpers
# ==============================================================================

@testset "@pt" begin
    # To get the output of the macro @pt, we must redirect the stdout.
    old_stdout = stdout
    in, out    = redirect_stdout()

    # The configurations must not interfere with the printings of any type
    # except for the `Dict`.
    @ptconf sortkeys = true

    # Test 1
    # --------------------------------------------------------------------------

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

    @ptconf tf = ascii_dots
    @pt :header = ["1","2","3","4"] data

    result = String(readavailable(in))
    @test result == expected

    # Test 2
    # --------------------------------------------------------------------------

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

    @ptconf tf = unicode_rounded
    @ptconf alignment = :c
    @pt data

    result = String(readavailable(in))
    @test result == expected

    # Test 3
    # --------------------------------------------------------------------------

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

    header = ["Column 1" "Column 2"; "Sub. 1" "Sub. 2"]

    @ptconfclean
    @ptconf tf = ascii_rounded
    @pt :header = header [1 2; 3 4; 5 6]

    result = String(readavailable(in))
    @test result == expected

    # Test 4
    # --------------------------------------------------------------------------

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
    @pt d = Dict(Int64(1) => "São José dos Campos",
                 Int64(2) => "SP",
                 Int64(3) => "Brasil")

    result = String(readavailable(in))
    @test result == expected

    # Restore the original stdout.
    close(in)
    close(out)
    redirect_stdout(old_stdout)

    # The expression after `@pt` must be evaluated. Hence, `d` must be a dict
    # with the defined elements.
    @test d isa Dict
    @test d[1] == "São José dos Campos"
    @test d[2] == "SP"
    @test d[3] == "Brasil"
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

# Issue #9
# ==============================================================================

@testset "Issue #9 - Printing table with row number column and sub-headers" begin
    expected = """
┌─────┬───┬───────┬─────┬────┐
│ Row │ 1 │     2 │   3 │  4 │
│     │ 5 │     6 │   7 │  8 │
│     │ 9 │    10 │  11 │ 12 │
├─────┼───┼───────┼─────┼────┤
│   1 │ 1 │ false │ 1.0 │  1 │
│   2 │ 2 │  true │ 2.0 │  2 │
│   3 │ 3 │ false │ 3.0 │  3 │
│   4 │ 4 │  true │ 4.0 │  4 │
│   5 │ 5 │ false │ 5.0 │  5 │
│   6 │ 6 │  true │ 6.0 │  6 │
└─────┴───┴───────┴─────┴────┘
"""
    result = sprint((io, data)->pretty_table(io, data, [1  2  3  4;
                                                        5  6  7  8;
                                                        9 10 11 12];
                                            show_row_number = true), data)
    @test result == expected
end

# Issue #10
# ==============================================================================

@testset "Issue #10 - Size of the row number column without header" begin
    v = 0:1:6

    expected = """
┌───┬───┐
│ 1 │ 0 │
│ 2 │ 1 │
│ 3 │ 2 │
│ 4 │ 3 │
│ 5 │ 4 │
│ 6 │ 5 │
│ 7 │ 6 │
└───┴───┘
"""

    result = sprint((io, v)->pretty_table(io, v; noheader = true,
                                          show_row_number = true), v)
    @test result == expected
end

# Issue #16
# ==============================================================================

@testset "Issue #16 - Printing DataFrames that contains strings" begin
    df = DataFrame(:a => Int64[1, 2], :b => ["A", "B"]);

    expected = """
┌───────┬────────┐
│     a │      b │
│ Int64 │ String │
├───────┼────────┤
│     1 │      A │
│     2 │      B │
└───────┴────────┘
"""

    result = sprint(pretty_table, df)

    @test result == expected
end
