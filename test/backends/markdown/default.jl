## Description #############################################################################
#
# Markdown Back End: Test with default options.
#
############################################################################################

@testset "Default Options" begin
    matrix = [
        1 1.0 0x01 'a' "abc" missing
        2 2.0 0x02 'b' "def" nothing
        3 3.0 0x03 'c' "ghi" :symbol
    ]

    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** | **Col. 5** | **Col. 6** |
|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|
|          1 |        1.0 |          1 |          a |        abc |    missing |
|          2 |        2.0 |          2 |          b |        def |    nothing |
|          3 |        3.0 |          3 |          c |        ghi |     symbol |
"""

    result = pretty_table(String, matrix; backend = :markdown)

    @test result == expected
end

