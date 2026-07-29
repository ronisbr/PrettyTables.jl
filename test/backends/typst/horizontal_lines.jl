## Description #############################################################################
#
# Typst Back End: Tests related to the horizontal and vertical line specifications.
#
############################################################################################

@testset "Line Specifications" verbose = true begin
    # `horizontal_lines_at_data_rows` and `vertical_lines_at_data_columns` accept either a
    # `Symbol` (`:all` / `:none`) or an explicit `Vector{Int}`. The vector branch is what
    # narrows the field type in the back end, and it must select exactly the requested rows
    # and columns.
    matrix = [1 2 3; 4 5 6]

    @testset "Vector of Indices" begin
        result = pretty_table(
            String,
            matrix;
            backend = :typst,
            table_format = TypstTableFormat(;
                horizontal_lines_at_data_rows  = [1],
                vertical_lines_at_data_columns = [1],
            ),
        )

        # Only the line after the first data row is drawn with the middle stroke.
        @test occursin("table.hline(y: 2, stroke: 0.5pt,),", result)

        # Only the vertical line after the first data column is drawn, so there is no line
        # at `x: 2`.
        @test occursin("table.vline(x: 1, end: 3, stroke: 0.8pt),", result)
        @test !occursin("table.vline(x: 2,", result)
    end

    @testset "All Lines" begin
        result = pretty_table(
            String,
            matrix;
            backend = :typst,
            table_format = TypstTableFormat(;
                horizontal_lines_at_data_rows  = :all,
                vertical_lines_at_data_columns = :all,
            ),
        )

        @test occursin("table.hline(y: 2, stroke: 0.5pt,),", result)

        # Now every interior vertical line must be present.
        @test occursin("table.vline(x: 1, end: 3, stroke: 0.8pt),", result)
        @test occursin("table.vline(x: 2, end: 3, stroke: 0.8pt),", result)
    end
end
