## Description #############################################################################
#
# Tests of formatters.
#
############################################################################################

@testset "Formatters" begin
    expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** |
|-----------:|-----------:|-----------:|-----------:|
| 1          | false      | 1          | 1          |
| 0          | true       | 0          | 0          |
| 3          | false      | 3          | 3          |
| 0          | true       | 0          | 0          |
| 5          | false      | 5          | 5          |
| 0          | true       | 0          | 0          |
"""

    formatter = (data, i, j) -> begin
        if j != 2
            return isodd(i) ? i : 0
        else
            return data
        end
    end

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        formatters = formatter,
    )

    @test result == expected
end

