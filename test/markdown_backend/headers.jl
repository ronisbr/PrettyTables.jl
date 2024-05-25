## Description #############################################################################
#
# Tests of headers and sub-headers.
#
############################################################################################

@testset "Headers and Sub-headers" begin
    expected = """
| **1**<br>`A`<br>`E` | **2**<br>`B`<br>`F` | **3**<br>`C`<br>`G` | **4**<br>`D`<br>`H` |
|--------------------:|--------------------:|--------------------:|--------------------:|
| 1                   | false               | 1.0                 | 1                   |
| 2                   | true                | 2.0                 | 2                   |
| 3                   | false               | 3.0                 | 3                   |
| 4                   | true                | 4.0                 | 4                   |
| 5                   | false               | 5.0                 | 5                   |
| 6                   | true                | 6.0                 | 6                   |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        header = (
            ["1", "2", "3", "4"],
            [:A,  :B,  :C,  :D],
            [:E,  :F,  :G,  :H]
        ),
    )

    @test result == expected

    expected = """
| **1** | **2** | **3** | **4** |
|------:|------:|------:|------:|
| 1     | false | 1.0   | 1     |
| 2     | true  | 2.0   | 2     |
| 3     | false | 3.0   | 3     |
| 4     | true  | 4.0   | 4     |
| 5     | false | 5.0   | 5     |
| 6     | true  | 6.0   | 6     |
"""

    result = pretty_table(
        String,
        data;
        backend = Val(:markdown),
        header = (
            ["1", "2", "3", "4"],
            [:A,  :B,  :C,  :D],
            [:E,  :F,  :G,  :H]
        ),
        show_subheader = false,
    )

    @test result == expected
end
