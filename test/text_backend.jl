# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# These structures must not be defined inside a @testset. Otherwise, the test
# will fail for Julia 1.0.
struct MyColumnTable{T <: AbstractMatrix}
    names::Vector{Symbol}
    lookup::Dict{Symbol, Int}
    matrix::T
end

struct MyRowTable{T <: AbstractMatrix}
    names::Vector{Symbol}
    lookup::Dict{Symbol, Int}
    matrix::T
end

struct MyMatrixRow{T} <: Tables.AbstractRow
    row::Int
    source::MyRowTable{T}
end

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
    result = pretty_table(String, data)
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
    result = pretty_table(String, data; alignment = :l)
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
    result = pretty_table(String, data; alignment = :c)
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
    result = pretty_table(String, data; alignment = [:l,:r,:c,:r])
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
    result = pretty_table(String, data;
                          alignment = [:l,:r,:c,:r],
                          cell_alignment = Dict( (3,1) => :r,
                                                 (3,2) => :l,
                                                 (1,4) => :l,
                                                 (3,4) => :c,
                                                 (4,4) => :c,
                                                 (6,4) => :l ))
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

    result = pretty_table(String, data;
                          filters_row     = ( (data,i) -> i%2 == 0,),
                          filters_col     = ( (data,i) -> i%2 == 1,),
                          formatter       = ft_printf("%.3",3),
                          show_row_number = true)
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

    result = pretty_table(String, data;
                          filters_row     = ( (data,i) -> i%2 == 0,),
                          filters_col     = ( (data,i) -> i%2 == 1,),
                          formatter       = ft_printf("%.3",3),
                          show_row_number = true,
                          alignment       = [:c,:l,:l,:c])
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
    result = pretty_table(String, data; formatter = formatter)
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
    result = pretty_table(String, data;
                          alignment       = [:l,:r,:c,:r],
                          show_row_number = true)
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
    result = pretty_table(String, data, tf = ascii_dots)
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
    result = pretty_table(String, data, tf = ascii_rounded)
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
    result = pretty_table(String, data, tf = borderless)
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
    result = pretty_table(String, data, tf = PrettyTables.compact)
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
    result = pretty_table(String, data, tf = markdown)
    @test result == expected

    # matrix
    # ==========================================================================

    expected = """
┌                     ┐
│ 1   false   1.0   1 │
│ 2    true   2.0   2 │
│ 3   false   3.0   3 │
│ 4    true   4.0   4 │
│ 5   false   5.0   5 │
│ 6    true   6.0   6 │
└                     ┘
"""
    result = pretty_table(String, data, tf = matrix, noheader = true)
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
    result = pretty_table(String, data, tf = mysql)
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
    result = pretty_table(String, data, tf = simple)
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
    result = pretty_table(String, data, tf = unicode_rounded)
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

    tf = PrettyTables.TextFormat(unicode, top_line = false, bottom_line = false)
    result = pretty_table(String, data, tf = tf)
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

    tf = PrettyTables.TextFormat(unicode, header_line = false)
    result = pretty_table(String, data, tf = tf)
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
    result = pretty_table(String, data; formatter = ft_round(1))
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
    result = pretty_table(String, data; formatter = ft_round(1,[3,1]))
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
    result = pretty_table(String,data; formatter = ft_printf("%8.3f"))
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
    result = pretty_table(String,data; formatter = ft_printf("%8.3f",[1,4]))
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
    result = pretty_table(String, data;
                          formatter = ft_printf(["%8.2f","%8.4f"],[1,4]))
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
    result = pretty_table(String, data, [1;2;3;4])
    @test result == expected

    result = pretty_table(String, data, [1 2 3 4])
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
    result = pretty_table(String, data, [1 2 3 4; 5 6 7 8])
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
    result = pretty_table(String, data; hlines = findall(x->x == true, data[:,2]))
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
    result = pretty_table(String, data;
                          hlines = findall(x->x == true, data[:,2]),
                          hlines_format = ('├','+','┤','.'))
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

    result = pretty_table(String, data, header; linebreaks = true)
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

    result = pretty_table(String, data, header; alignment = :c, linebreaks = true)
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

    result = pretty_table(String, data, header; alignment = :l, linebreaks = true)
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

    result = pretty_table(String, data, header)
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

    result = pretty_table(String, data; noheader = true)
    @test result == expected

    result = pretty_table(String, data, [1 2]; noheader = true)
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
    result = pretty_table(String, data, [1 2]; alignment = :l, noheader = true)
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
    result = pretty_table(String, data, header; nosubheader = true)
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

    result = pretty_table(String, vec)
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

    result = pretty_table(String, vec; alignment = :c, show_row_number = true)
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

    result = pretty_table(String, vec, ["Header", "Sub-header"])
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

    result = pretty_table(String, data, screen_size = (10,10), crop = :none)
    @test result == expected

    result = pretty_table(String, data, screen_size = (-1,-1), crop = :both)
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

    result = pretty_table(String, data, screen_size = (10,30), crop = :both)
    @test result == expected

    result = pretty_table(String, data, screen_size = (10,30))
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

    result = pretty_table(String, data, screen_size = (10,30), crop = :horizontal)
    @test result == expected

    result = pretty_table(String, data, screen_size = (-1,30), crop = :both)
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

    result = pretty_table(String, data, screen_size = (10,30), crop = :vertical)
    @test result == expected

    result = pretty_table(String, data, screen_size = (10,-1), crop = :both)
    @test result == expected

    model = [1.123456789 for i = 1:8, j = 1:10]

    expected = """
┌───┬─────────────┬────┬─────┬──────┬───────┬────────┬─────────┬──────────┬───────────┐
│ … │ Col. 2      │ C… │ Co… │ Col… │ Col.… │ Col. 7 │ Col. 8  │  Col. 9  │   Col. 10 │
├───┼─────────────┼────┼─────┼──────┼───────┼────────┼─────────┼──────────┼───────────┤
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
│ … │ 1.123456789 │ 1… │ 1.… │ 1.1… │ 1.12… │ 1.123… │ 1.1234… │ 1.12345… │ 1.123456… │
└───┴─────────────┴────┴─────┴──────┴───────┴────────┴─────────┴──────────┴───────────┘
"""

    result = pretty_table(String, model,
                          columns_width = [1, 0, 2, 3, 4, 5, 6, 7, 8, 9],
                          alignment = [:l, :l, :r, :c, :r, :c, :l, :l, :c, :r])

    expected = """
┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │ Col. 6 │ Col. 7 │ Col. 8 │ Col. 9 │ Col. … │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┼────────┼────────┼────────┤
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
│ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │ 1.123… │
└────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┘
"""

    result = pretty_table(String, model,
                          columns_width = 6,
                          alignment = [:l, :l, :r, :c, :r, :c, :l, :l, :c, :r])

    @test result == expected
end

# Auto wrapping
# ==============================================================================

@testset "Auto wrapping" begin
    table = [1 """Ouviram do Ipiranga as margens plácidas
                  De um povo heróico o brado retumbante,
                  E o sol da Liberdade, em raios fúlgidos,
                  Brilhou no céu da Pátria nesse instante.""";
             2 """Se o penhor dessa igualdade
                  Conseguimos conquistar com braço forte,
                  Em teu seio, ó Liberdade,
                  Desafia o nosso peito a própria morte!""";
             3 """Ó Pátria amada, Idolatrada, Salve! Salve!
                  Brasil, um sonho intenso, um raio vívido
                  De amor e de esperança à terra desce,
                  Se em teu formoso céu, risonho e límpido,"""]

    header = ["Verse number", "Verse"]

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse number │                          Verse │
├──────────────┼────────────────────────────────┤
│            1 │         Ouviram do Ipiranga as │
│              │               margens plácidas │
│              │     De um povo heróico o brado │
│              │                    retumbante, │
│              │       E o sol da Liberdade, em │
│              │                raios fúlgidos, │
│              │       Brilhou no céu da Pátria │
│              │                nesse instante. │
├──────────────┼────────────────────────────────┤
│            2 │    Se o penhor dessa igualdade │
│              │     Conseguimos conquistar com │
│              │                   braço forte, │
│              │      Em teu seio, ó Liberdade, │
│              │        Desafia o nosso peito a │
│              │                 própria morte! │
├──────────────┼────────────────────────────────┤
│            3 │    Ó Pátria amada, Idolatrada, │
│              │                  Salve! Salve! │
│              │   Brasil, um sonho intenso, um │
│              │                    raio vívido │
│              │       De amor e de esperança à │
│              │                   terra desce, │
│              │         Se em teu formoso céu, │
│              │             risonho e límpido, │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(String, table, header,
                          autowrap      = true,
                          linebreaks    = true,
                          hlines        = 1:4,
                          columns_width = [-1,30])

    @test result == expected

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse number │             Verse              │
├──────────────┼────────────────────────────────┤
│      1       │     Ouviram do Ipiranga as     │
│              │        margens plácidas        │
│              │   De um povo heróico o brado   │
│              │          retumbante,           │
│              │    E o sol da Liberdade, em    │
│              │        raios fúlgidos,         │
│              │    Brilhou no céu da Pátria    │
│              │        nesse instante.         │
├──────────────┼────────────────────────────────┤
│      2       │  Se o penhor dessa igualdade   │
│              │   Conseguimos conquistar com   │
│              │          braço forte,          │
│              │   Em teu seio, ó Liberdade,    │
│              │    Desafia o nosso peito a     │
│              │         própria morte!         │
├──────────────┼────────────────────────────────┤
│      3       │  Ó Pátria amada, Idolatrada,   │
│              │         Salve! Salve!          │
│              │  Brasil, um sonho intenso, um  │
│              │          raio vívido           │
│              │    De amor e de esperança à    │
│              │          terra desce,          │
│              │     Se em teu formoso céu,     │
│              │       risonho e límpido,       │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(String, table, header,
                          alignment     = :c,
                          autowrap      = true,
                          linebreaks    = true,
                          hlines        = 1:4,
                          columns_width = [-1,30])

    @test result == expected

    expected = """
┌──────────────┬────────────────────────────────┐
│ Verse number │ Verse                          │
├──────────────┼────────────────────────────────┤
│ 1            │ Ouviram do Ipiranga as         │
│              │ margens plácidas               │
│              │ De um povo heróico o brado     │
│              │ retumbante,                    │
│              │ E o sol da Liberdade, em       │
│              │ raios fúlgidos,                │
│              │ Brilhou no céu da Pátria       │
│              │ nesse instante.                │
├──────────────┼────────────────────────────────┤
│ 2            │ Se o penhor dessa igualdade    │
│              │ Conseguimos conquistar com     │
│              │ braço forte,                   │
│              │ Em teu seio, ó Liberdade,      │
│              │ Desafia o nosso peito a        │
│              │ própria morte!                 │
├──────────────┼────────────────────────────────┤
│ 3            │ Ó Pátria amada, Idolatrada,    │
│              │ Salve! Salve!                  │
│              │ Brasil, um sonho intenso, um   │
│              │ raio vívido                    │
│              │ De amor e de esperança à       │
│              │ terra desce,                   │
│              │ Se em teu formoso céu,         │
│              │ risonho e límpido,             │
└──────────────┴────────────────────────────────┘
"""

    result = pretty_table(String, table, header,
                          alignment     = :l,
                          autowrap      = true,
                          linebreaks    = true,
                          hlines        = 1:4,
                          columns_width = [-1,30])

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

    result = pretty_table(String, dict, sortkeys = true)
    @test result == expected
end

# Row names
# ==============================================================================

@testset "Show row names" begin
    expected = """
┌───────┬─────┬───────┬───────┬─────┐
│       │  C1 │    C2 │    C3 │  C4 │
│       │ Int │  Bool │ Float │ Hex │
├───────┼─────┼───────┼───────┼─────┤
│ Row 1 │   1 │ false │   1.0 │   1 │
│ Row 2 │   2 │  true │   2.0 │   2 │
│ Row 3 │   3 │ false │   3.0 │   3 │
│ Row 4 │   4 │  true │   4.0 │   4 │
│ Row 5 │   5 │ false │   5.0 │   5 │
│ Row 6 │   6 │  true │   6.0 │   6 │
└───────┴─────┴───────┴───────┴─────┘
"""

    result = pretty_table(String, data,
                          ["C1" "C2" "C3" "C4"; "Int" "Bool" "Float" "Hex"],
                          row_names = ["Row $i" for i = 1:6])

    @test result == expected

    expected = """
┌───────────┬─────┬───────┬───────┬─────┐
│ Row names │  C1 │    C2 │    C3 │  C4 │
│           │ Int │  Bool │ Float │ Hex │
├───────────┼─────┼───────┼───────┼─────┤
│     Row 1 │   1 │ false │   1.0 │   1 │
│     Row 2 │   2 │  true │   2.0 │   2 │
│     Row 3 │   3 │ false │   3.0 │   3 │
│     Row 4 │   4 │  true │   4.0 │   4 │
│     Row 5 │   5 │ false │   5.0 │   5 │
│     Row 6 │   6 │  true │   6.0 │   6 │
└───────────┴─────┴───────┴───────┴─────┘
"""

    result = pretty_table(String, data,
                          ["C1" "C2" "C3" "C4"; "Int" "Bool" "Float" "Hex"],
                          row_names = ["Row $i" for i = 1:6],
                          row_name_column_title = "Row names")

    @test result == expected

    expected = """
┌───────────┬─────┬───────┬───────┬─────┐
│ Row names │  C1 │    C2 │    C3 │  C4 │
│           │ Int │  Bool │ Float │ Hex │
├───────────┼─────┼───────┼───────┼─────┤
│   Row 1   │   1 │ false │   1.0 │   1 │
│   Row 2   │   2 │  true │   2.0 │   2 │
│   Row 3   │   3 │ false │   3.0 │   3 │
│   Row 4   │   4 │  true │   4.0 │   4 │
│   Row 5   │   5 │ false │   5.0 │   5 │
│   Row 6   │   6 │  true │   6.0 │   6 │
└───────────┴─────┴───────┴───────┴─────┘
"""

    result = pretty_table(String, data,
                          ["C1" "C2" "C3" "C4"; "Int" "Bool" "Float" "Hex"],
                          row_names = ["Row $i" for i = 1:6],
                          row_name_column_title = "Row names",
                          row_name_alignment = :c)

    @test result == expected

    expected = """
┌───────────┬─────┬───────┬───────┬─── ⋯
│ Row names │  C1 │    C2 │    C3 │  C ⋯
│           │ Int │  Bool │ Float │ He ⋯
├───────────┼─────┼───────┼───────┼─── ⋯
│   Row 1   │   1 │ false │   1.0 │    ⋯
│   Row 2   │   2 │  true │   2.0 │    ⋯
│     ⋮     │  ⋮  │   ⋮   │   ⋮   │  ⋮ ⋯
└───────────┴─────┴───────┴───────┴─── ⋯
"""

    result = pretty_table(String, data,
                          ["C1" "C2" "C3" "C4"; "Int" "Bool" "Float" "Hex"],
                          row_names = ["Row $i" for i = 1:6],
                          row_name_column_title = "Row names",
                          row_name_alignment = :c,
                          screen_size = (11,40))
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

    result = pretty_table(String, matrix)
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

# Table.jl compatibility
# ==============================================================================

@testset "Tables.jl compatibility" begin
    # A DataFrame is compliant with Tables.jl API.
    df = DataFrame(x = Int64(1):Int64(3),
                   y = 'a':'c',
                   z = ["String 1";"String 2";"String 3"]);

    # Thus, the following 5 calls must provide the same results.
    result_1 = pretty_table(String, df)
    result_2 = pretty_table(String, Tables.rowtable(df))
    result_3 = pretty_table(String, Tables.columntable(df))
    result_4 = pretty_table(String, Tables.columns(df))
    result_5 = pretty_table(String, Tables.rows(df))

    expected = """
┌───────┬──────┬──────────┐
│     x │    y │        z │
│ Int64 │ Char │   String │
├───────┼──────┼──────────┤
│     1 │    a │ String 1 │
│     2 │    b │ String 2 │
│     3 │    c │ String 3 │
└───────┴──────┴──────────┘
"""

    @test result_1 == result_2 == result_3 == result_4 == result_5 == expected

    # If a header is passed, then it must replace the Tables.jl schema.

    result = pretty_table(String, df, ["My col. 1", "My col. 2", "My col. 3"])

    expected = """
┌───────────┬───────────┬───────────┐
│ My col. 1 │ My col. 2 │ My col. 3 │
├───────────┼───────────┼───────────┤
│         1 │         a │  String 1 │
│         2 │         b │  String 2 │
│         3 │         c │  String 3 │
└───────────┴───────────┴───────────┘
"""

    @test result == expected

    # Test the case in which a schema is not available
    # ==========================================================================

    expected = """
┌───┬───────┬─────┬───┐
│ a │     b │   c │ d │
├───┼───────┼─────┼───┤
│ 1 │ false │ 1.0 │ 1 │
│ 2 │  true │ 2.0 │ 2 │
│ 3 │ false │ 3.0 │ 3 │
│ 4 │  true │ 4.0 │ 4 │
│ 5 │ false │ 5.0 │ 5 │
│ 6 │  true │ 6.0 │ 6 │
└───┴───────┴─────┴───┘
"""

    # Column table
    # --------------------------------------------------------------------------

    Tables.istable(::Type{<:MyColumnTable}) = true
    names(m::MyColumnTable) = getfield(m, :names)
    mat(m::MyColumnTable) = getfield(m, :matrix)
    lookup(m::MyColumnTable) = getfield(m, :lookup)

    Tables.columnaccess(::Type{<:MyColumnTable}) = true
    Tables.columns(m::MyColumnTable) = m
    Tables.getcolumn(m::MyColumnTable, ::Type{T}, col::Int, nm::Symbol) where {T} = mat(m)[:, col]
    Tables.getcolumn(m::MyColumnTable, nm::Symbol) = mat(m)[:, lookup(m)[nm]]
    Tables.getcolumn(m::MyColumnTable, i::Int) = mat(m)[:, i]
    Tables.columnnames(m::MyColumnTable) = names(m)

    table = MyColumnTable([:a,:b,:c,:d],
                          Dict(:a => 1, :b => 2, :c => 3, :d => 4),
                          data)

    result = pretty_table(String, table)

    @test Tables.schema(table) == nothing
    @test result == expected

    # Row table
    # --------------------------------------------------------------------------

    # First, we need to create a object that complies with Tables.jl and that
    # does not have a schema. This is based on Tables.jl documentation.

    Tables.istable(::Type{<:MyRowTable}) = true
    names(m::MyRowTable) = getfield(m, :names)
    mat(m::MyRowTable) = getfield(m, :matrix)
    lookup(m::MyRowTable) = getfield(m, :lookup)

    Tables.rowaccess(::Type{<:MyRowTable}) = true
    Tables.rows(m::MyRowTable) = m
    Base.eltype(m::MyRowTable{T}) where {T} = MyMatrixRow{T}
    Base.length(m::MyRowTable) = size(mat(m), 1)
    Base.iterate(m::MyRowTable, st=1) = st > length(m) ? nothing : (MyMatrixRow(st, m), st + 1)

    Tables.getcolumn(m::MyMatrixRow, ::Type, col::Int, nm::Symbol) =
        getfield(getfield(m, :source), :matrix)[getfield(m, :row), col]
    Tables.getcolumn(m::MyMatrixRow, i::Int) =
        getfield(getfield(m, :source), :matrix)[getfield(m, :row), i]
    Tables.getcolumn(m::MyMatrixRow, nm::Symbol) =
        getfield(getfield(m, :source), :matrix)[getfield(m, :row), getfield(getfield(m, :source), :lookup)[nm]]
    Tables.columnnames(m::MyMatrixRow) = names(getfield(m, :source))

    table = MyRowTable([:a,:b,:c,:d], Dict(:a => 1, :b => 2, :c => 3, :d => 4),
                       data)

    result = pretty_table(String, table)

    @test Tables.schema(table) == nothing
    @test result == expected
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

    result = pretty_table(String, data, ["1" "2\n" "3" "4"])
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
    result = pretty_table(String, data, [1  2  3  4;
                                         5  6  7  8;
                                         9 10 11 12];
                          show_row_number = true)
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

    result = pretty_table(String, v; noheader = true, show_row_number = true)
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

    result = pretty_table(String, df)
    @test result == expected
end

# Issue #19
# ==============================================================================

@testset "Issue #19 - ft_printf with cells that are not numbers" begin
    matrix = [1 1; 2 2; 3 3; "teste" "teste"; 4 4; 5 5; true true; :s :s]

    expected = """
┌────────────┬────────┐
│     Col. 1 │ Col. 2 │
├────────────┼────────┤
│       1.00 │      1 │
│       2.00 │      2 │
│       3.00 │      3 │
│      teste │  teste │
│       4.00 │      4 │
│       5.00 │      5 │
│       1.00 │   true │
│          s │      s │
└────────────┴────────┘
"""

    result = pretty_table(String, matrix; formatter = ft_printf("%10.2f",[1]))
    @test result == expected

end

# Issue #22
# ==============================================================================

@testset "Issue #22 - Strings with quotes" begin
    # Without linebreaks.
    matrix = [1 "teste\"teste"
              2 "teste\"\"teste"]

    expected = """
┌────────┬──────────────┐
│ Col. 1 │       Col. 2 │
├────────┼──────────────┤
│      1 │  teste"teste │
│      2 │ teste""teste │
└────────┴──────────────┘
"""

    result = pretty_table(String, matrix)
    @test result == expected

    # With linebreaks.
    matrix = [ 1 """
    function str(str = "one string")
        return str
    end"""
    2 """
    function str(str = "")
        if isempty(str)
            return "one string"
        else
            return str
        end
    end"""]

    expected = """
┌────────┬──────────────────────────────────┐
│ Col. 1 │ Col. 2                           │
├────────┼──────────────────────────────────┤
│ 1      │ function str(str = "one string") │
│        │     return str                   │
│        │ end                              │
│ 2      │ function str(str = "")           │
│        │     if isempty(str)              │
│        │         return "one string"      │
│        │     else                         │
│        │         return str               │
│        │     end                          │
│        │ end                              │
└────────┴──────────────────────────────────┘
"""

    result = pretty_table(String, matrix; alignment = :l, linebreaks = true)

    @test result == expected
end

# Issue #24
# ==============================================================================

@testset "Issue #24 - Tables compatibility" begin
    # Named tuple of vectors (satisfies Tables interface).
    ctable = (x = Int64[1, 2, 3, 4], y = ["a", "b", "c", "d"])

    cresult = sprint(pretty_table, ctable)

    expected = """
┌───────┬────────┐
│     x │      y │
│ Int64 │ String │
├───────┼────────┤
│     1 │      a │
│     2 │      b │
│     3 │      c │
│     4 │      d │
└───────┴────────┘
"""

  @test cresult == expected
end

# Issue #28
# ==============================================================================

@testset "Issue #28 - Tables.jl API must have priority when printing" begin
    # A DataFrame is compliant with Tables.jl API.
    df = DataFrame(x = Int64(1):Int64(3),
                   y = 'a':'c',
                   z = ["String 1";"String 2";"String 3"]);

    # Thus, the following 3 calls must provide the same results.
    result_1 = pretty_table(String, df)
    result_2 = pretty_table(String, Tables.rowtable(df))
    result_3 = pretty_table(String, Tables.columns(df))

    expected = """
┌───────┬──────┬──────────┐
│     x │    y │        z │
│ Int64 │ Char │   String │
├───────┼──────┼──────────┤
│     1 │    a │ String 1 │
│     2 │    b │ String 2 │
│     3 │    c │ String 3 │
└───────┴──────┴──────────┘
"""

    @test result_1 == result_2 == result_3 == expected
end
