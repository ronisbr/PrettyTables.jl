## Description #############################################################################
#
# Text Back End: Test related with offset arrays.
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
┌─────┬─────────┬─────────┬─────────┐
│ Row │ Col. -3 │ Col. -2 │ Col. -1 │
├─────┼─────────┼─────────┼─────────┤
│  -2 │  (1, 1) │  (1, 2) │  #undef │
│  -1 │ nothing │ missing │  #undef │
│   0 │  #undef │  #undef │  (3, 3) │
└─────┴─────────┴─────────┴─────────┘
"""

    result = pretty_table(String, omatrix; show_row_number_column = true)

    @test result == expected
end

@testset "Summary Rows With Offset Columns" begin
    # The summary row path used the raw 1-based print index instead of offsetting it by
    # `first_column_index`. Hence, the summaries of the first columns were silently computed
    # from the wrong source column before the last one threw a `BoundsError`.
    data = OffsetArray([1 2 3; 4 5 6; 7 8 9], -1:1, 0:2)

    expected = """
┌─────┬────────┬────────┬────────┐
│     │ Col. 0 │ Col. 1 │ Col. 2 │
├─────┼────────┼────────┼────────┤
│     │      1 │      2 │      3 │
│     │      4 │      5 │      6 │
│     │      7 │      8 │      9 │
├─────┼────────┼────────┼────────┤
│ Sum │     12 │     15 │     18 │
└─────┴────────┴────────┴────────┘
"""

    result = pretty_table(String, data; summary_rows = [sum], summary_row_labels = ["Sum"])

    @test result == expected
end

@testset "Row Number Column Width With Offset Rows" begin
    # The row number column width was computed from the row *count* instead of from the
    # actual row indices, so a non 1-based row axis overflowed the column and broke the
    # borders.
    data = OffsetArray(reshape(collect(1:6), 2, 3), -1000:-999, 1:3)

    expected = """
┌───────┬────────┬────────┬────────┐
│   Row │ Col. 1 │ Col. 2 │ Col. 3 │
├───────┼────────┼────────┼────────┤
│ -1000 │      1 │      3 │      5 │
│  -999 │      2 │      4 │      6 │
└───────┴────────┴────────┴────────┘
"""

    result = pretty_table(String, data; show_row_number_column = true)

    @test result == expected
end
