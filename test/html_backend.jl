# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Tests related to the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: right; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 2</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 3</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: right; ">1</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: right; ">1.0</td>
<td style = "text-align: right; ">1</td>
</tr>
<tr>
<td style = "text-align: right; ">2</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: right; ">2.0</td>
<td style = "text-align: right; ">2</td>
</tr>
<tr>
<td style = "text-align: right; ">3</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: right; ">3.0</td>
<td style = "text-align: right; ">3</td>
</tr>
<tr>
<td style = "text-align: right; ">4</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: right; ">4.0</td>
<td style = "text-align: right; ">4</td>
</tr>
<tr>
<td style = "text-align: right; ">5</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: right; ">5.0</td>
<td style = "text-align: right; ">5</td>
</tr>
<tr>
<td style = "text-align: right; ">6</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: right; ">6.0</td>
<td style = "text-align: right; ">6</td>
</tr>
</table></body></html>
"""
    result = sprint((io,data)->pretty_table(io,data,backend = :html), data)
    @test result == expected
end

# Alignments
# ==============================================================================

@testset "Alignments" begin
    # Left
    # ==========================================================================
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: left; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: left; ">Col. 2</th>
<th style = "background: navy; color: white; text-align: left; ">Col. 3</th>
<th style = "background: navy; color: white; text-align: left; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: left; ">1</td>
<td style = "text-align: left; ">false</td>
<td style = "text-align: left; ">1.0</td>
<td style = "text-align: left; ">1</td>
</tr>
<tr>
<td style = "text-align: left; ">2</td>
<td style = "text-align: left; ">true</td>
<td style = "text-align: left; ">2.0</td>
<td style = "text-align: left; ">2</td>
</tr>
<tr>
<td style = "text-align: left; ">3</td>
<td style = "text-align: left; ">false</td>
<td style = "text-align: left; ">3.0</td>
<td style = "text-align: left; ">3</td>
</tr>
<tr>
<td style = "text-align: left; ">4</td>
<td style = "text-align: left; ">true</td>
<td style = "text-align: left; ">4.0</td>
<td style = "text-align: left; ">4</td>
</tr>
<tr>
<td style = "text-align: left; ">5</td>
<td style = "text-align: left; ">false</td>
<td style = "text-align: left; ">5.0</td>
<td style = "text-align: left; ">5</td>
</tr>
<tr>
<td style = "text-align: left; ">6</td>
<td style = "text-align: left; ">true</td>
<td style = "text-align: left; ">6.0</td>
<td style = "text-align: left; ">6</td>
</tr>
</table></body></html>
"""
    result = sprint((io, data)->pretty_table(io, data; alignment = :l,
                                             backend = :html), data)
    @test result == expected

    # Center
    # ==========================================================================
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: center; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 2</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 3</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: center; ">1</td>
<td style = "text-align: center; ">false</td>
<td style = "text-align: center; ">1.0</td>
<td style = "text-align: center; ">1</td>
</tr>
<tr>
<td style = "text-align: center; ">2</td>
<td style = "text-align: center; ">true</td>
<td style = "text-align: center; ">2.0</td>
<td style = "text-align: center; ">2</td>
</tr>
<tr>
<td style = "text-align: center; ">3</td>
<td style = "text-align: center; ">false</td>
<td style = "text-align: center; ">3.0</td>
<td style = "text-align: center; ">3</td>
</tr>
<tr>
<td style = "text-align: center; ">4</td>
<td style = "text-align: center; ">true</td>
<td style = "text-align: center; ">4.0</td>
<td style = "text-align: center; ">4</td>
</tr>
<tr>
<td style = "text-align: center; ">5</td>
<td style = "text-align: center; ">false</td>
<td style = "text-align: center; ">5.0</td>
<td style = "text-align: center; ">5</td>
</tr>
<tr>
<td style = "text-align: center; ">6</td>
<td style = "text-align: center; ">true</td>
<td style = "text-align: center; ">6.0</td>
<td style = "text-align: center; ">6</td>
</tr>
</table></body></html>
"""
    result = sprint((io, data)->pretty_table(io, data; alignment = :c,
                                             backend = :html), data)
    @test result == expected

    # Per column configuration
    # ==========================================================================

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: left; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 2</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 3</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: left; ">1</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">1.0</td>
<td style = "text-align: right; ">1</td>
</tr>
<tr>
<td style = "text-align: left; ">2</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">2.0</td>
<td style = "text-align: right; ">2</td>
</tr>
<tr>
<td style = "text-align: left; ">3</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">3.0</td>
<td style = "text-align: right; ">3</td>
</tr>
<tr>
<td style = "text-align: left; ">4</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">4.0</td>
<td style = "text-align: right; ">4</td>
</tr>
<tr>
<td style = "text-align: left; ">5</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">5.0</td>
<td style = "text-align: right; ">5</td>
</tr>
<tr>
<td style = "text-align: left; ">6</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">6.0</td>
<td style = "text-align: right; ">6</td>
</tr>
</table></body></html>
"""
    result = sprint((io, data)->pretty_table(io, data;
                                             alignment = [:l,:r,:c,:r],
                                             backend = :html), data)
    @test result == expected

    # Cell override
    # ==========================================================================

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: left; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 2</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 3</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: left; ">1</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">1.0</td>
<td style = "text-align: left; ">1</td>
</tr>
<tr>
<td style = "text-align: left; ">2</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">2.0</td>
<td style = "text-align: right; ">2</td>
</tr>
<tr>
<td style = "text-align: right; ">3</td>
<td style = "text-align: left; ">false</td>
<td style = "text-align: center; ">3.0</td>
<td style = "text-align: center; ">3</td>
</tr>
<tr>
<td style = "text-align: left; ">4</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">4.0</td>
<td style = "text-align: center; ">4</td>
</tr>
<tr>
<td style = "text-align: left; ">5</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">5.0</td>
<td style = "text-align: right; ">5</td>
</tr>
<tr>
<td style = "text-align: left; ">6</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">6.0</td>
<td style = "text-align: left; ">6</td>
</tr>
</table></body></html>
"""
    result = sprint((io, data)->pretty_table(io, data;
                                             alignment = [:l,:r,:c,:r],
                                             backend = :html,
                                             cell_alignment =
                                                Dict( (3,1) => :r,
                                                      (3,2) => :l,
                                                      (1,4) => :l,
                                                      (3,4) => :c,
                                                      (4,4) => :c,
                                                      (6,4) => :l )), data)
    @test result == expected
end

# Filters
# ==============================================================================

@testset "Filters" begin
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: right; ">Row</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 3</th>
</tr>
<tr>
<td style = "text-align: right; ">2</td>
<td style = "text-align: right; ">2</td>
<td style = "text-align: right; ">2.0</td>
</tr>
<tr>
<td style = "text-align: right; ">4</td>
<td style = "text-align: right; ">4</td>
<td style = "text-align: right; ">4.0</td>
</tr>
<tr>
<td style = "text-align: right; ">6</td>
<td style = "text-align: right; ">6</td>
<td style = "text-align: right; ">6.0</td>
</tr>
</table></body></html>
"""

    result = sprint((io,data)->pretty_table(io, data;
                                            backend = :html,
                                            filters_row = ( (data,i) -> i%2 == 0,),
                                            filters_col = ( (data,i) -> i%2 == 1,),
                                            formatter = ft_printf("%.3",3),
                                            show_row_number = true), data)
    @test result == expected

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: right; ">Row</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: left; ">Col. 3</th>
</tr>
<tr>
<td style = "text-align: right; ">2</td>
<td style = "text-align: center; ">2</td>
<td style = "text-align: left; ">2.0</td>
</tr>
<tr>
<td style = "text-align: right; ">4</td>
<td style = "text-align: center; ">4</td>
<td style = "text-align: left; ">4.0</td>
</tr>
<tr>
<td style = "text-align: right; ">6</td>
<td style = "text-align: center; ">6</td>
<td style = "text-align: left; ">6.0</td>
</tr>
</table></body></html>
"""

    result = sprint((io,data)->pretty_table(io, data;
                                            backend = :html,
                                            filters_row = ( (data,i) -> i%2 == 0,),
                                            filters_col = ( (data,i) -> i%2 == 1,),
                                            formatter = ft_printf("%.3",3),
                                            show_row_number = true,
                                            alignment = [:c,:l,:l,:c]), data)
    @test result == expected
end

# Formatter
# ==============================================================================

@testset "Formatter" begin
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: right; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 2</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 3</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: right; ">1</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: right; ">1</td>
<td style = "text-align: right; ">1</td>
</tr>
<tr>
<td style = "text-align: right; ">0</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: right; ">0</td>
<td style = "text-align: right; ">0</td>
</tr>
<tr>
<td style = "text-align: right; ">3</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: right; ">3</td>
<td style = "text-align: right; ">3</td>
</tr>
<tr>
<td style = "text-align: right; ">0</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: right; ">0</td>
<td style = "text-align: right; ">0</td>
</tr>
<tr>
<td style = "text-align: right; ">5</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: right; ">5</td>
<td style = "text-align: right; ">5</td>
</tr>
<tr>
<td style = "text-align: right; ">0</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: right; ">0</td>
<td style = "text-align: right; ">0</td>
</tr>
</table></body></html>
"""
    formatter = Dict(0 => (v,i) -> isodd(i) ? i : 0,
                     2 => (v,i) -> v)
    result = sprint((io, data)->pretty_table(io, data; backend = :html,
                                             formatter = formatter), data)
    @test result == expected
end

# Show row number
# ==============================================================================

@testset "Show row number" begin
    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: right; ">Row</th>
<th style = "background: navy; color: white; text-align: left; ">Col. 1</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 2</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 3</th>
<th style = "background: navy; color: white; text-align: right; ">Col. 4</th>
</tr>
<tr>
<td style = "text-align: right; ">1</td>
<td style = "text-align: left; ">1</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">1.0</td>
<td style = "text-align: right; ">1</td>
</tr>
<tr>
<td style = "text-align: right; ">2</td>
<td style = "text-align: left; ">2</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">2.0</td>
<td style = "text-align: right; ">2</td>
</tr>
<tr>
<td style = "text-align: right; ">3</td>
<td style = "text-align: left; ">3</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">3.0</td>
<td style = "text-align: right; ">3</td>
</tr>
<tr>
<td style = "text-align: right; ">4</td>
<td style = "text-align: left; ">4</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">4.0</td>
<td style = "text-align: right; ">4</td>
</tr>
<tr>
<td style = "text-align: right; ">5</td>
<td style = "text-align: left; ">5</td>
<td style = "text-align: right; ">false</td>
<td style = "text-align: center; ">5.0</td>
<td style = "text-align: right; ">5</td>
</tr>
<tr>
<td style = "text-align: right; ">6</td>
<td style = "text-align: left; ">6</td>
<td style = "text-align: right; ">true</td>
<td style = "text-align: center; ">6.0</td>
<td style = "text-align: right; ">6</td>
</tr>
</table></body></html>
"""
    result = sprint((io, data)->pretty_table(io, data;
                                             alignment       = [:l,:r,:c,:r],
                                             backend         = :html,
                                             show_row_number = true), data)
    @test result == expected
end

# Sub-headers
# ==============================================================================

# Hiding header and sub-header
# ==============================================================================

# Print vectors
# ==============================================================================

@testset "Print vectors" begin

    vec = 0:1:10

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: right; ">Col. 1</th>
</tr>
<tr>
<td style = "text-align: right; ">0</td>
</tr>
<tr>
<td style = "text-align: right; ">1</td>
</tr>
<tr>
<td style = "text-align: right; ">2</td>
</tr>
<tr>
<td style = "text-align: right; ">3</td>
</tr>
<tr>
<td style = "text-align: right; ">4</td>
</tr>
<tr>
<td style = "text-align: right; ">5</td>
</tr>
<tr>
<td style = "text-align: right; ">6</td>
</tr>
<tr>
<td style = "text-align: right; ">7</td>
</tr>
<tr>
<td style = "text-align: right; ">8</td>
</tr>
<tr>
<td style = "text-align: right; ">9</td>
</tr>
<tr>
<td style = "text-align: right; ">10</td>
</tr>
</table></body></html>
"""

    result = sprint((io,data)->pretty_table(io, data, backend = :html), vec)
    @test result == expected

    expected = """
<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
table, td, th {
    border-collapse: collapse
}

td, th {
    border:  ;
    padding: 6px
}
table {
    font-family: sans-serif;
}

tr:nth-child(odd) {
    background: #eee;
}

tr:nth-child(even) {
    background: #fff;
}

</style>
<body>
<table>

<tr>
<th style = "background: navy; color: white; text-align: right; ">Row</th>
<th style = "background: navy; color: white; text-align: center; ">Col. 1</th>
</tr>
<tr>
<td style = "text-align: right; ">1</td>
<td style = "text-align: center; ">0</td>
</tr>
<tr>
<td style = "text-align: right; ">2</td>
<td style = "text-align: center; ">1</td>
</tr>
<tr>
<td style = "text-align: right; ">3</td>
<td style = "text-align: center; ">2</td>
</tr>
<tr>
<td style = "text-align: right; ">4</td>
<td style = "text-align: center; ">3</td>
</tr>
<tr>
<td style = "text-align: right; ">5</td>
<td style = "text-align: center; ">4</td>
</tr>
<tr>
<td style = "text-align: right; ">6</td>
<td style = "text-align: center; ">5</td>
</tr>
<tr>
<td style = "text-align: right; ">7</td>
<td style = "text-align: center; ">6</td>
</tr>
<tr>
<td style = "text-align: right; ">8</td>
<td style = "text-align: center; ">7</td>
</tr>
<tr>
<td style = "text-align: right; ">9</td>
<td style = "text-align: center; ">8</td>
</tr>
<tr>
<td style = "text-align: right; ">10</td>
<td style = "text-align: center; ">9</td>
</tr>
<tr>
<td style = "text-align: right; ">11</td>
<td style = "text-align: center; ">10</td>
</tr>
</table></body></html>
"""

    result = sprint((io, vec)->pretty_table(io, vec; alignment = :c,
                                            backend = :html,
                                            show_row_number = true), vec)
    @test result == expected

    # TODO: test sub-headers.
end

# Dictionaries
# ==============================================================================

# Helpers
# ==============================================================================
