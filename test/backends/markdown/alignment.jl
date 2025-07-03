## Description #############################################################################
#
# Markdown Back End: Tests related with the cell alignment.
# 
############################################################################################

@testset "Alignment" verbose = true begin
    matrix = [(i, j) for i in 1:5, j in 1:5]

    @testset "Alignment as a Symbol" begin
        expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** | **Col. 5** |
|:----------:|:----------:|:----------:|:----------:|:----------:|
|   (1, 1)   |   (1, 2)   |   (1, 3)   |   (1, 4)   |   (1, 5)   |
|   (2, 1)   |   (2, 2)   |     (2, 3) |   (2, 4)   |   (2, 5)   |
|   (3, 1)   |   (3, 2)   |   (3, 3)   |   (3, 4)   |   (3, 5)   |
|   (4, 1)   |   (4, 2)   |   (4, 3)   |   (4, 4)   | (4, 5)     |
|   (5, 1)   |   (5, 2)   |   (5, 3)   |   (5, 4)   |   (5, 5)   |
"""

        result = pretty_table(
            String,
            matrix;
            alignment = :c,
            backend = :markdown,
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected
    end

    @testset "Alignment as a Vector" begin
        expected = """
| **Col. 1** | **Col. 2** | **Col. 3** | **Col. 4** | **Col. 5** |
|:-----------|:----------:|-----------:|:-----------|:----------:|
| (1, 1)     |   (1, 2)   |     (1, 3) | (1, 4)     |   (1, 5)   |
| (2, 1)     |   (2, 2)   |     (2, 3) | (2, 4)     |   (2, 5)   |
| (3, 1)     |   (3, 2)   |     (3, 3) | (3, 4)     |   (3, 5)   |
| (4, 1)     |   (4, 2)   |     (4, 3) | (4, 4)     | (4, 5)     |
| (5, 1)     |   (5, 2)   |     (5, 3) | (5, 4)     |   (5, 5)   |
"""

        result = pretty_table(
            String,
            matrix;
            backend = :markdown,
            alignment = [:l, :c, :r, :l, :c],
            cell_alignment = [(2, 3) => :r, (4, 5) => :l]
        )

        @test result == expected
    end

end
