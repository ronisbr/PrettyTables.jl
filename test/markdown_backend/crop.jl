## Description #############################################################################
#
# Tests related to cropping.
#
############################################################################################

@testset "Cropping" begin
    # == Bottom Cropping (Default) =========================================================

    matrix = [(i, j) for i in 1:7, j in 1:7]
    header = (
        ["Column $i" for i in 1:7],
        ["C$i" for i in 1:7]
    )

    expected = """
| **Column 1**<br>`C1` | **Column 2**<br>`C2` | **Column 3**<br>`C3` | ⋯ |
|---------------------:|---------------------:|---------------------:|:-:|
| (1, 1)               | (1, 2)               | (1, 3)               | ⋯ |
| (2, 1)               | (2, 2)               | (2, 3)               | ⋯ |
| (3, 1)               | (3, 2)               | (3, 3)               | ⋯ |
| ⋮                    | ⋮                    | ⋮                    | ⋱ |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header  = header,
        max_num_of_rows = 3,
        max_num_of_columns = 3
    )
    @test result == expected

    expected = """
| **Column 1**<br>`C1` | **Column 2**<br>`C2` | **Column 3**<br>`C3` | **Column 4**<br>`C4` | **Column 5**<br>`C5` | **Column 6**<br>`C6` | **Column 7**<br>`C7` |
|---------------------:|---------------------:|---------------------:|---------------------:|---------------------:|---------------------:|---------------------:|
| (1, 1)               | (1, 2)               | (1, 3)               | (1, 4)               | (1, 5)               | (1, 6)               | (1, 7)               |
| (2, 1)               | (2, 2)               | (2, 3)               | (2, 4)               | (2, 5)               | (2, 6)               | (2, 7)               |
| (3, 1)               | (3, 2)               | (3, 3)               | (3, 4)               | (3, 5)               | (3, 6)               | (3, 7)               |
| ⋮                    | ⋮                    | ⋮                    | ⋮                    | ⋮                    | ⋮                    | ⋮                    |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header  = header,
        max_num_of_rows = 3
    )
    @test result == expected

    expected = """
| **Column 1**<br>`C1` | **Column 2**<br>`C2` | **Column 3**<br>`C3` | ⋯ |
|---------------------:|---------------------:|---------------------:|:-:|
| (1, 1)               | (1, 2)               | (1, 3)               | ⋯ |
| (2, 1)               | (2, 2)               | (2, 3)               | ⋯ |
| (3, 1)               | (3, 2)               | (3, 3)               | ⋯ |
| (4, 1)               | (4, 2)               | (4, 3)               | ⋯ |
| (5, 1)               | (5, 2)               | (5, 3)               | ⋯ |
| (6, 1)               | (6, 2)               | (6, 3)               | ⋯ |
| (7, 1)               | (7, 2)               | (7, 3)               | ⋯ |
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header  = header,
        max_num_of_columns = 3
    )
    @test result == expected
end

@testset "Omitted Cell Summary" begin
    matrix = [(i, j) for i in 1:7, j in 1:7]
    header = (
        ["Column $i" for i in 1:7],
        ["C$i" for i in 1:7]
    )

    expected = """
| **Column 1**<br>`C1` | **Column 2**<br>`C2` | **Column 3**<br>`C3` | ⋯ |
|---------------------:|---------------------:|---------------------:|:-:|
| (1, 1)               | (1, 2)               | (1, 3)               | ⋯ |
| (2, 1)               | (2, 2)               | (2, 3)               | ⋯ |
| (3, 1)               | (3, 2)               | (3, 3)               | ⋯ |
| ⋮                    | ⋮                    | ⋮                    | ⋱ |

_4 columns and 4 rows omitted_
"""

    result = pretty_table(
        String,
        matrix;
        backend = Val(:markdown),
        header  = header,
        max_num_of_rows = 3,
        max_num_of_columns = 3,
        show_omitted_cell_summary = true
    )
    @test result == expected
end
