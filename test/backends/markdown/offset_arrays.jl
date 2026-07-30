## Description #############################################################################
#
# Markdown Back End: Test related with offset arrays.
#
############################################################################################

@testset "Offset Arrays" begin
    matrix = Matrix{Any}(undef, 3, 3)
    matrix[1, 1] = (1, 1)
    matrix[1, 2] = (1, 2)
    matrix[2, 1] = nothing
    matrix[2, 2] = missing
    matrix[3, 3] = (3, 3)

    omatrix = OffsetArray(matrix, -2:0, -3:-1)

    expected = """
| **Row** | **Col. -3** | **Col. -2** | **Col. -1** |
|--------:|------------:|------------:|------------:|
|  **-2** |      (1, 1) |      (1, 2) |      #undef |
|  **-1** |     nothing |     missing |      #undef |
|   **0** |      #undef |      #undef |      (3, 3) |
"""

    result = pretty_table(
        String, omatrix; backend = :markdown, show_row_number_column = true
    )

    @test result == expected
end

@testset "Empty Table With Row Numbers" begin
    # The row number column width used `floor(Int, log10(m) + 1)`, which throws an
    # `InexactError` for an empty table because `log10(0) == -Inf`.
    expected = """
| **Row** | **A** | **B** |
|--------:|------:|------:|
"""

    result = pretty_table(
        String,
        Matrix{Int}(undef, 0, 2);
        backend = :markdown,
        show_row_number_column = true,
        column_labels = [["A", "B"]],
    )

    @test result == expected
end
