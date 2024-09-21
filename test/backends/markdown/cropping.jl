## Description #############################################################################
#
# Markdown Back End: Tests related with table cropping.
#
############################################################################################

@testset "Table Cropping" verbose = true begin
    matrix = [(i, j) for i in 1:100, j in 1:100]

    @testset "Bottom Cropping" begin
        expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | ⋯ |
|-----------:|-----------:|-----------:|---|
|     (1, 1) |     (1, 2) |     (1, 3) | ⋯ |
|     (2, 1) |     (2, 2) |     (2, 3) | ⋯ |
|          ⋮ |          ⋮ |          ⋮ | ⋱ |

*97 columns and 98 rows omitted*
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3
        )

        @test result == expected
    end

    @testset "Middle Cropping" begin
        expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | ⋯ |
|-----------:|-----------:|-----------:|---|
|     (1, 1) |     (1, 2) |     (1, 3) | ⋯ |
|          ⋮ |          ⋮ |          ⋮ | ⋱ |
|   (100, 1) |   (100, 2) |   (100, 3) | ⋯ |

*97 columns and 98 rows omitted*
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            vertical_crop_mode = :middle
        )

        @test result == expected
    end

    @testset "Omitted Cell Summary" begin
        expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | ⋯ |
|-----------:|-----------:|-----------:|---|
|     (1, 1) |     (1, 2) |     (1, 3) | ⋯ |
|     (2, 1) |     (2, 2) |     (2, 3) | ⋯ |
|          ⋮ |          ⋮ |          ⋮ | ⋱ |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            maximum_number_of_rows = 2,
            maximum_number_of_columns = 3,
            show_omitted_cell_summary = false
        )

        @test result == expected
    end
end
