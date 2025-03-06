## Description #############################################################################
#
# Text Back End: Test with default options.
#
############################################################################################

@testset "Default Option" verbose = true begin
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    @testset "With Colors" begin
        expected = """
┌────────┬────────┬────────┬────────┬────────┬─────────┐
│\e[1m Col. 1 \e[0m│\e[1m Col. 2 \e[0m│\e[1m Col. 3 \e[0m│\e[1m Col. 4 \e[0m│\e[1m Col. 5 \e[0m│\e[1m  Col. 6 \e[0m│
├────────┼────────┼────────┼────────┼────────┼─────────┤
│      1 │    1.0 │      1 │      a │    abc │ missing │
│      2 │    2.0 │      2 │      b │    def │ nothing │
│      3 │    3.0 │      3 │      c │    ghi │  symbol │
└────────┴────────┴────────┴────────┴────────┴─────────┘
"""

        result = pretty_table(String, matrix; color = true)
        @test result == expected
    end

    @testset "Without Colors" begin
        expected = """
┌────────┬────────┬────────┬────────┬────────┬─────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │  Col. 6 │
├────────┼────────┼────────┼────────┼────────┼─────────┤
│      1 │    1.0 │      1 │      a │    abc │ missing │
│      2 │    2.0 │      2 │      b │    def │ nothing │
│      3 │    3.0 │      3 │      c │    ghi │  symbol │
└────────┴────────┴────────┴────────┴────────┴─────────┘
"""
        result = pretty_table(String, matrix)
        @test result == expected
    end

    @testset "Automatic Type Detection" begin
        expected = """
┌────────┬────────┬────────┬────────┬────────┬─────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │ Col. 4 │ Col. 5 │  Col. 6 │
├────────┼────────┼────────┼────────┼────────┼─────────┤
│      1 │    1.0 │      1 │      a │    abc │ missing │
│      2 │    2.0 │      2 │      b │    def │ nothing │
│      3 │    3.0 │      3 │      c │    ghi │  symbol │
└────────┴────────┴────────┴────────┴────────┴─────────┘
"""
        result = pretty_table(String, matrix; table_format = TextTableFormat())
        @test result == expected
    end
end
