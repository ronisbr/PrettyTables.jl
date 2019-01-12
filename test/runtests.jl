using Test
using PrettyTables

data = ["Col. 1" "Col. 2" "Col. 3" "Col. 4";
              1    false      1.0     0x01 ;
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

# Aligments
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
│      0 │  false │      0 │      0 │
│      3 │   true │      3 │      3 │
│      0 │  false │      0 │      0 │
│      5 │   true │      5 │      5 │
│      0 │  false │      0 │      0 │
│      7 │   true │      7 │      7 │
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
end
